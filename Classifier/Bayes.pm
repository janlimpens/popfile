# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Classifier::Bayes;

use Object::Pad;
use feature qw(state try);
no warnings 'experimental::try';
use locale;
use Classifier::Bucket;
use Classifier::Buckets;
use Classifier::Corpus;
use Classifier::MailParse;
use Classifier::Sessions;
use Classifier::Magnets;
use Classifier::Stopwords;
use POPFile::Role::DBConnect;
use POPFile::Role::SQL;
use IO::Handle;
use DBI;
use List::Util qw(max min);
use MIME::Base64;
use File::Copy;

# This is used to get the hostname of the current machine
# in a cross platform way

use Sys::Hostname;

# A handy variable containing the value of an EOL for networks

my $eol = "\015\012";

# Korean characters definition

my $ksc5601_sym = '(?:[\xA1-\xAC][\xA1-\xFE])';
my $ksc5601_han = '(?:[\xB0-\xC8][\xA1-\xFE])';
my $ksc5601_hanja = '(?:[\xCA-\xFD][\xA1-\xFE])';
my $ksc5601 = "(?:$ksc5601_sym|$ksc5601_han|$ksc5601_hanja)";

my $eksc = "(?:$ksc5601|[\x81-\xC6][\x41-\xFE])"; #extended ksc

class Classifier::Bayes :isa(POPFile::Module) :does(POPFile::Role::DBConnect) :does(POPFile::Role::SQL) :does(POPFile::Role::Logging);

=head1 NAME

Classifier::Bayes - Naive Bayes email classifier

=head1 DESCRIPTION

Implements a Naive Bayes classifier for email messages.  Manages per-user
buckets, a word-frequency corpus stored in SQLite (or MySQL/PostgreSQL),
and a session-key API that proxies and the UI use to perform classification,
training, and corpus management.

The main entry points are C<classify_and_modify> (classify a message and
inject the C<X-Text-Classification> header) and the bucket/word management
methods (C<create_bucket>, C<add_message_to_bucket>, etc.).

=cut

field $wordscores :reader :writer = 0;

# wmformat: format of the word-matrix display in message detail
field $wmformat :reader :writer = '';

field $hostname = '';

field $history = 0;

# Cached prepared SQL statements (set in db_connect, released in db_disconnect)
field $db_delete_zero_words = 0;

# Caches the name of each bucket — subkeys: id, pseudo
field $db_bucketid = {};

# Per-userid word-count caches
field $db_bucketcount = {};
field $db_bucketunique = {};

field $parser :reader = Classifier::MailParse->new();

field $possible_colors = [qw(
    red green blue brown
    orange purple magenta gray
    plum silver pink lightgreen
    lightblue lightcyan lightcoral lightsalmon
    lightgrey darkorange darkcyan feldspar
    black)];
# Precomputed per-bucket log-probabilities
field $bucket_start = {};

field $not_likely = {};

# Unclassified cutoff: top probability must be this many times greater
# than the second probability (default 100×)
field $unclassified = log(100);

field $magnet_used = 0;
field $magnet_detail = 0;

field $sessions :reader = undef;
field $magnets :reader = undef;
field $buckets :reader = undef;
field $corpus :reader = undef;
field $stopwords :reader = undef;

field $db_is_sqlite = 0;
field $db_name = '';

BUILD {
    $self->set_name('bayes');
}

=head2 initialize

Called to set up the Bayes module's parameters

=cut

method initialize() {
    # This is the name for the database

    $self->config(database => 'popfile.db');

    # This is the 'connect' string used by DBI to connect to the
    # database, if you decide to change from using SQLite to some
    # other database (e.g. MySQL, Oracle, ...) this *should* be all
    # you need to change.  The additional parameters user and auth are
    # needed for some databases.
    #
    # Note that the dbconnect string
    # will be interpolated before being passed to DBI and the variable
    # $dbname can be used within it and it resolves to the full path
    # to the database named in the database parameter above.

    $self->config(dbconnect => 'dbi:SQLite:dbname=$dbname');
    $self->config(dbuser => '');
    $self->config(dbauth => '');

    # No default unclassified weight is the number of times more sure
    # POPFile must be of the top class vs the second class, default is
    # 100 times more

    $self->config(unclassified_weight => 100);
    $self->config(stopword_ratio => 0);

    # The characters that appear before and after a subject
    # modification

    $self->config(subject_mod_left => '[');
    $self->config(subject_mod_right => ']');

    # The position to insert a subject modification
    #  1 : Beginning of the subject (default)
    # -1 : End of the subject

    $self->config(subject_mod_pos => 1);

    # Get the hostname for use in the X-POPFile-Link header

    $hostname = hostname;

    # Allow the user to override the hostname

    $self->config(hostname => $hostname);

    # If set to 1 then the X-POPFile-Link will have < > around the URL
    # (i.e. X-POPFile-Link: <http://foo.bar>) when set to 0 there are
    # none (i.e. X-POPFile-Link: http://foo.bar)

    $self->config(xpl_angle => 0);

    # This parameter is used when the UI is operating in Stealth Mode.
    # If left blank (the default setting) the X-POPFile-Link will use 127.0.0.1
    # otherwise it will use this string instead. The system's HOSTS file should
    # map the string to 127.0.0.1

    $self->config(localhostname => '');

    $self->config(sqlite_fast_writes => 1);
    $self->config(sqlite_backup => 1);

    # SQLite Journal mode.
    # To use this option, DBD::SQLite v1.20 or later is required.
    #
    #   delete   : Delete journal file after committing. (default)
    #              Slow but reliable.
    #   truncate : Truncate journal file to zero length after committing.
    #              Faster than 'delete' in some environment but less reliable.
    #   persist  : Persist journal file after committing.
    #              Faster than 'delete' in some environment but less reliable.
    #   memory   : Store journal file in memory.
    #              Very fast but can't rollback when process crashes.
    #   off      : Turn off journaling.
    #              Fastest of all but can't rollback.
    #
    # For more information about the journal mode, see:
    # http://www.sqlite.org/pragma.html#pragma_journal_mode

    $self->config(sqlite_journal_mode => 'delete');

    # Japanese wakachigaki parser ('kakasi' or 'mecab' or 'internal').

    $self->config(nihongo_parser => 'kakasi');

    $self->mq_register('COMIT', $self);
    $self->mq_register('RELSE', $self);

    $self->mq_register('TICKD', $self);

    return 1;
}

=head2 deliver

Called by the message queue to deliver a message

There is no return value from this method

=cut

method deliver ($type, @message) {
    return do {
        if ($type eq 'COMIT') {
            $self->classified($message[0], $message[2]);
        } elsif ($type eq 'RELSE') {
            $sessions->remove_session($message[0]);
        } elsif ($type eq 'TICKD') {
            $self->backup_database();
        }
    }
}

=head2 start

Called to start the Bayes module running

=cut

method start() {
    # In Japanese or Korean or Chinese mode, explicitly set LC_COLLATE and
    # LC_CTYPE to C.
    #
    # This is to avoid Perl crash on Windows because default
    # LC_COLLATE of Japanese Win is Japanese_Japan.932(Shift_JIS),
    # which is different from the charset POPFile uses for Japanese
    # characters(EUC-JP).
    #
    # And on some configuration (e.g. Japanese Mac OS X), LC_CTYPE is set to
    # UTF-8 but POPFile uses EUC-JP encoding for Japanese. In this situation
    # lc() does not work correctly.

    my $language = $self->module_config(api => 'locale') || '';

    if ($language =~ /^(Nihongo$|Korean$|Chinese)/) {
        use POSIX qw(locale_h);
        setlocale(LC_COLLATE, 'C');
        setlocale(LC_CTYPE,   'C');
    }

    # Pass in the current interface language for language specific parsing

    $parser->set_lang($language);
    $parser->mangle()->set_ui_language($language);
    $unclassified = log($self->config('unclassified_weight'));

    $buckets = Classifier::Buckets->new();
    return 0
        unless $self->db_connect();
    $sessions = Classifier::Sessions->new();
    $magnets = Classifier::Magnets->new();
    $corpus = Classifier::Corpus->new();
    $stopwords = Classifier::Stopwords->new();

    if ($language eq 'Nihongo') {
        # Setup Nihongo (Japanese) parser.

        my $nihongo_parser = $self->config('nihongo_parser');

        $nihongo_parser = $parser->setup_nihongo_parser($nihongo_parser);

        $self->log_msg(DEBUG => "Use Nihongo (Japanese) parser : $nihongo_parser");
        $self->config(nihongo_parser => $nihongo_parser);
    }

    return 1;
}

=head2 stop

Called when POPFile is terminating

=cut

method stop() {
    $self->db_disconnect();
    $db_bucketid = {};
    $buckets->reset_parameters();
    $db_bucketcount = {};
    $db_bucketunique = {};
    $parser = Classifier::MailParse->new();
}

=head2 classified

Called to inform the module about a classification event

There is no return value from this method

=cut

method classified ($session, $class) {
    return $self->set_bucket_parameter(
        $session,
        $class,
        'count',
        $self->get_bucket_parameter($session, $class, 'count') + 1)
}

=head2 backup_database

Called when the TICKD message is received each hour and if we are using
the default SQLite database will make a copy with the .backup extension

=cut

method backup_database() {
    # If database backup is turned on and we are using SQLite then
    # backup the database by copying it
    # TODO: separate implementations
    if ($self->config('sqlite_backup') && $db_is_sqlite) {
        unless (copy($db_name, "$db_name.backup")) {
            $self->log_msg(WARN => "Failed to backup database ".$db_name);
        }
    }
}

=head2 tweak_sqlite($tweak, $state, $db)

Applies or reverts a named SQLite optimisation.  Currently only tweak
C<1> (async writes via C<PRAGMA synchronous=off>) is implemented and
is guarded by the C<sqlite_fast_writes> config flag.

=cut

method tweak_sqlite ($tweak, $state, $db) {
    return unless $db_is_sqlite;
    if ($tweak == 1 && $self->config('sqlite_fast_writes')) {
        $self->log_msg(INFO => "sqlite_fast_writes: synchronous=" . ($state ? 'off' : 'normal'));
        $db->do('pragma synchronous=' . ($state ? 'off' : 'normal'));
    }
}

=head2 reclassified

Called to inform the module about a reclassification from one bucket
to another


There is no return value from this method

C<session> Valid API session
C<bucket> The old bucket name
C<newbucket> The new bucket name
C<undo> 1 if this is an undo operation

=cut

method reclassified ($session, $bucket, $newbucket, $undo) {
    $self->log_msg(WARN => "Reclassification from $bucket to $newbucket");

    my $c = $undo
        ? -1
        : 1;

    if ($bucket ne $newbucket) {
        my $count = $self->get_bucket_parameter($session, $newbucket, 'count');
        my $newcount = $count + $c;
        $newcount = 0
            if $newcount < 0;
        $self->set_bucket_parameter($session, $newbucket, 'count', $newcount);
        $count = $self->get_bucket_parameter($session, $bucket, 'count');
        $newcount = $count - $c;
        $newcount = 0
            if $newcount < 0;
        $self->set_bucket_parameter($session, $bucket, 'count', $newcount);
        my $fncount = $self->get_bucket_parameter($session, $newbucket, 'fncount');
        my $newfncount = $fncount + $c;
        $newfncount = 0
            if $newfncount < 0;
        $self->set_bucket_parameter($session, $newbucket, 'fncount', $newfncount);
        my $fpcount = $self->get_bucket_parameter($session, $bucket, 'fpcount');
        my $newfpcount = $fpcount + $c;
        $newfpcount = 0
            if $newfpcount < 0;
        $self->set_bucket_parameter($session, $bucket, 'fpcount', $newfpcount);
    }
}

=head2 get_color

Retrieves the color for a specific word, color is the most likely bucket

C<$session> Session key returned by get_session_key
C<$word> Word to get the color of

=cut

method get_color ($session, $word) {
    my $max = -10000;
    my $color = 'black';

    for my $bucket ($self->get_buckets($session)) {
        my $prob = $self->get_value($session, $bucket, $word);
        if ($prob != 0)  {
        if ($prob > $max)  {
                $max = $prob;
                $color = $self->get_bucket_parameter($session, $bucket, 'color');
            }
        }
    }

    return $color;
}

=head2 get_word_colors

    my %colors = $self->get_word_colors($session, @words);

Returns a hash mapping each word in C<@words> to the display color of the
bucket that has the highest probability for that word.  Words not seen in
any bucket are omitted from the result.

=cut

method get_word_colors ($session, @words) {
    my $userid = $self->valid_session_key($session);
    return () unless defined $userid && @words;

    my $uid_buckets = $db_bucketid->{$userid} // {};
    my %id_to_name = map { $db_bucketid->{$userid}{$_}{id} => $_ }
                     keys $uid_buckets->%*;

    my %best_prob;
    my %best_name;
    my $chunk_size = 500;
    while (@words) {
        my @chunk = splice @words, 0, $chunk_size;
        my $word_expr = $self->qb()->compare('w.word', \@chunk);
        my $sth = $self->validate_sql_prepare_and_execute(
            "SELECT w.word, m.bucketid, m.times
             FROM words w
             JOIN matrix m ON m.wordid = w.id
             JOIN buckets b ON b.id = m.bucketid
                            AND b.userid = ?
                            AND b.pseudo = 0
             WHERE " . $word_expr->as_sql(),
            $userid, $word_expr->params());
        next unless defined $sth;
        while (my ($word, $bucketid, $times) = $sth->fetchrow_array()) {
            my $name = $id_to_name{$bucketid} // next;
            my $total = $self->get_bucket_word_count($session, $name);
            next unless $total;
            my $prob = $times / $total;
            if (!exists $best_prob{$word} || $prob > $best_prob{$word}) {
                $best_prob{$word} = $prob;
                $best_name{$word} = $name;
            }
        }
    }

    my %colors;
    for my $word (keys %best_name) {
        $colors{$word} = $self->get_bucket_color($session, $best_name{$word});
    }
    return %colors
}

=head2 get_not_likely_

Returns the probability of a word that doesn't appear

=cut

method get_not_likely ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $not_likely->{$userid}{$bucket} // 0;
}

=head2 get_value_

Returns the value for a specific word in a bucket.  The word is
converted to the log value of the probability before return to get
the raw value just hit the hash directly or call get_base_value_

=cut

method get_value ($session, $bucket, $word) {
    my $value = $self->db_get_word_count($session, $bucket, $word);
    if (defined($value) && ($value > 0)) {
        # Profiling notes:
        #
        # I tried caching the log of the total value and then doing
        # log($value) - $cached and this turned out to be
        # much slower than this single log with a division in it
        return log($value / $self->get_bucket_word_count($session, $bucket));
    } else {
        return 0;
    }
}

=head2 get_base_value

    my $n = $self->get_base_value($session, $bucket, $word);

Returns the raw training count for C<$word> in C<$bucket>, or 0 if the word
is not present.  Unlike C<get_value>, no logarithm is applied.

=cut

method get_base_value ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return 0
        unless defined $userid;
    return $corpus->word_count_get($self->db(),
        $db_bucketid->{$userid}{$bucket}{id}, $word) // 0
}

=head2 set_value_

Sets the value for a word in a bucket and updates the total word
counts for the bucket and globally

=cut

method set_value ($session, $bucket, $word, $value) {
    my $userid = $self->valid_session_key($session);
    return 0
        unless defined $userid;
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    $corpus->word_count_set($self->db(), $bucketid, $word, $value);
    $self->validate_sql_prepare_and_execute(
        $db_delete_zero_words, $bucketid);
    return 1
}

=head2 get_sort_value_ behaves the same as get_value_, except that it

returns not_likely rather than 0 if the word is not found.  This
makes its result more suitable as a sort key for bucket ranking.

=cut

method get_sort_value ($session, $bucket, $word) {
    my $v = $self->get_value($session, $bucket, $word);
    if ($v == 0) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
        return $not_likely->{$userid}{$bucket} // 0
    } else {
        return $v
    }
}

=head2 update_constants

Updates not_likely and bucket_start

=cut

method update_constants ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my $wc = $self->get_word_count($session);
    $not_likely->{$userid} = {};

    return unless $wc > 0;

    for my $bucket ($self->get_buckets($session)) {
        my $total = $self->get_bucket_word_count($session, $bucket);
        if ($total != 0) {
            $bucket_start->{$userid}{$bucket} = log($total / $wc);
            $not_likely->{$userid}{$bucket} = -log(10 * $total);
        } else {
            $bucket_start->{$userid}{$bucket} = 0;
            $not_likely->{$userid}{$bucket} = 0;
        }
    }
}

=head2 db_connect

Connects to the POPFile database and returns 1 if successful

=cut

method db_connect() {
    # Connect to the database, note that the database must exist for
    # this to work, to make this easy for people POPFile we will
    # create the database automatically here using the file
    # 'popfile.sql' which should be located in the same directory the
    # Classifier/Bayes.pm module

    # If we are using SQLite then the dbname is actually the name of a
    # file, and hence we treat it like one, otherwise we leave it
    # alone

    my $dbname;
    my $dbconnect = $self->config('dbconnect');
    my $dbpresent;
    my $sqlite = ($dbconnect =~ /sqlite/i);
    my $mysql = ($dbconnect =~ /mysql/i);
    my %connection_options = ();
    if ($sqlite) {
        if ($dbconnect =~ /:memory:/i) {
            $dbname = ':memory:';
            $dbpresent = 0;
        } else {
            $dbname = $self->get_user_path($self->config('database'));
            $dbpresent = (-e $dbname) || 0;
        }
        $connection_options{sqlite_unicode} = 1;
    } else {
        $dbname = $self->config('database');
        $dbpresent = 1;

        if ($mysql) {
            # Turn on auto_reconnect
            $connection_options{mysql_auto_reconnect} = 1;
        }
    }

    # Record whether we are using SQLite or not and the name of the
    # database so that other routines can access it; this is used by
    # the backup_database routine to make a backup copy of the
    # database when using SQLite.

    $db_is_sqlite = $sqlite;
    $db_name = $dbname;

    # Now perform the connect, note that this is database independent
    # at this point, the actual database that we connect to is defined
    # by the dbconnect parameter.

    $dbconnect =~ s/\$dbname/$dbname/g;
    $self->log_msg(INFO => "Attempting to connect to $dbconnect ($dbpresent)");

    my $dsn;
    if ($sqlite) {
        $dsn = $dbname;
    } elsif ($mysql) {
        my $user = $self->config('dbuser') // '';
        my $auth = $self->config('dbauth') // '';
        my ($host) = ($dbconnect =~ /host=([^;]+)/i);
        $host //= 'localhost';
        $dsn = "mysql://$user:$auth\@$host/$dbname";
    } else {
        my $user = $self->config('dbuser') // '';
        my $auth = $self->config('dbauth') // '';
        my ($host) = ($dbconnect =~ /host=([^;]+)/i);
        $host //= 'localhost';
        $dsn = "postgresql://$user:$auth\@$host/$dbname";
    }
    $self->_connect($dsn, %connection_options);
    my $db = $self->db();
    unless (defined($db)) {
        $self->log_msg(WARN => "Failed to connect to database and got error $DBI::errstr");
        return 0;
    }

    if ($sqlite) {
        $self->log_msg(INFO => "Using SQLite library version " . $db->{sqlite_version});

        # Set the synchronous mode to normal (default of SQLite 2.x).

        $self->tweak_sqlite(1, 1, $db);

        # For Japanese compatibility

        if ($parser->lang() eq 'Nihongo') {
            $db->do('pragma case_sensitive_like=1');
        }

        if ($db->{sqlite_version} ge '3.6.0') {
            # Configure journal mode

            my $journal_mode = $self->config('sqlite_journal_mode');

            if ($journal_mode =~ /^(delete|truncate|persist|memory|off)$/i) {
                $db->do("pragma journal_mode=$journal_mode");
            }
        }
    }

    unless ($dbpresent) {
        unless ($self->insert_schema($sqlite)) {
            return 0
        }
    }

    # Now check for a need to upgrade the database because the schema
    # has been changed.  From POPFile v0.22.0 there's a special
    # 'popfile' table inside the database that contains the schema
    # version number.  If the version number doesn't match or is
    # missing then do the upgrade.

    open my $schema_fh, '<', $self->get_root_path('Classifier/popfile.sql');
    <$schema_fh> =~ /-- POPFILE SCHEMA (\d+)/;
    my $version = $1;
    close $schema_fh;

    my $need_upgrade = 1;

    #
    # retrieve the SQL_IDENTIFIER_QUOTE_CHAR for the database then use it
    # to strip off any sqlquotechars from the table names we retrieve
    #

    my $sqlquotechar = $db->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } $db->tables();

    for my $table (@tables) {
        if ($table =~ /\.?popfile$/) {
            my @row = $db->selectrow_array('select version from popfile');
            if ($#row == 0) {
                $need_upgrade = ($row[0] != $version);
            }
        }
    }

    if ($need_upgrade) {
        print "\n\nDatabase schema is outdated, performing automatic upgrade\n";
        # The database needs upgrading
        $self->db_upgrade();
        print "\nDatabase upgrade complete\n\n";
    }

    my $has_mid = grep { $_->[1] eq 'mid' }
        @{$db->selectall_arrayref("PRAGMA table_info(history)")};
    $db->do("ALTER TABLE history ADD COLUMN mid TEXT") unless $has_mid;

    # Now prepare common SQL statements for use, as a matter of convention the
    # parameters to each statement always appear in the following order:
    #
    # user
    # bucket
    # word
    # parameter

    $db_delete_zero_words = $db->prepare($self->normalize_sql(
        'DELETE FROM matrix
         WHERE (matrix.times <= 0 OR matrix.times IS NULL)
            AND matrix.bucketid = ?'));
    $buckets->load_parameter_ids($db);
    return 1
}

=head2 insert_schema

Insert the POPFile schema in a database

C<$sqlite> Set to 1 if this is a SQLite database

=cut

method insert_schema ($sqlite) {
    if (-e $self->get_root_path('Classifier/popfile.sql')) {
        my $schema = '';

        $self->log_msg(WARN => "Creating database schema");

        open my $schema_fh, '<', $self->get_root_path('Classifier/popfile.sql');
        while (<$schema_fh>) {
            next if (/^--/);
            next if (!/[a-z;]/);
            s/--.*$//;

            # If the line begins 'alter' and we are doing SQLite then ignore
            # the line

            if ($sqlite && (/^alter/i)) {
                next;
            }

            $schema .= $_;

            if (/end;/ || (/\);/) || (/^alter/i)) {
                $self->db()->do($schema);
                $schema = '';
            }
        }
        close $schema_fh;
        return 1;
    } else {
        $self->log_msg(WARN => "Can't find the database schema");
        return 0;
    }
}

=head2 db_upgrade

Upgrade the POPFile schema by dumping, recreating, and restoring data.

=cut

method db_upgrade() {
    my $db = $self->db();
    my $is_sqlite = ($db->{Driver}->{Name} =~ /SQLite/);

    my $sqlquotechar = $db->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } ($db->tables());

    # Dump all data as INSERT statements, drop old tables,
    # recreate schema, then restore data.

    my $i = 0;
    my $ins_file = $self->get_user_path('insert.sql');
    open INSERT, '>' . $ins_file;

    for my $table (@tables) {
        next if ($table =~ /\.?popfile$/);
        if ($is_sqlite && ($table =~ /(?:^|\.)sqlite_/)) {
            next;
        }
        if ($i > 99) {
            print "\n";
        }
        print "    Saving table $table\n    ";

        my $t = $db->prepare("select * from $table;");
        $t->execute();
        $i = 0;
        while (1) {
            if ((++$i % 100) == 0) {
                print "[$i]";
                STDOUT->flush();
            }
            if (($i % 1000) == 0) {
                print "\n";
                STDOUT->flush();
            }
            my $rows = $t->fetchrow_arrayref;

            last
                unless defined $rows;

            if ($is_sqlite) {
                print INSERT "INSERT OR IGNORE INTO $table (";
            } else {
                print INSERT "INSERT INTO $table (";
            }
            for my $i (0..$t->{NUM_OF_FIELDS}-1) {
                if ($i != 0) {
                    print INSERT ',';
                }
                print INSERT $t->{NAME}->[$i];
            }
            print INSERT ') VALUES (';
            for my $i (0..$t->{NUM_OF_FIELDS}-1) {
                if ($i != 0) {
                    print INSERT ',';
                }
                my $val = $rows->[$i];
                if ($t->{TYPE}->[$i] !~ /^int/i) {
                    $val = '' unless (defined($val));
                    $val =~ s/\x00//g;
                    $val = $self->db()->quote($val);
                } else {
                    $val = 'NULL' unless (defined($val));
                }
                print INSERT $val;
            }
            print INSERT ");\n";
        }
        $t->finish;
    }

    close INSERT;

    if ($i > 99) {
        print "\n";
    }

    for my $table (@tables) {
        if ($is_sqlite && ($table =~ /(?:^|\.)sqlite_/)) {
            next;
        }
        print "    Dropping old table $table\n";
        $db->do("DROP TABLE $table;");
    }

    print "    Inserting new database schema\n";
    if (!$self->insert_schema($is_sqlite)) {
        return 0;
    }

    print "    Restoring old data\n    ";

    $db->begin_work;
    open INSERT, '<' . $ins_file;
    $i = 0;
    while (<INSERT>) {
        if ((++$i % 100) == 0) {
           print "[$i]";
           STDOUT->flush();
        }
        if (($i % 1000) == 0) {
            print "\n";
            STDOUT->flush();
        }
        s/[\r\n]//g;
        $db->do($_);
    }
    close INSERT;
    $db->commit;

    unlink $ins_file;
}

=head2 db_disconnect

Disconnect from the POPFile database

=cut

method db_disconnect() {
    return
        unless ref $db_delete_zero_words;
    $db_delete_zero_words->finish();

    # Avoid DBD::SQLite 'closing dbh with active statement handles' bug

    undef $db_delete_zero_words;

    $self->_disconnect();
}

=head2 db_update_cache

Updates our local cache of user and bucket ids.

C<$session> Must be a valid session
C<$updated_bucket> Bucket to update cache
C<$deleted_bucket> Bucket to delete cache
                   If none of them is specified, update whole cache.

=cut

method db_update_cache ($session, $updated_bucket = undef, $deleted_bucket = undef) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    $buckets->refresh_id_cache($self->db(), $db_bucketid, $userid);
    $corpus->refresh_counts($self->db(), $db_bucketcount, $db_bucketunique,
        $db_bucketid, $userid, $updated_bucket, $deleted_bucket);
    $self->update_constants($session);
}

=head2 db_get_word_count

Return the 'count' value for a word in a bucket.  If the word is not
found in that bucket then returns undef.

C<$session> Valid session ID from get_session_key
C<$bucket> bucket word is in
C<$word> word to lookup

=cut

=head2 magnet_match_helper

Helper the determines if a specific string matches a certain magnet
type in a bucket, used by magnet_match_

C<$session> Valid session from get_session_key
C<$match> The string to match
C<$bucket> The bucket to check
C<$type> The magnet type to check

=cut

method magnet_match_helper ($session, $match, $bucket, $type) {
    my $userid = $self->valid_session_key($session);
    return 0
        unless defined $userid
            && exists $db_bucketid->{$userid}{$bucket};
    my $id = $magnets->find_match($self->db(),
        $db_bucketid->{$userid}{$bucket}{id}, $type, $match);
    if ($id) {
        $magnet_used = 1;
        $magnet_detail = $id;
        return 1
    }
    return 0
}

method single_magnet_match ($magnet, $match, $type) {
    return $magnets->word_match($magnet, $match, $type)
}

=head2 magnet_match

Helper the determines if a specific string matches a certain magnet
type in a bucket

C<$session> Valid session from get_session_key
C<$match> The string to match
C<$bucket> The bucket to check
C<$type> The magnet type to check

=cut

method magnet_match ($session, $match, $bucket, $type) {
    return $self->magnet_match_helper($session, $match, $bucket, $type);
}

=head2 write_line

Writes a line to a file and parses it unless the classification is
already known

C<$file> File handle for file to write line to
C<$line> The line to write
C<$class> (optional) The current classification

=cut

method write_line ($file, $line, $class) {
    if (defined($file) && (ref $file eq 'GLOB')) {
    if (defined(fileno $file)) {
            print $file $line;
        } else {
            my ($package, $filename, $line, $subroutine) = caller;
            $self->log_msg(WARN => "Tried to write to a closed file. Called from $package line $line");
        }
    }

    if ($class eq '') {
        $parser->parse_line($line);
    }
}

=head2 add_words_to_bucket

Takes words previously parsed by the mail parser and adds/subtracts
them to/from a bucket, this is a helper used by
add_messages_to_bucket, remove_message_from_bucket

C<$session> Valid session from get_session_key
C<$bucket> Bucket to add to
C<$subtract> Set to -1 means subtract the words, set to 1 means add

=cut

method add_words_to_bucket ($session, $bucket, $subtract) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    unless (defined $bucketid) {
        $self->log_msg(WARN => "add_words_to_bucket: bucketid undef for user=$userid bucket=$bucket; skipping");
        return
    }
    unless (keys $parser->words()->%*) {
        $self->log_msg(INFO => "add_words_to_bucket: no words parsed for user=$userid bucket=$bucket; skipping");
        return
    }
    $self->log_msg(5, "add_words_to_bucket: user=$userid bucket=$bucket bucketid=$bucketid words=" . scalar(keys $parser->words()->%*));
    $corpus->add_words($self->db(), $bucketid, $subtract, $parser->words()->%*)
}

=head2 echo_to_dot

$mail The stream (created with IO::) to send the message to (the
remote mail server)
$client (optional) The local mail client (created with IO::) that
needs the response
$file (optional) A file to print the response to, caller specifies
open style
$before (optional) String to send to client before the dot is sent

echo all information from the $mail server until a single line with
a . is seen

NOTE Also echoes the line with . to $client but not to $file

Returns 1 if there was a . or 0 if reached EOF before we hit the .

=cut

method echo_to_dot ($mail, $client, $file, $before) {
    my $hit_dot = 0;

    my $isopen = open FILE, "$file" if (defined($file));
    binmode FILE if ($isopen);

    while (my $line = $self->slurp($mail)) {
        # Check for an abort

        last if ($self->alive() == 0);

        # The termination has to be a single line with exactly a dot
        # on it and nothing else other than line termination
        # characters.  This is vital so that we do not mistake a line
        # beginning with . as the end of the block

        if ($line =~ /^\.(\r\n|\r|\n)$/) {
            $hit_dot = 1;

            if (defined($before) && ($before ne '')) {
                print $client $before if (defined($client));
                print FILE $before if (defined($isopen));
            }

            # Note that there is no print FILE here.  This is correct
            # because we do no want the network terminator . to appear
            # in the file version of any message

            print $client $line if (defined($client));
            last;
        }

        print $client $line if (defined($client));
        print FILE $line if (defined($isopen));
    }

    close FILE
        if ($isopen);

    return $hit_dot;
}

=head2 substr_euc

"substr" function which supports EUC Japanese charset

C<$pos> Start position
C<$len> Word length

=cut
sub substr_euc($str, $pos, $len) {
    my $result_str;
    my $char;
    my $count = 0;
    if (!$pos) {
        $pos = 0;
    }
    if (!$len) {
        $len = length($str);
    }

    for ($pos = 0; $count < $len; $pos++) {
        $char = substr($str, $pos, 1);
        if ($char =~ /[\x80-\xff]/) {
        $char = substr($str, $pos++, 2);
        }
        $result_str .= $char;
        $count++;
    }

    return $result_str;
}

=head2 valid_session_key

Returns undef is the session key is not valid, or returns the user
ID associated with the session key which can be used in database
accesses

C<$session> Session key returned by call to get_session_key

=cut

method valid_session_key($session) {
    return $sessions->validate_session($session)
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

=head2 get_session_key


Returns a string based session key if the username and password
match, or undef if not

C<$user> The name of an existing user
C<$pwd> The user's password

=cut

method get_session_key ($user, $pwd) {
    my ($session, $userid) = $sessions->create_session($self->db(), $user, $pwd);
    return
        unless defined $session;
    $self->db_update_cache($session);
    return $session
}

=head2 release_session_key


Releases and invalidates the session key

C<$session> A session key previously returned by get_session_key

=cut

method release_session_key ($session) {
    $self->mq_post("RELSE", $session);
}


=head2 get_top_bucket

Helper function used by classify to get the bucket with the highest
score from data stored in a matrix of information (see definition of
%matrix in classify for details) and a list of potential buckets


Returns the bucket in $buckets with the highest score

C<$userid> User ID for database access
C<$id> ID of a word in $matrix
C<$matrix> Reference to the %matrix hash in classify
C<$buckets> Reference to a list of buckets

=cut

method get_top_bucket ($userid, $id, $matrix, $buckets) {
    my $best_probability = 0;
    my $top_bucket = 'unclassified';

    for my $bucket ($buckets->@*) {
        my $probability = 0;
        if (defined($matrix->{$id}{$bucket}) && ($matrix->{$id}{$bucket} > 0)) {
            $probability = $matrix->{$id}{$bucket} / $db_bucketcount->{$userid}{$bucket};
        }

        if ($probability > $best_probability) {
            $best_probability = $probability;
            $top_bucket = $bucket;
        }
    }

    return $top_bucket;
}

=head2 classify


Splits the mail message into valid words, then runs the Bayes
algorithm to figure out which bucket it belongs in.  Returns the
bucket name

C<$session> A valid session key returned by a call to get_session_key
$file The name of the file containing the text to classify (or undef
to use the data already in the parser)
C<$templ> Reference to the UI template used for word score display
$matrix (optional) Reference to a hash that will be filled with the
word matrix used in classification
$idmap (optional) Reference to a hash that will map word ids in the
$matrix to actual words

=cut

method classify ($session, $file, $templ = undef, $matrix = undef, $idmap = undef) {
    my $msg_total = 0;

    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    $unclassified = log($self->config('unclassified_weight'));

    $magnet_used = 0;
    $magnet_detail = 0;

    if (defined($file)) {
        return if (!-f $file);

        $parser->parse_file($file,
            $self->global_config('message_cutoff'));
    }

    # Get the list of buckets

    my @buckets = $self->get_buckets($session);

    # If the user has not defined any buckets then we escape here
    # return unclassified

    return "unclassified"
        unless @buckets;

    return "unclassified"
        unless $not_likely->{$userid}->%*;

    # Check to see if this email should be classified based on a magnet

    for my $bucket ($self->get_buckets_with_magnets($session))  {
        for my $type ($self->get_magnet_types_in_bucket($session, $bucket)) {
            if ($self->magnet_match($session, $parser->get_header($type), $bucket, $type)) {
                return $bucket;
            }
        }
    }

    # The score hash will contain the likelihood that the given
    # message is in each bucket, the buckets are the keys for score

    # Set up the initial score as P(bucket)

    my %score;
    my %matchcount;

    # Build up a list of the buckets that are OK to use for
    # classification (i.e.  that have at least one word in them).

    my @ok_buckets;

    for my $bucket (@buckets) {
        if (defined $bucket_start->{$userid}{$bucket} && $bucket_start->{$userid}{$bucket} != 0) {
            $score{$bucket} = $bucket_start->{$userid}{$bucket};
            $matchcount{$bucket} = 0;
            push @ok_buckets, ($bucket);
        }
    }

    @buckets = @ok_buckets;

    # If the user does not have at least two buckets which contains
    # some words then we escape here return unclassified

    return "unclassified" if (@buckets < 2);

    # For each word go through the buckets and calculate
    # P(word|bucket) and then calculate P(word|bucket) ^ word count
    # and multiply to the score

    my $word_count = 0;

    # The correction value is used to generate score displays variable
    # which are consistent with the word scores shown by the GUI's
    # word lookup feature.  It is computed to make the contribution of
    # a word which is unrepresented in a bucket zero.  This correction
    # affects only the values displayed in the display; it has no
    # effect on the classification process.

    my $correction = 0;

    # Classification against the database works in a sequence of steps
    # to get the fastest time possible.  The steps are as follows:
    #
    # 1. Convert the list of words returned by the parser into a list
    #    of unique word ids that can be used in the database.  This
    #    requires a select against the database to get the word ids
    #    (and associated words) which is then converted into two
    #    things: @id_list which is just the sorted list of word ids
    #    and %idmap which maps a word to its id.
    #
    # 2. Then run a second select that get the triplet (count, id,
    #    bucket) for each word id and each bucket.  The triplet
    #    contains the word count from the database for each bucket and
    #    each id, where there is an entry. That data gets loaded into
    #    the sparse matrix %matrix.
    #
    # 3. Do the normal classification loop as before running against
    # the @id_list for the words and for each bucket.  If there's an
    # entry in %matrix for the id/bucket combination then calculate
    # the probability, otherwise use the not_likely probability.
    #
    # NOTE.  Since there is a single not_likely probability we do not
    # worry about the fact that the select in 1 might return a shorter
    # list of words than was found in the message (because some words
    # are not in the database) since the missing words will be the
    # same for all buckets and hence constitute a fixed scaling factor
    # on all the buckets which is irrelevant in deciding which the
    # winning bucket is.

    my @words = sort keys $parser->words()->%*;

    my ($id_list_ref, $idmap_ref) = $corpus->resolve_word_ids(
        $self->db(), \@words);
    if (defined $idmap) {
        %$idmap = (%$idmap, %$idmap_ref);
    } else {
        $idmap = $idmap_ref;
    }
    my $matrix_ref = $corpus->fetch_matrix(
        $self->db(), $id_list_ref, $userid);
    if (defined $matrix) {
        %$matrix = (%$matrix, %$matrix_ref);
    } else {
        $matrix = $matrix_ref;
    }
    my @id_list = $id_list_ref->@*;
    my $not_likely_for_bucket = $not_likely->{$userid};
    my $display_not_likely = (sort { $a <=> $b } values $not_likely_for_bucket->%*)[0] // 0;
    my $stopword_ratio = $self->config('stopword_ratio') + 0;

    for my $id (@id_list) {
        if ($stopword_ratio > 0 && @buckets > 1) {
            my $min_c = 'inf';
            my $max_c = 0;
            my $all_present = 1;
            for my $bucket (@buckets) {
                my $c = $$matrix{$id}{$bucket} // 0;
                if ($c == 0) { $all_present = 0; last }
                $min_c = $c if $c < $min_c;
                $max_c = $c if $c > $max_c;
            }
            next if $all_present && $max_c / $min_c < $stopword_ratio;
        }
        $word_count += 2;
        my $wmax = -10000;
        my $count = $parser->words()->{$$idmap{$id}};

        for my $bucket (@buckets) {
            my $probability = $not_likely_for_bucket->{$bucket};

            if (defined($$matrix{$id}{$bucket}) && ($$matrix{$id}{$bucket} > 0)) {
                $probability = log($$matrix{$id}{$bucket} / $db_bucketcount->{$userid}{$bucket});
                $matchcount{$bucket} += $count;
            }

            $wmax = $probability if ($wmax < $probability);
            $score{$bucket} += ($probability * $count);
        }

        if ($wmax > $display_not_likely) {
            $correction += $display_not_likely * $count;
        } else {
            $correction += $wmax * $count;
        }
    }

    # Now sort the scores to find the highest and return that bucket
    # as the classification

    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    my %raw_score;
    my $base_score = defined $ranking[0] ? $score{$ranking[0]} : 0;
    my $total = 0;

    # If the first and second bucket are too close in their
    # probabilities, call the message unclassified.  Also if there are
    # fewer than 2 buckets.

    my $class = 'unclassified';

    if (@buckets > 1 && $score{$ranking[0]} > ($score{$ranking[1]} + $unclassified)) {
        $class = $ranking[0];
    }

    # Compute the total of all the scores to generate the normalized
    # scores and probability estimate.  $total is always 1 after the
    # first loop iteration, so any additional term less than 2 ** -54
    # is insignificant, and need not be computed.

    my $ln2p_54 = -54 * log(2);

    for my $b (@ranking) {
        $raw_score{$b} = $score{$b};
        $score{$b} -= $base_score;

        $total += exp($score{$b}) if ($score{$b} > $ln2p_54);
    }

    if ($wordscores && defined($templ)) {
        my %qm = $parser->quickmagnets()->%*;
        my $mlen = scalar(keys $parser->quickmagnets()->%*);

        if ($mlen > 0) {
            $templ->param(View_QuickMagnets_If => 1);
            $templ->param(View_QuickMagnets_Count => ($mlen + 1));
            my @buckets = $self->get_buckets($session);
            my $i = 0;
            my %types = $self->get_magnet_types($session);

            my @bucket_data;
            for my $bucket (@buckets) {
                my %row_data;
                $row_data{View_QuickMagnets_Bucket} = $bucket;
                $row_data{View_QuickMagnets_Bucket_Color} = $self->get_bucket_color($session, $bucket);
                push (@bucket_data, \%row_data);
            }

            my @qm_data;
            for my $type (sort keys %types) {
                my %row_data;

                if (defined $qm{$type}) {
                    $i++;

                    $row_data{View_QuickMagnets_Type} = $type;
                    $row_data{View_QuickMagnets_I} = $i;
                    $row_data{View_QuickMagnets_Loop_Buckets} = \@bucket_data;

                    my @magnet_data;
                    for my $magnet ($qm{$type}->@*) {
                        my %row_magnet;
                        $row_magnet{View_QuickMagnets_Magnet} = $magnet;
                        push (@magnet_data, \%row_magnet);
                    }
                    $row_data{View_QuickMagnets_Loop_Magnets} = \@magnet_data;

                    push (@qm_data, \%row_data);
                }
            }
            $templ->param(View_QuickMagnets_Loop => \@qm_data);
        }

        $templ->param(View_Score_If_Score => $wmformat eq 'score');
        my $log10 = log(10.0);

        my @score_data;
        for my $b (@ranking) {
            my %row_data;
            my $prob = exp($score{$b})/$total;
            my $probstr;
            my $rawstr;

            # If the computed probability would display as 1, display
            # it as .999999 instead.  We don't want to give the
            # impression that POPFile is ever completely sure of its
            # classification.

            if ($prob >= .999999) {
                $probstr = sprintf("%12.6f", 0.999999);
            } else {
                if ($prob >= 0.1 || $prob == 0.0) {
                    $probstr = sprintf("%12.6f", $prob);
                } else {
                    $probstr = sprintf("%17.6e", $prob);
                }
            }

            my $color = $self->get_bucket_color($session, $b);

            $row_data{View_Score_Bucket} = $b;
            $row_data{View_Score_Bucket_Color} = $color;
            $row_data{View_Score_MatchCount} = $matchcount{$b};
            $row_data{View_Score_ProbStr} = $probstr;

            if ($wmformat eq 'score') {
                $row_data{View_Score_If_Score} = 1;
                $rawstr = sprintf("%12.6f", ($raw_score{$b} - $correction)/$log10);
                $row_data{View_Score_RawStr} = $rawstr;
            }
            push (@score_data, \%row_data);
        }
        $templ->param(View_Score_Loop_Scores => \@score_data);

        if ($wmformat ne '') {
            $templ->param(View_Score_If_Table => 1);

            my @header_data;
            for my $ix (0..($#buckets > 7? 7: $#buckets)) {
                my %row_data;
                my $bucket = $ranking[$ix];
                my $bucketcolor = $self->get_bucket_color($session, $bucket);
                $row_data{View_Score_Bucket} = $bucket;
                $row_data{View_Score_Bucket_Color} = $bucketcolor;
                push (@header_data, \%row_data);
            }
            $templ->param('View_Score_Loop_Bucket_Header' => \@header_data);

            my %wordprobs;

            # If the word matrix is supposed to show probabilities,
            # compute them, saving the results in %wordprobs.

            if ($wmformat eq 'prob') {
                for my $id (@id_list) {
                    my $sumfreq = 0;
                    my %wval;
                    for my $bucket (@ranking) {
                        $wval{$bucket} = $$matrix{$id}{$bucket} || 0;
                        $sumfreq += $wval{$bucket};
                    }

                    # If $sumfreq is still zero then this word didn't
                    # appear in any buckets so we shouldn't create
                    # wordprobs entries for it

                    if ($sumfreq != 0) {
                        for my $bucket (@ranking) {
                            $wordprobs{$bucket,$id} = $wval{$bucket} / $sumfreq;
                        }
                    }
                }
            }

            my @ranked_ids;
            if ($wmformat eq 'prob') {
                @ranked_ids = sort {($wordprobs{$ranking[0],$b}||0) <=> ($wordprobs{$ranking[0],$a}||0)} @id_list;
            } else {
                @ranked_ids = sort {($$matrix{$b}{$ranking[0]}||0) <=> ($$matrix{$a}{$ranking[0]}||0)} @id_list;
            }

            my @word_data;
            my %chart;
            for my $id (@ranked_ids) {
                my %row_data;
                my $known = 0;

                for my $bucket (@ranking) {
                    if (defined($$matrix{$id}{$bucket})) {
                        $known = 1;
                        last;
                    }
                }

                if ($known == 1) {
                    my $wordcolor = $self->get_bucket_color($session, $self->get_top_bucket($userid, $id, $matrix, \@ranking));
                    my $count = $parser->words()->{$$idmap{$id}};

                    $row_data{View_Score_Word} = $$idmap{$id};
                    $row_data{View_Score_Word_Color} = $wordcolor;
                    $row_data{View_Score_Word_Count} = $count;

                    my $base_probability = 0;
                    if (defined($$matrix{$id}{$ranking[0]}) && ($$matrix{$id}{$ranking[0]} > 0)) {
                        $base_probability = log($$matrix{$id}{$ranking[0]} / $db_bucketcount->{$userid}{$ranking[0]});
                    }

                    my @per_bucket;
                    my @score;
                    for my $ix (0..($#buckets > 7? 7: $#buckets)) {
                        my %bucket_row;
                        my $bucket = $ranking[$ix];
                        my $probability = 0;
                        if (defined($$matrix{$id}{$bucket}) && ($$matrix{$id}{$bucket} > 0)) {
                            $probability = log($$matrix{$id}{$bucket} / $db_bucketcount->{$userid}{$bucket});
                        }
                        my $color = 'black';

                        if ($probability >= $base_probability || $base_probability == 0) {
                            $color = $self->get_bucket_color($session, $bucket);
                        }

                        $bucket_row{View_Score_If_Probability} = ($probability != 0);
                        $bucket_row{View_Score_Word_Color} = $color;
                        if ($probability != 0) {
                            my $wordprobstr;
                            if ($wmformat eq 'score') {
                                $wordprobstr = sprintf("%12.4f", ($probability - $not_likely_for_bucket->{$bucket})/$log10);
                                push (@score, $wordprobstr);
                            } else {
                                if ($wmformat eq 'prob') {
                                    $wordprobstr = sprintf("%12.4f", $wordprobs{$bucket,$id});
                                } else {
                                    $wordprobstr = sprintf("%13.5f", exp($probability));
                                }
                            }
                            $bucket_row{View_Score_Probability} = $wordprobstr;
                        }
                        else {
                            # Scores eq 0 must also be remembered.
                            push @score, 0;
                        }
                        push @per_bucket, \%bucket_row;
                    }
                    $row_data{View_Score_Loop_Per_Bucket} = \@per_bucket;

                    # If we are doing the word scores then we build up
                    # a hash that maps the name of a word to a value
                    # which is the difference between the word scores
                    # for the top two buckets.  We later use this to
                    # draw a chart

                    if ($wmformat eq 'score') {
                        $chart{$idmap->{$id}} = ($score[0] || 0) - ($score[1] || 0);
                    }

                    push (@word_data, \%row_data);
                }
            }
            $templ->param(View_Score_Loop_Words => \@word_data);

            if ($wmformat eq 'score') {
                # Draw a chart that shows how the decision between the top
                # two buckets was made.

                my @words = sort { $chart{$b} <=> $chart{$a} } keys %chart;

                my @chart_data;
                my $max_chart = $chart{$words[0]};
                my $min_chart = $chart{$words[$#words]};
                my $scale = ($max_chart > $min_chart) ? 400 / ($max_chart - $min_chart) : 0;

                my $color_1 = $self->get_bucket_color($session, $ranking[0]);
                my $color_2 = $self->get_bucket_color($session, $ranking[1]);

                $templ->param('Bucket_1' => $ranking[0]);
                $templ->param('Bucket_2' => $ranking[1]);

                $templ->param('Color_Bucket_1' => $color_1);
                $templ->param('Color_Bucket_2' => $color_2);

                $templ->param('Score_Bucket_1' => sprintf("%.3f", ($raw_score{$ranking[0]} - $correction)/$log10));
                $templ->param('Score_Bucket_2' => sprintf("%.3f", ($raw_score{$ranking[1]} - $correction)/$log10));

                for (my $i=0; $i <= $#words; $i++) {
                    my $word_1 = $words[$i];
                    my $word_2 = $words[$#words - $i];

                    my $width_1 = int($chart{$word_1} * $scale + .5);
                    my $width_2 = int($chart{$word_2} * $scale - .5) * -1;

                    last if ($width_1 <=0 && $width_2 <= 0);

                    my %row_data;

                    $row_data{View_Chart_Word_1} = $word_1;
                    if ($width_1 > 0) {
                        $row_data{View_If_Bar_1} = 1;
                        $row_data{View_Width_1} = $width_1;
                        $row_data{View_Color_1} = $color_1;
                        $row_data{Score_Word_1} = sprintf "%.3f", $chart{$word_1};
                    }
                    else {
                        $row_data{View_If_Bar_1} = 0;
                    }

                    $row_data{View_Chart_Word_2} = $word_2;
                    if ($width_2 > 0) {
                        $row_data{View_If_Bar_2} = 1;
                        $row_data{View_Width_2} = $width_2;
                        $row_data{View_Color_2} = $color_2;
                        $row_data{Score_Word_2} = sprintf "%.3f", $chart{$word_2};
                    }
                    else {
                        $row_data{View_If_Bar_2} = 0;
                    }

                    push (@chart_data, \%row_data);
                }
                $templ->param(View_Loop_Chart => \@chart_data);
                $templ->param(If_chart => 1);
            }
            else {
                $templ->param(If_chart => 0);
            }
        }
    }

    return $class;
}

=head2 classify_and_modify

This method reads an email terminated by . on a line by itself (or
the end of stream) from a handle and creates an entry in the
history, outputting the same email on another handle with the
appropriate header modifications and insertions


Returns a classification if it worked and the slot ID of the history
item related to this classification

IMPORTANT NOTE: $mail and $client should be binmode

C<$session> - A valid session key returned by a call to get_session_key
C<$mail> - an open stream to read the email from
C<$client> - an open stream to write the modified email to
C<$nosave> - set to 1 indicates that this should not save to history
C<$class> - if we already know the classification
C<$slot> - Must be defined if $class is set
C<$echo> - 1 to echo to the client, 0 to supress, defaults to 1
C<$crlf> - The sequence to use at the end of a line in the output,
  normally this is left undefined and this method uses $eol (the
  normal network end of line), but if this method is being used with
  real files you may wish to pass in \n instead

=cut

method classify_and_modify ($session, $mail, $client, $nosave, $class, $slot, $echo, $crlf) {
    $echo = 1    unless (defined $echo);
    $crlf = $eol unless (defined $crlf);

    my $msg_subject;              # The message subject
    my $msg_head_before = '';     # Store the message headers that
                                  # come before Subject here
    my $msg_head_after = '';      # Store the message headers that
                                  # come after Subject here
    my $msg_head_q = '';          # Store questionable header lines here
    my $msg_body = '';            # Store the message body here
    my $in_subject_header = 0;    # 1 if in Subject header

    # These two variables are used to control the insertion of the
    # X-POPFile-TimeoutPrevention header when downloading long or slow
    # emails

    my $last_timeout = time;
    my $timeout_count = 0;

    # Indicates whether the first time through the receive loop we got
    # the full body, this will happen on small emails

    my $got_full_body = 0;

    # The size of the message downloaded so far.

    my $message_size = 0;

    # The classification for this message

    my $classification = '';

    # Whether we are currently reading the mail headers or not

    my $getting_headers = 1;

    # The maximum size of message to parse, or 0 for unlimited

    my $max_size = $self->global_config('message_cutoff');
    $max_size = 0 unless (defined($max_size) || ($max_size =~ /\D/));

    my $msg_file;

    # If we don't yet know the classification then start the parser

    $class = '' unless (defined($class));
    if ($class eq '') {
        $parser->start_parse();
        ($slot, $msg_file) = $history->reserve_slot();
    } else {
        $msg_file = $history->get_slot_file($slot);
    }

    # We append .TMP to the filename for the MSG file so that if we are in
    # middle of downloading a message and we refresh the history we do not
    # get class file errors

    my $msg;
    if (!$nosave) {
        open $msg, '>', $msg_file or $self->log_msg(WARN => "Could not open $msg_file : $!");
    }

    while (my $line = $self->slurp($mail)) {
        my $fileline;

        # This is done so that we remove the network style end of line
        # CR LF and allow Perl to decide on the local system EOL which
        # it will expand out of \n when this gets written to the temp
        # file

        $fileline = $line;
        $fileline =~ s/[\r\n]//g;
        $fileline .= "\n";

        # Check for an abort

        last if ($self->alive() == 0);

        # The termination of a message is a line consisting of exactly
        # .CRLF so we detect that here exactly

        if ($line =~ /^\.(\r\n|\r|\n)$/) {
            $got_full_body = 1;
            last;
        }

        if ($getting_headers)  {
            # Kill header lines containing only whitespace (Exim does this)

            next if ($line =~ /^[ \t]+(\r\n|\r|\n)$/i);

            if ($line !~ /^(\r\n|\r|\n)$/i) {
                $message_size += length $line;
                $self->write_line($nosave?undef:$msg, $fileline, $class);

                # If there is no echoing occuring, it doesn't matter
                # what we do to these

                if ($echo) {
                    if ($line =~ /^Subject:(.*)/i)  {
                        $msg_subject = $1;
                        $msg_subject =~ s/(\012|\015)//g;
                        $in_subject_header = 1;
                        next;
                    } elsif ($line !~ /^[ \t]/) {
                        $in_subject_header = 0;
                    }

                    # Strip out the X-Text-Classification header that
                    # is in an incoming message

                    next
                        if ($line =~ /^X-Text-Classification:/i);
                    next
                        if ($line =~ /^X-POPFile-Link:/i);

                    # Store any lines that appear as though they may
                    # be non-header content Lines that are headers
                    # begin with whitespace or Alphanumerics and "-"
                    # followed by a colon.
                    #
                    # This prevents weird things like HTML before the
                    # headers terminate from causing the XPL and XTC
                    # headers to be inserted in places some clients
                    # can't detect

                    if ($line =~ /^[ \t]/ && $in_subject_header) {
                        $line =~ s/(\012|\015)//g;
                        $msg_subject .= $crlf . $line;
                        next;
                    }

                    if ($line =~ /^([ \t]|([A-Z0-9\-_]+:))/i) {
                        unless (defined($msg_subject))  {
                            $msg_head_before .= $msg_head_q . $line;
                        } else {
                            $msg_head_after  .= $msg_head_q . $line;
                        }
                        $msg_head_q = '';
                    } else {
                        # Gather up any header lines that are questionable

                        $self->log_msg(INFO => "Found odd email header: $line");
                        $msg_head_q .= $line;
                    }
                }
            } else {
                $self->write_line($nosave?undef:$msg, "\n", $class);
                $message_size += length $crlf;
                $getting_headers = 0;
            }
        } else {
            $message_size += length $line;
            $msg_body .= $line;
            $self->write_line($nosave?undef:$msg, $fileline, $class);
        }

        # Check to see if too much time has passed and we need to keep
        # the mail client happy

        if (time > ($last_timeout + 2)) {
            print $client "X-POPFile-TimeoutPrevention: $timeout_count$crlf" if ($echo);
            $timeout_count += 1;
            $last_timeout = time;
        }

        last
            if $max_size > 0
            && $message_size > $max_size
            && !$getting_headers;
    }

    close $msg
        unless $nosave;

    # If we don't yet know the classification then stop the parser
    if ($class eq '') {
        $parser->stop_parse();
    }

    # Do the text classification and update the counter for that
    # bucket that we just downloaded an email of that type

    $classification = ($class ne '')
        ? $class
        : $self->classify($session, undef);

    my $subject_modification = $self->get_bucket_parameter($session, $classification, 'subject');
    my $xtc_insertion = $self->get_bucket_parameter($session, $classification, 'xtc');
    my $xpl_insertion = $self->get_bucket_parameter($session, $classification, 'xpl');
    my $quarantine = $self->get_bucket_parameter($session, $classification, 'quarantine');

    my $modification = $self->config('subject_mod_left') . $classification . $self->config('subject_mod_right');

    # Add the Subject line modification or the original line back again
    # Don't add the classification unless it is not present

    my $original_msg_subject = $msg_subject;

    if ($subject_modification) {
        if (! defined $msg_subject) {
            $msg_subject = " $modification";
        } elsif ($msg_subject !~ /\Q$modification\E/) {
            if ($self->config('subject_mod_pos') > 0) {
                $msg_subject = " $modification$msg_subject";
            } else {
                $msg_subject = "$msg_subject $modification";
            }
        }
    }

    if ($quarantine) {
        if (defined($original_msg_subject)) {
            $msg_head_before .= "Subject:$original_msg_subject$crlf";
        }
    } else {
        if (defined($msg_subject)) {
            $msg_head_before .= "Subject:$msg_subject$crlf";
        }
    }

    # Add LF if $msg_head_after ends with CR to avoid header concatination

    $msg_head_after =~ s/\015\z/$crlf/;

    # Add the XTC header

    if ($xtc_insertion && !$quarantine) {
        $msg_head_after .= "X-Text-Classification: $classification$crlf";
    }

    # Add the XPL header

    my $host = $self->module_config('api', 'local')
        ? $self->config('localhostname') || '127.0.0.1'
        : $self->config('hostname');
    my $port = $self->module_config('api', 'port');

    my $xpl = "http://$host:$port/jump_to_message?view=$slot";

    $xpl = "<$xpl>" if ($self->config('xpl_angle'));

    if ($xpl_insertion && !$quarantine) {
        $msg_head_after .= "X-POPFile-Link: $xpl$crlf";
    }

    $msg_head_after .= $msg_head_q;
    $msg_head_after .= $crlf if (!$getting_headers);

    # Echo the text of the message to the client

    if ($echo) {
        # If the bucket is quarantined then we'll treat it specially
        # by changing the message header to contain information from
        # POPFile and wrapping the original message in a MIME encoding

       if ($quarantine) {
       my ($orig_from, $orig_to, $orig_subject) = ($parser->get_header('from'), $parser->get_header('to'), $parser->get_header('subject'));
       my ($encoded_from, $encoded_to) = ($orig_from, $orig_to);
       if ($parser->lang() eq 'Nihongo') {
               require Encode;

               Encode::from_to($orig_from, 'euc-jp', 'iso-2022-jp');
               Encode::from_to($orig_to, 'euc-jp', 'iso-2022-jp');
               Encode::from_to($orig_subject, 'euc-jp', 'iso-2022-jp');

               $encoded_from = $orig_from;
               $encoded_to = $orig_to;
               $encoded_from =~ s/(\x1B\x24\x42.+\x1B\x28\x42)/"=?ISO-2022-JP?B?" . encode_base64($1,'') . "?="/eg;
               $encoded_to =~ s/(\x1B\x24\x42.+\x1B\x28\x42)/"=?ISO-2022-JP?B?" . encode_base64($1,'') . "?="/eg;
           }

           print $client "From: $encoded_from$crlf";
           print $client "To: $encoded_to$crlf";
           print $client "Date: " . $parser->get_header('date') . "$crlf";
           print $client "Subject:$msg_subject$crlf" if (defined($msg_subject));
           print $client "X-Text-Classification: $classification$crlf" if ($xtc_insertion);
           print $client "X-POPFile-Link: $xpl$crlf" if ($xpl_insertion);
           print $client "MIME-Version: 1.0$crlf";
           print $client "Content-Type: multipart/report; boundary=\"$slot\"$crlf$crlf--$slot$crlf";
           print $client "Content-Type: text/plain";
           print $client "; charset=iso-2022-jp" if ($parser->lang() eq 'Nihongo');
           print $client "$crlf$crlf";
           print $client "POPFile has quarantined a message.  It is attached to this email.$crlf$crlf";
           print $client "Quarantined Message Detail$crlf$crlf";

           print $client "Original From: $orig_from$crlf";
           print $client "Original To: $orig_to$crlf";
           print $client "Original Subject: $orig_subject$crlf";

           print $client "To examine the email open the attachment. ";
           print $client "To change this mail's classification go to $xpl$crlf";
           print $client "$crlf";
           print $client "The first 20 words found in the email are:$crlf$crlf";

           my $first20 = $parser->first20();
           if ($parser->lang() eq 'Nihongo') {
               require Encode;

               Encode::from_to($first20, 'euc-jp', 'iso-2022-jp');
           }

           print $client $first20;
           print $client "$crlf--$slot$crlf";
           print $client "Content-Type: message/rfc822$crlf$crlf";
        }

        print $client $msg_head_before;
        print $client $msg_head_after;
        print $client $msg_body;
    }

    my $before_dot = '';

    if ($quarantine && $echo) {
        $before_dot = "$crlf--$slot--$crlf";
    }

    my $need_dot = 0;

    if ($got_full_body) {
        $need_dot = 1;
    } else {
        $need_dot = !$self->echo_to_dot($mail, $echo?$client:undef, $nosave?undef:'>>' . $msg_file, $before_dot) && !$nosave;
    }

    if ($need_dot) {
        print $client $before_dot if ($before_dot ne '');
        print $client ".$crlf"    if ($echo);
    }

    # In some cases it's possible (and totally illegal) to get a . in
    # the middle of the message, to cope with the we call flush_extra_
    # here to remove any extra stuff the POP3 server is sending Make
    # sure to supress output if we are not echoing, and to save to
    # file if not echoing and saving

    unless ($nosave || $echo) {
        # if we're saving (not nosave) and not echoing, we can safely
        # unload this into the temp file

        if (open FLUSH, ">$msg_file.flush") {
            binmode FLUSH;

            # TODO: Do this in a faster way (without flushing to one
            # file then copying to another) (perhaps a select on $mail
            # to predict if there is flushable data)

            $self->flush_extra($mail, \*FLUSH, 0);
            close FLUSH;

            # append any data we got to the actual temp file

            if (((-s "$msg_file.flush") > 0) && (open FLUSH, "<$msg_file.flush")) {
                binmode FLUSH;
                if (open TEMP, ">>$msg_file") {
                    binmode TEMP;

                    # The only time we get data here is if it is after
                    # a CRLF.CRLF We have to re-create it to avoid
                    # data-loss

                    print TEMP ".$crlf";

                    print TEMP $_ while (<FLUSH>);

                    # NOTE: The last line flushed MAY be a CRLF.CRLF,
                    # which isn't actually part of the message body

                    close TEMP;
                }
                close FLUSH;
            }
            unlink("$msg_file.flush");
        }
    } else {
        # if we are echoing, the client can make sure we have no data
        # loss otherwise, the data can be discarded (not saved and not
        # echoed)

        $self->flush_extra($mail, $client, $echo?0:1);
    }

    if ($class eq '') {
        if ($nosave) {
            $history->release_slot($slot);
        } else {
            $history->commit_slot($session, $slot, $classification, $magnet_detail);
        }
    }

    return ($classification, $slot, $magnet_used);
}

=head2 get_buckets

Returns a list containing all the real bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_buckets($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $buckets->names($db_bucketid, $userid)
}

=head2 get_bucket_objects

Returns a list of Classifier::Bucket objects for all non-pseudo buckets,
each populated with name, color, count, and prior from the in-memory cache.

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_bucket_objects ($session) {
    my $userid = $self->valid_session_key($session);
    return ()
        unless defined $userid;
    my @result;
    for my $name ($self->get_buckets($session)) {
        my $b = Classifier::Bucket->new(
            name   => $name,
            color  => $self->get_bucket_parameter($session, $name, 'color'),
            count  => $db_bucketcount->{$userid}{$name} // 0,
            prior  => $bucket_start->{$userid}{$name} // 0,
        );
        push @result, $b;
    }
    return @result
}

=head2 get_bucket_id

Returns the internal ID for a bucket for database calls

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket name

=cut

method get_bucket_id ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless (defined($db_bucketid->{$userid}{$bucket}));

    return $db_bucketid->{$userid}{$bucket}{id};
}

=head2 get_bucket_name

Returns the name of a bucket from an internal ID

C<$session> A valid session key returned by a call to get_session_key
C<$id> The bucket id

=cut

method get_bucket_name ($session, $id) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    for $b (keys $db_bucketid->{$userid}->%*) {
        if ($id == $db_bucketid->{$userid}{$b}{id}) {
            return $b;
        }
    }

    return '';
}

=head2 get_pseudo_buckets

Returns a list containing all the pseudo bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_pseudo_buckets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my @buckets;

    for my $b (sort keys $db_bucketid->{$userid}->%*) {
        if ($db_bucketid->{$userid}{$b}{pseudo} == 1) {
            push @buckets, ($b);
        }
    }

    return @buckets;
}

=head2 get_all_buckets

Returns a list containing all the bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_all_buckets ($session) {
    if (my $userid = $self->valid_session_key($session)) {
        return sort keys $db_bucketid->{$userid}->%*
    }
    $self->log_msg(WARN => 'Could not get user ID');
    return
}

=head2 is_pseudo_bucket

Returns 1 if the named bucket is pseudo

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to check

=cut

method is_pseudo_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return (defined($db_bucketid->{$userid}{$bucket}) &&
             $db_bucketid->{$userid}{$bucket}{pseudo});
}

=head2 is_bucket

Returns 1 if the named bucket is a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to check

=cut

method is_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return (defined($db_bucketid->{$userid}{$bucket}) &&
        !$db_bucketid->{$userid}{$bucket}{pseudo});
}

=head2 get_bucket_word_count

Returns the total word count (including duplicates) for the passed in bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_word_count ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->bucket_count($db_bucketcount, $userid, $bucket)
}

=head2 get_bucket_word_list

Returns a list of words all with the same first character

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired
C<$prefix> The first character of the words

=cut

method get_bucket_word_list ($session, $bucket, $prefix) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$bucket};
    return $corpus->word_list_for_bucket($self->db(),
        $db_bucketid->{$userid}{$bucket}{id}, $prefix)
}

=head2 get_words_for_bucket

Returns a paginated list of words for a bucket sorted by Laplace-smoothed
relevance descending: C<bucket_count / (total_count + 10)>.  This surfaces
words that are both frequent and strongly associated with the bucket, while
burying single-occurrence noise and near-neutral stopwords.

C<$session> A valid session key
C<$bucket> Bucket name
C<%opts> page (1-based), per_page

Returns a hashref with keys: words (arrayref of hashrefs), total (int).

=cut

method get_words_for_bucket ($session, $bucket, %opts) {
    my $userid = $self->valid_session_key($session);
    return { words => [], total => 0 }
        unless defined $userid;
    return { words => [], total => 0 }
        unless exists $db_bucketid->{$userid}{$bucket};
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $offset = ($page - 1) * $per_page;
    my $dir  = ($opts{dir} // '') eq 'asc' ? 'ASC' : 'DESC';
    my $sort = $opts{sort} // 'relevance';
    my ($words, $total) = $corpus->bucket_word_page(
        $self->db(), $db_bucketid->{$userid}{$bucket}{id},
        $sort, $dir, $per_page, $offset);
    return { words => $words, total => $total }
}

=head2 search_words_cross_bucket

Search words across all non-pseudo buckets, returning per-bucket counts.

C<$session> A valid session key
C<$prefix> Word prefix to search (empty matches all)
C<%opts> sort (word|coverage|total|<bucket-name>), dir (asc|desc), page, per_page

Returns hashref: { words => [...], total => N, buckets => [...] }.

=cut

method search_words_cross_bucket ($session, $prefix, %opts) {
    my $userid = $self->valid_session_key($session);
    return { words => [], total => 0, buckets => [] }
        unless defined $userid;
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $sort = $opts{sort} // 'word';
    my $dir = ($opts{dir} // '') eq 'desc' ? 'DESC' : 'ASC';
    my $bucket_filter = $opts{bucket} // '';
    my @bucket_names = map { $_->[0] }
        $self->validate_sql_prepare_and_execute(
            'SELECT name FROM buckets WHERE userid = ? AND pseudo = 0 ORDER BY name',
            $userid)->fetchall_arrayref->@*;
    return { words => [], total => 0, buckets => \@bucket_names }
        unless @bucket_names;
    return { words => [], total => 0, buckets => \@bucket_names }
        if $bucket_filter ne '' && !(grep { $_ eq $bucket_filter } @bucket_names);
    my %stopwords = map { $_ => 1 } $self->get_stopword_list($session);
    my ($paged_words, $total, $bucket_data) =
        $self->_search_words_fetch($userid, $prefix, $bucket_filter, $sort, $dir, $per_page, ($page - 1) * $per_page);
    return { words => [], total => $total, buckets => \@bucket_names }
        unless $paged_words->@*;
    my @result = map {
        my $word = $_;
        my %b = map { $_ => ($bucket_data->{$word}{$_} // 0) } @bucket_names;
        my $cov = scalar grep { $b{$_} > 0 } @bucket_names;
        { word => $word,
          buckets => \%b,
          coverage => $cov,
          is_stopword => exists $stopwords{$word} ? \1 : \0 }
    } $paged_words->@*;
    return { words => \@result, total => $total, buckets => \@bucket_names }
}

method _search_words_fetch ($userid, $prefix, $bucket_filter, $sort, $dir, $per_page, $offset) {
    return $corpus->search_words_cross($self->db(), $self->qb(),
        $userid, $prefix, $bucket_filter, $sort, $dir, $per_page, $offset)
}

=head2 get_word_by_id

Returns the word string for a given word ID, or undef if not found.

C<$id> Word ID from the words table

=cut

method get_word_by_id ($id) {
    return $corpus->word_for_id($self->db(), $id)
}

=head2 remove_word_from_bucket

Removes a word from a bucket's corpus (deletes the matrix row).

C<$session> A valid session key
C<$bucket>  Bucket name
C<$word>    Word to remove

=cut

method remove_word_from_bucket ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$bucket};
    $corpus->remove_word($self->db(),
        $db_bucketid->{$userid}{$bucket}{id}, $word);
    $self->db_update_cache($session, $bucket);
}

=head2 move_word_between_buckets

Moves a word's count from one bucket to another in the matrix.

C<$session>     A valid session key
C<$from_bucket> Source bucket name
C<$to_bucket>   Target bucket name
C<$word>        Word to move

=cut

method move_word_between_buckets ($session, $from_bucket, $to_bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$from_bucket}
            && exists $db_bucketid->{$userid}{$to_bucket};
    my $from_id = $db_bucketid->{$userid}{$from_bucket}{id};
    my $to_id = $db_bucketid->{$userid}{$to_bucket}{id};
    $corpus->move_word($self->db(), $from_id, $to_id, $word);
    $self->db_update_cache($session, $from_bucket);
    $self->db_update_cache($session, $to_bucket);
}

=head2 get_bucket_word_prefixes

Returns a list of all the initial letters of words in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_word_prefixes($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    my $prev = '';
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $result = $corpus->raw_word_prefixes($self->db(), $bucketid);
    if (($self->module_config('api', 'locale')//'') eq 'Nihongo') {
        return
            grep {$_ ne $prev && ($prev = $_, 1)}
            sort
            map {substr_euc($_,0,1)}
            $result->@*;
    } else {
        if  (($self->module_config('api', 'locale') // '') eq 'Korean') {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {$_ =~ /([\x20-\x80]|$eksc)/} $result->@*;
        } else {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr($_,0,1)} $result->@*;
        }
    }
}

=head2 get_word_count

Returns the total word count (including duplicates)

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_word_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->total_count($db_bucketcount, $db_bucketid, $userid)
}

=head2 get_count_for_word

Returns the number of times the word occurs in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket we are asking about
C<$word> The word we are asking about

=cut

method get_count_for_word ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $self->get_base_value($session, $bucket, $word);
}

=head2 get_bucket_unique_count

Returns the unique word count (excluding duplicates) for the passed
in bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_unique_count ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->bucket_unique($db_bucketunique, $userid, $bucket)
}

=head2 get_unique_word_count

Returns the unique word count (excluding duplicates) for all buckets

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_unique_word_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->total_unique($db_bucketunique, $db_bucketid, $userid)
}

=head2 get_bucket_color

Returns the color associated with a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the color is requested
C<NOTE> This API is DEPRECATED in favor of calling get_bucket_parameter for
      the parameter named 'color'

=cut

method get_bucket_color ($session, $bucket) {
    return $self->get_bucket_parameter($session, $bucket, 'color');
}

=head2 set_bucket_color

Returns the color associated with a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the color is requested
C<$color> The new color
C<NOTE> This API is DEPRECATED in favor of calling set_bucket_parameter for
      the parameter named 'color'

=cut

method set_bucket_color ($session, $bucket, $color) {
    return $self->set_bucket_parameter($session, $bucket, 'color', $color);
}

=head2 get_bucket_parameter

Returns the value of a per bucket parameter

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket
C<$parameter> The name of the parameter

=cut

method get_bucket_parameter ($session, $bucket, $parameter) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $buckets->parameter_get($self->db(), $userid, $bucket,
        $db_bucketid->{$userid}{$bucket}{id}, $parameter)
}

=head2 set_bucket_parameter

Sets the value associated with a bucket specific parameter

=cut

method set_bucket_parameter ($session, $bucket, $parameter, $value) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $buckets->parameter_set($self->db(), $userid, $bucket,
        $db_bucketid->{$userid}{$bucket}{id}, $parameter, $value)
}

=head2 create_bucket

Creates a new bucket, returns 1 if the creation succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name for the new bucket

=cut

method create_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        if $self->is_bucket($session, $bucket)
        || $self->is_pseudo_bucket($session, $bucket);
    return 0
        unless $buckets->name_is_valid($bucket);
    $buckets->create_in_db($self->db(), $userid, $bucket);
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 delete_bucket

Deletes a bucket, returns 1 if the delete succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to delete

=cut

method delete_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    $buckets->delete_from_db($self->db(), $userid, $bucket);
    $self->db_update_cache($session, undef, $bucket);
    $history->force_requery();
    return 1
}

=head2 rename_bucket

Renames a bucket, returns 1 if the rename succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$old_bucket> The old name of the bucket
C<$new_bucket> The new name of the bucket

=cut

method rename_bucket ($session, $old_bucket, $new_bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    unless (defined $db_bucketid->{$userid}{$old_bucket}) {
        $self->log_msg(WARN => "Bad bucket name $old_bucket to rename_bucket");
        return 0
    }
    if (defined $db_bucketid->{$userid}{$new_bucket}) {
        $self->log_msg(WARN => "Bucket named $new_bucket already exists");
        return 0
    }
    return 0
        unless $buckets->name_is_valid($new_bucket);
    $self->log_msg(INFO => "Rename bucket $old_bucket to $new_bucket");
    $buckets->rename_in_db($self->db(),
        $db_bucketid->{$userid}{$old_bucket}{id}, $new_bucket);
    $self->db_update_cache($session, $new_bucket, $old_bucket);
    $history->force_requery();
    return 1
}

=head2 add_messages_to_bucket

Parses mail messages and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
@files           List of file names to parse

=cut

method add_messages_to_bucket ($session, $bucket, @files) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    # This is done to clear out the word list because in the loop
    # below we are going to not reset the word list on each parse

    $parser->start_parse();
    $parser->stop_parse();

    for my $file (@files) {
        $parser->parse_file($file, $self->global_config('message_cutoff'), 0);
    }

    $self->add_words_to_bucket($session, $bucket, 1);
    $self->db_update_cache($session, $bucket);

    return 1;
}

=head2 train_messages_batch

Parses a list of raw message texts and trains them all into C<$bucket> in a
single DB transaction.  Aggregates word counts across all messages before
writing.

C<$session>  A valid session key returned by a call to get_session_key
C<$bucket>   Name of the bucket to train into
C<$texts>    Array-ref of raw message text strings

=cut

method train_messages_batch ($session, $bucket, $texts) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    $parser->start_parse();
    $parser->stop_parse();
    for my $text ($texts->@*) {
        $parser->start_parse(0);
        $parser->parse_line($_) for split /(?<=\n)/, $text;
        $parser->stop_parse();
    }
    $self->add_words_to_bucket($session, $bucket, 1);
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 add_message_to_bucket

Parses a mail message and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
C<$file> Name of file containing mail message to parse

=cut

method add_message_to_bucket ($session, $bucket, $file) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        $self->log_msg(WARN => "add_message_to_bucket: bucket '$bucket' not found for user=$userid file=" . ($file // 'undef'));
        return 0;
    }

    my $result = $self->add_messages_to_bucket($session, $bucket, $file);
    $self->log_msg(5, "add_message_to_bucket: user=$userid bucket=$bucket file=" . ($file // 'undef') . " result=" . (defined $result ? $result : 'undef'));
    return $result;
}

=head2 remove_message_from_bucket

Parses a mail message and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
C<$file> Name of file containing mail message to parse

=cut

method remove_message_from_bucket ($session, $bucket, $file) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    $parser->parse_file($file,
        $self->global_config('message_cutoff'));
        $self->add_words_to_bucket($session, $bucket, -1);
        $self->db_update_cache($session, $bucket);

    return 1;
}

=head2 get_buckets_with_magnets

Returns the names of the buckets for which magnets are defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_buckets_with_magnets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->get_buckets_with($self->db(), $userid)
}

=head2 get_magnet_types_in_bucket

Returns the types of the magnets in a specific bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to search for magnets

=cut

method get_magnet_types_in_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->get_types_in_bucket($self->db(), $db_bucketid->{$userid}{$bucket}{id})
}

=head2 clear_bucket

Removes all words from a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to clear

=cut

method clear_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    $buckets->clear_bucket_words($self->db(),
        $db_bucketid->{$userid}{$bucket}{id});
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 clear_magnets

Removes every magnet currently defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method clear_magnets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->clear($self->db(), $userid)
}

=head2 get_magnets

Returns the magnets of a certain type in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to search for magnets
C<$type> The magnet type (e.g. from, to or subject)

=cut

method get_magnets ($session, $bucket, $type) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket}
            && defined $type;
    return $magnets->get($self->db(), $db_bucketid->{$userid}{$bucket}{id}, $type)
}

=head2 get_magnet_types

Get a hash mapping magnet types (e.g. from) to magnet names (e.g. From);

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_magnet_types ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->get_types($self->db())
}

=head2 create_magnet

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket the magnet belongs in
C<$type> The magnet type (e.g. from, to or subject)
C<$text> The text of the magnet

Creates a new magnet in C<$bucket>.

=cut

method create_magnet ($session, $bucket, $type, $text) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->create($self->db(), $db_bucketid->{$userid}{$bucket}{id}, $type, $text)
}

=head2 delete_magnet

    $self->delete_magnet($session, $bucket, $type, $text);

Removes the magnet with type C<$type> and value C<$text> from C<$bucket>.

=cut

method delete_magnet ($session, $bucket, $type, $text) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->delete($self->db(), $db_bucketid->{$userid}{$bucket}{id}, $type, $text,
        sub { $history->force_requery() })
}

=head2 get_stopword_list

Gets the complete list of stop words

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_stopword_list ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $stopwords->get_list($parser->mangle(), $userid)
}

=head2 get_stopword_candidates

    my @candidates = $self->get_stopword_candidates($session, $ratio, $limit);

Returns words that appear in every non-pseudo bucket with a max-to-min
per-bucket frequency ratio below C<$ratio>.  These words carry little
discriminative power.  C<$limit> caps the result set (default 50).

Each entry is a hashref with C<word>, C<min_count>, C<max_count>, and C<ratio>.

=cut

method get_stopword_candidates ($session, $ratio = 2.0, $limit = 50) {
    my $userid = $self->valid_session_key($session);
    return ()
        unless defined $userid;
    return $stopwords->get_candidates($self->db(), $userid, $ratio, $limit)
}

=head2 magnet_count

Gets the number of magnets that are defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method magnet_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->count($self->db(), $userid)
}

=head2 set_history

    $self->set_history($history_obj);

Injects the C<POPFile::History> object used to record classified messages.

=cut

method set_history($h) {
    $history = $h;
}

# end class Classifier::Bayes

1;
