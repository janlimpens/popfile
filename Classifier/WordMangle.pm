package Classifier::WordMangle;

use Object::Pad;

# ----------------------------------------------------------------------------
#
# WordMangle.pm --- Mangle words for better classification
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

use locale;

# These are used for Japanese support

my $ascii             = '[\x00-\x7F]';
my $two_bytes_euc_jp  = '(?:[\x8E\xA1-\xFE][\xA1-\xFE])';
my $three_bytes_euc_jp = '(?:\x8F[\xA1-\xFE][\xA1-\xFE])';
my $euc_jp = "(?:$ascii|$two_bytes_euc_jp|$three_bytes_euc_jp)";

class Classifier::WordMangle :isa(POPFile::Module) {
    field %stop__;

    BUILD {
        $self->set_name('wordmangle');
    }

    method start {
        $self->load_stopwords();
        return 1;
    }

    # -------------------------------------------------------------------------
    #
    # load_stopwords, save_stopwords
    #
    # Load and save the stop word list from/to the stopwords file.
    #
    # -------------------------------------------------------------------------
    method load_stopwords {
        if ( open my $stops, '<', $self->get_user_path('stopwords') ) {
            %stop__ = ();
            while ( <$stops> ) {
                s/[\r\n]//g;
                $stop__{$_} = 1;
            }
            close $stops;
        } else {
            $self->log_msg(0, 'Failed to open stopwords file' );
        }
    }

    method save_stopwords {
        if ( open my $stops, '>', $self->get_user_path('stopwords') ) {
            for my $word ( keys %stop__ ) {
                print $stops "$word\n";
            }
            close $stops;
        }
    }

    # -------------------------------------------------------------------------
    #
    # mangle
    #
    # Mangles a word into its canonical form or returns '' to indicate the
    # word should be ignored.
    #
    # $word           The word to mangle
    # $allow_colon    If set, allows ':' inside a word (for header pseudowords)
    # $ignore_stops   If set, ignores the stop word list
    #
    # -------------------------------------------------------------------------
    method mangle ($word, $allow_colon = undef, $ignore_stops = undef) {
        my $lcword = lc($word);

        return '' unless $lcword;

        return '' if ( ( $stop__{$lcword} || $stop__{$word} )
                       && !defined($ignore_stops) );

        $lcword =~ s/(\+|\/|\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.|\\)/\./g;

        return '' if length($lcword) > 45;

        return '' if $lcword =~ /^[A-F0-9]{8,}$/i;

        $lcword =~ s/://g if !defined($allow_colon);

        return ( $lcword =~ /:/ ) ? $word : $lcword;
    }

    # -------------------------------------------------------------------------
    #
    # add_stopword, remove_stopword
    #
    # Add or remove a stop word.  Returns 1 on success, 0 for invalid input.
    #
    # $stopword    The word to add or remove
    # $lang        The current language
    #
    # -------------------------------------------------------------------------
    method add_stopword ($stopword, $lang = '') {
        if ( $lang eq 'Nihongo' ) {
            return 0 if $stopword !~ /^($euc_jp)+$/o;
        } else {
            return 0 if ( $stopword !~ /:/ )
                     && ( $stopword =~ /[^[:alpha:]\-_\.\@0-9]/i );
        }

        $stopword = $self->mangle( $stopword, 1, 1 );

        if ( $stopword ne '' ) {
            $stop__{$stopword} = 1;
            $self->save_stopwords();
            return 1;
        }

        return 0;
    }

    method remove_stopword ($stopword, $lang = '') {
        if ( $lang eq 'Nihongo' ) {
            return 0 if $stopword !~ /^($euc_jp)+$/o;
        } else {
            return 0 if ( $stopword !~ /:/ )
                     && ( $stopword =~ /[^[:alpha:]\-_\.\@0-9]/i );
        }

        $stopword = $self->mangle( $stopword, 1, 1 );

        if ( $stopword ne '' ) {
            delete $stop__{$stopword};
            $self->save_stopwords();
            return 1;
        }

        return 0;
    }

    # -------------------------------------------------------------------------
    # stopwords accessor — returns list of current stopwords
    # -------------------------------------------------------------------------
    method stopwords ($value = undef) {
        %stop__ = %{$value} if defined $value;
        return keys %stop__;
    }
}

1;
