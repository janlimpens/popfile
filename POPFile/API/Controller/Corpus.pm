package POPFile::API::Controller::Corpus;

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub _bucket_name ($self, $id) {
    my $svc = $self->popfile_svc;
    for my $name ($svc->get_all_buckets()) {
        return $name
            if ($svc->get_bucket_id($name) // 0) == $id;
    }
    return
}

sub _bucket_or_404 ($self, $id) {
    my $name = _bucket_name($self, $id);
    return $name
        if defined $name;
    $self->render(status => 404, json => { error => 'not found' });
    return
}

sub list_buckets ($self) {
    my $svc = $self->popfile_svc;
    my @result;
    for my $b ($svc->get_all_buckets()) {
        push @result, {
            id => $svc->get_bucket_id($b) + 0,
            name => $b,
            pseudo => $svc->is_pseudo_bucket($b) ? \1 : \0,
            word_count => $svc->get_bucket_word_count($b) + 0,
            color => $svc->get_bucket_color($b) // '#666666',
        };
    }
    $self->render(json => \@result);
}

sub create_bucket ($self) {
    my $svc = $self->popfile_svc;
    my $body = $self->req->json // {};
    my $name = $body->{name} // '';
    my $color = $body->{color} // '';
    return $self->render(status => 400, json => { error => 'name required' })
        if $name eq '';
    return $self->render(status => 422, json => { error => 'invalid name' })
        if $name =~ /[^\p{L}\p{N}\s\-_]/ || $name =~ m{[/\\]|\.\.};
    my $ok = $svc->create_bucket($name);
    return $self->render(status => 409, json => { error => 'bucket already exists' })
        unless $ok;
    $svc->set_bucket_color($name, $color)
        if $color =~ /^#[0-9a-fA-F]{6}$/;
    my $id = $svc->get_bucket_id($name);
    $self->render(json => { ok => \1, id => $id + 0 });
}

sub get_bucket ($self) {
    my $svc = $self->popfile_svc;
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    $self->render(json => {
        id => $svc->get_bucket_id($name) + 0,
        name => $name,
        color => $svc->get_bucket_color($name) // '#666666',
        word_count => $svc->get_bucket_word_count($name) + 0,
        pseudo => $svc->is_pseudo_bucket($name) ? \1 : \0,
        fpcount => ($svc->get_bucket_parameter($name, 'fpcount') // 0) + 0,
        fncount => ($svc->get_bucket_parameter($name, 'fncount') // 0) + 0,
    });
}

sub delete_bucket ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    $self->popfile_svc->delete_bucket($name);
    $self->render(json => { ok => \1 });
}

sub rename_bucket ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $body = $self->req->json // {};
    my $new = $body->{new_name} // '';
    return $self->render(status => 400, json => { error => 'new_name required' })
        if $new eq '';
    $self->popfile_svc->rename_bucket($name, $new);
    $self->render(json => { ok => \1 });
}

sub get_bucket_words ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $svc = $self->popfile_svc;
    my $prefix = $self->param('prefix') // '';
    my @words = $svc->get_bucket_word_list($name, $prefix);
    my @result = map { { id => $_->[0] + 0, word => $_->[1], count => ($_->[2] // 0) + 0 } } @words;
    $self->render(json => \@result);
}

sub clear_bucket_words ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    $self->popfile_svc->clear_bucket($name);
    $self->render(json => { ok => \1 });
}

sub update_bucket_params ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $svc = $self->popfile_svc;
    my $body = $self->req->json // {};
    $svc->set_bucket_color($name, $body->{color})
        if defined $body->{color};
    $self->render(json => { ok => \1 });
}

sub list_bucket_words_with_accuracy ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $svc = $self->popfile_svc;
    my $page = ($self->param('page') // 1) + 0;
    my $per_page = ($self->param('per_page') // 50) + 0;
    my $sort = $self->param('sort') // 'relevance';
    my $dir  = $self->param('dir')  // 'desc';
    my $result = $svc->get_words_for_bucket($name,
        page => $page,
        per_page => $per_page,
        sort => $sort,
        dir  => $dir);
    $self->render(json => {
        words => $result->{words},
        total => $result->{total} + 0,
        page => $page,
        per_page => $per_page });
}

sub remove_bucket_word ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $svc = $self->popfile_svc;
    my $word = $svc->get_word_by_id($self->param('word_id'));
    return $self->render(status => 404, json => { error => 'word not found' })
        unless defined $word;
    $svc->remove_word_from_bucket($name, $word);
    $self->render(json => { ok => \1 });
}

sub move_bucket_word ($self) {
    my $name = _bucket_or_404($self, $self->param('id'));
    return
        unless defined $name;
    my $body = $self->req->json // {};
    my $to_id = $body->{to_id};
    return $self->render(status => 400, json => { error => 'to_id required' })
        unless defined $to_id;
    my $to = _bucket_or_404($self, $to_id);
    return
        unless defined $to;
    my $svc = $self->popfile_svc;
    my $word = $svc->get_word_by_id($self->param('word_id'));
    return $self->render(status => 404, json => { error => 'word not found' })
        unless defined $word;
    $svc->move_word_between_buckets($name, $to, $word);
    $self->render(json => { ok => \1 });
}

sub list_stopwords ($self) {
    my @words = sort $self->popfile_svc->get_stopword_list();
    $self->render(json => \@words);
}

sub list_stopword_candidates ($self) {
    my $svc = $self->popfile_svc;
    my $ratio = ($self->param('ratio') // 5.0) + 0;
    my $limit = ($self->param('limit') // 50) + 0;
    $ratio = 2.0 if $ratio <= 1;
    $limit = 50 if $limit < 1 || $limit > 500;
    my @candidates = $svc->get_stopword_candidates($ratio, $limit);
    $self->render(json => \@candidates);
}

sub search_words ($self) {
    my $svc = $self->popfile_svc;
    my $q = $self->param('q') // '';
    my $bucket = $self->param('bucket') // '';
    my $sort = $self->param('sort') // 'word';
    my $dir = $self->param('dir') // 'asc';
    my $page = ($self->param('page') // 1) + 0;
    my $per_page = ($self->param('per_page') // 50) + 0;
    $self->render(json => $svc->search_words_cross_bucket(
        $q,
        bucket => $bucket, sort => $sort, dir => $dir, page => $page, per_page => $per_page));
}

1;
