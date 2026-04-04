#!/usr/bin/perl
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
# bench-stemming.pl — benchmark accuracy, speed and memory of word stemming,
# multilingual stopwords and language detection in POPFile.
#
# Usage:  perl -I t/lib -I . t/bench-stemming.pl
#
# Four configurations:
#   baseline  stemming=0, auto_detect_language=0
#   stemming  stemming=1, auto_detect_language=0
#   lang-det  stemming=0, auto_detect_language=1
#   all       stemming=1, auto_detect_language=1

use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";
use POPFile::Features;

use File::Temp qw(tempdir tempfile);
use Time::HiRes qw(gettimeofday tv_interval);
use List::Util qw(shuffle);

use TestHelper;

# ---------------------------------------------------------------------------
# Corpus design
#
# The key challenge for the classifier:
#   - Spam/ham share some vocabulary (e.g. "free", "offer" appear in both)
#   - Test set uses morphological variants not seen in training (to expose
#     where stemming helps: train "win" / test "winning", "winner", "wins")
#   - Three languages (EN / DE / FR)
# ---------------------------------------------------------------------------

# Core word pools per language per class.
# TRAIN_ONLY words appear only in training data.
# TEST_VARIANT words appear in test data as morphological variants of TRAIN_ONLY words.

my %CORPUS = (
    en => {
        spam => {
            train => [qw(
                buy purchase offer bargain discount deal coupon promo
                free gratis prize lottery win reward cash refund
                click subscribe limited urgent alert warning immediately
                earn profit invest speculate scheme doubling tripling
                cheap affordable medication pill prescription pharmacy
            )],
            test_variants => [qw(
                buying purchased offers bargains discounts deals coupons
                freely prizes lotteries wins rewards clicks subscribing
                earnings profitable investing speculating schemes doubles
            )],
        },
        ham => {
            train => [qw(
                meeting schedule agenda standup sync retrospective
                project milestone deadline deliverable sprint backlog
                report analysis summary findings recommendation proposal
                budget forecast revenue estimate approval review
                colleague manager director team member stakeholder
            )],
            test_variants => [qw(
                meetings scheduled agendas standups syncing retrospectives
                projects milestones deadlines deliverables sprints
                reports analyzed summarized findings recommends proposals
                budgets forecasting revenues estimates approvals reviewing
            )],
        },
        stopwords_train => [qw(the a an is are was were be been being
                               have has had do does did will would could
                               should may might shall can to of in on at)],
    },
    de => {
        spam => {
            train => [qw(
                kaufen angebot rabatt gutschein promo sonderangebot
                kostenlos gratis gewinn lotterie gewinnen belohnung geld
                klicken abonnieren begrenzt dringend sofort
                verdienen gewinn investieren spekulation verdoppeln
                billig günstig medikament pille rezept apotheke
            )],
            test_variants => [qw(
                kaufte angebote rabatte gutscheine angeboten sonderangebote
                gewonnen lotterien gewinnt belohnungen klickte abonniert
                verdient gewinne investiert spekuliert verdoppelt
            )],
        },
        ham => {
            train => [qw(
                besprechung zeitplan tagesordnung standup synchronisation
                projekt meilenstein frist liefergegenstand sprint rückstand
                bericht analyse zusammenfassung empfehlung vorschlag
                budget prognose umsatz schätzung genehmigung überprüfung
                kollege manager direktor team mitglied stakeholder
            )],
            test_variants => [qw(
                besprechungen zeitpläne tagesordnungen standups
                projekte meilensteine fristen liefergegenstände sprints
                berichte analysen zusammenfassungen empfehlungen vorschläge
                budgets prognosen umsätze schätzungen genehmigungen
            )],
        },
    },
    fr => {
        spam => {
            train => [qw(
                acheter offre remise coupon promo promotion
                gratuit prix loterie gagner récompense argent
                cliquer abonner limité urgent immédiatement
                gagner profit investir spéculer doubler
                pas-cher médicament pilule ordonnance pharmacie
            )],
            test_variants => [qw(
                achetant acheté offres remises coupons promotions
                gagnez loteries gagne récompenses cliqué abonné
                gagnant profits investissant spécule doublant
            )],
        },
        ham => {
            train => [qw(
                réunion calendrier ordre-du-jour standup synchronisation
                projet jalon délai livrable sprint backlog
                rapport analyse résumé recommandation proposition
                budget prévision revenus estimation approbation révision
                collègue responsable directeur équipe membre partie-prenante
            )],
            test_variants => [qw(
                réunions calendriers ordres-du-jour standups
                projets jalons délais livrables sprints
                rapports analyses résumés recommandations propositions
                budgets prévisions revenus estimations approbations
            )],
        },
    },
);

# Shared words that appear in BOTH spam and ham (makes classification harder)
my @NOISE_EN = qw(important information message update news special contact);
my @NOISE_DE = qw(wichtig information nachricht aktualisierung neuigkeiten);
my @NOISE_FR = qw(important information message mise-à-jour nouvelles);

sub pick_n($aref, $n) {
    my @pool = @{$aref};
    my @out;
    push @out, $pool[int(rand(@pool))] for 1..$n;
    @out
}

sub make_email($lang, $class, $use_variants, $idx) {
    srand($idx * 137 + ($lang eq 'en' ? 0 : $lang eq 'de' ? 1000 : 2000)
          + ($class eq 'spam' ? 0 : 5000));

    my $pool = $CORPUS{$lang}{$class};
    my $noise = $lang eq 'en' ? \@NOISE_EN : $lang eq 'de' ? \@NOISE_DE : \@NOISE_FR;

    my @body;
    if ($use_variants) {
        # test emails: 60% core training words + 40% morphological variants
        # baseline classifier can still classify from the 60% core
        # stemming helps even more by recognising the 40% variants
        push @body, pick_n($pool->{train},         12);
        push @body, pick_n($pool->{test_variants},  8);
    } else {
        push @body, pick_n($pool->{train}, 20);
    }
    push @body, pick_n($noise, 3);
    # also include some stop-like words to test stopword filtering
    push @body, @{$CORPUS{en}{stopwords_train}} if $lang eq 'en';

    my %subj = (
        en => { spam => 'Important offer for you', ham => 'Project update' },
        de => { spam => 'Wichtiges Angebot',        ham => 'Projektaktualisierung' },
        fr => { spam => 'Offre importante',         ham => 'Mise à jour projet' },
    );
    my %from = (
        en => { spam => 'deals@promo.example.com',       ham => 'alice@work.example.com' },
        de => { spam => 'angebot@promo.example.de',      ham => 'anna@arbeit.example.de' },
        fr => { spam => 'offre@promo.example.fr',        ham => 'marie@travail.example.fr' },
    );

    my $body = join(' ', shuffle(@body));
    return "From: $from{$lang}{$class}\nTo: me\@example.com\n" .
           "Subject: $subj{$lang}{$class}\n" .
           "MIME-Version: 1.0\nContent-Type: text/plain; charset=utf-8\n\n" .
           "$body\n"
}

# Build corpus: 60 train + 20 test per language per class
my (@train_msgs, @test_msgs);
my $idx = 0;
for my $lang (qw(en de fr)) {
    for my $class (qw(spam ham)) {
        for my $i (0..59) {
            push @train_msgs, { class => $class, lang => $lang,
                                body => make_email($lang, $class, 0, $idx++) };
        }
        for my $i (0..19) {
            push @test_msgs, { class => $class, lang => $lang,
                               body => make_email($lang, $class, 1, $idx++) };
        }
    }
}
@train_msgs = shuffle(@train_msgs);

# ---------------------------------------------------------------------------
# Benchmark helpers
# ---------------------------------------------------------------------------

sub rss_kb {
    open my $fh, '<', "/proc/$$/status" or return 0;
    while (<$fh>) { return (split /\s+/, $_)[1] if /^VmRSS/ }
    0
}

sub run_scenario($label, %cfg) {

    my ($config, $mq, $tmpdir) = TestHelper::setup();
    my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);
    $wm->config('stemming',             $cfg{stemming}             // 0);
    $wm->config('auto_detect_language', $cfg{auto_detect_language} // 0);
    $wm->set_language('en');

    my $session = TestHelper::reset_db($bayes, $config);
    $bayes->create_bucket($session, 'spam');
    $bayes->create_bucket($session, 'ham');

    my $mem0 = rss_kb();
    my $t0 = [gettimeofday];

    for my $msg (@train_msgs) {
        my ($fh, $fname) = tempfile(DIR => $tmpdir, SUFFIX => '.eml', UNLINK => 1);
        binmode $fh, ':encoding(UTF-8)';
        print $fh $msg->{body};
        close $fh;
        $bayes->add_message_to_bucket($session, $msg->{class}, $fname);
    }

    my $train_s = tv_interval($t0);
    my $mem1 = rss_kb();
    my $vocab = $bayes->db()->selectrow_array('select count(*) from words')  // 0;
    my $matrix = $bayes->db()->selectrow_array('select count(*) from matrix') // 0;

    # Classify test set — warm up cache first (1 pass), then time second pass
    my @test_files;
    for my $msg (@test_msgs) {
        my ($fh, $fname) = tempfile(DIR => $tmpdir, SUFFIX => '.eml', UNLINK => 0);
        binmode $fh, ':encoding(UTF-8)';
        print $fh $msg->{body};
        close $fh;
        push @test_files, { fname => $fname, class => $msg->{class}, lang => $msg->{lang} };
    }

    # Warm up
    for my $tf_w (@test_files) {
        $bayes->classify($session, $tf_w->{fname});
    }

    # Timed run
    my ($correct, $correct_en, $correct_de, $correct_fr) = (0) x 4;
    my $t1 = [gettimeofday];
    for my $tf (@test_files) {
        my ($bucket) = $bayes->classify($session, $tf->{fname});
        my $ok = defined $bucket && $bucket eq $tf->{class};
        $correct++ if $ok;
        $correct_en++ if $ok && $tf->{lang} eq 'en';
        $correct_de++ if $ok && $tf->{lang} eq 'de';
        $correct_fr++ if $ok && $tf->{lang} eq 'fr';
    }
    my $cls_s = tv_interval($t1);
    my $mem2 = rss_kb();
    my $total = scalar @test_files;

    return {
        label => $label,
        accuracy => $total ? $correct / $total : 0,
        acc_en => $correct_en,
        acc_de => $correct_de,
        acc_fr => $correct_fr,
        correct => $correct,
        total => $total,
        vocab => $vocab,
        matrix => $matrix,
        train_s => $train_s,
        cls_us => $total ? $cls_s / $total * 1_000_000 : 0,
        mem_train_kb => $mem1 - $mem0,
        mem_cls_kb => $mem2 - $mem1,
    }
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

printf "Corpus: %d train / %d test  (EN+DE+FR, morphological variants in test)\n\n",
    scalar @train_msgs, scalar @test_msgs;

my @R;
push @R, run_scenario('baseline', stemming => 0, auto_detect_language => 0);
push @R, run_scenario('stemming', stemming => 1, auto_detect_language => 0);
push @R, run_scenario('lang-det', stemming => 0, auto_detect_language => 1);
push @R, run_scenario('all',      stemming => 1, auto_detect_language => 1);

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------
printf "%-10s  %8s  %5s  %5s  %8s  %10s  %5s  %5s  %5s\n",
    '', 'Accuracy', 'Vocab', 'Mtrx', 'Train(s)', 'Cls(µs)', 'EN', 'DE', 'FR';
print '-' x 72, "\n";

my $per_lang = 40;  # 20 test per class × 2 classes
for my $r (@R) {
    printf "%-10s  %7.1f%%  %5d  %5d  %8.3f  %10.0f  %4d  %4d  %4d\n",
        $r->{label},
        $r->{accuracy} * 100,
        $r->{vocab},
        $r->{matrix},
        $r->{train_s},
        $r->{cls_us},
        $r->{acc_en},
        $r->{acc_de},
        $r->{acc_fr};
}

print "\n--- vs baseline ---\n";
my $b = $R[0];
for my $r (@R[1..$#R]) {
    my $dacc = sprintf('%+.1f pp', ($r->{accuracy} - $b->{accuracy}) * 100);
    my $dvoc = sprintf('%+.0f%%', ($r->{vocab}  - $b->{vocab})  / ($b->{vocab}  || 1) * 100);
    my $dmtrx = sprintf('%+.0f%%', ($r->{matrix} - $b->{matrix}) / ($b->{matrix} || 1) * 100);
    my $dcls = sprintf('%+.0f%%', ($r->{cls_us} - $b->{cls_us}) / ($b->{cls_us} || 1) * 100);
    my $dtrn = sprintf('%+.0f%%', ($r->{train_s} - $b->{train_s}) / ($b->{train_s} || 1) * 100);
    printf "%-10s  accuracy %s  vocab %s  matrix %s  train %s  classify %s\n",
        $r->{label}, $dacc, $dvoc, $dmtrx, $dtrn, $dcls;
}

printf "\n(test set: %d msgs total, %d per language)\n", scalar @test_msgs, $per_lang;
printf "Note: test set uses morphological variants not seen in training.\n";
printf "      Language detection overhead from Lingua::Identify on 1 KB sample.\n";
