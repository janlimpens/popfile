# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::Configuration;

=head1 NAME

POPFile::Configuration - manage POPFile configuration parameters

=head1 DESCRIPTION

Loads and saves C<popfile.cfg>, manages all registered configuration
parameters across POPFile modules, and parses the command line.

Individual modules register parameters via C<config()> / C<global_config()>
(inherited from L<POPFile::Module>).  C<POPFile::Configuration> stores the
canonical values and persists them to disk.  It also handles upgrading old
parameter names from earlier POPFile releases.

=cut

use Object::Pad;
use locale;

use File::Copy qw(copy);
use Getopt::Long;

class POPFile::Configuration
    :isa(POPFile::Module);

field %configuration_parameters;
field $pid_file = '';
field $pid_check = 0;
field $save_needed :reader :writer = 0;
field $started :reader :writer = 0;
field $popfile_root :reader :writer = $ENV{POPFILE_ROOT} || './';
field $popfile_user :reader :writer = $ENV{POPFILE_USER} || './';
field %deprecated_parameters;

BUILD {
    $pid_check = time;
    $self->set_name('config');
}

=head2 initialize

Registers default configuration values and subscribes to the C<TICKD>
message for periodic saves.

=cut

method initialize() {
    $self->config('piddir', './');
    $self->config('pidcheck_interval', 5);
    $self->global_config('timeout', 60);
    $self->global_config('msgdir', 'messages/');
    $self->global_config('message_cutoff', 100000);
    $self->mq_register('TICKD', $self);
    return 1;
}

=head2 start

Writes the PID file and aborts startup if another POPFile instance is
already running.  Returns 1 on success, 0 if a live instance was detected.

=cut

method start() {
    $started = 1;
    $pid_file = $self->get_user_path($self->config('piddir') . 'popfile.pid', 0);
    if (defined($self->live_check())) {
        return 0;
    }
    $self->write_pid();
    return 1;
}

=head2 service

Periodically checks the PID file and rewrites it if it has been removed
(e.g. by a signal from another instance).  Returns 1 normally.

=cut

method service() {
    my $time = time;
    if ($self->config('pidcheck_interval') > 0) {
        if ($pid_check <= ($time - $self->config('pidcheck_interval'))) {
            $pid_check = $time;
            if (!$self->check_pid()) {
                $self->write_pid();
                $self->log_msg(WARN => "New POPFile instance detected and signalled");
            }
        }
    }
    return 1;
}

=head2 stop

Saves the configuration to disk and deletes the PID file.

=cut

method stop() {
    $self->save_configuration();
    $self->delete_pid();
}

=head2 deliver

Handles the C<TICKD> message by saving the configuration to disk (no-op if
no parameter has changed since the last save).

=cut

method deliver ($type, @message) {
    if ($type eq 'TICKD') {
        $self->save_configuration();
    }
}

=head2 live_check

Checks whether another POPFile instance is running by reading the existing
PID file.  Waits up to C<pidcheck_interval * 2> seconds for the other
instance to respond.  Returns the PID of the running instance, or C<undef>
if none.

=cut

method live_check() {
    if ($self->check_pid()) {
        my $oldpid = $self->get_pid();
        my $wait_time = $self->config('pidcheck_interval') * 2;
        my $error = "\n\nA copy of POPFile appears to be running.\n Attempting to signal the previous copy.\n Waiting $wait_time seconds for a reply.\n";
        $self->delete_pid();
        print STDERR $error;
        select(undef, undef, undef, $wait_time);
        my $pid = $self->get_pid();
        if (defined($pid)) {
            $error = "\n A copy of POPFile is running.\n It has signaled that it is alive with process ID: $pid\n";
            print STDERR $error;
            return $pid;
        } else {
            print STDERR "\nThe other POPFile ($oldpid) failed to signal back, starting new copy ($$)\n";
        }
    }
    return undef;
}

=head2 check_pid

Returns true if the PID file exists on disk.

=cut

method check_pid() {
    return (-e $pid_file);
}

=head2 get_pid

Returns the process ID stored in the PID file, or C<undef> if the file
cannot be read.

=cut

method get_pid() {
    if (open my $pid_fh, '<', $pid_file) {
        my $pid = <$pid_fh>;
        $pid =~ s/[\r\n]//g;
        close $pid_fh;
        return $pid;
    }
    return undef;
}

=head2 write_pid

Writes the current process ID (C<$$>) to the PID file.

=cut

method write_pid() {
    if (open my $pid_fh, '>', $pid_file) {
        print $pid_fh "$$\n";
        close $pid_fh;
    }
}

=head2 delete_pid

Removes the PID file from disk.

=cut

method delete_pid() {
    unlink($pid_file);
}

=head2 parse_command_line

Parses C<@ARGV> using L<Getopt::Long>.  Accepts C<--set key=value> pairs and
legacy positional C<-key value> pairs.  Updates matching registered
parameters.  Returns 1 on success, 0 on parse error.

=cut

method parse_command_line() {
    my @set_options;
    if (!GetOptions("set=s" => \@set_options)) {
        return 0;
    }
    my @options;
    for my $i (0..$#set_options) {
        $set_options[$i] =~ /-?(.+)=(.+)/;
        if (!defined($1)) {
            print STDERR "\nBad option: $set_options[$i]\n";
            return 0;
        }
        push @options, ("-$1");
        if (defined($2)) {
            push @options, ($2);
        }
    }
    push @options, @ARGV;
    if (@options)  {
        my $i = 0;
        while ($i <= $#options )  {
            if ($options[$i] =~ /^-(.+)$/) {
                my $parameter = $self->upgrade_parameter($1);
                if (defined($configuration_parameters{$parameter})) {
                    if ($i < $#options ) {
                        $self->parameter($parameter, $options[$i+1]);
                        $i += 2;
                    } else {
                        print STDERR "\nMissing argument for $options[$i]\n";
                        return 0;
                    }
                } else {
                    print STDERR "\nUnknown option $options[$i]\n";
                    return 0;
                }
            } else {
                print STDERR "\nExpected a command line option and got $options[$i]\n";
                return 0;
            }
        }
    }
    return 1;
}

=head2 upgrade_parameter

Given a legacy parameter name (from the command line or an old config file),
returns the current canonical name.  Returns the input unchanged if no
upgrade mapping exists.

=cut

method upgrade_parameter ($parameter) {
    my %upgrades = (
        corpus => 'bayes_corpus',
        unclassified_probability => 'bayes_unclassified_probability',

        piddir => 'config_piddir',

        debug => 'GLOBAL_debug',
        msgdir => 'GLOBAL_msgdir',
        timeout => 'GLOBAL_timeout',

        logdir => 'logger_logdir',

        localpop => 'pop3_local',
        port => 'pop3_port',
        sport => 'pop3_secure_port',
        server => 'pop3_secure_server',
        separator => 'pop3_separator',
        toptoo => 'pop3_toptoo',

        language => 'api_locale',
        html_language => 'api_locale',

        archive => 'history_archive',
        archive_classes => 'history_archive_classes',
        archive_dir => 'history_archive_dir',
        history_days => 'history_history_days',
        html_archive => 'history_archive',
        html_archive_classes => 'history_archive_classes',
        html_archive_dir => 'history_archive_dir',
        html_history_days => 'history_history_days',
    );
    if (defined($upgrades{$parameter})) {
        return $upgrades{$parameter};
    } else {
        return $parameter;
    }
}

=head2 load_configuration

Reads C<popfile.cfg> and populates the configuration hash.  Unknown
parameters (no longer registered by any module) are preserved in a
deprecated-parameters store so they are not silently lost on the next save.

=cut

method load_configuration() {
    $started = 1;
    my $config_file = $self->get_user_path('popfile.cfg');
    my $sample_file = $self->get_root_path('popfile.cfg.sample');
    if (!-e $config_file && -e $sample_file) {
        copy($sample_file, $config_file);
    }
    if (open my $config, '<', $config_file) {
        while (<$config>) {
            s/(\015|\012)//g;
            if (/(\S+) (.+)?/) {
                my $parameter = $1;
                my $value = $2;
                $value = '' if !defined($value);
                $parameter = $self->upgrade_parameter($parameter);
                if (defined($configuration_parameters{$parameter})) {
                    $configuration_parameters{$parameter}{value} = $value;
                } else {
                    $deprecated_parameters{$parameter} = $value;
                }
            }
        }
        close $config;
    } else {
        if (-e $config_file && !-r _) {
            $self->log_msg(WARN => "Couldn't load from the configuration file $config_file");
        }
    }
    $save_needed = 0;
}

=head2 save_configuration

Writes all registered parameters to C<popfile.cfg> (via a temporary file to
avoid corruption).  Does nothing if no parameter has changed since the last
save (C<save_needed> is 0).

=cut

method save_configuration() {
    return if $save_needed == 0;
    my $config_file = $self->get_user_path('popfile.cfg');
    my $config_temp = $self->get_user_path('popfile.cfg.tmp');
    if (-e $config_file && !-w _) {
        $self->log_msg(WARN => "Can't write to the configuration file $config_file");
        return
    }
    if (open my $tmp, '>', $config_temp) {
        foreach my $key (sort keys %configuration_parameters) {
            print $tmp "$key $configuration_parameters{$key}{value}\n";
        }
        close $tmp;
        if (copy($config_temp, $config_file)) {
            unlink $config_temp;
            $save_needed = 0;
        } else {
            $self->log_msg(WARN => "Couldn't write configuration to $config_file: $!");
        }
    } else {
        $self->log_msg(WARN => "Couldn't open a temporary configuration file $config_temp");
    }
}

=head2 get_user_path

    my $path = $self->get_user_path($relative_path);
    my $path = $self->get_user_path($relative_path, $sandbox);

Resolves C<$relative_path> relative to C<POPFILE_USER>.  When C<$sandbox>
is true (the default), absolute paths and paths containing C<..> are
rejected.

=cut

method get_user_path ($path, $sandbox = undef) {
    return $self->path_join($popfile_user, $path, $sandbox);
}

=head2 get_root_path

Like L</get_user_path> but resolves relative to C<POPFILE_ROOT>.

=cut

method get_root_path ($path, $sandbox = undef) {
    return $self->path_join($popfile_root, $path, $sandbox);
}

=head2 path_join

    my $full = $self->path_join($left, $right);
    my $full = $self->path_join($left, $right, $sandbox);

Concatenates two path segments.  When C<$sandbox> is true (the default),
returns C<undef> and logs a warning if C<$right> is absolute or contains
C<..>.

=cut

method path_join ($left, $right, $sandbox = undef) {
    $sandbox = 1 if (!defined($sandbox));
    if (($right =~ /^\//) ||
         ($right =~ /^[A-Za-z]:[\/\\]/) ||
         ($right =~ /\\\\/ ) ) {
        if ( $sandbox ) {
            $self->log_msg(WARN => "Attempt to access path $right outside sandbox" );
            return undef;
        } else {
            return $right;
        }
    }
    if ( $sandbox && ( $right =~ /\.\./)) {
        $self->log_msg(WARN => "Attempt to access path $right outside sandbox");
        return undef;
    }
    $left  =~ s/\/$//;
    $right =~ s/^\///;
    return "$left/$right";
}

=head2 parameter

    my $val = $self->parameter($name);
    $self->parameter($name, $new_value);

Gets or sets a configuration parameter by its fully-qualified name (e.g.
C<pop3_port>).  Setting a value before C<start()> is called also updates the
default.  Returns the current value, or C<undef> if the parameter is not
registered.

=cut

method parameter ($name, $value = undef) {
    if (defined($value)) {
        if ($started && $name =~ /^imap_(hostname|login|password)$/ && $value eq '') {
            require Carp;
            Carp::cluck("CONFIG_DIAG: $name set to empty after load");
        }
        $save_needed = 1;
        $configuration_parameters{$name}{value} = $value;
        if ($started == 0) {
            $configuration_parameters{$name}{default} = $value;
        }
    }
    if (defined($configuration_parameters{$name})) {
        return $configuration_parameters{$name}{value};
    } else {
        return undef;
    }
}

=head2 is_default

    my $bool = $self->is_default($name);

Returns true if the named parameter still holds its registered default value.

=cut

method is_default ($name) {
    return ($configuration_parameters{$name}{value} eq
             $configuration_parameters{$name}{default});
}

=head2 configuration_parameters

Returns a sorted list of all registered parameter names.

=cut

method configuration_parameters() {
    return sort keys %configuration_parameters;
}

=head2 deprecated_parameter

    my $val = $self->deprecated_parameter($name);

Returns the value of a parameter that was present in C<popfile.cfg> but is
no longer registered by any module, or C<undef> if it was never seen.

=cut

method deprecated_parameter ($name) {
    return $deprecated_parameters{$name};
}

1;
