# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Logger;

use Object::Pad;
use locale;
use File::Path qw(make_path);
use Log::Any::Adapter;
use POPFile::Log::Adapter;

my $seconds_per_day = 60 * 60 * 24;

class POPFile::Logger :isa(POPFile::Module);

=head1 NAME

POPFile::Logger — file and stdout logger backed by Log::Any

=head1 DESCRIPTION

C<POPFile::Logger> manages log output for the entire POPFile process.  It
configures a L<POPFile::Log::Adapter> instance (a L<Log::Any> adapter) that
writes timestamped lines to a daily rotating log file and/or standard output
depending on the C<debug> global config flag.

Log files are named C<popfileNNNNN.log> where C<NNNNN> is the Unix timestamp
of midnight for that day.  Files older than three days are pruned automatically
on the C<TICKD> message-queue event.

The module also maintains a ten-line ring buffer of recent log lines accessible
via C<last_ten()>, used by the web UI to show recent activity.

=head1 METHODS

=cut

field $debug_filename = '';
field $last_tickd = 0;
field $today = 0;

BUILD {
    $self->set_name('logger');
}

=head2 initialize()

Registers logger configuration: C<logdir> (platform-specific default),
C<format> (C<'default'>), C<level> (0), C<log_to_stdout> (0), C<log_sql>
(0), and the C<debug> global config flag (1).  Registers for the C<TICKD>
message-queue event.  Returns 1.

=cut

method initialize() {
    $self->global_config('debug', 1);
    $self->config('logdir', $self->_default_log_dir());
    $self->config('format', 'default');
    $self->config('level', 0);
    $self->config('log_to_stdout', 0);
    $self->config('log_sql', 0);
    $last_tickd = time;
    $self->mq_register('TICKD', $self);
    return 1
}

method _default_log_dir() {
    if ($^O eq 'MSWin32') {
        my $base = $ENV{LOCALAPPDATA} // $ENV{APPDATA} // $ENV{USERPROFILE} // '.';
        return $base . '\\POPFile\\Logs\\';
    }
    return ($ENV{HOME} // '.') . '/Library/Logs/POPFile/'
        if $^O eq 'darwin';
    my $state = $ENV{XDG_STATE_HOME} // (($ENV{HOME} // '') . '/.local/state');
    return $state . '/popfile/'
}

=head2 deliver($type, @message)

Message-queue handler.  On C<TICKD> events calls C<remove_debug_files()>
to prune old log files.

=cut

method deliver ($type, @message) {
    $self->remove_debug_files()
        if $type eq 'TICKD';
}

=head2 start()

Creates the log directory if necessary, computes today's log filename, and
installs the L<POPFile::Log::Adapter>.  Logs the POPFile startup message.
Returns 1.

=cut

method start() {
    my $dir = $self->get_user_path($self->config('logdir'), 0);
    make_path($dir) unless -d $dir;
    $self->calculate_today();
    $self->_reconfigure_adapter();
    Log::Any->get_logger(category => 'POPFile')->error(
        'POPFile ' . $self->version() . ' starting');
    return 1
}

=head2 stop()

Logs the POPFile shutdown message.

=cut

method stop() {
    Log::Any->get_logger(category => 'POPFile')->error('POPFile stopped');
}

=head2 service()

Called every main-loop tick.  Reconfigures the adapter and posts C<TICKD>
once per hour to trigger log-file rotation and pruning.  Returns 1.

=cut

method service() {
    $self->calculate_today();
    if ($self->time > ($last_tickd + 3600)) {
        $self->_reconfigure_adapter();
        $self->mq_post('TICKD');
        $last_tickd = $self->time;
    }
    return 1
}

=head2 time()

Returns the current Unix timestamp.  Exists as a method so tests can mock it.

=cut

method time() { return time }

=head2 calculate_today()

Updates the current log filename when the calendar day changes.  No-op if the
date has not changed since last call.

=cut

method calculate_today() {
    my $new_today = int($self->time / $seconds_per_day) * $seconds_per_day;
    return if $new_today == $today;
    $today = $new_today;
    $debug_filename = $self->get_user_path(
        $self->config('logdir') . "popfile$today.log", 0);
}

method _reconfigure_adapter() {
    my $debug = $self->global_config('debug') // 0;
    POPFile::Log::Adapter->configure(
        to_file => ($debug & 1) ? 1 : 0,
        to_stdout => (($debug & 2) || $self->config('log_to_stdout')) ? 1 : 0,
        filename => $debug_filename,
        popfile_level => $self->config('level') // 0,
        format => $self->config('format') // 'default',
);
    Log::Any::Adapter->set('+POPFile::Log::Adapter');
}

=head2 remove_debug_files()

Deletes log files in the configured C<logdir> that are more than three days
old.

=cut

method remove_debug_files() {
    my @files = glob($self->get_user_path(
        $self->config('logdir') . 'popfile*.log', 0));
    for my $f (@files) {
        if ($f =~ /popfile([0-9]+)\.log/) {
            unlink $f if $1 < ($self->time - 3 * $seconds_per_day);
        }
    }
}

=head2 debug($level, $message)

Compatibility shim for legacy callers that use POPFile's numeric level
convention (0 = error, 1 = info, 2 = debug).  Emits C<$message> at info
level if C<$level> is within the configured C<level> threshold.

=cut

method debug ($level, $message) {
    Log::Any->get_logger(category => 'POPFile')->info($message)
        if $level <= ($self->config('level') // 0);
}

=head2 debug_filename()

Returns the path of the current log file.

=cut

method debug_filename() { $debug_filename }

=head2 last_ten()

Returns the last ten log lines from the ring buffer maintained by
L<POPFile::Log::Adapter>.

=cut

method last_ten() { POPFile::Log::Adapter->ring()->@* }

1;
