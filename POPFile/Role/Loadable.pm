use Object::Pad;

role POPFile::Loadable {

=head1 NAME

POPFile::Loadable - role marking a class as a POPFile loadable module

=head1 DESCRIPTION

Composing this role declares that a class participates in the POPFile module
lifecycle. C<POPFile::Loader> verifies C<DOES('POPFile::Loadable')> after
instantiation instead of checking a file-header comment.

All lifecycle methods have default no-op implementations; subclasses override
as needed.

=head2 initialize

Called once before C<start>. Register configuration parameters here.
Returns 1 on success, 0 to abort loading.

=head2 start

Called to open connections and begin operation.
Returns 1 on success, 0 to abort, 2 to unload the module.

=head2 service

Called repeatedly in the main loop. Returns 1 to continue, 0 to request shutdown.

=head2 stop

Called on shutdown. Clean up resources here.

=head2 prefork / forked / postfork / childexit / reaper / deliver

Fork-lifecycle and message-queue hooks.

=cut

    method initialize                               { return 1 }
    method start                                    { return 1 }
    method stop                                     {}
    method service                                  { return 1 }
    method prefork                                  {}
    method forked ($writer = undef)                 {}
    method postfork ($pid = undef, $reader = undef) {}
    method childexit                                {}
    method reaper                                   {}
    method deliver ($type, @message)                {}
}
