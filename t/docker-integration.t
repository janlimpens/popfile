#!/usr/bin/perl
# Docker integration test — skipped by default.
# Run with: TEST_DOCKER=1 make test-docker
BEGIN {
    @INC = grep { !/\/lib$/ && $_ ne 'lib' && !/thread-multi/ } @INC;
    require FindBin;
    require Cwd;
    my $root = Cwd::abs_path("$FindBin::Bin/..");
    require lib;
    lib->import("$root/local/lib/perl5");
    unshift @INC, "$FindBin::Bin/lib", $root;
}
use v5.38;
use warnings;
use Test2::V0;
use TestHelper;
use File::Temp qw(tempdir);
use Cwd qw(abs_path);

my $repo_root = abs_path("$FindBin::Bin/..");

unless ($ENV{TEST_DOCKER}) {
    plan skip_all => 'Set TEST_DOCKER=1 to run Docker integration tests';
}

my $image = 'popfile-test';
my $container = 'popfile-test-' . time();

sub _run {
    my (@cmd) = @_;
    my $out = `@cmd 2>&1`;
    my $rc = $? >> 8;
    return ($rc, $out);
}

subtest 'docker daemon available' => sub {
    my ($rc) = _run('docker', 'info');
    is($rc, 0, 'docker daemon responds');
};

subtest 'build image' => sub {
    my ($rc, $out) = _run('docker', 'build', '-t', $image, $repo_root);
    is($rc, 0, 'image builds successfully') or diag $out;
};

subtest 'start container with defaults' => sub {
    my ($rc, $out) = _run(
        'docker', 'run', '-d', '--name', $container,
        '-p', '0:7070', $image);
    is($rc, 0, 'container starts') or diag $out;
    sleep 2;
    my ($rc2) = _run('docker', 'inspect', '-f', '{{.State.Running}}', $container);
    is($rc2, 0, 'docker inspect succeeds');
    chomp(my $running = `docker inspect -f '{{.State.Running}}' $container 2>/dev/null` // '');
    is($running, 'true', 'container is running');
};

subtest 'health endpoint responds' => sub {
    my $port = `docker port $container 7070 2>/dev/null` // '';
    chomp $port;
    $port =~ s/.*://;
    ok($port =~ /^\d+$/, "got host port: $port");
    my ($rc, $out) = _run('curl', '-sf', "http://localhost:$port/api/v1/health");
    is($rc, 0, 'health endpoint is reachable') or diag $out;
    like($out, qr/"status":"ok"/, 'health reports ok');
};

subtest 'config file is created' => sub {
    my $port = `docker port $container 7070 2>/dev/null` // '';
    chomp $port;
    $port =~ s/.*://;
    my ($rc, $out) = _run('curl', '-sf', "http://localhost:$port/api/v1/config");
    is($rc, 0, 'config endpoint reachable') or diag $out;
    like($out, qr/"api_local":0/, 'api_local defaults to 0');
    like($out, qr/"api_port":7070/, 'api_port is 7070');
};

subtest 'container with password' => sub {
    _run('docker', 'stop', $container);
    _run('docker', 'rm', $container);
    my $pw_container = $container . '-pw';
    my ($rc, $out) = _run(
        'docker', 'run', '-d', '--name', $pw_container,
        '-p', '0:7070', '-e', 'POPFILE_PASSWORD=secret42', $image);
    is($rc, 0, 'password container starts');
    sleep 2;

    my $port = `docker port $pw_container 7070 2>/dev/null` // '';
    chomp $port;
    $port =~ s/.*://;

    my ($rc1, $out1) = _run('curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
        "http://localhost:$port/api/v1/health");
    is($out1, '403', 'no token → 403');

    my ($rc2, $out2) = _run('curl', '-s', '-o', '/dev/null', '-w', '%{http_code}',
        '-H', 'X-POPFile-Token: secret42',
        "http://localhost:$port/api/v1/health");
    is($out2, '200', 'with token → 200');

    _run('docker', 'stop', $pw_container);
    _run('docker', 'rm', $pw_container);
};

END {
    _run('docker', 'stop', $container) if $container;
    _run('docker', 'rm', '-f', $container) if $container;
    _run('docker', 'rmi', '-f', $image) if $image;
}

done_testing;
