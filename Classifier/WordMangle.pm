# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Classifier::WordMangle;

use Object::Pad;

use locale;
use Lingua::Stem::Snowball;
use Lingua::StopWords;

# These are used for Japanese support

my $ascii = '[\x00-\x7F]';
my $two_bytes_euc_jp = '(?:[\x8E\xA1-\xFE][\xA1-\xFE])';
my $three_bytes_euc_jp = '(?:\x8F[\xA1-\xFE][\xA1-\xFE])';
my $euc_jp = "(?:$ascii|$two_bytes_euc_jp|$three_bytes_euc_jp)";

my %snowball_languages = map { $_ => 1 }
    qw(da nl en fi fr de hu it no pt ro ru es sv tr);

my %ui_to_iso = (
    English => 'en', German => 'de', French => 'fr',
    Spanish => 'es', Italian => 'it', Dutch => 'nl',
    Portuguese => 'pt', Swedish => 'sv', Norwegian => 'no',
    Danish => 'da', Finnish => 'fi', Hungarian => 'hu',
    Romanian => 'ro', Russian => 'ru', Turkish => 'tr',
);

class Classifier::WordMangle :isa(POPFile::Module);

field %stop__;
field $language = 'en';
field $stemmer = undef;

BUILD {
    $self->set_name('wordmangle');
}

=head1 NAME

Classifier::WordMangle — normalise and filter words before classification

=head1 DESCRIPTION

Prepares raw words extracted from email messages for use by the Bayesian
classifier.  Responsibilities:

=over 4

=item *

Stop-word filtering — words on the user-editable stopwords list are dropped.

=item *

Word normalisation — lowercasing, stripping of special characters, length
limits, and hex-string rejection.

=item *

Optional Snowball stemming — reduces inflected forms to their stem so that
"running" and "runs" count as the same token.

=item *

Language support — loads the correct stop-word list and stemmer for the
current UI language.

=back

=head1 METHODS

=head2 initialize

Registers the C<stemming> and C<auto_detect_language> configuration
parameters.  Returns 1.

=cut

    method initialize() {
        $self->config('stemming',             0);
        $self->config('auto_detect_language', 1);
        return 1
    }

=head2 start

Loads the stopwords file and initialises the stemmer and stop-word list for
the current language.  Returns 1.

=cut

    method start() {
        $self->_init_language($language);
        return 1
    }

    method _init_language ($lang) {
        $language = $lang;
        $stemmer = undef;
        if ($self->config('stemming') && $snowball_languages{$lang}) {
            $stemmer = Lingua::Stem::Snowball->new(lang => $lang, encoding => 'UTF-8');
        }
        %stop__ = ();
        my $sw = Lingua::StopWords::getStopWords($lang, 'UTF-8') // {};
        $stop__{$_} = 1 for keys $sw->%*;
    }

=head2 set_language($lang)

Sets the active language using a two-letter ISO 639-1 code (e.g. C<'en'>,
C<'de'>).  Reinitialises the stemmer and stop-word list accordingly.

=cut

    method set_language ($lang) {
        $self->_init_language($lang);
    }

=head2 set_ui_language($ui_name)

Sets the active language from a human-readable UI name (e.g. C<'German'>).
Translates to the corresponding ISO 639-1 code and delegates to
L</set_language>.

=cut

    method set_ui_language ($ui_name) {
        $self->_init_language($ui_to_iso{$ui_name} // 'en');
    }

=head2 get_language

Returns the current ISO 639-1 language code.

=cut

    method get_language() { $language }

=head2 mangle($word, $allow_colon, $ignore_stops)

Normalises C<$word> for use as a classifier token.  Returns the normalised
word, or an empty string if the word should be discarded.

Discards the word when it:

=over 4

=item * is empty after lowercasing

=item * is in the stop-word list (unless C<$ignore_stops> is true)

=item * is longer than 45 characters

=item * looks like a hex string (8 or more hex digits)

=item * is an HTML pseudo-token that carries an embedded value with no
classification signal: C<html:css*>, C<html:comment>, C<html:fontcolor*>,
C<html:backcolor*>, C<html:fontsize*>, C<html:imgwidth*>, C<html:imgheight*>

=item * is C<zwnj> or C<zwj> — zero-width character HTML entity name
artifacts that survive undecoded in the email text

=item * is a plain word (no colon) starting with C<hg>, C<bk>, or C<dk>,
or containing the bigram C<jk> — consonant pairs that do not appear in any
supported language, indicating a random opaque token (tracking ID, CSS class
name hash, etc.)

=back

Strips colons unless C<$allow_colon> is true (colons separate header-field
tokens such as C<content-type:text/plain>).  If stemming is enabled and the
word contains no colon, applies the Snowball stemmer.

=cut

    method mangle ($word, $allow_colon = undef, $ignore_stops = undef) {
        my $lcword = lc($word);

        return '' unless $lcword;

        return '' if (($stop__{$lcword} || $stop__{$word})
                       && !defined($ignore_stops));

        $lcword =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.|\\)/\./g;

        return '' if length($lcword) > 45;

        return '' if $lcword =~ /^[A-F0-9]{8,}$/i;

        return '' if $lcword =~ /^html:(?:css|fontcolor|backcolor|fontsize|imgwidth|imgheight)/;
        return '' if $lcword eq 'html:comment';

        return '' if $lcword eq 'zwnj' || $lcword eq 'zwj';

        return '' if !defined($allow_colon)
            && ( $lcword =~ /^(?:hg|bk|dk)/ || $lcword =~ /jk/ );

        $lcword =~ s/://g unless defined $allow_colon;

        my $result = ($lcword =~ /:/) ? $word : $lcword;

        if (defined $stemmer && $result !~ /:/) {
            my $stemmed = $stemmer->stem($result);
            $result = $stemmed if defined $stemmed && $stemmed ne '';
        }

        return $result
    }

=head2 mangle_words($word)

Like L</mangle>, but first splits C<$word> on any single colon that is not
part of a C<::> sequence (e.g. C<word1:word2> → C<word1>, C<word2>), then
mangles each part.  Colons inside C<::> are left for the normal colon-strip
pass inside L</mangle>.

Returns a (possibly empty) list of mangled tokens.

=cut

    method mangle_words ($word) {
        my @parts = split /(?<!:):(?!:)/, $word;
        return grep { $_ ne '' } map { $self->mangle($_) } @parts
    }

=head2 stopwords

Returns the list of current stop words.  If C<$value> is a hashref, replaces the list.

=cut
    method stopwords($value = undef) { keys %stop__ }

1;
