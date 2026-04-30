package TestMocks;
use v5.38;
use warnings;

=head1 NAME

TestMocks — mock objects for POPFile mojo controller tests that need
isolation from real database or IMAP services.

=head1 SYNOPSIS

    use TestMocks;

    my $svc  = TestMocks::MockSvc->new(buckets => { ham => '#aaffaa' });
    my $hist = TestMocks::MockHist->new(slots => \%slots);
    my $imap = TestMocks::MockImap->new();
    my $mq   = TestMocks::StubMQ->new();

=cut

package TestMocks::MockSvc;

sub new ($class, %args) {
    bless {
        buckets => $args{buckets} // {},
        hist    => $args{hist},
        remove_log => [],
        add_log    => [],
        %args
    }, $class
}

sub history_obj ($self)          { $self->{hist} }
sub get_all_buckets ($self)       { keys $self->{buckets}->%* }
sub is_bucket ($self, $n)         { exists $self->{buckets}{$n} }
sub get_bucket_color ($self, $n)  { $self->{buckets}{$n} // '#666666' }
sub is_pseudo_bucket ($self, $n)  { 0 }
sub get_bucket_word_count ($self, $n) { 0 }
sub classify ($self, $file)       { 'ham' }
sub get_word_colors ($self, @w)   { () }
sub mangle_word ($self, $w)       { lc $w }

sub create_bucket ($self, $name) {
    return 0
        if exists $self->{buckets}{$name};
    $self->{buckets}{$name} = '#666666';
    return 1
}

sub add_message_to_bucket ($self, $bucket, $file) {
    push $self->{add_log}->@*, { bucket => $bucket, file => $file };
}

sub remove_message_from_bucket ($self, $bucket, $file) {
    push $self->{remove_log}->@*, { bucket => $bucket, file => $file };
}

package TestMocks::MockHist;

sub new ($class, %args) {
    bless { slots => $args{slots} // {}, mid_log => [], queries => {}, next_qid => 1, %args }, $class
}

sub get_search_queries ($self, %args) {
    my $bucket   = $args{bucket} // '';
    my $search   = $args{search} // '';
    my $page     = $args{page}   // 1;
    my $per_page = $args{per_page} // 25;
    my @ids = sort { $a <=> $b } grep {
        my $s = $self->{slots}{$_};
        ($bucket eq '' || $s->{bucket} eq $bucket)
            && ($search eq '' || $s->{fields}[1] =~ /\Q$search\E/i
                || $s->{fields}[4] =~ /\Q$search\E/i)
    } keys $self->{slots}->%*;
    my $total  = scalar @ids;
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
    $self->{slots}{$slot}{bucket}     = $class;
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
