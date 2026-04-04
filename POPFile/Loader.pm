# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::Loader;

=head1 NAME

POPFile::Loader - discover, load, link, and drive all POPFile modules

=head1 DESCRIPTION

C<POPFile::Loader> is the central orchestrator for the POPFile engine.
It scans module directories, instantiates every L<POPFile::Loadable>
module it finds, wires them together, and drives them through the standard
lifecycle: C<initialize()> → C<start()> → C<service()> loop → C<stop()>.

Methods whose names begin with C<CORE_> are reserved for use by the main
entry point (C<popfile.pl>).  All other methods may be called by
POPFile-based utilities that need to load a subset of modules.

=cut

use Object::Pad;
use locale;

use Getopt::Long qw(:config pass_through);
use IO::Handle;
use Log::Any ();

class POPFile::Loader;

field %components;
field $alive = 1;
field $debug = 1;
field $shutdown = 0;
field $aborting = '';
field $pipeready = '';
field $forker = '';
field $reaper = '';
field $childexit = '';
field $warning = '';
field $die_cb = '';
field $version_string = '';
field $popfile_root = './';

=head2 CORE_loader_init

Reads C<POPFILE_ROOT> from the environment, sets up internal signal/fork
callback references, loads the version string from C<VERSION>, and
processes the C<--shutdown> command-line flag.

=cut

method CORE_loader_init() {
    if (defined $ENV{POPFILE_ROOT}) {
        $popfile_root = $ENV{POPFILE_ROOT};
    }

    $aborting  = sub { $self->CORE_aborting(@_) };
    $pipeready = sub { $self->pipeready(@_) };
    $forker    = sub { $self->CORE_forker(@_) };
    $reaper    = sub { $self->CORE_reaper(@_) };
    $childexit = sub { $self->CORE_childexit(@_) };
    $warning   = sub { $self->CORE_warning(@_) };
    $die_cb    = sub { $self->CORE_die(@_) };

    my $version_file = $self->root_path('VERSION');

    if (-e $version_file) {
        open my $fh, '<', $version_file;
        my $v = <$fh>;
        close $fh;
        chomp $v;
        $self->CORE_version($v);
    }

    GetOptions('shutdown' => \$shutdown);

    print "\nPOPFile Engine loading\n" if $debug;
}

=head2 CORE_aborting

Signal handler for C<SIGQUIT>, C<SIGTERM>, etc.  Sets the C<alive> flag
to 0 on both the loader and every loaded module, causing the service loop
to exit at the next iteration.

=cut

method CORE_aborting {
    $alive = 0;
    for my $type (sort keys %components) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->set_alive(0);
        }
    }
}

=head2 pipeready

    my $bool = $self->pipeready($pipe_handle);

Returns 1 if data is available to be read on C<$pipe_handle> (non-blocking
C<select> with a 10 ms timeout), 0 otherwise.

=cut

method pipeready ($pipe) {
    return 0 if !defined $pipe;

    my $rin = '';
    vec($rin, fileno($pipe), 1) = 1;
    my $ready = select($rin, undef, undef, 0.01);
    return ($ready > 0);
}

=head2 CORE_reaper

C<SIGCHLD> handler.  Calls C<reaper()> on every module so each can wait
for its own child processes, then reinstalls itself.

=cut

method CORE_reaper {
    for my $type (sort keys %components) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->reaper();
        }
    }

    $SIG{CHLD} = $reaper;
}

=head2 CORE_childexit

    $self->CORE_childexit($exit_code);

Called by a module running inside a forked child when it wants to exit.
Notifies all other modules in the same process by calling their
C<childexit()> methods, then calls C<exit($exit_code)>.

=cut

method CORE_childexit ($code) {
    for my $type (sort keys %components) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->childexit();
        }
    }

    exit $code;
}

=head2 CORE_forker

Forks the POPFile process.  Calls C<prefork()> on all modules before
forking, C<forked()> on all modules in the child, and C<postfork()> on all
modules in the parent.  Returns C<($pid, $pipe_handle)>: C<$pid == 0> in
the child (with the write end of the pipe), non-zero in the parent (with
the read end).

=cut

method CORE_forker() {
    my @types = sort keys %components;

    for my $type (@types) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->prefork();
        }
    }

    pipe my $reader, my $writer;
    my $pid = fork();

    if (!defined $pid) {
        close $reader;
        close $writer;
        return (undef, undef);
    }

    if ($pid == 0) {
        for my $type (@types) {
            for my $name (sort keys $components{$type}->%*) {
                $components{$type}{$name}->forked($writer);
            }
        }
        close $reader;
        $writer->autoflush(1);
        return (0, $writer);
    }

    for my $type (@types) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->postfork($pid, $reader);
        }
    }

    close $writer;
    return ($pid, $reader);
}

=head2 CORE_warning

C<__WARN__> handler.  Logs the warning via L<Log::Any> and re-emits it
when the global debug level is greater than 0.

=cut

method CORE_warning (@message) {
    if ($self->module_config('GLOBAL', 'debug') > 0) {
        Log::Any->get_logger(category => 'POPFile')->warning("Perl warning: @message");
        warn @message;
    }
}

=head2 CORE_die

C<__DIE__> handler.  Ignored inside C<eval> blocks (C<$^S> is set).
Otherwise logs the error, calls L</CORE_stop> for a graceful shutdown, and
exits with code 1.

=cut

method CORE_die (@message) {
    return if $^S;

    print STDERR @message;

    if ($self->module_config('GLOBAL', 'debug') > 0) {
        Log::Any->get_logger(category => 'POPFile')->error("Perl fatal error: @message");
    }

    $self->CORE_stop();
    exit 1;
}

=head2 CORE_load_directory_modules

    $self->CORE_load_directory_modules($directory, $type);

Scans C<$directory> (relative to C<POPFILE_ROOT>) for C<*.pm> files and
calls L</CORE_load_module> on each one, registering them under C<$type>
in the component table.

=cut

method CORE_load_directory_modules ($directory, $type) {
    print "\n         {$type:" if $debug;

    opendir my $dh, $self->root_path($directory);

    while (my $entry = readdir $dh) {
        if ($entry =~ /\.pm$/) {
            $self->CORE_load_module("$directory/$entry", $type);
        }
    }

    closedir $dh;

    print '} ' if $debug;
}

=head2 CORE_load_module

    my $mod = $self->CORE_load_module($module_path, $type);

Loads a single module via L</load_module> and registers it in the
component table under C<$type>.  Returns the module handle, or C<undef>
on failure.

=cut

method CORE_load_module ($module, $type) {
    my $mod = $self->load_module($module);

    if (defined $mod) {
        my $name = $mod->name();
        print " $name" if $debug;
        $components{$type}{$name} = $mod;
    }
    return $mod;
}

=head2 load_module

    my $mod = $self->load_module($module_path);

Loads a single C<*.pm> file, instantiates the class it defines, and
returns the object if it does the L<POPFile::Loadable> role.  Returns
C<undef> if the file does not exist, fails to compile, or is not a
loadable module.  Has no side-effects on the component table.

=cut

method load_module ($module) {
    return
        unless -f $self->root_path($module);
    require $module;
    (my $class = $module) =~ s/\//::/g;
    $class =~ s/\.pm$//;
    my $mod = eval { $class->new() };
    return
        if $@;
    return $mod->DOES('POPFile::Loadable') ? $mod : undef
}

=head2 CORE_signals

Installs signal handlers for C<SIGQUIT>, C<SIGTERM>, C<SIGINT>, etc.
C<SIGALRM> and C<SIGPIPE> are ignored.  Returns C<%SIG>.

=cut

method CORE_signals() {
    $SIG{QUIT} = $aborting;
    $SIG{ABRT} = $aborting;
    $SIG{KILL} = $aborting;
    $SIG{STOP} = $aborting;
    $SIG{TERM} = $aborting;
    $SIG{INT}  = $aborting;
    $SIG{CHLD} = $reaper;
    $SIG{ALRM} = 'IGNORE';
    $SIG{PIPE} = 'IGNORE';
    $SIG{__WARN__} = $warning;
    $SIG{__DIE__}  = $die_cb;

    return $SIG;
}

=head2 CORE_load

    $self->CORE_load();
    $self->CORE_load($noserver);

Loads all module directories.  When C<$noserver> is 1, the C<UI>, C<Proxy>,
and C<Services> directories are skipped (useful for CLI utilities).

=cut

method CORE_load ($noserver = 0) {
    print "\n    Loading... " if $debug;

    $self->CORE_load_directory_modules(POPFile => 'core');
    $self->CORE_load_directory_modules(Classifier => 'classifier');

    if (!$noserver) {
        $self->CORE_load_directory_modules(UI => 'interface');
        $self->CORE_load_directory_modules(Proxy => 'proxy');
        $self->CORE_load_directory_modules(Services => 'services');
    }
}

=head2 CORE_link_components

Wires loaded modules together: injects the configuration, MQ, version
string, classifier, history, classifier service, and database service into
every module that accepts them.

=cut

method CORE_link_components() {
    print "\n\nPOPFile Engine $version_string starting" if $debug;

    for my $type (sort keys %components) {
        for my $name (sort keys $components{$type}->%*) {
            $components{$type}{$name}->set_version(
                scalar($self->CORE_version()));
            $components{$type}{$name}->set_configuration(
                $components{core}{config});
            $components{$type}{$name}->set_mq(
                $components{core}{mq});
        }
    }

    for my $type (sort keys %components) {
        for my $name (sort keys $components{$type}->%*) {
            my $mod = $components{$type}{$name};
            $mod->set_classifier($components{classifier}{bayes})
                if $mod->can('set_classifier');
            $mod->set_history($components{core}{history})
                if $mod->can('set_history');
        }
    }

    if (defined $components{services}{classifier_service}) {
        my $svc = $components{services}{classifier_service};

        for my $name (sort keys $components{proxy}->%*) {
            my $mod = $components{proxy}{$name};
            $mod->set_service($svc) if $mod->can('set_service');
        }
        for my $name (sort keys $components{interface}->%*) {
            my $mod = $components{interface}{$name};
            $mod->set_service($svc) if $mod->can('set_service');
        }
    }

    $components{core}{history}->set_classifier(
        $components{classifier}{bayes});
    $components{classifier}{bayes}->set_history(
        $components{core}{history});

    $components{classifier}{bayes}->parser()->set_mangle(
        $components{classifier}{wordmangle});

    if (defined $components{services}{database}) {
        my $db_svc = $components{services}{database};
        foreach my $type (sort keys %components) {
            foreach my $name (sort keys $components{$type}->%*) {
                $components{$type}{$name}->set_db_service($db_svc)
                    if $components{$type}{$name}->can('set_db_service');
            }
        }
    }
}

=head2 CORE_initialize

Calls C<initialize()> on every loaded module in dependency order (core
first, then all others).  Dies if any module returns 0.

=cut

method CORE_initialize() {
    print "\n\n    Initializing... " if $debug;

    my @c = ('core', grep { !/^core$/ } sort keys %components);

    for my $type (@c) {
        print "\n         {$type:" if $debug;
        for my $name (sort keys $components{$type}->%*) {
            print " $name" if $debug;
            STDOUT->flush();

            my $mod  = $components{$type}{$name};
            my $code = $mod->initialize();

            if ($code == 0) {
                die "Failed to start while initializing the $name module";
            }

            if ($code == 1) {
                $mod->set_alive(1);
                $mod->set_forker($forker);
                $mod->setchildexit($childexit);
                $mod->set_pipeready($pipeready);
            }
        }
        print '} ' if $debug;
    }
    print "\n" if $debug;
}

=head2 CORE_config

Loads C<popfile.cfg> and applies command-line overrides.  Returns 1 on
success, 0 if command-line parsing failed.

=cut

method CORE_config() {
    $components{core}{config}->load_configuration();
    return $components{core}{config}->parse_command_line();
}

=head2 CORE_start

Calls C<start()> on every loaded module in dependency order (core,
classifier, services first; then the rest).  Modules that return 2 are
silently removed.  Dies if any module returns 0.

=cut

method CORE_start() {
    print "\n    Starting...     " if $debug;

    my @c = ('core', 'classifier', 'services',
              grep { !/^(core|classifier|services)$/ } sort keys %components);

    for my $type (@c) {
        print "\n         {$type:" if $debug;
        for my $name (sort keys $components{$type}->%*) {
            my $code = $components{$type}{$name}->start();

            if ($code == 0) {
                die "Failed to start while starting the $name module";
            }

            if ($code == 2) {
                delete $components{$type}{$name};
            } else {
                print " $name" if $debug;
                STDOUT->flush();
            }
        }
        print '} ' if $debug;
    }

    print "\n\nPOPFile Engine ", scalar($self->CORE_version()), " running\n"
        if $debug;
    STDOUT->flush();
}

=head2 CORE_service

    $self->CORE_service();
    $self->CORE_service($nowait);

The main service loop.  Calls C<service()> on every module; exits the loop
if any module returns 0 or if C<$alive> becomes 0.  Sleeps 50 ms between
rounds unless C<$nowait> is 1, in which case it runs exactly one round and
returns.  Returns the final value of C<$alive>.

=cut

method CORE_service ($nowait = 0) {
    while ($alive == 1) {
        for my $type (sort keys %components) {
            for my $name (sort keys $components{$type}->%*) {
                if ($components{$type}{$name}->service() == 0) {
                    $alive = 0;
                    last;
                }
            }
        }

        select(undef, undef, undef, 0.05) if !$nowait;

        last if $nowait;

        if ($shutdown == 1) {
            $alive = 0;
        }
    }

    return $alive;
}

=head2 CORE_stop

Stops all loaded modules.  The MQ and history modules are stopped first so
they can flush pending state; all others follow in sorted order.

=cut

method CORE_stop() {
    if ($debug) {
        print "\n\nPOPFile Engine $version_string stopping\n";
        STDOUT->flush();
        print "\n    Stopping... ";
    }

    $components{core}{mq}->set_alive(0);
    $components{core}{mq}->stop();
    $components{core}{history}->set_alive(0);
    $components{core}{history}->stop();

    for my $type (sort keys %components) {
        print "\n         {$type:" if $debug;
        for my $name (sort keys $components{$type}->%*) {
            print " $name" if $debug;
            STDOUT->flush();

            next if $name eq 'mq';
            next if $name eq 'history';
            $components{$type}{$name}->set_alive(0);
            $components{$type}{$name}->stop();
        }
        print '} ' if $debug;
    }

    print "\n\nPOPFile Engine $version_string terminated\n"
        if $debug;
}

=head2 CORE_version

    my $v = $self->CORE_version();
    $self->CORE_version($v);

Gets or sets the POPFile version string (read from the C<VERSION> file
during L</CORE_loader_init>).

=cut

method CORE_version ($v = undef) {
    return $version_string
        unless defined $v;
    $version_string = $v;
}

=head2 get_module

    my $mod = $self->get_module('Classifier::Bayes');
    my $mod = $self->get_module($name, $type);

Looks up a loaded module by name and type.  When called with a single
C<Namespace::Name> argument the namespace is mapped to an internal type
(C<POPFile> → C<core>, C<UI> → C<interface>).

=cut

method get_module ($name, $type = undef) {
    if (!defined($type) && $name =~ /^(.*)::(.*)$/) {
        $type = lc $1;
        $name = lc $2;
        $type =~ s/^popfile$/core/i;
        $type =~ s/^ui$/interface/i;
    }

    return $components{$type}{$name};
}

=head2 set_module

    $self->set_module($type, $name, $module);

Inserts C<$module> into the component table under C<$type> / C<$name>.
Useful in tests that need to inject mock modules.

=cut

method set_module ($type, $name, $module) {
    $components{$type}{$name} = $module;
}

=head2 remove_module

    $self->remove_module($type, $name);

Calls C<stop()> on the named module and removes it from the component table.

=cut

method remove_module ($type, $name) {
    $components{$type}{$name}->stop();
    delete $components{$type}{$name};
}

=head2 root_path

    my $full = $self->root_path($relative_path);

Joins C<$relative_path> with C<POPFILE_ROOT>, normalising directory
separators.

=cut

method root_path ($path) {
    $popfile_root =~ s/[\/\\]$//;
    $path         =~ s/^[\/\\]//;

    return "$popfile_root/$path";
}

=head2 debug

    my $val = $self->debug();
    $self->debug($val);

Gets or sets the debug flag.  When set to 1 (the default) the loader
prints progress messages to C<STDOUT> during startup and shutdown.

=cut

method debug ($val = undef) {
    $debug = $val if defined $val;
    return $debug;
}

=head2 module_config

    my $val = $self->module_config($module, $item);
    $self->module_config($module, $item, $value);

Thin proxy to C<< POPFile::Configuration->module_config() >>.

=cut

method module_config ($module, $item, $value = undef) {
    return $components{core}{config}->module_config($module, $item, $value);
}

1;
