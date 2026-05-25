package POPFile::API::Controller::Config;
use Mojo::Base 'Mojolicious::Controller', -signatures;

use POPFile::Config;

# Keys accepted by PUT but never returned by GET.
my %API_WRITE_ONLY = (
    bayes => { map { $_ => 1 } qw(dbauth) },
    imap  => { map { $_ => 1 } qw(password) },
);

# Build flat API-key → {ns, key, wo} map from schema.
# wo=1 keys are accepted by PUT but excluded from GET.
sub _api_config_map() {
    state $map;
    return $map
        if $map;
    my $props = POPFile::Config->schema_properties();
    for my $ns (sort keys $props->%*) {
        next if $ns eq 'version';
        my $keys = $props->{$ns}{properties};
        for my $key (sort keys $keys->%*) {
            $map->{"${ns}_$key"} = { ns => $ns, key => $key, wo => $API_WRITE_ONLY{$ns}{$key} };
        }
    }
    return $map
}

sub get_config($self) {
    my $map = _api_config_map();
    my %result;
    for my $flat_key (keys $map->%*) {
        next if $map->{$flat_key}{wo};
        my $entry = $map->{$flat_key};
        $result{$flat_key} = POPFile::Config->instance()->get($entry->{ns}, $entry->{key}) // '';
    }
    $self->render(json => \%result)
}

sub update_config($self) {
    require POPFile::ConfigFile;
    my $body = $self->req->json // {};
    my $path = POPFile::Config->resolve_path();
    my $data = POPFile::ConfigFile->new()->load($path);
    my $map = _api_config_map();
    for my $flat_key (keys $body->%*) {
        next
            unless exists $map->{$flat_key};
        my $entry = $map->{$flat_key};
        $data->{$entry->{ns}}{$entry->{key}} = $body->{$flat_key};
    }
    my $props = POPFile::Config->schema_properties();
    for my $ns (keys $props->%*) {
        next if $ns eq 'version';
        next
            unless ref $data->{$ns} eq 'HASH';
        my $keys = $props->{$ns}{properties};
        delete $data->{$ns}{$_}
            for grep { !exists $keys->{$_} } keys $data->{$ns}->%*;
    }
    delete $data->{$_}
        for grep { $_ ne 'version' && !exists $props->{$_} } keys $data->%*;
    my $result = POPFile::Config->try_validate($data);
    if ($result->@*) {
        my @fields;
        for my $msg ($result->@*) {
            my (undef, $detail) = split(/: /, $msg, 2);
            my $path = (split(/: /, $msg, 2))[0];
            $path =~ s{^/}{};
            $path =~ s{/}{_}g;
            push @fields, { path => $path, message => $detail // $msg };
        }
        return $self->render(status => 422, json => { error => join("\n", $result->@*), fields => \@fields });
    }
    POPFile::ConfigFile->new()->save($path, $data);
    if (grep { /^logger_/ } keys $body->%*) {
        my $loader = $self->popfile_loader();
        my $logger = $loader->get_module('POPFile::Logger')
            if defined $loader;
        $logger->reconfigure()
            if defined $logger;
    }
    $self->render(json => { ok => \1, restart_needed => \1 })
}

sub get_status($self) {
    my $cfg = POPFile::Config->instance();
    my $imap_enabled = $cfg->get(imap => 'enabled') // 0;
    unless ($imap_enabled) {
        return $self->render(json => { checks => [{
            id => 'imap_service',
            label => 'IMAP Service',
            status => 'disabled',
            detail => 'IMAP is disabled. Enable it in Settings → IMAP.',
        }] });
    }
    state $cached_result;
    state $cached_at = 0;
    my $now = time();
    if ($cached_result && $now - $cached_at < 60) {
        return $self->render(json => $cached_result);
    }
    my $hostname = $cfg->get(imap => 'hostname') // '';
    my $port = $cfg->get(imap => 'port') // '';
    my $login = $cfg->get(imap => 'login') // '';
    my $password = $cfg->get(imap => 'password') // '';
    my $use_ssl = $cfg->get(imap => 'use_ssl') // 0;
    my $flag_pattern = $self->popfile_api->get_user_path('popfile.train*', 0);
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
    my $mq_obj = $self->popfile_api->mq();
    $self->render_later();
    Mojo::IOLoop->subprocess(
        sub {
            require Services::IMAP::Client;
            my @c;
            my $client = Services::IMAP::Client->new();
            $client->set_mq($mq_obj);
            $client->set_name('imap');
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
            my $imap_svc = $self->popfile_imap();
            my @watched = $imap_svc->watched_folders();
            my %map_hash = $imap_svc->folder_mappings();
            my @missing_w = grep { !$on_server{$_} } @watched;
            push @c, { id => 'watched_folders', label => 'Watched Folders',
                status => @missing_w ? 'warn' : 'ok',
                detail => @missing_w
                    ? 'Missing on server: ' . join(', ', @missing_w)
                    : 'All ' . scalar(@watched) . ' watched folder(s) exist' };
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
            my $response = { checks => \@checks };
            $cached_result = $response;
            $cached_at = $now;
            $self->render(json => $response);
        }
    );
}

sub restart($self) {
    $self->render(json => { ok => \1, message => 'Restarting...' });
    $self->rendered(200);
    my $dir = ($ENV{POPFILE_USER} // $ENV{POPFILE_ROOT} // '.');
    $dir =~ s{[\\/]+$}{};
    unlink("$dir/popfile.pid");
    my $script = $ENV{POPFILE_SCRIPT} // $0;
    exec($^X, $script, 'start')
}

sub get_timezones($self) {
    require File::Find;
    my $base = '/usr/share/zoneinfo';
    return $self->render(json => ['UTC'])
        unless -d $base;
    my @zones;
    File::Find::find({
        wanted => sub {
            return if -d $_;
            (my $rel = $File::Find::name) =~ s{^\Q$base/\E}{};
            return if $rel =~ m{^right/|^posix/};
            my $is_metadata = $rel eq 'localtime'
                || $rel eq 'posixrules'
                || $rel eq 'leapseconds'
                || $rel =~ /\.(?:tab|list|zi)$/;
            return if $is_metadata;
            push @zones, $rel;
        },
        no_chdir => 1 }, $base);
    @zones = sort @zones;
    unshift @zones, 'UTC';
    my $host = POPFile::Config->_detect_host_timezone();
    $self->render(json => { zones => \@zones, host => $host });
}

1;
