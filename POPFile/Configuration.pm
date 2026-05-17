# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::Configuration;

=head1 NAME

POPFile::Configuration — PID management, path resolution, CLI parsing

=head1 DESCRIPTION

Manages the POPFile PID file, resolves user/root paths, parses the command
line, and provides encryption helpers for sensitive config values.

Configuration storage has moved to L<POPFile::Config> and L<POPFile::ConfigFile>.
This module no longer stores or persists configuration parameters.

=cut

use Object::Pad;
use locale;

use Getopt::Long;

class POPFile::Configuration
    :isa(POPFile::Module);

field $pid_file = '';
field $pid_check = 0;
field $pidcheck_interval = 5;
field $started :reader :writer = 0;
field $popfile_root :reader :writer = $ENV{POPFILE_ROOT} || './';
field $popfile_user :reader :writer = $ENV{POPFILE_USER} || './';

BUILD {
    $pid_check = time;
    $self->set_name("config");
}

=head2 initialize

Subscribes to the C<TICKD> message for periodic PID checks.

=cut

method initialize() {
    $self->mq_register('TICKD', $self);
    return 1;
}

=head2 start

Writes the PID file and aborts startup if another POPFile instance is
already running.  Returns 1 on success, 0 if a live instance was detected.

=cut

method start() {
    $started = 1;
    $pid_file = $self->get_user_path('popfile.pid', 0);
    if (defined($self->live_check())) {
        return 0;
    }
    $self->write_pid();
    return 1;
}

=head2 service

Periodically checks the PID file and rewrites it if it has been removed
(e.g. by a signal from another instance).  Returns 1 normally.

=cut

method service() {
    my $time = time;
    if ($pid_check <= ($time - $pidcheck_interval)) {
        $pid_check = $time;
        if (!$self->check_pid()) {
            $self->write_pid();
            $self->log_msg(WARN => "New POPFile instance detected and signalled");
        }
    }
    return 1;
}

=head2 stop

Deletes the PID file.

=cut

method stop() {
    $self->delete_pid();
}

=head2 deliver

Handles the C<TICKD> message (no-op — periodic saves are handled by ConfigFile).

=cut

method deliver ($type, @message) {
}

=head2 live_check

Checks whether another POPFile instance is running by reading the existing
PID file.  Waits up to C<pidcheck_interval * 2> seconds for the other
instance to respond.  Returns the PID of the running instance, or C<undef>
if none.

=cut

method live_check() {
    if ($self->check_pid()) {
        my $oldpid = $self->get_pid();
        my $wait_time = $pidcheck_interval * 2;
        my $error = "\n\nA copy of POPFile appears to be running.\n Attempting to signal the previous copy.\n Waiting $wait_time seconds for a reply.\n";
        $self->delete_pid();
        print STDERR $error;
        select(undef, undef, undef, $wait_time);
        my $pid = $self->get_pid();
        if (defined($pid)) {
            $error = "\n A copy of POPFile is running.\n It has signaled that it is alive with process ID: $pid\n";
            print STDERR $error;
            return $pid;
        } else {
            print STDERR "\nThe other POPFile ($oldpid) failed to signal back, starting new copy ($$)\n";
        }
    }
    return;
}

=head2 check_pid

Returns true if the PID file exists on disk.

=cut

method check_pid() {
    return (-e $pid_file);
}

=head2 get_pid

Returns the process ID stored in the PID file, or C<undef> if the file
cannot be read.

=cut

method get_pid() {
    if (open my $pid_fh, '<', $pid_file) {
        my $pid = <$pid_fh>;
        $pid =~ s/[\r\n]//g;
        close $pid_fh;
        return $pid;
    }
    return;
}

=head2 write_pid

Writes the current process ID (C<$$>) to the PID file.

=cut

method write_pid() {
    if (open my $pid_fh, '>', $pid_file) {
        print $pid_fh "$$\n";
        close $pid_fh;
    }
}

=head2 delete_pid

Removes the PID file from disk.

=cut

method delete_pid() {
    unlink($pid_file);
}

=head2 parse_command_line

Parses C<@ARGV> using L<Getopt::Long>.  Accepts C<--set key=value> pairs and
legacy positional C<-key value> pairs.  Returns 1 on success, 0 on parse error.

=cut

method parse_command_line() {
    my @set_options;
    if (!GetOptions("set=s" => \@set_options)) {
        return 0;
    }
    for my $i (0..$#set_options) {
        $set_options[$i] =~ /-?(.+)=(.+)/;
        unless (defined $1) {
            print STDERR "\nBad option: $set_options[$i]\n";
            return 0;
        }
    }
    return 1;
}

=head2 get_user_path

    my $path = $self->get_user_path($relative_path);
    my $path = $self->get_user_path($relative_path, $sandbox);

Resolves C<$relative_path> relative to C<POPFILE_USER>.  When C<$sandbox>
is true (the default), absolute paths and paths containing C<..> are
rejected.

=cut

method get_user_path ($path, $sandbox = undef) {
    return $self->path_join($popfile_user, $path, $sandbox);
}

=head2 get_root_path

Like L</get_user_path> but resolves relative to C<POPFILE_ROOT>.

=cut

method get_root_path ($path, $sandbox = undef) {
    return $self->path_join($popfile_root, $path, $sandbox);
}

=head2 path_join

    my $full = $self->path_join($left, $right);
    my $full = $self->path_join($left, $right, $sandbox);

Concatenates two path segments.  When C<$sandbox> is true (the default),
returns C<undef> and logs a warning if C<$right> is absolute or contains
C<..>.

=cut

method path_join ($left, $right, $sandbox = undef) {
    $sandbox //= 1;
    $right //= '';
    if ($right =~ /^\// || $right =~ /^[A-Za-z]:[\/\\]/ || $right =~ /\\\\/) {
        if ($sandbox) {
            $self->log_msg(WARN => "Attempt to access path $right outside sandbox");
            return;
        } else {
            return $right;
        }
    }
    if ($sandbox && $right =~ /\.\./) {
        $self->log_msg(WARN => "Attempt to access path $right outside sandbox");
        return;
    }
    $left =~ s/\/$//;
    $right =~ s/^\///;
    return "$left/$right";
}

=head2 _is_sensitive_key

Returns true for configuration keys whose values should be encrypted at rest.

=cut

my @SENSITIVE_KEYS = qw(api_password imap_password);

method _is_sensitive_key($key) {
    return 1 if grep { $_ eq $key } @SENSITIVE_KEYS;
    return 0
}

=head2 _encrypt_config

Encrypts a sensitive configuration value using AES-256-CBC with a key derived
from the POPFile root path.

=cut

method _encrypt_config($plaintext) {
    return $plaintext if $plaintext eq '' || $plaintext =~ /^ENC:/;
    require Crypt::Cipher::AES;
    require Crypt::Mode::CBC;
    require MIME::Base64;
    my $key = $self->_crypto_key();
    my $iv = Crypt::Cipher::AES->new($key)->encrypt('0' x 16);
    my $padded = $plaintext . chr(16 - (length($plaintext) % 16)) x (16 - (length($plaintext) % 16));
    my $cbc = Crypt::Mode::CBC->new('AES', 0);
    my $cipher = $cbc->encrypt($padded, $key, $iv);
    return 'ENC:' . MIME::Base64::encode_base64($iv . $cipher, '')
}

=head2 _decrypt_config

Decrypts a value previously encrypted with C<_encrypt_config>.

=cut

method _decrypt_config($ciphertext) {
    return $ciphertext unless $ciphertext =~ s/^ENC://;
    require MIME::Base64;
    require Crypt::Mode::CBC;
    my $raw = MIME::Base64::decode_base64($ciphertext);
    return $ciphertext if length($raw) < 16;
    my $iv = substr($raw, 0, 16, '');
    my $key = $self->_crypto_key();
    my $cbc = Crypt::Mode::CBC->new('AES', 0);
    my $plain = $cbc->decrypt($raw, $key, $iv);
    my $pad = ord(substr($plain, -1));
    $plain = substr($plain, 0, -$pad)
        if $pad > 0 && $pad <= 16;
    return $plain
}

=head2 _crypto_key

Derives a 32-byte AES-256 key from the POPFile root path using SHA-256.
The key is deterministic per installation.

=cut

method _crypto_key() {
    require Digest::SHA;
    my $seed = $popfile_root . ':popfile-config-key';
    return Digest::SHA::sha256($seed)
}

1;
