package Classifier::MailParse;

# ----------------------------------------------------------------------------
#
# MailParse.pm --- Parse a mail message or messages into words
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# ----------------------------------------------------------------------------

use Object::Pad;
use locale;

use MIME::Base64;
use MIME::QuotedPrint;

use HTML::Tagset;

# Korean characters definition

my $ksc5601_sym   = '(?:[\xA1-\xAC][\xA1-\xFE])';
my $ksc5601_han   = '(?:[\xB0-\xC8][\xA1-\xFE])';
my $ksc5601_hanja = '(?:[\xCA-\xFD][\xA1-\xFE])';
my $ksc5601       = "(?:$ksc5601_sym|$ksc5601_han|$ksc5601_hanja)";

my $eksc = "(?:$ksc5601|[\x81-\xC6][\x41-\xFE])"; #extended ksc

# These are used for Japanese support

my %encoding_candidates = (    'Nihongo' => [ 'cp932', 'euc-jp', '7bit-jis' ]
);
my $ascii              = '[\x00-\x7F]';                                      # ASCII chars
my $two_bytes_euc_jp   = '(?:[\x8E\xA1-\xFE][\xA1-\xFE])';                   # 2bytes EUC-JP chars
my $three_bytes_euc_jp = '(?:\x8F[\xA1-\xFE][\xA1-\xFE])';                   # 3bytes EUC-JP chars
my $euc_jp             = "(?:$ascii|$two_bytes_euc_jp|$three_bytes_euc_jp)"; # EUC-JP chars

# Symbols in EUC-JP chars which cannot be considered a part of words

my $symbol_row1_euc_jp = '(?:[\xA1][\xA1-\xBB\xBD-\xFE])';
my $symbol_row2_euc_jp = '(?:[\xA2][\xA1-\xFE])';
my $symbol_row8_euc_jp = '(?:[\xA8][\xA1-\xFE])';
my $symbol_euc_jp      = "(?:$symbol_row1_euc_jp|$symbol_row2_euc_jp|$symbol_row8_euc_jp)";

# Cho-on kigou(symbol in Japanese), a special symbol which can appear
# in middle of words

my $cho_on_symbol = '(?:\xA1\xBC)';

# Non-symbol EUC-JP chars

my $non_symbol_two_bytes_euc_jp = '(?:[\x8E\xA3-\xA7\xB0-\xFE][\xA1-\xFE])';
my $non_symbol_euc_jp = "(?:$non_symbol_two_bytes_euc_jp|$three_bytes_euc_jp|$cho_on_symbol)";

# Constants for the internal wakachigaki parser.
# Kind of EUC-JP chars
my $euc_jp_symbol    = '[\xA1\xA2\xA6-\xA8\xAD\xF9-\xFC][\xA1-\xFE]';                # The symbols make a word of one character.
my $euc_jp_alphanum  = '(?:\xA3[\xB0-\xB9\xC1-\xDA\xE1-\xFA])+';                     # One or more alphabets and numbers
my $euc_jp_hiragana  = '(?:(?:\xA4[\xA1-\xF3])+(?:\xA1[\xAB\xAC\xB5\xB6\xBC])*)+';   # One or more Hiragana characters
my $euc_jp_katakana  = '(?:(?:\xA5[\xA1-\xF6])+(?:\xA1[\xA6\xBC\xB3\xB4])*)+';       # One or more Katakana characters
my $euc_jp_hkatakana = '(?:\x8E[\xA6-\xDF])+';                                       # One or more Half-width Katakana characters
my $euc_jp_kanji     = '[\xB0-\xF4][\xA1-\xFE](?:[\xB0-\xF4][\xA1-\xFE]|\xA1\xB9)?'; # One or two Kanji characters

my $euc_jp_word = '(' .    $euc_jp_alphanum .     '|' . 
    $euc_jp_hiragana .     '|' . 
    $euc_jp_katakana .     '|' . 
    $euc_jp_hkatakana .    '|' . 
    $euc_jp_kanji .        '|' . 
    $euc_jp_symbol .       '|' . 
    $ascii .              '+|' .
    $three_bytes_euc_jp . ')';
# HTML entity mapping to character codes, this maps things like &amp;
# to their corresponding character code

my %entityhash = (          'aacute' => 225, 'Aacute' => 193, 'Acirc'  => 194, 'acirc'  => 226,
          'acute'  => 180, 'AElig'  => 198, 'aelig'  => 230, 'Agrave' => 192,
          'agrave' => 224, 'amp'    => 38,  'Aring'  => 197, 'aring'  => 229,
          'atilde' => 227, 'Atilde' => 195, 'Auml'   => 196, 'auml'   => 228,
          'brvbar' => 166, 'ccedil' => 231, 'Ccedil' => 199, 'cedil'  => 184,
          'cent'   => 162, 'copy'   => 169, 'curren' => 164, 'deg'    => 176,
          'divide' => 247, 'Eacute' => 201, 'eacute' => 233, 'ecirc'  => 234,
          'Ecirc'  => 202, 'Egrave' => 200, 'egrave' => 232, 'ETH'    => 208,
          'eth'    => 240, 'Euml'   => 203, 'euml'   => 235, 'frac12' => 189,
          'frac14' => 188, 'frac34' => 190, 'iacute' => 237, 'Iacute' => 205,
          'icirc'  => 238, 'Icirc'  => 206, 'iexcl'  => 161, 'igrave' => 236,
          'Igrave' => 204, 'iquest' => 191, 'iuml'   => 239, 'Iuml'   => 207,
          'laquo'  => 171, 'macr'   => 175, 'micro'  => 181, 'middot' => 183,
          'nbsp'   => 160, 'not'    => 172, 'ntilde' => 241, 'Ntilde' => 209,
          'oacute' => 243, 'Oacute' => 211, 'Ocirc'  => 212, 'ocirc'  => 244,
          'Ograve' => 210, 'ograve' => 242, 'ordf'   => 170, 'ordm'   => 186,
          'oslash' => 248, 'Oslash' => 216, 'Otilde' => 213, 'otilde' => 245,
          'Ouml'   => 214, 'ouml'   => 246, 'para'   => 182, 'plusmn' => 177,
          'pound'  => 163, 'raquo'  => 187, 'reg'    => 174, 'sect'   => 167,
          'shy'    => 173, 'sup1'   => 185, 'sup2'   => 178, 'sup3'   => 179,
          'szlig'  => 223, 'thorn'  => 254, 'THORN'  => 222, 'times'  => 215,
          'Uacute' => 218, 'uacute' => 250, 'ucirc'  => 251, 'Ucirc'  => 219,
          'ugrave' => 249, 'Ugrave' => 217, 'uml'    => 168, 'Uuml'   => 220,
          'uuml'   => 252, 'Yacute' => 221, 'yacute' => 253, 'yen'    => 165,
          'yuml'   => 255 );
# All known HTML tags divided into two groups: tags that generate
# whitespace as in 'foo<br></br>bar' and tags that don't such as
# 'foo<b></b>bar'.  The first case shouldn't count as an empty pair
# because it breaks the line.  The second case doesn't have any visual
# impact and it treated as 'foobar' with an empty pair.

my $spacing_tags = "address|applet|area|base|basefont" .    "|bdo|bgsound|blockquote|body|br|button|caption" .
    "|center|col|colgroup|dd|dir|div|dl|dt|embed" .
    "|fieldset|form|frame|frameset|h1|h2|h3|h4|h5|h6" .
    "|head|hr|html|iframe|ilayer|input|isindex|label" .
    "|legend|li|link|listing|map|menu|meta|multicol" .
    "|nobr|noembed|noframes|nolayer|noscript|object" .
    "|ol|optgroup|option|p|param|plaintext|pre|script" .
    "|select|spacer|style|table|tbody|td|textarea" .
    "|tfoot|th|thead|title|tr|ul|wbr|xmp";
my $non_spacing_tags = "a|abbr|acronym|b|big|blink" .    "|cite|code|del|dfn|em|font|i|img|ins|kbd|q|s" .
    "|samp|small|span|strike|strong|sub|sup|tt|u|var";
my $eol = "\015\012";

# Mapping from HTML color names to hexadecimal values (static, shared across instances)
my %color_map = (         'aliceblue',            'f0f8ff', 'antiquewhite',      'faebd7',
         'aqua',                 '00ffff', 'aquamarine',        '7fffd4',
         'azure',                'f0ffff', 'beige',             'f5f5dc',
         'bisque',               'ffe4c4', 'black',             '000000',
         'blanchedalmond',       'ffebcd', 'blue',              '0000ff',
         'blueviolet',           '8a2be2', 'brown',             'a52a2a',
         'burlywood',            'deb887', 'cadetblue',         '5f9ea0',
         'chartreuse',           '7fff00', 'chocolate',         'd2691e',
         'coral',                'ff7f50', 'cornflowerblue',    '6495ed',
             'cornsilk',             'fff8dc', 'crimson',           'dc143c',
             'cyan',                 '00ffff', 'darkblue',          '00008b',
             'darkcyan',             '008b8b', 'darkgoldenrod',     'b8860b',
             'darkgray',             'a9a9a9', 'darkgreen',         '006400',
             'darkkhaki',            'bdb76b', 'darkmagenta',       '8b008b',
             'darkolivegreen',       '556b2f', 'darkorange',        'ff8c00',
             'darkorchid',           '9932cc', 'darkred',           '8b0000',
             'darksalmon',           'e9967a', 'darkseagreen',      '8fbc8f',
             'darkslateblue',        '483d8b', 'darkturquoise',     '00ced1',
             'darkviolet',           '9400d3', 'deeppink',          'ff1493',
             'deepskyblue',          '00bfff', 'deepskyblue',       '2f4f4f',
             'dimgray',              '696969', 'dodgerblue',        '1e90ff',
             'firebrick',            'b22222', 'floralwhite',       'fffaf0',
             'forestgreen',          '228b22', 'fuchsia',           'ff00ff',
             'gainsboro',            'dcdcdc', 'ghostwhite',        'f8f8ff',
             'gold',                 'ffd700', 'goldenrod',         'daa520',
             'gray',                 '808080', 'green',             '008000',
             'greenyellow',          'adff2f', 'honeydew',          'f0fff0',
             'hotpink',              'ff69b4', 'indianred',         'cd5c5c',
             'indigo',               '4b0082', 'ivory',             'fffff0',
             'khaki',                'f0e68c', 'lavender',          'e6e6fa',
             'lavenderblush',        'fff0f5', 'lawngreen',         '7cfc00',
             'lemonchiffon',         'fffacd', 'lightblue',         'add8e6',
             'lightcoral',           'f08080', 'lightcyan',         'e0ffff',
             'lightgoldenrodyellow', 'fafad2', 'lightgreen',        '90ee90',
             'lightgrey',            'd3d3d3', 'lightpink',         'ffb6c1',
             'lightsalmon',          'ffa07a', 'lightseagreen',     '20b2aa',
             'lightskyblue',         '87cefa', 'lightslategray',    '778899',
             'lightsteelblue',       'b0c4de', 'lightyellow',       'ffffe0',
             'lime',                 '00ff00', 'limegreen',         '32cd32',
             'linen',                'faf0e6', 'magenta',           'ff00ff',
             'maroon',               '800000', 'mediumaquamarine',  '66cdaa',
             'mediumblue',           '0000cd', 'mediumorchid',      'ba55d3',
             'mediumpurple',         '9370db', 'mediumseagreen',    '3cb371',
             'mediumslateblue',      '7b68ee', 'mediumspringgreen', '00fa9a',
             'mediumturquoise',      '48d1cc', 'mediumvioletred',   'c71585',
             'midnightblue',         '191970', 'mintcream',         'f5fffa',
             'mistyrose',            'ffe4e1', 'moccasin',          'ffe4b5',
             'navajowhite',          'ffdead', 'navy',              '000080',
             'oldlace',              'fdf5e6', 'olive',             '808000',
             'olivedrab',            '6b8e23', 'orange',            'ffa500',
             'orangered',            'ff4500', 'orchid',            'da70d6',
             'palegoldenrod',        'eee8aa', 'palegreen',         '98fb98',
             'paleturquoise',        'afeeee', 'palevioletred',     'db7093',
             'papayawhip',           'ffefd5', 'peachpuff',         'ffdab9',
             'peru',                 'cd853f', 'pink',              'ffc0cb',
             'plum',                 'dda0dd', 'powderblue',        'b0e0e6',
             'purple',               '800080', 'red',               'ff0000',
             'rosybrown',            'bc8f8f', 'royalblue',         '4169e1',
             'saddlebrown',          '8b4513', 'salmon',            'fa8072',
             'sandybrown',           'f4a460', 'seagreen',          '2e8b57',
             'seashell',             'fff5ee', 'sienna',            'a0522d',
             'silver',               'c0c0c0', 'skyblue',           '87ceeb',
             'slateblue',            '6a5acd', 'slategray',         '708090',
             'snow',                 'fffafa', 'springgreen',       '00ff7f',
             'steelblue',            '4682b4', 'tan',               'd2b48c',
             'teal',                 '008080', 'thistle',           'd8bfd8',
             'tomato',               'ff6347', 'turquoise',         '40e0d0',
             'violet',               'ee82ee', 'wheat',             'f5deb3',
             'white',                'ffffff', 'whitesmoke',        'f5f5f5',
             'yellow',               'ffff00', 'yellowgreen',       '9acd32'
);
class Classifier::MailParse {
    # Hash of word frequencies
    field %words;
    field $msg_total = 0;

    # Internal buffer for colorized output
    field $ut = '';

    # Optional callback sub($word)->$color set by Bayes when colorized output is needed
    field $color_resolver :reader :writer = undef;

    # From/To/Cc/Subject values captured during parsing
    field $from = '';
    field $to = '';
    field $cc = '';
    field $subject = '';

    # Pairs of magnet-type => magnet-string extracted from headers
    field %quickmagnets;

    # CSS tag names that set the current foreground/background color
    field $cssfontcolortag = '';
    field $cssbackcolortag = '';

    # RGB distance between back and font color (for invisible-ink detection)
    field $htmlcolordistance = 0;

    # Current HTML color state (defaults: white background, black font)
    field $htmlbackcolor = 'ffffff';
    field $htmlbodycolor = 'ffffff';
    field $htmlfontcolor = '000000';

    field $content_type = '';
    field $base64 = '';
    field $in_html_tag = 0;
    field $html_tag = '';
    field $html_arg = '';
    field $html_end = 0;
    field $in_headers = 0;

    field $lang :reader :writer = '';
    field $first20 = '';
    field $first20count = 0;

    # Accumulates soft-wrapped quoted-printable lines
    field $prev = '';

    # Dispatch table for the active Nihongo (Japanese) parser
    field %nihongo_parser;

    # Parsing state: current MIME boundary list, encoding, header name, header value
    field $cur_mime = '';
    field $cur_encoding = '';
    field $cur_header = '';
    field $cur_argument = '';

    # WordMangle instance injected by Bayes
    field $mangle :reader :writer = undef;
    field $date = '';

    field $colorized = '';
    field $charset = '';
    field $debug = 0;
    field $need_kakasi_mutex = 0;
    field $kakasi_mutex = undef;

=head2 get_color__

Returns the highlight color for C<$word> by calling the C<color_resolver>
callback, or an empty string if no resolver is set.

=cut

method get_color__ ($word) {
    return '' unless defined $color_resolver;
    return $color_resolver->($word);
}

=head2 compute_rgb_distance

Computes the Euclidean distance between two C<rrggbb> hex color strings
treated as points in 3-D RGB space. Returns an integer distance.

=cut

method compute_rgb_distance ($left, $right) {
    # TODO: store front/back colors in a RGB hash/array
    #       converting to a hh hh hh format and back
    #       is a waste as is repeatedly decoding
    #       from hh hh hh format

    # Figure out where the left color is and then subtract the right
    # color (point from it) to get the vector

    $left =~ /^(..)(..)(..)$/;
    my ( $rl, $gl, $bl ) = ( hex( $1 ), hex( $2 ), hex( $3 ) );

    $right =~ /^(..)(..)(..)$/;
    my ( $r, $g, $b ) = ( $rl - hex( $1 ), $gl - hex( $2 ), $bl - hex( $3 ) );

    # Now apply Pythagoras in 3D to get the distance between them, we
    # return the int because we don't need decimal level accuracy

    my $distance = int( sqrt( $r*$r + $g*$g + $b*$b ) );

    print "rgb distance: $left -> $right = $distance" if $debug;

    return $distance;
}

=head2 compute_html_color_distance

Updates C<$htmlcolordistance> from the current C<$htmlbackcolor> and
C<$htmlfontcolor> fields via C<compute_rgb_distance>.

=cut

method compute_html_color_distance {
    # TODO: store front/back colors in a RGB hash/array
    #       converting to a hh hh hh format and back
    #       is a waste as is repeatedly decoding
    #       from hh hh hh format

    if ( $htmlfontcolor ne '' && $htmlbackcolor ne '' ) {
        $htmlcolordistance = $self->compute_rgb_distance(            $htmlfontcolor, $htmlbackcolor );    }
}

=head2 map_color

Converts an HTML color value (name, C<#rrggbb>, or IE flex-hex) into
its canonical lowercase C<rrggbb> hexadecimal form.

=cut

method map_color ($color) {
    # The canonical form is lowercase hexadecimal, so start by
    # lowercasing and stripping any initial #

    $color = lc( $color );

    # Map color names to hexadecimal values

    if ( defined( $color_map{$color} ) ) {
        return $color_map{$color};
    } else {
        # Do this after checking the color map, as there is no "#blue" color
        # TODO: The #, however, is optional in IE.. Do we pseudo-word this?

        $color =~ s/^#//;

        my $old_color = $color;

        # Due to a bug/feature in Microsoft Internet Explorer it's
        # possible to use invalid hexadecimal colors where the number
        # 0 is replaced by any other character and if the hex has an
        # uneven multiple of 3 number of characters it is padded on
        # the right with 0s and if the hex is too long, it is divided
        # into even triplets with the leftmost characters in the
        # triplets being significant. Short (1-char) triplets are
        # left-padded with 0's
        # We go one higher than the quotient if the length isn't an
        # even multiple of 3

        my $quotient = int ( ( length( $color ) + 2 ) / 3 );

        # right-pad entire value to get past the next full multiple of
        # the quotient ("abc abc abc" needs at least one more
        # character to make three even triplets)

        $color .= "00" . "0" x $quotient;

        # even length RGB triplets
        my ( $r, $g, $b ) =            ( $color =~ /(.{$quotient})(.{$quotient})(.{$quotient})/ );
        print "$r $g $b\n" if $debug;

        # left-trim very long triplets to 4 bytes
        $r =~ s/.*(.{8})$/$1/;
        $g =~ s/.*(.{8})$/$1/;
        $b =~ s/.*(.{8})$/$1/;

        # right-trim long triplets to get the first two bytes
        $r =~ s/(..).*/$1/;
        $g =~ s/(..).*/$1/;
        $b =~ s/(..).*/$1/;

        # left-pad short triplets (eg FFF -> 0F0F0F)
        $r = '0' . $r if ( length( $r ) == 1 );
        $g = '0' . $g if ( length( $g ) == 1 );
        $b = '0' . $b if ( length( $b ) == 1 );

        $color = "$r$g$b"; # here is our real color value

        # Any non-hex values remaining get 0'd out
        $color =~ s/[^0-9a-f]/0/g;

        if ( $debug ) {            print "hex color $color\n";
            print "flex-hex detected\n" if ( $color ne $old_color );
        }
        # Add pseudo-word anytime flex hex detected

        if ( $color ne $old_color ) {
            $self->update_pseudoword( 'trick:flexhex', $old_color, 0, '' );
        }

        return $color;
    }
}

=head2 increment_word

Increments the raw frequency count for C<$word> without mangling or colorization.

=cut

method increment_word ($word) {
    $words{$word} += 1;
    $msg_total    += 1;

    print "--- $word ($words{$word})\n" if $debug;
}

=head2 update_pseudoword

Adds C<$prefix:$word> to the word frequency table after mangling. Unlike
C<update_word>, no further tokenization is applied. Returns 1 if the
pseudoword was accepted, 0 if filtered by a stopword.

=cut

method update_pseudoword ($prefix, $word, $encoded, $literal) {
    my $mword = $mangle->mangle( "$prefix:$word", 1 );

    if ( $mword ne '' ) {
        if ( defined( $color_resolver ) ) {
            if ( $encoded == 1 ) {
                $literal =~ s/</&lt;/g;
                $literal =~ s/>/&gt;/g;
                my $color = $self->get_color__( $mword );
                my $to    = "<b><font color=\"$color\"><a title=\"$mword\">$literal</a></font></b>";
                $ut .= $to . ' ';
            }
        }

        $self->increment_word( $mword );
        return 1;
    }

    return 0;
}

=head2 update_word

Mangles and adds C<$word> to the frequency table. C<$encoded> is 1 for
base64 content, C<$before>/C<$after> are surrounding characters for
colorization anchoring, and C<$prefix> is prepended to the mangled word
(e.g. C<"from">, C<"subject">).

=cut

method update_word ($word, $encoded, $before, $after, $prefix) {
    my $mword = $mangle->mangle( $word );

    if ( $mword ne '' ) {
        $mword = $prefix . ':' . $mword if ( $prefix ne '' );

        if ( $prefix =~ /(from|to|cc|subject)/i ) {
            push @{ $quickmagnets{$prefix} }, $word;
        }

        if ( defined( $color_resolver ) ) {
            my $color = $self->get_color__( $mword );
            if ( $encoded == 0 ) {
                $after = '&' if ( $after eq '>' );
                if ( !( $ut =~                        s/($before)\Q$word\E($after)
                         /$1<b><font color=\"$color\">$word<\/font><\/b>$2/x ) ) {                    print "Could not find $word for colorization\n" if $debug;
                }
            } else {
                $ut .= "<font color=\"$color\">$word<\/font> ";
            }
        }

        $self->increment_word( $mword );
    }
}

=head2 add_line

Tokenizes C<$bigline> and updates word frequencies. C<$encoded> is 1 for
base64-decoded content; C<$prefix> is prepended to word tokens (e.g. C<"subject">).
Words hidden by invisible-ink colors generate a pseudoword instead.

=cut

method add_line ($bigline, $encoded, $prefix) {
    my $p = 0;

    return if ( !defined( $bigline ) );

    print "add_line: [$bigline]\n" if $debug;

    # If the line is really long then split at every 1k and feed it to
    # the parser below

    # Check the HTML back and font colors to ensure that we are not
    # about to add words that are hidden inside invisible ink

    if ( $htmlfontcolor ne $htmlbackcolor ) {
        # If we are adding a line and the colors are different then we
        # will add a count for the color difference to make sure that
        # we catch camouflage attacks using similar colors, if the
        # color similarity is less than 100.  I chose 100 somewhat
        # arbitrarily but classic black text on white background has a
        # distance of 441, red/blue or green on white has distance
        # 255.  100 seems like a reasonable upper bound for tracking
        # evil spammer tricks with similar colors

        if ( $htmlcolordistance < 100 ) {
            $self->update_pseudoword(                'html', "colordistance$htmlcolordistance",
                $encoded, '' );        }

        while ( $p < length( $bigline ) ) {
            my $line = substr( $bigline, $p, 1024 );

            # mangle up html character entities
            # these are just the low ISO-Latin1 entities
            # see: http://www.w3.org/TR/REC-html32#latin1
            # TODO: find a way to make this (and other similar stuff) highlight
            #       without using the encoded content printer or modifying $ut

            while ( $line =~ m/(&(\w{3,6});)/g ) {
                my $from = $1;
                my $to   = $entityhash{$2};

                if ( defined( $to ) ) {
                    # HTML entities confilict with DBCS and EUC-JP
                    # chars. Replace entities with blanks.

                    if ( $lang =~ /^(Korean|Nihongo)$/ ) {
                        $to = ' ';
                    } else {
                        $to = chr( $to );
                    }
                    $line         =~ s/$from/$to/g;
                    $ut =~ s/$from/$to/g;
                    print "$from -> $to\n" if $debug;
                }
            }

            while ( $line =~ m/(&#([\d]{1,3});)/g ) {
                # Don't decode odd (nonprintable) characters or < >'s.

                if ( ( ( $2 < 255 ) && ( $2 > 63 ) ) ||                     ( $2 == 61 ) ||
                     ( ( $2 < 60 ) && ( $2 > 31 ) ) ) {                    my $from = $1;
                    my $to   = chr( $2 );

                    if ( defined( $to ) && ( $to ne '' ) ) {
                        $line         =~ s/$from/$to/g;
                        $ut =~ s/$from/$to/g;
                        print "$from -> $to\n" if $debug;
                        $self->update_pseudoword(                            'html', 'numericentity', $encoded, $from );                    }
                }
            }

            # Pull out any email addresses in the line that are marked
            # with <> and have an @ in them

            while ( $line =~ s/(mailto:)?                               ([[:alpha:]0-9\-_\.]+?
                               @
                               ([[:alpha:]0-9\-_\.]+\.[[:alpha:]0-9\-_]+))
                               ([\"\&\)\?\:\/ >\&\;]|$)//x ) {                $self->update_word( $2, $encoded, ( $1 ? $1 : '' ),                                    '[\&\?\:\/ >\&\;]', $prefix );                $self->add_url( $3, $encoded, '\@', '[\&\?\:\/]', $prefix );
            }

            # Grab domain names (gTLD)
            # http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains

            while ( $line =~ s/(([[:alpha:]0-9\-_]+\.)+)                               (aero|arpa|asia|biz|cat|com|coop|edu|gov|info|
                                int|jobs|mil|mobi|museum|name|net|org|pro|tel|
                                travel|xxx)
                               ([^[:alpha:]0-9\-_\.]|$)/$4/ix ) {                $self->add_url( "$1$3", $encoded, '', '', $prefix );
            }

            # Grab country domain names (ccTLD)
            # http://en.wikipedia.org/wiki/List_of_Internet_top-level_domains

            while ( $line =~ s/(([[:alpha:]0-9\-_]+\.)+)                               (a[cdefgilmnoqrstuwxz]|
                                b[abdefghijmnorstvwyz]|
                                c[acdfghiklmnorsuvxyz]|
                                d[ejkmoz]|
                                e[cegrstu]|
                                f[ijkmor]|
                                g[abdefghilmnpqrstuwy]|
                                h[kmnrtu]|
                                i[delmnoqrst]|
                                j[emop]|
                                k[eghimnprwyz]|
                                l[abcikrstuvy]|
                                m[acdeghklmnopqrstuvwxyz]|
                                n[acefgilopruz]|
                                om|
                                p[aefghklmnrstwy]|
                                qa|
                                r[eosuw]|
                                s[abcdeghijklmnortuvyz]|
                                t[cdfghjklmnoprtvwz]|
                                u[agksyz]|
                                v[aceginu]|
                                w[fs]|
                                y[et]|
                                z[amw])
                               ([^[:alpha:]0-9\-_\.]|$)/$4/ix )  {                $self->add_url( "$1$3", $encoded, '', '', $prefix );
            }

            # Grab IP addresses

            while ( $line =~ s/(?<![[:alpha:]\d.])                               (([12]?\d{1,2}\.){3}[12]?\d{1,2})
                               (?![[:alpha:]\d])//x ) {                $self->update_word( $1, $encoded, '', '', $prefix );
            }

            # Deal with runs of alternating spaces and letters

            while ( $line =~ s/([ ]|^)                               ([A-Za-z]([\'\*^`&\. ]|[ ][ ])
                                (?:[A-Za-z]\3){1,14}[A-Za-z])
                               ([ ]|\3|[!\?,]|$)/ /x ) {                my $original = "$1$2$4";
                my $word     = $2;
                print "$word ->" if $debug;
                $word =~ s/[^A-Z]//gi;
                print "$word\n" if $debug;
                $self->update_word( $word, $encoded, ' ', ' ', $prefix );
                $self->update_pseudoword( 'trick', 'spacedout',                                          $encoded, $original );            }

            # Deal with random insertion of . inside words

            while ( $line =~ s/ ([A-Z]+)\.([A-Z]{2,}) / $1$2 /i ) {
                $self->update_pseudoword( 'trick', 'dottedwords',                                          $encoded, "$1$2" );            }

            if ( $lang eq 'Nihongo' ) {
                # In Japanese mode, non-symbol EUC-JP characters should be
                # matched.
                #
                # ^$euc_jp*? is added to avoid incorrect matching.
                # For example, EUC-JP char represented by code A4C8,
                # should not match the middle of two EUC-JP chars
                # represented by CCA4 and C8BE, the second byte of the
                # first char and the first byte of the second char.

                # In Japanese, one character words are common, so care about
                # words between 2 and 45 characters

                while ( $line =~ s/^$euc_jp*?                                   ([A-Za-z][A-Za-z\']{2,44}|
                                    $non_symbol_euc_jp{2,45})
                                   (?:[_\-,\.\"\'\)\?!:;\/& \t\n\r]{0,5}|$)
                                  //ox ) {                    if ( ( $in_headers == 0 ) &&                         ( $first20count < 20 ) ) {                        $first20count += 1;
                        $first20 .= " $1";
                    }

                    $self->update_word(                        $1, $encoded, '',
                        '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]|' . $symbol_euc_jp,
                        $prefix );                }
            } else {
                if ( $lang eq 'Korean' ) {
                    # In Korean mode, [[:alpha:]] in regular
                    # expression is changed to 2bytes chars to support
                    # 2 byte characters.
                    #
                    # In Korean, care about words between 2 and 45
                    # characters.

                    while ( $line =~ s/(([A-Za-z]|$eksc)                                        ([A-Za-z\']|$eksc){1,44})
                                        ([_\-,\.\"\'\)\?!:;\/& \t\n\r]{0,5}|$)
                                      //x ) {                        if ( ( $in_headers == 0 ) &&                             ( $first20count < 20 ) ) {                            $first20count += 1;
                            $first20 .= " $1";
                        }

                        $self->update_word( $1, $encoded, '',                                            '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]',
                                            $prefix ) if ( length $1 >= 2 );                    }
                } else {
                    # Only care about words between 3 and 45
                    # characters since short words like an, or, if are
                    # too common and the longest word in English
                    # (according to the OED) is
                    # pneumonoultramicroscopicsilicovolcanoconiosis

                    while ( $line =~ s/([[:alpha:]][[:alpha:]\']{1,44})                                       ([_\-,\.\"\'\)\?!:;\/& \t\n\r]{0,5}|$)
                                      //x ) {                        if ( ( $in_headers == 0 ) &&                             ( $first20count < 20 ) ) {                            $first20count += 1;
                            $first20 .= " $1";
                        }

                        $self->update_word( $1, $encoded, '',                                            '[_\-,\.\"\'\)\?!:;\/ &\t\n\r]',
                                            $prefix ) if ( length $1 >= 3 );                    }
                }
            }

            $p += 1024;
        }
    } else {
        if ( $bigline =~ /[^ \t]/ ) {
            $self->update_pseudoword( 'trick', 'invisibleink',                                      $encoded, $bigline );        }
    }
}

=head2 update_tag

Extracts classifiable tokens (domain names, alt text, color attributes,
CSS styles) from an HTML tag. C<$end_tag> is true for closing tags.
Updates word frequencies and HTML color state.

=cut

method update_tag ($tag, $arg, $end_tag, $encoded) {
    # TODO: Make sure $tag only ever gets alphanumeric input (in some
    #       cases it has been demonstrated that things like ()| etc can
    #       end up in $tag

    $tag =~ s/[\r\n]//g;
    $arg =~ s/[\r\n]//g;

    print "HTML " . ( $end_tag ? "closing" : '' ) . " tag $tag with argument $arg\n" if $debug;

    # End tags do not require any argument decoding but we do look at
    # them to make sure that we handle /font to change the font color

    if ( $end_tag ) {
        if ( $tag =~ /^font$/i ) {
            $htmlfontcolor = $self->map_color( 'black' );
            $self->compute_html_color_distance();
        }

        # If we hit a table tag then any font information is lost

        if ( $tag =~ /^(table|td|tr|th)$/i ) {
            $htmlfontcolor = $self->map_color( 'black' );
            $htmlbackcolor = $htmlbodycolor;
            $self->compute_html_color_distance();
        }

        if ( lc( $tag ) eq $cssbackcolortag ) {
            $htmlbackcolor   = $htmlbodycolor;
            $cssbackcolortag = '';

            $self->compute_html_color_distance();

            print "CSS back color reset to $htmlbackcolor (tag closed: $tag)\n" if $debug;
        }

        if ( lc( $tag ) eq $cssfontcolortag ) {
            $htmlfontcolor   = $self->map_color( 'black' );
            $cssfontcolortag = '';

            $self->compute_html_color_distance();

            print "CSS font color reset to $htmlfontcolor (tag closed: $tag)\n" if $debug;
        }

        return;
    }

    # Count the number of TD elements
    if ( $tag =~ /^td$/i ) {
        $self->update_pseudoword( 'html', 'td', $encoded, $tag );
    }

    my $attribute;
    my $value;

    # These are used to pass good values to update_word

    my $quote;
    my $end_quote;

    # Strip the first attribute while there are any attributes
    # Match the closing attribute character, if there is none
    # (this allows nested single/double quotes),
    # match a space or > or EOL

    my $original;

    while ( $arg =~ s/[ \t]*                      ((\w+)[ \t]*=[ \t]*
                       (([\"\'])(.*?)\4|([^ \t>]+)($|([ \t>])))
                      )//x ) {        $original  = $1;
        $attribute = $2;
        $value     = $5 || $6 || '';
        $quote     = '';
        $end_quote = '[\> \t\&\n]';
        if ( defined $4 ) {
            $quote     = $4;
            $end_quote = $4;
        }

        print "   attribute $attribute with value $quote$value$quote\n" if $debug;

        # Remove leading whitespace and leading value-less attributes

        if ( $arg =~ s/^(([ \t]*(\w+)[\t ]+)+)([^=])/$4/ ) {
            print "   attribute(s) $1 with no value\n" if $debug;
        }

        # Toggle for parsing script URI's.
        # Should be left off (0) until more is known about how different
        # html rendering clients behave.

        my $parse_script_uri = 0;

        # Tags with src attributes

        if ( ( $attribute =~ /^src$/i ) &&             ( ( $tag =~ /^img|frame|iframe$/i ) ||
               ( ( $tag =~ /^script$/i ) && $parse_script_uri ) ) ) {
            # "CID:" links refer to an origin-controlled attachment to
            # a html email.  Adding strings from these, even if they
            # appear to be hostnames, may or may not be beneficial

            if ( $value =~ /^(cid)\:/i ) {
                # Add a pseudo-word when CID source links are detected

                $self->update_pseudoword( 'html', 'cidsrc',                                          $encoded, $original );
                # TODO: I've seen virus messages try to use a CID: href


            } else {
                my $host = $self->add_url( $value, $encoded,                                           $quote, $end_quote, '' );
                # If the host name is not blank (i.e. there was a
                # hostname in the url and it was an image, then if the
                # host was not this host then report an off machine
                # image

                if ( ( $host ne '' ) && ( $tag =~ /^img$/i ) ) {
                    if ( $host ne 'localhost' ) {
                        $self->update_pseudoword( 'html', 'imgremotesrc',                                                  $encoded, $original );                    }
                }

                if ( ( $host ne '' ) && ( $tag =~ /^iframe$/i ) ) {
                    if ( $host ne 'localhost' ) {
                        $self->update_pseudoword( 'html', 'iframeremotesrc',                                                  $encoded, $original );                    }
                }
            }

            next;
        }

        # Tags with href attributes

        if ( ( $attribute =~ /^href$/i ) &&             ( $tag =~ /^(a|link|base|area)$/i ) ) {
            # Look for mailto:'s

            if ( $value =~ /^mailto:/i ) {
                if ( ( $tag =~ /^a$/ ) &&                     ( $value =~ /^mailto:
                                  ([[:alpha:]0-9\-_\.]+?
                                   @
                                   ([[:alpha:]0-9\-_\.]+?))
                                  ([>\&\?\:\/\" \t]|$)/ix ) )  {                    $self->update_word(                        $1, $encoded, 'mailto:',
                        ( $3 ? '[\\\>\&\?\:\/]' : $end_quote ), '' );                    $self->add_url(                        $2, $encoded, '@',
                        ( $3 ? '[\\\&\?\:\/]' : $end_quote ), '' );                }
            } else {
                # Anything that isn't a mailto is probably an URL

                $self->add_url( $value, $encoded, $quote, $end_quote, '' );
            }

            next;
        }

        # Tags with alt attributes

        if ( ( $attribute =~ /^alt$/i ) && ( $tag =~ /^img$/i ) ) {
            $self->add_line( $value, $encoded, '' );
            next;
        }

        # Tags with working background attributes

        if ( ( $attribute =~ /^background$/i ) &&             ( $tag =~ /^(td|table|body)$/i ) ) {            $self->add_url( $value, $encoded, $quote, $end_quote, '' );
            next;
        }

        # Tags that load sounds

        if ( $attribute =~ /^bgsound$/i && $tag =~ /^body$/i ) {
            $self->add_url( $value, $encoded, $quote, $end_quote, '' );
            next;
        }

        # Tags with colors in them

        if ( ( $attribute =~ /^color$/i ) && ( $tag =~ /^font$/i ) ) {
            $self->update_word( $value, $encoded, $quote, $end_quote, '' );
            $self->update_pseudoword( 'html', "fontcolor$value",                                      $encoded, $original );            $htmlfontcolor = $self->map_color( $value );
            $self->compute_html_color_distance();
            print "Set html font color to $htmlfontcolor\n" if $debug;
            next;
        }

        if ( ( $attribute =~ /^text$/i ) && ( $tag =~ /^body$/i ) ) {
            $self->update_pseudoword( 'html', "fontcolor$value",                                      $encoded, $original );            $self->update_word( $value, $encoded, $quote, $end_quote, '' );
            $htmlfontcolor = $self->map_color( $value );
            $self->compute_html_color_distance();
            print "Set html font color to $htmlfontcolor\n" if $debug;
            next;
        }

        # The width and height of images

        if ( ( $attribute =~ /^(width|height)$/i ) && ( $tag =~ /^img$/i ) ) {
            $attribute = lc( $attribute );
            $self->update_pseudoword( 'html', "img$attribute$value",                                      $encoded, $original );            next;
        }

        # Font sizes

        if ( ( $attribute =~ /^size$/i ) && ( $tag =~ /^font$/i ) ) {
            # TODO: unify font size scaling to use the same scale
            #       across size specifiers

            $self->update_pseudoword( 'html', "fontsize$value",                                      $encoded, $original );            next;
        }

        # Tags with background colors

        if ( ( $attribute =~ /^(bgcolor|back)$/i ) &&             ( $tag =~ /^(td|table|body|tr|th|font)$/i ) ) {            $self->update_word( $value, $encoded, $quote, $end_quote, '' );
            $self->update_pseudoword( 'html', "backcolor$value",                                      $encoded, $original );            $htmlbackcolor = $self->map_color( $value );
            print "Set html back color to $htmlbackcolor\n" if $debug;

            if ( $tag =~ /^body$/i ) {
                $htmlbodycolor = $htmlbackcolor
            }
            $self->compute_html_color_distance();
            next;
        }

        # Tags with a charset

        if ( ( $attribute =~ /^content$/i ) && ( $tag =~ /^meta$/i ) ) {
            if ( $value =~ /charset=([^\t\r\n ]{1,40})[\"\>]?/ ) {
                $self->update_word( $1, $encoded, '', '', '' );
            }
            next;
        }

        # CSS handling

        if ( !exists( $HTML::Tagset::emptyElement->{ lc( $tag ) } ) &&             ( $attribute =~ /^style$/i ) ) {            print "      Inline style tag found in $tag: $attribute=$value\n" if $debug;

            my $style = $self->parse_css_style( $value );

            if ( $debug ) {                print "      CSS properties: ";
                foreach my $key ( keys( %{$style} ) ) {
                    print "$key($style->{$key}), ";
                }
                print "\n";
            }
            # CSS font sizing
            if ( defined( $style->{'font-size'} ) ) {
                my $size = $style->{'font-size'};

                # TODO: unify font size scaling to use the same scale
                #       across size specifiers approximate font sizes here:
                # http://www.dejeu.com/web/tools/tech/css/variablefontsizes.asp

                if ( $size =~ /(((\+|\-)?\d?\.?\d+)                                (em|ex|px|%|pt|in|cm|mm|pt|pc))|
                               (xx-small|x-small|small|medium|large|x-large|
                                xx-large)/x ) {                    $self->update_pseudoword( 'html', "cssfontsize$size",                                              $encoded, $original );                    print "     CSS font-size set to: $size\n" if $debug;
                }
            }

            # CSS visibility
            if ( defined( $style->{'visibility'} ) ) {
                $self->update_pseudoword(                    'html', "cssvisibility" . $style->{'visibility'},
                    $encoded, $original );            }

            # CSS display
            if ( defined( $style->{'display'} ) ) {
                $self->update_pseudoword(                    'html', "cssdisplay" . $style->{'display'},
                    $encoded, $original );            }


            # CSS foreground coloring

            if ( defined( $style->{'color'} ) ) {
                my $color = $style->{'color'};

                print "      CSS color: $color\n" if $debug;

                $color = $self->parse_css_color( $color );

                if ( $color ne "error" ) {
                    $htmlfontcolor = $color;
                    $self->compute_html_color_distance();

                    print "      CSS set html font color to $htmlfontcolor\n" if $debug;
                    $self->update_pseudoword(                        'html', "cssfontcolor$htmlfontcolor",
                        $encoded, $original );
                    $cssfontcolortag = lc( $tag );
                }
            }

            # CSS background coloring

            if ( defined( $style->{'background-color'} ) ) {
                my $background_color = $style->{'background-color'};

                $background_color =                    $self->parse_css_color( $background_color );
                if ( $background_color ne "error" ) {
                    $htmlbackcolor = $background_color;
                    $self->compute_html_color_distance();
                    print "       CSS set html back color to $htmlbackcolor\n" if $debug;

                    $htmlbodycolor = $background_color                        if ( $tag =~ /^body$/i );                    $cssbackcolortag = lc( $tag );

                    $self->update_pseudoword(                        'html', "cssbackcolor$htmlbackcolor",
                        $encoded, $original );                }
            }

            # CSS all-in one background declaration (ugh)

            if ( defined( $style->{'background'} ) ) {
                my $expression;
                my $background = $style->{'background'};

                # Take the possibly multi-expression "background" property

                while ( $background =~ s/^([^ \t\r\n\f]+)( |$)// ) {
                    # and examine each expression individually

                    $expression = $1;
                    print "       CSS expression $expression in background property\n" if $debug;

                    my $background_color =                        $self->parse_css_color( $expression );
                    # to see if it is a color

                    if ( $background_color ne "error" ) {
                        $htmlbackcolor = $background_color;
                        $self->compute_html_color_distance();
                        print "       CSS set html back color to $htmlbackcolor\n" if $debug;

                        if ( $tag =~ /^body$/i ) {
                            $htmlbodycolor = $background_color;
                        }
                        $cssbackcolortag = lc( $tag );

                        $self->update_pseudoword(                            'html', "cssbackcolor$htmlbackcolor",
                            $encoded, $original );                    }
                }
            }
        }

        # TODO: move this up into the style part above

        # Tags with style attributes (this one may impact
        # performance!!!)  most container tags accept styles, and the
        # background style may not be in a predictable location
        # (search the entire value)

        if ( ( $attribute =~ /^style$/i ) &&             ( $tag =~ /^(body|td|tr|table|span|div|p)$/i ) ) {            $self->add_url( $1, $encoded, '[\']', '[\']', '' )                if ( $value =~ /background\-image:[ \t]?url\([ \t]?\'(.*)\'[ \t]?\)/i );            next;
        }

        # Tags with action attributes

        if ( $attribute =~ /^action$/i && $tag =~ /^form$/i ) {
            if ( $value =~ /^(ftp|http|https):\/\//i ) {
                $self->add_url( $value, $encoded, $quote, $end_quote, '' );
                next;
            }

            # mailto forms

            if ( $value =~ /^mailto:                            ([[:alpha:]0-9\-_\.]+?
                             @
                             ([[:alpha:]0-9\-_\.]+?))
                            ([>\&\?\:\/\" \t]|$)/ix )  {                $self->update_word(                    $1, $encoded, 'mailto:',
                    ( $3 ? '[\\\>\&\?\:\/]' : $end_quote ), '' );                $self->add_url(                    $2, $encoded, '@',
                    ( $3 ? '[\\\>\&\?\:\/]' : $end_quote ), '' );            }
            next;
        }
    }
}

=head2 add_url

Parses a URL or domain, decomposes it into host/path/query, and adds the
hostname and its sub-domains as words. Returns the extracted hostname, or
an empty string when none is found. Pass C<$noadd> to parse without
updating word frequencies.

=cut

method add_url ($url, $encoded, $before, $after, $prefix, $noadd = undef) {
    my $temp_url = $url;
    my $temp_before;
    my $temp_after;
    my $hostform;   #ip or name

    # parts of a URL, from left to right
    my $protocol;
    my $authinfo;
    my $host;
    my $port;
    my $path;
    my $query;
    my $hash;

    return undef if ( !defined( $url ) );

    # Strip the protocol part of a URL (e.g. http://)

    $protocol = $1 if ( $url =~ s/^([^:]*)\:\/\/// );

    # Remove any URL encoding (protocol may not be URL encoded)

    my $oldurl   = $url;
    my $percents = ( $url =~ s/(%([0-9A-Fa-f]{2}))/chr(hex("0x$2"))/ge );

    if ( ( $percents > 0 ) && !defined( $noadd ) ) {
        $self->update_pseudoword( 'html', 'encodedurl', $encoded, $oldurl );
    }

    # Extract authorization information from the URL
    # (e.g. http://foo@bar.com)

    if ( $url =~ s/^(([[:alpha:]0-9\-_\.\;\:\&\=\+\$\,]+)(\@|\%40))+// ) {
        $authinfo = $1;

        if ( $authinfo ne '' ) {
            $self->update_pseudoword( 'html', 'authorization', 
                                      $encoded, $oldurl );
        }
    }

    if ( $url =~ s/^(([[:alpha:]0-9\-_]+\.)+)                    (aero|arpa|asia|biz|cat|com|coop|edu|gov|info|
                     int|jobs|mil|mobi|museum|name|net|org|pro|tel|
                     travel|xxx|[a-z]{2})
                    ([^[:alpha:]0-9\-_\.]|$)/$4/ix ) {        $host     = "$1$3";
        $hostform = "name";
    } else {
        if ( $url =~ /(([^:\/])+)/ ) {
            # Some other hostname format found, maybe
            # Read here for reference: http://www.pc-help.org/obscure.htm
            # Go here for comparison: http://www.samspade.org/t/url

            # save the possible hostname

            my $host_candidate = $1;

            # stores discovered IP address

            my %quads;

            # temporary values

            my $quad = 1;
            my $number;

            # iterate through the possible hostname, build dotted quad
            # format

            while ( $host_candidate =~                    s/\G^((0x)[0-9A-Fa-f]+|0[0-7]+|[0-9]+)(\.)?// ) {                my $hex = $2;

                # possible IP quad(s)

                my $quad_candidate = $1;
                my $more_dots      = $3;

                if ( defined $hex ) {
                    # hex number
                    # trim arbitrary octets that are greater than most
                    # significant bit

                    $quad_candidate =~ s/.*(([0-9A-F][0-9A-F]){4})$/$1/i;
                    $number = hex( $quad_candidate );
                } else {
                    if ( $quad_candidate =~ /^0([0-7]+)/ ) {
                        # octal number

                        $number = oct( $1 );
                    } else {
                        # assume decimal number
                        # deviates from the obscure.htm document here,
                        # no current browsers overflow

                        $number = int( $quad_candidate );
                    }
                }

                # No more IP dots?

                if ( !defined( $more_dots ) ) {
                    # Expand final decimal/octal/hex to extra quads

                    while ( $quad <= 4 ) {
                        my $shift = ( ( 4 - $quad ) * 8 );
                        $quads{$quad} =                            ( $number & ( hex( "0xFF" ) << $shift ) )
                                >> $shift;                        $quad += 1;
                    }
                } else {
                    # Just plug the quad in, no overflow allowed

                    $quads{$quad} = $number if ( $number < 256 );
                    $quad += 1;
                }

                last if ( $quad > 4 );
            }

            $host_candidate =~ s/\r|\n|$//g;
            if ( ( $host_candidate eq '' ) &&                 defined( $quads{1} )      &&
                 defined( $quads{2} )      &&
                 defined( $quads{3} )      &&
                 defined( $quads{4} )      &&
                 !defined( $quads{5} ) ) {
                # we did actually find an IP address, and not some fake

                $hostform = "ip";
                $host     = "$quads{1}.$quads{2}.$quads{3}.$quads{4}";
                $url =~ s/(([^:\/])+)//;
            }
        }
    }

    if ( !defined( $host ) || ( $host eq '' ) ) {
        print "no hostname found: [$temp_url]\n" if $debug;
        return '';
    }

    $port  = $1 if ( $url =~ s/^\:(\d+)// );
    $path  = $1 if ( $url =~ s/^([\\\/][^\#\?\n]*)($)?// );
    $query = $1 if ( $url =~ s/^[\?]([^\#\n]*|$)?// );
    $hash  = $1 if ( $url =~ s/^[\#](.*)$// );

    if ( !defined( $protocol ) || ( $protocol =~ /^(http|https)$/ ) ) {
        $temp_before = $before;
        $temp_before = "\:\/\/" if ( defined $protocol );
        $temp_before = "[\@]" if ( defined $authinfo );

        $temp_after = $after;
        $temp_after = "[\#]" if ( defined $hash );
        $temp_after = "[\?]" if ( defined $query );
        $temp_after = "[\\\\\/]" if ( defined $path );
        $temp_after = "[\:]" if ( defined $port );

        # add the entire domain

        $self->update_word(            $host, $encoded,
            $temp_before, $temp_after, $prefix ) if ( !defined( $noadd ) );
        # decided not to care about tld's beyond the verification
        # performed when grabbing $host special subTLD's can just get
        # their own classification weight (eg, .bc.ca)
        # http://www.0dns.org has a good reference of ccTLD's and
        # their sub-tld's if desired

        if ( $hostform eq 'name' ) {
            # recursively add the roots of the domain

            while ( $host =~ s/^([^\.]+\.)?(([^\.]+\.?)*)(\.[^\.]+)$/$2$4/ ) {
                if ( !defined( $1 ) ) {
                    $self->update_word(                        $4, $encoded,
                        $2, '[<]', $prefix) if ( !defined( $noadd ) );                    last;
                }
                $self->update_word(                    $host, $encoded,
                    $1 || $2, '[<]', $prefix) if ( !defined( $noadd ) );            }
        }
    }

    # $protocol $authinfo $host $port $query $hash may be processed
    # below if desired
    return $host;
}

# ----------------------------------------------------------------------------
#
# parse_html
#
# Parse a line that might contain HTML information, returns 1 if we
# are still inside an unclosed HTML tag
#
# $line     A line of text
# $encoded  1 if this HTML was found inside encoded (base64) text
#
# ----------------------------------------------------------------------------
method parse_html ($line, $encoded) {
    my $found = 1;

    $line =~ s/[\r\n]+/ /gm;

    print "parse_html: [$line] " . $in_html_tag . "\n" if $debug;

    # Remove HTML comments and other tags that begin !

    while ( $line =~ s/(<!.*?>)// ) {
        $self->update_pseudoword( 'html', 'comment', $encoded, $1 );
        print "$line\n" if $debug;
    }

    # Remove invalid tags.  This finds tags of the form [a-z0-9]+ with
    # optional attributes and removes them if the tag isn't
    # recognized.

    # TODO: This also removes tags in plain text emails so a sentence
    # such as 'To run the program type "program <filename>".' is also
    # effected.  The correct fix seams to be to look at the
    # Content-Type header and only process mails of type text/html.

    while ( $line =~ s/(<\/?(?!(?:$spacing_tags|$non_spacing_tags)\W)                        [a-z0-9]+(?:\s+.*?)?\/?>)//iox ) {        $self->update_pseudoword( 'html', 'invalidtag', $encoded, $1 );
        print "html:invalidtag: $1\n" if $debug;
    }

    # Remove pairs of non-spacing tags without content such as <b></b>
    # and also <b><i></i></b>.

    # TODO: What about combined open and close tags such as <b />?

    while ( $line =~ s/(<($non_spacing_tags)(?:\s+[^>]*?)?><\/\2>)//io ) {
        $self->update_pseudoword( 'html', 'emptypair', $encoded, $1 );
        print "html:emptypair: $1\n" if $debug;
    }

    while ( $found && ( $line ne '' ) ) {
        $found = 0;

        # If we are in an HTML tag then look for the close of the tag,
        # if we get it then handle the tag, if we don't then keep
        # building up the arguments of the tag

        if ( $in_html_tag ) {
            if ( $line =~ s/^([^>]*?)>// ) {
                $html_arg .= $1;
                $in_html_tag = 0;
                $html_tag =~ s/=\n ?//g;
                $html_arg =~ s/=\n ?//g;
                $self->update_tag( $html_tag, $html_arg,                                   $html_end, $encoded );                $html_tag = '';
                $html_arg = '';
                $found              = 1;
                next;
            } else {
                $html_arg .= $line;
                return 1;
            }
        }

        # Does the line start with a HTML tag that is closed (i.e. has
        # both the < and the > present)?  If so then handle that tag
        # immediately and continue

        if ( $line =~ s/^<([\/]?)([A-Za-z]+)([^>]*?)>// ) {
            $self->update_tag( $2, $3, ( $1 eq '/' ), $encoded );
            $found = 1;
            next;
        }

        # Does the line consist of just a tag that has no closing >
        # then set up the global vars that record the tag and return 1
        # to indicate to the caller that we have an unclosed tag

        if ( $line =~ /^<([\/]?)([A-Za-z][^ >]+)([^>]*)$/ ) {
            $html_end      = ( $1 eq '/' );
            $html_tag    = $2;
            $html_arg    = $3;
            $in_html_tag = 1;
            return 1;
        }

        # There could be something on the line that needs parsing
        # (such as a word), if we reach here then we are not in an
        # unclosed tag and so we can grab everything from the start of
        # the line to the end or the first < and pass it to the line
        # parser

        if ( $line =~ s/^([^<]+)(<|$)/$2/ ) {
            $found = 1;
            $self->add_line( $1, $encoded, '' );
        }
    }

    return 0;
}

# ----------------------------------------------------------------------------
#
# parse_file
#
# Read messages from file and parse into a list of words and
# frequencies, returns a colorized HTML version of message if color is
# set
#
# $file     The file to open and parse
# $max_size The maximum size of message to parse, or 0 for unlimited
# $reset    If set to 0 then the list of words from a previous parse is not
#           reset, this can be used to do multiple parses and build a single
#           word list.  By default this is set to 1 and the word list is reset
#
# ----------------------------------------------------------------------------
method parse_file ($file, $max_size = undef, $reset = undef) {
    $reset    = 1 if ( !defined( $reset    ) );
    $max_size = 0 if ( !defined( $max_size ) || ( $max_size =~ /\D/ ) );

    $self->start_parse( $reset );

    my $size_read = 0;

    open my $msg, '<', $file;
    binmode $msg;

    # Read each line and find each "word" which we define as a
    # sequence of alpha characters

    while ( <$msg> ) {
        $size_read += length( $_ );
        $self->parse_line( $_ );
        if ( ( $max_size > 0 ) &&             ( $size_read > $max_size ) ) {            last;
        }
    }

    close $msg;

    $self->stop_parse();

    if ( defined( $color_resolver ) ) {
        $colorized .= $ut if ( $ut ne '' );

        $colorized .= "</tt>";
        $colorized =~ s/(\r\n\r\n|\r\r|\n\n)/__BREAK____BREAK__/g;
        $colorized =~ s/[\r\n]+/__BREAK__/g;
        $colorized =~ s/__BREAK__/<br \/>/g;

        return $colorized;
    } else {
        return '';
    }
}

# ----------------------------------------------------------------------------
#
# start_parse
#
# Called to reset internal variables before parsing.  This is
# automatically called when using the parse_file API, and must be
# called before the first call to parse_line.
#
# $reset    If set to 0 then the list of words from a previous parse is not
#           reset, this can be used to do multiple parses and build a single
#           word list.  By default this is set to 1 and the word list is reset
#
# ----------------------------------------------------------------------------
method start_parse ($reset = undef) {
    $reset = 1 if ( !defined( $reset ) );

    # This will contain the mime boundary information in a mime message

    $cur_mime = '';

    # Contains the encoding for the current block in a mime message

    $cur_encoding = '';

    # Variables to save header information to while parsing headers

    $cur_header   = '';
    $cur_argument = '';

    # Clear the word hash

    $content_type = '';

    # Base64 attachments are loaded into this as we read them

    $base64 = '';

    # Variable to note that the temporary colorized storage is
    # "frozen", and what type of freeze it is (allows nesting of
    # reasons to freeze colorization)

    $in_html_tag = 0;

    $html_tag    = '';
    $html_arg    = '';

    if ( $reset ) {
        %words = ();
    }

    $msg_total    = 0;
    $from         = '';
    $to           = '';
    $cc           = '';
    $subject      = '';
    $ut           = '';
    %quickmagnets = ();

    $htmlbodycolor = $self->map_color( 'white' );
    $htmlbackcolor = $self->map_color( 'white' );
    $htmlfontcolor = $self->map_color( 'black' );
    $self->compute_html_color_distance();

    $in_headers = 1;

    $first20      = '';
    $first20count = 0;

    # Used to return a colorize page

    $colorized = '';
    $colorized .= "<tt>" if ( defined( $color_resolver ) );

    # Clear the character set to avoid using the wrong charsets
    $charset = '';

    if ( $lang eq 'Nihongo' ) {
        # Since Text::Kakasi is not thread-safe, we use it under the
        # control of a Mutex to avoid a crash if we are running on
        # Windows.
        if ( $need_kakasi_mutex ) {
            require POPFile::Mutex;
            $kakasi_mutex->acquire();
        }

        # Initialize Nihongo (Japanese) parser
        $nihongo_parser{init}( $self );
    }
}

# ----------------------------------------------------------------------------
#
# stop_parse
#
# Called at the end of a parse job.  Automatically called if
# parse_file is used, must be called after the last call to
# parse_line.
#
# ----------------------------------------------------------------------------
method stop_parse {
    $colorized .= $self->clear_out_base64();

    $self->clear_out_qp();

    # If we reach here and discover that we think that we are in an
    # unclosed HTML tag then there has probably been an error (such as
    # a < in the text messing things up) and so we dump whatever is
    # stored in the HTML tag out

    if ( $in_html_tag ) {
        $self->add_line( "$html_tag $html_arg", 0, '' );
    }

    # if we are here, and still have headers stored, we must have a
    # bodyless message

    # TODO: Fix me

    if ( $cur_header ne '' ) {
        $self->parse_header( $cur_header, $cur_argument,                             $cur_mime, $cur_encoding );        $cur_header   = '';
        $cur_argument = '';
    }

    $in_html_tag = 0;

    if ( $lang eq 'Nihongo' ) {
        # Close Nihongo (Japanese) parser
        $nihongo_parser{close}( $self );

        if ( $need_kakasi_mutex ) {
            require POPFile::Mutex;
            $kakasi_mutex->release();
        }
    }
}

# ----------------------------------------------------------------------------
#
# parse_line
#
# Called to parse a single line from a message.  If using this API
# directly then be sure to call start_parse before the first call to
# parse_line.
#
# $line               Line of file to parse
#
# ----------------------------------------------------------------------------
method parse_line ($read) {
    if ( $read ne '' ) {
        # For the Mac we do further splitting of the line at the CR
        # characters

        while ( $read =~ s/(.*?)[\r\n]+// ) {
            my $line = "$1\r\n";

            next if ( !defined( $line ) );

            print ">>> $line" if $debug;

            # Decode quoted-printable

            if ( !$in_headers &&                 ( $cur_encoding =~ /quoted\-printable/i ) ) {                if ( $line =~ s/=\r\n$// ) {
                    # Encoded in multiple lines

                    $prev .= $line;
                    next;
                } else {
                    $line = $prev . $line;
                    $prev = '';
                }
                $line = decode_qp( $line );
                $line =~ s/\x00/NUL/g;
            }

            if ( ( $lang eq 'Nihongo' ) &&                 !$in_headers &&
                 ( $cur_encoding !~ /base64/i ) ) {
                # Decode \x??
                $line =~ s/\\x([8-9A-F][A-F0-9])/pack("C", hex($1))/eig;

                $line = convert_encoding(                    $line, $charset, 'euc-jp', '7bit-jis',
                    @{ $encoding_candidates{ $lang } } );                $line = $nihongo_parser{parse}( $self, $line );
            }

            if ( defined( $color_resolver ) ) {
                if ( !$in_html_tag ) {
                    $colorized .= $ut;
                    $ut = '';
                }

                $ut .= $self->splitline( $line,                                                   $cur_encoding );            }

            if ( $in_headers ) {
                # temporary colorization while in headers is handled
                # within parse_header

                $ut = '';

                # Check for blank line signifying end of headers

                if ( $line =~ /^(\r\n|\r|\n)/ ) {
                    # Parse the last header
                    ( $cur_mime, $cur_encoding ) =                        $self->parse_header(
                            $cur_header, $cur_argument,
                            $cur_mime, $cur_encoding );
                    # Clear the saved headers
                    $cur_header   = '';
                    $cur_argument = '';

                    $ut .= $self->splitline( "\015\012", 0 );
                    $ut .= "<a name=\"message_body\" />";

                    $in_headers = 0;
                    print "Header parsing complete.\n" if $debug;

                    next;
                }

                # Append to argument if the next line begins with
                # whitespace (isn't a new header)

                if ( $line =~ /^([\t ])([^\r\n]+)/ ) {
                    $cur_argument .= "$eol$1$2";
                    next;
                }

                # If we have an email header then split it into the
                # header and its argument

                if ( $line =~ /^([A-Za-z\-]+):[ \t]*([^\n\r]*)/ ) {
                    # Parse the last header

                    ( $cur_mime, $cur_encoding ) =                        $self->parse_header(
                            $cur_header, $cur_argument,
                            $cur_mime, $cur_encoding )
                        if ( $cur_header ne '' );
                    # Save the new information for the current header

                    $cur_header   = $1;
                    $cur_argument = $2;
                    next;
                }

                next;
            }

            # If we are in a mime document then spot the boundaries

            if ( ( $cur_mime ne '' ) &&                 ( $line =~ /^\-\-($cur_mime)(\-\-)?/ ) ) {
                # approach each mime part with fresh eyes

                $cur_encoding = '';

                if ( !defined( $2 ) ) {
                    # This means there was no trailing -- on the mime
                    # boundary (which would have indicated the end of
                    # a boundary, so now we have a new part of the
                    # document, hence we need to look for new headers

                    print "Hit MIME boundary --$1\n" if $debug;

                    $self->clear_out_qp();

                    # Decode base64 for every part.
                    $colorized .= $self->clear_out_base64() . "\n\n";

                    $in_headers = 1;
                } else {
                    # A boundary was just terminated

                    $in_headers = 0;

                    my $boundary = $1;

                    print "Hit MIME boundary terminator --$1--\n" if $debug;

                    # Escape to match escaped boundary characters

                    $boundary =~ s/(.*)/\Q$1\E/g;

                    # Remove the boundary we just found from the
                    # boundary list.  The list is stored in
                    # $cur_mime and consists of mime boundaries
                    # separated by the alternation characters | for
                    # use within a regexp

                    my $temp_mime = '';

                    foreach my $aboundary ( split( /\|/, $cur_mime ) ) {
                        if ( $boundary ne $aboundary ) {
                            if ( $temp_mime ne '' ) {
                                $temp_mime = join( '|',                                                   $temp_mime, $aboundary );                            } else {
                                $temp_mime = $aboundary;
                            }
                        }
                    }

                    $cur_mime = $temp_mime;

                    print "MIME boundary list now $cur_mime\n" if $debug;
                }

                next;
            }

            # If we are doing base64 decoding then look for suitable
            # lines and remove them for decoding

            if ( $cur_encoding =~ /base64/i ) {
                $line =~ s/[\r\n]//g;
                $line =~ s/!$//;
                $base64 .= $line;

                next;
            }

            next if ( !defined( $line ) );

            $self->parse_html( $line, 0 );
        }
    }
}

# ----------------------------------------------------------------------------
#
# clear_out_base64
#
# If there's anything in the {base64__} then decode it and parse it,
# returns colorization information to be added to the colorized output
#
# ----------------------------------------------------------------------------
method clear_out_base64 {
    my $colorized = '';

    if ( $base64 ne '' ) {
        my $decoded = '';

        $ut     = '' if ( defined( $color_resolver ) );
        $base64 =~ s/ //g;

        print "Base64 data: " . $base64 . "\n" if $debug;

        $decoded = decode_base64( $base64 );

        if ( $lang eq 'Nihongo' ) {
            $decoded = convert_encoding(                $decoded, $charset, 'euc-jp', '7bit-jis',
                @{ $encoding_candidates{ $lang } } );            $decoded = $nihongo_parser{parse}( $self, $decoded );
        }

        $self->parse_html( $decoded, 1 );

        print "Decoded: " . $decoded . "\n" if $debug;

        if ( defined( $color_resolver ) ) {
            $ut = "<b>Found in encoded data:</b> " . $ut;
        }

        if ( defined( $color_resolver ) ) {
            if ( $ut ne '' ) {
                $colorized = $ut;
                $ut = '';
            }
        }
    }

    $base64 = '';

    return $colorized;
}

# ----------------------------------------------------------------------------
#
# clear_out_qp
#
# If there's anything in the {prev__} then decode it and parse it
#
# ----------------------------------------------------------------------------
method clear_out_qp {
    if ( ( $cur_encoding =~ /quoted\-printable/i ) &&
         ( $prev ne '' ) ) {
        my $line = decode_qp( $prev );
        $line =~ s/\x00/NUL/g;

        if ( $lang eq 'Nihongo' ) {
            $line = convert_encoding(
                $line, $charset, 'euc-jp', '7bit-jis',
                @{ $encoding_candidates{ $lang } } );
            $line = $nihongo_parser{parse}( $self, $line );
        }

        $ut .= $self->splitline( $line, '' );

        $self->parse_html( $line, 0 );
        $prev = '';
    }
}

# ----------------------------------------------------------------------------
#
# decode_string - Decode MIME encoded strings used in the header lines
# in email messages
#
# $mystring     - The string that neeeds decode
#
# Return the decoded string, this routine recognizes lines of the form
#
# =?charset?[BQ]?text?=
#
# $lang Pass in the current interface language for language specific
# encoding conversion A B indicates base64 encoding, a Q indicates
# quoted printable encoding
# ----------------------------------------------------------------------------
method decode_string ($mystring, $lang = undef) {
    # I choose not to use "$mystring = MIME::Base64::decode( $1 );"
    # because some spam mails have subjects like: "Subject: adjpwpekm
    # =?ISO-8859-1?Q?=B2=E1=A4=D1=AB=C7?= dopdalnfjpw".  Therefore we
    # proceed along the string, from left to right, building a new
    # string from the decoded and non-decoded parts


    my $charset = '';

    return '' if ( !defined( $mystring ) );

    $lang = $lang if ( !defined( $lang ) || ( $lang eq '' ) );

    my $output          = '';
    my $last_is_encoded = 0;

    while ( $mystring =~ m/(.*?)(=\?([\w-]+)\?(B|Q)\?(.*?)\?=)/igc ) {
        my ( $pre, $atom, $encoding, $value );
        ( $pre, $atom, $charset, $encoding, $value ) = ( $1, $2, $3, $4, $5 );

        $output .= $pre unless ( $last_is_encoded && defined( $atom )                                    && ( $pre =~ /^[\t ]+$/ ) );      # PROFILE BLOCK STOP( Per RFC 2047 section 6.2 )

        if ( defined( $atom ) ) {
            if ( $encoding =~ /^[bB]$/ ) {
                $value = decode_base64( $value );

                # for Japanese header

                if ( $lang eq 'Nihongo' ) {
                    $value = convert_encoding(                        $value, $charset, 'euc-jp', '7bit-jis',
                        @{ $encoding_candidates{ $lang } } );                }
                $last_is_encoded = 1;
            } elsif ( $encoding =~ /^[qQ]$/ ) {
                $value =~ s/\_/=20/g;
                $value = decode_qp( $value );
                $value =~ s/\x00/NUL/g;

                # for Japanese header

                if ( $lang eq 'Nihongo' ) {
                    $value = convert_encoding(                        $value, $charset, 'euc-jp', '7bit-jis',
                        @{ $encoding_candidates{ $lang } } );                }
                $last_is_encoded = 1;
            }
        } else {
            $last_is_encoded = 0;
        }
        $output .= $value || '';
    }

    # grab the unmatched tail (thanks to /gc and \G)

    $output .= $1 if ( $mystring =~ m/\G(.*)/g );

    return $output;
}

# ----------------------------------------------------------------------------
#
# get_header - Returns the value of the from, to, subject or cc header
#
# $header      Name of header to return (note must be lowercase)
#
# ----------------------------------------------------------------------------
method get_header ($header) {
    return $from    if $header eq 'from';
    return $to      if $header eq 'to';
    return $cc      if $header eq 'cc';
    return $subject if $header eq 'subject';
    return '';
}

# ----------------------------------------------------------------------------
#
# parse_header - Performs parsing operations on a message header
#
# $header       Name of header being processed
# $argument     Value of header being processed
# $mime         The presently saved mime boundaries list
# $encoding     Current message encoding
#
# ----------------------------------------------------------------------------
method parse_header ($header, $argument, $mime, $encoding) {
    print "Header ($header) ($argument)\n" if $debug;

    # After a discussion with Tim Peters and some looking at emails
    # I'd received I discovered that the header names (case sensitive)
    # are very significant in identifying different types of mail, for
    # example much spam uses MIME-Version, MiME-Version and
    # Mime-Version

    my $fix_argument = $argument;
    $fix_argument =~ s/</&lt;/g;
    $fix_argument =~ s/>/&gt;/g;

    $argument =~ s/(\r\n|\r|\n)//g;
    $argument =~ s/^[ \t]+//;

    if ( $self->update_pseudoword( 'header', $header, 0, $header ) ) {
        if ( defined( $color_resolver ) ) {
            my $color     = $self->get_color__( "header:$header" );
            $ut = "<b><font color=\"$color\">$header</font></b>: $fix_argument\015\012";
        }
    } else {
        if ( defined( $color_resolver ) ) {
            $ut = "$header: $fix_argument\015\012";
        }
    }

    # Check the encoding type in all RFC 2047 encoded headers

    if ( $argument =~ /=\?([^\r\n\t ]{1,40})\?(Q|B)/i ) {
        $self->update_word( $1, 0, '', '', 'charset' );
    }

    # Handle the From, To and Cc headers and extract email addresses
    # from them and treat them as words

    # For certain headers we are going to mark them specially in the
    # corpus by tagging them with where they were found to help the
    # classifier do a better job.  So if you have
    #
    # From: foo@bar.com
    #
    # then we'll add from:foo@bar.com to the corpus and not just
    # foo@bar.com

    my $prefix = '';

    if ( $header =~ /^(From|To|Cc|Reply\-To)$/i ) {
        # These headers at least can be decoded

        $argument = $self->decode_string( $argument, $lang );

        if ( $header =~ /^From$/i ) {
            $prefix = 'from';
            if ( $from eq '' ) {
                $from = $argument;
                $from =~ s/[\t\r\n]//g;
            }
        }

        if ( $header =~ /^To$/i ) {
            $prefix = 'to';
            if ( $to eq '' ) {
                $to = $argument;
                $to =~ s/[\t\r\n]//g;
            }
        }

        if ( $header =~ /^Cc$/i ) {
            $prefix = 'cc';
            if ( $cc eq '' ) {
                $cc = $argument;
                $cc =~ s/[\t\r\n]//g;
            }
        }

        while ( $argument =~ s/<([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+?))>// ) {
            $self->update_word( $1, 0, ';', '&', $prefix );
            $self->add_url( $2, 0, '@', '[&<]', $prefix );
        }

        while ( $argument =~ s/([[:alpha:]0-9\-_\.]+?@([[:alpha:]0-9\-_\.]+))// ) {
            $self->update_word( $1, 0, '', '', $prefix );
            $self->add_url( $2, 0, '@', '', $prefix );
        }

        $self->add_line( $argument, 0, $prefix );
        return ( $mime, $encoding );
    }

    if ( $header =~ /^Subject$/i ) {
        $prefix = 'subject';
        $argument = $self->decode_string( $argument, $lang );
        if ( $subject eq '' ) {
            # In Japanese mode, parse subject with Nihongo (Japanese) parser

            $argument = $nihongo_parser{parse}( $self, $argument )                if ( ( $lang eq 'Nihongo' ) && ( $argument ne '' ) );
            $subject = $argument;
            $subject =~ s/[\t\r\n]//g;
        }
    }

    $date = $argument if ( $header =~ /^Date$/i );

    if ( $header =~ /^X-Spam-Status$/i ) {
        # We have found a header added by SpamAssassin. We expect to
        # find keywords in here that will help us classify our
        # messages

        # We will find the keywords after the phrase "tests=" and
        # before SpamAssassin's version number or autolearn= string

        ( my $sa_keywords = $argument ) =~ s/[\r\n ]//sg;
        $sa_keywords =~ s/^.+tests=(.+)/$1/;
        $sa_keywords =~ s/(.+)autolearn.+$/$1/ or            $sa_keywords =~ s/(.+)version.+$/$1/;
        # remove all spaces that may still be present:
        $sa_keywords =~ s/[\t ]//g;

        foreach ( split /,/, $sa_keywords ) {
            $self->update_pseudoword( 'spamassassin', lc( $_ ), 0, $argument );
        }
    }

    if ( $header =~ /^X-SpamViper-Score$/ ) {
        # This is a header that was added by SpamViper. Works just
        # like the SpamAssassin header.

        ( my $sv_keywords = $argument ) =~ s/[\r\n]//g;

        # The keywords can be found after the phrase "Mail scored X
        # points":

        $sv_keywords =~ s/Mail scored \d+ points //;
        $sv_keywords =~ s/[\t ]//g;

        foreach ( split /,/, $sv_keywords ) {
            $self->update_pseudoword( 'spamviper', lc( $_ ), 0, $argument );
        }
    }

    if ( $header =~ /^X-Spam-Level$/i ) {
        my $count = ( $argument =~ tr/*// );
        for ( 1 .. $count ) {
            $self->update_pseudoword( 'spamassassinlevel', 'spam',                                      0, $argument );        }
    }

    # Look for MIME

    if ( $header =~ /^Content-Type$/i ) {
        if ( $argument =~ /charset=\"?([^\"\r\n\t ]{1,40})\"?/ ) {
            $charset = $1;
            $self->update_word( $1, 0, '', '', 'charset' );
        }

        if ( $argument =~ /^(.*?)(;)/ ) {
            print "Set content type to $1\n" if $debug;
            $content_type = $1;
        }

        if ( $argument =~ /multipart\//i ) {
            my $boundary = $argument;

            if ( $boundary =~ /boundary=[ ]?                               (\"([A-Z0-9\'\(\)\+\_\,\-\.\/\:\=\?]
                                   [A-Z0-9\'\(\)\+_,\-\.\/:=\? \@]{0,69})\"|
                                ([^\(\)\<\>\@\,\;\:\\\"\/\[\]\?\=]{1,70})
                               )/ix ) {
                $boundary = ( $2 || $3 );

                $boundary =~ s/(.*)/\Q$1\E/g;

                if ( $mime ne '' ) {
                    # Fortunately the pipe character isn't a valid
                    # mime boundary character!

                    $mime = join( '|', $mime, $boundary );
                } else {
                    $mime = $boundary;
                }
                print "Set mime boundary to $mime\n" if $debug;
                return ( $mime, $encoding );
            }
        }

        if ( $argument =~ /name=\"(.*)\"/i ) {
            $self->add_attachment_filename( $1 );
        }

        return ( $mime, $encoding );
    }

    # Look for the different encodings in a MIME document, when we hit
    # base64 we will do a special parse here since words might be
    # broken across the boundaries

    if ( $header =~ /^Content-Transfer-Encoding$/i ) {
        $encoding = $argument;
        print "Setting encoding to $encoding\n" if $debug;
        my $compact_encoding = $encoding;
        $compact_encoding =~ s/[^A-Za-z0-9]//g;
        $self->update_pseudoword( 'encoding', $compact_encoding,                                  0, $encoding );        return ( $mime, $encoding );
    }

    # Some headers to discard

    return ( $mime, $encoding )        if ( $header =~ /^(Thread-Index|X-UIDL|Message-ID|
                           X-Text-Classification|X-Mime-Key)$/ix );
    # Some headers should never be RFC 2047 decoded

    $argument = $self->decode_string( $argument, $lang )        if ( $header !~ /^(Received|Content\-Type|Content\-Disposition)$/i );
    if ( $header =~ /^Content-Disposition$/i ) {
        $self->handle_disposition( $argument );
        return ( $mime, $encoding );
    }

    $self->add_line( $argument, 0, $prefix );

    return ( $mime, $encoding );
}

# ----------------------------------------------------------------------------
#
# parse_css_ruleset - Parses text for CSS declarations
#                     Uses the second part of the "ruleset" grammar
#
# $line         The line to match
# $braces       1 if braces are included, 0 if excluded. Defaults to 0.
#               (optional)
# Returns       A hash of properties containing their expressions
#
# ----------------------------------------------------------------------------

method parse_css_style ($line, $braces) {
    # http://www.w3.org/TR/CSS2/grammar.html

    $braces = 0 if ( !defined( $braces ) );

    # A reference is used to return data

    my $hash = {};

    if ( $braces ) {
        $line =~ s/\{(.*?)\}/$1/;
    }
    while ( $line =~ s/^[ \t\r\n\f]*                       ([a-z][a-z0-9\-]+)[ \t\r\n\f]*:
                       [ \t\r\n\f]*(.*?)[ \t\r\n\f]?(;|$)//ix ) {        $hash->{ lc( $1 ) } = $2;
    }
    return $hash;
}

# ----------------------------------------------------------------------------
#
# parse_css_color - Parses a CSS color string
#
# $color        The string to parse
# Returns       (r,g,b) triplet in list context, rrggbb (hex) color in scalar
#               context
#
# In case of an error: (-1,-1,-1) in list context, "error" in scalar
# context
#
# ----------------------------------------------------------------------------

method parse_css_color ($color) {
    # CSS colors can be in a rgb(r,g,b), #hhh, #hhhhhh or a named color form

    # http://www.w3.org/TR/CSS2/syndata.html#color-units

    my ( $r, $g, $b, $error, $found ) = ( 0, 0, 0, 0, 0 );

    if ( $color =~ /^rgb\( ?(.*?) ?\, ?(.*?) ?\, ?(.*?) ?\)$/ ) {
        # rgb(r,g,b) can be expressed as values 0-255 or percentages 0%-100%,
        # numbers outside this range are allowed and should be clipped into
        # this range

        # TODO: store front/back colors in a RGB hash/array
        #       converting to a hh hh hh format and back
        #       is a waste as is repeatedly decoding
        #       from hh hh hh format

        ( $r, $g, $b ) = ( $1, $2, $3 );

        my $ispercent = 0;

        my $value_re   = qr/^((-[1-9]\d*)|([1-9]\d*|0))$/;
        my $percent_re = qr/^([1-9]\d+|0)%$/;

        my ( $r_temp, $g_temp, $b_temp );

        if ( ( ($r_temp) = ($r =~ $percent_re) ) &&             ( ($g_temp) = ($g =~ $percent_re) ) &&
             ( ($b_temp) = ($b =~ $percent_re) ) ) {
            $ispercent = 1;

            # clip to 0-100
            $r_temp = 100 if ( $r_temp > 100 );
            $g_temp = 100 if ( $g_temp > 100 );
            $b_temp = 100 if ( $b_temp > 100 );

            # convert into 0-255 range
            $r = int( ( ( $r_temp / 100 ) * 255 ) + .5 );
            $g = int( ( ( $g_temp / 100 ) * 255 ) + .5 );
            $b = int( ( ( $b_temp / 100 ) * 255 ) + .5 );

            $found = 1;
        }

        if ( ( $r =~ $value_re ) &&             ( $g =~ $value_re ) &&
             ( $b =~ $value_re ) ) {
            $ispercent = 0;

            #clip to 0-255

            $r =   0 if ( $r <=   0 );
            $r = 255 if ( $r >= 255 );
            $g =   0 if ( $g <=   0 );
            $g = 255 if ( $g >= 255 );
            $b =   0 if ( $b <=   0 );
            $b = 255 if ( $b >= 255 );

            $found = 1;
        }

        if ( !$found ) {
            # here we have a combination of percentages and integers
            # or some other oddity
            $ispercent = 0;
            $error     = 1;
        }

        print "        CSS rgb($r, $g, $b) percent: $ispercent\n" if $debug;
    }
    if ( $color =~ /^#(([0-9a-f]{3})|([0-9a-f]{6}))$/i ) {
        # #rgb or #rrggbb
        print "        CSS numeric form: $color\n" if $debug;

        $color = $2 || $3;

        if ( defined( $2 ) ) {
            # in 3 value form, the value is computed by doubling each digit

            ( $r, $g, $b ) = ( hex( $1 x 2 ), hex( $2 x 2 ), hex( $3 x 2 ) )                if ( $color =~ /^(.)(.)(.)$/ );        } else {
            ( $r, $g, $b ) = ( hex( $1 ), hex( $2 ), hex( $3 ) )                if ( $color =~ /^(..)(..)(..)$/ );        }
        $found = 1;
    }
    if ( $color =~ /^(aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|                      olive|purple|red|silver|teal|white|yellow)$/i ) {
        # these are the only CSS defined colours

        print "       CSS textual color form: $color\n" if $debug;

        my $new_color = $self->map_color( $color );

        # our color map may have failed

        $error = 1 if ( $new_color eq $color );
        ( $r, $g, $b ) = ( hex( $1 ), hex( $2 ), hex( $3 ) )            if ( $new_color =~ /^(..)(..)(..)$/ );        $found = 1;
    }

    $found = 0 if ( $error );

    if ( $found &&         defined( $r ) && ( 0 <= $r ) && ( $r <= 255 ) &&
         defined( $g ) && ( 0 <= $g ) && ( $g <= 255 ) &&
         defined( $b ) && ( 0 <= $b ) && ( $b <= 255 ) ) {        if ( wantarray ) {
            return ( $r, $g, $b );
        } else {
            $color = sprintf( '%1$02x%2$02x%3$02x', $r, $g, $b );
            return $color;
        }
    } else {
        if ( wantarray ) {
            return ( -1, -1, -1 );
        } else {
            return "error";
        }
    }
}

# ----------------------------------------------------------------------------
#
# match_attachment_filename - Matches a line like 'attachment;
# filename="<filename>"
#
# $line         The line to match
# Returns       The first match (= "attchment" if found)
#               The second match (= name of the file if found)
#
# ----------------------------------------------------------------------------
method match_attachment_filename ($line) {
    $line =~ /\s*(.*);\s*filename=\"(.*)\"/;

    return ( $1, $2 );
}

# ----------------------------------------------------------------------------
#
# file_extension - Splits a filename into name and extension
#
# $filename     The filename to split
# Returns       The name of the file
#               The extension of the file
#
# ----------------------------------------------------------------------------
method file_extension ($filename) {
    if ( $filename =~ m/(.*)\.(.*)$/ ) {
        return ( $1, $2 );
    } else {
        return ( $filename, '' );
    }
}

# ----------------------------------------------------------------------------
#
# add_attachment_filename - Adds a file name and extension as pseudo
#                           words attchment_name and attachment_ext
#
# $filename     The filename to add to the list of words
#
# ----------------------------------------------------------------------------
method add_attachment_filename ($filename) {
    if ( defined( $filename ) && ( $filename ne '' ) ) {
        print "Add filename $filename\n" if $debug;

        # Decode the filename
        $filename = $self->decode_string( $filename );

        my ( $name, $ext ) = $self->file_extension( $filename );

        if ( defined( $name ) && ( $name ne '' ) ) {
            $self->update_pseudoword( 'mimename', $name, 0, $name );
        }

        if ( defined( $ext ) && ( $ext ne '' ) ) {
            $self->update_pseudoword( 'mimeextension', $ext, 0, $ext );
        }
    }
}

# ----------------------------------------------------------------------------
#
# handle_disposition - Parses Content-Disposition header to extract filename.
#                      If filename found, at the file name and extension to
#                      the word list
#
# $params     The parameters of the Content-Disposition header
#
# ----------------------------------------------------------------------------
method handle_disposition ($params) {
    my ( $attachment, $filename ) = $self->match_attachment_filename( $params );

    if ( defined( $attachment ) && ( $attachment eq 'attachment' ) ) {
        $self->add_attachment_filename( $filename );
    }
}

# ----------------------------------------------------------------------------
#
# splitline - Escapes characters so a line will print as plain-text
#             within a HTML document.
#
# $line         The line to escape
# $encoding     The value of any current encoding scheme
#
# ----------------------------------------------------------------------------
method splitline ($line, $encoding) {
    $line =~ s/([^\r\n]{100,120} )/$1\r\n/g;
    $line =~ s/([^ \r\n]{120})/$1\r\n/g;

    $line =~ s/</&lt;/g;
    $line =~ s/>/&gt;/g;

    if ( $encoding =~ /quoted\-printable/i ) {
        $line =~ s/=3C/&lt;/g;
        $line =~ s/=3E/&gt;/g;
    }

    $line =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;

    return $line;
}

# GETTERS/SETTERS

method first20 {
    return $first20;
}

method quickmagnets {
    return \%quickmagnets;
}

method words {
    return \%words;
}

# ----------------------------------------------------------------------------
#
# convert_encoding
#
# Convert string from one encoding to another
#
# $string       The string to be converted
# $from         Original encoding
# $to           The encoding which the string is converted to
# $default      The default encoding that is used when $from is invalid or not
#               defined
# @candidates   Candidate encodings for guessing
# ----------------------------------------------------------------------------
sub convert_encoding
{
    my ( $string, $from, $to, $default, @candidates ) = @_;

    # If the string contains only ascii characters, do nothing.
    return $string if ( $string =~ /^[\r\n\t\x20-\x7E]*$/ );

    require Encode;
    require Encode::Guess;

    # First, guess the encoding.

    my $enc = Encode::Guess::guess_encoding( $string, @candidates );

    if ( ref $enc ) {
        $from = $enc->name;
    } else {
        # If guess does not work, check whether $from is valid.

        if ( !( Encode::resolve_alias( $from ) ) ) {
            # Use $default as $from when $from is invalid.

            $from = $default;
        }
    }

    if ( $from ne $to ) {
        my ( $orig_string ) = $string;

        # Workaround for Encode::Unicode error bug.
        eval {
            no warnings 'utf8';
            if ( ref $enc ) {
                $string = Encode::encode( $to, $enc->decode( $string ) );
            } else {
                Encode::from_to( $string, $from, $to );
            }
        };
        $string = $orig_string if ( $@ );
    }
    return $string;
}

# ----------------------------------------------------------------------------
#
# parse_line_with_kakasi
#
# Parse a line with Kakasi
#
# Japanese needs to be parsed by language processing filter, "Kakasi"
# before it is passed to Bayes classifier because words are not
# splitted by spaces.
#
# $line          The line to be parsed
#
# ----------------------------------------------------------------------------
method parse_line_with_kakasi ($line) {
    # If the line does not contain Japanese characters, do nothing
    return $line if ( $line =~ /^[\x00-\x7F]*$/ );

    # Split Japanese line into words using Kakasi Wakachigaki mode
    $line = Text::Kakasi::do_kakasi( $line );

    return $line;
}

# ----------------------------------------------------------------------------
#
# parse_line_with_mecab
#
# Parse a line with MeCab
#
# Split Japanese words by spaces using "MeCab" - Yet Another Part-of-Speech
# and Morphological Analyzer.
#
# $line          The line to be parsed
#
# ----------------------------------------------------------------------------
method parse_line_with_mecab ($line) {
    # If the line does not contain Japanese characters, do nothing
    return $line if ( $line =~ /^[\x00-\x7F]*$/ );

    # Split Japanese line into words using MeCab
    $line = $nihongo_parser{obj_mecab}->parse( $line );

    # Remove the unnecessary white spaces
    $line =~ s/([\x00-\x1f\x21-\x7f]) (?=[\x00-\x1f\x21-\x7f])/$1/g;

    return $line;
}

# ----------------------------------------------------------------------------
#
# parse_line_with_internal_parser
#
# Parse a line with an internal perser
#
# Split characters by kind of the character
#
# $line          The line to be parsed
#
# ----------------------------------------------------------------------------
method parse_line_with_internal_parser ($line) {
    # If the line does not contain Japanese characters, do nothing
    return $line if ( $line =~ /^[\x00-\x7F]*$/ );

    # Split Japanese line into words by the kind of characters
    $line =~ s/\G$euc_jp_word/$1 /og;

    return $line;
}

# ----------------------------------------------------------------------------
#
# init_kakasi
#
# Open the kanwa dictionary and initialize the parameter of Kakasi.
#
# ----------------------------------------------------------------------------
sub init_kakasi
{
    # Initialize Kakasi with Wakachigaki mode(-w is passed to
    # Kakasi as argument). Both input and ouput encoding are
    # EUC-JP.

    Text::Kakasi::getopt_argv( 'kakasi', '-w', '-ieuc', '-oeuc' );
}

# ----------------------------------------------------------------------------
#
# init_mecab
#
# Create a new parser object of MeCab.
#
# ----------------------------------------------------------------------------
method init_mecab {
    # Initialize MeCab (-F %M\s -U %M\s -E \n is passed to MeCab as argument).
    # Insert white spaces after words.

    $nihongo_parser{obj_mecab}        = MeCab::Tagger->new( '-F %M\s -U %M\s -E \n' );}

# ----------------------------------------------------------------------------
#
# close_kakasi
#
# Close the kanwa dictionary of Kakasi.
#
# ----------------------------------------------------------------------------
sub close_kakasi
{
    Text::Kakasi::close_kanwadict();
}

# ----------------------------------------------------------------------------
#
# close_mecab
#
# Free the parser object of MeCab.
#
# ----------------------------------------------------------------------------
method close_mecab {
    $nihongo_parser{obj_mecab} = undef;
}

# ----------------------------------------------------------------------------
#
# setup_nihongo_parser
#
# Check whether Nihongo (Japanese) parsers are available and setup subroutines.
#
# $nihongo_parser  Nihongo (Japanese) parser to use
#                  ( kakasi / mecab / internal )
#
# ----------------------------------------------------------------------------
method setup_nihongo_parser ($nihongo_parser) {
    # If MeCab is installed, use MeCab.
    if ( $nihongo_parser eq 'mecab' ) {
        my $has_mecab = 0;

        foreach my $prefix ( @INC ) {
            my $realfilename = "$prefix/MeCab.pm";
            if ( -f $realfilename ) {
                $has_mecab = 1;
                last;
            }
        }

        # If MeCab is not installed, try to use Text::Kakasi.
        $nihongo_parser = 'kakasi' if ( !$has_mecab );
    }

    # If Text::Kakasi is installed, use Text::Kakasi.
    if ( $nihongo_parser eq 'kakasi' ) {
        my $has_kakasi = 0;

        foreach my $prefix ( @INC ) {
            my $realfilename = "$prefix/Text/Kakasi.pm";
            if ( -f $realfilename ) {
                $has_kakasi = 1;
                last;
            }
        }

        # If Kakasi is not installed, use the internal parser.
        $nihongo_parser = 'internal' if ( !$has_kakasi );
    }

    # Setup perser's subroutines
    if ( $nihongo_parser eq 'mecab' ) {
        # Import MeCab module
        require MeCab;
        MeCab->import();

        $nihongo_parser{init}  = \&init_mecab;
        $nihongo_parser{parse} = \&parse_line_with_mecab;
        $nihongo_parser{close} = \&close_mecab;
    } elsif ( $nihongo_parser eq 'kakasi' ) {
        # Import Text::Kakasi module
        require Text::Kakasi;
        Text::Kakasi->import();

        $nihongo_parser{init}  = \&init_kakasi;
        $nihongo_parser{parse} = \&parse_line_with_kakasi;
        $nihongo_parser{close} = \&close_kakasi;
    } else {
        # Require no external modules
        $nihongo_parser{init}  = sub { }; # Needs no initialization
        $nihongo_parser{parse} = \&parse_line_with_internal_parser;
        $nihongo_parser{close} = sub { };
    }

    return $nihongo_parser;
}

} # end class Classifier::MailParse

1;
