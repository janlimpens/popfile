# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Proxy::POP3;

use Object::Pad;
use locale;

use Digest::MD5;

my $eol = "\015\012";

class Proxy::POP3 :isa(Proxy::Proxy);


=head1 NAME

Proxy::POP3 — POP3 proxy that classifies messages with POPFile

=head1 DESCRIPTION

C<Proxy::POP3> extends L<Proxy::Proxy> to intercept POP3 sessions between a
mail client and a real POP3 server.  It parses the extended
C<USER host:port:username> syntax to determine the upstream server, relays
authentication, and calls the classifier service to tag each retrieved message
with an C<X-Text-Classification> header before forwarding it to the client.

Supports plain username/password authentication, APOP, and SSL connections
(when L<IO::Socket::SSL> is available) as well as optional SOCKS proxying
inherited from the base class.

=head1 METHODS

=head2 initialize

Registers POP3-specific configuration parameters: C<port> (default 1110),
C<secure_server>, C<secure_port>, C<local>, C<toptoo>, C<separator>, and
C<welcome_string>.  Delegates to C<< Proxy::Proxy->initialize() >>.

=cut

field $use_apop = 0;
field $apop_user = '';
field $apop_banner = undef;

BUILD {
    $self->set_name('pop3');
    $self->set_connection_timeout_error('-ERR no response from mail server');
    $self->set_connection_failed_error('-ERR can\'t connect to');
    $self->set_good_response('^\+OK');
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
    $self->set_welcome_string("POP3 POPFile (" . $self->version() . ") server ready");

    if (($self->config->get('enabled')) == 0) {
        return 2;
    }

    return $self->SUPER::start();
}

=head2 child($client)

Handles one complete POP3 session for C<$client>.  Parses the extended
C<USER host[:port]:username[:ssl|apop]> syntax, connects to the upstream
server, relays authentication, classifies each retrieved message via the
classifier service, and supports C<RETR>, C<TOP>, C<LIST>, C<UIDL>,
C<STAT>, C<DELE>, C<NOOP>, C<CAPA>, C<RSET>, C<AUTH>, and C<QUIT>.

=cut

method child($client) {
    my %downloaded;
    my $mail;

    $apop_banner = undef;
    $use_apop = 0;
    $apop_user = '';

    $self->tee($client, "+OK " . $self->welcome_string() . "$eol");

    my $s = ':';
    $s =~ s/(\$|\@|\[|\]|\(|\)|\||\?|\*|\.|\^|\+)/\\$1/;

    my $transparent = "^USER ([^$s]+)\$";
    my $user_command = "USER ([^$s]+)($s(\\d{1,5}))?$s([^$s]+)($s([^$s]+))?";

    while (<$client>) {
        my $command = $_;
        $command =~ s/(\015|\012)//g;
        $self->log_msg(DEBUG => "Command: --$command--");

        my ($new_mail, $action) = $self->_dispatch($mail, $client, $command, \%downloaded, $transparent, $user_command);
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
    $self->log_msg(WARN => "POP3 proxy done");
}

# ─── Command dispatch ─────────────────────────────────────────────────

method _dispatch($mail, $client, $command, $downloaded, $transparent_re, $user_re) {
    return $self->_handle_user_transparent($mail, $client, $command, $transparent_re)
        || $self->_handle_user($mail, $client, $command, $user_re)
        || $self->_handle_pass($mail, $client, $command)
        || $self->_handle_apop_client($client, $command)
        || $self->_handle_auth_mech($mail, $client, $command)
        || $self->_handle_auth($mail, $client, $command)
        || $self->_handle_list_uidl($mail, $client, $command)
        || $self->_handle_top($mail, $client, $command, $downloaded)
        || $self->_handle_retr($mail, $client, $command, $downloaded)
        || $self->_handle_capa($mail, $client, $command)
        || $self->_handle_helo($client, $command)
        || $self->_handle_simple($mail, $client, $command)
        || $self->_handle_quit($mail, $client, $command)
        || $self->_handle_unknown($mail, $client, $command);
}

# ─── Command handlers ─────────────────────────────────────────────────

method _handle_user_transparent($mail, $client, $command, $transparent_re) {
    return
        unless $command =~ $transparent_re;
    return ($mail, 'next')
        if $self->config->get('secure_server') eq '';
    $self->tee($client,
        "-ERR Transparent proxying not configured: set secure server/port ( command you sent: '$command' )$eol");
    return ($mail, 'next')
}

method _handle_user($mail, $client, $command, $user_re) {
    return
        unless $command =~ $user_re;
    return ($mail, 'next')
        if $1 eq '';
    my ($host, $port, $user, $options) = ($1, $3, $4, $6);
    $self->mq_post('LOGIN', $user);
    my $ssl = defined($options) && ($options =~ /ssl/i);
    $port //= $ssl ? 995 : 110;
    $mail = $self->verify_connected($mail, $client, $host, $port, $ssl);
    return ($mail, 'next')
        unless $mail;
    if (defined($options) && ($options =~ /apop/i)) {
        return $self->_init_apop($mail, $client, $host, $user);
    }
    $use_apop = 0;
    if ($self->echo_response($mail, $client, 'USER ' . $user) == 2) {
        return ($mail, 'last');
    }
    return ($mail, 'next')
}

method _init_apop($mail, $client, $host, $user) {
    $apop_banner = $1
        if $self->connect_banner() =~ /(<[^>]+>)/;
    $self->log_msg(DEBUG => "banner=" . $apop_banner)
        if defined $apop_banner;
    unless (defined $apop_banner) {
        $use_apop = 0;
        $self->tee($client,
            "-ERR $host doesn't support APOP, aborting authentication$eol");
        return ($mail, 'next');
    }
    $use_apop = 1;
    $apop_user = $user;
    $self->tee($client, "+OK hello $user$eol");
    return ($mail, 'next')
}

method _handle_pass($mail, $client, $command) {
    return
        unless $command =~ /PASS (.*)/i;
    if ($use_apop) {
        my $md5 = Digest::MD5->new;
        $md5->add($apop_banner, $1);
        my $md5hex = $md5->hexdigest;
        $self->log_msg(DEBUG => "digest='$md5hex'");
        my ($response, $ok) = $self->get_response($mail, $client,
            "APOP $apop_user $md5hex", 0, 1);
        if ($ok && $response =~ /$self->good_response()/) {
            $self->tee($client, "+OK password ok$eol");
        } else {
            $self->tee($client, $response);
        }
    } else {
        return ($mail, 'last')
            if $self->echo_response($mail, $client, $command) == 2;
    }
    return ($mail, 'next')
}

method _handle_apop_client($client, $command) {
    return
        unless $command =~ /APOP ([^:]+)(:(\\d{1,5}))?:([^:]+) .*?/io;
    $self->tee($client,
        "-ERR APOP not supported between mail client and POPFile.$eol");
    return (undef, 'next')
}

method _handle_auth_mech($mail, $client, $command) {
    return
        unless $command =~ /AUTH ([^ ]+)/i;
    return (undef, 'next')
        if $self->config->get('secure_server') eq '';
    $mail = $self->verify_connected($mail, $client,
        $self->config->get('secure_server'),
        $self->config->get('secure_port'));
    return ($mail, 'next')
        unless $mail;
    my ($response, $ok) = $self->get_response($mail, $client, $command);
    while (!($response =~ /\+OK/) && !($response =~ /-ERR/)) {
        my $auth = <$client>;
        $auth =~ s/(\015|\012)$//g;
        ($response, $ok) = $self->get_response($mail, $client, $auth);
    }
    return ($mail, 'next')
}

method _handle_auth($mail, $client, $command) {
    return
        unless $command =~ /AUTH/i;
    return (undef, 'next')
        if $self->config->get('secure_server') eq '';
    $mail = $self->verify_connected($mail, $client,
        $self->config->get('secure_server'),
        $self->config->get('secure_port'));
    return ($mail, 'next')
        unless $mail;
    my $response = $self->echo_response($mail, $client, "AUTH");
    return ($mail, 'last')
        if $response == 2;
    $self->echo_to_dot($mail, $client)
        if $response == 0;
    return ($mail, 'next')
}

method _handle_list_uidl($mail, $client, $command) {
    return
        unless $command =~ /LIST ?(.*)?/i || $command =~ /UIDL ?(.*)?/i;
    my $response = $self->echo_response($mail, $client, $command);
    return ($mail, 'last')
        if $response == 2;
    $self->echo_to_dot($mail, $client)
        if $response == 0 && $1 eq '';
    return ($mail, 'next')
}

method _handle_top($mail, $client, $command, $downloaded) {
    return
        unless $command =~ /TOP (.*) (.*)/i;
    my $count = $1;
    return
        if $2 eq '99999999';
    unless (($self->config->get('toptoo')) == 1) {
        my $response = $self->echo_response($mail, $client, $command);
        return ($mail, 'last')
            if $response == 2;
        $self->echo_to_dot($mail, $client)
            if $response == 0;
        return ($mail, 'next')
    }
    my $response = $self->echo_response($mail, $client, "RETR $count");
    return ($mail, 'last')
        if $response == 2;
    return ($mail, 'next')
        unless $response == 0;
    my $svc = $self->set_classifier_service();
    my ($class, $slot) = $svc->classify_message($mail, $client, 0, '', 0, 0, $eol);
    $downloaded->{$count}{slot} = $slot;
    $downloaded->{$count}{class} = $class;
    $response = $self->echo_response($mail, $client, $command, 1);
    return ($mail, 'last')
        if $response == 2;
    $svc->classify_message($mail, $client, 1, $class, $slot, 1, $eol)
        if $response == 0;
    return ($mail, 'next')
}

method _handle_retr($mail, $client, $command, $downloaded) {
    return
        unless $command =~ /RETR (.*)/i || $command =~ /TOP (.*) 99999999/i;
    my $count = $1;
    my $svc = $self->set_classifier_service();
    my $history = $svc->history_obj();
    if (defined $downloaded->{$count}) {
        my $file = $history->get_slot_file($downloaded->{$count}{slot});
        if ($file && open my $retrfile, '<', $file) {
            binmode $retrfile;
            $self->log_msg(INFO => "Printing message from cache");
            $self->tee($client,
                "+OK " . (-s $file) . " bytes from POPFile cache$eol");
            $svc->classify_message($retrfile, $client, 1,
                $downloaded->{$count}{class},
                $downloaded->{$count}{slot}, undef, $eol);
            print $client ".$eol";
            close $retrfile;
            return ($mail, 'next')
        }
    }
    my $response = $self->echo_response($mail, $client, $command);
    return ($mail, 'last')
        if $response == 2;
    if ($response == 0) {
        my ($class, $slot) = $svc->classify_message($mail, $client, 0, '', 0, undef, $eol);
        $downloaded->{$count}{slot} = $slot;
        $downloaded->{$count}{class} = $class;
    }
    return ($mail, 'next')
}

method _handle_capa($mail, $client, $command) {
    return
        unless $command =~ /CAPA/i;
    return (undef, 'next')
        if !$mail && $self->config->get('secure_server') eq '';
    $mail //= $self->verify_connected($mail, $client,
        $self->config->get('secure_server'),
        $self->config->get('secure_port'));
    return ($mail, 'next')
        unless $mail;
    my $response = $self->echo_response($mail, $client, "CAPA");
    return ($mail, 'last')
        if $response == 2;
    $self->echo_to_dot($mail, $client)
        if $response == 0;
    return ($mail, 'next')
}

method _handle_helo($client, $command) {
    return
        unless $command =~ /HELO/i;
    $self->tee($client, "+OK HELO POPFile Server Ready$eol");
    return (undef, 'next')
}

method _handle_simple($mail, $client, $command) {
    return
        unless $command =~ /NOOP/i
        || $command =~ /STAT/i
        || $command =~ /XSENDER (.*)/i
        || $command =~ /DELE (.*)/i
        || $command =~ /RSET/i;
    return ($mail, 'last')
        if $self->echo_response($mail, $client, $command) == 2;
    return ($mail, 'next')
}

method _handle_quit($mail, $client, $command) {
    return
        unless $command =~ /QUIT/i;
    if ($mail) {
        $self->echo_response($mail, $client, $command);
        close $mail;
    } else {
        $self->tee($client, "+OK goodbye$eol");
    }
    return (undef, 'last')
}

method _handle_unknown($mail, $client, $command) {
    if ($mail && $mail->connected) {
        return ($mail, 'last')
            if $self->echo_response($mail, $client, $command) == 2;
        return ($mail, 'next')
    }
    $self->tee($client, "-ERR unknown command or bad syntax$eol");
    return ($mail, 'next')
}


1;
