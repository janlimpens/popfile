# POPFILE LOADABLE MODULE
use Object::Pad;
use Fcntl ();
use Services::IMAP::Client;

class Services::IMAP :isa(POPFile::Module) {
    field $classifier :writer(set_classifier) = 0;
    field $history :writer(set_history) = 0;
    field %folders;
    field @mailboxes;
    field $folder_change_flag = 0;
    field %hash_values;
    field $api_session = '';
    field $imap_error = '';
    field $last_update = 0;

    my $cfg_separator = "-->";

    BUILD {
        $self->set_name('imap');
    }

    method initialize {
        $self->config_( 'hostname',        '' );
        $self->config_( 'port',            143 );
        $self->config_( 'login',           '' );
        $self->config_( 'password',        '' );
        $self->config_( 'update_interval', 20 );
        $self->config_( 'expunge',         0 );
        $self->config_( 'use_ssl',         0 );
        $self->config_( 'watched_folders',       'INBOX' );
        $self->config_( 'bucket_folder_mappings', '' );
        $self->config_( 'uidvalidities',          '' );
        $self->config_( 'uidnexts',               '' );
        $self->config_( 'enabled',         0 );
        $self->config_( 'training_mode',   0 );
        $last_update = time - $self->config_('update_interval');
        return 1
    }

    method start {
        return 2 if $self->config_('enabled') == 0;
        return 1
    }

    method stop {
        $self->disconnect_folders__();
    }

    method service {
        return 1 if time - $last_update < $self->config_('update_interval');
        eval {
            local $SIG{PIPE}    = 'IGNORE';
            local $SIG{__DIE__};
            if ( $self->config_('training_mode') == 1 ) {
                $self->train_on_archive__();
            }
            else {
                if ( !%folders || $folder_change_flag == 1 ) {
                    $self->build_folder_list__();
                }
                $self->connect_server__();
                %hash_values = ();
                for my $folder ( keys %folders ) {
                    $self->scan_folder($folder)
                        if exists $folders{$folder}{imap};
                }
            }
        };
        if ( $@ ) {
            $self->disconnect_folders__();
            $self->config_( 'training_mode', 0 );
            if ( $@ =~ /^POPFILE-IMAP-EXCEPTION: (.+\)\))/s ) {
                $self->log_( 0, $1 );
            }
            else {
                die $@;
            }
        }
        $last_update = time;
        return 1
    }

    method api_session {
        $api_session = $classifier->get_session_key('admin', '') unless $api_session;
        return $api_session
    }

    method new_imap_client {
        my $client = Services::IMAP::Client->new();
        $client->set_configuration($self->configuration());
        $client->set_mq($self->mq());
        $client->set_name($self->name());
        if ( $client->connect() ) {
            if ( $client->login() ) {
                return $client
            }
            $self->log_( 0, "Could not LOGIN." );
            $imap_error = 'NO_LOGIN';
        }
        else {
            $self->log_( 0, "Could not CONNECT to server." );
            $imap_error = 'NO_CONNECT';
        }
        return
    }

    method build_folder_list__ {
        $self->log_( 1, "Building list of serviced folders." );
        %folders = ();
        for my $folder ( $self->watched_folders__() ) {
            $folders{$folder}{watched} = 1;
        }
        for my $bucket ( $classifier->get_all_buckets($self->api_session()) ) {
            my $folder = $self->folder_for_bucket__($bucket);
            $folders{$folder}{output} = $bucket if defined $folder;
        }
        %folders = () if keys(%folders) == 1;
        $folder_change_flag = 0;
    }

    method connect_server__ {
        my $imap;
        for my $folder ( keys %folders ) {
            last if exists $folders{$folder}{imap};
            if ( exists $folders{$folder}{output}
                 && !exists $folders{$folder}{watched}
                 && $classifier->is_pseudo_bucket( $self->api_session(), $folders{$folder}{output} ) ) {
                next;
            }
            unless ( defined $imap ) {
                $imap = $folders{$folder}{imap};
                unless ( defined $imap ) {
                    $imap = $self->new_imap_client();
                    if ( $imap ) {
                        $folders{$folder}{imap} = $imap;
                    }
                    else {
                        die "POPFILE-IMAP-EXCEPTION: Could not connect: $imap_error " . __FILE__ . '(' . __LINE__ . '))';
                    }
                }
            }
            @mailboxes = $imap->get_mailbox_list() unless @mailboxes;
            my $info       = $imap->status($folder);
            my $uidnext    = $info->{UIDNEXT};
            my $uidvalidity = $info->{UIDVALIDITY};
            unless ( defined $uidvalidity && defined $uidnext ) {
                $self->log_( 0, "Could not STATUS folder $folder." );
                $imap->logout();
                die "POPFILE-IMAP-EXCEPTION: Could not get a STATUS for IMAP folder $folder (" . __FILE__ . '(' . __LINE__ . '))';
            }
            $folders{$folder}{imap} = $imap;
            if ( defined $imap->uid_validity($folder) ) {
                if ( $imap->check_uidvalidity( $folder, $uidvalidity ) ) {
                    unless ( defined $imap->uid_next($folder) ) {
                        $self->log_( 0, "Detected invalid UIDNEXT configuration value for folder $folder. Some new messages might have been skipped." );
                        $imap->uid_next( $folder, $uidnext );
                    }
                }
                else {
                    $self->log_( 0, "Changed UIDVALIDITY for folder $folder. Some new messages might have been skipped." );
                    $imap->uid_validity( $folder, $uidvalidity );
                    $imap->uid_next( $folder, $uidnext );
                }
            }
            else {
                $self->log_( 0, "Storing UIDVALIDITY for folder $folder." );
                $imap->uid_validity( $folder, $uidvalidity );
                $imap->uid_next( $folder, $uidnext );
            }
        }
    }

    method disconnect_folders__ {
        $self->log_( 1, "Trying to disconnect all connections." );
        for my $folder ( keys %folders ) {
            my $imap = $folders{$folder}{imap};
            if ( defined $imap && $imap->connected() ) {
                eval { $imap->logout($folder) };
            }
        }
        %folders = ();
    }

    method scan_folder ($folder) {
        my $is_watched = exists $folders{$folder}{watched} ? 1 : 0;
        my $is_output  = exists $folders{$folder}{output}  ? $folders{$folder}{output} : '';
        $self->log_( 1, "Looking for new messages in folder $folder." );
        my $imap = $folders{$folder}{imap};
        $imap->noop();
        my $moved_message = 0;
        my @uids = $imap->get_new_message_list_unselected($folder);
        for my $msg (@uids) {
            $self->log_( 1, "Found new message in folder $folder (UID: $msg)" );
            my $hash = $self->get_hash( $folder, $msg );
            $imap->uid_next( $folder, $msg + 1 );
            unless ( defined $hash ) {
                $self->log_( 0, "Skipping message $msg." );
                next;
            }
            if ( exists $hash_values{$hash} ) {
                my $destination = $hash_values{$hash};
                if ( $destination ne $folder ) {
                    $self->log_( 0, "Found duplicate hash value: $hash. Moving the message to $destination." );
                    $imap->move_message( $msg, $destination );
                    $moved_message++;
                }
                else {
                    $self->log_( 0, "Found duplicate hash value: $hash. Ignoring duplicate in folder $folder." );
                }
                next;
            }
            if ( $is_watched && $self->can_classify__($hash) ) {
                my $result = $self->classify_message( $msg, $hash, $folder );
                if ( defined $result ) {
                    $moved_message++ if $result ne '';
                    $hash_values{$hash} = $result ne '' ? $result : $folder;
                }
                next;
            }
            if ( my $bucket = $is_output ) {
                if ( my $old_bucket = $self->can_reclassify__( $hash, $bucket ) ) {
                    $self->reclassify_message( $folder, $msg, $old_bucket, $hash );
                    next;
                }
            }
            $self->log_( 1, "Ignoring message $msg" );
        }
        $imap->expunge() if $moved_message && $self->config_('expunge');
    }

    method classify_message ($msg, $hash, $folder) {
        my $file = $self->get_user_path_('imap.tmp');
        my $pseudo_mailer;
        unless ( sysopen( $pseudo_mailer, $file, Fcntl::O_RDWR() | Fcntl::O_CREAT() ) ) {
            $self->log_( 0, "Unable to open temporary file $file. Nothing done to message $msg. ($!)" );
            return
        }
        binmode $pseudo_mailer;
        my $imap       = $folders{$folder}{imap};
        my $moved_a_msg = '';
        PART: for my $part (qw/ HEADER TEXT /) {
            my ($ok, @lines) = $imap->fetch_message_part( $msg, $part );
            unless ($ok) {
                $self->log_( 0, "Could not fetch the $part part of message $msg." );
                return
            }
            syswrite $pseudo_mailer, $_ for @lines;
            my ($class, $slot, $magnet_used);
            if ( $part eq 'HEADER' ) {
                sysseek $pseudo_mailer, 0, 0;
                ($class, $slot, $magnet_used) = $classifier->classify_and_modify(
                    $self->api_session(), $pseudo_mailer, undef, 1, '', undef, 0, undef );
                if ($magnet_used) {
                    $self->log_( 0, "Message with slot $slot was classified as $class using a magnet." );
                    syswrite $pseudo_mailer, "\nThis message was classified based on a magnet.\nThe body of the message was not retrieved from the server.\n";
                }
                else {
                    next PART;
                }
            }
            sysseek $pseudo_mailer, 0, 0;
            ($class, $slot, $magnet_used) = $classifier->classify_and_modify(
                $self->api_session(), $pseudo_mailer, undef, 0, '', undef, 0, undef );
            close $pseudo_mailer;
            unlink $file;
            if ( $magnet_used || $part eq 'TEXT' ) {
                my $destination = $self->folder_for_bucket__($class);
                if ( defined $destination ) {
                    if ( $folder ne $destination ) {
                        $imap->move_message( $msg, $destination );
                        $moved_a_msg = $destination;
                    }
                }
                else {
                    $self->log_( 0, "Message cannot be moved because output folder for bucket $class is not defined." );
                }
                $self->log_( 0, "Message was classified as $class." );
                last PART;
            }
        }
        return $moved_a_msg
    }

    method reclassify_message ($folder, $msg, $old_bucket, $hash) {
        my $new_bucket = $folders{$folder}{output};
        my $imap       = $folders{$folder}{imap};
        my ($ok, @lines) = $imap->fetch_message_part( $msg, '' );
        unless ($ok) {
            $self->log_( 0, "Could not fetch message $msg!" );
            return
        }
        my $file = $self->get_user_path_('imap.tmp');
        unless ( open my $TMP, '>', $file ) {
            $self->log_( 0, "Cannot open temp file $file" );
            return
        }
        else {
            print $TMP $_ for @lines;
            close $TMP;
        }
        my $slot = $history->get_slot_from_hash($hash);
        $classifier->add_message_to_bucket( $self->api_session(), $new_bucket, $file );
        $classifier->reclassified( $self->api_session(), $old_bucket, $new_bucket, 0 );
        $history->change_slot_classification( $slot, $new_bucket, $self->api_session(), 0 );
        $self->log_( 0, "Reclassified the message with UID $msg from bucket $old_bucket to bucket $new_bucket." );
        unlink $file;
        return 1
    }

    method get_hash ($folder, $msg) {
        my $imap = $folders{$folder}{imap};
        my ($ok, @lines) = $imap->fetch_message_part(
            $msg, "HEADER.FIELDS (Message-id Date Subject Received)" );
        unless ($ok) {
            $self->log_( 0, "Could not FETCH the header fields of message $msg!" );
            return
        }
        my (%header, $last);
        for (@lines) {
            s/[\r\n]//g;
            last if /^$/;
            if ( /^([^ \t]+):[ \t]*(.*)$/ ) {
                $last = lc $1;
                push @{$header{$last}}, $2;
            }
            elsif ( defined $last ) {
                $header{$last}[-1] .= $_;
            }
        }
        my $mid      = $header{'message-id'}[0];
        my $date     = $header{'date'}[0];
        my $subject  = $header{'subject'}[0];
        my $received = $header{'received'}[0];
        my $hash     = $history->get_message_hash( $mid, $date, $subject, $received );
        $self->log_( 1, sprintf( 'Hashed message: %s.', $subject // 'undef' ) );
        $self->log_( 1, "Message $msg has hash value $hash" );
        return $hash
    }

    method can_classify__ ($hash) {
        my $slot = $history->get_slot_from_hash($hash);
        if ( $slot ne '' ) {
            $self->log_( 1, "Message was already classified (slot $slot)." );
            return
        }
        $self->log_( 1, "The message is not yet in history." );
        return 1
    }

    method can_reclassify__ ($hash, $new_bucket) {
        my $slot = $history->get_slot_from_hash($hash);
        unless ( $slot ne '' ) {
            $self->log_( 1, "Message is unknown and cannot be reclassified." );
            return
        }
        my ($id, $from, $to, $cc, $subject, $date, undef, $inserted,
            $bucket, $reclassified, undef, $magnetized) = $history->get_slot_fields($slot);
        $self->log_( 2, "get_slot_fields: slot=$slot bucket=$bucket reclassified=$reclassified magnetized=$magnetized" );
        if ($magnetized) {
            $self->log_( 1, "The message was classified using a magnet and cannot be reclassified." );
            return
        }
        if ($reclassified) {
            $self->log_( 1, "The message was already reclassified." );
            return
        }
        if ( $new_bucket eq $bucket ) {
            $self->log_( 1, "Will not reclassify to same bucket ($new_bucket)." );
            return
        }
        if ( $classifier->is_pseudo_bucket( $self->api_session(), $new_bucket ) ) {
            $self->log_( 1, "Will not reclassify to pseudo-bucket ($new_bucket)" );
            return
        }
        return $bucket
    }

    method folder_for_bucket__ ($bucket, $folder = undef) {
        my $all     = $self->config_('bucket_folder_mappings');
        my %mapping = split /$cfg_separator/, $all;
        if ( defined $folder ) {
            $mapping{$bucket} = $folder;
            my $new = '';
            $new .= "$_$cfg_separator$mapping{$_}$cfg_separator" for keys %mapping;
            $self->log_( 1, $new );
            $self->config_( 'bucket_folder_mappings', $new );
            return
        }
        return exists $mapping{$bucket} ? $mapping{$bucket} : undef
    }

    method watched_folders__ (@new_folders) {
        my $all = $self->config_('watched_folders');
        if (@new_folders) {
            $self->config_( 'watched_folders', join( $cfg_separator, @new_folders ) . $cfg_separator );
            return
        }
        return split /$cfg_separator/, $all
    }

    method train_on_archive__ {
        $self->log_( 0, "Training on existing archive." );
        %folders = ();
        $self->build_folder_list__();
        for my $folder ( keys %folders ) {
            delete $folders{$folder} if exists $folders{$folder}{watched};
        }
        $self->connect_server__();
        for my $folder ( keys %folders ) {
            my $bucket = $folders{$folder}{output};
            next if $classifier->is_pseudo_bucket( $self->api_session(), $bucket );
            next if $folder eq 'INBOX';
            my $imap = $folders{$folder}{imap};
            $imap->uid_next( $folder, 1 );
            my @uids = $imap->get_new_message_list_unselected($folder);
            $self->log_( 0, "Training on " . scalar(@uids) . " messages in folder $folder to bucket $bucket." );
            for my $msg (@uids) {
                my ($ok, @lines) = $imap->fetch_message_part( $msg, '' );
                $imap->uid_next( $folder, $msg );
                unless ($ok) {
                    $self->log_( 0, "Could not fetch message $msg!" );
                    next;
                }
                my $file = $self->get_user_path_('imap.tmp');
                unless ( open my $TMP, '>', $file ) {
                    $self->log_( 0, "Cannot open temp file $file" );
                    next;
                }
                else {
                    print $TMP "$_\n" for @lines;
                    close $TMP;
                }
                $classifier->add_message_to_bucket( $self->api_session(), $bucket, $file );
                $self->log_( 0, "Training on the message with UID $msg to bucket $bucket." );
                unlink $file;
            }
        }
        %folders = ();
        $self->config_( 'training_mode', 0 );
    }
}
