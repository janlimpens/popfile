# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Apply
Add                                     Add
Remove                                  Remove
Previous                                Previous
Next                                    Next
From                                    From
Subject                                 Subject
Reclassify                              Reclassify
Undo                                    Undo
Close                                   Close
Bucket                                  Bucket
Magnet                                  Magnet
Delete                                  Delete
Create                                  Create
Total                                   Total
Rename                                  Rename
Update                                  Update
Refresh                                 Refresh
Date                                    Date

# The header and footer that appear on every UI page

Configuration_Language                  Language

History_SearchMessage                   Search From/Subject

Magnet_CurrentMagnets                   Current Magnets
Magnet_CreateNew                        Create New Magnet

Bucket_CreateBucket                     Create bucket with name
Bucket_RenameBucket                     Rename bucket named

Imap_Server                             IMAP server hostname:
Imap_Port                               IMAP Server port:
Imap_Login                              IMAP account login:
Imap_Password                           Password for IMAP account:
Imap_Expunge                            Expunge deleted messages from watched folders.
Imap_Interval                           Update interval in seconds:
Imap_NoConnectionMessage                Please configure the connection details first. After you have done that, more options will be available on this page.
Imap_Use_SSL							Use SSL

NavHistory                              History
NavCorpus                               Corpus
NavWordSearch                           Words & Stopwords
NavMagnets                              Magnets
NavIMAP                                 IMAP
NavStatus                               Status

# --- New keys for Svelte UI components ---

Reconnect_Title                         Connection lost
Reconnect_Message                       The backend is not reachable. Trying to reconnect...
Reconnect_Now                           Reconnect now
Reconnect_Connecting                    Connecting...
Reconnect_RetryIn                       Retrying in

BucketSelect_NameRequired               Name required
BucketSelect_InvalidName                Only a-z, 0-9, - and _
BucketSelect_AlreadyExists              Already exists
BucketSelect_CreateError                Error creating bucket
BucketSelect_AddNew                     Add new...

Magnet_Created                          Magnet created
Magnet_Deleted                          Magnet deleted

Status_Description                      Health checks for POPFile services.
Status_Checking                         Checking...
Status_LoadError                        Failed to load status
Status_NoChecks                         No checks available.

Imap_Description                        Monitor IMAP folders and automatically classify incoming messages.
Imap_Connection                         Connection
Imap_Connected                          Connected
Imap_Testing                            Testing...
Imap_TestConnection                     Test Connection
Imap_ConnectionFailed                   Connection failed
Imap_SaveAnyway                         Save anyway
Imap_SaveConnection                     Save Connection
Imap_TrainingMode                       Training mode
Imap_TrainingLimit                      Messages per folder (0 = unlimited)
Imap_TrainingHint                       Training mode scans existing archive folders and trains the classifier on their contents. The flag resets automatically when training completes.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_WatchedFolders                     Watched Folders
Imap_WatchedHint                        POPFile monitors these IMAP folders for new messages to classify.
Imap_NoFoldersWatched                   No folders watched yet.
Imap_BucketFolderMappings               Bucket -> Folder Mappings
Imap_MappingsHint                       Classified messages are moved to the specified IMAP folder. Leave unmapped buckets empty to skip moving.
Imap_FetchFolders                       Fetch Folders
Imap_Fetching                           Fetching...
Imap_IMAFFolder                         IMAP Folder
Imap_NoMappings                         No mappings defined.
Imap_SaveFolders                        Save Folders
Imap_Saving                             Saving...
Imap_Advanced                           Advanced
Imap_Wizard                             Setup Wizard
Imap_WizardDesc                         Select folders to create buckets and mappings for.
Imap_WizardSelectAll                    Select all
Imap_WizardDeselectAll                  Deselect all
Imap_WizardEmpty                        No additional folders found on the server.
Imap_WizardApply                        Create & map
Imap_WizardDone                         {count} bucket(s) created and mapped.
Imap_WizardTrain                        Train now
Imap_WizardClose                        Close
Imap_Cancel                             Cancel

Corpus_Color                            Color
Corpus_Actions                          Actions
Corpus_Clear                            Clear
Corpus_BucketList                       Buckets
WordSearch_Title                        Word Search
WordSearch_Placeholder                  prefix...
WordSearch_Search                       Search
WordSearch_ColumnWord                   Word
WordSearch_ColumnBuckets                Buckets
WordSearch_AddStopword                  + Stopword
WordSearch_RemoveStopword               Stopword
WordSearch_IsStopword                   stopword
WordSearch_StopwordList                 Stopwords
WordSearch_NoResults                    No words found.
WordSearch_NoStopwords                  No stopwords defined.
WordSearch_Loading                      Loading...
WordSearch_Total                        words

History_AllBuckets                      All buckets
History_Reclassifying                   Reclassifying...
History_ReclassifyUnclassified          Reclassify unclassified
History_Selected                        selected
History_MoveTo                          — move to —
History_Moving                          Moving...
History_HighlightWords                  Highlight words by bucket
History_Loading                         Loading...
History_PerPage                         Per page:

Settings_Search                         Search settings...
Settings_AutoDetect                     Auto-detect
Settings_Saved                          Saved
Settings_ErrorSaving                    Error saving
Settings_SaveChanges                    Save Changes
Settings_Saving                         Saving...

# --- Settings sections and field labels ---

Settings_SectionUI                      User Interface
Settings_SectionSecurity                Security
Settings_SectionPOP3                    POP3
Settings_DescPOP3                        POP3 proxy — sits between your mail client and your POP3 server. It classifies every message and adds an X-Text-Classification header. Point your mail client at the host and port POPFile listens on (default 1110) instead of your real POP3 server.
Settings_SectionSMTP                    SMTP
Settings_DescSMTP                        SMTP proxy — sits between your mail client and your SMTP server. It classifies outgoing messages and forwards them to the real server. Point your mail client at the host and port POPFile listens on (default 25).
Settings_SectionNNTP                    NNTP
Settings_DescNNTP                        NNTP proxy — sits between your newsreader and your NNTP server. It classifies articles and adds classification headers. Point your newsreader at the host and port POPFile listens on (default 119).
Settings_SectionIMAP                    IMAP
Settings_EnableService                  Enable service
Settings_SectionClassifier              Classifier
Settings_SectionHistory                 History
Settings_SectionLogging                 Logging

Settings_HTTPPort                       HTTP Port
Settings_LocalOnly                      Local Only
Settings_ItemsPerPage                   Items Per Page
Settings_SessionDividers                Session Dividers
Settings_WordTable                      Word Table
Settings_AdminPassword                  Admin Password
Settings_ListenPort                     Listen Port
Settings_ServerSeparator                Server Separator
Settings_ForceFork                      Force Fork
Settings_TOPFetchesBody                 TOP Fetches Body
Settings_SSLChainServer                 SSL Chain Server
Settings_SSLChainPort                   SSL Chain Port
Settings_ChainServer                    Chain Server
Settings_ChainPort                      Chain Port
Settings_HEADFetchesBody                HEAD Fetches Body
Settings_ListenAddress                  Listen Address
Settings_MessageCutoff                  Message Cutoff
Settings_UnclassifiedWeight             Unclassified Weight
Settings_SubjectTagLeft                 Subject Tag Left
Settings_SubjectTagRight                Subject Tag Right
Settings_TagPosition                    Tag Position
Settings_SQLiteBackup                   SQLite: periodic backup
Settings_SQLiteFastWrites               SQLite: fast writes (less safe)
Settings_SQLiteJournalMode              SQLite Journal Mode
Settings_WordStemming                   Word Stemming
Settings_AutoDetectLanguage             Auto-detect Language
Settings_RetentionDays                  Retention (days)
Settings_ArchiveMessages                Archive Messages
Settings_ArchiveDirectory               Archive Directory
Settings_ArchiveSubdirs                 Archive Sub-dirs
Settings_LogLevel                       Log Level
Settings_LogDirectory                   Log Directory
Settings_LogToStdout                    Log to stdout
Settings_LogSQLToStdout                 Log SQL queries
Settings_LogFormat                      Log Format
Settings_OpenBrowser                    Open browser on start

Settings_DescHTTPPort                   Port the web UI listens on. Requires restart.
Settings_DescLocalOnly_UI               Restrict the web UI to localhost connections.
Settings_DescItemsPerPage               Rows shown per page in History and Magnets.
Settings_DescSessionDividers            Show dividers between browsing sessions in History.
Settings_DescWordTable                  What to display in the word probability table.
Settings_DescLanguage                   UI display language. Leave empty to auto-detect from browser.
Settings_DescAdminPassword              Leave empty to disable password protection.
Settings_DescPOP3                        POP3 proxy — sits between your mail client and your POP3 server. It classifies every message and adds an X-Text-Classification header. Point your mail client at the host and port POPFile listens on (default 1110) instead of your real POP3 server.
Settings_DescPOP3                        POP3 proxy — sits between your mail client and your POP3 server. It classifies every message and adds an X-Text-Classification header. Point your mail client at the host and port POPFile listens on (default 1110) instead of your real POP3 server.
Settings_DescPOP3                        POP3 proxy — sits between your mail client and your POP3 server. It classifies every message and adds an X-Text-Classification header. Point your mail client at the host and port POPFile listens on (default 1110) instead of your real POP3 server.
Settings_DescEnableProxy                Start this proxy listener when POPFile starts.
Settings_DescForceFork                  Fork a new process for each connection.
Settings_DescTOPFetchesBody             Also retrieve message body with the TOP command.
Settings_DescSSLChainServer             Upstream SSL POP3 server hostname for SSL chaining.
Settings_DescSSLChainPort               Upstream SSL POP3 server port.
Settings_DescSMTP                        SMTP proxy — sits between your mail client and your SMTP server. It classifies outgoing messages and forwards them to the real server. Point your mail client at the host and port POPFile listens on (default 25).
Settings_DescChainServer                Upstream SMTP server hostname.
Settings_DescChainPort                  Upstream SMTP server port.
Settings_DescSMTP                        SMTP proxy — sits between your mail client and your SMTP server. It classifies outgoing messages and forwards them to the real server. Point your mail client at the host and port POPFile listens on (default 25).
Settings_DescNNTP                        NNTP proxy — sits between your newsreader and your NNTP server. It classifies articles and adds classification headers. Point your newsreader at the host and port POPFile listens on (default 119).
Settings_DescNNTP                        NNTP proxy — sits between your newsreader and your NNTP server. It classifies articles and adds classification headers. Point your newsreader at the host and port POPFile listens on (default 119).
Settings_DescNNTP                        NNTP proxy — sits between your newsreader and your NNTP server. It classifies articles and adds classification headers. Point your newsreader at the host and port POPFile listens on (default 119).
Settings_DescHEADFetchesBody            Retrieve full article with the HEAD command.
Settings_DescListenAddress              IP address to bind to. Empty = all interfaces.
Settings_DescMessageCutoff              Maximum words analysed per message (0 = unlimited).
Settings_DescUnclassifiedWeight         Probability threshold below which mail is "unclassified".
Settings_DescSubjectTagLeft             Prefix inserted into Subject header, e.g. [SPAM].
Settings_DescSubjectTagRight            Suffix appended to Subject header.
Settings_DescTagPosition                Where to place the subject tag.
Settings_DescSQLiteBackup               Copy the database to a .backup file every hour.
Settings_DescSQLiteFastWrites           Disable SQLite write-ahead sync for faster inserts. Risks minor data loss on crash.
Settings_DescSQLiteJournal              SQLite journal / WAL mode.
Settings_DescWordStemming               Reduce words to their stem before classification (e.g. "running" to "run"). Improves recall for morphologically rich languages at ~10% latency cost.
Settings_DescAutoDetectLang             Detect the language of each message and apply matching stopwords and stemmer. Adds ~130% classify latency; useful for mixed-language mailboxes.
Settings_DescRetentionDays              How many days to keep message history.
Settings_DescArchiveMessages            Save a copy of every classified message to disk.
Settings_DescArchiveDir                 Directory for archived messages (relative to user dir).
Settings_DescArchiveSubdirs             Split archive into N sub-directories (0 = disabled).
Settings_DescLogLevel                   Verbosity of log output.
Settings_DescLogDirectory               Directory for log files. Empty = popfile root.
Settings_DescLogToStdout                Mirror log output to stdout in addition to the log file.
Settings_DescLogSQLToStdout             Include SQL statements with bound values in log output. Follows the same destination as other log messages (file and/or stdout).
Settings_DescLogFormat                  Log line format. Use 'plain' for journald or any environment that adds its own timestamps.
Settings_DescOpenBrowser                Open the default browser when the web UI is ready.

Settings_OptHidden                      Hidden
Settings_OptFrequencies                 Frequencies
Settings_OptProbabilities               Probabilities
Settings_OptLogScores                   Log Scores
Settings_OptFront                       Front
Settings_OptEnd                         End
Settings_OptErrorsOnly                  Errors only
Settings_OptWarnings                    Warnings
Settings_OptInfo                        Info
Settings_OptDebug                       Debug

Language_Name                           English
Wizard_Next                             Next
Wizard_Manual                           Manual setup
Wizard_ManualDesc                       Enter your mail server details below.
Wizard_Encryption                       Encryption
Wizard_None                             None
Wizard_Welcome                          Welcome to POPFile. POPFile helps you keep your inbox organised. Start by entering your username — usually your email address.
Wizard_Username                         Username
Wizard_Done                             All set!
