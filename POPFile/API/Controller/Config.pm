package POPFile::API::Controller::Config;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use constant CFG => {
    api_port => [api => 'port'],
    api_password => [api => 'password'],
    api_local => [api => 'local'],
    api_page_size => [api => 'page_size'],
    api_session_dividers => [api => 'session_dividers'],
    api_wordtable_format => [api => 'wordtable_format'],
    api_locale => [api => 'locale'],
    pop3_enabled => [pop3 => 'enabled'],
    pop3_port => [pop3 => 'port'],
    pop3_separator => [pop3 => 'separator'],
    pop3_local => [pop3 => 'local'],
    pop3_force_fork => [pop3 => 'force_fork'],
    pop3_toptoo => [pop3 => 'toptoo'],
    pop3_secure_server => [pop3 => 'secure_server'],
    pop3_secure_port => [pop3 => 'secure_port'],
    smtp_enabled => [smtp => 'enabled'],
    smtp_port => [smtp => 'port'],
    smtp_chain_server => [smtp => 'chain_server'],
    smtp_chain_port => [smtp => 'chain_port'],
    smtp_local => [smtp => 'local'],
    smtp_force_fork => [smtp => 'force_fork'],
    nntp_enabled => [nntp => 'enabled'],
    nntp_port => [nntp => 'port'],
    nntp_separator => [nntp => 'separator'],
    nntp_local => [nntp => 'local'],
    nntp_force_fork => [nntp => 'force_fork'],
    nntp_headtoo => [nntp => 'headtoo'],
    bayes_hostname => [bayes => 'hostname'],
    bayes_message_cutoff => [bayes => 'message_cutoff'],
    bayes_unclassified_weight => [bayes => 'unclassified_weight'],
    bayes_subject_mod_left => [bayes => 'subject_mod_left'],
    bayes_subject_mod_right => [bayes => 'subject_mod_right'],
    bayes_subject_mod_pos => [bayes => 'subject_mod_pos'],
    bayes_sqlite_fast_writes => [bayes => 'sqlite_fast_writes'],
    bayes_sqlite_backup => [bayes => 'sqlite_backup'],
    bayes_sqlite_journal_mode => [bayes => 'sqlite_journal_mode'],
    wordmangle_stemming => [wordmangle => 'stemming'],
    wordmangle_auto_detect_language => [wordmangle => 'auto_detect_language'],
    history_history_days => [history => 'history_days'],
    history_archive => [history => 'archive'],
    history_archive_dir => [history => 'archive_dir'],
    history_archive_classes => [history => 'archive_classes'],
    logger_level => [logger => 'level'],
    logger_logdir => [logger => 'logdir'],
    logger_log_to_stdout => [logger => 'log_to_stdout'],
    logger_log_sql => [logger => 'log_sql'],
    imap_enabled => [imap => 'enabled'],
    imap_hostname => [imap => 'hostname'],
    imap_port => [imap => 'port'],
    imap_login => [imap => 'login'],
    imap_password => [imap => 'password'],
    imap_use_ssl => [imap => 'use_ssl'],
    imap_update_interval => [imap => 'update_interval'],
    imap_expunge => [imap => 'expunge'],
    imap_training_mode => [imap => 'training_mode'],
    imap_training_error => [imap => 'training_error'],
    imap_training_limit => [imap => 'training_limit'],
};

sub get_config($self) {
    my $api = $self->popfile_api;
    my %cfg;
    for my $key (keys %{CFG()}) {
        my ($mod, $param) = CFG->{$key}->@*;
        $cfg{$key} = $api->module_config($mod, $param) // '';
    }
    $self->render(json => \%cfg)
}

sub update_config($self) {
    my $api = $self->popfile_api;
    my $body = $self->req->json // {};
    for my $key (keys $body->%*) {
        next unless exists CFG->{$key};
        my ($mod, $param) = CFG->{$key}->@*;
        if ($key =~ /^imap_(hostname|login|password)$/) {
            my $val = $body->{$key} // '(undef)';
            $self->app->log->info("CONFIG_DIAG: update_config setting $key='$val'");
        }
        $api->module_config($mod, $param, $body->{$key});
    }
    $api->configuration()->save_configuration();
    $self->render(json => { ok => \1 })
}

sub get_status($self) {
    my $api = $self->popfile_api;
    my $hostname = $api->module_config('imap', 'hostname') // '';
    my $port = $api->module_config('imap', 'port') // '';
    my $login = $api->module_config('imap', 'login') // '';
    my $password = $api->module_config('imap', 'password') // '';
    my $use_ssl = $api->module_config('imap', 'use_ssl') // 0;
    my $imap_sep = '-->';
    my $watched_raw = $api->module_config('imap', 'watched_folders') // '';
    my $mapping_raw = $api->module_config('imap', 'bucket_folder_mappings') // '';
    my $flag_pattern = $api->get_user_path('popfile.train*', 0);
    my @train_flags = defined $flag_pattern ? glob($flag_pattern) : ();
    my @train_pending = map { /popfile\.train\.(.+)$/ ? $1 : '*' } @train_flags;
    unless ($hostname ne '' && $port ne '') {
        return $self->render(json => { checks => [{
            id => 'connectivity',
            label => 'IMAP Connectivity',
            status => 'warn',
            detail => 'IMAP not configured',
        }] });
    }
    my $cfg_obj = $api->configuration();
    my $mq_obj = $api->mq();
    $self->render_later();
    Mojo::IOLoop->subprocess(
        sub {
            require Services::IMAP::Client;
            my @c;
            my $client = Services::IMAP::Client->new();
            $client->set_configuration($cfg_obj);
            $client->set_mq($mq_obj);
            $client->set_name('imap');
            $client->config('hostname', $hostname);
            $client->config('port', $port);
            $client->config('login', $login);
            $client->config('password', $password);
            $client->config('use_ssl', $use_ssl);
            unless ($client->connect()) {
                push @c, { id => 'connectivity', label => 'IMAP Connectivity',
                    status => 'error', detail => "Cannot reach $hostname:$port" };
                return \@c;
            }
            push @c, { id => 'connectivity', label => 'IMAP Connectivity',
                status => 'ok', detail => "Connected to $hostname:$port" };
            unless ($client->login()) {
                push @c, { id => 'authentication', label => 'IMAP Authentication',
                    status => 'error', detail => "Login failed for $login" };
                return \@c;
            }
            push @c, { id => 'authentication', label => 'IMAP Authentication',
                status => 'ok', detail => "Logged in as $login" };
            my @server_folders = $client->get_mailbox_list();
            $client->logout();
            my %on_server = map { $_ => 1 } @server_folders;
            my @watched = grep { $_ ne '' } split /\Q$imap_sep\E/, $watched_raw;
            my @missing_w = grep { !$on_server{$_} } @watched;
            push @c, { id => 'watched_folders', label => 'Watched Folders',
                status => @missing_w ? 'warn' : 'ok',
                detail => @missing_w
                    ? 'Missing on server: ' . join(', ', @missing_w)
                    : 'All ' . scalar(@watched) . ' watched folder(s) exist' };
            my %map_hash = split /\Q$imap_sep\E/, $mapping_raw;
            my @missing_m = grep { $_ ne '' && !$on_server{$map_hash{$_}} } keys %map_hash;
            push @c, { id => 'bucket_mappings', label => 'Bucket → Folder Mappings',
                status => @missing_m ? 'warn' : 'ok',
                detail => @missing_m
                    ? 'Target folders missing: ' . join(', ', map { $map_hash{$_} } @missing_m)
                    : 'All ' . scalar(keys %map_hash) . ' mapping(s) valid' };
            return \@c
        },
        sub ($loop, $err, $result) {
            my @checks = defined $result ? $result->@* : ();
            if (@train_pending) {
                my $who = join(', ', map { $_ eq '*' ? 'all' : $_ } @train_pending);
                push @checks, { id => 'training', label => 'Training',
                    status => 'warn',
                    detail => "Training pending: $who" };
            }
            $self->render(json => { checks => \@checks });
        }
    );
}

__PACKAGE__
