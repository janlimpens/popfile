# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Services::IMAP::Folder;

=head1 NAME

Services::IMAP::Folder - value object representing an IMAP folder

=head1 DESCRIPTION

A value object that holds both the internal UTF-8 folder name and the
IMAP Modified UTF-7 encoded name used on the wire.  This class encapsulates
the conversion between the two formats.

Instances are created either from IMAP-encoded names (from the server) or
from internal UTF-8 names (for sending commands).

=cut

use Object::Pad;

class Services::IMAP::Folder;

use Encode qw(decode encode);
use MIME::Base64 qw(encode_base64 decode_base64);

field $name :param :reader;
field $imap_name :param :reader = undef;
field $watched :param :reader :writer = 0;
field $output_bucket :param :reader :writer = undef;

method _encode_chunk ($chunk) {
    return ''
        if $chunk eq '';
    my $encoded = encode('UTF-16BE', $chunk);
    $encoded = encode_base64($encoded, '');
    $encoded =~ s/=+$//;
    $encoded =~ s/\//+/g;
    return '&' . $encoded . '-'
}

method _utf8_to_imap_utf7 ($str) {
    return ''
        unless defined $str;
    my $result = '';
    my $i = 0;
    my $len = length $str;
    while ($i < $len) {
        my $char = substr($str, $i, 1);
        my $ord = ord($char);
        if ($ord == 0x26) {
            $result .= '&-';
            $i++;
        } elsif ($ord >= 0x20 && $ord <= 0x7e) {
            $result .= $char;
            $i++;
        } else {
            my $j = $i;
            while ($j < $len) {
                my $c = substr($str, $j, 1);
                my $o = ord($c);
                last
                    if $o >= 0x20 && $o <= 0x7e;
                $j++;
            }
            my $chunk = substr($str, $i, $j - $i);
            $result .= $self->_encode_chunk($chunk);
            $i = $j;
        }
    }
    return $result
}

method _decode_chunk ($chunk) {
    return '&'
        if $chunk eq '';
    (my $b = $chunk) =~ tr|+|/|;
    return decode('UTF-16BE', decode_base64($b))
}

method _imap_utf7_to_utf8 ($str) {
    return ''
        unless defined $str;
    $str =~ s/&([^-]*)-/$self->_decode_chunk($1)/ge;
    return $str
}

sub from_imap_name ($class, $encoded) {
    my $tmp = $class->new(name => '');
    my $decoded = $tmp->_imap_utf7_to_utf8($encoded);
    return $class->new(
        name => $decoded,
        imap_name => $encoded,
    )
}

method to_imap_name () {
    return $imap_name // $self->_utf8_to_imap_utf7($name)
}

1;
