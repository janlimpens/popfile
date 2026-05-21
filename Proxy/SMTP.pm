# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Proxy::SMTP;

use Object::Pad;
use locale;

my $eol = "\015\012";

class Proxy::SMTP :isa(Proxy::Proxy);


=head1 NAME

Proxy::SMTP — SMTP proxy that classifies outgoing messages with POPFile

=head1 DESCRIPTION

C<Proxy::SMTP> extends L<Proxy::Proxy> to intercept SMTP sessions between a
mail client and a real SMTP relay.  It forwards C<HELO>/C<EHLO>, envelope
commands, and C<DATA> to the configured C<chain_server>, passing each
submitted message through the classifier service to add an
C<X-Text-Classification> header.

Disabled by default (C<enabled = 0>).

=head1 METHODS

=head2 initialize

Registers SMTP-specific configuration parameters: C<port> (default 25),
C<chain_server>, C<chain_port>, C<local>, and C<welcome_string>.  Forces
C<enabled> to 0 after calling C<< Proxy::Proxy->initialize() >>.

=cut

BUILD {
    $self->set_name('smtp');
    $self->set_connection_timeout_error('554 Transaction failed');
    $self->set_connection_failed_error('554 Transaction failed, can\'t connect to');
    $self->set_good_response('^[23]');
}

method initialize() {
    return 0
        unless $self->SUPER::initialize();
    return 1;
}

=head2 start

Skips startup (returns 2) if the C<enabled> config flag is 0.  Otherwise
refreshes the C<welcome_string> if it still contains the old version token,
then calls C<< Proxy::Proxy->start() >> to open the listening socket.

=cut

method start() {
    $self->set_welcome_string("SMTP POPFile (" . $self->version() . ") welcome");

    if (($self->config->get('enabled')) == 0) {
        return 2;
    }

    return $self->SUPER::start();
}

=head2 child($client)

Handles one complete SMTP session for C<$client>.  Connects to the configured
C<chain_server> on the first C<HELO>/C<EHLO>, relays envelope commands
(C<MAIL FROM>, C<RCPT TO>, etc.), and classifies each message body when C<DATA>
is received.  Suppresses unsupported ESMTP extensions (C<CHUNKING>,
C<BINARYMIME>, C<XEXCH50>) from C<EHLO> responses.

=cut

method child($client) {
    my $count = 0;
    my $mail;

    $self->tee($client, "220 " . $self->welcome_string() . "$eol");

    while (<$client>) {
        my $command = $_;
        $command =~ s/(\015|\012)//g;
        $self->log_msg(DEBUG => "Command: --$command--");

        my ($new_mail, $action) = $self->_dispatch($mail, $client, $command, \$count);
        $mail = $new_mail
            if defined $new_mail;
        last
            if $action eq 'last';
        next
            if $action eq 'next';
    }

    $self->done_slurp($mail)
        if defined $mail;
    close $mail
        if defined $mail;
    close $client;
    $self->log_msg(WARN => "SMTP proxy done");
}

my $ENVELOPE_RE = qr/MAIL FROM:|RCPT TO:|VRFY|EXPN|NOOP|HELP|RSET/i;

method _dispatch($mail, $client, $command, $count_ref) {
    return $self->_handle_helo($mail, $client, $command)
        || $self->_handle_ehlo($mail, $client, $command)
        || $self->_handle_envelope($mail, $client, $command)
        || $self->_handle_data($mail, $client, $command, $count_ref)
        || $self->_handle_quit($mail, $client, $command)
        || $self->_handle_unknown($mail, $client, $command);
}

method _handle_helo($mail, $client, $command) {
    return
        unless $command =~ /^HELO/i;
    return (undef, 'next')
        unless $self->config->get('chain_server');
    $mail = $self->verify_connected($mail, $client,
        $self->config->get('chain_server'),
        $self->config->get('chain_port'));
    return (undef, 'last')
        unless $mail;
    $self->smtp_echo_response($mail, $client, $command);
    return ($mail, 'next')
}

method _handle_ehlo($mail, $client, $command) {
    return
        unless $command =~ /^EHLO/i;
    return (undef, 'next')
        unless $self->config->get('chain_server');
    $mail = $self->verify_connected($mail, $client,
        $self->config->get('chain_server'),
        $self->config->get('chain_port'));
    return (undef, 'last')
        unless $mail;
    $self->smtp_echo_response($mail, $client, $command,
        qr/250\-CHUNKING|BINARYMIME|XEXCH50/);
    return ($mail, 'next')
}

method _handle_envelope($mail, $client, $command) {
    return
        unless $command =~ $ENVELOPE_RE;
    $self->smtp_echo_response($mail, $client, $command);
    return (undef, 'next')
}

method _handle_data($mail, $client, $command, $count_ref) {
    return
        unless $command =~ /^DATA/i;
    return (undef, 'next')
        unless $self->smtp_echo_response($mail, $client, $command);
    $$count_ref += 1;
    $self->set_classifier_service()->classify_message(
        $client, $mail, 0, '', 0, undef, $eol);
    my $response = $self->slurp($mail);
    $self->tee($client, $response);
    return (undef, 'next')
}

method _handle_quit($mail, $client, $command) {
    return
        unless $command =~ /^QUIT/i;
    if ($mail) {
        $self->smtp_echo_response($mail, $client, $command);
        close $mail;
    } else {
        $self->tee($client, "221 goodbye$eol");
    }
    return (undef, 'last')
}

method _handle_unknown($mail, $client, $command) {
    if ($mail && $mail->connected) {
        $self->smtp_echo_response($mail, $client, $command);
        return ($mail, 'next')
    }
    $self->tee($client, "500 unknown command or bad syntax$eol");
    return (undef, 'last')
}

=head2 smtp_echo_response($mail, $client, $command, $suppress)

Sends C<$command> to C<$mail> and relays the response to C<$client>.  If the
response is a multi-line C<2xx-> continuation, reads and forwards lines until
the final C<2xx > terminator, optionally filtering lines matching C<$suppress>.
Returns true if the response matched C<$good_response>.

=cut

method smtp_echo_response($mail, $client, $command, $suppress = undef) {
    my ($response, $ok) = $self->get_response($mail, $client, $command);
    if ($response =~ /^\d\d\d-/) {
        $self->echo_to_regexp($mail, $client, qr/^\d\d\d /, 1, $suppress);
    }
    return ($response =~ /$self->good_response()/);
}


1;
