# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

class POPFile::ConfigFile;

use Cpanel::JSON::XS;
use Path::Tiny qw(path);

field $json_encoder = Cpanel::JSON::XS->new()->utf8()->pretty()->canonical();
field $json_decoder = Cpanel::JSON::XS->new()->utf8();

method load($path) {
    my $content = path($path)->slurp_utf8();
    return $json_decoder->decode($content)
}

method save($path, $data) {
    path($path)->spew_utf8($json_encoder->encode($data), {atomic => 1});
    chmod(0600, $path);
    return
}

1;
