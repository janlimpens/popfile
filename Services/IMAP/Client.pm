# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Role::Config;

use Carp qw(confess);
use IO::Socket::INET;
use IO::Socket::SSL;
use IO::Select;
use Socket ();

class Services::IMAP::Client
    :isa(POPFile::Module)
    :does(POPFile::Role::Config);

use POPFile::Features;
use Encode qw(decode);
use MIME::Base64 qw(decode_base64);

field $test_hostname;
field $test_port;
field $test_use_ssl;
field $test_login;
field $test_password;
field $socket = undef;
field $folder = undef;
field $tag = 0;
field $last_response = '';
field $last_command = '';
field %uid_next_cache;
field %uid_validity_cache;

method set_test_credentials(%args) {
    $test_hostname = $args{hostname};
    $test_port = $args{port};
    $test_use_ssl = $args{use_ssl};
    $test_login = $args{login};
    $test_password = $args{password};
    return
}



=head1 NAME

Services::IMAP::Client — low-level IMAP client used by Services::IMAP

=head1 DESCRIPTION

C<Services::IMAP::Client> implements just enough of the IMAP4rev1 protocol
for POPFile's classification loop: connect, authenticate, select folders,
fetch messages, move messages, and disconnect.

Each IMAP command is tagged with a monotonically increasing sequence number
(C<A00001>, C<A00002>, …).  Responses are read line by line until the tagged
completion line is seen.  Literal octets (C<{N}> syntax) are handled
transparently.  All IMAP errors are treated as fatal and routed through
C<bail_out()>, which shuts down the socket and dies with a
C<POPFILE-IMAP-EXCEPTION> string that C<Services::IMAP::service()> catches.

=head1 METHODS

=cut

my $eol = "\015\012";

method _imap_utf7_decode_chunk ($chunk) {
    return '&'
        if $chunk eq '';
    (my $b = $chunk) =~ tr|+|/|;
    return decode('UTF-16BE', decode_base64($b))
}

method _decode_folder ($encoded) {
    $encoded =~ s/&([^-]*)-/$self->_imap_utf7_decode_chunk($1)/ge;
    return $encoded
}

method _encode_folder ($utf8) {
    require Services::IMAP::Folder;
    return Services::IMAP::Folder->new(name => $utf8)->to_imap_name()
}

=head2 connect()

Opens a TCP (or SSL) connection to C<hostname:port> from config.  Reads and
discards the server greeting.  Sets the internal socket and returns 1 on
success, C<undef> on failure.

=cut

method connect() {
    my $hostname = $test_hostname // $self->config->get('hostname');
    my $port = $test_port // $self->config->get('port');
    my $use_ssl = $test_use_ssl // $self->config->get('use_ssl');
    my $timeout = $self->_global_timeout();
    $self->log_msg(INFO => "Connecting to $hostname:$port");
    unless ($hostname ne '' && $port ne '') {
        $self->log_msg(WARN => "Invalid port or hostname. Will not connect to server.");
        return false
    }
    my $imap;
    if ($use_ssl) {
        require IO::Socket::SSL;
        $imap = IO::Socket::SSL->new(
            Proto => 'tcp',
            PeerAddr => $hostname,
            PeerPort => $port,
            Timeout => $timeout,
            Domain => Socket::AF_INET(),
        ) or $self->log_msg(WARN => "IO::Socket::SSL error: $@");
    }
    else {
        $imap = IO::Socket::INET->new(
            Proto => 'tcp',
            PeerAddr => $hostname,
            PeerPort => $port,
            Timeout => $timeout,
        ) or $self->log_msg(WARN => "IO::Socket::INET error: $@");
    }
    return unless $imap && $imap->connected();
    binmode $imap unless $use_ssl;
    my $selector = IO::Select->new($imap);
    unless (() = $selector->can_read($timeout)) {
        $self->log_msg(WARN => "Connection timed out for $hostname:$port");
        return false
    }
    $self->log_msg(INFO => "Connected to $hostname:$port timeout $timeout");
    my $buf = $self->slurp($imap);
    return unless defined $buf;
    $self->log_msg(TRACE => ">> $buf");
    $socket = $imap;
    return true
}

=head2 login()

Sends C<LOGIN> with the configured credentials.  Returns 1 on success,
C<undef> on failure.  Credentials are masked in the log.

=cut

method login() {
    my $login = $test_login // $self->config->get('login');
    my $pass = $test_password // $self->config->get('password');
    $self->log_msg(INFO => "Logging in");
    $self->say('LOGIN "' . $login . '" "' . $pass . '"');
    return $self->get_response() == 1 ? 1 : undef
}

=head2 logout()

Sends C<LOGOUT>, shuts down the socket, and clears the internal state.
Returns 1 on success, 0 on failure.

=cut

method logout() {
    $self->log_msg(INFO => "Logging out");
    $self->say('LOGOUT');
    if ($self->get_response() == 1) {
        $socket->shutdown(2);
        $folder = undef;
        $socket = undef;
        return true
    }
    return false
}

=head2 noop()

Sends C<NOOP> to keep the connection alive and flush unsolicited responses.
Returns the response code.

=cut

method noop() {
    $self->say('NOOP');
    my $result = $self->get_response();
    $self->log_msg(WARN => "NOOP failed (return value $result)") unless $result == 1;
    return $result
}

=head2 status($folder_name)

Sends C<STATUS> for C<$folder_name> requesting C<UIDNEXT> and
C<UIDVALIDITY>.  Returns a hashref with those two keys (values may be
C<undef> if the server did not supply them).

=cut

method status ($folder_name) {
    my $ret = { UIDNEXT => undef, UIDVALIDITY => undef };
    $self->say("STATUS \"" . $self->_encode_folder($folder_name) . "\" (UIDNEXT UIDVALIDITY)");
    if ($self->get_response() == 1) {
        my @lines = split /$eol/, $last_response;
        for (@lines) {
            if (/^\* STATUS/) {
                $ret->{UIDNEXT} = $1 if /UIDNEXT (\d+)/;
                $ret->{UIDVALIDITY} = $1 if /UIDVALIDITY (\d+)/;
            }
            last;
        }
    }
    for my $k (keys %$ret) {
        $self->log_msg(WARN => "Could not get $k STATUS for folder $folder_name.")
            unless defined $ret->{$k};
    }
    return $ret
}

=head2 select($folder_name)

Sends C<SELECT> to make C<$folder_name> the current mailbox.  Stores the
folder name on success.  Returns the IMAP response code.

=cut

method select ($folder_name) {
    $self->say("SELECT \"" . $self->_encode_folder($folder_name) . "\"");
    my $result = $self->get_response();
    $folder = $folder_name if $result == 1;
    return $result
}

=head2 create_folder($folder_name)

Sends C<CREATE> for C<$folder_name>.  Returns the IMAP response code.

=cut

method create_folder ($folder_name) {
    $self->say("CREATE \"" . $self->_encode_folder($folder_name) . "\"");
    return $self->get_response()
}

=head2 expunge()

Sends C<EXPUNGE> to permanently remove messages flagged C<\Deleted>.

=cut

method expunge() {
    $self->say('EXPUNGE');
    $self->get_response();
}

=head2 say($command)

Sends a tagged IMAP command to the server.  Masks C<LOGIN> credentials in the
log.  Calls C<bail_out()> if the write fails.  Returns 1.

=cut

method say ($command) {
    $last_command = $command;
    $last_command =~ s/(LOGIN ").+?" ".+?(")/$1xxxxx" "xxxxx$2/;
    my $cmdstr = sprintf "A%05d %s%s", $tag, $command, $eol;
    (my $logged = $cmdstr) =~ s/^(A\d+) LOGIN ".+?" ".+"(.+)/$1 LOGIN "xxxxx" "xxxxx"$2/;
    unless (print { $socket } $cmdstr) {
        $self->bail_out("Lost connection while I tried to say '$logged'.");
    }
    $self->log_msg(DEBUG => "<< $logged");
    return true
}

=head2 get_response()

Reads the server response to the last C<say()> call.  Handles multi-line
responses and literal octets (C<{N}> continuation).  Sets an alarm for the
global timeout.  Returns 1 (OK), 0 (NO), -1 (BAD), or -2 (unexpected).
Calls C<bail_out()> if the connection is lost.

=cut

method get_response() {
    local $SIG{ALRM} = sub {
        alarm 0;
        $self->bail_out("The connection to the IMAP server timed out while we waited for a response.");
    };
    alarm $self->_global_timeout();
    my $actual_tag = sprintf "A%05d", $tag;
    my $response = '';
    my $count_octets = 0;
    my $octet_count = 0;
    while (my $buf = $self->slurp($socket)) {
        if ($response eq '' && !defined $buf) {
            $self->bail_out("The connection to the IMAP server was lost while trying to get a response to command '$last_command'.");
        }
        if ($response eq '' && $buf =~ m/\{(\d+)\}$eol/) {
            $count_octets = $1 + length($buf);
        }
        $response .= $buf;
        if ($count_octets) {
            $octet_count += length $buf;
            $count_octets = 0 if $octet_count >= $count_octets;
            $self->log_msg(TRACE => ">> $buf");
        }
        if ($count_octets == 0) {
            if ($buf =~ /^$actual_tag (OK|BAD|NO)/) {
                $self->log_msg($1 ne 'OK' ? 'WARN' : 'TRACE', ">> $buf");
                last;
            }
            if ($buf =~ /^\* (.+)/) {
                my $untagged = $1;
                $self->log_msg(TRACE => ">> $buf");
                if ($untagged =~ /UIDVALIDITY/
                     && $last_command !~ /^SELECT/
                     && $last_command !~ /^STATUS/) {
                    $self->log_msg(WARN => "Got unsolicited UIDVALIDITY response from server while reading response for $last_command.");
                }
                if ($untagged =~ /^BYE/ && $last_command !~ /^LOGOUT/) {
                    $self->log_msg(WARN => "Got unsolicited BYE response from server while reading response for $last_command.");
                }
            }
        }
    }
    $last_response = $response;
    alarm 0;
    $tag++;
    return $self->bail_out("The connection to the IMAP server was lost while trying to get a response to command '$last_command'")
        unless $response;
    return 1  if $response =~ /^$actual_tag OK/m;
    return 0  if $response =~ /^$actual_tag NO/m;
    return -1 if $response =~ /^$actual_tag BAD/m;
    $self->log_msg(WARN => "!!! Server said something unexpected !!!");
    return -2
}

=head2 move_message($msg, $destination)

Copies UID C<$msg> to C<$destination> with C<UID COPY>, then flags the
original C<\Deleted>.  Returns 1 on success, 0 on failure.

=cut

method move_message ($msg, $destination) {
    $self->log_msg(INFO => "Moving message $msg to $destination");
    $self->say("UID COPY $msg \"" . $self->_encode_folder($destination) . "\"");
    my $ok = $self->get_response();
    if ($ok == 1) {
        $self->say("UID STORE $msg +FLAGS (\\Deleted)");
        $ok = $self->get_response();
    }
    else {
        $self->log_msg(WARN => "Could not copy message ($ok)!");
    }
    return $ok ? true : false
}

=head2 get_mailbox_list()

Sends C<LIST "" "*"> and returns a sorted list of all mailbox names on the
server, with modified UTF-7 (RFC 3501) folder names decoded to UTF-8.
Returns an empty list on failure.

=cut

method get_mailbox_list() {
    $self->log_msg(DEBUG => "Getting mailbox list");
    $self->say('LIST "" "*"');
    my $result = $self->get_response();
    unless ($result == 1) {
        $self->log_msg(WARN => "LIST command failed (return value [$result]).");
        return
    }
    my @lines = split /$eol/, $last_response;
    my @mailboxes;
    for my $name ( grep { /^\*/ } @lines) {
        $name =~ s/^\* LIST \(.*\) .+? (.+)$/$1/;
        $name =~ s/"(.*?)"/$1/;
        $name = $self->_decode_folder($name);
        push @mailboxes, $name;
    }
    return sort @mailboxes
}

=head2 get_new_message_list()

Searches the currently selected folder for UIDs ≥ the stored C<UIDNEXT>
using C<UID SEARCH … UNDELETED>.  Returns UIDs in ascending order.
Requires that C<select()> has been called first.

=cut

method get_new_message_list() {
    my $uid = $self->uid_next($folder);
    $self->log_msg(DEBUG => "Getting uids ge $uid in folder $folder");
    $self->say("UID SEARCH UID $uid:* UNDELETED");
    my $result = $self->get_response();
    unless ($result == 1) {
        $self->log_msg(WARN => "SEARCH command failed (return value: $result, used UID was [$uid])!");
    }
    my @matching;
    @matching = split / /, $1 if $last_response =~ /\* SEARCH (.+)$eol/;
    return sort { $a <=> $b } grep { $_ >= $uid } @matching
}

=head2 get_new_message_list_unselected($folder_name)

Checks C<$folder_name> via C<STATUS> without selecting it.  If the stored
C<UIDVALIDITY> has changed, logs the anomaly and returns nothing.  If new
UIDs are available, selects the folder and delegates to
C<get_new_message_list()>.  Returns a list of new UIDs or an empty list.

=cut

method get_new_message_list_unselected ($folder_name) {
    my $last_known = $self->uid_next($folder_name);
    my $info = $self->status($folder_name);
    $self->bail_out("Could not get a valid response to the STATUS command.")
        unless defined $info;
    my $new_next = $info->{UIDNEXT};
    my $new_vali = $info->{UIDVALIDITY};
    if ($new_vali != $self->uid_validity($folder_name)) {
        $self->log_msg(WARN => "The folder $folder_name has a new UIDVALIDTIY value! Skipping new messages (if any).");
        $self->uid_validity($folder_name, $new_vali);
        return
    }
    if ($last_known < $new_next) {
        $self->select($folder_name);
        return $self->get_new_message_list()
    }
    return
}

=head2 search_header_in_folder($folder_name, $field, $value)

Selects C<$folder_name> and searches for messages whose header field C<$field>
matches C<$value> using C<UID SEARCH HEADER>.  Returns a list of matching UIDs
(possibly empty) or an empty list on IMAP failure.

=cut

method search_header_in_folder ($folder_name, $field, $value) {
    $self->select($folder_name);
    (my $quoted = $value) =~ s/([\\"])/\\$1/g;
    $self->say("UID SEARCH HEADER $field \"$quoted\"");
    my $result = $self->get_response();
    unless ($result == 1) {
        $self->log_msg(WARN => "SEARCH HEADER $field failed in $folder_name (result: $result)");
        return
    }
    my @matching;
    @matching = split / /, $1 if $last_response =~ /\* SEARCH (.+)$eol/;
    return map { $_ + 0 } @matching
}

=head2 fetch_message_part($msg, $part)

Fetches C<$part> (e.g. C<'HEADER'>, C<'TEXT'>,
C<'HEADER.FIELDS (…)'>, or C<''> for the whole message) of UID C<$msg>
using C<UID FETCH … BODY.PEEK[…]>.  Body size is capped by
C<message_cutoff> from the global config.  Returns C<(1, @lines)> on success or
C<(0)> on failure.

=cut

method fetch_message_part ($msg, $part) {
    if ($part ne '') {
        $self->log_msg(DEBUG => "Fetching $part of message $msg");
    }
    else {
        $self->log_msg(DEBUG => "Fetching message $msg");
    }
    if ($part eq 'TEXT' || $part eq '') {
        my $limit = $self->config('GLOBAL')->get('message_cutoff') || 0;
        $self->say("UID FETCH $msg (FLAGS BODY.PEEK[$part]<0.$limit>)");
    }
    else {
        $self->say("UID FETCH $msg (FLAGS BODY.PEEK[$part])");
    }
    my $result = $self->get_response();
    $self->log_msg(DEBUG => "Got " . ($part ne '' ? $part : 'message') . " # $msg, result: $result.");
    unless ($result == 1) {
        return 0
    }
    my @lines;
    if ($last_response =~ m/\* \d+ FETCH/) {
        if ($last_response =~ m/(?!$eol)\{(\d+)\}$eol/) {
            my $num_octets = $1;
            my $pos = index $last_response, "{$num_octets}$eol";
            $pos += length "{$num_octets}$eol";
            my $message = substr $last_response, $pos, $num_octets;
            while ($message =~ m/(.*?(?:$eol|\012|\015))/g) {
                push @lines, $1;
            }
        }
        else {
            while ($last_response =~ m/(.*?(?:$eol|\012|\015))/g) {
                push @lines, $1;
            }
            shift @lines;
            pop @lines;
            pop @lines;
            $self->log_msg(WARN => "Could not find octet count in server's response!");
        }
    }
    else {
        $self->log_msg(WARN => "Unexpected server response to the FETCH command!");
    }
    return 1, @lines
}

=head2 load_uid_state(%nexts, %validities)

Pre-loads in-memory UID state from the caller (typically after reading from
the database).  Both arguments are plain hashes keyed by folder name.

=cut

method load_uid_state (%args) {
    %uid_next_cache = $args{nexts}->%*
        if ref $args{nexts} eq 'HASH';
    %uid_validity_cache = $args{validities}->%*
        if ref $args{validities} eq 'HASH';
}

=head2 uid_nexts() / uid_validities()

Return references to the in-memory uid_next / uid_validity hashes so that
the caller can persist the current state to the database.

=cut

method uid_nexts ()     { \%uid_next_cache }
method uid_validities () { \%uid_validity_cache }

=head2 uid_validity($folder_name, $uidval)

Get/set the in-memory C<UIDVALIDITY> for C<$folder_name>.  With one argument,
returns the stored value or C<undef>.  With two arguments, stores the new
value and returns nothing.

=cut

method uid_validity ($folder_name, $uidval = undef) {
    Carp::confess("gimme a folder!") unless $folder_name;
    if (defined $uidval) {
        $uid_validity_cache{$folder_name} = $uidval;
        $self->log_msg(DEBUG => "Updated UIDVALIDITY value for folder $folder_name to $uidval.");
        return
    }
    return
        unless exists $uid_validity_cache{$folder_name};
    return $uid_validity_cache{$folder_name} =~ /^\d+$/
        ? $uid_validity_cache{$folder_name}
        : undef
}

=head2 uid_next($folder_name, $uidnext)

Get/set the in-memory C<UIDNEXT> for C<$folder_name>.  With one argument,
returns the stored value or C<undef>.  With two arguments, stores the new
value and returns nothing.

=cut

method uid_next ($folder_name, $uidnext = undef) {
    Carp::confess("I need a folder") unless $folder_name;
    if (defined $uidnext) {
        $uid_next_cache{$folder_name} = $uidnext;
        $self->log_msg(DEBUG => "Updated UIDNEXT value for folder $folder_name to $uidnext.");
        return
    }
    return exists $uid_next_cache{$folder_name} && $uid_next_cache{$folder_name} =~ /^\d+$/
        ? $uid_next_cache{$folder_name}
        : undef
}

=head2 check_uid_validity($folder_name, $new_val)

Returns 1 if C<$new_val> matches the stored C<UIDVALIDITY> for
C<$folder_name>, C<undef> otherwise.  Dies if either argument is missing.

=cut

method check_uid_validity ($folder_name, $new_val) {
    Carp::confess("check_uid_validity needs a new uidvalidity!") unless defined $new_val;
    Carp::confess("check_uid_validity needs a folder name!")     unless defined $folder_name;
    my $old_val = $self->uid_validity($folder_name);
    return $new_val == $old_val ? true : false
}

=head2 connected()

Returns 1 if the socket is open, C<undef> otherwise.

=cut

method connected() {
    return $socket ? true : false
}

=head2 bail_out($msg)

Shuts down the socket, logs C<$msg>, and dies with a
C<POPFILE-IMAP-EXCEPTION> string that C<Services::IMAP::service()> catches.

=cut

method bail_out ($msg) {
    $socket->shutdown(2) if defined $socket;
    $socket = undef;
    my (undef, $filename, $line) = caller;
    $self->log_msg(WARN => $msg);
    die "POPFILE-IMAP-EXCEPTION: $msg ($filename ($line))"
}

1;
