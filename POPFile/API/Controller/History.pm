package POPFile::API::Controller::History;

=head1 NAME

POPFile::API::Controller::History - Message history and reclassification endpoints

=head1 DESCRIPTION

Handles all C</api/v1/history> routes, including pagination, filtering,
and bulk reclassification. Services are accessed via the Mojolicious helpers
registered in L<POPFile::API/build_app>: C<popfile_svc>, C<popfile_session>,
and C<popfile_history>.

=cut

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Encode qw();

my sub decode_header($value) {
    return ''
        unless defined $value && length $value;
    return Encode::decode('MIME-Header', $value)
}

sub list_history ($self) {
    my $svc = $self->popfile_svc;
    my $max_per_page = 200;
    my $per_page_default = 25;
    my $page = ($self->param('page') // 1) + 0;
    my $per_page = ($self->param('per_page') // $per_page_default) + 0;
    my $search = $self->param('search');
    my $bucket = $self->param('bucket');
    $page = 1
        if $page < 1;
    $per_page = $per_page_default
        if $per_page < 1 || $per_page > $max_per_page;
    my $hist = $svc->history_obj();
    my ($total, $rows) = $hist->get_search_queries(
        $bucket ? (bucket => $bucket) : (),
        $search ? (search => $search) : (),
        page => $page,
        per_page => $per_page,
        sort => 'date DESC' );
    my @items =
        map {
            $_->{color} = $svc->get_bucket_color($_->{'bucket'} // '') // '#666666';
            $_->{hdr_from}    = decode_header($_->{hdr_from});
            $_->{hdr_subject} = decode_header($_->{hdr_subject});
            $_->{hdr_to}      = decode_header($_->{hdr_to});
            $_
        }
        grep { $_ }
        $rows->@*;
    $self->render(json => { items => \@items, total => $total });
}

sub reclassify_unclassified ($self) {
    my $svc = $self->popfile_svc;
    my $session = $self->popfile_session;
    my $hist = $svc->history_obj();
    my $qid = $hist->start_query();
    $hist->set_query($qid, 'unclassified', '', '-inserted', 0);
    my $total = $hist->get_query_size($qid);
    my @rows = $hist->get_query_rows($qid, 1, $total);
    $hist->stop_query($qid);
    my $updated = 0;
    for my $row (@rows) {
        next unless defined $row;
        my $slot = $row->[0];
        my $file = $hist->get_slot_file($slot);
        next unless defined $file;
        my $new_bucket = $svc->classify($file);
        next unless defined $new_bucket && $new_bucket ne 'unclassified';
        $hist->change_slot_classification($slot, $new_bucket, $session, 0);
        $updated++;
    }
    $self->render(json => { updated => $updated + 0, total => $total + 0 });
}

sub bulk_reclassify ($self) {
    my $svc = $self->popfile_svc;
    my $session = $self->popfile_session;
    my $body = $self->req->json // {};
    my $bucket = $body->{bucket} // '';
    my $slots = $body->{slots} // [];
    if ($bucket eq '' || ref $slots ne 'ARRAY' || !$slots->@*) {
        return $self->render(status => 400, json => { error => 'invalid params' });
    }
    my %known = map { $_ => 1 } $svc->get_all_buckets();
    unless ($known{$bucket}) {
        return $self->render(status => 422, json => { error => 'unknown bucket' });
    }
    my @valid_slots = grep { /^\d+$/ } $slots->@*;
    my $updated = 0;
    for my $slot (@valid_slots) {
        my $result = $self->_do_reclassify($slot, $bucket);
        $updated++
            unless $result->{error};
    }
    $self->render(json => { updated => $updated + 0 });
}

sub reclassify_item ($self) {
    my $slot = $self->param('slot');
    my $body = $self->req->json // {};
    my $bucket = $body->{bucket} // '';
    if ($bucket eq '' || $slot !~ /^\d+$/) {
        return $self->render(status => 400, json => { error => 'invalid params' });
    }
    my $result = $self->_do_reclassify($slot, $bucket);
    if ($result->{error}) {
        return $self->render(status => 422, json => { error => $result->{error} });
    }
    $self->render(json => { ok => \1 });
}

sub get_history_item ($self) {
    my $svc = $self->popfile_svc;
    my $slot = $self->param('slot');
    return $self->render(status => 400, json => { error => 'invalid slot' })
        unless $slot =~ /^\d+$/;
    my $hist = $svc->history_obj();
    my $file = $hist->get_slot_file($slot);
    return $self->render(status => 404, json => { error => 'not found' })
        unless defined $file && -f $file;
    open my $fh, '<', $file
        or return $self->render(status => 500, json => { error => 'cannot read' });
    my $in_headers = 1;
    my $body = '';
    while (<$fh>) {
        s/[\r\n]//g;
        if ($in_headers) {
            $in_headers = 0 if $_ eq '';
            next;
        }
        $body .= "$_\n";
    }
    close $fh;
    my %orig_for;
    for my $raw (split /\W+/, $body) {
        next if $raw eq '';
        my $mangled = $svc->mangle_word($raw);
        next if $mangled eq '' || exists $orig_for{$mangled};
        $orig_for{$mangled} = lc $raw;
    }
    my %mangled_colors = $svc->get_word_colors(keys %orig_for);
    my %word_colors;
    for my $mangled (keys %mangled_colors) {
        $word_colors{ $orig_for{$mangled} } = $mangled_colors{$mangled};
    }
    $self->render(json => { body => $body, word_colors => \%word_colors });
}

sub _do_reclassify ($self, $slot, $bucket) {
    my $svc = $self->popfile_svc;
    my $session = $self->popfile_session;
    my %known = map { $_ => 1 } $svc->get_all_buckets();
    return { error => 'unknown bucket' }
        unless $known{$bucket};
    my $hist = $svc->history_obj();
    my @fields = $hist->get_slot_fields($slot);
    return { error => 'invalid slot' }
        unless @fields;
    my $old_bucket = $fields[8];
    my $hash = $fields[6];
    $hist->change_slot_classification($slot, $bucket, $session, 0);
    return {}
        unless defined $old_bucket && $old_bucket ne $bucket;
    my $file = $hist->get_slot_file($slot);
    $svc->remove_message_from_bucket($old_bucket, $file);
    $svc->add_message_to_bucket($bucket, $file);
    my $imap = $self->popfile_imap;
    $imap->request_folder_move($hash, $bucket)
        if defined $imap && defined $hash;
    return {}
}

__PACKAGE__
