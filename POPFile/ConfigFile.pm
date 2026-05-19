# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

class POPFile::ConfigFile;

use Cpanel::JSON::XS;
use Crypt::Cipher::AES;
use Crypt::Mode::CBC;
use MIME::Base64 qw(encode_base64 decode_base64);
use Path::Tiny qw(path);

field $json_encoder = Cpanel::JSON::XS->new()->utf8()->pretty()->canonical();
field $json_decoder = Cpanel::JSON::XS->new()->utf8();

my @SENSITIVE_KEYS = qw(password);

method _crypto_key() {
    require Digest::SHA;
    my $seed = ($ENV{POPFILE_ROOT} // '.') . ':popfile-config-key';
    Digest::SHA::sha256($seed)
}

method _encrypt($plaintext) {
    return $plaintext if $plaintext eq '' || $plaintext =~ /^ENC:/;
    my $key = $self->_crypto_key();
    my $iv = Crypt::Cipher::AES->new($key)->encrypt('0' x 16);
    my $pad_len = 16 - (length($plaintext) % 16);
    my $padded = $plaintext . chr($pad_len) x $pad_len;
    my $cbc = Crypt::Mode::CBC->new('AES', 0);
    my $cipher = $cbc->encrypt($padded, $key, $iv);
    'ENC:' . encode_base64($iv . $cipher, '')
}

method _decrypt($ciphertext) {
    return $ciphertext unless $ciphertext =~ s/^ENC://;
    my $raw = decode_base64($ciphertext);
    return $ciphertext if length($raw) < 16;
    my $iv = substr($raw, 0, 16, '');
    my $key = $self->_crypto_key();
    my $cbc = Crypt::Mode::CBC->new('AES', 0);
    my $plain = $cbc->decrypt($raw, $key, $iv);
    my $pad = ord(substr($plain, -1));
    $plain = substr($plain, 0, -$pad)
        if $pad > 0 && $pad <= 16;
    $plain
}

method _walk_sensitive($node, $coderef) {
    return unless ref $node eq 'HASH';
    for my $k (keys $node->%*) {
        if (ref $node->{$k} eq 'HASH') {
            $self->_walk_sensitive($node->{$k}, $coderef);
        } elsif (!ref $node->{$k} && $node->{$k} ne '') {
            $node->{$k} = $coderef->($node->{$k})
                if grep { $_ eq $k } @SENSITIVE_KEYS;
        }
    }
}

method load($path) {
    return +{version => 2}
        unless -e $path;
    my $content = path($path)->slurp_utf8();
    my $data = $json_decoder->decode($content);
    $self->_walk_sensitive($data, sub($v) { $self->_decrypt($v) });
    return $data
}

method save($path, $data) {
    my $clone = $json_decoder->decode($json_encoder->encode($data));
    $self->_walk_sensitive($clone, sub($v) { $self->_encrypt($v) });
    my $tmp = "$path.tmp";
    path($tmp)->spew_utf8($json_encoder->encode($clone));
    rename($tmp, $path) or die "Cannot rename $tmp to $path: $!";
    chmod(0600, $path);
    return
}

1;
