# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            no
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          no

# Common words that are used on their own all over the interface
Apply                                   Bruk
On                                      På
Off                                     Av
TurnOn                                  Slå på
TurnOff                                 Slå av
Add                                     Legg til
Remove                                  Fjern
Previous                                Forrige
Next                                    Neste
From                                    Fra
Subject                                 Emne
Classification                          Klassifisering
Reclassify                              Re-klassifisering
Undo                                    Angre
Close                                   Lukk
Find                                    Søk
Filter                                  Filtrer
Yes                                     Ja
No                                      Nei
ChangeToYes                             Skift til Ja
ChangeToNo                              Skift til Nei
Bucket                                  Bøtte
Magnet                                  Magnet
Delete                                  Slett
Create                                  Opprett
To                                      Til
Total                                   Total
Rename                                  Omdøp
Frequency                               Frekvens
Probability                             Sannsynlighet
Score                                   Resultat
Lookup                                  Søk etter

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrollsenter
Header_Shutdown                         Lukk POPFile
Header_History                          Logg
Header_Buckets                          Bøtter
Header_Configuration                    Konfigurering
Header_Advanced                         Avansert
Header_Security                         Sikkerhet
Header_Magnets                          Magneter

Footer_HomePage                         POPFile Hjemmeside
Footer_Manual                           Manual
Footer_Forums                           Diskusjonsforum
Footer_FeedMe                           Mat meg!
Footer_RequestFeature                   Etterspør funksjoner
Footer_MailingList                      Mailingliste

Configuration_Error1                    Skilletegnet skal være ett enkelt tegn
Configuration_Error2                    Brukergrensesnittets port skal være et nummer mellom 1 og 65535
Configuration_Error3                    POP3-porten skal være et nummer mellom 1 og 65535
Configuration_Error4                    Sidens størrelse skal være mellom 1 og 1000
Configuration_Error5                    Antall dager i loggen skal være et tall mellom 1 og 366
Configuration_Error6                    TCP-tidsavbrudd skal være et tall mellom 10 og 1800
Configuration_POP3Port                  POP3-porten
Configuration_POP3Update                Oppdaterte porten til %s; Denne endringen vil ikke tre i kraft før POPFile er startet på nytt
Configuration_Separator                 Skilletegn
Configuration_SepUpdate                 Oppdaterte skilletegnet til %s
Configuration_UI                        Brukergrensesnittets web-port
Configuration_UIUpdate                  Oppdaterte Brukergrensesnittets web-port til %s; endringen vil ikke tre i kraft før POPFile startes på nytt
Configuration_History                   Antall e-post pr. side
Configuration_HistoryUpdate             Oppdaterte antall e-post pr. side til %s
Configuration_Days                      Antall dager oppføringer i loggen skal beholdes
Configuration_DaysUpdate                Oppdaterte antall dager oppføringer i loggen skal beholdes til %s
Configuration_UserInterface             Brukergrensesnittet
Configuration_Skins                     Skins
Configuration_SkinsChoose               Velg skin
Configuration_Language                  Språk
Configuration_LanguageChoose            Velg språk
Configuration_ListenPorts               POP3-porten
Configuration_HistoryView               Logg-visning
Configuration_TCPTimeout                TCP-forbindelsens tidsavbrudd
Configuration_TCPTimeoutSecs            TCP-forbindelsens tidsavbrudd i sekunder
Configuration_TCPTimeoutUpdate          Oppdaterte TCP-forbindelsens tidsavbrudd til %s
Configuration_ClassificationInsertion   Klassifikasjonsmåter (innsetting)
Configuration_SubjectLine               Emnelinje-innsetting
Configuration_XTCInsertion              X-Text-Classification innsetting
Configuration_XPLInsertion              X-POPFile-Link innsetting
Configuration_Logging                   Logging
Configuration_None                      Ingen
Configuration_ToScreen                  Til Skjerm
Configuration_ToFile                    Til Fil
Configuration_ToScreenFile              Til Skjerm og Fil
Configuration_LoggerOutput              Logger output
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' Er allerede i Stoppordlisten
Advanced_Error2                         Stoppord kan kun inneholde Alfanumeriske tegn, ., _, -, eller @ tegn
Advanced_Error3                         '%s' er lagt til i stoppordlisten
Advanced_Error4                         '%s' er ikke i stoppordlisten
Advanced_Error5                         '%s' er fjernet fra stoppordlisten
Advanced_StopWords                      Stoppord
Advanced_Message1                       Disse ordene blir ignorert fra all klassifisering fordi de forekommer meget ofte.
Advanced_AddWord                        Legg til ord
Advanced_RemoveWord                     Fjern ord

History_Filter                          &nbsp;(vis kun bøtten<font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(søk emne for %s)
History_Title                           Siste meldinger
History_Jump                            Hopp til melding
History_ShowAll                         Vis alle
History_ShouldBe                        Skulle være
History_NoFrom                          ingen Fra-linje
History_NoSubject                       ingen Emne-linje
History_ClassifyAs                      klassifisert som
History_MagnetUsed                      Magnet brukt
History_ChangedTo                       Endret til <font color="%s">%s
History_Already                         Re-klassifisert som <font color="%s">%s</font>
History_RemoveAll                       Fjern alle
History_RemovePage                      Fjern side
History_Remove                          For å fjerne oppføringer i loggen, klikk
History_SearchMessage                   Søk Emne
History_NoMessages                      Ingen meldinger

Password_Title                          Passord
Password_Enter                          Skriv inn passord
Password_Go                             OK!
Password_Error1                         Feil passord

Security_Error1                         Den sikre porten skal være et tall mellom 1 og 65535
Security_Stealth                        Stealth Mode/Server Operation
Security_NoStealthMode                  Nei (Stealth Mode)
Security_ExplainStats                   (Denne funksjonen sender en gang per dag de etterfølgene tre verdiene til et script hos wwwu.sethesource.com: bc (det totale antall bøtter du har) mc (det totale antall i meldinger som POPFile har klassifisert ) og ec (det totale antall klassifiseringsfeil). Disse blir lageret i en fil og jeg vil bruke disse data til å offentligjøre statistikk omkring hvordan folk bruker POPFile og hvor godt POPFile virker. Min web-server beholder denne log-filen omtrent 5 dager og blir så slettet; Jeg lagrer ingen forbindelse mellom statistikken og individuelle IP-adresser.)
Security_ExplainUpdate                  (Denne funksjonen sender en gang per dag de  etterfølgene tre verdiene til et script hos wwwu.sethesource.com: ma (hovedversjonsnummeret på din installerte POPFile), mi (under-versjonsnummeret på din installerte POPFile) og bn (build nummer på din installerte POPFile). POPFile mottar et svar i form av et stykke grafikk som vises i toppen av siden, hvis en ny version er tilgjengelig. Min web-server tar vare på denne log-filen omtrent 5 dager og de blir så slettet; Jeg lagrer ingen forbindelse mellom statistikken og individuelle IP-adresser.)
Security_PasswordTitle                  Brukergrensesnittets Passord
Security_Password                       Passord
Security_PasswordUpdate                 Oppdater passord til %s
Security_AUTHTitle                      Godkjenning av sikkert passord
Security_SecureServer                   Sikker Server
Security_SecureServerUpdate             Opdaterte sikker server til %s; denne endringen vil ikke tre i kraft før omstart av POPFile
Security_SecurePort                     Sikker port
Security_SecurePortUpdate               Opdaterte porten til %s; denne endringen vil ikke tre i kraft før omstart av POPFile
Security_POP3                           Godta POP3-tilkoblinger fra andre maskiner
Security_UI                             Godta HTTP (Brukergrensesnitt) tilkoblinger fra andre maskiner
Security_UpdateTitle                    Automatisk Oppdaterings-kontroll
Security_Update                         Kontroller daglig om det finnes oppdateringer til POPFile
Security_StatsTitle                     Statistikk-rapportering
Security_Stats                          Send statistikk tilbake til John daglig

Magnet_Error1                           Magneten '%s' finnes allrede i bøtten'%s' 
Magnet_Error2                           Den nye magneten '%s' er i konflikt med magneten '%s' i bøtten '%s' og kan gi flertydige resultater. Den nye magneten ble ikke tilføyd.
Magnet_Error3                           Opprettet den nye magneten '%s' i bøtten '%s'
Magnet_CurrentMagnets                   Nåværende Magneter
Magnet_Message1                         De følgende magnetene gjør at e-post alltid blir klassifisert til den spesifiserte bøtten.
Magnet_CreateNew                        Opprett Ny Magnet
Magnet_Explanation                      Tre typer magneter er anbefalt: <ul><li>Fra adressen eller navn:</b> For eksempel: john@firma.dk for å matche en spesifikk adresse, <br />firma.dk for å matche alle som sender fra firma.dk, <br />John Doe for å matche en spesifikk person, John for å matche alle John'er</li><li><b>Til adresse eller navn:</b> Samme som en Fra: Magnet men bare for Til: Adressen i en e-post</li><li><b>Emne-ord:</b> For eksempel: hei for å matche alle meldinger med ordet hei i emnet</li></ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Verdier
Magnet_Always                           Tilhører alltid bøtten

Bucket_Error1                           Bøttenes navn kan kun inneholde bokstavene a til z med små bokstaver, samt - og _
Bucket_Error2                           Bøtten med navnet %s eksisterer allerede
Bucket_Error3                           Opprett bøtten med navnet %s
Bucket_Error4                           Skriv venligst ikke et tomt ord
Bucket_Error5                           Omdøp bøtten %s til %s
Bucket_Error6                           Slett bøtten %s
Bucket_Title                            Oversikt
Bucket_BucketName                       Bøttenes navn
Bucket_WordCount                        Ordtelling
Bucket_WordCounts                       Ordfordeling
Bucket_UniqueWords                      Unike ord
Bucket_SubjectModification              Emne-modifisering
Bucket_ChangeColor                      Skift farge
Bucket_NotEnoughData                    Ikke nok data
Bucket_ClassificationAccuracy           Klassifikasjons-nøyaktighet
Bucket_EmailsClassified                 Antall e-post klassifisert
Bucket_EmailsClassifiedUpper            Antall e-post klassifisert
Bucket_ClassificationErrors             Klassifiseringsfeil
Bucket_Accuracy                         Nøyaktighet
Bucket_ClassificationCount              Klassifiseringstelling
Bucket_ResetStatistics                  Nullstill Statistikkene
Bucket_LastReset                        Sist nullstilt
Bucket_CurrentColor                     %s Nåværende farge er %s
Bucket_SetColorTo                       Sett %s fargen til %s
Bucket_Maintenance                      Vedlikehold
Bucket_CreateBucket                     Oppret bøtten med navnet
Bucket_DeleteBucket                     Slett bøtten med navnet
Bucket_RenameBucket                     Omdøp bøtten med navnet
Bucket_Lookup                           Søk etter
Bucket_LookupMessage                    Søk etter ord i bøttene
Bucket_LookupMessage2                   Søkeresultatet for
Bucket_LookupMostLikely                 Det er mest sannsynlig at <b>%s</b> forekommer i <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> forekommer ikke i noen av bøttene
Bucket_DisabledGlobally                 Deaktivert globalt
Bucket_To                               til
Bucket_Quarantine                       Karantene

SingleBucket_Title                      Detaljer for %s
SingleBucket_WordCount                  Totalt antall ord i bøtten
SingleBucket_TotalWordCount             Totalt antall ord
SingleBucket_Percentage                 Prosentandelen av totalen
SingleBucket_WordTable                  Ord tabell for %s
SingleBucket_Message1                   Markerte (*) ord er blitt brukt til å klassifisere i denne POPFile-sesjonen. Trykk på hvilket som helst ord for å slå opp dens sannsynlighet for alle bøttene.
SingleBucket_Unique                     %s unike

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
NavCorpus Korpus
NavHistory Historikk
NavIMAP IMAP
NavMagnets Magneter
NavSettings Innstillinger
NavStatus Status
NavWordView Ord
Corpus_BucketList Kategorier
Corpus_Color Farge
Corpus_Actions Handlinger
Corpus_Clear Tøm
Corpus_Search Søk
Corpus_StopwordsTitle Stoppord
Corpus_StopwordsDesc Ord på denne listen brukes aldri til klassifisering.
Corpus_RemoveStopword Fjern
Corpus_StopwordCandidates Stoppordkandidater
Corpus_StopwordCandidatesDesc Ord som forekommer jevnt i alle kategorier — liten diskriminerende kraft.
Corpus_StopwordRatio Maks/min-forholdterskel
Corpus_LoadCandidates Finn kandidater
Corpus_NoCandidates Ingen kandidater funnet ved denne terskelen.
Corpus_AddStopword Legg til stoppord
Corpus_WordsLink Ord →
BucketSelect_AddNew Legg til ny...
BucketSelect_AlreadyExists Eksisterer allerede
BucketSelect_CreateError Feil ved oppretting av kategori
BucketSelect_InvalidName Bare a-z, 0-9, - og _
BucketSelect_NameRequired Navn påkrevd
Bucket_InIgnoredWords <b>%s</b> er i ignorerte ord. POPFile ignorerer dette ordet
Bucket_ClassificationFN Falsk negativer
Bucket_ClassificationFP Falsk positiver
ApplyChanges Bruk endringer
Arrived Mottatt
Cc Kopi
Count Antall
Date Dato
FAQ FAQ
Footer_Wiki Dokumentasjon
ID ID
Probability Sannsynlighet
QuickMagnets HurtigMagneter
Refresh Oppdater
Scores Scorer
Shutdown_Message POPFile er avsluttet
Size Størrelse
Update Oppdater
Word Ord
Configuration_CurrentLogFile &lt;Vis gjeldende loggfil&gt;
Configuration_Error7 XML RPC lytteporten må være et tall mellom 1 og 65535
Configuration_Error8 SOCKS V proxy-porten må være et tall mellom 1 og 65535
Configuration_Error9 Brukergrensesnittporten kan ikke ha samme verdi som POP3 lytteporten
Configuration_Error10 POP3 lytteporten kan ikke ha samme verdi som brukergrensesnittporten
Configuration_Fields Historikk-kolonner
Configuration_NNTPFork Tillat samtidige NNTP-forbindelser
Configuration_NNTPPort NNTP lytteport
Configuration_NNTPSeparator NNTP vert:port:bruker skilletegn
Configuration_NNTPSepUpdate NNTP-skilletegn oppdatert til %s
Configuration_NNTPUpdate NNTP-port oppdatert til %s; endringen trer i kraft etter omstart av POPFile
Configuration_POP3Separator POP3 vert:port:bruker skilletegn
Configuration_POP3SepUpdate POP3-skilletegn oppdatert til %s
Configuration_POPFork Tillat samtidige POP3-forbindelser
Configuration_SMTPFork Tillat samtidige SMTP-forbindelser
Configuration_SMTPPort SMTP lytteport
Configuration_SMTPUpdate SMTP-port oppdatert til %s; endringen trer i kraft etter omstart av POPFile
Configuration_SOCKSPort SOCKS V proxy-port
Configuration_SOCKSPortUpdate SOCKS V proxy-port oppdatert til %s
Configuration_SOCKSServer SOCKS V proxy-vert
Configuration_SOCKSServerUpdate SOCKS V proxy-vert oppdatert til %s
Configuration_XMLRPCPort XML-RPC lytteport
Configuration_XMLRPCUpdate XML-RPC-port oppdatert til %s; endringen trer i kraft etter omstart av POPFile
Help_Bucket_Setup POPFile krever minst to kategorier i tillegg til pseudo-kategorien "uklassifisert". Det som gjør POPFile unikt er at det kan klassifisere e-post i mer enn det; du kan ha et hvilket som helst antall kategorier. Et enkelt oppsett ville være en "søppelpost"-, "personlig"- og "arbeid"-kategori.
Help_No_More Ikke vis dette igjen
Help_Training Når du bruker POPFile for første gang, vet det ingenting og trenger opplæring. POPFile krever opplæring med meldinger for hver kategori; opplæring skjer når du omklassifiserer en melding som POPFile feilklassifiserte til riktig kategori. Før POPFile klassifiserer den første meldingen, må du ha omklassifisert meldinger til minst to kategorier.
History_AllBuckets Alle kategorier
History_Automatic Automatisk
History_ChangedClass Ville nå klassifisere som
History_Column_Characters Endre bredde på Fra, Til, Kopi og Emne-kolonner
History_Decrease Reduser
History_HighlightWords Fremhev ord etter kategori
History_Increase Øk
History_Loading Laster...
History_Magnet &nbsp;(viser bare magnetklassifiserte meldinger)
History_MagnetBecause <b>Magnet brukt</b><p>Klassifisert til <font color="%s">%s</font> på grunn av magnet %s </p>
History_MoveTo — flytt til —
History_Moving Flytter...
History_Negate_Search Inverter søk/filter
History_NoMagnet &nbsp;(viser bare ikke-magnetklassifiserte meldinger)
History_NoMatchingMessages Ingen samsvarende meldinger
History_Purge Utløp nå
History_Reclassified Omklassifisert
History_Reclassifying Omklassifiserer...
History_ReclassifyUnclassified Omklassifiser uklassifiserte
History_RemoveChecked Fjern valgte
History_ResetSearch Tilbakestill
History_Selected valgt(e)
History_ShowMagnet magnetisert
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
Imap_Bucket2Folder Post for kategori '<b>%s</b>' går til mappe
Imap_BucketFolderMappings Kategori -> Mappatilordninger
Imap_Bytelimit Byte per melding til klassifisering. Angi 0 for den komplette meldingen:
Imap_BytelimitError Angi et tall.
Imap_Connected Tilkoblet
Imap_Connection Tilkobling
Imap_ConnectionFailed Tilkobling mislyktes
Imap_Description Overvåk IMAP-mapper og klassifiser automatisk innkommende meldinger.
Imap_EnableService Aktiver IMAP-tjeneste
Imap_Expunge Slett slettede meldinger fra overvåkede mapper.
Imap_FetchFolders Hent mapper
Imap_Fetching Henter...
Imap_IMAFFolder IMAP-mappe
Imap_Interval Oppdateringsintervall i sekunder:
Imap_IntervalError Angi et intervall mellom 10 og 3600 sekunder.
Imap_Login IMAP-konto innlogging:
Imap_LoginError Angi et bruker-/innloggingsnavn!
Imap_MapError Du kan ikke knytte mer enn én kategori til en enkelt mappe!
Imap_MappingsHint Klassifiserte meldinger flyttes til den angitte IMAP-mappen. La ikke-tilordnede kategorier være tomme for å hoppe over flytting.
Imap_NoConnectionMessage Konfigurer tilkoblingsdetaljene først. Etter det vil det være flere alternativer tilgjengelig på denne siden.
Imap_NoFoldersWatched Ingen mapper overvåkes ennå.
Imap_NoMappings Ingen tilordninger definert.
Imap_Now nå!
Imap_Password Passord for IMAP-konto:
Imap_PasswordError Angi et passord for serveren!
Imap_Port IMAP-serverport:
Imap_PortError Angi et gyldig portnummer!
Imap_RefreshFolders Oppdater mappeliste
Imap_SaveAnyway Lagre likevel
Imap_SaveConnection Lagre tilkobling
Imap_SaveFolders Lagre mapper
Imap_Saving Lagrer...
Imap_Server IMAP-server vertsnavn:
Imap_ServerNameError Angi serverens vertsnavn!
Imap_Service Tjeneste
Imap_TestConnection Test tilkobling
Imap_Testing Tester...
Imap_TrainingHint Opplæringsmodus gjennomgår eksisterende arkivmapper og trener klassifikatoren på innholdet. Flagget tilbakestilles automatisk når opplæringen er fullført.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Opplæringsmodus
Imap_TrainingLimit Meldinger per mappe (0 = ubegrenset)
Imap_UpdateError1 Kunne ikke logge inn. Bekreft brukernavn og passord.
Imap_UpdateError2 Tilkobling til server mislyktes. Sjekk vertsnavn og port og sørg for at du er tilkoblet internett.
Imap_UpdateError3 Konfigurer tilkoblingsdetaljene først.
Imap_Use_SSL Bruk SSL
Imap_WatchedFolder Overvåket mappe nr.
Imap_WatchedFolders Overvåkede mapper
Imap_WatchedHint POPFile overvåker disse IMAP-mappene for nye meldinger å klassifisere.
Imap_WatchMore en mappe til listen over overvåkede mapper

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
Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magnet opprettet
Magnet_Deleted Magnet slettet
Magnet_Jump Gå til magnetside
Reconnect_Connecting Kobler til...
Reconnect_Message Backend er ikke tilgjengelig. Forsøker å koble til igjen...
Reconnect_Now Koble til nå
Reconnect_RetryIn Prøver igjen om
Reconnect_Title Tilkobling mistet
Security_NNTP Godta NNTP-forbindelser fra eksterne maskiner (krever omstart av POPFile)
Security_SMTP Godta SMTP-forbindelser fra eksterne maskiner (krever omstart av POPFile)
Security_SMTPPort SMTP-kjedeport
Security_SMTPPortUpdate SMTP-kjedeport oppdatert til %s; endringen trer i kraft etter omstart av POPFile
Security_SMTPServer SMTP-kjedeserver
Security_SMTPServerUpdate SMTP-kjedeserver oppdatert til %s; endringen trer i kraft etter omstart av POPFile
Security_StealthMode (Stealthmodus)
Security_XMLRPC Godta XML-RPC-forbindelser fra eksterne maskiner (krever omstart av POPFile)
Session_Error POPFile-økten din har utløpt. Dette kan ha blitt forårsaket av å starte og stoppe POPFile mens nettleseren var åpen. Klikk på en av koblingene ovenfor for å fortsette å bruke POPFile.
Session_Title POPFile-økt utløpt
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
SingleBucket_ClearBucket Fjern alle ord
Status_Checking Kontrollerer...
Status_Description Statuskontroller for POPFile-tjenester.
Status_LoadError Kunne ikke laste status
Status_NoChecks Ingen kontroller tilgjengelige.
View_Chart Beslutningsdiagram
View_DownloadMessage Last ned melding
View_MessageBody Meldingsinnhold
View_MessageHeader Meldingshode
View_ShowFrequencies Vis ordfrekvenser
View_ShowProbabilities Vis ordsannsynligheter
View_ShowScores Vis ordscorer og beslutningsdiagram
View_Title Enkeltmeldingsvisning
View_WordFrequencies viser ordfrekvenser
View_WordMatrix Ordmatrise
View_WordProbabilities viser ordsannsynligheter
View_WordScores viser ordscorer
Windows_Console Kjør POPFile i et konsollvindu?
Windows_NextTime <p><font color="red">Denne endringen vil ikke tre i kraft før neste gang du starter POPFile</font>
Windows_TrayIcon Vis POPFile-ikonet i Windows systemstatusfeltet?

Advanced_AllParameters Alle POPFile-parametere
Advanced_ConfigFile Konfigurasjonsfil:
Advanced_Parameter Parameter
Advanced_Value Verdi
Advanced_Warning Dette er den fullstendige listen over POPFile-parametere. Kun for avanserte brukere: du kan endre hvilken som helst og klikke Oppdater; det er ingen gyldighetssjekk. Elementer vist med fet skrift er endret fra standardinnstillingen.

Language_Name                           Norsk
History_PerPage                          Oppføringer per side
Imap_Advanced                            Avansert
Imap_Cancel                              Avbryt
Imap_Wizard                              Oppsettveiviser
Imap_WizardApply                         Opprett og tilordne
Imap_WizardClose                         Lukk
Imap_WizardDesc                          Velg mapper å opprette bøtter og tilordninger for.
Imap_WizardDeselectAll                   Fjern alle valg
Imap_WizardDone                          {count} bøtte(r) opprettet og tilordnet.
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
WordSearch_ColumnBuckets                 Bøtter
WordSearch_ColumnWord                    Ord
WordSearch_Coverage                      Dekning
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
