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
use feature 'signatures';
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Cwd        qw(abs_path);

our $REPO_ROOT = abs_path("$Bin/..");

# ---------------------------------------------------------------------------
# setup()
#
# Creates a minimal POPFile environment:
#   - A real POPFile::Configuration wired to itself (bootstrapped)
#   - A stub MQ with no-op post() and register()
#   - A temporary user directory (cleaned up after the test)
#
# Returns ($config, $mq, $tmpdir)
# ---------------------------------------------------------------------------
sub setup {
    my $mq = bless { posted => [], registered => {} }, 'TestHelper::MQ';

    require POPFile::Configuration;
    my $config = POPFile::Configuration->new();
    $config->set_configuration($config);
    $config->set_mq($mq);

    my $tmpdir = tempdir( CLEANUP => 1 );
    $config->set_popfile_root($REPO_ROOT);
    $config->set_popfile_user($tmpdir);

    $config->initialize();
    $config->set_started(1);

    return ($config, $mq, $tmpdir);
}

# ---------------------------------------------------------------------------
# wire($module, $config, $mq)
# ---------------------------------------------------------------------------
sub wire($mod, $config, $mq) {
    $mod->set_configuration($config);
    $mod->set_mq($mq);
    return $mod;
}

# ---------------------------------------------------------------------------
# configure_db($config)
#
# Overrides the Bayes DB connection to use an in-memory SQLite database,
# or a real DB if TEST_DBCONNECT is set in the environment.
# Must be called after Classifier::Bayes->initialize() and before start().
# ---------------------------------------------------------------------------
sub configure_db($config) {
    if ( defined $ENV{TEST_DBCONNECT} ) {
        $config->parameter('bayes_dbconnect', $ENV{TEST_DBCONNECT});
        $config->parameter('bayes_dbuser',    $ENV{TEST_DBUSER}   // '');
        $config->parameter('bayes_dbauth',    $ENV{TEST_DBAUTH}   // '');
        $config->parameter('bayes_database',  $ENV{TEST_DATABASE} // 'popfile_test');
    } else {
        $config->parameter('bayes_dbconnect', 'dbi:SQLite:dbname=:memory:');
    }
}

# ---------------------------------------------------------------------------
# make_module($class, $config, $mq)
#
# Convenience: require $class, construct, wire, initialize.
# For Classifier::Bayes, also injects a stub history and configures the DB.
# Does NOT call start() — call that yourself if needed.
# ---------------------------------------------------------------------------
sub make_module($class, $config, $mq) {
    (my $file = $class) =~ s{::}{/}g;
    require "$file.pm";
    my $mod = $class->new();
    wire($mod, $config, $mq);
    $mod->initialize();
    if ( $class eq 'Classifier::Bayes' ) {
        require Services::Database;
        my $db_svc = Services::Database->new();
        wire($db_svc, $config, $mq);
        $db_svc->initialize();
        $mod->set_db_service($db_svc);
        $mod->set_history( bless {}, 'TestHelper::History' );
        configure_db($config);
    }
    return $mod
}

# ---------------------------------------------------------------------------
# setup_bayes($config, $mq)
#
# Convenience: create and start a WordMangle + Bayes pair.
# Returns ($wm, $bayes).
# ---------------------------------------------------------------------------
sub setup_bayes($config, $mq) {
    my $wm = make_module('Classifier::WordMangle', $config, $mq);
    $wm->start();
    my $bayes = make_module('Classifier::Bayes', $config, $mq);
    $bayes->parser()->set_mangle($wm);
    $bayes->start();
    return ($wm, $bayes)
}

# ---------------------------------------------------------------------------
# reset_db($bayes, $config)
#
# Truncates all user-generated data from the test database, leaving only
# the schema seed rows (admin user, pseudo-buckets, magnet sentinel, etc.).
# Returns a fresh session key.
# ---------------------------------------------------------------------------
sub reset_db($bayes, $config) {
    my $db = $bayes->db();
    $db->do('delete from history');
    $db->do('delete from matrix');
    $db->do('delete from words');
    $db->do('delete from bucket_params');
    $db->do('delete from user_params');
    $db->do('delete from magnets where id != 0');
    $db->do('delete from buckets where pseudo = 0');
    my $session = $bayes->get_session_key('admin', '');
    $bayes->db_update_cache($session);
    return $session
}

# ---------------------------------------------------------------------------
# load_fixture($bayes, $session, $fixture)
#
# $fixture may be:
#   - a string: path relative to t/fixtures/, without .pl extension
#   - a hashref: { buckets => [...], train => { bucket => [\@files] } }
#
# File paths in train lists are resolved relative to t/fixtures/.
# ---------------------------------------------------------------------------
sub load_fixture($bayes, $session, $fixture) {
    if ( !ref $fixture ) {
        my $path = "$REPO_ROOT/t/fixtures/$fixture.pl";
        $fixture = do $path
            or die "Cannot load fixture '$fixture': " . ($@ || $!);
    }
    my $fixture_dir = "$REPO_ROOT/t/fixtures";
    for my $bucket ( @{ $fixture->{buckets} // [] } ) {
        $bayes->create_bucket($session, $bucket);
    }
    for my $bucket ( keys %{ $fixture->{train} // {} } ) {
        for my $filename ( @{ $fixture->{train}{$bucket} } ) {
            $bayes->add_message_to_bucket($session, $bucket, "$fixture_dir/$filename");
        }
    }
}

# ---------------------------------------------------------------------------
# Stub History
# ---------------------------------------------------------------------------
package TestHelper::History;

sub force_requery {}

# ---------------------------------------------------------------------------
# Stub MQ
# ---------------------------------------------------------------------------
package TestHelper::MQ;

sub post($self, $type, @msg) {
    push @{ $self->{posted} }, { type => $type, msg => \@msg };
    for my $waiter (@{ $self->{waiters}{$type} // [] }) {
        $waiter->deliver($type, @msg);
    }
}

sub register($self, $type, $obj) {
    push @{ $self->{waiters}{$type} }, $obj;
}

1;
