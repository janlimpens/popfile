# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Classifier::Bayes;

use Object::Pad;
use feature qw(state try);
no warnings 'experimental::try';
use locale;
use Classifier::Bucket;
use Classifier::MailParse;
use POPFile::Role::DBConnect;
use POPFile::Role::SQL;
use IO::Handle;
use DBI;
use Digest::MD5 qw(md5_hex);
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
field $db_get_buckets = 0;
field $db_get_wordid = 0;
field $db_get_word_count = 0;
field $db_put_word_count = 0;
field $db_get_unique_word_count = 0;
field $db_get_bucket_word_counts = 0;
field $db_get_bucket_word_count = 0;
field $db_get_full_total = 0;
field $db_get_bucket_parameter = 0;
field $db_set_bucket_parameter = 0;
field $db_get_bucket_parameter_default = 0;
field $db_get_buckets_with_magnets = 0;
field $db_delete_zero_words = 0;
field $db_get_userid = 0;

# Temporary per-call prepared statements (undef'd after use)
field $db_getwords;
field $db_classify;
field $get_wordids;

# Caches the name of each bucket — subkeys: id, pseudo
field $db_bucketid = {};

# Caches the IDs that map to parameter types
field $db_parameterid = {};

# Caches looked up parameter values on a per bucket basis
field $db_parameters = {};

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

# DEPRECATED: only used when upgrading old flat-file corpus files
field $corpus_version = 1;

# Unclassified cutoff: top probability must be this many times greater
# than the second probability (default 100×)
field $unclassified = log(100);

field $magnet_used = 0;
field $magnet_detail = 0;

# Maps session keys to user ids (see get_session_key / release_session_key)
field $api_sessions = {};

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

    # The corpus is kept in the 'corpus' subfolder of POPFile
    #
    # DEPRECATED This is only used to find an old corpus that might
    # need to be upgraded

    $self->config(corpus => 'corpus');

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
            $self->release_session_key_private($message[0]);
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

    return 0
        unless $self->db_connect();

    if ($language eq 'Nihongo') {
        # Setup Nihongo (Japanese) parser.

        my $nihongo_parser = $self->config('nihongo_parser');

        $nihongo_parser = $parser->setup_nihongo_parser($nihongo_parser);

        $self->log_msg(DEBUG => "Use Nihongo (Japanese) parser : $nihongo_parser");
        $self->config(nihongo_parser => $nihongo_parser);
    }

    $self->upgrade_predatabase_data();

    return 1;
}

=head2 stop

Called when POPFile is terminating

=cut

method stop() {
    $self->db_disconnect();
    $db_bucketid = {};
    $db_parameters = {};
    $db_parameterid = {};
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

    my $word_expr = $self->qb()->compare('w.word', \@words);
    my $sth = $self->db()->prepare($self->normalize_sql(
        "SELECT w.word, m.bucketid, m.times
         FROM words w
         JOIN matrix m ON m.wordid = w.id
         JOIN buckets b ON b.id = m.bucketid
                        AND b.userid = ?
                        AND b.pseudo = 0
         WHERE " . $word_expr->as_sql()));
    $sth->execute($userid, $word_expr->params());

    my %best_prob;
    my %best_name;
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

    my %colors;
    for my $word (keys %best_name) {
        $colors{$word} = $self->get_bucket_color($session, $best_name{$word});
    }
    return %colors
}

=head2 get_not_likely_

Returns the probability of a word that doesn't appear

=cut

method get_not_likely ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $not_likely->{$userid};
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
    my $value = $self->db_get_word_count($session, $bucket, $word);
    if (defined($value)) {
        return $value;
    } else {
        return 0;
    }
}

=head2 set_value_

Sets the value for a word in a bucket and updates the total word
counts for the bucket and globally

=cut

method set_value ($session, $bucket, $word, $value) {
    if ($self->db_put_word_count($session, $bucket, $word, $value) == 1) {
    my $userid = $self->valid_session_key($session);
        my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
        $self->validate_sql_prepare_and_execute(
            $db_delete_zero_words, $bucketid);
        return 1;
    } else {
        return 0;
    }
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
        return $not_likely->{$userid}
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

    if ($wc > 0)  {
        $not_likely->{$userid} = -log(10 * $wc);

        for my $bucket ($self->get_buckets($session)) {
            my $total = $self->get_bucket_word_count($session, $bucket);
            if ($total != 0) {
                $bucket_start->{$userid}{$bucket} = log($total / $wc);
            } else {
                $bucket_start->{$userid}{$bucket} = 0;
            }
        }
    } else {
        $not_likely->{$userid} = 0;
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
    my $need_convert = 0;
    my $old_dbh;

    if ($sqlite && $dbpresent) {
        # Check if the database is SQLite2 format

        open my $dbfile, '<', $dbname;
        my $buffer;
        my $readed = sysread($dbfile, $buffer, 47);
        close $dbfile;

        if ($buffer eq '** This file contains an SQLite 2.1 database **') {
            $self->log_msg(WARN => 'SQLite 2 database found. Try to upgrade');

            # Test DBD::SQLite version

            my $ver = -1;
            try {
                require DBD::SQLite;
                $ver = $DBD::SQLite::VERSION;
            }
            catch ($e) {}

            if ($ver ge '1.00') {
                $self->log_msg(INFO => "DBD::SQLite $ver found");

                # Backup SQLite2 database

                my $old_dbname = $dbname . '-sqlite2';
                unlink $old_dbname;
                rename $dbname, $old_dbname;

                # Connect to SQLite2 database

                my $old_dbconnect = $self->config('dbconnect');
                $old_dbconnect =~ s/SQLite:/SQLite2:/;
                $old_dbconnect =~ s/\$dbname/$old_dbname/g;

                $old_dbh = DBI->connect($old_dbconnect, $self->config('dbuser'), $self->config('dbauth'));
                # Update the config file

                $dbconnect = $self->config('dbconnect');
                $dbconnect =~ s/SQLite2:/SQLite:/;
                $self->config(dbconnect => $dbconnect);
                $dbconnect =~ s/\$dbname/$dbname/g;

                $need_convert = 1;
            }
        } else {
            # Update the config file

            $dbconnect = $self->config('dbconnect');
            $dbconnect =~ s/SQLite2:/SQLite:/;
            $self->config(dbconnect => $dbconnect);
            $dbconnect =~ s/\$dbname/$dbname/g;
        }
    }


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

        if ($need_convert) {
        $self->log_msg(WARN => 'Convert SQLite2 database to SQLite3 database');

        $self->db_upgrade($old_dbh);
            $old_dbh->disconnect;

            $self->log_msg(WARN => 'Database convert completed');
        }

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

    # Now prepare common SQL statements for use, as a matter of convention the
    # parameters to each statement always appear in the following order:
    #
    # user
    # bucket
    # word
    # parameter

    $db_get_buckets = $db->prepare($self->normalize_sql(
        'SELECT name, id, pseudo FROM buckets
         WHERE buckets.userid = ?'));
    $db_get_wordid = $db->prepare($self->normalize_sql(
        'SELECT id FROM words
         WHERE words.word = ? LIMIT 1'));
    $db_get_userid = $db->prepare($self->normalize_sql(
        'SELECT id FROM users
         WHERE name = ? AND password = ? LIMIT 1'));
    $db_get_word_count = $db->prepare($self->normalize_sql(
        'SELECT matrix.times FROM matrix
         WHERE matrix.bucketid = ? AND
            matrix.wordid = ? LIMIT 1'));
    $db_put_word_count = $db->prepare($self->normalize_sql(
        'REPLACE INTO matrix (bucketid, wordid, times, lastseen) VALUES (?, ?, ?, date(\'now\'))'));
    $db_get_bucket_word_counts = $db->prepare($self->normalize_sql(
        'SELECT sum(matrix.times), count(matrix.id), buckets.name FROM matrix, buckets
         WHERE matrix.bucketid = buckets.id
            AND buckets.userid = ?
         GROUP BY buckets.name'));
    $db_get_bucket_word_count = $db->prepare($self->normalize_sql(
        'SELECT sum(times), count(*) FROM matrix
         WHERE bucketid = ?'));
    $db_get_unique_word_count = $db->prepare($self->normalize_sql(
        'SELECT count(*) FROM matrix
         WHERE matrix.bucketid IN (
             SELECT buckets.id FROM buckets
             WHERE buckets.userid = ?)'));
    $db_get_full_total = $db->prepare($self->normalize_sql(
        'SELECT sum(matrix.times) FROM matrix
         WHERE matrix.bucketid IN (
             SELECT buckets.id FROM buckets
             WHERE buckets.userid = ?)'));
    $db_get_bucket_parameter = $db->prepare($self->normalize_sql(
        'SELECT bucket_params.val FROM bucket_params
         WHERE bucket_params.bucketid = ? AND
            bucket_params.btid = ?'));
    $db_set_bucket_parameter = $db->prepare($self->normalize_sql(
        'REPLACE INTO bucket_params (bucketid, btid, val) VALUES (?, ?, ?)'));
    $db_get_bucket_parameter_default = $db->prepare($self->normalize_sql(
        'SELECT bucket_template.def FROM bucket_template
         WHERE bucket_template.id = ?'));
    $db_get_buckets_with_magnets = $db->prepare($self->normalize_sql(
        'SELECT buckets.name FROM buckets, magnets
         WHERE buckets.userid = ?
            AND magnets.id != 0
            AND magnets.bucketid = buckets.id
         GROUP BY buckets.name
         ORDER BY buckets.name'));
    $db_delete_zero_words = $db->prepare($self->normalize_sql(
        'DELETE FROM matrix
         WHERE (matrix.times = 0 OR matrix.times IS NULL)
            AND matrix.bucketid = ?'));
    # Get the mapping from parameter names to ids into a local hash

    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT name, id FROM bucket_template');
        while (my $row = $h->fetchrow_arrayref) {
        $db_parameterid->{$row->[0]} = $row->[1];
    }
    $h->finish();
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

Upgrade the POPFile schema / Convert the database

C<$db_from> Database handle convert from
                 undef if upgrade POPFile schema

=cut

method db_upgrade ($db_from = undef) {
    my $drop_table;

    unless (defined($db_from)) {
        $drop_table = 1;
        $db_from = $self->db();
    }

    my $from_sqlite = ($db_from->{Driver}->{Name} =~ /SQLite/);
    my $to_sqlite = ($self->db()->{Driver}->{Name} =~ /SQLite/);

    my $sqlquotechar = $db_from->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } ($db_from->tables());

    # We are going to dump out all the data in the database as
    # INSERT OR IGNORE statements in a temporary file, then DROP all
    # the tables in the database, then recreate the schema from the
    # new schema and finally rerun the inserts.

    my $i = 0;
    my $ins_file = $self->get_user_path('insert.sql');
    open INSERT, '>' . $ins_file;

    for my $table (@tables) {
        next if ($table =~ /\.?popfile$/);
        if ($from_sqlite && ($table =~ /^sqlite_/)) {
            next;
        }
        if ($i > 99) {
            print "\n";
        }
        print "    Saving table $table\n    ";

        my $t = $db_from->prepare("select * from $table;");
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

            if ($to_sqlite) {
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
                    $val = $self->db_quote($val);
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

    if ($drop_table) {
        for my $table (@tables) {
            if ($from_sqlite && ($table =~ /^sqlite_/)) {
                next;
            }
            print "    Dropping old table $table\n";
            $self->db()->do("DROP TABLE $table;");
        }
    }

    print "    Inserting new database schema\n";
    if (!$self->insert_schema($to_sqlite)) {
        return 0;
    }

    print "    Restoring old data\n    ";

    $self->db()->begin_work;
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
        $self->db()->do($_);
    }
    close INSERT;
    $self->db()->commit;

    unlink $ins_file;
}

=head2 db_disconnect

Disconnect from the POPFile database

=cut

method db_disconnect() {
    return
        unless ref $db_get_buckets;
    $db_get_buckets->finish();
    $db_get_wordid->finish();
    $db_get_userid->finish();
    $db_get_word_count->finish();
    $db_put_word_count->finish();
    $db_get_bucket_word_counts->finish();
    $db_get_bucket_word_count->finish();
    $db_get_unique_word_count->finish();
    $db_get_full_total->finish();
    $db_get_bucket_parameter->finish();
    $db_set_bucket_parameter->finish();
    $db_get_bucket_parameter_default->finish();
    $db_get_buckets_with_magnets->finish();
    $db_delete_zero_words->finish();

    # Avoid DBD::SQLite 'closing dbh with active statement handles' bug

    undef $db_get_buckets;
    undef $db_get_wordid;
    undef $db_get_userid;
    undef $db_get_word_count;
    undef $db_put_word_count;
    undef $db_get_bucket_word_counts;
    undef $db_get_bucket_word_count;
    undef $db_get_unique_word_count;
    undef $db_get_full_total;
    undef $db_get_bucket_parameter;
    undef $db_set_bucket_parameter;
    undef $db_get_bucket_parameter_default;
    undef $db_get_buckets_with_magnets;
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

    delete $db_bucketid->{$userid};

    $self->validate_sql_prepare_and_execute($db_get_buckets, $userid);
    while (my $row = $db_get_buckets->fetchrow_arrayref) {
        $db_bucketid->{$userid}{$row->[0]}{id} = $row->[1];
        $db_bucketid->{$userid}{$row->[0]}{pseudo} = $row->[2];
    }

    my $updated = 0;

    if (defined($updated_bucket) &&
         defined($db_bucketid->{$userid}{$updated_bucket})) {
        my $bucketid = $db_bucketid->{$userid}{$updated_bucket}{id};
        $self->validate_sql_prepare_and_execute(
            $db_get_bucket_word_count, $bucketid);
        my $row = $db_get_bucket_word_count->fetchrow_arrayref;

        $db_bucketcount->{$userid}{$updated_bucket} =
            (defined($row->[0]) ? $row->[0] : 0);
        $db_bucketunique->{$userid}{$updated_bucket} = $row->[1];

        $updated = 1;
    }

    if (defined($deleted_bucket) &&
         !defined($db_bucketid->{$userid}{$deleted_bucket})) {
        # Delete cache for specified bucket.

        delete $db_bucketcount->{$userid}{$deleted_bucket};
        delete $db_bucketunique->{$userid}{$deleted_bucket};

        $updated = 1;
    }

    if (!$updated) {
        delete $db_bucketcount->{$userid};
        delete $db_bucketunique->{$userid};

        $self->validate_sql_prepare_and_execute(
            $db_get_bucket_word_counts, $userid);
        for my $b (sort keys $db_bucketid->{$userid}->%*) {
            $db_bucketcount->{$userid}{$b} = 0;
            $db_bucketunique->{$userid}{$b} = 0;
        }

        while (my $row = $db_get_bucket_word_counts->fetchrow_arrayref) {
            $db_bucketcount->{$userid}{$row->[2]} = $row->[0];
            $db_bucketunique->{$userid}{$row->[2]} = $row->[1];
        }
    }

    $self->update_constants($session);
}

=head2 db_get_word_count

Return the 'count' value for a word in a bucket.  If the word is not
found in that bucket then returns undef.

C<$session> Valid session ID from get_session_key
C<$bucket> bucket word is in
C<$word> word to lookup

=cut

method db_get_word_count ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined($userid);

    $self->validate_sql_prepare_and_execute($db_get_wordid, $word);
    my $result = $db_get_wordid->fetchrow_arrayref;
    unless (defined($result)) {
        return;
    }

    my $wordid = $result->[0];

    $self->validate_sql_prepare_and_execute(
        $db_get_word_count,
        $db_bucketid->{$userid}{$bucket}{id}, $wordid);
    $result = $db_get_word_count->fetchrow_arrayref;
    if (defined($result)) {
         return $result->[0];
    } else {
         return;
    }
}

=head2 db_put_word_count

Update 'count' value for a word in a bucket, if the update fails
then returns 0 otherwise is returns 1

C<$session> Valid session ID from get_session_key
C<$bucket> bucket word is in
C<$word> word to update
C<$count> new count value

=cut

method db_put_word_count ($session, $bucket, $word, $count) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return 0 unless defined $count && $count > 0;

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    unless (defined $bucketid) {
        $self->log_msg(WARN => "db_put_word_count: bucketid undef for user=$userid bucket=$bucket word=$word");
        return 0;
    }

    my $result = $self->validate_sql_prepare_and_execute(
        $db_get_wordid, $word)->fetchrow_arrayref;
    unless (defined($result)) {
        $self->validate_sql_prepare_and_execute(
            'insert into words (word) values (?);', $word);
        $result = $self->validate_sql_prepare_and_execute(
            $db_get_wordid, $word)->fetchrow_arrayref;
    }

    my $wordid = $result->[0];

    $self->validate_sql_prepare_and_execute(
        $db_put_word_count, $bucketid, $wordid, $count);
    return 1;
}

=head2 upgrade_predatabase_data

Looks for old POPFile data (in flat files or BerkeleyDB tables) and
upgrades it to the SQL database.  Data upgraded is removed.

=cut

method upgrade_predatabase_data() {
    my $possible_colors = [qw(
        red green blue brown
        orange purple magenta gray
        plum silver pink lightgreen
        lightblue lightcyan lightcoral lightsalmon
        lightgrey darkorange darkcyan feldspar
        black)];
    my $c = 0;

    # There's an assumption here that this is the single user version
    # of POPFile and hence what we do is cheat and get a session key
    # assuming that the user name is admin with password ''

    my $session = $self->get_session_key('admin', '');

    unless (defined($session)) {
        $self->log_msg(WARN => "Tried to get the session key for user admin and failed; cannot upgrade old data");
        return;
    }

    my @buckets = glob $self->get_user_path($self->config('corpus') . '/*');

    for my $bucket (@buckets) {
        # A bucket directory must be a directory

        next
            unless (-d $bucket);
        next
            unless (-e "$bucket/table") || (-e "$bucket/table.db");

        return 0
            if (!$self->upgrade_bucket($session, $bucket));

        my $color = '';

        # See if there's a color file specified
        if (open COLOR, '<' . "$bucket/color") {
            $color = <COLOR>;

            # Someone (who shall remain nameless) went in and manually created
            # empty color files in their corpus directories which would cause
            # $color at this point to be undefined and hence you'd get warnings
            # about undefined variables below.  So this little test is to deal
            # with that user and to make POPFile a little safer which is always
            # a good thing

            unless (defined($color)) {
                $color = '';
            } else {
                $color =~ s/[\r\n]//g;
            }
            close COLOR;
            unlink "$bucket/color";
        }

        $bucket =~ /([[:alpha:]0-9-_]+)$/;
        $bucket =  $1;

        $self->set_bucket_color($session, $bucket, ($color eq '')?$possible_colors->[$c]:$color);

        $c = ($c+1) % scalar $possible_colors->@*;
    }

    $self->release_session_key($session);

    return 1;
}

=head2 upgrade_bucket

Loads an individual bucket

C<$session> Valid session key from get_session_key
C<$bucket> The bucket name

=cut

method upgrade_bucket ($session, $bucket) {
    $bucket =~ /([[:alpha:]0-9-_]+)$/;
    $bucket =  $1;

    $self->create_bucket($session, $bucket);

    if (open PARAMS, '<' . $self->get_user_path($self->config('corpus') . "/$bucket/params")) {
        while (<PARAMS>)  {
            s/[\r\n]//g;
            if (/^([[:lower:]]+) ([^\r\n\t ]+)$/)  {
                $self->set_bucket_parameter($session, $bucket, $1, $2);
            }
        }
        close PARAMS;
        unlink $self->get_user_path($self->config('corpus') . "/$bucket/params");
    }

    # Pre v0.21.0 POPFile had GLOBAL parameters for subject modification,
    # XTC and XPL insertion.  To make the upgrade as clean as possible
    # check these parameters so that if they were OFF we set the equivalent
    # per bucket to off

    for my $gl ('subject', 'xtc', 'xpl') {
        $self->log_msg(INFO => "Checking deprecated parameter GLOBAL_$gl for $bucket\n");
        my $val = $self->configuration()->deprecated_parameter("GLOBAL_$gl");
        if (defined($val) && ($val == 0)) {
            $self->log_msg(INFO => "GLOBAL_$gl is 0 for $bucket, overriding $gl\n");
            $self->set_bucket_parameter($session, $bucket, $gl, 0);
        }
    }

    # See if there are magnets defined
    if (open MAGNETS, '<' . $self->get_user_path($self->config('corpus') . "/$bucket/magnets")) {
        while (<MAGNETS>)  {
            s/[\r\n]//g;

            # Because of a bug in v0.17.9 and earlier of POPFile the text of
            # some magnets was getting mangled by certain characters having
            # a \ prepended.  Code here removes the \ in these cases to make
            # an upgrade smooth.

            if (/^([^ ]+) (.+)$/)  {
                my $type = $1;
                my $value = $2;

                $value =~ s/^[ \t]+//g;
                $value =~ s/[ \t]+$//g;

                $value =~ s/\\(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/$1/g;
                $self->create_magnet($session, $bucket, $type, $value);
            } else {
                # This branch is used to catch the original magnets in an
                # old version of POPFile that were just there for from
                # addresses only

                if (/^(.+)$/) {
                    my $value = $1;
                    $value =~ s/\\(\?|\*|\||\(|\)|\[|\]|\{|\}|\^|\$|\.)/$1/g;
                    $self->create_magnet($session, $bucket, 'from', $value);
                }
            }
        }
        close MAGNETS;
        unlink $self->get_user_path($self->config('corpus') . "/$bucket/magnets");
    }

    # If there is no existing table but there is a table file (the old style
    # flat file used by POPFile for corpus storage) then create the new
    # database from it thus performing an automatic upgrade.

    if (-e $self->get_user_path($self->config('corpus') . "/$bucket/table")) {
        $self->log_msg(WARN => "Performing automatic upgrade of $bucket corpus from flat file to DBI");

        $self->db()->begin_work();

        if (open WORDS, '<' . $self->get_user_path($self->config('corpus') . "/$bucket/table"))  {
            my $wc = 1;

            my $first = <WORDS>;
            if (defined($first) && ($first =~ s/^__CORPUS__ __VERSION__ (\d+)//)) {
                if ($1 != $corpus_version)  {
                    print STDERR "Incompatible corpus version in $bucket\n";
                    close WORDS;
                    $self->db()->rollback;
                    return 0;
                } else {
                    $self->log_msg(WARN => "Upgrading bucket $bucket...");

                    while (<WORDS>) {
                        if ($wc % 100 == 0) {
                            $self->log_msg(WARN => "$wc");
                        }
                        $wc += 1;
                        s/[\r\n]//g;

                        if (/^([^\s]+) (\d+)$/) {
                            if ($2 != 0) {
                                $self->db_put_word_count($session, $bucket, $1, $2);
                            }
                        } else {
                            $self->log_msg(WARN => "Found entry in corpus for $bucket that looks wrong: \"$_\" (ignoring)");
                        }
                    }
                }

                if ($wc > 1) {
                    $wc -= 1;
                    $self->log_msg(WARN => "(completed $wc words)");
                }
                close WORDS;
            } else {
                close WORDS;
                $self->db()->rollback();
                unlink $self->get_user_path($self->config('corpus') . "/$bucket/table");
                return 0;
            }

            $self->db()->commit();
            unlink $self->get_user_path($self->config('corpus') . "/$bucket/table");
        }
    }

    # Now check to see if there's a BerkeleyDB-style table

    my $bdb_file = $self->get_user_path($self->config('corpus') . "/$bucket/table.db");

    if (-e $bdb_file) {
        $self->log_msg(WARN => "Performing automatic upgrade of $bucket corpus from BerkeleyDB to DBI");

        require BerkeleyDB;

        my %h;
        tie %h, "BerkeleyDB::Hash", -Filename => $bdb_file;

        $self->log_msg(WARN => "Upgrading bucket $bucket...");
        $self->db()->begin_work;

        my $wc = 1;

        for my $word (keys %h) {
            if ($wc % 100 == 0) {
            $self->log_msg(WARN => "$wc");
            }

            next if ($word =~ /__POPFILE__(LOG__TOTAL|TOTAL|UNIQUE)__/);

            $wc += 1;
            if ($h{$word} != 0) {
                $self->db_put_word_count($session, $bucket, $word, $h{$word});
            }
        }

        $wc -= 1;
        $self->log_msg(WARN => "(completed $wc words)");
        $self->db()->commit();
        untie %h;
        unlink $bdb_file;
    }

    return 1;
}

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
    return
        unless defined $userid;

    my @magnets;

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT magnets.val, magnets.id FROM magnets, users, buckets, magnet_types
         WHERE buckets.id = ?
            AND magnets.id != 0
            AND users.id = buckets.userid
            AND magnets.bucketid = buckets.id
            AND magnet_types.mtype = ?
            AND magnets.mtid = magnet_types.id
         ORDER BY magnets.val',
        $bucketid, $type);
        my ($val, $id);
        $h->bind_columns(\$val, \$id);
        while (my $row = $h->fetchrow_arrayref) {
        push @magnets, [ $val, $id ];
    }
    $h->finish();

    for my $m (@magnets) {
        my ($magnet, $id) = $m->@*;
        if ($self->single_magnet_match($magnet, $match, $type)) {
            $magnet_used = 1;
            $magnet_detail = $id;
            return 1;
        }
    }
    return 0;
}

=head2 single_magnet_match

Helper the determines if a specific string matches a specific magnet

C<$magnet> The magnet string
C<$match> The string to match
C<$type> The magnet type to check

=cut

method single_magnet_match ($magnet, $match, $type) {
    my $matched = 0;
    if ($type =~ /^(from|to)$/) {
        # From / To
        if ($magnet =~ /[\w]+\@[\w]+/) {
            # e-mail address -> exact match
            $matched = 1
                if ($match =~ m/(^|[^\w\-])\Q$magnet\E($|[^\w\.])/i);
        } elsif ($magnet =~ /\./) {
            # domain name -> domain match
            if ($magnet =~ /^[\@\.]/) {
                $matched = 1
                    if ($match =~ /\Q$magnet\E($|[^\w\.])/i);
            } else {
                $matched = 1
                    if ($match =~ m/[\@\.]\Q$magnet\E($|[^\w\.])/i);
            }
        } else {
            # name -> word match
            $matched = 1
                if ($match =~ m/(^|[^\w])\Q$magnet\E($|[^\w])/i);
        }
    } else {
        # Subject -> word match
        $matched = 1
            if ($match =~ m/(^|[^\w])\Q$magnet\E($|[^\w])/i);
    }

    return $matched;
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
        return;
    }

    unless (keys $parser->words()->%*) {
        $self->log_msg(INFO => "add_words_to_bucket: no words parsed for user=$userid bucket=$bucket; skipping");
        return;
    }
    $self->log_msg(5, "add_words_to_bucket: user=$userid bucket=$bucket bucketid=$bucketid words=" . scalar(keys $parser->words()->%*));
    my $qb = $self->qb();
    my $word_expr = $qb->compare('word', [sort keys $parser->words()->%*]);
    my $select = $qb->select('id', 'word')->from('words')->where($word_expr);
    $get_wordids = $self->validate_sql_prepare_and_execute(
        $select->as_sql(), $select->params());
    my @id_list;
    my %wordmap;
    my ($wordid, $word);

    $get_wordids->bind_columns(\$wordid, \$word);
    while ($get_wordids->fetchrow_arrayref()) {
        push @id_list, $wordid;
        $wordmap{$word} = $wordid;
    }

    $get_wordids->finish();
    undef $get_wordids;
    my %counts;
    if (@id_list) {
        my $qb = $self->qb();
        my $expr = $qb->combine_and(
            $qb->compare('matrix.wordid', \@id_list),
            $qb->compare('matrix.bucketid', $db_bucketid->{$userid}{$bucket}{id}));
        my $select = $qb->select('matrix.times', 'matrix.wordid')->from('matrix')->where($expr);
        $db_getwords = $self->validate_sql_prepare_and_execute(
            $select->as_sql(), $select->params());
        my $count;
        my $wid;
        $db_getwords->bind_columns(\$count, \$wid);
        while ($db_getwords->fetchrow_arrayref) {
            $counts{$wid} = $count;
        }
        $db_getwords->finish();
        undef $db_getwords;
    }

    $self->db()->begin_work;
    for my $word (keys $parser->words()->%*) {
        # If there's already a count then it means that the word is
        # already in the database and we have its id in
        # $wordmap{$word} so for speed we execute the
        # db_put_word_count query here rather than going through
        # set_value_ which would need to look up the wordid again

        if (defined($wordmap{$word}) && defined($counts{$wordmap{$word}})) {
            $self->validate_sql_prepare_and_execute(
                $db_put_word_count,
                $db_bucketid->{$userid}{$bucket}{id},
                $wordmap{$word},
                $counts{$wordmap{$word}} +
                    $subtract * $parser->words()->{$word});
        } else {
            # If the word is not in the database and we are trying to
            # subtract then we do nothing because negative values are
            # meaningless

            if ($subtract == 1) {
                $self->db_put_word_count($session, $bucket, $word, $parser->words()->{$word});
            }
        }
    }

    # If we were doing a subtract operation it's possible that some of
    # the words in the bucket now have a zero count and should be
    # removed

    if ($subtract == -1) {
        $self->validate_sql_prepare_and_execute(
            $db_delete_zero_words,
            $db_bucketid->{$userid}{$bucket}{id});
    }

    $self->db()->commit();
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

=head2 generate_unique_session_key

Returns a unique string based session key that can be used as a key
in the api_sessions

=cut

method generate_unique_session_key() {
    my @chars = ('A'..'Z', 0..9);
    my $session = '';
    do {
        my $length = int(16 + rand(4));
        for my $i (0 .. $length) {
            my $random = $chars[int(rand(scalar @chars))];
            # Just to add spice to things we sometimes lowercase the value
            if (rand(1) < rand(1)) {
                $random = lc($random);
            }
            $session .= $random;
        }
    } while defined $api_sessions->{$session};
    return $session;
}

=head2 release_session_key_private

Releases and invalidates the session key. Worker function that does
the work of release_session_key.

DO NOT CALL DIRECTLY!

unless you want your session key released immediately, possibly
preventing asynchronous tasks from completing

C<$session> A session key previously returned by get_session_key

=cut

method release_session_key_private ($session) {
    if (defined $api_sessions->{$session}) {
        $self->log_msg(INFO => "release_session_key releasing key $session for user $api_sessions->{$session}");
        delete $api_sessions->{$session};
    }
}

=head2 valid_session_key

Returns undef is the session key is not valid, or returns the user
ID associated with the session key which can be used in database
accesses

C<$session> Session key returned by call to get_session_key

=cut

method valid_session_key($session) {
    # This provides protection against someone using the XML-RPC
    # interface and calling this API directly to fish for session
    # keys, this must be called from within this module

    return
        unless caller eq 'Classifier::Bayes';

    # If the session key is invalid then wait 1 second.  This is done
    # to prevent people from calling a POPFile API such as
    # get_bucket_count with random session keys fishing for a valid
    # key.  The XML-RPC API is single threaded and hence this will
    # delay all use of that API by one second.  Of course in normal
    # use when the user knows the username/password or session key
    # then there is no delay

    unless (defined $api_sessions->{$session}) {
        my ($package, $filename, $line, $subroutine) = caller;
        $self->log_msg(WARN => "Invalid session key $session provided in $package @ $line");
        select(undef, undef, undef, 1);
    }

    return $api_sessions->{$session};
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
    # The password is stored in the database as an MD5 hash of the
    # username and password concatenated and separated by the string
    # __popfile__, so compute the hash here

    my $hash = md5_hex($user . '__popfile__' . $pwd);

    $self->validate_sql_prepare_and_execute($db_get_userid, $user, $hash);
    my $result = $db_get_userid->fetchrow_arrayref;
    unless (defined($result)) {
        # The delay of one second here is to prevent people from trying out
        # username/password combinations at high speed to determine the
        # credentials of a valid user

        $self->log_msg(WARN => "Attempt to login with incorrect credentials for user $user");
        select(undef, undef, undef, 1);
        return;
    }

    my $session = $self->generate_unique_session_key();

    $api_sessions->{$session} = $result->[0];

    $self->db_update_cache($session);

    $self->log_msg(INFO => "get_session_key returning key $session for user $api_sessions->{$session}");

    return $session;
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

    # If all of the user's buckets have no words then we escape here
    # return unclassified
    # $not_likely->{$userid} is 0 if word count is 0.
    # See: update_constants)

    return "unclassified"
        if ($not_likely->{$userid} == 0);

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
    my $qb = $self->qb();
    my $words_expr = $qb->compare('word', \@words);
    my $select = $qb->select('id', 'word')
        ->from('words')
        ->where($words_expr)
        ->order_by($qb->order_by('id'));
    $get_wordids = $self->validate_sql_prepare_and_execute(
        $select->as_sql(), $select->params());
    my @id_list;
    my %temp_idmap;
    my ($wordid, $word);

    unless (defined($idmap)) {
        $idmap = \%temp_idmap;
    }

    $get_wordids->bind_columns(\$wordid, \$word);
    while ($get_wordids->fetchrow_arrayref()) {
        push @id_list, $wordid;
        $idmap->{$wordid} = $word;
    }

    $get_wordids->finish();
    undef $get_wordids;

    my $ids_expr = $self->qb()->compare('matrix.wordid', \@id_list);
    $db_classify = $self->validate_sql_prepare_and_execute(
        "SELECT matrix.times, matrix.wordid, buckets.name
         FROM matrix, buckets
         WHERE " . $ids_expr->as_sql() . "
           AND matrix.bucketid = buckets.id
           AND buckets.userid = ?",
        $ids_expr->params(),
        $userid);
    # %matrix maps wordids and bucket names to counts
    # $matrix{$wordid}{$bucket} == $count

    my %temp_matrix;
    my ($count, $bucketname);

    unless (defined($matrix)) {
        $matrix = \%temp_matrix;
    }

    $db_classify->bind_columns(\$count, \$wordid, \$bucketname);
    while ($db_classify->fetchrow_arrayref) {
        $$matrix{$wordid}{$bucketname} = $count;
    }

    $db_classify->finish;
    undef $db_classify;

    my $not_likely = $not_likely->{$userid};
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
            my $probability = $not_likely;

            if (defined($$matrix{$id}{$bucket}) && ($$matrix{$id}{$bucket} > 0)) {
                $probability = log($$matrix{$id}{$bucket} / $db_bucketcount->{$userid}{$bucket});
                $matchcount{$bucket} += $count;
            }

            $wmax = $probability if ($wmax < $probability);
            $score{$bucket} += ($probability * $count);
        }

        if ($wmax > $not_likely) {
            $correction += $not_likely * $count;
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
                                $wordprobstr = sprintf("%12.4f", ($probability - $not_likely->{$userid})/$log10);
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

    # Note that get_buckets does not return pseudo buckets

    my @buckets;

    for my $b (sort keys $db_bucketid->{$userid}->%*) {
        if ($db_bucketid->{$userid}{$b}{pseudo} == 0) {
            push @buckets, ($b);
        }
    }

    return @buckets;
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
        my $b = Classifier::Bucket->new();
        $b->set_property('name', $name);
        $b->set_property('color', $self->get_bucket_parameter($session, $name, 'color'));
        $b->set_property('count', $db_bucketcount->{$userid}{$name} // 0);
        $b->set_prior($bucket_start->{$userid}{$name} // 0);
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

    my $c = $db_bucketcount->{$userid}{$bucket};

    return defined($c)
        ? $c
        : 0;
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
        unless exists($db_bucketid->{$userid}{$bucket});

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};

    $prefix = '' unless (defined($prefix));
    $prefix =~ s/\0//g;

    my $rows = $self->db()->selectall_arrayref('
        SELECT words.word, matrix.times
        FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?
            AND words.word LIKE ?', undef, $bucketid, "$prefix%");
    return $rows->@*;
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
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $offset = ($page - 1) * $per_page;
    my %sort_expr = (
        relevance => 'CAST(bucket_count AS FLOAT) / (total_count + 10)',
        count     => 'bucket_count',
        total     => 'total_count',
        word      => 'word',
    );
    my $sort = $sort_expr{ $opts{sort} // 'relevance' } // $sort_expr{relevance};
    my $dir  = ($opts{dir} // '') eq 'asc' ? 'ASC' : 'DESC';
    my $count_row = $self->validate_sql_prepare_and_execute(
        'SELECT COUNT(*) FROM matrix WHERE bucketid = ?',
        $bucketid)->fetchrow_arrayref;
    my $total = $count_row ? $count_row->[0] + 0 : 0;
    my $sth = $self->validate_sql_prepare_and_execute(
        "WITH wc AS (
             SELECT w.word,
                    m.times AS bucket_count,
                    (SELECT COALESCE(SUM(m2.times), 0)
                     FROM matrix m2
                     WHERE m2.wordid = m.wordid) AS total_count
             FROM matrix m
             JOIN words w ON w.id = m.wordid
             WHERE m.bucketid = ?
         )
         SELECT word, bucket_count, total_count
         FROM wc
         ORDER BY $sort $dir
         LIMIT ? OFFSET ?",
        $bucketid, $per_page, $offset);
    my @words;
    while (my $row = $sth->fetchrow_hashref()) {
        my $count = $row->{bucket_count} + 0;
        my $total_count = $row->{total_count} + 0;
        my $accuracy = $total_count > 0 ? $count / $total_count : 0;
        push @words, {
            word => $row->{word},
            count => $count,
            total => $total_count,
            accuracy => $accuracy };
    }
    return { words => \@words, total => $total }
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
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $wordid_row = $self->validate_sql_prepare_and_execute(
        'SELECT id FROM words WHERE word = ?',
        $word)->fetchrow_arrayref;
    return
        unless defined $wordid_row;
    my $wordid = $wordid_row->[0];
    $self->validate_sql_prepare_and_execute(
        'DELETE FROM matrix WHERE bucketid = ? AND wordid = ?',
        $bucketid, $wordid);
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
        unless exists $db_bucketid->{$userid}{$from_bucket};
    return
        unless exists $db_bucketid->{$userid}{$to_bucket};
    my $from_id = $db_bucketid->{$userid}{$from_bucket}{id};
    my $to_id = $db_bucketid->{$userid}{$to_bucket}{id};
    my $wordid_row = $self->validate_sql_prepare_and_execute(
        'SELECT id FROM words WHERE word = ?',
        $word)->fetchrow_arrayref;
    return
        unless defined $wordid_row;
    my $wordid = $wordid_row->[0];
    my $count_row = $self->validate_sql_prepare_and_execute(
        'SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?',
        $from_id, $wordid)->fetchrow_arrayref;
    return
        unless defined $count_row;
    my $count = $count_row->[0];
    $self->validate_sql_prepare_and_execute(
        'DELETE FROM matrix WHERE bucketid = ? AND wordid = ?',
        $from_id, $wordid);
    my $existing_row = $self->validate_sql_prepare_and_execute(
        'SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?',
        $to_id, $wordid)->fetchrow_arrayref;
    if (defined $existing_row) {
        $self->validate_sql_prepare_and_execute(
            'UPDATE matrix SET times = times + ?, lastseen = date(\'now\') WHERE bucketid = ? AND wordid = ?',
            $count, $to_id, $wordid);
    } else {
        $self->validate_sql_prepare_and_execute(
            'INSERT INTO matrix (bucketid, wordid, times) VALUES (?, ?, ?)',
            $to_id, $wordid, $count);
    }
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
    my $result = $self->db()->selectcol_arrayref("
        SELECT words.word FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?", undef, $bucketid);
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

    my $word_count = 0;
    for my $bucket (keys $db_bucketid->{$userid}->%*) {
        $word_count += $db_bucketcount->{$userid}{$bucket} // 0;
    }

    return $word_count;
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

    my $c = $db_bucketunique->{$userid}{$bucket};

    return defined($c)
        ? $c
        : 0;
}

=head2 get_unique_word_count

Returns the unique word count (excluding duplicates) for all buckets

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_unique_word_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my $unique_word_count = 0;
    for my $bucket (keys $db_bucketid->{$userid}->%*) {
        $unique_word_count += $db_bucketunique->{$userid}{$bucket};
    }

    return $unique_word_count;
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

    # See if there's a cached value

    if (defined($db_parameters->{$userid}{$bucket}{$parameter})) {
        return $db_parameters->{$userid}{$bucket}{$parameter};
    }

    # Make sure that the bucket passed in actually exists

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return;
    }

    # Make sure that the parameter is valid

    unless (defined($db_parameterid->{$parameter})) {
        return;
    }

    # If there is a non-default value for this parameter then return it.

    $self->validate_sql_prepare_and_execute(
        $db_get_bucket_parameter,
        $db_bucketid->{$userid}{$bucket}{id},
        $db_parameterid->{$parameter});
    my $result = $db_get_bucket_parameter->fetchrow_arrayref;

    # If this parameter has not been defined for this specific bucket then
    # get the default value

    unless (defined($result)) {
        $self->validate_sql_prepare_and_execute(
            $db_get_bucket_parameter_default,
            $db_parameterid->{$parameter});
        $result = $db_get_bucket_parameter_default->fetchrow_arrayref;
    }

    if (defined($result)) {
        $db_parameters->{$userid}{$bucket}{$parameter} = $result->[0];
        return $result->[0];
    } else {
        return;
    }
}

=head2 set_bucket_parameter

Sets the value associated with a bucket specific parameter

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket
C<$parameter> The name of the parameter
C<$value> The new value

=cut

method set_bucket_parameter ($session, $bucket, $parameter, $value) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    # Make sure that the bucket passed in actually exists

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return;
    }

    # Make sure that the parameter is valid

    unless (defined($db_parameterid->{$parameter})) {
        return;
    }

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $btid = $db_parameterid->{$parameter};

    # Exactly one row should be affected by this statement

    $self->validate_sql_prepare_and_execute($db_set_bucket_parameter,
        $bucketid, $btid, $value);
    if (defined($db_parameters->{$userid}{$bucket}{$parameter})) {
        $db_parameters->{$userid}{$bucket}{$parameter} = $value;
    }

    return 1;
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

    if ($self->is_bucket($session, $bucket) ||
    $self->is_pseudo_bucket($session, $bucket)) {
        return 0;
    }

    return 0 if ($bucket =~ /[^[:lower:]\-_0-9]/);

    $self->validate_sql_prepare_and_execute('
        INSERT INTO buckets (name, pseudo, userid)
        VALUES (?, 0, ?)',
        $bucket, $userid);
        $self->db_update_cache($session, $bucket);
    return 1;
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

    # Make sure that the bucket passed in actually exists
    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    $self->validate_sql_prepare_and_execute(
        'DELETE FROM buckets
         WHERE buckets.userid = ?
            AND buckets.name = ?
            AND buckets.pseudo = 0',
        $userid, $bucket);
        $self->db_update_cache($session, undef, $bucket);
    $history->force_requery();

    return 1;
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

    # Make sure that the bucket passed in actually exists

    unless (defined($db_bucketid->{$userid}{$old_bucket})) {
        $self->log_msg(WARN => "Bad bucket name $old_bucket to rename_bucket");
        return 0;
    }

    if (defined($db_bucketid->{$userid}{$new_bucket})) {
        $self->log_msg(WARN => "Bucket named $new_bucket already exists");
        return 0;
    }

    return 0
        if ($new_bucket =~ /[^[:lower:]\-_0-9]/);

    my $id = $db_bucketid->{$userid}{$old_bucket}{id};

    $self->log_msg(INFO => "Rename bucket $old_bucket to $new_bucket");

    my $result = $self->validate_sql_prepare_and_execute(
        'UPDATE buckets SET name = ? WHERE id = ?',
        $new_bucket, $id);
    unless (defined($result) || ($result == -1)) {
        return 0;
    } else {
        $self->db_update_cache($session, $new_bucket, $old_bucket);
        $history->force_requery();

        return 1;
    }
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
        $self->log_msg(WARN => "add_message_to_bucket: bucket '$bucket' not found for user=$userid file=$file");
        return 0;
    }

    my $result = $self->add_messages_to_bucket($session, $bucket, $file);
    $self->log_msg(5, "add_message_to_bucket: user=$userid bucket=$bucket file=$file result=" . (defined $result ? $result : 'undef'));
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

    my @result;

    $self->validate_sql_prepare_and_execute(
        $db_get_buckets_with_magnets, $userid);
        while (my $row = $db_get_buckets_with_magnets->fetchrow_arrayref) {
        push @result, ($row->[0]);
    }

    return @result;
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

    my @result;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return;
    }

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT magnet_types.mtype FROM magnet_types, magnets, buckets
         WHERE magnet_types.id = magnets.mtid
            AND magnets.bucketid = buckets.id
            AND buckets.id = ?
         GROUP BY magnet_types.mtype
         ORDER BY magnet_types.mtype',
        $bucketid);
        while (my $row = $h->fetchrow_arrayref) {
        push @result, ($row->[0]);
    }
    $h->finish;

    return @result;
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

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return;
    }

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};

    $self->validate_sql_prepare_and_execute(
        'DELETE FROM matrix WHERE matrix.bucketid = ?',
        $bucketid);
    $self->db_update_cache($session, $bucket);

    return 1;
}

=head2 clear_magnets

Removes every magnet currently defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method clear_magnets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    for my $bucket (keys $db_bucketid->{$userid}->%*) {
        my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
        $self->validate_sql_prepare_and_execute(
            'DELETE FROM magnets WHERE magnets.bucketid = ?',
            $bucketid);
        $self->validate_sql_prepare_and_execute(
            'UPDATE history SET magnetid = 0
             WHERE bucketid = ?
                AND userid = ?',
            $bucketid, $userid);
    }

    return 1;
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


    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    return 0 unless (defined($type));

    my @result;
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT magnets.val FROM magnets, magnet_types
         WHERE magnets.bucketid = ?
            AND magnets.id != 0
            AND magnet_types.id = magnets.mtid
            AND magnet_types.mtype = ?
         ORDER BY magnets.val',
        $bucketid, $type);
    while (my $row = $h->fetchrow_arrayref()) {
        push @result, ($row->[0]);
    }
    $h->finish();

    return @result;
}

=head2 get_magnet_types

Get a hash mapping magnet types (e.g. from) to magnet names (e.g. From);

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_magnet_types ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my %result;

    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT magnet_types.mtype, magnet_types.header
         FROM magnet_types ORDER BY mtype');
         while (my $row = $h->fetchrow_arrayref()) {
            $result{$row->[0]} = $row->[1];
        }
    $h->finish();

    return %result;
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
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $result = $self->validate_sql_prepare_and_execute(
        'SELECT magnet_types.id FROM magnet_types WHERE magnet_types.mtype = ?',
        $type)->fetchrow_arrayref();
    my $mtid = $result->[0];
    return 0
        unless defined $mtid;
    $self->validate_sql_prepare_and_execute(
        'INSERT INTO magnets ( bucketid, mtid, val ) VALUES ( ?, ?, ? )',
        $bucketid, $mtid, $text);
    return 1
}

=head2 delete_magnet

    $self->delete_magnet($session, $bucket, $type, $text);

Removes the magnet with type C<$type> and value C<$text> from C<$bucket>.

=cut

method delete_magnet ($session, $bucket, $type, $text) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    # todo: avoid autovivification
    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};

    my $result = $self->validate_sql_prepare_and_execute(
        'SELECT magnets.id FROM magnets, magnet_types
         WHERE magnets.mtid = magnet_types.id
            AND magnets.bucketid = ?
            AND magnets.val = ?
            AND magnet_types.mtype = ?',
        $bucketid, $text, $type)->fetchrow_arrayref;
        return 0 unless (defined($result));

    my $magnetid = $result->[0];

    return 0 unless (defined($magnetid));

    $self->validate_sql_prepare_and_execute(
        'DELETE FROM magnets WHERE id = ?',
        $magnetid);
    $self->validate_sql_prepare_and_execute(
        'UPDATE history SET magnetid = 0
         WHERE magnetid = ?
            AND userid = ?',
        $magnetid, $userid);
    $history->force_requery();

    return 1;
}

=head2 get_stopword_list

Gets the complete list of stop words

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_stopword_list ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $parser->mangle()->stopwords();
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

    my $bucket_count_row = $self->validate_sql_prepare_and_execute(
        'SELECT COUNT(*) FROM buckets WHERE userid = ? AND pseudo = 0',
        $userid)->fetchrow_arrayref;
    my $n_buckets = $bucket_count_row ? $bucket_count_row->[0] : 0;
    return ()
        if $n_buckets < 2;

    my $sth = $self->validate_sql_prepare_and_execute(
        'SELECT w.word,
                MIN(m.times) AS min_count,
                MAX(m.times) AS max_count,
                CAST(MAX(m.times) AS FLOAT) / MIN(m.times) AS ratio
         FROM words w
         JOIN matrix m ON m.wordid = w.id
         JOIN buckets b ON b.id = m.bucketid
         WHERE b.userid = ?
           AND b.pseudo = 0
         GROUP BY w.id, w.word
         HAVING COUNT(DISTINCT m.bucketid) = ?
            AND MIN(m.times) > 0
            AND CAST(MAX(m.times) AS FLOAT) / MIN(m.times) < ?
         ORDER BY CAST(MAX(m.times) AS FLOAT) / MIN(m.times) ASC
         LIMIT ?',
        $userid, $n_buckets, $ratio, $limit);

    my @candidates;
    while (my $row = $sth->fetchrow_hashref()) {
        push @candidates, {
            word => $row->{word},
            min_count => $row->{min_count} + 0,
            max_count => $row->{max_count} + 0,
            ratio => $row->{ratio} + 0,
        };
    }
    return @candidates
}

=head2 magnet_count

Gets the number of magnets that are defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method magnet_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my $result = $self->validate_sql_prepare_and_execute(
        'SELECT count(*) FROM magnets, buckets
         WHERE buckets.userid = ?
            AND magnets.id != 0
            AND magnets.bucketid = buckets.id',
        $userid)->fetchrow_arrayref;
        if (defined($result)) {
        return $result->[0];
    } else {
        return 0;
    }
}

=head2 add_stopword, remove_stopword

Adds or removes a stop word


Return 0 for a bad stop word, and 1 otherwise

C<$session> A valid session key returned by a call to get_session_key
C<$stopword> The word to add or remove

=cut

method add_stopword ($session, $stopword) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    # Pass language parameter to add_stopword()

    return $parser->mangle()->add_stopword(
        $stopword, $self->module_config('api', 'locale'));
}

method remove_stopword ($session, $stopword) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    # Pass language parameter to remove_stopword()

    return $parser->mangle()->remove_stopword(
        $stopword, $self->module_config('api', 'locale'));
}

=head2 db_quote

Quote a string for use in a sql statement. Before calling DBI::quote on the
string the string is also checked for any null-bytes.


returns the quoted string without any possible null-bytes

C<$string> The string that should be quoted.

=cut

method db_quote ($string) {
    my $backup = $string;
    if ($string =~ s/\x00//g) {
        my ($package, $file, $line) = caller;
        $self->log_msg(WARN => "Found null-byte in string '$backup'. Called from package '$package' ($file), line $line.");
    }
    return $self->db()->quote($string);
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
