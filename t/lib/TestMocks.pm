package TestMocks;
use v5.38;
use warnings;

=head1 NAME

TestMocks — canonical mock objects for POPFile mojo controller tests

=head1 SYNOPSIS

    use TestMocks;

    my $svc = TestMocks::MockSvc->new(buckets => { ham => '#aaffaa', spam => '#ffaaaa' });
    my $hist = TestMocks::MockHist->new(slots => \%slots);
    my $imap = TestMocks::MockImap->new();
    my $mq   = TestMocks::StubMQ->new();

=head1 DESCRIPTION

Single source of truth for all test mocks. Import this instead of defining
package-level mocks inline. Every controller method is stubbed; tests that
need behavioural verification can access the internal log hashes
(C<$svc-E<gt>{create_log}>, C<$imap-E<gt>{move_requests}>, etc.).

=cut

# ── MockSvc — stubs all Services::Classifier methods ──

package TestMocks::MockSvc;

sub new ($class, %args) {
    my $self = {
        buckets => $args{buckets} // {},
        hist => $args{hist},
        create_log => [],
        delete_log => [],
        rename_log => [],
        remove_log => [],
        add_log => [],
        magnet_log => [],
        magnet_delete_log => [],
        stopword_log => [],
        stopword_remove_log => [],
        move_word_log => [],
        remove_word_log => [],
        %args };
    bless $self, $class
}

sub history_obj ($self) { $self->{hist} }
sub bayes ($self) { undef }

sub get_all_buckets ($self) { keys $self->{buckets}->%* }
sub is_bucket ($self, $name) { exists $self->{buckets}{$name} }
sub is_pseudo_bucket ($self, $name) { 0 }
sub get_bucket_color ($self, $name) { $self->{buckets}{$name} // '#666666' }
sub get_bucket_word_count ($self, $name) { 0 }
sub get_bucket_parameter ($self, $name, $param) { 0 }
sub get_bucket_word_list ($self, $name, $prefix) { () }
sub get_bucket_word_prefixes ($self, $name) { () }
sub get_count_for_word ($self, $bucket, $word) { 0 }
sub get_word_count ($self) { 0 }
sub get_unique_word_count ($self) { 0 }
sub get_bucket_unique_count ($self, $name) { 0 }
sub get_buckets ($self) { keys $self->{buckets}->%* }
sub get_pseudo_buckets ($self) { () }

sub create_bucket ($self, $name) {
    push $self->{create_log}->@*, $name;
    return 0 if exists $self->{buckets}{$name};
    $self->{buckets}{$name} = '#666666';
    return 1
}
sub delete_bucket ($self, $name) {
    push $self->{delete_log}->@*, $name;
    delete $self->{buckets}{$name};
}
sub rename_bucket ($self, $old, $new) {
    push $self->{rename_log}->@*, { old => $old, new => $new };
    $self->{buckets}{$new} = delete $self->{buckets}{$old}
        if exists $self->{buckets}{$old};
}
sub clear_bucket ($self, $name) { }
sub set_bucket_color ($self, $name, $color) { $self->{buckets}{$name} = $color }
sub update_bucket_params ($self, $name, %params) { }

sub get_magnet_types ($self) { () }
sub get_buckets_with_magnets ($self) { () }
sub get_magnet_types_in_bucket ($self, $name) { () }
sub get_magnets ($self, $name, $type) { () }
sub create_magnet ($self, $bucket, $type, $val) {
    push $self->{magnet_log}->@*, { bucket => $bucket, type => $type, value => $val };
}
sub delete_magnet ($self, $bucket, $type, $val) {
    push $self->{magnet_delete_log}->@*, { bucket => $bucket, type => $type, value => $val };
}
sub clear_magnets ($self) { }
sub magnet_count ($self) { 0 }

sub add_message_to_bucket ($self, $bucket, $file) {
    push $self->{add_log}->@*, { bucket => $bucket, file => $file };
}
sub add_messages_to_bucket ($self, $bucket, @files) { }
sub remove_message_from_bucket ($self, $bucket, $file) {
    push $self->{remove_log}->@*, { bucket => $bucket, file => $file };
}
sub classify ($self, $file) { 'ham' }
sub classify_message ($self, $mail, $client, $nosave, $class, $slot, $echo, $crlf) { }
sub mangle_word ($self, $word) { lc($word) }
sub get_word_colors ($self, @words) { () }
sub get_color ($self, $word) { '#666666' }
sub set_bucket_parameter ($self, $bucket, $param, $value) { }
sub get_words_for_bucket ($self, $bucket, %opts) { { words => [], total => 0 } }
sub remove_word_from_bucket ($self, $bucket, $word) {
    push $self->{remove_word_log}->@*, { bucket => $bucket, word => $word };
}
sub move_word_between_buckets ($self, $from, $to, $word) {
    push $self->{move_word_log}->@*, { from => $from, to => $to, word => $word };
}
sub search_words_cross_bucket ($self, $prefix, %opts) { { words => [], total => 0 } }

sub add_stopword ($self, $word) {
    push $self->{stopword_log}->@*, $word;
    return 1
}
sub get_stopword_list ($self) { () }
sub remove_stopword ($self, $word) {
    push $self->{stopword_remove_log}->@*, $word;
}
sub get_stopword_candidates ($self, $ratio, $limit = 50) { () }

# ── MockHist — stubs POPFile::History methods ──

package TestMocks::MockHist;

sub new ($class, %args) {
    bless { slots => $args{slots} // {}, queries => {}, next_qid => 1, mid_log => [], %args }, $class
}

sub get_search_queries ($self, %args) {
    my $bucket = $args{bucket} // '';
    my $search = $args{search} // '';
    my $page = $args{page} // 1;
    my $per_page = $args{per_page} // 25;
    my @ids = sort { $a <=> $b } grep {
        my $s = $self->{slots}{$_};
        ($bucket eq '' || $s->{bucket} eq $bucket)
            && ($search eq '' || $s->{fields}[1] =~ /\Q$search\E/i
                || $s->{fields}[4] =~ /\Q$search\E/i)
    } keys $self->{slots}->%*;
    my $total = scalar @ids;
    my $offset = ($page - 1) * $per_page;
    my @page_ids = splice(@ids, $offset, $per_page);
    my @rows = map {
        my $f = $self->{slots}{$_}{fields};
        { slot => $f->[0], from => $f->[1], to => $f->[2], cc => $f->[3],
            subject => $f->[4], date => $f->[5], hash => $f->[6],
            inserted => $f->[7], bucket => $f->[8], usedtobe => $f->[9],
            bucket_id => $f->[10], magnet => $f->[11], size => $f->[12] }
    } @page_ids;
    return ($total, \@rows)
}

sub get_slot_file ($self, $slot) {
    return $self->{slots}{$slot}{file}
        if $self->{slots}{$slot};
    return undef
}

sub get_slot_fields ($self, $slot) {
    return ()
        unless $self->{slots}{$slot};
    return $self->{slots}{$slot}{fields}->@*
}

sub change_slot_classification ($self, $slot, $class, $session, $undo) {
    return
        unless $self->{slots}{$slot};
    $self->{slots}{$slot}{fields}[8] = $class;
    $self->{slots}{$slot}{bucket} = $class;
}

sub set_message_id ($self, $slot, $mid) {
    push $self->{mid_log}->@*, { slot => $slot, mid => $mid };
}

sub is_valid_slot ($self, $slot) {
    return exists $self->{slots}{$slot} ? 1 : undef
}

sub get_slot_from_hash ($self, $hash) { '' }

sub start_query ($self) {
    my $qid = $self->{next_qid}++;
    $self->{queries}{$qid} = { filter => '', search => '' };
    return $qid
}

sub stop_query ($self, $qid) { delete $self->{queries}{$qid} }

sub set_query ($self, $qid, $filter, $search, $sort, $not) {
    $self->{queries}{$qid}{filter} = $filter // '';
    $self->{queries}{$qid}{search} = $search // '';
}

sub get_query_size ($self, $qid) {
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @matching = grep { $filter eq '' || $self->{slots}{$_}{bucket} eq $filter }
        keys $self->{slots}->%*;
    return scalar @matching
}

sub get_query_rows ($self, $qid, $start, $count) {
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @ids = sort { $a <=> $b } grep {
        $filter eq '' || $self->{slots}{$_}{bucket} eq $filter
    } keys $self->{slots}->%*;
    my @page = splice(@ids, $start - 1, $count);
    return map { $self->{slots}{$_}{fields} } @page
}

sub reserve_slot ($self, $time) { (1, '/tmp/test.msg') }
sub release_slot ($self, $slot) { }
sub commit_slot ($self, $session, $slot, $bucket, $magnet) { }
sub delete_query ($self, $qid) { }
sub force_requery ($self) { }

# ── MockImap — stubs Services::IMAP methods ──

package TestMocks::MockImap;

sub new ($class, %args) {
    bless { move_requests => [], cached_mids => {}, %args }, $class
}

sub cache_message_id ($self, $hash, $mid) {
    $self->{cached_mids}{$hash} = $mid;
}

sub request_folder_move ($self, $hash, $target_bucket, $source_bucket = undef) {
    push $self->{move_requests}->@*, {
        hash => $hash,
        target_bucket => $target_bucket,
        source_bucket => $source_bucket };
}

sub request_folder_rescan ($self, $folder) { }

# ── StubMQ — no-op message queue ──

package TestMocks::StubMQ;

sub new ($class, %args) { bless { %args }, $class }
sub post ($self, $type, @msg) { }
sub register ($self, $type, $obj) { }

1;
