#!/usr/bin/perl
BEGIN {
    @INC = grep { !/\/lib$/ && $_ ne 'lib' && !/thread-multi/ } @INC;
    require FindBin;
    require Cwd;
    my $root = Cwd::abs_path("$FindBin::Bin/..");
    require lib;
    lib->import("$root/local/lib/perl5");
    unshift @INC, "$FindBin::Bin/lib", $root;
}
use strict;
use warnings;

use Test2::V0;
use Test::Mojo;
use File::Temp qw(tempdir tempfile);

my $tmpdir = tempdir(CLEANUP => 1);

my ($fh, $fixture_file) = tempfile(DIR => $tmpdir, SUFFIX => '.msg');
print $fh "From: alice\@example.com\r\nSubject: Test\r\n\r\nThis is a ham message.\r\n";
close $fh;

my %slots = (
    1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test', '2024-01-01', 'abc', time(), 'ham', undef, 1, '', 100], file => $fixture_file, bucket => 'ham' },
    2 => { fields => [2, 'spammer@evil.com',  'bob@example.com', '', 'Win', '2024-01-02', 'def', time(), 'unclassified', undef, 2, '', 200], file => $fixture_file, bucket => 'unclassified' },
);

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa');

my $mock_hist = bless {
    slots => \%slots,
    queries => {},
    next_qid => 1,
}, 'MockHist';

my $mock_svc = bless {
    hist => $mock_hist,
    buckets => \%buckets,
}, 'MockSvc';

require UI::Mojo;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $ui = UI::Mojo->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($mock_svc);

my $app = $ui->build_app($mock_svc, 'test-session');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/history returns items and total' => sub {
    $t->get_ok('/api/v1/history')
      ->status_is(200)
      ->json_has('/items')
      ->json_has('/total');
    my $data = $t->tx->res->json;
    is($data->{total}, 2, 'total matches slot count');
    is(scalar @{$data->{items}}, 2, 'items count matches');
};

subtest 'GET /api/v1/history pagination' => sub {
    $t->get_ok('/api/v1/history?page=1&per_page=1')
      ->status_is(200);
    my $data = $t->tx->res->json;
    is($data->{total}, 2, 'total still 2');
    is(scalar @{$data->{items}}, 1, 'per_page=1 returns 1 item');
};

subtest 'GET /api/v1/history/:slot valid slot' => sub {
    $t->get_ok('/api/v1/history/1')
      ->status_is(200)
      ->json_has('/body')
      ->json_has('/word_colors');
    my $data = $t->tx->res->json;
    like($data->{body}, qr/ham/, 'body contains message text');
};

subtest 'GET /api/v1/history/:slot invalid slot returns 404' => sub {
    $t->get_ok('/api/v1/history/999')
      ->status_is(404);
};

subtest 'POST /api/v1/history/:slot/reclassify changes bucket' => sub {
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
      ->status_is(200)
      ->json_is('/ok', 1);
    is($slots{1}{bucket}, 'spam', 'bucket updated in mock');
};

subtest 'POST /api/v1/history/:slot/reclassify unknown bucket returns 422' => sub {
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'nosuchbucket' })
      ->status_is(422)
      ->json_has('/error');
};

subtest 'POST /api/v1/history/bulk-reclassify returns updated count' => sub {
    $slots{1}{bucket} = 'ham';
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { slots => [1, 2], bucket => 'spam' })
      ->status_is(200)
      ->json_has('/updated');
    my $data = $t->tx->res->json;
    ok($data->{updated} >= 1, 'at least one slot updated');
};

subtest 'POST /api/v1/history/bulk-reclassify missing params returns 400' => sub {
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { slots => [] })
      ->status_is(400);
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { bucket => 'spam' })
      ->status_is(400);
};

subtest 'POST /api/v1/history/reclassify-unclassified returns updated and total' => sub {
    $slots{2}{bucket} = 'unclassified';
    $t->post_ok('/api/v1/history/reclassify-unclassified')
      ->status_is(200)
      ->json_has('/updated')
      ->json_has('/total');
};

done_testing;

package MockHist;

sub get_search_queries {
    my ($self, %args) = @_;
    my $bucket = $args{bucket} // '';
    my $search = $args{search} // '';
    my $page = $args{page} // 1;
    my $per_page = $args{per_page} // 25;
    my @ids = sort { $a <=> $b } grep {
        my $s = $self->{slots}{$_};
        ($bucket eq '' || $s->{bucket} eq $bucket)
        && ($search eq '' || $s->{fields}[1] =~ /\Q$search\E/i || $s->{fields}[4] =~ /\Q$search\E/i)
    } keys %{$self->{slots}};
    my $total = scalar @ids;
    my $offset = ($page - 1) * $per_page;
    my @page_ids = splice(@ids, $offset, $per_page);
    my @rows = map {
        my $f = $self->{slots}{$_}{fields};
        { slot => $f->[0], from => $f->[1], to => $f->[2], cc => $f->[3],
          subject => $f->[4], date => $f->[5], hash => $f->[6],
          inserted => $f->[7], bucket => $f->[8], usedtobe => $f->[9],
          bucket_id => $f->[10], magnet => $f->[11], size => $f->[12] }
    } @page_ids;
    return ($total, \@rows)
}

sub start_query {
    my ($self) = @_;
    my $qid = $self->{next_qid}++;
    $self->{queries}{$qid} = { filter => '', search => '' };
    return $qid
}

sub stop_query {
    my ($self, $qid) = @_;
    delete $self->{queries}{$qid};
}

sub set_query {
    my ($self, $qid, $filter, $search, $sort, $not) = @_;
    $self->{queries}{$qid}{filter} = $filter // '';
    $self->{queries}{$qid}{search} = $search // '';
}

sub get_query_size {
    my ($self, $qid) = @_;
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @matching = grep {
        $filter eq '' || $self->{slots}{$_}{bucket} eq $filter
    } keys %{$self->{slots}};
    return scalar @matching
}

sub get_query_rows {
    my ($self, $qid, $start, $count) = @_;
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @ids = sort { $a <=> $b } grep {
        $filter eq '' || $self->{slots}{$_}{bucket} eq $filter
    } keys %{$self->{slots}};
    my @page = splice(@ids, $start - 1, $count);
    return map { $self->{slots}{$_}{fields} } @page
}

sub get_slot_file {
    my ($self, $slot) = @_;
    return $self->{slots}{$slot} ? $self->{slots}{$slot}{file} : undef
}

sub get_slot_fields {
    my ($self, $slot) = @_;
    return () unless $self->{slots}{$slot};
    return @{$self->{slots}{$slot}{fields}}
}

sub change_slot_classification {
    my ($self, $slot, $class, $session, $undo) = @_;
    return unless $self->{slots}{$slot};
    $self->{slots}{$slot}{fields}[8] = $class;
    $self->{slots}{$slot}{bucket} = $class;
}

package MockSvc;

sub history_obj { return $_[0]->{hist} }
sub bayes { return undef }

sub get_all_buckets { return keys %{$_[0]->{buckets}} }

sub is_bucket {
    my ($self, $name) = @_;
    return exists $self->{buckets}{$name} ? 1 : 0
}

sub is_pseudo_bucket { return 0 }

sub get_bucket_color {
    my ($self, $name) = @_;
    return $self->{buckets}{$name} // '#666666'
}

sub get_bucket_word_count { return 0 }
sub get_bucket_parameter { return 0 }
sub get_bucket_word_list { return () }
sub create_bucket {
    my ($self, $name) = @_;
    return 0 if exists $self->{buckets}{$name};
    $self->{buckets}{$name} = '#666666';
    return 1
}
sub delete_bucket { }
sub rename_bucket { }
sub clear_bucket { }
sub set_bucket_color { }
sub get_magnet_types { return () }
sub get_buckets_with_magnets { return () }
sub get_magnet_types_in_bucket { return () }
sub get_magnets { return () }
sub create_magnet { }
sub delete_magnet { }
sub remove_message_from_bucket { }
sub add_message_to_bucket { }

sub classify {
    my ($self, $file) = @_;
    return 'ham'
}

sub mangle_word {
    my ($self, $word) = @_;
    return lc($word)
}

sub get_word_colors {
    my ($self, @words) = @_;
    return ()
}

package StubMQ;
sub post { }
sub register { }
