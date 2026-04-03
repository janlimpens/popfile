package POPFile::Features;

use strict;
use warnings;
use builtin ();
use feature ();
use utf8 ();

sub import {
    strict->import();
    warnings->import();
    utf8->import();
    feature->import(qw(say state try));
    warnings->unimport('experimental::try');
    no strict 'refs';
    my $caller = caller;
    *{"${caller}::trim"} = \&builtin::trim;
}

1;

__END__

=head1 NAME

POPFile::Features - Bundle modern Perl features for POPFile modules

=head1 SYNOPSIS

    use POPFile::Features;

    say trim("  hello  ");    # say and trim available
    my $x = do { state $n = 0; ++$n };
    try { ... } catch ($e) { ... }

=head1 DESCRIPTION

One-liner that enables the modern Perl features used throughout the POPFile
codebase, so each module does not need to repeat the same list of pragmas.

Calling C<use POPFile::Features> in a file is equivalent to:

    use strict;
    use warnings;
    use utf8;
    use feature qw(say state try);
    no warnings 'experimental::try';
    use builtin qw(trim);

This module does B<not> load Object::Pad; class-based modules still need
their own C<use Object::Pad>.

=head1 EXPORTS

=over 4

=item trim

Imported directly from C<builtin::trim> into the caller's namespace.

=back

=cut
