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
LanguageCode                            nl
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en
 
# Common words that are used on their own all over the interface
Apply                                   Doorvoeren
On                                      Aan
Off                                     Uit
TurnOn                                  Zet aan
TurnOff                                 Zet uit
Add                                     Voeg toe
Remove                                  Verwijder
Previous                                Vorige
Next                                    Volgende
From                                    Van
Subject                                 Onderwerp
Classification                          Classificatie
Reclassify                              Herclasseren
Undo                                    Maak ongedaan
Close                                   Sluiten
Find                                    Zoek
Filter                                  Filter
Yes                                     Ja
No                                      Nee
ChangeToYes                             Verander naar Ja
ChangeToNo                              Verander naar Nee
Bucket                                  Bak
Magnet                                  Magneet
Delete                                  Verwijder
Create                                  Maak aan
To                                      Aan
Total                                   Totaal
Rename                                  Hernoemen
Frequency                               Frequentie
Probability                             Waarschijnlijkheid
Score                                   Score
Lookup                                  Bekijk

# The header and footer that appear on every UI page
Header_Title                            POPFile Control Center
Header_Shutdown                         Afsluiten
Header_History                          Geschiedenis
Header_Buckets                          Bakken
Header_Configuration                    Configuratie
Header_Advanced                         Gevorderd
Header_Security                         Veiligheid
Header_Magnets                          Magneten

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Handleiding
Footer_Forums                           Forums
Footer_FeedMe                           Voer mij!
Footer_RequestFeature                   Vraag functionaliteit aan
Footer_MailingList                      Mailing Lijst

Configuration_Error1                    Het scheidingsteken moet een enkel karakter zijn
Configuration_Error2                    De gebruikers interface poort moet een getal zijn tussen 1 en 65535
Configuration_Error3                    De POP3 luisterpoort moet een getal zijn tussen 1 en 65535
Configuration_Error4                    De pagina grootte moet een getal zijn tussen 1 en 1000
Configuration_Error5                    Het aantal dagen in de geschiedenis moet een getal zijn tussen 1 en 366
Configuration_Error6                    De TCP timeout moet een getal zijn tussen 10 en 1800
Configuration_POP3Port                  POP3 luisterpoort
Configuration_POP3Update                Poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Configuration_Separator                 Scheidingsteken
Configuration_SepUpdate                 Scheidingsteken veranderd naar %s
Configuration_UI                        Gebruikers interface web poort
Configuration_UIUpdate                  Gebruikers interface web poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Configuration_History                   Aantal emails per pagina
Configuration_HistoryUpdate             Aantal emails per pagina veranderd naar %s
Configuration_Days                      Aantal dagen geschiedenis om te bewaren
Configuration_DaysUpdate                Aantal dagen geschiedenis om te bewaren veranderd naar %s
Configuration_UserInterface             Gebruikers Interface
Configuration_Skins                     Huiden
Configuration_SkinsChoose               Kies huid
Configuration_Language                  Taal
Configuration_LanguageChoose            Kies Taal
Configuration_ListenPorts               Luister Poorten
Configuration_HistoryView               Geschiedenis View
Configuration_TCPTimeout                TCP Connectie Timeout
Configuration_TCPTimeoutSecs            TCP Connectie Timeout in seconden
Configuration_TCPTimeoutUpdate          TCP Connectie Timeout veranderd naar %s
Configuration_ClassificationInsertion   Classificatie toevoeging
Configuration_SubjectLine               Onderwerp regel verandering
Configuration_XTCInsertion              X-Text-Classification toevoeging
Configuration_XPLInsertion              X-POPFile-Link toevoeging
Configuration_Logging                   Logging
Configuration_None                      Geen
Configuration_ToScreen                  Naar het scherm
Configuration_ToFile                    Naar een bestand
Configuration_ToScreenFile              Naar het scherm en naar een bestand
Configuration_LoggerOutput              Logger uitvoer
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' zit al in de lijst met stopwoorden
Advanced_Error2                         stopwoorden mogen alleen alphanumerieke, ., _, -, of @ karakters bevatten
Advanced_Error3                         '%s' is toegevoegd aan de lijst met stopwoorden
Advanced_Error4                         '%s' zit niet in de lijst met stopwoorden
Advanced_Error5                         '%s' is verwijderd van de lijst met stopwoorden
Advanced_StopWords                      Stopwoorden
Advanced_Message1                       De volgende woorden worden genegeerd bij alle classificaties omdat ze zeer vaak voorkomen.
Advanced_AddWord                        Voeg woord toe
Advanced_RemoveWord                     Verwijder woord

History_Filter                          &nbsp;(alleen uit bak <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(gezocht op onderwerp %s)
History_Title                           Recente Berichten
History_Jump                            Spring naar bericht
History_ShowAll                         Laat alles zien
History_ShouldBe                        Moet zijn
History_NoFrom                          geen van regel
History_NoSubject                       geen onderwerp regel
History_ClassifyAs                      Classificeer als
History_MagnetUsed                      Magneet gebruikt
History_ChangedTo                       Veranderd naar <font color="%s">%s
History_Already                         Is al gereclassificeerd als <font color="%s">%s</font>
History_RemoveAll                       Verwijder alles
History_RemovePage                      Verwijder pagina
History_Remove                          Om berichten te verwijderen in de geschiedenis klik
History_SearchMessage                   Zoek onderwerp
History_NoMessages                      Geen berichten

Password_Title                          Wachtwoord
Password_Enter                          Voer wachtwoord in
Password_Go                             Go!
Password_Error1                         Ongeldig wachtwoord

Security_Error1                         De veilige poort moet een nummer zijn tussen 1 en 65535
Security_Stealth                        Undercover modus/Server operatie
Security_NoStealthMode                  Nee (Undercover modus)
Security_ExplainStats                   (als dit aan staat stuurt POPFile één keer per dag de volgende drie waarden naar een script op getpopfile.org: bc (het aantal bakken dat je hebt), mc (het totaal aantal geclassificeerde berichten door POPFile) en ec (het totaal aantal fouten tijdens classificatie).  Deze waarden worden opgeslagen in een bestand en ik zal deze gegevens gebruiken om statistieken te publiceren over hoe mensen POPFile gebruiken en hoe goed het werkt.  Mijn web server houdt de log bestanden 5 dagen vast waarna ze verwijderd zullen worden; Ik bewaar geen gegevens over het verband tussen de statistieken en individuele IP adressen.)
Security_ExplainUpdate                  (als dit aan staat stuurt POPFile één keer per dag de volgende drie waarden naar een script op getpopfile.org: ma (het grote versie nummer van jouw POPFile installatie), mi (het kleine versie nummer van jouw POPFile installatie) en bn (het bouwnummer van jouw versie van POPFile).  POPFile ontvangt in reactie hierop een plaatje dat bovenaan de pagina afgebeeld wordt als er een nieuwe versie van POPFile beschikbaar is. Mijn web server houdt de log bestanden 5 dagen vast waarna ze verwijderd zullen worden; Ik bewaar geen gegevens over het verband tussen de update checks en individuele IP adressen.)
Security_PasswordTitle                  Gebruikers Interface Wachtwoord
Security_Password                       Wachtwoord
Security_PasswordUpdate                 Wachtwoord veranderd naar %s
Security_AUTHTitle                      Veilig Wachtwoord Authentificatie (AUTH)
Security_SecureServer                   Veilige Server
Security_SecureServerUpdate             Veilige server veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Security_SecurePort                     Veilige poort
Security_SecurePortUpdate               Veilige poort veranderd naar %s; deze verandering krijgt effect zodra je POPFile herstart hebt
Security_POP3                           Accepteer POP3 verbindingen van andere machines 
Security_UI                             Accepteer HTTP (Gebruikers Interface) verbindingen van andere machines 
Security_UpdateTitle                    Automatische Update controle 
Security_Update                         Controleer dagelijks op nieuwe versies van POPFile 
Security_StatsTitle                     Rapporteer statistieken
Security_Stats                          Stuur dagelijks statistieken naar John terug

Magnet_Error1                           Magneet'%s' bestaat al in bak '%s'
Magnet_Error2                           Nieuwe magneet '%s' botst met magneet '%s' in bak '%s' en kan voor verwarrende resultaten leiden.  Nieuwe magneet niet toegevoegd.
Magnet_Error3                           Maak nieuwe magneet '%s' in bak '%s'
Magnet_CurrentMagnets                   Huidige magneten
Magnet_Message1                         De volgende magneten zorgen er altijd voor dat berichten in de gespecificeerde bak vallen.
Magnet_CreateNew                        Maak Nieuwe Magneet
Magnet_Explanation                      Er zijn drie type magneten beschikbaar: <ul><li>Van adres of naam:</b> B.v.: john@company.com om een specifiek adres te specificeren, <br />company.com om iedereen te specificeren die berichten sturen vanaf company.com, <br />John Doe om een bepaalde persoon te specificeren, John om alle Johns te specificeren</li><li><b>Naar adres of naam:</b> Net als een "Van" magneet maar nu voor de geadresseerde</li><li><b>Onderwerp woorden:</b> B.v.: Hallo om alle berichten met Hallo in het onderwerp te specificeren.</li></ul>
Magnet_MagnetType                       Magneet type
Magnet_Value                            Waarde
Magnet_Always                           Gaat altijd naar bak

Bucket_Error1                           Baknamen kunnen alleen a t/m z (geen hoofdletters) en - en _ karakters bevatten
Bucket_Error2                           Baknaam %s bestaat al
Bucket_Error3                           Bak aangemaakt met naam %s
Bucket_Error4                           Voert u a.u.b. een woord in
Bucket_Error5                           Bak %s hernoemd naar %s
Bucket_Error6                           Bak %s verwijderd
Bucket_Title                            Opsomming
Bucket_BucketName                       Baknaam
Bucket_WordCount                        Aantal woorden
Bucket_WordCounts                       Aantal woorden
Bucket_UniqueWords                      Unieke woorden
Bucket_SubjectModification              Onderwerp aanpassing
Bucket_ChangeColor                      Verander kleur
Bucket_NotEnoughData                    Niet genoeg gegevens
Bucket_ClassificationAccuracy           Classificatie precisie
Bucket_EmailsClassified                 Berichten geclassificeerd
Bucket_EmailsClassifiedUpper            Berichten Geclassificeerd
Bucket_ClassificationErrors             Classificatiefouten
Bucket_Accuracy                         Precisie
Bucket_ClassificationCount              Aantal Classificaties
Bucket_ResetStatistics                  Herstart statistieken
Bucket_LastReset                        Laatste Herstart
Bucket_CurrentColor                     %s huidige kleur is %s
Bucket_SetColorTo                       Zet %s kleur op %s
Bucket_Maintenance                      Onderhoud
Bucket_CreateBucket                     Maak bak aan met naam
Bucket_DeleteBucket                     Verwijder bak met naam 
Bucket_RenameBucket                     Hernoem bak met naam
Bucket_Lookup                           Bekijk
Bucket_LookupMessage                    Bekijk woord in bak
Bucket_LookupMessage2                   Resultaat voor 
Bucket_LookupMostLikely                 <b>%s</b> komt het meest waarschijnlijk voor in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> komt niet voor in een van de bakken
Bucket_DisabledGlobally                 Globaal uitgeschakeld
Bucket_To                               naar

SingleBucket_Title                      Details voor %s
SingleBucket_WordCount                  Aantal woorden in bak
SingleBucket_TotalWordCount             Totaal aantal woorden
SingleBucket_Percentage                 Percentage van totaal
SingleBucket_WordTable                  Woordentabel voor %s
SingleBucket_Message1                   Woorden met een sterretje (*) zijn gebruikt voor classificatie in deze POPFile sessie.  Klik op een woord om de waarschijnlijkheid te zien voor alle bakken.
SingleBucket_Unique                     %s uniek

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of an email message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the email's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of PopFile.  The first is how accurate its classification is, the second is how many emails have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the email classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of emails classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in an email.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify email according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of PopFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the email before it is passed on to the email client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of PopFile, whether it should automatically check for updates to the program, and whether statistics about PopFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that PopFile ignores when classifying email due to their relative frequency in email in general.  They are organized per row according to the first letter of the words.


# New keys added (translations batch 2)
LanguageCharset ISO-8859-1
LanguageDirection ltr
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Corpus
NavHistory Geschiedenis
NavIMAP IMAP
NavMagnets Magneten
NavSettings Instellingen
NavStatus Status
Corpus_BucketList Categorieën
Corpus_Color Kleur
Corpus_Actions Acties
Corpus_Clear Wissen
Corpus_Search Zoeken
Corpus_StopwordsTitle Stopwoorden
Corpus_StopwordsDesc Woorden in deze lijst worden nooit gebruikt voor classificatie.
Corpus_RemoveStopword Verwijderen
Corpus_StopwordCandidates Stopwoordkandidaten
Corpus_StopwordCandidatesDesc Woorden die gelijkmatig voorkomen in alle categorieën — weinig onderscheidend vermogen.
Corpus_StopwordRatio Max/min-verhoudrempelwaarde
Corpus_LoadCandidates Kandidaten zoeken
Corpus_NoCandidates Geen kandidaten gevonden bij deze drempelwaarde.
Corpus_AddStopword Toevoegen aan stopwoorden
BucketSelect_AddNew Nieuwe toevoegen...
BucketSelect_AlreadyExists Bestaat al
BucketSelect_CreateError Fout bij aanmaken categorie
BucketSelect_InvalidName Alleen a-z, 0-9, - en _
BucketSelect_NameRequired Naam verplicht
Bucket_InIgnoredWords <b>%s</b> staat in genegeerde woorden. POPFile negeert dit woord
Bucket_ClassificationFN Fout-negatieven
Bucket_ClassificationFP Fout-positieven
Bucket_Quarantine Quarantaine<br>Bericht
ApplyChanges Wijzigingen toepassen
Arrived Ontvangen
Cc Cc
Count Aantal
Date Datum
FAQ FAQ
Footer_Wiki Documentatie
ID ID
Probability Kans
QuickMagnets SnelMagneten
Refresh Vernieuwen
Scores Scores
Shutdown_Message POPFile is afgesloten
Size Grootte
Update Bijwerken
Word Woord
Configuration_CurrentLogFile &lt;Huidig logbestand bekijken&gt;
Configuration_Error7 De XML RPC luisterpoort moet een getal zijn tussen 1 en 65535
Configuration_Error8 De SOCKS V proxy-poort moet een getal zijn tussen 1 en 65535
Configuration_Error9 De gebruikersinterfacepoort mag niet dezelfde waarde hebben als de POP3 luisterpoort
Configuration_Error10 De POP3 luisterpoort mag niet dezelfde waarde hebben als de gebruikersinterfacepoort
Configuration_Fields Geschiedeniskolommen
Configuration_NNTPFork Gelijktijdige NNTP-verbindingen toestaan
Configuration_NNTPPort NNTP luisterpoort
Configuration_NNTPSeparator Scheidingsteken NNTP host:poort:gebruiker
Configuration_NNTPSepUpdate NNTP-scheidingsteken bijgewerkt naar %s
Configuration_NNTPUpdate NNTP-poort bijgewerkt naar %s; wijziging wordt van kracht na herstart van POPFile
Configuration_POP3Separator Scheidingsteken POP3 host:poort:gebruiker
Configuration_POP3SepUpdate POP3-scheidingsteken bijgewerkt naar %s
Configuration_POPFork Gelijktijdige POP3-verbindingen toestaan
Configuration_SMTPFork Gelijktijdige SMTP-verbindingen toestaan
Configuration_SMTPPort SMTP luisterpoort
Configuration_SMTPUpdate SMTP-poort bijgewerkt naar %s; wijziging wordt van kracht na herstart van POPFile
Configuration_SOCKSPort SOCKS V proxy-poort
Configuration_SOCKSPortUpdate SOCKS V proxy-poort bijgewerkt naar %s
Configuration_SOCKSServer SOCKS V proxy-host
Configuration_SOCKSServerUpdate SOCKS V proxy-host bijgewerkt naar %s
Configuration_XMLRPCPort XML-RPC luisterpoort
Configuration_XMLRPCUpdate XML-RPC-poort bijgewerkt naar %s; wijziging wordt van kracht na herstart van POPFile
Help_Bucket_Setup POPFile vereist minimaal twee categorieën naast de pseudo-categorie "niet-geclassificeerd". Wat POPFile uniek maakt is dat het e-mail in meer categorieën kan indelen; u kunt elk gewenst aantal categorieën hebben. Een eenvoudige instelling zou een categorie "spam", "persoonlijk" en "werk" zijn.
Help_No_More Dit niet meer tonen
Help_Training Wanneer u POPFile voor het eerst gebruikt, weet het niets en heeft het training nodig. POPFile heeft training met berichten voor elke categorie nodig; training vindt plaats wanneer u een bericht dat POPFile verkeerd heeft geclassificeerd opnieuw classificeert naar de juiste categorie. Voordat POPFile het eerste bericht classificeert, moet u berichten in minimaal twee categorieën hebben herclassificeerd.
History_AllBuckets Alle categorieën
History_Automatic Automatisch
History_ChangedClass Zou nu classificeren als
History_Column_Characters Breedte van Van, Aan, Cc en Onderwerpkolommen wijzigen
History_Decrease Verkleinen
History_HighlightWords Woorden markeren per categorie
History_Increase Vergroten
History_Loading Laden...
History_Magnet &nbsp;(alleen berichten geclassificeerd door magneet)
History_MagnetBecause <b>Magneet gebruikt</b><p>Geclassificeerd naar <font color="%s">%s</font> vanwege magneet %s </p>
History_MoveTo — verplaatsen naar —
History_Moving Verplaatsen...
History_Negate_Search Zoekopdracht/filter omkeren
History_NoMagnet &nbsp;(alleen berichten niet geclassificeerd door magneet)
History_NoMatchingMessages Geen overeenkomende berichten
History_Purge Nu verlopen
History_Reclassified Herclassificeerd
History_Reclassifying Herclassificeren...
History_ReclassifyUnclassified Niet-geclassificeerde herclassificeren
History_RemoveChecked Geselecteerde verwijderen
History_ResetSearch Wissen
History_Selected geselecteerd
History_ShowMagnet gemagnetiseerd
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
Imap_Bucket2Folder Post voor categorie '<b>%s</b>' gaat naar map
Imap_BucketFolderMappings Categorie -> Maptoewijzingen
Imap_Bytelimit Bytes per bericht voor classificatie. Voer 0 in voor het volledige bericht:
Imap_BytelimitError Voer een getal in.
Imap_Connected Verbonden
Imap_Connection Verbinding
Imap_ConnectionFailed Verbinding mislukt
Imap_Description IMAP-mappen bewaken en inkomende berichten automatisch classificeren.
Imap_EnableService IMAP-service inschakelen
Imap_Expunge Verwijderde berichten uit bewaakte mappen verwijderen.
Imap_FetchFolders Mappen ophalen
Imap_Fetching Ophalen...
Imap_IMAFFolder IMAP-map
Imap_Interval Bijwerkinterval in seconden:
Imap_IntervalError Voer een interval in tussen 10 en 3600 seconden.
Imap_Login IMAP-accountnaam:
Imap_LoginError Voer een gebruikers-/aanmeldingsnaam in!
Imap_MapError U kunt niet meer dan één categorie aan een enkele map koppelen!
Imap_MappingsHint Geclassificeerde berichten worden verplaatst naar de opgegeven IMAP-map. Laat niet-gekoppelde categorieën leeg om verplaatsen over te slaan.
Imap_NoConnectionMessage Configureer eerst de verbindingsdetails. Daarna zijn meer opties beschikbaar op deze pagina.
Imap_NoFoldersWatched Nog geen mappen bewaakt.
Imap_NoMappings Geen toewijzingen gedefinieerd.
Imap_Now nu!
Imap_Password Wachtwoord voor IMAP-account:
Imap_PasswordError Voer een wachtwoord in voor de server!
Imap_Port IMAP-serverpoort:
Imap_PortError Voer een geldig poortnummer in!
Imap_RefreshFolders Mappenlijst vernieuwen
Imap_SaveAnyway Toch opslaan
Imap_SaveConnection Verbinding opslaan
Imap_SaveFolders Mappen opslaan
Imap_Saving Opslaan...
Imap_Server IMAP-servernaam:
Imap_ServerNameError Voer de hostnaam van de server in!
Imap_Service Service
Imap_TestConnection Verbinding testen
Imap_Testing Testen...
Imap_TrainingHint De trainingsmodus doorzoekt bestaande archiefmappen en traint de classificator op hun inhoud. De vlag wordt automatisch gereset wanneer de training is voltooid.
Imap_TrainingMode Trainingsmodus
Imap_UpdateError1 Aanmelden mislukt. Controleer uw gebruikersnaam en wachtwoord.
Imap_UpdateError2 Verbinding met server mislukt. Controleer de hostnaam en poort en zorg dat u online bent.
Imap_UpdateError3 Configureer eerst de verbindingsdetails.
Imap_Use_SSL SSL gebruiken
Imap_WatchedFolder Bewaakte map nr.
Imap_WatchedFolders Bewaakte mappen
Imap_WatchedHint POPFile bewaakt deze IMAP-mappen op nieuwe berichten om te classificeren.
Imap_WatchMore een map toevoegen aan de lijst met bewaakte mappen
Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magneet aangemaakt
Magnet_Deleted Magneet verwijderd
Magnet_Jump Naar magneetpagina
Reconnect_Connecting Verbinden...
Reconnect_Message Het backend is niet bereikbaar. Verbinding wordt hersteld...
Reconnect_Now Nu verbinden
Reconnect_RetryIn Opnieuw proberen over
Reconnect_Title Verbinding verbroken
Security_NNTP NNTP-verbindingen van externe machines accepteren (vereist herstart van POPFile)
Security_SMTP SMTP-verbindingen van externe machines accepteren (vereist herstart van POPFile)
Security_SMTPPort SMTP-ketenpoort
Security_SMTPPortUpdate SMTP-ketenpoort bijgewerkt naar %s; wijziging wordt van kracht na herstart van POPFile
Security_SMTPServer SMTP-ketenserver
Security_SMTPServerUpdate SMTP-ketenserver bijgewerkt naar %s; wijziging wordt van kracht na herstart van POPFile
Security_StealthMode (Stealthmodus)
Security_XMLRPC XML-RPC-verbindingen van externe machines accepteren (vereist herstart van POPFile)
Session_Error Uw POPFile-sessie is verlopen. Dit kan zijn veroorzaakt door het starten en stoppen van POPFile terwijl uw webbrowser open bleef. Klik op een van de bovenstaande koppelingen om door te gaan met POPFile.
Session_Title POPFile-sessie verlopen
Settings_AdminPassword Beheerderswachtwoord
Settings_ArchiveDirectory Archiefmap
Settings_ArchiveMessages Berichten archiveren
Settings_ArchiveSubdirs Archiefsubmappen
Settings_AutoDetect Automatisch detecteren
Settings_AutoDetectLanguage Taal automatisch detecteren
Settings_ChainPort Ketenpoort
Settings_ChainServer Ketenserver
Settings_DateFormat Datumnotatie
Settings_DescAdminPassword Laat leeg om wachtwoordbeveiliging uit te schakelen.
Settings_DescArchiveDir Map voor gearchiveerde berichten (relatief aan gebruikersmap).
Settings_DescArchiveMessages Een kopie van elk geclassificeerd bericht opslaan op schijf.
Settings_DescArchiveSubdirs Archief verdelen in N submappen (0 = uitgeschakeld).
Settings_DescAutoDetectLang Detecteert de taal van elk bericht en past bijbehorende stopwoorden en stemmer toe. Voegt ~130% classificatievertraging toe; nuttig voor meertalige postvakken.
Settings_DescChainPort Poort van de stroomopwaartse SMTP-server.
Settings_DescChainServer Hostnaam van de stroomopwaartse SMTP-server.
Settings_DescDateFormat strftime-notatietekenreeks. Leeg laten voor standaard locale.
Settings_DescForceFork Voor elke verbinding een nieuw proces aanmaken.
Settings_DescHEADFetchesBody Volledig artikel ophalen met het HEAD-commando.
Settings_DescHTTPPort Poort waarop de webinterface luistert. Vereist herstart.
Settings_DescItemsPerPage Rijen weergegeven per pagina in Geschiedenis en Magneten.
Settings_DescLanguage Weergavetaal van de interface. Leeg laten voor automatische detectie vanuit de browser.
Settings_DescListenAddress IP-adres om aan te binden. Leeg = alle interfaces.
Settings_DescLocalOnly_UI Webinterface beperken tot lokale verbindingen.
Settings_DescLogDirectory Map voor logbestanden. Leeg = POPFile-root.
Settings_DescLogLevel Uitgebreidheid van loguitvoer.
Settings_DescLogSQLToStdout Elke SQL-instructie met gebonden waarden naar stdout afdrukken. Alleen actief wanneer "Loggen naar stdout" ook is ingeschakeld.
Settings_DescLogToStdout Loguitvoer ook naar stdout spiegelen naast het logbestand.
Settings_DescMessageCutoff Maximaal aantal geanalyseerde woorden per bericht (0 = onbeperkt).
Settings_DescNNTPLocalOnly Alleen NNTP-verbindingen van localhost accepteren.
Settings_DescNNTPPort Poort waarop POPFile luistert voor NNTP (standaard 119).
Settings_DescNNTPSeparator Scheidingsteken tussen gebruiker en server.
Settings_DescPOP3LocalOnly Alleen POP3-verbindingen van localhost accepteren.
Settings_DescPOP3Port Poort waarop POPFile luistert voor POP3 (standaard 1110).
Settings_DescPOP3Separator Teken dat gebruiker van server scheidt (bijv. gebruiker:mailhost).
Settings_DescRetentionDays Hoeveel dagen berichtgeschiedenis bewaren.
Settings_DescSessionDividers Scheidingslijnen weergeven tussen browsersessies in Geschiedenis.
Settings_DescSMTPLocalOnly Alleen SMTP-verbindingen van localhost accepteren.
Settings_DescSMTPPort Poort waarop POPFile luistert voor SMTP (standaard 25).
Settings_DescSQLiteJournal SQLite-journaalmodus / WAL.
Settings_DescSQLiteTweaks Bitmasker: 1 = snellere schrijfacties (minder veilig), 2 = periodieke back-up.
Settings_DescSSLChainPort Poort van de stroomopwaartse SSL POP3-server.
Settings_DescSSLChainServer Hostnaam van de stroomopwaartse SSL POP3-server voor SSL-ketening.
Settings_DescSubjectTagLeft Prefix ingevoegd in de onderwerpheader, bijv. [SPAM].
Settings_DescSubjectTagRight Suffix toegevoegd aan de onderwerpheader.
Settings_DescTagPosition Waar het onderwerplabel te plaatsen.
Settings_DescTOPFetchesBody Berichtinhoud ook ophalen met het TOP-commando.
Settings_DescUnclassifiedWeight Kansdrempel waaronder e-mail "niet-geclassificeerd" is.
Settings_DescWordStemming Woorden reduceren tot hun stam vóór classificatie (bijv. "lopen" naar "loop"). Verbetert recall voor morfologisch rijke talen bij ~10% latentiekosten.
Settings_DescWordTable Wat weergeven in de woordkanssentabel.
Settings_ErrorSaving Fout bij opslaan
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD haalt inhoud op
Settings_HTTPPort HTTP-poort
Settings_ItemsPerPage Items per pagina
Settings_ListenAddress Luisteradres
Settings_ListenPort Luisterpoort
Settings_LocalOnly Alleen lokaal
Settings_LogDirectory Logmap
Settings_LogLevel Logniveau
Settings_LogSQLToStdout SQL naar stdout loggen
Settings_LogToStdout Naar stdout loggen
Settings_MessageCutoff Berichtlimiet
Settings_OptDebug Debug
Settings_OptEnd Einde
Settings_OptErrorsOnly Alleen fouten
Settings_OptFrequencies Frequenties
Settings_OptFront Voorkant
Settings_OptHidden Verborgen
Settings_OptInfo Info
Settings_OptLogScores Scores loggen
Settings_OptProbabilities Kansen
Settings_OptWarnings Waarschuwingen
Settings_RetentionDays Bewaring (dagen)
Settings_SaveChanges Wijzigingen opslaan
Settings_Saved Opgeslagen
Settings_Saving Opslaan...
Settings_Search Instellingen zoeken...
Settings_SectionClassifier Classificator
Settings_SectionHistory Geschiedenis
Settings_SectionLogging Logboekregistratie
Settings_SectionNNTP NNTP-proxy
Settings_SectionPOP3 POP3-proxy
Settings_SectionSecurity Beveiliging
Settings_SectionSMTP SMTP-proxy
Settings_SectionUI Gebruikersinterface
Settings_ServerSeparator Serverscheidingsteken
Settings_SessionDividers Sessiescheidingen
Settings_SQLiteJournalMode SQLite-journaalmodus
Settings_SQLiteTweaks SQLite-optimalisaties
Settings_SSLChainPort SSL-ketenpoort
Settings_SSLChainServer SSL-ketenserver
Settings_SubjectTagLeft Onderwerplabel links
Settings_SubjectTagRight Onderwerplabel rechts
Settings_TagPosition Labelpositie
Settings_TOPFetchesBody TOP haalt inhoud op
Settings_UnclassifiedWeight Gewicht niet-geclassificeerd
Settings_WordStemming Woordstamming
Settings_WordTable Woordentabel
SingleBucket_ClearBucket Alle woorden verwijderen
Status_Checking Controleren...
Status_Description Statuscontroles voor POPFile-services.
Status_LoadError Status laden mislukt
Status_NoChecks Geen controles beschikbaar.
View_Chart Beslissingsdiagram
View_DownloadMessage Bericht downloaden
View_MessageBody Berichtinhoud
View_MessageHeader Berichtkoptekst
View_ShowFrequencies Woordfrequenties weergeven
View_ShowProbabilities Woordkansen weergeven
View_ShowScores Woordscores en beslissingsdiagram weergeven
View_Title Enkelbericht weergeven
View_WordFrequencies woordfrequenties weergeven
View_WordMatrix Woordmatrix
View_WordProbabilities woordkansen weergeven
View_WordScores woordscores weergeven
Windows_Console POPFile uitvoeren in een consolevenster?
Windows_NextTime <p><font color="red">Deze wijziging wordt pas van kracht de volgende keer dat u POPFile start</font>
Windows_TrayIcon POPFile-pictogram weergeven in het Windows-systeemvak?

Advanced_AllParameters Alle POPFile-parameters
Advanced_ConfigFile Configuratiebestand:
Advanced_Parameter Parameter
Advanced_Value Waarde
Advanced_Warning Dit is de volledige lijst van POPFile-parameters. Alleen voor gevorderde gebruikers: u kunt elk item wijzigen en op Bijwerken klikken; er is geen geldigheidscontrole. Vetgedrukte items zijn gewijzigd ten opzichte van de standaardinstelling.
