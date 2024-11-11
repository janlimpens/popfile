use v5.38;
use Test2::V0;
use lib './..';
use POPFile::Module;
use DDP;
use builtin qw(blessed);

package Test {
    use base qw/ POPFile::Module /;
}

my $test = Test->new();
$test->name('Test');
ok blessed $test, 'Test object created';
is $test->name, 'Test', 'name is Test';

done_testing();
