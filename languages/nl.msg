# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en
 
# Common words that are used on their own all over the interface
Apply                                   Doorvoeren
Add                                     Voeg toe
Remove                                  Verwijder
Previous                                Vorige
Next                                    Volgende
From                                    Van
Subject                                 Onderwerp
Reclassify                              Herclasseren
Undo                                    Maak ongedaan
Close                                   Sluiten
Bucket                                  Bak
Magnet                                  Magneet
Delete                                  Verwijder
Create                                  Maak aan
Total                                   Totaal
Rename                                  Hernoemen

# The header and footer that appear on every UI page


Configuration_Separator                 Scheidingsteken
Configuration_SepUpdate                 Scheidingsteken veranderd naar %s
Configuration_Language                  Taal


History_SearchMessage                   Zoek onderwerp



Magnet_CurrentMagnets                   Huidige magneten
Magnet_CreateNew                        Maak Nieuwe Magneet

Bucket_CreateBucket                     Maak bak aan met naam
Bucket_RenameBucket                     Hernoem bak met naam




# New keys added (translations batch 2)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Corpus
NavHistory Geschiedenis
NavIMAP IMAP
NavMagnets Magneten
NavStatus Status
NavWordView Woorden
Corpus_BucketList Categorieën
Corpus_Color Kleur
Corpus_Actions Acties
Corpus_Clear Wissen
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
Date Datum
Refresh Vernieuwen
Update Bijwerken
History_AllBuckets Alle categorieën
History_HighlightWords Woorden markeren per categorie
History_Loading Laden...
History_MoveTo — verplaatsen naar —
History_Moving Verplaatsen...
History_Reclassifying Herclassificeren...
History_ReclassifyUnclassified Niet-geclassificeerde herclassificeren
History_Selected geselecteerd
Imap_BucketFolderMappings Categorie -> Maptoewijzingen
Imap_Connected Verbonden
Imap_Connection Verbinding
Imap_ConnectionFailed Verbinding mislukt
Imap_Description IMAP-mappen bewaken en inkomende berichten automatisch classificeren.
Imap_Expunge Verwijderde berichten uit bewaakte mappen verwijderen.
Imap_FetchFolders Mappen ophalen
Imap_Fetching Ophalen...
Imap_IMAFFolder IMAP-map
Imap_Interval Bijwerkinterval in seconden:
Imap_Login IMAP-accountnaam:
Imap_MappingsHint Geclassificeerde berichten worden verplaatst naar de opgegeven IMAP-map. Laat niet-gekoppelde categorieën leeg om verplaatsen over te slaan.
Imap_NoConnectionMessage Configureer eerst de verbindingsdetails. Daarna zijn meer opties beschikbaar op deze pagina.
Imap_NoFoldersWatched Nog geen mappen bewaakt.
Imap_NoMappings Geen toewijzingen gedefinieerd.
Imap_Password Wachtwoord voor IMAP-account:
Imap_Port IMAP-serverpoort:
Imap_SaveAnyway Toch opslaan
Imap_SaveConnection Verbinding opslaan
Imap_SaveFolders Mappen opslaan
Imap_Saving Opslaan...
Imap_Server IMAP-servernaam:
Imap_TestConnection Verbinding testen
Imap_Testing Testen...
Imap_TrainingHint De trainingsmodus doorzoekt bestaande archiefmappen en traint de classificator op hun inhoud. De vlag wordt automatisch gereset wanneer de training is voltooid.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Trainingsmodus
Imap_TrainingLimit Berichten per map (0 = onbeperkt)
Imap_Use_SSL SSL gebruiken
Imap_WatchedFolders Bewaakte mappen
Imap_WatchedHint POPFile bewaakt deze IMAP-mappen op nieuwe berichten om te classificeren.

WordView_Title Woordnauwkeurigheid
WordView_SelectBucket selecteer categorie
WordView_Words woorden
WordView_Loading Laden...
WordView_Empty Geen woorden in deze categorie.
WordView_ColWord Woord
WordView_ColCount Aantal
WordView_ColTotal Totaal
WordView_ColAccuracy Nauwkeurigheid
WordView_ColActions Acties
WordView_Remove Verwijderen
WordView_MoveTo verplaatsen naar
WordView_Move Verplaatsen
Magnet_Created Magneet aangemaakt
Magnet_Deleted Magneet verwijderd
Reconnect_Connecting Verbinden...
Reconnect_Message Het backend is niet bereikbaar. Verbinding wordt hersteld...
Reconnect_Now Nu verbinden
Reconnect_RetryIn Opnieuw proberen over
Reconnect_Title Verbinding verbroken
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
Status_Checking Controleren...
Status_Description Statuscontroles voor POPFile-services.
Status_LoadError Status laden mislukt
Status_NoChecks Geen controles beschikbaar.


Language_Name                           Nederlands
History_PerPage                          Items per pagina
Imap_Advanced                            Geavanceerd
Imap_Cancel                              Annuleren
Imap_Wizard                              Installatiewizard
Imap_WizardApply                         Aanmaken en koppelen
Imap_WizardClose                         Sluiten
Imap_WizardDesc                          Selecteer mappen om buckets en koppelingen voor aan te maken.
Imap_WizardDeselectAll                   Alles deselecteren
Imap_WizardDone                          {count} bucket(s) aangemaakt en gekoppeld.
Imap_WizardEmpty                         Geen extra mappen gevonden op de server.
Imap_WizardSelectAll                     Alles selecteren
Imap_WizardTrain                         Nu trainen
NavWordSearch                            Woorden zoeken
Settings_DescEnableProxy                 Start deze proxy wanneer POPFile opstart.
Settings_DescLogFormat                   Formaat van loguitvoer (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Browser automatisch openen bij opstarten.
Settings_DescSQLiteBackup                Automatisch back-up maken van database voor schema-wijzigingen.
Settings_DescSQLiteFastWrites            Database synchronisatie uitschakelen (sneller, minder veilig).
Settings_EnableService                   Service inschakelen
Settings_LogFormat                       Logformaat
Settings_OpenBrowser                     Browser openen
Settings_SQLiteBackup                    SQLite back-up
Settings_SQLiteFastWrites                SQLite snel schrijven
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Stopwoord toevoegen
WordSearch_ColumnBuckets                 Buckets
WordSearch_ColumnWord                    Woord
WordSearch_IsStopword                    Stopwoord
WordSearch_Loading                       Laden...
WordSearch_NoResults                     Geen resultaten.
WordSearch_NoStopwords                   Geen stopwoorden.
WordSearch_Placeholder                   Voer een woord in...
WordSearch_RemoveStopword                Stopwoord verwijderen
WordSearch_Search                        Zoeken
WordSearch_StopwordList                  Stopwoordenlijst
WordSearch_Title                         Woorden zoeken
WordSearch_Total                         Totaal
