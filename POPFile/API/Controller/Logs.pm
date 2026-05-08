package POPFile::API::Controller::Logs;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use File::Basename qw(basename);

=head1 NAME

POPFile::API::Controller::Logs — log file tail and download

=head1 DESCRIPTION

Provides read-only access to the current POPFile log file.

=cut

sub tail($self) {
    my $loader = $self->popfile_loader;
    return $self->render(status => 503, json => { error => 'Loader not available' })
        unless defined $loader;
    my $logger = $loader->get_module('POPFile::Logger');
    return $self->render(status => 503, json => { error => 'Logger not available' })
        unless defined $logger;
    my $log_file = $logger->debug_filename();
    return $self->render(json => { lines => [] })
        unless defined $log_file && -f $log_file;
    my $lines = $self->param('lines') // 100;
    $lines = 1000 if $lines > 1000;
    $lines = 1 if $lines < 1;
    open my $fh, '<', $log_file
        or return $self->render(status => 500, json => { error => "Cannot open log: $!" });
    my @all = <$fh>;
    close $fh;
    my @tail = @all < $lines ? @all : @all[-$lines .. -1];
    chomp @tail;
    $self->render(json => { lines => \@tail, file => basename($log_file) })
}

sub download($self) {
    my $loader = $self->popfile_loader;
    return $self->render(status => 503, json => { error => 'Loader not available' })
        unless defined $loader;
    my $logger = $loader->get_module('POPFile::Logger');
    return $self->render(status => 503, json => { error => 'Logger not available' })
        unless defined $logger;
    my $log_file = $logger->debug_filename();
    return $self->render(status => 404, json => { error => 'No log file' })
        unless defined $log_file && -f $log_file;
    $self->res()->headers()->content_type('text/plain; charset=UTF-8');
    $self->res()->headers()->header(
        'Content-Disposition' => 'attachment; filename="' . basename($log_file) . '"');
    $self->reply->file($log_file);
}

1;
