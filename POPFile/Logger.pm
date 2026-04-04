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

field $debug_filename = '';
    field $last_tickd = 0;
    field $today = 0;

    BUILD {
        $self->set_name('logger');
    }

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

    method deliver ($type, @message) {
        $self->remove_debug_files()
            if $type eq 'TICKD';
    }

    method start() {
        my $dir = $self->get_user_path($self->config('logdir'), 0);
        make_path($dir) unless -d $dir;
        $self->calculate_today();
        $self->_reconfigure_adapter();
        Log::Any->get_logger(category => 'POPFile')->error(
            'POPFile ' . $self->version() . ' starting');
        return 1
    }

    method stop() {
        Log::Any->get_logger(category => 'POPFile')->error('POPFile stopped');
    }

    method service() {
        $self->calculate_today();
        if ( $self->time > ($last_tickd + 3600) ) {
            $self->_reconfigure_adapter();
            $self->mq_post('TICKD');
            $last_tickd = $self->time;
        }
        return 1
    }

    method time() { return time }

    method calculate_today() {
        my $new_today = int( $self->time / $seconds_per_day ) * $seconds_per_day;
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

    method remove_debug_files() {
        my @files = glob( $self->get_user_path(
            $self->config('logdir') . 'popfile*.log', 0) );
        for my $f (@files) {
            if ($f =~ /popfile([0-9]+)\.log/) {
                unlink $f if $1 < ($self->time - 3 * $seconds_per_day);
            }
        }
    }

    method debug ($level, $message) {
        Log::Any->get_logger(category => 'POPFile')->info($message)
            if $level <= ($self->config('level') // 0);
    }

    method debug_filename() { $debug_filename }

    method last_ten() { POPFile::Log::Adapter->ring()->@* }

1;
