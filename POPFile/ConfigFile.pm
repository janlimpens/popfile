# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::ConfigFile;

=head1 NAME

POPFile::ConfigFile - JSON-based configuration file I/O

=head1 DESCRIPTION

This module provides atomic read/write operations for POPFile's JSON
configuration file.  It handles UTF-8 encoding, advisory locking, and
atomic writes via temp-file + rename.

=cut

use Object::Pad;

class POPFile::ConfigFile;

use Cpanel::JSON::XS;
use Fcntl qw(:flock :seek :mode);
use Path::Tiny qw(path);

field $json_encoder;
field $json_decoder;

ADJUST {
    $json_encoder = Cpanel::JSON::XS->new->utf8->pretty->canonical;
    $json_decoder = Cpanel::JSON::XS->new->utf8;
}

method load ($path) {
    my $fh = path($path)->openr_utf8();
    flock($fh, LOCK_SH) or die "Cannot lock $path: $!";
    my $content = do { local $/; <$fh> };
    $fh->close();
    
    return $json_decoder->decode($content)
}

method save ($path, $data) {
    my $tmp_path = $path . '.tmp';
    
    my $fh = path($tmp_path)->openw_utf8();
    print $fh $json_encoder->encode($data);
    $fh->close();
    
    my $dest_fh = path($path)->openrw();
    flock($dest_fh, LOCK_EX) or die "Cannot lock $path: $!";
    
    rename($tmp_path, $path) or die "Cannot rename $tmp_path to $path: $!";
    chmod(MODE(0600), $path);
    
    $dest_fh->close();
}

1;
