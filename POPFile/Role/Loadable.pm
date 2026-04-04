# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Loadable {

=head1 NAME

POPFile::Loadable - role marking a class as a POPFile loadable module

=head1 DESCRIPTION

Composing this role declares that a class participates in the POPFile module
lifecycle. C<POPFile::Loader> verifies C<DOES('POPFile::Loadable')> after
instantiation instead of checking a file-header comment.

Default no-op implementations live in C<POPFile::Module>. Subclasses override
as needed.

=head2 Design Notes

B<Transitive composition via POPFile::Module.>
This role is composed directly by C<POPFile::Module> only.  Every leaf class
(C<Classifier::Bayes>, C<UI::Mojo>, C<Proxy::Proxy>, etc.) inherits it
transitively through C<:isa(POPFile::Module)>.  Object::Pad propagates role
membership through the inheritance chain, so C<< $leaf->DOES('POPFile::Loadable') >>
returns true without each leaf needing an explicit C<:does(POPFile::Loadable)>.

B<Why not declare the role on every leaf class?>
Repeating C<:does(POPFile::Loadable)> on each leaf would be redundant and
noisy.  The authoritative statement of the contract is the single
C<:does(POPFile::Loadable)> on C<POPFile::Module>.  Adding it to subclasses
would imply they override the composition in some way, which they do not.

B<When to add an explicit declaration.>
If a class ever needs to satisfy the C<POPFile::Loadable> contract without
inheriting from C<POPFile::Module> — for example a lightweight stub or a
test double — it should declare C<:does(POPFile::Loadable)> explicitly and
provide its own method implementations.

=cut

    method initialize();
    method start();
    method stop();
    method service();
    method prefork();
    method forked ($writer = undef);
    method postfork ($pid = undef, $reader = undef);
    method childexit();
    method reaper();
    method deliver ($type, @message);
}
