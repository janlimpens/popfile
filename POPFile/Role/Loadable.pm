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
