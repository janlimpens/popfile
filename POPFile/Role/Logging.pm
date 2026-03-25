use Object::Pad;
use Log::Any ();

role POPFile::Role::Logging {

    method log_ ($level, $message) {
        my $log = Log::Any->get_logger(category => ref($self));
        my ( undef, undef, $line ) = caller;
        my $msg = ref($self) . ": $line: $message";
        if    ($level == 0) { $log->error($msg) }
        elsif ($level == 1) { $log->info($msg)  }
        else                { $log->debug($msg) }
    }
}
