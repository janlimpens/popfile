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
use Email::MIME;
use Encode qw();
use HTML::Entities qw(decode_entities);
use feature 'current_sub';

my sub decode_header($value) {
    return '' unless defined $value && length $value;
    return $value unless $value =~ /=\?[\w-]+\?[BbQq]\?/;
    my $bytes = Encode::is_utf8($value) ? Encode::encode('UTF-8', $value) : $value;
    $bytes .= '?=' unless $bytes =~ /\?=\s*$/;
    return Encode::decode('MIME-Header', $bytes)
}

my sub _strip_html($html) {
    $html =~ s/<(?:style|script)[^>]*>.*?<\/(?:style|script)>//gsi;
    $html =~ s/<br\s*\/?>|<\/(?:p|div|tr|li|blockquote|h\d)>/\n/gi;
    $html =~ s/<[^>]+>//g;
    return decode_entities($html)
}

my sub _normalise($text) {
    $text =~ s/\p{Cf}//g;
    $text =~ s/\p{Zs}/ /g;
    $text =~ s/\r//g;
    $text =~ s/^[^\S\n]+$//mg;
    $text =~ s/([\s\n])+/$1/g;
    $text =~ s/\A\n+//;
    return $text
}

my sub _part_text($part) {
    my $ct = $part->content_type // 'text/plain';
    return '' unless $ct =~ m{^text/}i;
    my $body = eval { $part->body_str } // $part->body // '';
    $body = _strip_html($body) if $ct =~ m{text/html}i;
    return _normalise($body)
}

my sub _extract_body($email) {
    my @parts = $email->subparts;
    return _part_text($email) unless @parts;
    my ($plain) = grep { ($_->content_type // '') =~ m{^text/plain}i } @parts;
    my ($html)  = grep { ($_->content_type // '') =~ m{^text/html}i  } @parts;
    if ($plain) {
        my $text = _part_text($plain);
        return $text if !$html || length($text) >= 200;
        my $html_text = _part_text($html);
        return length($html_text) > length($text) ? $html_text : $text;
    }
    for my $part (@parts) {
        my $text = __SUB__->($part);
        return $text if $text ne '';
    }
    return ''
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
            $_->{color}   = $svc->get_bucket_color($_->{'bucket'} // '') // '#666666';
            $_->{from}    = decode_header($_->{from});
            $_->{subject} = decode_header($_->{subject});
            $_->{to}      = decode_header($_->{to});
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
    open my $fh, '<:raw', $file
        or return $self->render(status => 500, json => { error => 'cannot read' });
    my $raw = do { local $/; <$fh> };
    close $fh;
    my $email = eval { Email::MIME->new($raw) };
    return $self->render(status => 500, json => { error => 'cannot parse' })
        unless defined $email;
    my $body = _extract_body($email);
    my %orig_for;
    for my $word (split /\W+/, $body) {
        next if $word eq '';
        my $mangled = $svc->mangle_word($word);
        next if $mangled eq '' || exists $orig_for{$mangled};
        $orig_for{$mangled} = lc $word;
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
