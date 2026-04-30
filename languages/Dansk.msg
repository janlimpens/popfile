# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            da
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          da

# Common words that are used on their own all over the interface
Apply                                   Anvend
On                                      Til
Off                                     Fra
TurnOn                                  Slå til
TurnOff                                 Slå fra
Add                                     Tilføj
Remove                                  Fjern
Previous                                Forrige
Next                                    Næste
From                                    Fra
Subject                                 Emne
Classification                          Klassificering
Reclassify                              Genklassificering
Undo                                    Fortryd
Close                                   Luk
Find                                    Søg
Filter                                  Filtrér
Yes                                     Ja
No                                      Nej
ChangeToYes                             Skift til Ja
ChangeToNo                              Skift til Nej
Bucket                                  Spand
Magnet                                  Magnet
Delete                                  Slet
Create                                  Tilføj
To                                      Til
Total                                   Total
Rename                                  Omdøb
Frequency                               Frekvens
Probability                             Sandsynlighed
Score                                   Resultat
Lookup                                  Slå op

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrolcenter
Header_Shutdown                         Luk
Header_History                          Historik
Header_Buckets                          Spande
Header_Configuration                    Indstillinger
Header_Advanced                         Avanceret
Header_Security                         Sikkerhed
Header_Magnets                          Magneter

Footer_HomePage                         POPFiles hjemmeside
Footer_Manual                           Manual
Footer_Forums                           Fora
Footer_FeedMe                           Donér
Footer_RequestFeature                   Foreslå funktion
Footer_MailingList                      Postliste

Configuration_Error1                    Skilletegnet skal være et enkelt tegn
Configuration_Error2                    Kontrolcenterets port skal være et tal mellem 1 og 65535
Configuration_Error3                    POP3-porten skal være et tal mellem 1 og 65535
Configuration_Error4                    Sidens størelse skal være mellem 1 og 1000
Configuration_Error5                    Antal dage i historikken skal være et tal mellem 1 og 366
Configuration_Error6                    TCP-timeouten skal være et tal mellem 10 og 1800
Configuration_Error7                    XML-RPC-porten skal være et tal mellem 1 og 65535
Configuration_POP3Port                  POP3-port
Configuration_POP3Update                Opdaterede POP3-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_XMLRPCUpdate              Opdaterede XML-RPC-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_XMLRPCPort                XML-RPC-port
Configuration_SMTPPort                  SMTP-port
Configuration_SMTPUpdate                Opdaterede SMTP-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_NNTPPort                  NNTP-port
Configuration_NNTPUpdate                Opdaterede NNTP-porten til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_POP3Separator             POP3 vært:port:bruger-skilletegn
Configuration_NNTPSeparator             NNTP vært:port:bruger-skilletegn
Configuration_POP3SepUpdate             Opdaterede POP3-skilletegn til %s
Configuration_NNTPSepUpdate             Opdaterede NNTP-skilletegn til %s
Configuration_UI                        Kontrolcenterets webport
Configuration_UIUpdate                  Opdaterede kontrolcenterets webport til %s; denne ændring vil ikke træde i kraft før POPFile er genstartet
Configuration_History                   Antal breve pr. side
Configuration_HistoryUpdate             Opdaterede antal breve pr. side til %s
Configuration_Days                      Antal dage historikken skal beholdes
Configuration_DaysUpdate                Opdaterede antal dage historikken skal beholdes til %s
Configuration_UserInterface             Kontrolcenter
Configuration_Skins                     Skins
Configuration_SkinsChoose               Vælg skin
Configuration_Language                  Sprog
Configuration_LanguageChoose            Vælg sprog
Configuration_ListenPorts               POP3-port
Configuration_HistoryView               Historik
Configuration_TCPTimeout                TCP-forbindelsens timeout
Configuration_TCPTimeoutSecs            TCP-forbindelsens timeout i sekunder
Configuration_TCPTimeoutUpdate          Opdaterede TCP-forbindelsens timeout til %s
Configuration_ClassificationInsertion   Klassificering
Configuration_SubjectLine               Emnelinie-modifikation
Configuration_XTCInsertion              X-Text-Classification
Configuration_XPLInsertion              X-POPFile-Link
Configuration_Logging                   Logning
Configuration_None                      Ingen
Configuration_ToScreen                  Til skærm
Configuration_ToFile                    Til fil
Configuration_ToScreenFile              Til skærm og fil
Configuration_LoggerOutput              Log
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Små skins
Configuration_TinySkins                 Meget små skins

Advanced_Error1                         '%s' er allerede i stopordslisten
Advanced_Error2                         Stopord kan kun indeholde tal og bogstaver, samt ., _, -, eller @.
Advanced_Error3                         '%s' er tilføjet til stopordslisten
Advanced_Error4                         '%s' er ikke i stopordslisten
Advanced_Error5                         '%s' er fjernet fra stopordslisten
Advanced_StopWords                      Stopord
Advanced_Message1                       Følgende ord bliver ignoreret under alle klassificeringer på grund af deres hyppighed:
Advanced_AddWord                        Tilføj ord
Advanced_RemoveWord                     Fjern ord

History_Filter                          &nbsp;(vis kun spanden <font color="%s">%s</font>)
History_FilterBy                        Filtrér med
History_Search                          &nbsp;(søg emne for %s)
History_Title                           Seneste beskeder
History_Jump                            Spring til besked
History_ShowAll                         Vis alle
History_ShouldBe                        Skal være
History_NoFrom                          Ingen fra-linie
History_NoSubject                       Ingen emne-linie
History_ClassifyAs                      Klassificeret som
History_MagnetUsed                      Magnet brugt
History_ChangedTo                       Skift til <font color="%s">%s
History_Already                         Allerede genklassificeret som <font color="%s">%s</font>
History_RemoveAll                       Fjern alle
History_RemovePage                      Fjern side
History_Remove                          Fjern breve i historikken ved at trykke
History_SearchMessage                   Søg i Fra/Emne
History_NoMessages                      Ingen breve
History_ShowMagnet                      Magnetiseret
History_Magnet                          &nbsp;(viser kun magnet-klassificerede meddelelser)
History_ResetSearch                     Nulstil

Password_Title                          Kodeord
Password_Enter                          Indtast kodeord
Password_Go                             OK
Password_Error1                         Forkert kodeord

Security_Error1                         Den sikre port skal være et tal mellem 1 og 65535
Security_Stealth                        Sikker tilstand/Server
Security_NoStealthMode                  Nej (Sikker tilstand)
Security_ExplainStats                   (Med denne funktion slået til sender POPFile en gang om dagen tre værdier til et script hos wwwu.sethesource.com:<br>bc (antallet af dine spande),<br>mc (antallet af breve, POPFile har klassificeret) og<br>ec (antallet af klassificeringsfejl). Disse tal bliver gemt i en fil. Jeg vil bruge disse data til at offentliggøre en statistik over hvordan folk bruger POPFile og hvor godt POPFile virker. Min web server gemmer denne logfil i ca. 5 dage, hvorefter de bliver slettet; Jeg gemmer ingen sammenhæng mellem statistikken og individuelle IP adresser.)
Security_ExplainUpdate                  (Med denne funktion slået til sender POPFile en gang om dagen tre værdier til et script hos wwwu.sethesource.com:<br>ma (det store versionsnummer på din installerede POPFile),<br>mi (det lille versionsnummer på din installerede POPFile) og<br>bn (build-nummeret på din installerede POPFile).<br>POPFile modtager et svar i form af et stykke grafik, som vises i toppen af siden, hvis en ny version er til rådighed. Min web server gemmer denne logfil i ca. 5 dage, hvorefter de bliver slettet; Jeg gemmer ingen sammenhæng mellem statistikken og individuelle IP adresser.)
Security_PasswordTitle                  Kontrolcenterets kodeord
Security_Password                       Kodeord
Security_PasswordUpdate                 Opdater kodeord til %s
Security_AUTHTitle                      Godkendelse af sikker adgangskode
Security_SecureServer                   Sikker server
Security_SecureServerUpdate             Opdaterede sikker server til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SecurePort                     Sikker port
Security_SecurePortUpdate               Opdaterede den sikre port til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SMTPServer                     SMTP-kæde-server
Security_SMTPServerUpdate               Opdaterede SMTP-kæde-server til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_SMTPPort                       SMTP-kæde-port
Security_SMTPPortUpdate                 Opdaterede SMTP-kæde-port til %s. Denne ændring vil ikke træde i kraft før POPFile er genstartet
Security_POP3                           Acceptér POP3-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_SMTP                           Acceptér SMTP-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_NNTP                           Acceptér NNTP-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_UI                             Acceptér HTTP(kontrolcenter)-tilslutninger fra andre maskiner
Security_XMLRPC                         Acceptér XML-RPC-tilslutninger fra andre maskiner (kræver at POPFile genstartes)
Security_UpdateTitle                    Automatisk opdateringscheck
Security_Update                         Check dagligt, om der er opdateringer af POPFile
Security_StatsTitle                     Statistikrapportering
Security_Stats                          Send statistikkerne tilbage til John dagligt

Magnet_Error1                           Magneten '%s' eksisterer allrede i spanden '%s' 
Magnet_Error2                           Den nye magnet '%s' er i konflikt med magneten '%s' i spanden '%s' og kunne skabe flertydige resultater. Den nye magnet er ikke tilføjet.
Magnet_Error3                           Tilføjede den nye magnet '%s' i spanden '%s'
Magnet_CurrentMagnets                   Magneter i brug
Magnet_Message1                         Magneterne får breve til altid at blive klassificeret til den specificerede spand.
Magnet_CreateNew                        Tilføj nye magneter
Magnet_Explanation                      Der findes tre typer magneter: <ul><li>"Fra:"-adresse eller -navn:</b> For eksempel: john@firma.dk for at matche en specifik adresse, <br />firma.dk for at matche alle, der sender fra firma.dk, <br />John Doe for at matche en specifik person, John for at matche alle John'er.</li><li><b>"Til:"-adresse eller -navn:</b> Lige som en "Fra:"-magnet, men bare for "Til:"-adressen i et brev.</li><li><b>Ord i emnet</b> For eksempel: hej for at matche alle breve med ordet hej i emnet.</li></ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Værdier
Magnet_Always                           Tilhører altid spanden

Bucket_Error1                           Spandenes navne kan kun indholde bogstaverne a til z med små bogstaver, samt - og _
Bucket_Error2                           Spanden med navnet %s findes allerede
Bucket_Error3                           Opret spanden med navnet %s
Bucket_Error4                           Skriv venligst et ikke-tomt ord
Bucket_Error5                           Omdøb spanden %s til %s
Bucket_Error6                           Slet spanden %s
Bucket_Title                            Oversigt
Bucket_BucketName                       Spandenes navne
Bucket_WordCount                        Ordtælling
Bucket_WordCounts                       Ordfordeling
Bucket_UniqueWords                      Unikke ord
Bucket_SubjectModification              Emnemodifikation
Bucket_ChangeColor                      Skift farve
Bucket_NotEnoughData                    Ikke nok data
Bucket_ClassificationAccuracy           Klassificeringsnøjagtighed
Bucket_EmailsClassified                 Klassificerede breve
Bucket_EmailsClassifiedUpper            Klassificerede breve
Bucket_ClassificationErrors             Klassificeringsfejl
Bucket_Accuracy                         Nøjagtighed
Bucket_ClassificationCount              Antal
Bucket_ResetStatistics                  Nulstil Statistikkerne
Bucket_LastReset                        Sidst nulstillet
Bucket_CurrentColor                     %s's aktuelle farve er %s
Bucket_SetColorTo                       Sæt %s-farven til %s
Bucket_Maintenance                      Vedligeholdelse
Bucket_CreateBucket                     Opret spanden med navnet
Bucket_DeleteBucket                     Slet spanden med navnet
Bucket_RenameBucket                     Omdøb spanden med navnet
Bucket_Lookup                           Slå op
Bucket_LookupMessage                    Slå ord op i spandene
Bucket_LookupMessage2                   Opslagsresultatet for
Bucket_LookupMostLikely                 Det er mest sandsynligt at <b>%s</b> forekommer i <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> forekommer ikke i nogle af spandene
Bucket_DisabledGlobally                 Deaktiveret globalt
Bucket_To                               til
Bucket_Quarantine                       Sæt i karantæne

SingleBucket_Title                      Detaljer for %s
SingleBucket_WordCount                  Antal ord i spanden
SingleBucket_TotalWordCount             Antal ord i alt
SingleBucket_Percentage                 Procent af alle ord
SingleBucket_WordTable                  Ordtabel for %s
SingleBucket_Message1                   Markerede (*) ord er blevet brugt til at klassificere i denne POPFile-session. Tryk på et ord for at slå dets sandsynlighed op for alle spandene.
SingleBucket_Unique                     %s unikke

Session_Title                           POPFile-session udløbet
Session_Error                           Din POPFile-session er udløbet. Dette kan skyldes, at du har stoppet og genstartet POPFile uden at lukke din browser.  Klik venligst på et af linkene ovenfor for at fortsætte med at bruge POPFile.


Header_MenuSummary                      Denne tabel er navigationsmenuen, som giver adgang til kontrolcenterets forskellige sider.
History_MainTableSummary                Denne tabel viser afsenderen og emnet på breve modtaget for nyligt og giver dig mulighed for at vurdere og reklassificere dem. Hvis du klikker på emnelinien vil hele brevets tekst blive vist, sammen med oplysninger om, hvorfor det blev klassificeret som det blev. Kolonnen "skal være" giver dig mulighed for at angive, hvilken spand brevet hører til i, eller til at fortryde denne ændring. Kolonnen "Slet" giver dig mulighed for at slette enkelte breve fra historikken, hvis du ikke længere har brug for dem.
History_OpenMessageSummary              Denne tabel indeholder et brevs fulde ordlyd, med nøgleordene, som er brugt til klassificering, markeret svarende til den spand, der er mest relevant for dem.
Bucket_MainTableSummary                 Denne tabel giver et overblik over klassificerings-spandene. Hver række viser spandens navn, antallet af optalte ord for spanden, antallet af unikke ord i spanden, om brevets emnelinie vil blive modificeret, når det klassificeres til spanden, om brevet skal sættes i karantæne, når det lander i spanden, samt en tabel til at vælge hvilken farve, der skal knyttes til spanden. Farven vil blive brugt til alt, hvad der har at gøre med spanden i kontrolcenteret.
Bucket_StatisticsTableSummary           Denne tabel viser tre sæt af statistikker over POPFiles ydelse. Den første viser, hvor nøjagtigt klassificeringen er, den næste viser hvor mange breve, der er blevet klassificeret og til hvilke spande, og den tredie viser, hvor mange ord der er i hver spand, samt deres relative procentandel.
Bucket_MaintenanceTableSummary          Denne tabel giver dig mulighed for at oprette, slette og omdøbe spande, og til at slå et ord op i alle spandene for se dets relative sandsynligheder.
Bucket_AccuracyChartSummary             Denne tabel viser en grafisk repræsentation af nøjagtigheden af brevklassificeringen.
Bucket_BarChartSummary                  Denne tabel viser en grafisk repræsentation af den procentvise fordeling spandene imellem. Den viser både antallet af klassificerede breve og det totale antal ord.
Bucket_LookupResultsSummary             Denne tabel viser sandsynlighederne, der er knyttet til hvert ord i korpusset. For hver spand viser den frekvensen, som ordet forekommer med, sandsynligheden for at det vil forekomme i spanden, samt den samlede effekt på spandens score, ordet vil have, hvis det forekommer i et brev.
Bucket_WordListTableSummary             Denne tabel viser alle ordene i en given spand organiseret alfabetisk i rækker.
Magnet_MainTableSummary                 Denne tabel viser en liste over magneter, der bruges til automatisk at klassificere breve i henhold til faste regler. Hver række viser hvordan magneten er defineret, hvilken spand, den er beregnet på, samt en knap til at slette magneten med.
Configuration_MainTableSummary          Denne tabel giver dig mulighed for at indstille POPFile.
Configuration_InsertionTableSummary     Denne tabel indeholder knapperne, der bestemmer, hvorvidt bestemte ændringer bliver lavet i brevets headere eller emnelinier, før det sendes videre til dit e-postprogram.
Security_MainTableSummary               Denne tabel indeholder kontroller, der vedrører POPFiles almene sikkerhed, hvorvidt programmet automatisk skal undersøge, om der er opdateringer tilgængelige på Internettet samt om der skal sendes statistik om programmets ydelse til programmets forfatter med henblik på offentliggørelse.
Advanced_MainTableSummary               Denne tabel indeholder en liste over stopord, som POPFile ignorerer på grund af deres hyppighed, når det klassificerer breve. De er organiseret alfabetisk i rækker.


# New keys added (translations batch 2)
LanguageCharset ISO-8859-1
LanguageDirection ltr
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpus
NavHistory Historik
NavIMAP IMAP
NavMagnets Magneter
NavSettings Indstillinger
NavStatus Status
NavWordView Ord
Corpus_BucketList Kategorier
Corpus_Color Farve
Corpus_Actions Handlinger
Corpus_Clear Ryd
Corpus_Search Søg
Corpus_StopwordsTitle Stopord
Corpus_StopwordsDesc Ord på denne liste bruges aldrig til klassificering.
Corpus_RemoveStopword Fjern
Corpus_StopwordCandidates Stopordskandidater
Corpus_StopwordCandidatesDesc Ord der forekommer jævnt i alle kategorier — ringe diskriminerende styrke.
Corpus_StopwordRatio Maks/min-forholdsgrænse
Corpus_LoadCandidates Find kandidater
Corpus_NoCandidates Ingen kandidater fundet ved denne grænse.
Corpus_AddStopword Tilføj til stopord
Corpus_WordsLink Ord →
BucketSelect_AddNew Tilføj ny...
BucketSelect_AlreadyExists Eksisterer allerede
BucketSelect_CreateError Fejl ved oprettelse af kategori
BucketSelect_InvalidName Kun a-z, 0-9, - og _
BucketSelect_NameRequired Navn påkrævet
Bucket_InIgnoredWords <b>%s</b> er i ignorerede ord. POPFile ignorerer dette ord
Bucket_ClassificationFN Falsk negative
Bucket_ClassificationFP Falsk positive
ApplyChanges Anvend ændringer
Arrived Modtaget
Cc Cc
Count Antal
Date Dato
FAQ FAQ
Footer_Wiki Dokumentation
ID ID
Probability Sandsynlighed
QuickMagnets HurtigMagneter
Refresh Opdater
Scores Scorer
Shutdown_Message POPFile er lukket ned
Size Størrelse
Update Opdater
Word Ord
Configuration_CurrentLogFile &lt;Vis aktuelt logfil&gt;
Configuration_Error8 SOCKS V proxy-porten skal være et tal mellem 1 og 65535
Configuration_Error9 Brugergrænsefladeport kan ikke have samme værdi som POP3 lytteport
Configuration_Error10 POP3 lytteport kan ikke have samme værdi som brugergrænsefladeport
Configuration_Fields Historikkolonner
Configuration_NNTPFork Tillad samtidige NNTP-forbindelser
Configuration_POPFork Tillad samtidige POP3-forbindelser
Configuration_SMTPFork Tillad samtidige SMTP-forbindelser
Configuration_SOCKSPort SOCKS V proxy-port
Configuration_SOCKSPortUpdate SOCKS V proxy-port opdateret til %s
Configuration_SOCKSServer SOCKS V proxy-vært
Configuration_SOCKSServerUpdate SOCKS V proxy-vært opdateret til %s
Help_Bucket_Setup POPFile kræver mindst to kategorier ud over pseudo-kategorien "uklassificeret". Det der gør POPFile unikt er, at det kan klassificere e-mail i mere end det; du kan have et vilkårligt antal kategorier. En simpel opsætning ville være en "spam"-, "personlig"- og "arbejds"-kategori.
Help_No_More Vis ikke dette igen
Help_Training Når du bruger POPFile første gang, ved det ingenting og har brug for træning. POPFile kræver træning med beskeder for hver kategori; træning sker, når du omklassificerer en besked, som POPFile har klassificeret forkert, til den korrekte kategori. Før POPFile klassificerer den første besked, skal du have omklassificeret beskeder til mindst to kategorier.
History_AllBuckets Alle kategorier
History_Automatic Automatisk
History_ChangedClass Ville nu klassificere som
History_Column_Characters Skift bredde af Fra, Til, Cc og Emne-kolonner
History_Decrease Mindsk
History_HighlightWords Fremhæv ord efter kategori
History_Increase Forøg
History_Loading Indlæser...
History_MagnetBecause <b>Magnet brugt</b><p>Klassificeret til <font color="%s">%s</font> på grund af magnet %s </p>
History_MoveTo — flyt til —
History_Moving Flytter...
History_Negate_Search Inverter søgning/filter
History_NoMagnet &nbsp;(viser kun ikke-magnet-klassificerede beskeder)
History_NoMatchingMessages Ingen matchende beskeder
History_Purge Udløb nu
History_Reclassified Omklassificeret
History_Reclassifying Omklassificerer...
History_ReclassifyUnclassified Omklassificer uklassificerede
History_RemoveChecked Fjern markerede
History_Selected valgt(e)
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
Imap_Bucket2Folder Post for kategori '<b>%s</b>' går til mappe
Imap_BucketFolderMappings Kategori -> Mappetildelinger
Imap_Bytelimit Bytes per besked til klassificering. Indtast 0 for den komplette besked:
Imap_BytelimitError Angiv venligst et tal.
Imap_Connected Forbundet
Imap_Connection Forbindelse
Imap_ConnectionFailed Forbindelsen mislykkedes
Imap_Description Overvåg IMAP-mapper og klassificer automatisk indgående beskeder.
Imap_EnableService Aktivér IMAP-tjeneste
Imap_Expunge Slet slettede beskeder fra overvågede mapper.
Imap_FetchFolders Hent mapper
Imap_Fetching Henter...
Imap_IMAFFolder IMAP-mappe
Imap_Interval Opdateringsinterval i sekunder:
Imap_IntervalError Angiv venligst et interval mellem 10 og 3600 sekunder.
Imap_Login IMAP-konto login:
Imap_LoginError Angiv venligst et bruger-/loginnavn!
Imap_MapError Du kan ikke tilknytte mere end én kategori til en enkelt mappe!
Imap_MappingsHint Klassificerede beskeder flyttes til den angivne IMAP-mappe. Lad ikke-tilknyttede kategorier være tomme for at springe flytning over.
Imap_NoConnectionMessage Konfigurer venligst forbindelsesdetaljerne først. Derefter vil der være flere muligheder tilgængelige på denne side.
Imap_NoFoldersWatched Ingen mapper overvåget endnu.
Imap_NoMappings Ingen tildelinger defineret.
Imap_Now nu!
Imap_Password Adgangskode til IMAP-konto:
Imap_PasswordError Angiv venligst en adgangskode til serveren!
Imap_Port IMAP-serverport:
Imap_PortError Angiv venligst et gyldigt portnummer!
Imap_RefreshFolders Opdater mappeliste
Imap_SaveAnyway Gem alligevel
Imap_SaveConnection Gem forbindelse
Imap_SaveFolders Gem mapper
Imap_Saving Gemmer...
Imap_Server IMAP-server værtsnavn:
Imap_ServerNameError Angiv venligst serverens værtsnavn!
Imap_Service Tjeneste
Imap_TestConnection Test forbindelse
Imap_Testing Tester...
Imap_TrainingHint Træningstilstand gennemgår eksisterende arkivmapper og træner klassificereren på deres indhold. Flaget nulstilles automatisk, når træningen er færdig.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Træningstilstand
Imap_TrainingLimit Beskeder pr. mappe (0 = ubegrænset)
Imap_UpdateError1 Kunne ikke logge ind. Kontroller venligst dit loginnavn og adgangskode.
Imap_UpdateError2 Forbindelsen til serveren mislykkedes. Kontroller venligst værtsnavn og port, og sørg for at du er online.
Imap_UpdateError3 Konfigurer venligst forbindelsesdetaljerne først.
Imap_Use_SSL Brug SSL
Imap_WatchedFolder Overvåget mappe nr.
Imap_WatchedFolders Overvågede mapper
Imap_WatchedHint POPFile overvåger disse IMAP-mapper for nye beskeder at klassificere.
Imap_WatchMore en mappe til listen over overvågede mapper

WordView_Title Ordnøjagtighed
WordView_SelectBucket vælg kategori
WordView_Words ord
WordView_Loading Indlæser...
WordView_Empty Ingen ord i denne kategori.
WordView_ColWord Ord
WordView_ColCount Antal
WordView_ColTotal Total
WordView_ColAccuracy Nøjagtighed
WordView_ColActions Handlinger
WordView_Remove Fjern
WordView_MoveTo flyt til
WordView_Move Flyt
Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magnet oprettet
Magnet_Deleted Magnet slettet
Magnet_Jump Gå til magnetside
Reconnect_Connecting Forbinder...
Reconnect_Message Backend er ikke tilgængeligt. Forsøger at genoprette forbindelsen...
Reconnect_Now Genoprette forbindelsen nu
Reconnect_RetryIn Prøver igen om
Reconnect_Title Forbindelsen mistet
Security_StealthMode (Stealth-tilstand)
Settings_AdminPassword Administratoradgangskode
Settings_ArchiveDirectory Arkivmappe
Settings_ArchiveMessages Arkiver beskeder
Settings_ArchiveSubdirs Arkiv-undermapper
Settings_AutoDetect Automatisk registrering
Settings_AutoDetectLanguage Registrer sprog automatisk
Settings_ChainPort Kædeport
Settings_ChainServer Kædeserver
Settings_DateFormat Datoformat
Settings_DescAdminPassword Lad tomt for at deaktivere adgangskodebeskyttelse.
Settings_DescArchiveDir Mappe til arkiverede beskeder (relativ til brugermappe).
Settings_DescArchiveMessages Gem en kopi af hver klassificeret besked på disk.
Settings_DescArchiveSubdirs Del arkiv i N undermapper (0 = deaktiveret).
Settings_DescAutoDetectLang Registrerer sproget i hver besked og anvender tilsvarende stopord og stemmer. Tilføjer ~130% klassificeringsforsinkelse; nyttigt til flersprogede postkasser.
Settings_DescChainPort Port for den overordnede SMTP-server.
Settings_DescChainServer Værtsnavn for den overordnede SMTP-server.
Settings_DescDateFormat strftime-formatstreng. Lad tomt for locale-standard.
Settings_DescForceFork Opret en ny proces for hver forbindelse.
Settings_DescHEADFetchesBody Hent komplet artikel med HEAD-kommandoen.
Settings_DescHTTPPort Port som webgrænsefladen lytter på. Kræver genstart.
Settings_DescItemsPerPage Rækker vist per side i Historik og Magneter.
Settings_DescLanguage Visningssprog for grænsefladen. Lad tomt for automatisk registrering fra browser.
Settings_DescListenAddress IP-adresse at binde til. Tom = alle grænseflader.
Settings_DescLocalOnly_UI Begræns webgrænsefladen til lokale forbindelser.
Settings_DescLogDirectory Mappe til logfiler. Tom = POPFile-rod.
Settings_DescLogLevel Uddybning af loguddata.
Settings_DescLogSQLToStdout Udskriv hver SQL-sætning med bundne værdier til stdout. Kun aktiv når "Log til stdout" også er aktiveret.
Settings_DescLogToStdout Spejl loguddata til stdout udover logfilen.
Settings_DescMessageCutoff Maksimalt antal analyserede ord per besked (0 = ubegrænset).
Settings_DescNNTPLocalOnly Acceptér kun NNTP-forbindelser fra localhost.
Settings_DescNNTPPort Port som POPFile lytter på for NNTP (standard 119).
Settings_DescNNTPSeparator Tegn der adskiller bruger fra server.
Settings_DescPOP3LocalOnly Acceptér kun POP3-forbindelser fra localhost.
Settings_DescPOP3Port Port som POPFile lytter på for POP3 (standard 1110).
Settings_DescPOP3Separator Tegn der adskiller bruger fra server (f.eks. bruger:mailhost).
Settings_DescRetentionDays Hvor mange dage beskederhistorik bevares.
Settings_DescSessionDividers Vis skillelinjer mellem browsersessioner i Historik.
Settings_DescSMTPLocalOnly Acceptér kun SMTP-forbindelser fra localhost.
Settings_DescSMTPPort Port som POPFile lytter på for SMTP (standard 25).
Settings_DescSQLiteJournal SQLite-journal / WAL-tilstand.
Settings_DescSQLiteTweaks Bitmaske: 1 = hurtigere skrivninger (mindre sikker), 2 = periodisk sikkerhedskopi.
Settings_DescSSLChainPort Port for den overordnede SSL POP3-server.
Settings_DescSSLChainServer Værtsnavn for den overordnede SSL POP3-server til SSL-kæde.
Settings_DescSubjectTagLeft Præfiks indsat i emne-headeren, f.eks. [SPAM].
Settings_DescSubjectTagRight Suffiks tilføjet til emne-headeren.
Settings_DescTagPosition Hvor emnemærkaten placeres.
Settings_DescTOPFetchesBody Hent også beskedindhold med TOP-kommandoen.
Settings_DescUnclassifiedWeight Sandsynlighedsgrænse under hvilken post er "uklassificeret".
Settings_DescWordStemming Reducer ord til deres stamme før klassificering (f.eks. "løber" til "løb"). Forbedrer recall for morfologisk rige sprog med ~10% forsinkelsesomkostning.
Settings_DescWordTable Hvad der vises i ordssandsynlighedstabellen.
Settings_ErrorSaving Fejl ved gemning
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD henter indhold
Settings_HTTPPort HTTP-port
Settings_ItemsPerPage Elementer per side
Settings_ListenAddress Lytteadresse
Settings_ListenPort Lytteport
Settings_LocalOnly Kun lokalt
Settings_LogDirectory Logmappe
Settings_LogLevel Logniveau
Settings_LogSQLToStdout Log SQL til stdout
Settings_LogToStdout Log til stdout
Settings_MessageCutoff Beskedergrænse
Settings_OptDebug Fejlsøgning
Settings_OptEnd Slut
Settings_OptErrorsOnly Kun fejl
Settings_OptFrequencies Frekvenser
Settings_OptFront Forside
Settings_OptHidden Skjult
Settings_OptInfo Info
Settings_OptLogScores Log scorer
Settings_OptProbabilities Sandsynligheder
Settings_OptWarnings Advarsler
Settings_RetentionDays Opbevaring (dage)
Settings_SaveChanges Gem ændringer
Settings_Saved Gemt
Settings_Saving Gemmer...
Settings_Search Søg i indstillinger...
Settings_SectionClassifier Klassifikatoren
Settings_SectionHistory Historik
Settings_SectionLogging Logning
Settings_SectionNNTP NNTP-proxy
Settings_SectionPOP3 POP3-proxy
Settings_SectionSecurity Sikkerhed
Settings_SectionSMTP SMTP-proxy
Settings_SectionUI Brugergrænseflade
Settings_ServerSeparator Serveradskillertegn
Settings_SessionDividers Sessionsskillere
Settings_SQLiteJournalMode SQLite-journaltilstand
Settings_SQLiteTweaks SQLite-justeringer
Settings_SSLChainPort SSL-kædeport
Settings_SSLChainServer SSL-kædeserver
Settings_SubjectTagLeft Emnemærkat venstre
Settings_SubjectTagRight Emnemærkat højre
Settings_TagPosition Mærkatplacering
Settings_TOPFetchesBody TOP henter indhold
Settings_UnclassifiedWeight Uklassificeret vægt
Settings_WordStemming Ordstemming
Settings_WordTable Ordtabel
SingleBucket_ClearBucket Fjern alle ord
Status_Checking Kontrollerer...
Status_Description Statuskontroller for POPFile-tjenester.
Status_LoadError Kunne ikke indlæse status
Status_NoChecks Ingen kontroller tilgængelige.
View_Chart Beslutningsdiagram
View_DownloadMessage Download besked
View_MessageBody Beskedindhold
View_MessageHeader Beskeddheader
View_ShowFrequencies Vis ordfrekvenser
View_ShowProbabilities Vis ordsandsynligheder
View_ShowScores Vis ordscorer og beslutningsdiagram
View_Title Enkelt beskedvisning
View_WordFrequencies viser ordfrekvenser
View_WordMatrix Ordmatrix
View_WordProbabilities viser ordsandsynligheder
View_WordScores viser ordscorer
Windows_Console Kør POPFile i et konsolvindue?
Windows_NextTime <p><font color="red">Denne ændring træder ikke i kraft, før næste gang du starter POPFile</font>
Windows_TrayIcon Vis POPFile-ikonet i Windows systembakke?

Advanced_AllParameters Alle POPFile-parametre
Advanced_ConfigFile Konfigurationsfil:
Advanced_Parameter Parameter
Advanced_Value Værdi
Advanced_Warning Dette er den komplette liste over POPFile-parametre. Kun til avancerede brugere: du kan ændre enhver og klikke Opdater; der er ingen gyldighed-kontrol. Elementer vist med fed er ændret fra standardindstillingen.

Language_Name                           Dansk
History_PerPage                          Per page:
Imap_Advanced                            Advanced
Imap_Cancel                              Cancel
Imap_Wizard                              Setup Wizard
Imap_WizardApply                         Create & map
Imap_WizardClose                         Close
Imap_WizardDesc                          Select folders to create buckets and mappings for.
Imap_WizardDeselectAll                   Deselect all
Imap_WizardDone                          {count} bucket(s) created and mapped.
Imap_WizardEmpty                         No additional folders found on the server.
Imap_WizardSelectAll                     Select all
Imap_WizardTrain                         Train now
NavWordSearch                            Words & Stopwords
Settings_DescEnableProxy                 Start this proxy listener when POPFile starts.
Settings_DescLogFormat                   Log line format. Use 'plain' for journald or any environment that adds its own timestamps.
Settings_DescOpenBrowser                 Open the default browser when the web UI is ready.
Settings_DescSQLiteBackup                Copy the database to a .backup file every hour.
Settings_DescSQLiteFastWrites            Disable SQLite write-ahead sync for faster inserts. Risks minor data loss on crash.
Settings_EnableService                   Enable service
Settings_LogFormat                       Log Format
Settings_OpenBrowser                     Open browser on start
Settings_SQLiteBackup                    SQLite: periodic backup
Settings_SQLiteFastWrites                SQLite: fast writes (less safe)
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   + Stopword
WordSearch_ColumnBuckets                 Buckets
WordSearch_ColumnWord                    Word
WordSearch_Coverage                      coverage
WordSearch_IsStopword                    stopword
WordSearch_Loading                       Loading...
WordSearch_NoResults                     No words found.
WordSearch_NoStopwords                   No stopwords defined.
WordSearch_Placeholder                   prefix...
WordSearch_RemoveStopword                Stopword
WordSearch_Search                        Search
WordSearch_StopwordList                  Stopwords
WordSearch_Title                         Word Search
WordSearch_Total                         words
