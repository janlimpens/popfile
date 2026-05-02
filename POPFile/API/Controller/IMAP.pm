package POPFile::API::Controller::IMAP;

=head1 NAME

POPFile::API::Controller::IMAP - IMAP folder configuration and diagnostic endpoints

=head1 DESCRIPTION

Handles all C</api/v1/imap/*> routes for IMAP folder management and server
diagnostics. Uses C<Services::IMAP::Client> (lazy-loaded) to test connections
and retrieve live folder lists from the IMAP server.

Services are accessed via the Mojolicious helpers registered in
L<POPFile::API/build_app>: C<popfile_api> for configuration access.

=cut

use Mojo::Base 'Mojolicious::Controller', -signatures;
use POPFile::Features;

sub _make_test_client($self, $body) {
    require POPFile::Configuration;
    require Services::IMAP::Client;
    my $api = $self->popfile_api;
    my $base = $api->configuration();
    my $config = POPFile::Configuration->new();
    $config->set_configuration($config);
    $config->set_mq($api->mq());
    $config->set_popfile_root($base->popfile_root());
    $config->set_popfile_user($base->popfile_user());
    $config->initialize();
    $config->set_started(1);
    $config->parameter('GLOBAL_timeout', $base->parameter('GLOBAL_timeout') // 60);
    my $client = Services::IMAP::Client->new();
    $client->set_configuration($config);
    $client->set_mq($api->mq());
    $client->set_name('imap');
    $client->config('hostname', $body->{hostname} // '');
    $client->config('port', $body->{port} // 143);
    $client->config('login', $body->{login} // '');
    $client->config('password', $body->{password} // '');
    $client->config('use_ssl', $body->{use_ssl} // 0);
    return $client
}

sub get_folders ($self) {
    my $api = $self->popfile_api;
    my $watched_raw = $api->module_config('imap', 'watched_folders') // '';
    my $mapping_raw = $api->module_config('imap', 'bucket_folder_mappings') // '';
    my $sep = $self->_imap_sep();
    my @watched = grep { $_ ne '' } split /\Q$sep\E/, $watched_raw;
    my %map_hash = split /\Q$sep\E/, $mapping_raw;
    my @mappings = map { { bucket => $_, folder => $map_hash{$_} } }
                    grep { $_ ne '' } keys %map_hash;
    $self->render(json => { watched => \@watched, mappings => \@mappings });
}

sub update_folders ($self) {
    my $api = $self->popfile_api;
    my $body = $self->req->json // {};
    my $sep = $self->_imap_sep();
    if (defined $body->{watched}) {
        my @w = grep { defined $_ && $_ ne '' } $body->{watched}->@*;
        my $raw = join($sep, @w) . (@w ? $sep : '');
        $api->module_config('imap', 'watched_folders', $raw);
    }
    if (defined $body->{mappings}) {
        my $raw = '';
        for my $m ($body->{mappings}->@*) {
            next unless defined $m->{bucket} && $m->{bucket} ne ''
                        && defined $m->{folder} && $m->{folder} ne '';
            $raw .= "$m->{bucket}$sep$m->{folder}$sep";
        }
        $api->module_config('imap', 'bucket_folder_mappings', $raw);
    }
    $api->configuration()->save_configuration();
    $self->render(json => { ok => \1 });
}

sub get_server_folders ($self) {
    require Services::IMAP::Client;
    my $api = $self->popfile_api;
    my $client = Services::IMAP::Client->new();
    $client->set_configuration($api->configuration());
    $client->set_mq($api->mq());
    $client->set_name('imap');
    unless ($client->connect()) {
        return $self->render(status => 503, json => { error => 'connect failed' });
    }
    unless ($client->login()) {
        return $self->render(status => 503, json => { error => 'login failed' });
    }
    my @folders = $client->get_mailbox_list();
    $client->logout();
    $self->render(json => \@folders);
}

sub test_connection ($self) {
    my $body = $self->req->json // {};
    my $client = $self->_make_test_client($body);
    my $err = '';
    try {
        unless ($client->connect()) {
            die 'connect';
        }
        unless ($client->login()) {
            die 'login';
        }
        $client->logout();
    }
    catch ($e) {
        if ($e =~ /^connect/) {
            $err = 'Could not connect to server';
        }
        elsif ($e =~ /^login/) {
            $err = 'Login failed';
        }
        elsif ($e =~ /POPFILE-IMAP-EXCEPTION: (.+?) \(/) {
            $err = $1;
        }
        else {
            $err = 'Connection test failed';
        }
        return $self->render(json => { ok => \0, error => $err });
    }
    $self->render(json => { ok => \1 });
}

sub _touch($path) {
    open my $fh, '>', $path or return 0;
    close $fh;
    return 1
}

sub trigger_training ($self) {
    my $api = $self->popfile_api;
    my $body = $self->req->json // {};
    my @buckets = ref $body->{buckets} eq 'ARRAY' ? $body->{buckets}->@* : ();
    my $all = $body->{all} || !@buckets;
    $api->module_config('imap', 'training_error', '');
    $api->configuration()->save_configuration();
    my @queued;
    if ($all) {
        my $flag = $api->get_user_path('popfile.train');
        return $self->render(status => 500, json => { error => 'cannot create flag' })
            unless defined $flag && _touch($flag);
        push @queued, '*';
    } else {
        for my $bucket (grep { /^[a-z0-9_-]+$/ } @buckets) {
            my $flag = $api->get_user_path("popfile.train.$bucket");
            next unless defined $flag && _touch($flag);
            push @queued, $bucket;
        }
    }
    $self->render(json => { ok => \1, queued => \@queued });
}

sub training_status ($self) {
    my $api = $self->popfile_api;
    my $pattern = $api->get_user_path('popfile.train*', 0);
    my @flags = defined $pattern ? glob($pattern) : ();
    my @pending = map {
        /popfile\.train\.(.+)$/ ? $1 : '*'
    } @flags;
    $self->render(json => { pending => \@pending });
}

sub rescan_folder ($self) {
    my $imap = $self->popfile_imap;
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless defined $imap;
    my $body = $self->req->json // {};
    my $folder = $body->{folder} // '';
    return $self->render(status => 400, json => { error => 'folder required' })
        unless $folder;
    $imap->request_folder_rescan($folder);
    $self->render(json => { queued => \1, folder => $folder });
}

sub _imap_sep ($self) {
    return '-->'
}

1;
