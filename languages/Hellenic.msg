# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

# Identify the language and character set used for the interface
LanguageCode                            gr
LanguageCharset                         ISO-8859-7
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Εφαρμογή
On                                     Ενεργό
Off                                     Ανενεργό
TurnOn                             Ενεργοποίηση
TurnOff                             Απενεργοποίη
Add                                     Προσθήκη
Remove                                  Απαλοιφή
Previous                                Προηγούμενο
Next                                    Επόμενο
From                                    Αποστολέας
Subject                                 Θέμα
Cc                                      Κοιν. 
Classification                          Ταξινόμηση
Reclassify                              Επαναταξινόμηση
Probability                             Πιθανότητα
Scores                                  Βαθμόλογίες
QuickMagnets                            Γρήγοροι Μαγνήτες
Undo                                    Undo
Close                                   Κλείσιμο
Find                                    Εύρεση
Filter                                  Φίλτρο
Yes                                     Ναί
No                                      Οχι
ChangeToYes                             Αλλαγή σε Ναί
ChangeToNo                              Αλλαγή σε Όχι
Bucket                                  Αρχείο
Magnet                                  Μαγνήτης
Delete                                  Διαγραφή
Create                                  Δημιουργία
To                                      Πρός
Total                                   Σύνολο
Rename                                  Μετονομασία
Frequency                               Συχνότητα
Probability                             Πιθανότητα
Score                                   Βαθμός
Lookup                                  Εύρευση
Word                                    Λέξη
Count                             Εμφανίσεις
Update                                  Ενημέρωση
Refresh                                 Φρεσκάρισμα

# The header and footer that appear on every UI page
Header_Title                            Κεντρο Ελέγχου POPFile
Header_Shutdown                         Κλείσιμο POPFile
Header_History                          Ιστορικό
Header_Buckets                          Αρχεία
Header_Configuration                    Επιλογές
Header_Advanced                         Προχωρημένες Επιλογές
Header_Security                         Ασφάλεια
Header_Magnets                          Μαγνήτες

Footer_HomePage                     Ιστοσελίδα POPFile
Footer_Manual                          Εγχειρίδιο
Footer_Forums                          Συζυτήσεις
Footer_FeedMe                         Συνεισφορά
Footer_RequestFeature           Ζητήστε Βελτιώσεις
Footer_MailingList                   Ενημερωτικά mail

Configuration_Error1                    Ο διαχωριστικός χαρακτήρας πρέπει να είναι μόνο ένας. 
Configuration_Error2                    Το  user interface port πρέπει να είναι μεταξύ 1 και 65535
Configuration_Error3                    Το POP3 listen port πρέπει να είναι μεταξύ 1 και 65535
Configuration_Error4                    Το μέγεθος σελίδας πρέπει να είναι μεταξύ 1 και 1000
Configuration_Error5                    Ο αριθμός ημερών για τήρηση ιστορικού πρέπει να είναι μεταξύ 1 και 366
Configuration_Error6                    Η παράμετρος TCP timeout πρέπει να είναι μεταξύ 10 και 1800
Configuration_Error7                    Η παράμετρος XML RPC listen port πρέπει να είναι μεταξύ 1 και 65535
Configuration_POP3Port                  POP3 listen port
Configuration_POP3Update                Η παράμετρος POP3 port άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_XMLRPCUpdate              Η παράμετρος XML-RPC port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_XMLRPCPort                XML-RPC listen port
Configuration_SMTPPort                  SMTP listen port
Configuration_SMTPUpdate                Η παράμετρος SMTP port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_NNTPPort                  NNTP listen port
Configuration_NNTPUpdate                Η παράμετρος NNTP port άλλαξε σε %s;  Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Configuration_POP3Separator             POP3 host:port:χαρακτήρας διαχωρισμού
Configuration_NNTPSeparator             NNTP host:port:Χαρακτήρας διαχωρισμού
Configuration_POP3SepUpdate             Αλλαγή χαρακτήρα διαχωρισμού POP3 σε %s
Configuration_NNTPSepUpdate             Αλλαγή χαρακτήρα διαχωρισμού NNTP σε %s
Configuration_UI                        Web port επιφάνειας ελέγχου
Configuration_UIUpdate                  Updated user interface web port to %s; this change will not take affect until you restart POPFile
Configuration_History                   Αριθμός μυνημάτων ανά Σελίδα
Configuration_HistoryUpdate             Αλλαγή αριθμού μυνημάτων ανά σελίδα σε %s
Configuration_Days                      Αρθιμός ημερών που κρατούνται σε ιστορικό
Configuration_DaysUpdate                Αλλαγή αρθιμού ημερών που κρατούνται σε ιστορικό σε %s
Configuration_UserInterface             Επιφάνεια Ελέγχου
Configuration_Skins                     Εμφάνιση
Configuration_SkinsChoose               Επιλογή εμφάνισης
Configuration_Language                  Γλώσσα
Configuration_LanguageChoose            Επιλογή Γλώσσας
Configuration_ListenPorts               Επιλογές επικοινωνίας
Configuration_HistoryView               Ιστορικό
Configuration_TCPTimeout                Connection Timeout
Configuration_TCPTimeoutSecs            Connection timeout σε δευτερόλεπτα
Configuration_TCPTimeoutUpdate          Αλλαγή  connection timeout σε %s
Configuration_ClassificationInsertion   Εισαγωγή Κειμένου σε μυνήματα
Configuration_SubjectLine               Αλλαγή Θέματος Μυνημάτων
Configuration_XTCInsertion              X-Text-Classification Header
Configuration_XPLInsertion              X-POPFile-Link Header
Configuration_Logging                   Ημερολόγιο Ενεργειών
Configuration_None                      Κανένα
Configuration_ToScreen                  Στην Οθόνη
Configuration_ToFile                    Σε Αρχείο
Configuration_ToScreenFile              Στην Οθόνη και σε αρχείο
Configuration_LoggerOutput              Εμφάνιση Ημερολογίου Ενεργειών
Configuration_GeneralSkins              Εμφανίσεις
Configuration_SmallSkins                 Μικρές Εμφανίσεις
Configuration_TinySkins                 Πιο Μικρές Εμφανίσεις
Configuration_CurrentLogFile            &lt;current log file&gt;

Advanced_Error1                         '%s' είναι ήδη στις εξαιρούμενες λέξεις
Advanced_Error2                         Οι εξαιρούμενες λέξεις μπορούν να συμπεριλαμβάνουν μόνο αλφανουμερικές λέξεις , ., _, -, η @ χαρακτήρες
Advanced_Error3                         '%s' προστέθηκε στις εξαιρούμενες λέξεις
Advanced_Error4                         '%s' δεν ανήκει στις εξαιρούμενες λέξεις
Advanced_Error5                         '%s' αφαιρέθηκε από τις εξαιρούμενες λέξεις
Advanced_StopWords                      Λέξεις που εξαιρούνται 
Advanced_Message1                       Το POPFile εξαιρεί τις ακόλουθες συχνά εμφανιζόμενες λέξεις :
Advanced_AddWord                        Προσθήκη Λέξης
Advanced_RemoveWord                     Αφαίρεση Λέξης

History_Filter                          &nbsp;(εμφανίζεται μόνον αρχείο <font color="%s">%s</font>)
History_FilterBy                        Φιλτράρισμα με χρήση
History_Search                          &nbsp;(αναζήτηση για Αποστολέα/Θέμα %s)
History_Title                           Προσφατα Μυνήματα
History_Jump                            Μυνήματα από
History_ShowAll                         Εμφάνιση όλων
History_ShouldBe                        Να ταξιμομηθεί ώς
History_NoFrom                          Δεν έχει αποστολέα
History_NoSubject                       Δεν υπάρχει θέμα
History_ClassifyAs                      Να ταξινομηθεί σαν
History_MagnetUsed                      Μαγνήτης σε χρήση
History_MagnetBecause                   <b>Μαγνήτης σε χρήση</b><p>Εχει ταξινομηθεί σε <font color="%s">%s</font> λόγω μαγνήτη %s </p>
History_ChangedTo                       Αλλαξε σε <font color="%s">%s
History_Already                         Εχει ήδη επαναταξινομηθεί σε <font color="%s">%s</font>
History_RemoveAll                       Διαγραφή Ολων
History_RemovePage                     Διαγραφή Σελίδας
History_Remove                          Για να διαγράψετε στοιχεία του ιστορικού πατήστε
History_SearchMessage                   Αναξήτηση Αποστολέα/Θέμα
History_NoMessages                      Δεν υπάρχουν Μηνύματα
History_ShowMagnet                      μαγνητισμένο
History_ShowNoMagnet                    μη μαγνητισμένο
History_Magnet                          &nbsp;(εμφάνιση μόνο μαγνητισμένων μυνημάτων)
History_NoMagnet                        &nbsp;(εμφάνιση μόνο μή μαγνητισμένων μυνημάτων)
History_ResetSearch                     Επαναφορά

Password_Title                          Σύνθημα
Password_Enter                          Γράψτε σύνθημα
Password_Go                             Προχωρήστε!
Password_Error1                         Λάθος σύνθημα

Security_Error1                         Το  port πρέπει να είναι ένας αριθμός μεταξύ 1 και 65535
Security_Stealth                        Λειτουργία Απόκρυψής/Λειτουργία Server
Security_NoStealthMode                  Οχι ( Λειτουργία Απόκρυψης )
Security_ExplainStats                   (Με αυτή την επιλογή ενεργή το POPFile στέλνει κάθε ημέρα τις ακόλουθες τρείς παραμέτρους σε ένα πρόγραμμα στο getpopfile.org: bc (σύνολο αρχείων που χρησιμοποιούνται ), mc (σύνολο ταξινομημένων μυνημάτων) and ec (σύνολο λαθών ταξινόμησης).  Αυτά αρχειοθετούνται και χρησιμοποιούνται για να συνταχθούν στατιστικές για το πώς οι χρήστες χρησιμοποιούν το POPFile αλλά και πόσο αποτελεσματικά αυτό δουλεύειs.  Τα αρχεία σβήνονται με την παρέλευση πενθημέρου; Δεν γίνονται συσχετισμοί μεταξύ των στατιστικών και των μεμονομένων διευθύνσεων IP.)
Security_ExplainUpdate                  (Με αυτή την επιλογή ενεργή το POPFile στέλνει κάθε ημέρα τις ακόλουθες τρείς παραμέτρους σε ένα πρόγραμμα στο getpopfile.org:: ma (τον κύριο αριθμό έκδοσης του εν χρήση POPFile), mi (τον δευτερεύοντα αριθμό έκδοσης του εν χρήση POPFile) και bn (τον  αριθμό έκδοσης του εν χρήση POPFile).  Το POPFile λαμβάνει μία απάντηση με την μορφή γραφικού που εμφανίζεται στην άνω μεριά της σελίδας, και σας ειδοποιεί ότι υπάρχει νέα ενημερωμένη έκδοση.  Τα αρχεία σβήνονται με την παρέλευση πενθημέρου; Δεν γίνονται συσχετισμοί μεταξύ των στατιστικών και των μεμονομένων διευθύνσεων IP.)
Security_PasswordTitle                  Σύνθημα Επιφάνειας Χρήσης
Security_Password                       Σύνθημα
Security_PasswordUpdate                 Το σύνθημα άλλαξε σε  %s
Security_AUTHTitle                      Remote Servers
Security_SecureServer                   POP3 SPA/AUTH server
Security_SecureServerUpdate             Η παράμετρος POP3 SPA/AUTH secure server άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SecurePort                     POP3 SPA/AUTH port
Security_SecurePortUpdate               Η παράμετρος POP3 SPA/AUTH port  άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SMTPServer                     SMTP chain server
Security_SMTPServerUpdate               Η παράμετρος SMTP chain server άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_SMTPPort                       SMTP chain port
Security_SMTPPortUpdate                 Η παράμετρος SMTP chain port άλλαξε σε %s; Οι αλλαγές θα γίνουν ενεργές στην επόμενη εκκίνηση του POPFile
Security_POP3                           Να γίνονται αποδεκτές συνδέσεις POP3 από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_SMTP                           Να γίνονται αποδεκτές συνδέσεις SMTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_NNTP                           Να γίνονται αποδεκτές συνδέσεις NNTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_UI                             Να γίνονται αποδεκτές συνδέσεις HTTP από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_XMLRPC                         Να γίνονται αποδεκτές συνδέσεις XML-RPC από Η/Υ στο δίκτυο (χρειάζεται επανεκκίνηση του POPFile )
Security_UpdateTitle                    Αυτόματος Ελεγχος για Ενημερωμένες Εκδόσεις
Security_Update                         Καθημερινός έλεγχος για Ενημερωμένες Εκδόσεις του  POPFile
Security_StatsTitle                     Αποστολή Στατιστικών
Security_Stats                          Καθημερινή Αποστολή Στατιστικών

Magnet_Error1                           Ο Μαγνήτης '%s' υπάρχει ήδη στο αρχείο '%s'
Magnet_Error2                           Ο νέος Μαγνήτης '%s' είναι σε αντίφαση με τον ήδη υπάρχοντα '%s' στο αρχείο '%s' και αυτό θα οδηγούσε σε λανθασμένες ταξινομήσεις.  Ο νέος μαγνήτης δεν προσετέθει..
Magnet_Error3                           Δημιουργία νέου μαγνήτη '%s' στο αρχείο '%s'
Magnet_CurrentMagnets                   Υπάρχοντες Μαγνήτες
Magnet_Message1                         Οι ακόλουθοι μαγνήτες πάντα ταξινομούν τα μυνήματα σας στο προκαθορισμένο αρχείο :.
Magnet_CreateNew                        Δημιουργία νέου μαγνήτη
Magnet_Explanation                      Αυτοί οι τύποι μαγνήτη είναι διαθέσιμοι: <ul><li><b>Από Διυυθυνση η Ονομα:</b> Π.χ.: john@company.com για συγκεκριμένη διευθυνσηs, <br />company.com για όλες τις διευθύνσεις που καταλήγουν σε company.com, <br />John Doe για συγκεκριμένο όνομα, John για όλους με πρώτο όνομα John</li><li><b>Προς/Κοιν. διεύθυνση η όνομα:</b> ¨Οπως για Αποστολέα αλλα αφορά τα πεδία Πρός/ Κοιν.:</li> <li><b>Θέμα :</b> Π.χ.: hello για να μαγνητισθούν όλα τα μυνήματα που περιέχουν την λέξη hello στο θέμα</li></ul>
Magnet_MagnetType                      Τύποι Μαγνητών
Magnet_Value                            Αξία
Magnet_Always                           Παντα ταξινομείται στο αρχείο
Magnet_Jump                             Μαγνήτες από 

Bucket_Error1                           Τα ονόματα των αρχείων μπορούν να περιέχουν μόνο τα πεζά αγγλικά γράμματα  a έως z, τους αριθμούς 0 εως 9,  και τους χαρακτήρες  - και _
Bucket_Error2                           Αρχείο  %s υπάρχει ήδη
Bucket_Error3                           Δημιουργήθηκε αρχείο με όνομα %s
Bucket_Error4                           Παρακαλούμε εισάγετε μι όχι κενή λέξη
Bucket_Error5                           Το αρχείο %s μετονομάστηκε σε %s
Bucket_Error6                           Διαγράφθηκε το αρχείο %s
Bucket_Title                            Περίληψη
Bucket_BucketName                       Αρχείο
Bucket_WordCount                        Πλήθος Λέξεων
Bucket_WordCounts                       Στατιστικά Λέξεων
Bucket_UniqueWords                      Μοναδικές Λέξεις
Bucket_SubjectModification              Αλλαγή Θέματος Μυνημάτων
Bucket_ChangeColor                      Αλλαγή Χρώματος
Bucket_NotEnoughData                    Ανεπαρκή Δεδομένα
Bucket_ClassificationAccuracy           Ακρίβεια Ταξινόμησης
Bucket_EmailsClassified                 Ταξινομημένα μυνήματα
Bucket_EmailsClassifiedUpper            Ταξινομημένα Μυνήματα
Bucket_ClassificationErrors             Σφάλματα Ταξινόμησης
Bucket_Accuracy                         Ακρίβεια Ταξινόμησης
Bucket_ClassificationCount              Αριθμ. Ταξινομήσεων
Bucket_ClassificationFP                 Ψευδή Θετικά
Bucket_ClassificationFN                 Ψευδή Αρνητικά
Bucket_ResetStatistics                  Μηδενισμός Στατιστικών
Bucket_LastReset                        Τελευταίος Μηδενισμός
Bucket_CurrentColor                     τρέχων χρώμα %s  είναι %s
Bucket_SetColorTo                       Ορισμός χρώματος  %s σε %s
Bucket_Maintenance                      Συντήρηση Αρχείων
Bucket_CreateBucket                     Δημιουργία αρχείου με όνομα
Bucket_DeleteBucket                     Διαγραφή αρχείου με όνομα
Bucket_RenameBucket                     Μετονομασία αρχείου με όνομα
Bucket_Lookup                           Εύρεση
Bucket_LookupMessage                    Εύρευση λέξεως σε αρχεία
Bucket_LookupMessage2                   Αποτελέσματα εύρεσης λέξεως 
Bucket_LookupMostLikely                 <b>%s</b> είναι πιο πιθανό να ανήκει στο <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> δεν ανήκει σε κανένα από τα αρχεία
Bucket_DisabledGlobally                 Γενικώς Απενεργοποιημένο 
Bucket_To                               σε
Bucket_Quarantine                       Καραντίνα

SingleBucket_Title                      Λεπτομέρειες του αρχείου %s
SingleBucket_WordCount                  Αριθμός λέξεων αρχείου
SingleBucket_TotalWordCount             Συνολικές εμφανίσεις λέξεων
SingleBucket_Percentage                 Ποσοστό επί συνόλου
SingleBucket_WordTable                  Πίνακας λέξεων για %s
SingleBucket_Message1                   Κάντε κλίκ πάνω σε ένα γράμμα για να δείτε τις λέξεις που αρχίζουν από αυτό.  Κάντε κλίκ σε μία λέξη για να δείτε τις πιθανότητες να ανήκει σε οποιοδήποτε αρχείο..
SingleBucket_Unique                     %s μοναδικές
SingleBucket_ClearBucket                Διαγραφή όλων των λέξεων

Session_Title                           Η συνεδρία του POPFile έχει λήξει
Session_Error                           Η παρούσα συνεδρία POPFile έχει λήξει.  Αυτό μποεί να είναι αποτέλεσμα της επανεκκίνησης του POPFile ενόσω το πρόγραμμα εμφάνισης ιστοσελίδων σας παρέμεινε ανοικτό.  Παρακαλούμε κάντε κλίκ σε κάποια από τις άνωθι συνδέσεις για να αποκαταστήσετε την επικοινωνία με το POPFile.

View_Title                              Εμφάνιση Μεμονομένου Μυνήματος

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of a message message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the message's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many messages have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the message classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of messages classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in a message.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify message according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the message before it is passed on to the message client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying message due to their relative frequency in message in general.  They are organized per row according to the first letter of the words.

Advanced_AllParameters                  Όλες οι παράμετροι POPFile
Advanced_ConfigFile                     Αρχείο ρυθμίσεων:
Advanced_Parameter                      Παράμετρος
Advanced_Value                          Τιμή
Advanced_Warning                        Αυτή είναι η πλήρης λίστα παραμέτρων POPFile. Μόνο για προχωρημένους χρήστες: μπορείτε να αλλάξετε οποιαδήποτε και να κάνετε κλικ στο Ενημέρωση. Δεν γίνεται έλεγχος εγκυρότητας. Τα στοιχεία με έντονη γραφή έχουν αλλαχτεί από την προεπιλογή. Δείτε <a href="http://getpopfile.org/docs/OptionReference">OptionReference</a> για περισσότερες πληροφορίες.
ApplyChanges                            Εφαρμογή αλλαγών
Arrived                                 Έφτασε
Bucket_InIgnoredWords                   <b>%s</b> βρίσκεται στις αγνοημένες λέξεις. Το POPFile αγνοεί αυτή τη λέξη
BucketSelect_AddNew                     Προσθήκη νέας...
BucketSelect_AlreadyExists              Υπάρχει ήδη
BucketSelect_CreateError                Σφάλμα δημιουργίας κατηγορίας
BucketSelect_InvalidName                Μόνο a-z, 0-9, - και _
BucketSelect_NameRequired               Απαιτείται όνομα
Configuration_Error10                   Η θύρα ακρόασης POP3 δεν μπορεί να έχει την ίδια τιμή με τη θύρα της διεπαφής χρήστη
Configuration_Error8                    Η θύρα διακομιστή SOCKS V πρέπει να είναι αριθμός μεταξύ 1 και 65535
Configuration_Error9                    Η θύρα της διεπαφής χρήστη δεν μπορεί να έχει την ίδια τιμή με τη θύρα ακρόασης POP3
Configuration_Fields                    Στήλες ιστορικού
Configuration_NNTPFork                  Να επιτρέπονται ταυτόχρονες συνδέσεις NNTP
Configuration_POPFork                   Να επιτρέπονται ταυτόχρονες συνδέσεις POP3
Configuration_SMTPFork                  Να επιτρέπονται ταυτόχρονες συνδέσεις SMTP
Configuration_SOCKSPort                 Θύρα διακομιστή SOCKS V
Configuration_SOCKSPortUpdate           Η θύρα SOCKS V ενημερώθηκε σε %s
Configuration_SOCKSServer               Διακομιστής SOCKS V
Configuration_SOCKSServerUpdate         Ο διακομιστής SOCKS V ενημερώθηκε σε %s
Corpus_Actions                          Ενέργειες
Corpus_AddStopword                      Προσθήκη στις λέξεις-στοπ
Corpus_BucketList                       Κατηγορίες
Corpus_Clear                            Καθαρισμός
Corpus_Color                            Χρώμα
Corpus_LoadCandidates                   Εύρεση υποψηφίων
Corpus_NoCandidates                     Δεν βρέθηκαν υποψήφιοι σε αυτό το κατώφλι.
Corpus_RemoveStopword                   Αφαίρεση
Corpus_Search                           Αναζήτηση
Corpus_StopwordCandidates               Υποψήφιες λέξεις-στοπ
Corpus_StopwordCandidatesDesc           Λέξεις που εμφανίζονται ομοιόμορφα σε όλες τις κατηγορίες — χαμηλή διακριτική δύναμη.
Corpus_StopwordRatio                    Κατώφλι αναλογίας μέγιστου/ελάχιστου
Corpus_StopwordsDesc                    Οι λέξεις σε αυτή τη λίστα δεν χρησιμοποιούνται ποτέ για ταξινόμηση.
Corpus_StopwordsTitle                   Λέξεις-στοπ
Date                                    Ημερομηνία
DonateLink                              Donate
FAQ                                     Συχνές ερωτήσεις
FAQLink                                 FAQ
Footer_Wiki                             Τεκμηρίωση
Help_Bucket_Setup                       Το POPFile χρειάζεται τουλάχιστον δύο κατηγορίες εκτός από την ψευδο-κατηγορία "αταξινόμητο". Αυτό που κάνει το POPFile μοναδικό είναι ότι μπορεί να ταξινομεί αλληλογραφία σε περισσότερες κατηγορίες. Μια απλή ρύθμιση θα περιελάμβανε τις κατηγορίες "spam", "personal" και "work".
Help_No_More                            Να μην εμφανιστεί ξανά
Help_Training                           Όταν χρησιμοποιείτε για πρώτη φορά το POPFile, δεν γνωρίζει τίποτα και χρειάζεται εκπαίδευση. Το POPFile χρειάζεται εκπαίδευση σε μηνύματα για κάθε κατηγορία, η εκπαίδευση γίνεται όταν αναταξινομείτε ένα μήνυμα που το POPFile ταξινόμησε λανθασμένα. Πρέπει επίσης να ρυθμίσετε το πρόγραμμα αλληλογραφίας σας να φιλτράρει βάσει της ταξινόμησης POPFile. Πληροφορίες στο <a href="http://getpopfile.org/docs/FAQ:EmailSorting">POPFile Documentation Project</a>.
History_AllBuckets                      Όλες οι κατηγορίες
History_Automatic                       Αυτόματο
History_ChangedClass                    Θα ταξινομηθεί τώρα ως
History_Column_Characters               Αλλαγή πλάτους στηλών Από, Προς, Κοιν. και Θέμα
History_Decrease                        Μείωση
History_HighlightWords                  Επισήμανση λέξεων ανά κατηγορία
History_Increase                        Αύξηση
History_Loading                         Φόρτωση...
History_MoveTo                          — μετακίνηση σε —
History_Moving                          Μετακίνηση...
History_Negate_Search                   Αντιστροφή αναζήτησης/φίλτρου
History_NoMatchingMessages              Δεν βρέθηκαν αντίστοιχα μηνύματα
History_Purge                           Λήξη τώρα
History_Reclassified                    Αναταξινομήθηκε
History_Reclassifying                   Αναταξινόμηση...
History_ReclassifyUnclassified          Αναταξινόμηση αταξινόμητων
History_RemoveChecked                   Αφαίρεση επιλεγμένων
History_Selected                        επιλεγμένο
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB
ID                                      Αναγν.
Imap_Bucket2Folder                      Αλληλογραφία για κατηγορία '<b>%s</b>' μεταφέρεται στο φάκελο
Imap_BucketFolderMappings               Αντιστοιχίσεις κατηγορίας -> φακέλου
Imap_Bytelimit                          Bytes ανά μήνυμα για ταξινόμηση. Εισάγετε 0 για πλήρες μήνυμα:
Imap_BytelimitError                     Παρακαλώ εισάγετε αριθμό.
Imap_Connected                          Συνδεδεμένο
Imap_Connection                         Σύνδεση
Imap_ConnectionFailed                   Αποτυχία σύνδεσης
Imap_Description                        Παρακολούθηση φακέλων IMAP και αυτόματη ταξινόμηση εισερχόμενων μηνυμάτων.
Imap_EnableService                      Ενεργοποίηση υπηρεσίας IMAP
Imap_Expunge                            Οριστική διαγραφή μηνυμάτων από παρακολουθούμενους φακέλους.
Imap_FetchFolders                       Ανάκτηση φακέλων
Imap_Fetching                           Ανάκτηση...
Imap_IMAFFolder                         Φάκελος IMAP
Imap_Interval                           Διάστημα ενημέρωσης σε δευτερόλεπτα:
Imap_IntervalError                      Παρακαλώ εισάγετε διάστημα μεταξύ 10 και 3600 δευτερολέπτων.
Imap_Login                              Όνομα χρήστη IMAP:
Imap_LoginError                         Παρακαλώ εισάγετε όνομα χρήστη!
Imap_MapError                           Δεν μπορείτε να αντιστοιχίσετε περισσότερες από μία κατηγορία σε έναν φάκελο!
Imap_MappingsHint                       Τα ταξινομημένα μηνύματα μεταφέρονται στον καθορισμένο φάκελο IMAP. Αφήστε κενό για παράλειψη μεταφοράς.
Imap_NoConnectionMessage                Παρακαλώ ρυθμίστε πρώτα τις λεπτομέρειες σύνδεσης. Μετά θα εμφανιστούν περισσότερες επιλογές σε αυτή τη σελίδα.
Imap_NoFoldersWatched                   Δεν παρακολουθούνται φάκελοι ακόμα.
Imap_NoMappings                         Δεν ορίστηκαν αντιστοιχίσεις.
Imap_Now                                τώρα!
Imap_Password                           Κωδικός πρόσβασης IMAP:
Imap_PasswordError                      Παρακαλώ εισάγετε κωδικό πρόσβασης!
Imap_Port                               Θύρα διακομιστή IMAP:
Imap_PortError                          Παρακαλώ εισάγετε έγκυρο αριθμό θύρας!
Imap_RefreshFolders                     Ανανέωση λίστας φακέλων
Imap_SaveAnyway                         Αποθήκευση ούτως ή άλλως
Imap_SaveConnection                     Αποθήκευση σύνδεσης
Imap_SaveFolders                        Αποθήκευση φακέλων
Imap_Saving                             Αποθήκευση...
Imap_Server                             Όνομα διακομιστή IMAP:
Imap_ServerNameError                    Παρακαλώ εισάγετε όνομα διακομιστή!
Imap_Service                            Υπηρεσία
Imap_TestConnection                     Δοκιμή σύνδεσης
Imap_Testing                            Δοκιμή...
Imap_TrainingHint                       Η λειτουργία εκπαίδευσης σαρώνει τους υπάρχοντες φακέλους αρχείου και εκπαιδεύει τον ταξινομητή στα περιεχόμενά τους. Η σημαία επαναφέρεται αυτόματα όταν ολοκληρωθεί η εκπαίδευση.
Imap_TrainingMode                       Λειτουργία εκπαίδευσης
Imap_UpdateError1                       Αδυναμία σύνδεσης. Ελέγξτε το όνομα χρήστη και τον κωδικό σας.
Imap_UpdateError2                       Αποτυχία σύνδεσης με τον διακομιστή. Ελέγξτε το όνομα κεντρικού υπολογιστή και τη θύρα και βεβαιωθείτε ότι είστε συνδεδεμένοι στο δίκτυο.
Imap_UpdateError3                       Παρακαλώ ρυθμίστε πρώτα τις λεπτομέρειες σύνδεσης.
Imap_Use_SSL                            Χρήση SSL
Imap_WatchedFolder                      Παρακολουθούμενος φάκελος αρ.
Imap_WatchedFolders                     Παρακολουθούμενοι φάκελοι
Imap_WatchedHint                        Το POPFile παρακολουθεί αυτούς τους φακέλους IMAP για νέα μηνύματα προς ταξινόμηση.
Imap_WatchMore                          φάκελος για προσθήκη στη λίστα παρακολούθησης
Locale_Date                             %a %R | %D %R
Locale_Decimal                          ,
Locale_Thousands                        .
Magnet_Created                          Δημιουργήθηκε μαγνήτης
Magnet_Deleted                          Διαγράφηκε μαγνήτης
MailingListLink                         mailing_lists
NavCorpus                               Σώμα κειμένου
NavHistory                              Ιστορικό
NavIMAP                                 IMAP
NavMagnets                              Μαγνήτες
NavSettings                             Ρυθμίσεις
NavStatus                               Κατάσταση
Reconnect_Connecting                    Σύνδεση...
Reconnect_Message                       Το σύστημα δεν είναι προσβάσιμο. Γίνεται προσπάθεια επανασύνδεσης...
Reconnect_Now                           Επανασύνδεση τώρα
Reconnect_RetryIn                       Επανάληψη σε
Reconnect_Title                         Η σύνδεση χάθηκε
RequestFeatureLink                      RequestFeature
Security_StealthMode                    (Λειτουργία αθέατου)
Settings_AdminPassword                  Κωδικός διαχειριστή
Settings_ArchiveDirectory               Κατάλογος αρχείου
Settings_ArchiveMessages                Αρχειοθέτηση μηνυμάτων
Settings_ArchiveSubdirs                 Υποκατάλογοι αρχείου
Settings_AutoDetect                     Αυτόματη ανίχνευση
Settings_AutoDetectLanguage             Αυτόματη ανίχνευση γλώσσας
Settings_ChainPort                      Θύρα αλυσίδας
Settings_ChainServer                    Διακομιστής αλυσίδας
Settings_DateFormat                     Μορφή ημερομηνίας
Settings_DescAdminPassword              Αφήστε κενό για απενεργοποίηση προστασίας κωδικού.
Settings_DescArchiveDir                 Κατάλογος για αρχειοθετημένα μηνύματα (σχετικά με τον κατάλογο χρήστη).
Settings_DescArchiveMessages            Αποθήκευση αντιγράφου κάθε ταξινομημένου μηνύματος στο δίσκο.
Settings_DescArchiveSubdirs             Διαίρεση αρχείου σε N υποκαταλόγους (0 = απενεργοποιημένο).
Settings_DescAutoDetectLang             Ανίχνευση γλώσσας κάθε μηνύματος και εφαρμογή αντίστοιχων λέξεων-στοπ και ετυμολογητή. Προσθέτει ~130% καθυστέρηση ταξινόμησης· χρήσιμο για γραμματοκιβώτια πολλών γλωσσών.
Settings_DescChainPort                  Θύρα ανάντη διακομιστή SMTP.
Settings_DescChainServer                Όνομα κεντρικού ανάντη διακομιστή SMTP.
Settings_DescDateFormat                 Μορφότυπος strftime. Αφήστε κενό για προεπιλογή locale.
Settings_DescForceFork                  Δημιουργία νέας διεργασίας για κάθε σύνδεση.
Settings_DescHEADFetchesBody            Ανάκτηση πλήρους άρθρου με την εντολή HEAD.
Settings_DescHTTPPort                   Θύρα που ακούει η διεπαφή ιστού. Απαιτείται επανεκκίνηση.
Settings_DescItemsPerPage               Γραμμές ανά σελίδα στο Ιστορικό και τους Μαγνήτες.
Settings_DescLanguage                   Γλώσσα εμφάνισης διεπαφής. Αφήστε κενό για αυτόματη ανίχνευση από τον περιηγητή.
Settings_DescListenAddress              Διεύθυνση IP για δέσμευση. Κενό = όλες οι διεπαφές.
Settings_DescLocalOnly_UI               Περιορισμός της διεπαφής ιστού σε συνδέσεις localhost.
Settings_DescLogDirectory               Κατάλογος αρχείων καταγραφής. Κενό = ρίζα popfile.
Settings_DescLogLevel                   Επίπεδο λεπτομέρειας καταγραφής.
Settings_DescLogSQLToStdout             Εκτύπωση κάθε πρότασης SQL με δεσμευμένες τιμές στο stdout. Ενεργό μόνο όταν είναι ενεργοποιημένη και η "Καταγραφή στο stdout".
Settings_DescLogToStdout                Αντικατοπτρισμός εξόδου καταγραφής στο stdout επιπλέον του αρχείου καταγραφής.
Settings_DescMessageCutoff              Μέγιστος αριθμός λέξεων για ανάλυση ανά μήνυμα (0 = απεριόριστο).
Settings_DescNNTPLocalOnly              Αποδοχή συνδέσεων NNTP μόνο από localhost.
Settings_DescNNTPPort                   Θύρα που ακούει το POPFile για NNTP (προεπιλογή 119).
Settings_DescNNTPSeparator              Χαρακτήρας που διαχωρίζει χρήστη από διακομιστή.
Settings_DescPOP3LocalOnly              Αποδοχή συνδέσεων POP3 μόνο από localhost.
Settings_DescPOP3Port                   Θύρα που ακούει το POPFile για POP3 (προεπιλογή 1110).
Settings_DescPOP3Separator              Χαρακτήρας που διαχωρίζει χρήστη από διακομιστή (π.χ. user:mailhost).
Settings_DescRetentionDays              Πόσες ημέρες να διατηρείται το ιστορικό μηνυμάτων.
Settings_DescSessionDividers            Εμφάνιση διαχωριστών μεταξύ περιόδων περιήγησης στο Ιστορικό.
Settings_DescSMTPLocalOnly              Αποδοχή συνδέσεων SMTP μόνο από localhost.
Settings_DescSMTPPort                   Θύρα που ακούει το POPFile για SMTP (προεπιλογή 25).
Settings_DescSQLiteJournal              Λειτουργία journal/WAL SQLite.
Settings_DescSQLiteTweaks               Bitmask: 1 = ταχύτερες εγγραφές (λιγότερο ασφαλές), 2 = περιοδικό αντίγραφο.
Settings_DescSSLChainPort               Θύρα ανάντη διακομιστή SSL POP3.
Settings_DescSSLChainServer             Όνομα κεντρικού ανάντη διακομιστή SSL POP3 για αλυσίδα SSL.
Settings_DescSubjectTagLeft             Πρόθεμα που εισάγεται στην επικεφαλίδα Θέματος, π.χ. [SPAM].
Settings_DescSubjectTagRight            Επίθεμα που προσαρτάται στην επικεφαλίδα Θέματος.
Settings_DescTagPosition                Πού να τοποθετείται η ετικέτα θέματος.
Settings_DescTOPFetchesBody             Ανάκτηση και του σώματος μηνύματος με την εντολή TOP.
Settings_DescUnclassifiedWeight         Κατώφλι πιθανότητας κάτω από το οποίο το ηλεκτρονικό ταχυδρομείο είναι "αταξινόμητο".
Settings_DescWordStemming               Αναγωγή λέξεων στη ρίζα τους πριν από την ταξινόμηση (π.χ. "running" σε "run"). Βελτιώνει την ανάκληση για μορφολογικά πλούσιες γλώσσες με κόστος ~10% καθυστέρησης.
Settings_DescWordTable                  Τι να εμφανίζεται στον πίνακα πιθανοτήτων λέξεων.
Settings_ErrorSaving                    Σφάλμα αποθήκευσης
Settings_ForceFork                      Αναγκαστική διακλάδωση
Settings_HEADFetchesBody                Το HEAD ανακτά το σώμα
Settings_HTTPPort                       Θύρα HTTP
Settings_ItemsPerPage                   Στοιχεία ανά σελίδα
Settings_ListenAddress                  Διεύθυνση ακρόασης
Settings_ListenPort                     Θύρα ακρόασης
Settings_LocalOnly                      Μόνο τοπικά
Settings_LogDirectory                   Κατάλογος καταγραφής
Settings_LogLevel                       Επίπεδο καταγραφής
Settings_LogSQLToStdout                 Καταγραφή SQL στο stdout
Settings_LogToStdout                    Καταγραφή στο stdout
Settings_MessageCutoff                  Όριο μηνύματος
Settings_OptDebug                       Αποσφαλμάτωση
Settings_OptEnd                         Τέλος
Settings_OptErrorsOnly                  Μόνο σφάλματα
Settings_OptFrequencies                 Συχνότητες
Settings_OptFront                       Μπροστά
Settings_OptHidden                      Κρυφό
Settings_OptInfo                        Πληροφορίες
Settings_OptLogScores                   Καταγραφή βαθμολογιών
Settings_OptProbabilities               Πιθανότητες
Settings_OptWarnings                    Προειδοποιήσεις
Settings_RetentionDays                  Διατήρηση (ημέρες)
Settings_SaveChanges                    Αποθήκευση αλλαγών
Settings_Saved                          Αποθηκεύτηκε
Settings_Saving                         Αποθήκευση...
Settings_Search                         Αναζήτηση ρυθμίσεων...
Settings_SectionClassifier              Ταξινομητής
Settings_SectionHistory                 Ιστορικό
Settings_SectionLogging                 Καταγραφή
Settings_SectionNNTP                    Διακομιστής μεσολάβησης NNTP
Settings_SectionPOP3                    Διακομιστής μεσολάβησης POP3
Settings_SectionSecurity                Ασφάλεια
Settings_SectionSMTP                    Διακομιστής μεσολάβησης SMTP
Settings_SectionUI                      Διεπαφή χρήστη
Settings_ServerSeparator                Διαχωριστής διακομιστή
Settings_SessionDividers                Διαχωριστές περιόδου σύνδεσης
Settings_SQLiteJournalMode              Λειτουργία journal SQLite
Settings_SQLiteTweaks                   Ρυθμίσεις SQLite
Settings_SSLChainPort                   Θύρα αλυσίδας SSL
Settings_SSLChainServer                 Διακομιστής αλυσίδας SSL
Settings_SubjectTagLeft                 Ετικέτα θέματος αριστερά
Settings_SubjectTagRight                Ετικέτα θέματος δεξιά
Settings_TagPosition                    Θέση ετικέτας
Settings_TOPFetchesBody                 Το TOP ανακτά το σώμα
Settings_UnclassifiedWeight             Βάρος αταξινόμητου
Settings_WordStemming                   Ετυμολόγηση λέξεων
Settings_WordTable                      Πίνακας λέξεων
Shutdown_Message                        Το POPFile τερματίστηκε
Size                                    Μέγεθος
Status_Checking                         Έλεγχος...
Status_Description                      Έλεγχοι υγείας υπηρεσιών POPFile.
Status_LoadError                        Αποτυχία φόρτωσης κατάστασης
Status_NoChecks                         Δεν υπάρχουν διαθέσιμοι έλεγχοι.
View_Chart                              Διάγραμμα απόφασης
View_DownloadMessage                    Λήψη μηνύματος
View_MessageBody                        Σώμα μηνύματος
View_MessageHeader                      Επικεφαλίδα μηνύματος
View_ShowFrequencies                    Εμφάνιση συχνοτήτων λέξεων
View_ShowProbabilities                  Εμφάνιση πιθανοτήτων λέξεων
View_ShowScores                         Εμφάνιση βαθμολογιών λέξεων και διαγράμματος απόφασης
View_WordFrequencies                    εμφάνιση συχνοτήτων λέξεων
View_WordMatrix                         Πίνακας λέξεων
View_WordProbabilities                  εμφάνιση πιθανοτήτων λέξεων
View_WordScores                         εμφάνιση βαθμολογιών λέξεων
WikiLink                                index.php
Windows_Console                         Εκτέλεση POPFile σε παράθυρο κονσόλας;
Windows_NextTime                        <p><font color="red">Αυτή η αλλαγή δεν θα τεθεί σε ισχύ μέχρι την επόμενη εκκίνηση του POPFile</font>
Windows_TrayIcon                        Εμφάνιση εικονιδίου POPFile στην περιοχή ειδοποιήσεων των Windows;
