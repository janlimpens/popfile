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
use MIME::Base64 qw(encode_base64);

field $name :param :reader;         # Internal name (UTF-8)
field $imap_name :param :reader;    # IMAP Modified UTF-7 Name
field $watched :param :reader :writer = 0;
field $output_bucket :param :reader :writer = undef;

BEGIN {
    *IMAP_SPECIALS = sub () { '&', '-', '.' }
}

method _imap_utf7_encode ($chunk) {
    return ''
        if $chunk eq '';
    
    my $encoded = encode('UTF-16BE', $chunk);
    $encoded = encode_base64($encoded, '');
    $encoded =~ s/\//+/g;
    
    return '&' . $encoded . '-'
}

method from_imap_name ($encoded) {
    my $decoded = $self->_imap_utf7_decode($encoded);
    return Services::IMAP::Folder->new(
        name      => $decoded,
        imap_name => $encoded,
    )
}

method _imap_utf7_decode($chunk) {
    return '&'
        if $chunk eq '';
    (my $b = $chunk) =~ tr/+/\//;
    return decode('UTF-16BE', decode_base64($b))
}

method to_imap_name () {
    return $imap_name // $self->_imap_utf7_encode($name)
}

1;
