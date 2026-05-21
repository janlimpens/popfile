# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Proxy::NNTP;

use Object::Pad;
use locale;

my $eol = "\015\012";

class Proxy::NNTP :isa(Proxy::Proxy);


=head1 NAME

Proxy::NNTP — NNTP proxy that classifies news articles with POPFile

=head1 DESCRIPTION

C<Proxy::NNTP> extends L<Proxy::Proxy> to intercept NNTP sessions between a
news reader and a real NNTP server.  It parses the extended
C<AUTHINFO USER server[:port]:username> syntax to determine the upstream
server, manages a three-state authentication handshake (username needed →
password needed → connected), and classifies each fetched article via the
classifier service.

Supports C<ARTICLE>, C<HEAD>, C<BODY>, and the full set of NNTP read commands.
Disabled by default (C<enabled = 0>).

=head1 METHODS

=head2 initialize

Registers NNTP-specific configuration parameters: C<port> (default 119),
C<local>, C<headtoo>, C<separator>, and C<welcome_string>.  Forces
C<enabled> to 0 after calling C<< Proxy::Proxy->initialize() >>.

=cut

BUILD {
    $self->set_name('nntp');
    $self->set_connection_timeout_error('500 no response from mail server');
    $self->set_connection_failed_error('500 can\'t connect to');
    $self->set_good_response('^(1|2|3)\d\d');
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
    $self->set_welcome_string("NNTP POPFile (" . $self->version() . ") server ready");
    if (($self->config->get('enabled')) == 0) {
        return 2;
    }
    return $self->SUPER::start();
}

=head2 child($client)

Handles one complete NNTP session for C<$client>.  Implements a three-state
machine (C<username needed> → C<password needed> / C<ignore password> →
C<connected>) driven by C<AUTHINFO USER> and C<AUTHINFO PASS> commands.
Once connected, relays C<ARTICLE>, C<HEAD>, C<BODY>, C<GROUP>, C<LIST>,
C<NEWGROUPS>, C<NEWNEWS>, C<XOVER>, and other standard NNTP commands,
classifying full articles via the classifier service.

=cut

method child($client) {
    my %downloaded;
    my $news;
    my $connection_state = 'username needed';
    my $svc = $self->set_classifier_service();
    my $history = $svc->history_obj();
    $self->tee($client, "201 " . $self->welcome_string() . "$eol");
    while (<$client>) {
        my $command = $_;
        $command =~ s/(\015|\012)//g;
        $self->log_msg(DEBUG => "Command: --$command--");
        last
            if $self->_handle_quit($news, $client, $command);
        next
            if $self->_handle_auth($client, \$news, $command, \$connection_state);
        next
            if $self->_handle_connected($news, $client, $command, \%downloaded, $svc, $history);
        next
            if $self->_handle_empty($news, $client, $command);
        last
            unless $self->_handle_unknown($news, $client, $command);
    }
    $self->done_slurp($news)
        if defined $news;
    close $news
        if defined $news;
    close $client;
    $self->log_msg(WARN => "NNTP proxy done");
}

method _handle_quit($news, $client, $command) {
    return 0
        unless $command =~ /^ *QUIT/i;
    if ($news) {
        $self->echo_response($news, $client, $command);
        close $news;
    } else {
        $self->tee($client, "205 goodbye$eol");
    }
    return 1
}

method _handle_auth($client, $news_ref, $command, $state_ref) {
    return 0
        if $$state_ref eq 'connected';
    if ($$state_ref eq 'username needed') {
        return $self->_auth_user($client, $news_ref, $command, $state_ref);
    }
    if ($$state_ref eq 'password needed' || $$state_ref eq 'ignore password') {
        return $self->_auth_password($$news_ref, $client, $command, $state_ref);
    }
    return 0
}

method _auth_user($client, $news_ref, $command, $state_ref) {
    my $separator = ':';
    my $user_command = "^ *AUTHINFO USER ([^:]+)(:([\\d]{1,5}))?(\\Q$separator\\E(.+))?";
    return 0
        unless $command =~ /$user_command/i;
    my $server = $1;
    my $port = (defined($3) && ($3 > 0) && ($3 < 65536)) ? $3 : undef;
    my $username = $5;
    if ($server eq '') {
        $self->tee($client,
            "482 Authentication rejected server name not specified in AUTHINFO USER command$eol");
        return -1
    }
    $$news_ref = $self->verify_connected($$news_ref, $client, $server, $port || 119);
    return -1
        unless $$news_ref;
    if (defined $username) {
        $self->get_response($$news_ref, $client, 'AUTHINFO USER ' . $username);
        $$state_ref = "password needed";
    } else {
        $self->tee($client, "381 password$eol");
        $$state_ref = "ignore password";
    }
    $self->flush_extra($$news_ref, $client, 0);
    return 1
}

method _auth_password($news, $client, $command, $state_ref) {
    if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
        if ($$state_ref eq 'password needed') {
            my ($response) = $self->get_response($news, $client, $command);
            $$state_ref = "connected"
                if $response =~ /^281 .*/;
        } else {
            $self->tee($client, "281 authentication accepted$eol");
            $$state_ref = "connected";
        }
    } else {
        $self->tee($client, "381 more authentication required for this command$eol");
    }
    return 1
}

method _handle_connected($news, $client, $command, $downloaded, $svc, $history) {
    return 0
        unless $news && $news->connected;
    return $self->_handle_article($news, $client, $command, $downloaded, $svc, $history)
        || $self->_handle_head($news, $client, $command, $downloaded, $svc, $history)
        || $self->_handle_body($news, $client, $command, $downloaded, $svc, $history)
        || $self->_handle_list_commands($news, $client, $command)
        || $self->_handle_help($news, $client, $command)
        || $self->_handle_group_commands($news, $client, $command)
        || $self->_handle_post_commands($news, $client, $command)
}

method _resolve_message_id($command, $news, $client) {
    my $arg = $1;
    return $arg
        if $arg !~ /^\d*$/;
    $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
    my ($response) = $self->get_response($news, $client, $command, 0, 1);
    if ($response =~ /^223 +(\d+) +([^ \015]+)/i) {
        return $2
    }
    $self->tee($client, $response);
    return undef
}

method _serve_from_cache($message_id, $client, $downloaded, $history, $code, $svc) {
    return 0
        unless defined $downloaded->{$message_id};
    my $file = $history->get_slot_file($downloaded->{$message_id}{slot});
    return 0
        unless $file && open my $retrfile, '<', $file;
    binmode $retrfile;
    $self->log_msg(INFO => "Printing message from cache");
    $self->tee($client, "$code 0 $message_id$eol");
    $svc->classify_message($retrfile, $client, 1,
        $downloaded->{$message_id}{class},
        $downloaded->{$message_id}{slot}, undef, $eol);
    print $client ".$eol";
    close $retrfile;
    return 1
}

method _handle_article($news, $client, $command, $downloaded, $svc, $history) {
    return 0
        unless $command =~ /^ *ARTICLE ?(.*)?/i;
    my $message_id = $self->_resolve_message_id($command, $news, $client);
    return 1
        unless defined $message_id;
    return 1
        if $self->_serve_from_cache($message_id, $client, $downloaded, $history, 220, $svc);
    my ($response) = $self->get_response($news, $client, $command);
    if ($response =~ /^220 +(\d+) +([^ \015]+)/i) {
        $message_id = $2;
        my ($class, $history_file) = $svc->classify_message($news, $client, 0, '', 0, undef, $eol);
        $downloaded->{$message_id}{slot} = $history_file;
        $downloaded->{$message_id}{class} = $class;
    }
    return 1
}

method _handle_head($news, $client, $command, $downloaded, $svc, $history) {
    return 0
        unless $command =~ /^ *HEAD ?(.*)?/i;
    my $message_id = $self->_resolve_message_id($command, $news, $client);
    return 1
        unless defined $message_id;
    return 1
        unless $self->config->get('headtoo');
    my ($class, $history_file, $cached);
    if (defined $downloaded->{$message_id}) {
        $cached = 1;
        $class = $downloaded->{$message_id}{class};
        $history_file = $downloaded->{$message_id}{slot};
    } else {
        my $article_command = $command;
        $article_command =~ s/^ *HEAD/ARTICLE/i;
        my ($response) = $self->get_response($news, $client, $article_command, 0, 1);
        return 1
            unless $response =~ /^220 +(\d+) +([^ \015]+)/i;
        $message_id = $2;
        $response =~ s/^220/221/;
        $self->tee($client, "$response");
        ($class, $history_file) = $svc->classify_message($news, undef, 0, '', 0, 0, $eol);
        $downloaded->{$message_id}{slot} = $history_file;
        $downloaded->{$message_id}{class} = $class;
    }
    my ($response) = $self->get_response($news, $client, $command, 0, $cached ? 0 : 1);
    if ($response =~ /^221 +(\d+) +([^ ]+)/i) {
        $svc->classify_message($news, $client, 1, $class, $history_file, 1, $eol);
    }
    return 1
}

method _handle_body($news, $client, $command, $downloaded, $svc, $history) {
    return 0
        unless $command =~ /^ *BODY ?(.*)?/i;
    my $message_id = $self->_resolve_message_id($command, $news, $client);
    return 1
        unless defined $message_id;
    if (defined $downloaded->{$message_id}) {
        my $file = $history->get_slot_file($downloaded->{$message_id}{slot});
        if ($file && open my $retrfile, '<', $file) {
            binmode $retrfile;
            $self->log_msg(INFO => "Printing message from cache");
            $self->tee($client, "222 0 $message_id$eol");
            while (my $line = $self->slurp($retrfile)) {
                last
                    if $line =~ /^[\015\012]+$/;
            }
            $self->echo_to_dot($retrfile, $client);
            print $client ".$eol";
            close $retrfile;
            return 1
        }
    }
    my $article_command = $command;
    $article_command =~ s/^ *BODY/ARTICLE/i;
    my ($response) = $self->get_response($news, $client, $article_command, 0, 1);
    return 1
        unless $response =~ /^220 +(\d+) +([^ \015]+)/i;
    $message_id = $2;
    $response =~ s/^220/222/;
    $self->tee($client, "$response");
    my ($class, $history_file) = $svc->classify_message($news, undef, 0, '', 0, 0, $eol);
    $downloaded->{$message_id}{slot} = $history_file;
    $downloaded->{$message_id}{class} = $class;
    ($response) = $self->get_response($news, $client, $command, 0, 1);
    if ($response =~ /^222 +(\d+) +([^ ]+)/i) {
        $self->echo_to_dot($news, $client, 0);
    }
    return 1
}

my $LIST_COMMANDS_RE = qr/^[ ]*(?:LIST|HEAD|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|XOVER|XPAT|XROVER|XTHREAD)/i;

method _handle_list_commands($news, $client, $command) {
    return 0
        unless $command =~ $LIST_COMMANDS_RE;
    my ($response) = $self->get_response($news, $client, $command);
    $self->echo_to_dot($news, $client, 0)
        if $response =~ /^2\d\d/;
    return 1
}

method _handle_help($news, $client, $command) {
    return 0
        unless $command =~ /^ *HELP/i;
    my ($response) = $self->get_response($news, $client, $command);
    $self->echo_to_dot($news, $client, 0)
        if $response =~ /^1\d\d/;
    return 1
}

my $GROUP_COMMANDS_RE = qr/^ *(?:GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i;

method _handle_group_commands($news, $client, $command) {
    return 0
        unless $command =~ $GROUP_COMMANDS_RE;
    $self->get_response($news, $client, $command);
    return 1
}

my $POST_COMMANDS_RE = qr/^ *(?:IHAVE|POST|XRELPIC)/i;

method _handle_post_commands($news, $client, $command) {
    return 0
        unless $command =~ $POST_COMMANDS_RE;
    my ($response) = $self->get_response($news, $client, $command);
    if ($response =~ /^3\d\d/) {
        $self->echo_to_dot($client, $news, 0);
        $self->get_response($news, $client, "$eol");
    } else {
        $self->tee($client, $response);
    }
    return 1
}

method _handle_empty($news, $client, $command) {
    return 0
        unless $command =~ /^ *$/;
    $self->get_response($news, $client, $command, 1)
        if $news && $news->connected;
    return 1
}

method _handle_unknown($news, $client, $command) {
    if ($news && $news->connected) {
        $self->echo_response($news, $client, $command);
        return 1
    }
    $self->tee($client, "500 unknown command or bad syntax$eol");
    return 0
}

=head2 get_message_id($news, $client, $command)

Converts an C<ARTICLE>/C<HEAD>/C<BODY> command to a C<STAT> command and sends
it to C<$news> to resolve a numeric article number to its Message-ID.
Returns C<($message_id, $response)> on success or C<(undef, $response)> if
the server returns an error.

=cut

method get_message_id($news, $client, $command) {
    $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
    my ($response, $ok) = $self->get_response($news, $client, $command, 0, 1);
    if ($response =~ /^223 +(\d+) +([^ \015]+)/i) {
        return ($2, $response);
    }
    return (undef, $response)
}


1;
