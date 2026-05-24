# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens
LanguageCharset ISO-8859-1
LanguageDirection ltr
Language_Name English
ManualLanguage en

Add Add
Apply Apply
Bucket Bucket
BucketSelect_AddNew Add new...
BucketSelect_AlreadyExists Already exists
BucketSelect_CreateError Error creating bucket
BucketSelect_InvalidName Only a-z, 0-9, - and _
BucketSelect_NameRequired Name required
Bucket_CreateBucket Create bucket with name
Bucket_RenameBucket Rename bucket named
Close Close
Configuration_Language Language
Corpus_Actions Actions
Corpus_BucketList Buckets
Corpus_Clear Clear
Corpus_Color Color
Create Create
Date Date
Delete Delete
From From
History_AllBuckets All buckets
History_HighlightWords Highlight words by bucket
History_Loading Loading...
History_MoveTo — move to —
History_Moving Moving...
History_PerPage Per page:
History_ReclassifyUnclassified Reclassify unclassified
History_Reclassifying Reclassifying...
History_SearchMessage Search From/Subject
History_Selected selected
Imap_Advanced Advanced
Imap_BucketFolderMappings Bucket -> Folder Mappings
Imap_Cancel Cancel
Imap_Connected Connected
Imap_Connection Connection
Imap_ConnectionFailed Connection failed
Imap_Description Monitor IMAP folders and automatically classify incoming messages.
Imap_Expunge Expunge deleted messages from watched folders.
Imap_FetchFolders Fetch Folders
Imap_Fetching Fetching...
Imap_IMAFFolder IMAP Folder
Imap_Interval Update interval in seconds:
Imap_Login IMAP account login:
Imap_MappingsHint Classified messages are moved to the specified IMAP folder. Leave unmapped buckets empty to skip moving.
Imap_NoConnectionMessage Please configure the connection details first. After you have done that, more options will be available on this page.
Imap_NoFoldersWatched No folders watched yet.
Imap_NoMappings No mappings defined.
Imap_Password Password for IMAP account:
Imap_Port IMAP Server port:
Imap_SaveAnyway Save anyway
Imap_SaveConnection Save Connection
Imap_SaveFolders Save Folders
Imap_Saving Saving...
Imap_Server IMAP server hostname:
Imap_TestConnection Test Connection
Imap_Testing Testing...
Imap_Train Train
Imap_TrainAll Train all buckets
Imap_TrainQueued Training queued
Imap_TrainingHint Training mode scans existing archive folders and trains the classifier on their contents. The flag resets automatically when training completes.
Imap_TrainingLimit Messages per folder (0 = unlimited)
Imap_TrainingMode Training mode
Imap_Use_SSL Use SSL
Imap_WatchedFolders Watched Folders
Imap_WatchedHint POPFile monitors these IMAP folders for new messages to classify.
Imap_Wizard Setup Wizard
Imap_WizardApply Create & map
Imap_WizardClose Close
Imap_WizardDesc Select folders to create buckets and mappings for.
Imap_WizardDeselectAll Deselect all
Imap_WizardDone {count} bucket(s) created and mapped.
Imap_WizardEmpty No additional folders found on the server.
Imap_WizardSelectAll Select all
Imap_WizardTrain Train now
Magnet_CreateNew Create New Magnet
Magnet_Created Magnet created
Magnet_CurrentMagnets Current Magnets
Magnet_Deleted Magnet deleted
NavCorpus Corpus
NavHistory History
NavIMAP IMAP
NavMagnets Magnets
NavStatus Status
NavWordSearch Words & Stopwords
Next Next
Previous Previous
Reclassify Reclassify
Reconnect_Connecting Connecting...
Reconnect_Message The backend is not reachable. Trying to reconnect...
Reconnect_Now Reconnect now
Reconnect_RetryIn Retrying in
Reconnect_Title Connection lost
Refresh Refresh
Remove Remove
Rename Rename
Settings_AdminPassword Admin Password
Settings_ArchiveDirectory Archive Directory
Settings_ArchiveMessages Archive Messages
Settings_ArchiveSubdirs Archive Sub-dirs
Settings_AutoDetect Auto-detect
Settings_AutoDetectLanguage Auto-detect Language
Settings_ChainPort Chain Port
Settings_ChainServer Chain Server
Settings_DescAdminPassword Leave empty to disable password protection.
Settings_DescArchiveDir Directory for archived messages (relative to user dir).
Settings_DescArchiveMessages Save a copy of every classified message to disk.
Settings_DescArchiveSubdirs Split archive into N sub-directories (0 = disabled).
Settings_DescAutoDetectLang Detect the language of each message and apply matching stopwords and stemmer. Adds ~130% classify latency; useful for mixed-language mailboxes.
Settings_DescChainPort Upstream SMTP server port.
Settings_DescChainServer Upstream SMTP server hostname.
Settings_DescEnableProxy Start this proxy listener when POPFile starts.
Settings_DescForceFork Fork a new process for each connection.
Settings_DescHEADFetchesBody Retrieve full article with the HEAD command.
Settings_DescHTTPPort Port the web UI listens on. Requires restart.
Settings_DescItemsPerPage Rows shown per page in History and Magnets.
Settings_DescLanguage UI display language. Leave empty to auto-detect from browser.
Settings_DescListenAddress IP address to bind to. Empty = all interfaces.
Settings_DescLocalOnly_UI Restrict the web UI to localhost connections.
Settings_DescLogDirectory Directory for log files. Empty = popfile root.
Settings_DescLogFormat Log line format. Use 'plain' for journald or any environment that adds its own timestamps.
Settings_DescLogLevel Verbosity of log output.
Settings_DescLogSQLToStdout Include SQL statements with bound values in log output. Follows the same destination as other log messages (file and/or stdout).
Settings_DescLogToStdout Mirror log output to stdout in addition to the log file.
Settings_DescMessageCutoff Maximum words analysed per message (0 = unlimited).
Settings_DescNNTP NNTP proxy — sits between your newsreader and your NNTP server. It classifies articles and adds classification headers. Point your newsreader at the host and port POPFile listens on (default 119).
Settings_DescOpenBrowser Open the default browser when the web UI is ready.
Settings_DescPOP3 POP3 proxy — sits between your mail client and your POP3 server. It classifies every message and adds an X-Text-Classification header. Point your mail client at the host and port POPFile listens on (default 1110) instead of your real POP3 server.
Settings_DescRetentionDays How many days to keep message history.
Settings_DescSMTP SMTP proxy — sits between your mail client and your SMTP server. It classifies outgoing messages and forwards them to the real server. Point your mail client at the host and port POPFile listens on (default 25).
Settings_DescSQLiteBackup Copy the database to a .backup file every hour.
Settings_DescSQLiteFastWrites Disable SQLite write-ahead sync for faster inserts. Risks minor data loss on crash.
Settings_DescSQLiteJournal SQLite journal / WAL mode.
Settings_DescSSLChainPort Upstream SSL POP3 server port.
Settings_DescSSLChainServer Upstream SSL POP3 server hostname for SSL chaining.
Settings_DescSessionDividers Show dividers between browsing sessions in History.
Settings_DescSubjectTagLeft Prefix inserted into Subject header, e.g. [SPAM].
Settings_DescSubjectTagRight Suffix appended to Subject header.
Settings_DescTOPFetchesBody Also retrieve message body with the TOP command.
Settings_DescTagPosition Where to place the subject tag.
Settings_DescUnclassifiedWeight Probability threshold below which mail is "unclassified".
Settings_DescWordStemming Reduce words to their stem before classification (e.g. "running" to "run"). Improves recall for morphologically rich languages at ~10% latency cost.
Settings_DescWordTable What to display in the word probability table.
Settings_EnableService Enable service
Settings_ErrorSaving Error saving
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD Fetches Body
Settings_HTTPPort HTTP Port
Settings_ItemsPerPage Items Per Page
Settings_ListenAddress Listen Address
Settings_ListenPort Listen Port
Settings_LocalOnly Local Only
Settings_LogDirectory Log Directory
Settings_LogFormat Log Format
Settings_LogLevel Log Level
Settings_LogSQLToStdout Log SQL queries
Settings_LogToStdout Log to stdout
Settings_MessageCutoff Message Cutoff
Settings_OpenBrowser Open browser on start
Settings_OptDebug Debug
Settings_OptEnd End
Settings_OptErrorsOnly Errors only
Settings_OptFrequencies Frequencies
Settings_OptFront Front
Settings_OptHidden Hidden
Settings_OptInfo Info
Settings_OptLogScores Log Scores
Settings_OptProbabilities Probabilities
Settings_OptWarnings Warnings
Settings_RetentionDays Retention (days)
Settings_SQLiteBackup SQLite: periodic backup
Settings_SQLiteFastWrites SQLite: fast writes (less safe)
Settings_SQLiteJournalMode SQLite Journal Mode
Settings_SSLChainPort SSL Chain Port
Settings_SSLChainServer SSL Chain Server
Settings_SaveChanges Save Changes
Settings_Saved Saved
Settings_RestartNeeded Restart required for changes to take effect.
Settings_RestartNow Restart Now
Settings_ConfirmRestart Restart POPFile now?
Settings_Saving Saving...
Settings_Search Search settings...
Settings_SectionClassifier Classifier
Settings_SectionHistory History
Settings_SectionIMAP IMAP
Settings_SectionLogging Logging
Settings_SectionNNTP NNTP
Settings_SectionPOP3 POP3
Settings_SectionSMTP SMTP
Settings_SectionSecurity Security
Settings_SectionUI User Interface
Settings_ServerSeparator Server Separator
Settings_SessionDividers Session Dividers
Settings_SubjectTagLeft Subject Tag Left
Settings_SubjectTagRight Subject Tag Right
Settings_TOPFetchesBody TOP Fetches Body
Settings_TagPosition Tag Position
Settings_UnclassifiedWeight Unclassified Weight
Settings_WordStemming Word Stemming
Settings_WordTable Word Table
Status_Checking Checking...
Status_Description Health checks for POPFile services.
Status_LoadError Failed to load status
Status_NoChecks No checks available.
Subject Subject
Total Total
Update Update
Wizard_Done All set!
Wizard_Encryption Encryption
Wizard_Manual Manual setup
Wizard_ManualDesc Enter your mail server details below.
Wizard_Next Next
Wizard_None None
Wizard_Username Username
Wizard_Welcome Welcome to POPFile. POPFile helps you keep your inbox organised. Start by entering your username — usually your email address.
WordSearch_AddStopword + Stopword
WordSearch_ColumnBuckets Buckets
WordSearch_ColumnWord Word
WordSearch_IsStopword stopword
WordSearch_Loading Loading...
WordSearch_NoResults No words found.
WordSearch_NoStopwords No stopwords defined.
WordSearch_Placeholder prefix...
WordSearch_RemoveStopword Stopword
WordSearch_Search Search
WordSearch_StopwordList Stopwords
WordSearch_Title Word Search
WordSearch_Total words

Settings_BasePath Base URL Path
Settings_DescBasePath Prefix for reverse proxy sub-path deployment (e.g. /popfile). Requires restart.
