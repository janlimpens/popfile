package TestHelper;

# ---------------------------------------------------------------------------
# Lightweight test harness for POPFile modules.
#
# Provides a minimal wired environment (Configuration + stub MQ)
# so individual modules can be unit-tested without the full Loader stack.
# Logging goes through Log::Any (Null adapter by default in tests).
# ---------------------------------------------------------------------------

use strict;
use warnings;
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Cwd        qw(abs_path);

# The repo root is the directory containing t/
our $REPO_ROOT = abs_path("$Bin/..");

# ---------------------------------------------------------------------------
# setup()
#
# Creates a minimal POPFile environment:
#   - A real POPFile::Configuration wired to itself (bootstrapped)
#   - A stub Logger with no-op debug()
#   - A stub MQ with no-op post() and register()
#   - A temporary user directory (cleaned up after the test)
#
# Returns ($config, $logger, $mq, $tmpdir)
# ---------------------------------------------------------------------------
sub setup {
    # Stub MQ – records posted messages but does nothing
    my $mq = bless { posted => [], registered => {} }, 'TestHelper::MQ';

    # Real Configuration, bootstrapped to itself
    require POPFile::Configuration;
    my $config = POPFile::Configuration->new();
    $config->set_configuration($config);   # Config points to itself
    $config->set_mq($mq);

    # Temp dir for user files (DB, stopwords, pid, cfg)
    my $tmpdir = tempdir( CLEANUP => 1 );
    $config->set_popfile_root($REPO_ROOT);
    $config->set_popfile_user($tmpdir);

    # Initialize registers default params; mark started so further
    # calls to parameter() don't reset defaults
    $config->initialize();
    $config->set_started(1);

    return ($config, $mq, $tmpdir);
}

# ---------------------------------------------------------------------------
# wire($module, $config, $logger, $mq)
#
# Injects the three infrastructure references into any POPFile::Module
# subclass, mirroring what Loader::CORE_link_components() does.
# ---------------------------------------------------------------------------
sub wire {
    my ($mod, $config, $mq) = @_;
    $mod->set_configuration($config);
    $mod->set_mq($mq);
    return $mod;
}

# ---------------------------------------------------------------------------
# make_module($class, $config, $logger, $mq)
#
# Convenience: require $class, construct, wire, initialize.
# Does NOT call start() – call that yourself if needed.
# ---------------------------------------------------------------------------
sub make_module {
    my ($class, $config, $mq) = @_;
    (my $file = $class) =~ s{::}{/}g;
    require "$file.pm";
    my $mod = $class->new();
    wire($mod, $config, $mq);
    $mod->initialize();
    return $mod;
}

# ---------------------------------------------------------------------------
# Stub Logger
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Stub MQ
# ---------------------------------------------------------------------------
package TestHelper::MQ;

# Synchronous MQ: deliver immediately to all registered waiters.
sub post {
    my ($self, $type, @msg) = @_;
    push @{ $self->{posted} }, { type => $type, msg => \@msg };
    for my $waiter (@{ $self->{waiters}{$type} // [] }) {
        $waiter->deliver($type, @msg);
    }
}

sub register {
    my ($self, $type, $obj) = @_;
    push @{ $self->{waiters}{$type} }, $obj;
}

1;
