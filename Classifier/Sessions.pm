# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Sessions;

use Object::Pad;
use feature qw(state try);
use Digest::MD5 qw(md5_hex);

class Classifier::Sessions :does(POPFile::Role::Logging);

=head1 NAME

Classifier::Sessions — session-key repository for Bayes classifier access

=head1 DESCRIPTION

Manages the collection of active session keys that map random string tokens
to internal user IDs.  Provides creation, validation, and removal primitives.

All dependencies are passed in method signatures rather than stored as fields.

=cut

field $api_sessions = {};

=head2 create_session($dbh, $user, $pwd)

Validates C<$user> / C<$pwd> against the C<users> table.  On success returns
C<(session_key, userid)>.  On failure returns an empty list after a one-second
delay to thwart brute-force attacks.

=cut

method create_session($dbh, $user, $pwd) {
    state $sth;
    $sth //= $dbh->prepare(
        'SELECT id FROM users WHERE name = ? AND password = ? LIMIT 1');
    my $hash = md5_hex($user . '__popfile__' . $pwd);
    $sth->execute($user, $hash);
    my $result = $sth->fetchrow_arrayref;
    unless (defined($result)) {
        $self->log_msg(WARN => "Attempt to login with incorrect credentials for user $user");
        select(undef, undef, undef, 1);
        return ()
    }
    my $session = $self->_generate_key();
    $api_sessions->{$session} = $result->[0];
    $self->log_msg(INFO => "get_session_key returning key $session for user $api_sessions->{$session}");
    return ($session, $result->[0])
}

=head2 validate_session($session)

Returns the user ID for a valid session key, or C<undef> after a one-second
delay and warning.  Only callable from C<Classifier::Bayes>.

=cut

method validate_session($session) {
    return
        unless caller eq 'Classifier::Bayes';
    unless (defined $api_sessions->{$session}) {
        my ($package, $filename, $line, $subroutine) = caller(1);
        $self->log_msg(WARN => "Invalid session key $session provided in $package @ $line");
        select(undef, undef, undef, 1);
    }
    return $api_sessions->{$session}
}

=head2 remove_session($session)

Deletes the session key from the active set.  Logs the release if the key
was present; silently no-ops otherwise.

=cut

method remove_session($session) {
    if (defined $api_sessions->{$session}) {
        $self->log_msg(INFO => "release_session_key releasing key $session for user $api_sessions->{$session}");
        delete $api_sessions->{$session};
    }
}

#----------------------------------------------------------------------------
# Private

method _generate_key() {
    my @chars = ('A'..'Z', 0..9);
    my $session = '';
    do {
        my $length = int(16 + rand(4));
        for my $i (0 .. $length) {
            my $random = $chars[int(rand(scalar @chars))];
            if (rand(1) < rand(1)) {
                $random = lc($random);
            }
            $session .= $random;
        }
    } while defined $api_sessions->{$session};
    return $session
}

1;
