# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# These are where to find the documents on the Wiki

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

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)


# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates


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



# New keys added (translations batch 2)
BucketSelect_AddNew Add new...
BucketSelect_AlreadyExists Already exists
BucketSelect_CreateError Error creating bucket
BucketSelect_InvalidName Only a-z, 0-9, - and _
BucketSelect_NameRequired Name required
Corpus_BucketList Buckets
Corpus_Color Colour
Corpus_Actions Actions
Corpus_Clear Clear
Corpus_StopwordsTitle Stop-words
Corpus_StopwordsDesc Words in this list are never used for classification.
Corpus_RemoveStopword Remove
Corpus_StopwordCandidates Stop-word candidates
Corpus_StopwordCandidatesDesc Words appearing evenly across all buckets — little discriminative power.
Corpus_StopwordRatio Max/min ratio threshold
Corpus_LoadCandidates Find candidates
Corpus_NoCandidates No candidates found at this threshold.
Corpus_AddStopword Add to stop-words
History_AllBuckets All buckets
History_HighlightWords Highlight words by bucket
History_Loading Loading...
History_MoveTo — move to —
History_Moving Moving...
History_Reclassifying Reclassifying...
History_ReclassifyUnclassified Reclassify unclassified
History_Selected selected
Imap_BucketFolderMappings Bucket -> Folder Mappings
Imap_Connected Connected
Imap_Connection Connection
Imap_ConnectionFailed Connection failed
Imap_Description Monitor IMAP folders and automatically classify incoming messages.
Imap_FetchFolders Fetch Folders
Imap_Fetching Fetching...
Imap_IMAFFolder IMAP Folder
Imap_MappingsHint Classified messages are moved to the specified IMAP folder. Leave unmapped buckets empty to skip moving.
Imap_NoFoldersWatched No folders watched yet.
Imap_NoMappings No mappings defined.
Imap_SaveAnyway Save anyway
Imap_SaveConnection Save Connection
Imap_SaveFolders Save Folders
Imap_Saving Saving...
Imap_TestConnection Test Connection
Imap_Testing Testing...
Imap_TrainingHint Training mode scans existing archive folders and trains the classifier on their contents. The flag resets automatically when training completes.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Training mode
Imap_WatchedFolders Watched Folders
Imap_WatchedHint POPFile monitors these IMAP folders for new messages to classify.
Magnet_Created Magnet created
Magnet_Deleted Magnet deleted
NavCorpus Corpus
NavHistory History
NavIMAP IMAP
NavMagnets Magnets
NavStatus Status
Reconnect_Connecting Connecting...
Reconnect_Message The backend is not reachable. Trying to reconnect...
Reconnect_Now Reconnect now
Reconnect_RetryIn Retrying in
Reconnect_Title Connection lost
Settings_AdminPassword Admin Password
Settings_ArchiveDirectory Archive Directory
Settings_ArchiveMessages Archive Messages
Settings_ArchiveSubdirs Archive Sub-dirs
Settings_AutoDetect Auto-detect
Settings_AutoDetectLanguage Auto-detect Language
Settings_ChainPort Chain Port
Settings_ChainServer Chain Server
Settings_DateFormat Date Format
Settings_DescAdminPassword Leave empty to disable password protection.
Settings_DescArchiveDir Directory for archived messages (relative to user dir).
Settings_DescArchiveMessages Save a copy of every classified message to disc.
Settings_DescArchiveSubdirs Split archive into N sub-directories (0 = disabled).
Settings_DescAutoDetectLang Detect the language of each message and apply matching stopwords and stemmer. Adds ~130% classify latency; useful for mixed-language mailboxes.
Settings_DescChainPort Upstream SMTP server port.
Settings_DescChainServer Upstream SMTP server hostname.
Settings_DescDateFormat strftime format string. Leave empty for locale default.
Settings_DescForceFork Fork a new process for each connection.
Settings_DescHEADFetchesBody Retrieve full article with the HEAD command.
Settings_DescHTTPPort Port the web UI listens on. Requires restart.
Settings_DescItemsPerPage Rows shown per page in History and Magnets.
Settings_DescLanguage UI display language. Leave empty to auto-detect from browser.
Settings_DescListenAddress IP address to bind to. Empty = all interfaces.
Settings_DescLocalOnly_UI Restrict the web UI to localhost connections.
Settings_DescLogDirectory Directory for log files. Empty = popfile root.
Settings_DescLogLevel Verbosity of log output.
Settings_DescLogSQLToStdout Print every SQL statement with bound values to stdout. Only active when "Log to stdout" is also enabled.
Settings_DescLogToStdout Mirror log output to stdout in addition to the log file.
Settings_DescMessageCutoff Maximum words analysed per message (0 = unlimited).
Settings_DescNNTPLocalOnly Only accept NNTP connections from localhost.
Settings_DescNNTPPort Port POPFile listens on for NNTP (default 119).
Settings_DescNNTPSeparator Character separating user from server.
Settings_DescPOP3LocalOnly Only accept POP3 connections from localhost.
Settings_DescPOP3Port Port POPFile listens on for POP3 (default 1110).
Settings_DescPOP3Separator Character that separates user from server (e.g. user:mailhost).
Settings_DescRetentionDays How many days to keep message history.
Settings_DescSessionDividers Show dividers between browsing sessions in History.
Settings_DescSMTPLocalOnly Only accept SMTP connections from localhost.
Settings_DescSMTPPort Port POPFile listens on for SMTP (default 25).
Settings_DescSQLiteJournal SQLite journal / WAL mode.
Settings_DescSQLiteTweaks Bitmask: 1 = faster writes (less safe), 2 = periodic backup.
Settings_DescSSLChainPort Upstream SSL POP3 server port.
Settings_DescSSLChainServer Upstream SSL POP3 server hostname for SSL chaining.
Settings_DescSubjectTagLeft Prefix inserted into Subject header, e.g. [SPAM].
Settings_DescSubjectTagRight Suffix appended to Subject header.
Settings_DescTagPosition Where to place the subject tag.
Settings_DescTOPFetchesBody Also retrieve message body with the TOP command.
Settings_DescUnclassifiedWeight Probability threshold below which mail is "unclassified".
Settings_DescWordStemming Reduce words to their stem before classification (e.g. "running" to "run"). Improves recall for morphologically rich languages at ~10% latency cost.
Settings_DescWordTable What to display in the word probability table.
Settings_ErrorSaving Error saving
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD Fetches Body
Settings_HTTPPort HTTP Port
Settings_ItemsPerPage Items Per Page
Settings_ListenAddress Listen Address
Settings_ListenPort Listen Port
Settings_LocalOnly Local Only
Settings_LogDirectory Log Directory
Settings_LogLevel Log Level
Settings_LogSQLToStdout Log SQL to stdout
Settings_LogToStdout Log to stdout
Settings_OpenBrowser Open browser on start
Settings_DescOpenBrowser Open the default browser when the web UI is ready.
Settings_MessageCutoff Message Cutoff
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
Settings_SaveChanges Save Changes
Settings_Saved Saved
Settings_Saving Saving...
Settings_Search Search settings...
Settings_SectionClassifier Classifier
Settings_SectionHistory History
Settings_SectionLogging Logging
Settings_SectionNNTP NNTP Proxy
Settings_SectionPOP3 POP3 Proxy
Settings_SectionSecurity Security
Settings_SectionSMTP SMTP Proxy
Settings_SectionUI User Interface
Settings_ServerSeparator Server Separator
Settings_SessionDividers Session Dividers
Settings_SQLiteJournalMode SQLite Journal Mode
Settings_SQLiteTweaks SQLite Tweaks
Settings_SSLChainPort SSL Chain Port
Settings_SSLChainServer SSL Chain Server
Settings_SubjectTagLeft Subject Tag Left
Settings_SubjectTagRight Subject Tag Right
Settings_TagPosition Tag Position
Settings_TOPFetchesBody TOP Fetches Body
Settings_UnclassifiedWeight Unclassified Weight
Settings_WordStemming Word Stemming
Settings_WordTable Word Table
Status_Checking Checking...
Status_Description Health checks for POPFile services.
Status_LoadError Failed to load status
Status_NoChecks No checks available.

Language_Name                           English (UK)
