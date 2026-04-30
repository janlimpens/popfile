# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            en
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# These are where to find the documents on the Wiki
WikiLink                                index.php
FAQLink                                 FAQ
RequestFeatureLink                      RequestFeature
MailingListLink                         mailing_lists
DonateLink                              Donate

# Common words that are used on their own all over the interface
Apply                                   Apply
ApplyChanges                            Apply Changes
On                                      On
Off                                     Off
TurnOn                                  Turn On
TurnOff                                 Turn Off
Add                                     Add
Remove                                  Remove
Previous                                Previous
Next                                    Next
From                                    From
Subject                                 Subject
Cc                                      Cc
Classification                          Bucket
Reclassify                              Reclassify
Probability                             Probability
Scores                                  Scores
QuickMagnets                            QuickMagnets
Undo                                    Undo
Close                                   Close
Find                                    Find
Filter                                  Filter
Yes                                     Yes
No                                      No
ChangeToYes                             Change to Yes
ChangeToNo                              Change to No
Bucket                                  Bucket
Magnet                                  Magnet
Delete                                  Delete
Create                                  Create
To                                      To
Total                                   Total
Rename                                  Rename
Frequency                               Frequency
Probability                             Probability
Score                                   Score
Lookup                                  Lookup
Word                                    Word
Count                                   Count
Update                                  Update
Refresh                                 Refresh
FAQ                                     FAQ
ID                                      ID
Date                                    Date
Arrived                                 Arrived
Size                                    Size

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       ,
Locale_Decimal                         .

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            POPFile Control Center
Header_Shutdown                         Shutdown POPFile
Header_History                          History
Header_Buckets                          Buckets
Header_Configuration                    Configuration
Header_Advanced                         Advanced
Header_Security                         Security
Header_Magnets                          Magnets

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Donate
Footer_RequestFeature                   Request Feature
Footer_MailingList                      Mailing List
Footer_Wiki                             Documentation

Configuration_Error1                    The separator character must be a single character
Configuration_Error2                    The user interface port must be a number between 1 and 65535
Configuration_Error3                    The POP3 listen port must be a number between 1 and 65535
Configuration_Error4                    The page size must be a number between 1 and 1000
Configuration_Error5                    The number of days in the history must be a number between 1 and 366
Configuration_Error6                    The TCP timeout must be a number between 10 and 1800
Configuration_Error7                    The XML RPC listen port must be a number between 1 and 65535
Configuration_Error8                    The SOCKS V proxy port must be a number between 1 and 65535
Configuration_Error9                    The user interface port cannot be the same value as the POP3 listen port
Configuration_Error10                   The POP3 listen port cannot be the same value as the user interface port
Configuration_POP3Port                  POP3 listen port
Configuration_POP3Update                Updated POP3 port to %s; this change will not take affect until you restart POPFile
Configuration_XMLRPCUpdate              Updated XML-RPC port to %s; this change will not take affect until you restart POPFile
Configuration_XMLRPCPort                XML-RPC listen port
Configuration_SMTPPort                  SMTP listen port
Configuration_SMTPUpdate                Updated SMTP port to %s; this change will not take affect until you restart POPFile
Configuration_NNTPPort                  NNTP listen port
Configuration_NNTPUpdate                Updated NNTP port to %s; this change will not take affect until you restart POPFile
Configuration_POPFork                   Allow concurrent POP3 connections
Configuration_SMTPFork                  Allow concurrent SMTP connections
Configuration_NNTPFork                  Allow concurrent NNTP connections
Configuration_POP3Separator             POP3 host:port:user separator character
Configuration_NNTPSeparator             NNTP host:port:user separator character
Configuration_POP3SepUpdate             Updated POP3 separator to %s
Configuration_NNTPSepUpdate             Updated NNTP separator to %s
Configuration_UI                        User interface web port
Configuration_UIUpdate                  Updated user interface web port to %s; this change will not take affect until you restart POPFile
Configuration_History                   Number of messages per page
Configuration_HistoryUpdate             Updated number of messages per page to %s
Configuration_Days                      Number of days of history to keep
Configuration_DaysUpdate                Updated number of days of history to %s
Configuration_UserInterface             User Interface
Configuration_Skins                     Skins
Configuration_SkinsChoose               Choose skin
Configuration_Language                  Language
Configuration_LanguageChoose            Choose language
Configuration_ListenPorts               Module Options
Configuration_HistoryView               History View
Configuration_TCPTimeout                Connection Timeout
Configuration_TCPTimeoutSecs            Connection timeout in seconds
Configuration_TCPTimeoutUpdate          Updated connection timeout to %s
Configuration_ClassificationInsertion   Message Text Insertion
Configuration_SubjectLine               Subject line<br>modification
Configuration_XTCInsertion              X-Text-Classification<br>Header
Configuration_XPLInsertion              X-POPFile-Link<br>Header
Configuration_Logging                   Logging
Configuration_None                      None
Configuration_ToScreen                  To Screen (console)
Configuration_ToFile                    To File
Configuration_ToScreenFile              To Screen and File
Configuration_LoggerOutput              Logger output
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins
Configuration_CurrentLogFile            &lt;View current log file&gt;
Configuration_SOCKSServer               SOCKS V proxy host
Configuration_SOCKSPort                 SOCKS V proxy port
Configuration_SOCKSPortUpdate           Updated SOCKS V proxy port to %s
Configuration_SOCKSServerUpdate         Updated SOCKS V proxy host to %s
Configuration_Fields                    History Columns

Advanced_Error1                         '%s' already in the Ignored Words list
Advanced_Error2                         Ignored words can only contain alphanumeric, ., _, -, or @ characters
Advanced_Error3                         '%s' added to the Ignored Words list
Advanced_Error4                         '%s' is not in the Ignored Words list
Advanced_Error5                         '%s' removed from the Ignored Words list
Advanced_StopWords                      Ignored Words
Advanced_Message1                       POPFile ignores the following frequently-used words:
Advanced_AddWord                        Add word
Advanced_RemoveWord                     Remove word
Advanced_AllParameters                  All POPFile Parameters
Advanced_Parameter                      Parameter
Advanced_Value                          Value
Advanced_Warning                        This is the complete list of POPFile parameters.  Advanced users only: you may change any and click Update; there is no validity checking.  Items shown in bold have been changed from the default setting.  See <a href="http://getpopfile.org/docs/OptionReference">OptionReference</a> for more information on options.
Advanced_ConfigFile                     Configuration file:

History_Filter                          &nbsp;(just showing bucket <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(searched for from/subject %s)
History_Title                           Recent Messages
History_Jump                            Jump to page
History_ShowAll                         Show All
History_ShouldBe                        Should be
History_NoFrom                          no from line
History_NoSubject                       no subject line
History_ClassifyAs                      Classify as
History_MagnetUsed                      Magnet used
History_MagnetBecause                   <b>Magnet Used</b><p>Classified to <font color="%s">%s</font> because of magnet %s </p>
History_ChangedTo                       Changed to <font color="%s">%s</font>
History_Already                         Reclassified as <font color="%s">%s</font>
History_RemoveAll                       Remove All
History_RemovePage                      Remove Page
History_RemoveChecked                   Remove Checked
History_Remove                          To remove entries in the history click
History_SearchMessage                   Search From/Subject
History_NoMessages                      No messages
History_NoMatchingMessages              No matching messages
History_ShowMagnet                      magnetized
History_Negate_Search                   Invert search/filter
History_Magnet                          &nbsp;(just showing magnet classified messages)
History_NoMagnet                        &nbsp;(just showing non-magnet classified messages)
History_ResetSearch                     Reset
History_ChangedClass                    Would now classify as
History_Purge                           Expire Now
History_Increase                        Increase
History_Decrease                        Decrease
History_Column_Characters               Change width of From, To, Cc and Subject columns
History_Automatic                       Automatic
History_Reclassified                    Reclassified
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          Password
Password_Enter                          Enter password
Password_Go                             Go!
Password_Error1                         Incorrect password

Security_Error1                         The port must be a number between 1 and 65535
Security_Stealth                        Stealth Mode/Server Operation
Security_NoStealthMode                  No (Stealth Mode)
Security_StealthMode                    (Stealth Mode)
Security_ExplainStats                   (With this turned on POPFile sends once per day the following three values to a script on getpopfile.org: bc (the total number of buckets that you have), mc (the total number of messages that POPFile has classified) and ec (the total number of classification errors). These three values get stored in a database which is used to generate some <a href="http://getpopfile.org/popfile_stats.html"><b>statistics</b></a> about how people use POPFile and how well it works.  Our web server keeps its log files for several days and then they get deleted; we are not storing any connection between the statistics and individual IP addresses.)
Security_ExplainUpdate                  (With this turned on POPFile sends once per day the following three values to a script on getpopfile.org: ma (the major version number of your installed POPFile), mi (the minor version number of your installed POPFile) and bn (the build number of your installed POPFile).  POPFile receives a response in the form of a graphic that appears at the top of the page if a new version is available.  Our web server keeps its log files for several days and then they get deleted; we are not storing any connection between the update checks and individual IP addresses.)
Security_PasswordTitle                  User Interface Password
Security_Password                       Password
Security_PasswordUpdate                 Updated password
Security_AUTHTitle                      Remote Servers
Security_SecureServer                   Remote POP3 server (SPA/AUTH or transparent proxy)
Security_SecureServerUpdate             Updated remote POP3 server to %s
Security_SecurePort                     Remote POP3 port (SPA/AUTH or transparent proxy)
Security_SecurePortUpdate               Updated remote POP3 server port to %s
Security_SMTPServer                     SMTP chain server
Security_SMTPServerUpdate               Updated SMTP chain server to %s; this change will not take affect until you restart POPFile
Security_SMTPPort                       SMTP chain port
Security_SMTPPortUpdate                 Updated SMTP chain port to %s; this change will not take affect until you restart POPFile
Security_POP3                           Accept POP3 connections from remote machines (requires POPFile restart)
Security_SMTP                           Accept SMTP connections from remote machines (requires POPFile restart)
Security_NNTP                           Accept NNTP connections from remote machines (requires POPFile restart)
Security_UI                             Accept HTTP (User Interface) connections from remote machines  (requires POPFile restart)
Security_XMLRPC                         Accept XML-RPC connections from remote machines (requires POPFile restart)
Security_UpdateTitle                    Automatic Update Checking
Security_Update                         Check daily for updates to POPFile
Security_StatsTitle                     Reporting Statistics
Security_Stats                          Send statistics daily

Magnet_Error1                           Magnet '%s' already exists in bucket '%s'
Magnet_Error2                           New magnet '%s' clashes with magnet '%s' in bucket '%s' and could cause ambiguous results.  New magnet was not added.
Magnet_Error3                           Create new magnet '%s' in bucket '%s'
Magnet_CurrentMagnets                   Current Magnets
Magnet_Message1                         The following magnets cause mail to always be classified into the specified bucket.
Magnet_CreateNew                        Create New Magnet
Magnet_Explanation                      These types of magnets are available: <ul><li><b>From address or name:</b> For example: john@company.com to match a specific address, <br />company.com to match everyone who sends from company.com, <br />John Doe to match a specific person, John to match all Johns</li><li><b>To/Cc address or name:</b> Like a From: magnet but for the To:/Cc: address in a message</li> <li><b>Subject words:</b> For example: hello to match all messages with hello in the subject</li></ul>
Magnet_MagnetType                       Magnet type
Magnet_Value                            Values
Magnet_Always                           Always goes to bucket
Magnet_Jump                             Jump to magnet page

Bucket_Error1                           Bucket names can only contain the letters a to z in lower case, numbers 0 to 9,  plus - and _
Bucket_Error2                           Bucket named %s already exists
Bucket_Error3                           Created bucket named %s
Bucket_Error4                           Please enter a non-blank word
Bucket_Error5                           Renamed bucket %s to %s
Bucket_Error6                           Deleted bucket %s
Bucket_Title                            Bucket Configuration
Bucket_BucketName                       Bucket<br>Name
Bucket_WordCount                        Word Count
Bucket_WordCounts                       Word Counts
Bucket_UniqueWords                      Distinct<br>Words
Bucket_SubjectModification              Subject Header<br>Modification
Bucket_ChangeColor                      Bucket<br>Color
Bucket_NotEnoughData                    Not enough data
Bucket_ClassificationAccuracy           Classification Accuracy
Bucket_EmailsClassified                 Messages classified
Bucket_EmailsClassifiedUpper            Messages Classified
Bucket_ClassificationErrors             Classification errors
Bucket_Accuracy                         Accuracy
Bucket_ClassificationCount              Classification Count
Bucket_ClassificationFP                 False Positives
Bucket_ClassificationFN                 False Negatives
Bucket_ResetStatistics                  Reset Statistics
Bucket_LastReset                        Last Reset
Bucket_CurrentColor                     %s current color is %s
Bucket_SetColorTo                       Set %s color to %s
Bucket_Maintenance                      Maintenance
Bucket_CreateBucket                     Create bucket with name
Bucket_DeleteBucket                     Delete bucket named
Bucket_RenameBucket                     Rename bucket named
Bucket_Lookup                           Lookup
Bucket_LookupMessage                    Lookup word in buckets
Bucket_LookupMessage2                   Lookup result for
Bucket_LookupMostLikely                 <b>%s</b> is most likely to appear in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> does not appear in any of the buckets
Bucket_InIgnoredWords                   <b>%s</b> is in Ignored Words. POPFile ignores this word
Bucket_DisabledGlobally                 Disabled globally
Bucket_To                               to
Bucket_Quarantine                       Quarantine<br>Message

SingleBucket_Title                      Detail for %s
SingleBucket_WordCount                  Bucket word count
SingleBucket_TotalWordCount             Total word count
SingleBucket_Percentage                 Percentage of total
SingleBucket_WordTable                  Word Table for %s
SingleBucket_Message1                   Click a letter in the index to see the list of words that start with that letter.  Click any word to lookup its probability for all buckets.
SingleBucket_Unique                     %s distinct
SingleBucket_ClearBucket                Remove All Words

Session_Title                           POPFile Session Expired
Session_Error                           Your POPFile session has expired.  This could have been caused by starting and stopping POPFile but leaving your web browser open.  Please click one of the links above to continue using POPFile.

View_Title                              Single Message View
View_ShowFrequencies                    Show word frequencies
View_ShowProbabilities                  Show word probabilities
View_ShowScores                         Show word scores and decision chart
View_WordMatrix                         Word matrix
View_WordProbabilities                  showing word probabilities
View_WordFrequencies                    showing word frequencies
View_WordScores                         showing word scores
View_Chart                              Decision Chart
View_DownloadMessage                    Download Message
View_MessageHeader                      Message Header
View_MessageBody                        Message Body

Windows_TrayIcon                        Show POPFile icon in Windows system tray?
Windows_Console                         Run POPFile in a console window?
Windows_NextTime                        <p><font color="red">This change will not take effect until the next time you start POPFile</font>

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of a message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the message's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many messages have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the message classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of messages classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency with which that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in a message.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify messages according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the message before it is passed on to the message client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying messages due to their relative frequency in messages in general.  They are organized per row according to the first letter of the words.

Imap_Bucket2Folder                      Mail for bucket '<b>%s</b>' goes to folder
Imap_MapError                           You cannot map more than one bucket to a single folder!
Imap_Server                             IMAP server hostname:
Imap_ServerNameError                    Please enter the server's hostname!
Imap_Port                               IMAP Server port:
Imap_PortError                          Please enter a valid port number!
Imap_Login                              IMAP account login:
Imap_LoginError                         Please enter a user/login name!
Imap_Password                           Password for IMAP account:
Imap_PasswordError                      Please enter a password for the server!
Imap_Expunge                            Expunge deleted messages from watched folders.
Imap_Interval                           Update interval in seconds:
Imap_IntervalError                      Please enter an interval between 10 and 3600 seconds.
Imap_Bytelimit                          Bytes per message to use for classification. Enter 0 (Null) for the complete message:
Imap_BytelimitError                     Please enter a number.
Imap_RefreshFolders                     Refresh list of folders
Imap_Now                                now!
Imap_UpdateError1                       Could not login. Verify your login name and password, please.
Imap_UpdateError2                       Failed to connect to server. Please check the host name and port and make sure you are online.
Imap_UpdateError3                       Please configure the connection details first.
Imap_NoConnectionMessage                Please configure the connection details first. After you have done that, more options will be available on this page.
Imap_WatchMore                          a folder to list of watched folders
Imap_WatchedFolder                      Watched folder no
Imap_Use_SSL							Use SSL

Shutdown_Message                        POPFile has shut down

Help_Training                           When you first use POPFile, it knows nothing and will need some training. POPFile requires training on messages for each bucket, training occurs when you reclassify a message POPFile missclassified to the correct bucket. Before POPFile will classify the first message, you will have to have reclassified messages to at least two buckets. You must also setup your mail client to filter messages based on POPFile's classification. Information on setting up your client filtering can be found at the <a href="http://getpopfile.org/docs/FAQ:EmailSorting">POPFile Documentation Project</a>.
Help_Bucket_Setup                       POPFile requires at least two buckets in addition to the "unclassified" pseudo-bucket. What makes POPFile unique is that it can classify email more than that, you can have any number of buckets. A simple setup would be a "spam", "personal", and a "work" bucket.
Help_No_More                            Don't show this again

NavHistory                              History
NavCorpus                               Corpus
NavWordSearch                           Words & Stopwords
NavMagnets                              Magnets
NavIMAP                                 IMAP
NavStatus                               Status
NavSettings                             Settings

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
Imap_Service                            Service
Imap_EnableService                      Enable IMAP service
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
Corpus_WordsLink                        Words →
Corpus_BucketList                       Buckets
Corpus_Search                           Search
WordSearch_Title                        Word Search
WordSearch_Placeholder                  prefix...
WordSearch_Search                       Search
WordSearch_ColumnWord                   Word
WordSearch_ColumnBuckets                Buckets
WordSearch_Coverage                     coverage
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
Wizard_Welcome                          Welcome to POPFile. POPFile helps you keep your inbox organised. Start by entering your username — usually your email address.
Wizard_Username                         Username
Wizard_Done                             All set!
