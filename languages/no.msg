# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          no

# Common words that are used on their own all over the interface
Apply                                   Bruk
Add                                     Legg til
Remove                                  Fjern
Previous                                Forrige
Next                                    Neste
From                                    Fra
Subject                                 Emne
Reclassify                              Re-klassifisering
Undo                                    Angre
Close                                   Lukk
Bucket                                  Bøtte
Magnet                                  Magnet
Delete                                  Slett
Create                                  Opprett
Total                                   Total
Rename                                  Omdøp

# The header and footer that appear on every UI page


Configuration_Separator                 Skilletegn
Configuration_SepUpdate                 Oppdaterte skilletegnet til %s
Configuration_Language                  Språk


History_SearchMessage                   Søk Emne



Magnet_CurrentMagnets                   Nåværende Magneter
Magnet_CreateNew                        Opprett Ny Magnet

Bucket_CreateBucket                     Oppret bøtten med navnet
Bucket_RenameBucket                     Omdøp bøtten med navnet




# New keys added (translations batch 2)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Korpus
NavHistory Historikk
NavIMAP IMAP
NavMagnets Magneter
NavStatus Status
NavWordView Ord
Corpus_BucketList Kategorier
Corpus_Color Farge
Corpus_Actions Handlinger
Corpus_Clear Tøm
Corpus_StopwordsTitle Stoppord
Corpus_StopwordsDesc Ord på denne listen brukes aldri til klassifisering.
Corpus_RemoveStopword Fjern
Corpus_StopwordCandidates Stoppordkandidater
Corpus_StopwordCandidatesDesc Ord som forekommer jevnt i alle kategorier — liten diskriminerende kraft.
Corpus_StopwordRatio Maks/min-forholdterskel
Corpus_LoadCandidates Finn kandidater
Corpus_NoCandidates Ingen kandidater funnet ved denne terskelen.
Corpus_AddStopword Legg til stoppord
BucketSelect_AddNew Legg til ny...
BucketSelect_AlreadyExists Eksisterer allerede
BucketSelect_CreateError Feil ved oppretting av kategori
BucketSelect_InvalidName Bare a-z, 0-9, - og _
BucketSelect_NameRequired Navn påkrevd
Date Dato
Refresh Oppdater
Update Oppdater
History_AllBuckets Alle kategorier
History_HighlightWords Fremhev ord etter kategori
History_Loading Laster...
History_MoveTo — flytt til —
History_Moving Flytter...
History_Reclassifying Omklassifiserer...
History_ReclassifyUnclassified Omklassifiser uklassifiserte
History_Selected valgt(e)
Imap_BucketFolderMappings Kategori -> Mappatilordninger
Imap_Connected Tilkoblet
Imap_Connection Tilkobling
Imap_ConnectionFailed Tilkobling mislyktes
Imap_Description Overvåk IMAP-mapper og klassifiser automatisk innkommende meldinger.
Imap_Expunge Slett slettede meldinger fra overvåkede mapper.
Imap_FetchFolders Hent mapper
Imap_Fetching Henter...
Imap_IMAFFolder IMAP-mappe
Imap_Interval Oppdateringsintervall i sekunder:
Imap_Login IMAP-konto innlogging:
Imap_MappingsHint Klassifiserte meldinger flyttes til den angitte IMAP-mappen. La ikke-tilordnede kategorier være tomme for å hoppe over flytting.
Imap_NoConnectionMessage Konfigurer tilkoblingsdetaljene først. Etter det vil det være flere alternativer tilgjengelig på denne siden.
Imap_NoFoldersWatched Ingen mapper overvåkes ennå.
Imap_NoMappings Ingen tilordninger definert.
Imap_Password Passord for IMAP-konto:
Imap_Port IMAP-serverport:
Imap_SaveAnyway Lagre likevel
Imap_SaveConnection Lagre tilkobling
Imap_SaveFolders Lagre mapper
Imap_Saving Lagrer...
Imap_Server IMAP-server vertsnavn:
Imap_TestConnection Test tilkobling
Imap_Testing Tester...
Imap_TrainingHint Opplæringsmodus gjennomgår eksisterende arkivmapper og trener klassifikatoren på innholdet. Flagget tilbakestilles automatisk når opplæringen er fullført.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Opplæringsmodus
Imap_TrainingLimit Meldinger per mappe (0 = ubegrenset)
Imap_Use_SSL Bruk SSL
Imap_WatchedFolders Overvåkede mapper
Imap_WatchedHint POPFile overvåker disse IMAP-mappene for nye meldinger å klassifisere.

WordView_Title Ordnøyaktighet
WordView_SelectBucket velg kategori
WordView_Words ord
WordView_Loading Laster...
WordView_Empty Ingen ord i denne kategorien.
WordView_ColWord Ord
WordView_ColCount Antall
WordView_ColTotal Total
WordView_ColAccuracy Nøyaktighet
WordView_ColActions Handlinger
WordView_Remove Fjern
WordView_MoveTo flytt til
WordView_Move Flytt
Magnet_Created Magnet opprettet
Magnet_Deleted Magnet slettet
Reconnect_Connecting Kobler til...
Reconnect_Message Backend er ikke tilgjengelig. Forsøker å koble til igjen...
Reconnect_Now Koble til nå
Reconnect_RetryIn Prøver igjen om
Reconnect_Title Tilkobling mistet
Settings_AdminPassword Administratorpassord
Settings_ArchiveDirectory Arkivmappe
Settings_ArchiveMessages Arkiver meldinger
Settings_ArchiveSubdirs Arkiv-undermapper
Settings_AutoDetect Automatisk oppdagelse
Settings_AutoDetectLanguage Oppdag språk automatisk
Settings_ChainPort Kjedeport
Settings_ChainServer Kjedeserver
Settings_DateFormat Datoformat
Settings_DescAdminPassword La stå tomt for å deaktivere passordbeskyttelse.
Settings_DescArchiveDir Mappe for arkiverte meldinger (relativt til brukermappe).
Settings_DescArchiveMessages Lagre en kopi av hver klassifisert melding på disk.
Settings_DescArchiveSubdirs Del arkiv i N undermapper (0 = deaktivert).
Settings_DescAutoDetectLang Oppdager språket i hver melding og bruker tilsvarende stoppord og stemmer. Legger til ~130% klassifiseringsforsinkelse; nyttig for flerspråklige postkasser.
Settings_DescChainPort Port for den overordnede SMTP-serveren.
Settings_DescChainServer Vertsnavn for den overordnede SMTP-serveren.
Settings_DescDateFormat strftime-formatstreng. La stå tomt for locale-standard.
Settings_DescForceFork Opprett en ny prosess for hver forbindelse.
Settings_DescHEADFetchesBody Hent komplett artikkel med HEAD-kommandoen.
Settings_DescHTTPPort Port som webgrensesnittet lytter på. Krever omstart.
Settings_DescItemsPerPage Rader vist per side i Historikk og Magneter.
Settings_DescLanguage Visningsspråk for grensesnittet. La stå tomt for automatisk gjenkjenning fra nettleser.
Settings_DescListenAddress IP-adresse å binde til. Tom = alle grensesnitt.
Settings_DescLocalOnly_UI Begrens webgrensesnittet til lokale forbindelser.
Settings_DescLogDirectory Mappe for loggfiler. Tom = POPFile-rot.
Settings_DescLogLevel Detaljnivå for loggutdata.
Settings_DescLogSQLToStdout Skriv ut hver SQL-setning med bundne verdier til stdout. Bare aktiv når "Logg til stdout" også er aktivert.
Settings_DescLogToStdout Speil loggutdata til stdout i tillegg til loggfilen.
Settings_DescMessageCutoff Maksimalt antall analyserte ord per melding (0 = ubegrenset).
Settings_DescNNTPLocalOnly Godta kun NNTP-forbindelser fra localhost.
Settings_DescNNTPPort Port som POPFile lytter på for NNTP (standard 119).
Settings_DescNNTPSeparator Tegn som skiller bruker fra server.
Settings_DescPOP3LocalOnly Godta kun POP3-forbindelser fra localhost.
Settings_DescPOP3Port Port som POPFile lytter på for POP3 (standard 1110).
Settings_DescPOP3Separator Tegn som skiller bruker fra server (f.eks. bruker:mailhost).
Settings_DescRetentionDays Hvor mange dager meldingshistorikk beholdes.
Settings_DescSessionDividers Vis skillelinjer mellom nettleserøkter i Historikk.
Settings_DescSMTPLocalOnly Godta kun SMTP-forbindelser fra localhost.
Settings_DescSMTPPort Port som POPFile lytter på for SMTP (standard 25).
Settings_DescSQLiteJournal SQLite-journal / WAL-modus.
Settings_DescSQLiteTweaks Bitmaske: 1 = raskere skriving (mindre sikker), 2 = periodisk sikkerhetskopiering.
Settings_DescSSLChainPort Port for den overordnede SSL POP3-serveren.
Settings_DescSSLChainServer Vertsnavn for den overordnede SSL POP3-serveren for SSL-kjeding.
Settings_DescSubjectTagLeft Prefiks satt inn i emnehode, f.eks. [SØPPELPOST].
Settings_DescSubjectTagRight Suffiks lagt til emnehode.
Settings_DescTagPosition Hvor emnemerket plasseres.
Settings_DescTOPFetchesBody Hent også meldingsinnhold med TOP-kommandoen.
Settings_DescUnclassifiedWeight Sannsynlighetsterskel under hvilken post er "uklassifisert".
Settings_DescWordStemming Reduser ord til stammen før klassifisering (f.eks. "løper" til "løp"). Forbedrer recall for morfologisk rike språk med ~10% forsinkelseskostnad.
Settings_DescWordTable Hva som vises i ordsannsynlighetstabellen.
Settings_ErrorSaving Feil ved lagring
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD henter innhold
Settings_HTTPPort HTTP-port
Settings_ItemsPerPage Elementer per side
Settings_ListenAddress Lytteadresse
Settings_ListenPort Lytteport
Settings_LocalOnly Bare lokalt
Settings_LogDirectory Loggmappe
Settings_LogLevel Loggnivå
Settings_LogSQLToStdout Logg SQL til stdout
Settings_LogToStdout Logg til stdout
Settings_MessageCutoff Meldingsgrense
Settings_OptDebug Feilsøking
Settings_OptEnd Slutt
Settings_OptErrorsOnly Bare feil
Settings_OptFrequencies Frekvenser
Settings_OptFront Forside
Settings_OptHidden Skjult
Settings_OptInfo Info
Settings_OptLogScores Logg scorer
Settings_OptProbabilities Sannsynligheter
Settings_OptWarnings Advarsler
Settings_RetentionDays Oppbevaring (dager)
Settings_SaveChanges Lagre endringer
Settings_Saved Lagret
Settings_Saving Lagrer...
Settings_Search Søk i innstillinger...
Settings_SectionClassifier Klassifikator
Settings_SectionHistory Historikk
Settings_SectionLogging Logging
Settings_SectionNNTP NNTP-proxy
Settings_SectionPOP3 POP3-proxy
Settings_SectionSecurity Sikkerhet
Settings_SectionSMTP SMTP-proxy
Settings_SectionUI Brukergrensesnitt
Settings_ServerSeparator Serverskilletegn
Settings_SessionDividers Øktskillere
Settings_SQLiteJournalMode SQLite-journalmodus
Settings_SQLiteTweaks SQLite-justeringer
Settings_SSLChainPort SSL-kjedeport
Settings_SSLChainServer SSL-kjedeserver
Settings_SubjectTagLeft Emnemerke venstre
Settings_SubjectTagRight Emnemerke høyre
Settings_TagPosition Merkeposisjon
Settings_TOPFetchesBody TOP henter innhold
Settings_UnclassifiedWeight Uklassifisert vekt
Settings_WordStemming Ordstemming
Settings_WordTable Ordtabell
Status_Checking Kontrollerer...
Status_Description Statuskontroller for POPFile-tjenester.
Status_LoadError Kunne ikke laste status
Status_NoChecks Ingen kontroller tilgjengelige.


Language_Name                           Norsk
History_PerPage                          Oppføringer per side
Imap_Advanced                            Avansert
Imap_Cancel                              Avbryt
Imap_Wizard                              Oppsettveiviser
Imap_WizardApply                         Opprett og tilordne
Imap_WizardClose                         Lukk
Imap_WizardDesc                          Velg mapper å opprette bøtter og tilordninger for.
Imap_WizardDeselectAll                   Fjern alle valg
Imap_WizardDone                          {count} kategori(er) opprettet og tilordnet.
Imap_WizardEmpty                         Ingen flere mapper funnet på serveren.
Imap_WizardSelectAll                     Velg alle
Imap_WizardTrain                         Tren nå
NavWordSearch                            Ordsøk
Settings_DescEnableProxy                 Start denne proxyen når POPFile starter.
Settings_DescLogFormat                   Format for loggutdata (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Åpne nettleser automatisk ved oppstart.
Settings_DescSQLiteBackup                Ta automatisk sikkerhetskopi av database før skjemaendringer.
Settings_DescSQLiteFastWrites            Deaktiver databasesynkronisering (raskere, mindre sikkert).
Settings_EnableService                   Aktiver tjeneste
Settings_LogFormat                       Loggformat
Settings_OpenBrowser                     Åpne nettleser
Settings_SQLiteBackup                    SQLite sikkerhetskopi
Settings_SQLiteFastWrites                SQLite rask skriving
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Legg til stoppord
WordSearch_ColumnBuckets                 Kategorier
WordSearch_ColumnWord                    Ord
WordSearch_IsStopword                    Stoppord
WordSearch_Loading                       Laster...
WordSearch_NoResults                     Ingen resultater.
WordSearch_NoStopwords                   Ingen stoppord.
WordSearch_Placeholder                   Skriv inn et ord...
WordSearch_RemoveStopword                Fjern stoppord
WordSearch_Search                        Søk
WordSearch_StopwordList                  Stoppordliste
WordSearch_Title                         Ordsøk
WordSearch_Total                         Totalt
