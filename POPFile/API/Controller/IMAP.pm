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
    require Services::IMAP::Client;
    my $api = $self->popfile_api;
    my $body = $self->req->json // {};
    my $client = Services::IMAP::Client->new();
    $client->set_configuration($api->configuration());
    $client->set_mq($api->mq());
    $client->set_name('imap');
    $client->config('hostname', $body->{hostname} // '');
    $client->config('port', $body->{port} // 143);
    $client->config('login', $body->{login} // '');
    $client->config('password', $body->{password} // '');
    $client->config('use_ssl', $body->{use_ssl} // 0);
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

sub trigger_training ($self) {
    my $api = $self->popfile_api;
    my $body = $self->req->json // {};
    my @buckets = ref $body->{buckets} eq 'ARRAY' ? $body->{buckets}->@* : ();
    my $all = $body->{all} || !@buckets;
    my @queued;
    if ($all) {
        my $flag = $api->get_user_path('popfile.train');
        return $self->render(status => 500, json => { error => 'cannot create flag' })
            unless defined $flag && open(my $fh, '>', $flag) && close($fh);
        push @queued, '*';
    } else {
        for my $bucket (grep { /^[a-z0-9_-]+$/ } @buckets) {
            my $flag = $api->get_user_path("popfile.train.$bucket");
            next unless defined $flag && open(my $fh, '>', $flag) && close($fh);
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

sub _imap_sep ($self) {
    return '-->'
}

__PACKAGE__
