use Object::Pad;
use Carp qw(confess);
use IO::Socket::INET;
use IO::Socket::SSL;
use IO::Select;
use Socket ();

class Services::IMAP::Client :isa(POPFile::Module) {

    field $socket        = undef;
    field $folder        = undef;
    field $tag           = 0;
    field $last_response = '';
    field $last_command  = '';

    my $eol           = "\015\012";
    my $cfg_separator = "-->";

    method connect {
        my $hostname = $self->config_('hostname');
        my $port     = $self->config_('port');
        my $use_ssl  = $self->config_('use_ssl');
        my $timeout  = $self->global_config_('timeout');
        $self->log_( 1, "Connecting to $hostname:$port" );
        unless ( $hostname ne '' && $port ne '' ) {
            $self->log_( 0, "Invalid port or hostname. Will not connect to server." );
            return
        }
        my $imap;
        if ( $use_ssl ) {
            require IO::Socket::SSL;
            $imap = IO::Socket::SSL->new(
                Proto    => 'tcp',
                PeerAddr => $hostname,
                PeerPort => $port,
                Timeout  => $timeout,
                Domain   => Socket::AF_INET(),
            ) or $self->log_( 0, "IO::Socket::SSL error: $@" );
        }
        else {
            $imap = IO::Socket::INET->new(
                Proto    => 'tcp',
                PeerAddr => $hostname,
                PeerPort => $port,
                Timeout  => $timeout,
            ) or $self->log_( 0, "IO::Socket::INET error: $@" );
        }
        return unless $imap && $imap->connected();
        binmode $imap unless $use_ssl;
        my $selector = IO::Select->new($imap);
        unless ( () = $selector->can_read($timeout) ) {
            $self->log_( 0, "Connection timed out for $hostname:$port" );
            return
        }
        $self->log_( 0, "Connected to $hostname:$port timeout $timeout" );
        my $buf = $self->slurp_($imap);
        $self->log_( 1, ">> $buf" );
        $socket = $imap;
        return 1
    }

    method login {
        my $login = $self->config_('login');
        my $pass  = $self->config_('password');
        $self->log_( 1, "Logging in" );
        $self->say( 'LOGIN "' . $login . '" "' . $pass . '"' );
        return $self->get_response() == 1 ? 1 : undef
    }

    method logout {
        $self->log_( 1, "Logging out" );
        $self->say('LOGOUT');
        if ( $self->get_response() == 1 ) {
            $socket->shutdown(2);
            $folder = undef;
            $socket = undef;
            return 1
        }
        return 0
    }

    method noop {
        $self->say('NOOP');
        my $result = $self->get_response();
        $self->log_( 0, "NOOP failed (return value $result)" ) unless $result == 1;
        return $result
    }

    method status ($folder_name) {
        my $ret = { UIDNEXT => undef, UIDVALIDITY => undef };
        $self->say( "STATUS \"$folder_name\" (UIDNEXT UIDVALIDITY)" );
        if ( $self->get_response() == 1 ) {
            my @lines = split /$eol/, $last_response;
            for (@lines) {
                if (/^\* STATUS/) {
                    $ret->{UIDNEXT}     = $1 if /UIDNEXT (\d+)/;
                    $ret->{UIDVALIDITY} = $1 if /UIDVALIDITY (\d+)/;
                }
                last;
            }
        }
        for my $k ( keys %$ret ) {
            $self->log_( 0, "Could not get $k STATUS for folder $folder_name." )
                unless defined $ret->{$k};
        }
        return $ret
    }

    method select ($folder_name) {
        $self->say( "SELECT \"$folder_name\"" );
        my $result = $self->get_response();
        $folder = $folder_name if $result == 1;
        return $result
    }

    method expunge {
        $self->say('EXPUNGE');
        $self->get_response();
    }

    method say ($command) {
        $last_command = $command;
        my $cmdstr = sprintf "A%05d %s%s", $tag, $command, $eol;
        unless ( print { $socket } $cmdstr ) {
            $self->bail_out( "Lost connection while I tried to say '$cmdstr'." );
        }
        (my $logged = $cmdstr) =~ s/^(A\d+) LOGIN ".+?" ".+"(.+)/$1 LOGIN "xxxxx" "xxxxx"$2/;
        $self->log_( 1, "<< $logged" );
        return 1
    }

    method get_response {
        local $SIG{ALRM} = sub {
            alarm 0;
            $self->bail_out( "The connection to the IMAP server timed out while we waited for a response." );
        };
        alarm $self->global_config_('timeout');
        my $actual_tag   = sprintf "A%05d", $tag;
        my $response     = '';
        my $count_octets = 0;
        my $octet_count  = 0;
        while ( my $buf = $self->slurp_($socket) ) {
            if ( $response eq '' && !defined $buf ) {
                $self->bail_out( "The connection to the IMAP server was lost while trying to get a response to command '$last_command'." );
            }
            if ( $response eq '' && $buf =~ m/\{(\d+)\}$eol/ ) {
                $count_octets = $1 + length($buf);
            }
            $response .= $buf;
            if ( $count_octets ) {
                $octet_count += length $buf;
                $count_octets = 0 if $octet_count >= $count_octets;
                $self->log_( 2, ">> $buf" );
            }
            if ( $count_octets == 0 ) {
                if ( $buf =~ /^$actual_tag (OK|BAD|NO)/ ) {
                    $self->log_( $1 ne 'OK' ? 0 : 1, ">> $buf" );
                    last;
                }
                if ( $buf =~ /^\* (.+)/ ) {
                    my $untagged = $1;
                    $self->log_( 1, ">> $buf" );
                    if ( $untagged =~ /UIDVALIDITY/
                         && $last_command !~ /^SELECT/
                         && $last_command !~ /^STATUS/ ) {
                        $self->log_( 0, "Got unsolicited UIDVALIDITY response from server while reading response for $last_command." );
                    }
                    if ( $untagged =~ /^BYE/ && $last_command !~ /^LOGOUT/ ) {
                        $self->log_( 0, "Got unsolicited BYE response from server while reading response for $last_command." );
                    }
                }
            }
        }
        $last_response = $response;
        alarm 0;
        $tag++;
        return $self->bail_out( "The connection to the IMAP server was lost while trying to get a response to command '$last_command'" )
            unless $response;
        return 1  if $response =~ /^$actual_tag OK/m;
        return 0  if $response =~ /^$actual_tag NO/m;
        return -1 if $response =~ /^$actual_tag BAD/m;
        $self->log_( 0, "!!! Server said something unexpected !!!" );
        return -2
    }

    method move_message ($msg, $destination) {
        $self->log_( 1, "Moving message $msg to $destination" );
        $self->say( "UID COPY $msg \"$destination\"" );
        my $ok = $self->get_response();
        if ( $ok == 1 ) {
            $self->say( "UID STORE $msg +FLAGS (\\Deleted)" );
            $ok = $self->get_response();
        }
        else {
            $self->log_( 0, "Could not copy message ($ok)!" );
        }
        return $ok ? 1 : 0
    }

    method get_mailbox_list {
        $self->log_( 1, "Getting mailbox list" );
        $self->say( 'LIST "" "*"' );
        my $result = $self->get_response();
        unless ( $result == 1 ) {
            $self->log_( 0, "LIST command failed (return value [$result])." );
            return
        }
        my @lines     = split /$eol/, $last_response;
        my @mailboxes;
        for (@lines) {
            next unless /^\*/;
            s/^\* LIST \(.*\) .+? (.+)$/$1/;
            s/"(.*?)"/$1/;
            push @mailboxes, $1;
        }
        return sort @mailboxes
    }

    method get_new_message_list {
        my $uid = $self->uid_next($folder);
        $self->log_( 1, "Getting uids ge $uid in folder $folder" );
        $self->say( "UID SEARCH UID $uid:* UNDELETED" );
        my $result = $self->get_response();
        unless ( $result == 1 ) {
            $self->log_( 0, "SEARCH command failed (return value: $result, used UID was [$uid])!" );
        }
        my @matching;
        @matching = split / /, $1 if $last_response =~ /\* SEARCH (.+)$eol/;
        return sort { $a <=> $b } grep { $_ >= $uid } @matching
    }

    method get_new_message_list_unselected ($folder_name) {
        my $last_known = $self->uid_next($folder_name);
        my $info       = $self->status($folder_name);
        $self->bail_out( "Could not get a valid response to the STATUS command." )
            unless defined $info;
        my $new_next = $info->{UIDNEXT};
        my $new_vali = $info->{UIDVALIDITY};
        if ( $new_vali != $self->uid_validity($folder_name) ) {
            $self->log_( 0, "The folder $folder_name has a new UIDVALIDTIY value! Skipping new messages (if any)." );
            $self->uid_validity( $folder_name, $new_vali );
            return
        }
        if ( $last_known < $new_next ) {
            $self->select($folder_name);
            return $self->get_new_message_list()
        }
        return
    }

    method fetch_message_part ($msg, $part) {
        if ( $part ne '' ) {
            $self->log_( 1, "Fetching $part of message $msg" );
        }
        else {
            $self->log_( 1, "Fetching message $msg" );
        }
        if ( $part eq 'TEXT' || $part eq '' ) {
            my $limit = $self->global_config_('message_cutoff') || 0;
            $self->say( "UID FETCH $msg (FLAGS BODY.PEEK[$part]<0.$limit>)" );
        }
        else {
            $self->say( "UID FETCH $msg (FLAGS BODY.PEEK[$part])" );
        }
        my $result = $self->get_response();
        $self->log_( 1, "Got " . ( $part ne '' ? $part : 'message' ) . " # $msg, result: $result." );
        unless ( $result == 1 ) {
            return 0
        }
        my @lines;
        if ( $last_response =~ m/\* \d+ FETCH/ ) {
            if ( $last_response =~ m/(?!$eol)\{(\d+)\}$eol/ ) {
                my $num_octets = $1;
                my $pos = index $last_response, "{$num_octets}$eol";
                $pos += length "{$num_octets}$eol";
                my $message = substr $last_response, $pos, $num_octets;
                while ( $message =~ m/(.*?(?:$eol|\012|\015))/g ) {
                    push @lines, $1;
                }
            }
            else {
                while ( $last_response =~ m/(.*?(?:$eol|\012|\015))/g ) {
                    push @lines, $1;
                }
                shift @lines;
                pop @lines;
                pop @lines;
                $self->log_( 0, "Could not find octet count in server's response!" );
            }
        }
        else {
            $self->log_( 0, "Unexpected server response to the FETCH command!" );
        }
        return 1, @lines
    }

    method uid_validity ($folder_name, $uidval = undef) {
        Carp::confess("gimme a folder!") unless $folder_name;
        my $all  = $self->config_('uidvalidities');
        my %hash = defined $all ? split( /$cfg_separator/, $all ) : ();
        if ( defined $uidval ) {
            $hash{$folder_name} = $uidval;
            my $new = '';
            $new .= "$_$cfg_separator$hash{$_}$cfg_separator" for keys %hash;
            $self->config_( 'uidvalidities', $new );
            $self->log_( 1, "Updated UIDVALIDITY value for folder $folder_name to $uidval." );
            return
        }
        return $hash{$folder_name} =~ /^\d+$/
            ? $hash{$folder_name}
            : undef
    }

    method uid_next ($folder_name, $uidnext = undef) {
        Carp::confess("I need a folder") unless $folder_name;
        my $all  = $self->config_('uidnexts');
        my %hash = defined $all ? split( /$cfg_separator/, $all ) : ();
        if ( defined $uidnext ) {
            $hash{$folder_name} = $uidnext;
            my $new = '';
            $new .= "$_$cfg_separator$hash{$_}$cfg_separator" for keys %hash;
            $self->config_( 'uidnexts', $new );
            $self->log_( 1, "Updated UIDNEXT value for folder $folder_name to $uidnext." );
            return
        }
        return exists $hash{$folder_name} && $hash{$folder_name} =~ /^\d+$/
            ? $hash{$folder_name}
            : undef
    }

    method check_uidvalidity ($folder_name, $new_val) {
        Carp::confess("check_uidvalidity needs a new uidvalidity!") unless defined $new_val;
        Carp::confess("check_uidvalidity needs a folder name!")     unless defined $folder_name;
        my $old_val = $self->uid_validity($folder_name);
        return $new_val == $old_val ? 1 : undef
    }

    method connected {
        return $socket ? 1 : undef
    }

    method bail_out ($msg) {
        $socket->shutdown(2) if defined $socket;
        $socket = undef;
        my ( undef, $filename, $line ) = caller;
        $self->log_( 0, $msg );
        die "POPFILE-IMAP-EXCEPTION: $msg ($filename ($line))"
    }
}
