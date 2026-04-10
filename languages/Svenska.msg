# Copyright (c) 2003-2011 John Graham-Cumming
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

# This is used to get the appropriate subdirectory for the manual

LanguageCode				sv
LanguageCharset				ISO-8859-1
LanguageDirection                       ltr

# Common words that are used on their own all over the interface
Apply                                   Verkställ
On                                      On
Off                                     Off
TurnOn                                  Sätt på
TurnOff                                 Stäng av
Add                                     Lägg till
Remove                                  Ta bort
Previous                                Föregående
Next                                    Nästa
From                                    Från
Subject                                 Ämne
Classification                          Klassifikation
Reclassify                              Reklassifikation
Undo                                    Ångra
Close                                   Stäng av server
Find                                    Sök
Filter                                  Filter
Yes                                     Ja
No                                      Nej
ChangeToYes                             Ändra till Ja
ChangeToNo                              Ändra till Nej
Bucket                                  Hink
Magnet                                  Magnet
Delete                                  Ta bort
Create                                  Skapa
To                                      Till
Total                                   Totalt
Rename                                  Döp om
Frequency                               Frekvens
Probability                             Sannolikhet
Score                                   Resultat
Lookup                                  Leta efter

# The header and footer that appear on every UI page
Header_Title                            Kontrollpanel
Header_Shutdown                         Stäng
Header_History                          Historia
Header_Buckets                          Hinkar
Header_Configuration                    Konfiguration
Header_Advanced                         Avancerat
Header_Security                         Säkerhet
Header_Magnets                          Magneter

Footer_HomePage                         Hem
Footer_Manual                           Manual
Footer_Forums                           Forum
Footer_FeedMe                           Återkoppling
Footer_RequestFeature                   Föreslå funktioner
Footer_MailingList                      Mailinglistor

Configuration_Error1                    Det avskiljande tecknet kan bara vara ett tecken.
Configuration_Error2                    Webgränssnittets post måste vara ett tal mellan 1 och 65535
Configuration_Error3                    POP3 porten måste vara ett tal mellan 1 och 65535
Configuration_Error4                    Sidans storlek måste vara ett tal mellan 1 och 1000
Configuration_Error5                    Antal dagar i 'histora' måste vara ett tal mellan 1 och 366
Configuration_Error6                    TCP timeout måste vara ett tal mellan 10 och 1800
Configuration_POP3Port                  POP3 port
Configuration_POP3Update                Uppdaterade porten till %s; denna ändring kommer inte att gälla förrän servern är omstartad.
Configuration_Separator                 Avskiljare
Configuration_SepUpdate                 Uppdaterade det avskiljande tecknet till %s
Configuration_UI                        Webgränssnittets HTTP port
Configuration_UIUpdate                  Uppdaterade webgränssnittets HTTP port till %s; denna ändring kommer inte att gälla förrän servern är omstartad.
Configuration_History                   Antal epost per sida
Configuration_HistoryUpdate             Uppdaterede antal email per sida till %s
Configuration_Days                      Antal dagar histora skall behållas
Configuration_DaysUpdate                Uppdaterede antal dagar histora skall sparas: %s
Configuration_UserInterface             Gränssnitt
Configuration_Skins                     Utseende ytan
Configuration_SkinsChoose               Välj tema
Configuration_Language                  Språk
Configuration_LanguageChoose            Välj språk
Configuration_ListenPorts               POP3
Configuration_HistoryView               Formatera 'Historia' vyn
Configuration_TCPTimeout                TCP förbindelsens timeout
Configuration_TCPTimeoutSecs            TCP förbindelsens timeout i sekunder
Configuration_TCPTimeoutUpdate          Updatera TCP förbindelsens timeout till %s
Configuration_ClassificationInsertion   Klassifikation epost headers
Configuration_SubjectLine               Ämnesrad modifiering
Configuration_XTCInsertion              X-Text-Klassification insättning
Configuration_XPLInsertion              X-POPFile-Länk insättning
Configuration_Logging                   Logging
Configuration_None                      Ingen
Configuration_ToScreen                  Till skärm
Configuration_ToFile                    Till fil
Configuration_ToScreenFile              Till skärm och fil
Configuration_LoggerOutput              Loggning utdata

Advanced_Error1                         '%s' finns redan i stoppord listan
Advanced_Error2                         Stoppord kan bara innehålla alfanumeriska tecken, ., _, -, eller @ tegn
Advanced_Error3                         '%s' är lagt till stopordlistan
Advanced_Error4                         '%s' finns inte i stoppordlistan
Advanced_Error5                         '%s' är borttaget från stoppordlistan
Advanced_StopWords                      Stoppord
Advanced_Message1                       Följande ord ignoreras av klassifikationen eftersom de förekommer ofta.
Advanced_AddWord                        Lägg till ord
Advanced_RemoveWord                     Ta bort ord

History_Filter                          &nbsp;(visa bara spannet <font color=%s>%s</font>)
History_Search                          &nbsp;(sök ämne för %s)
History_Title                           Historia
History_Jump                            Spring til besked
History_ShowAll                         Visa alla
History_ShouldBe                        skulle vara
History_NoFrom                          inget från rad
History_NoSubject                       iget ämne rad
History_ClassifyAs                      klassificerat som
History_MagnetUsed                      Magnet använd
History_ChangedTo                       Ändrat till <font color=%s>%s
History_Already                         Redan reklassificerat som <font color=%s>%s</font>
History_RemoveAll                       Ta bort alla
History_RemovePage                      Ta bort sida
History_Remove                          för att ta bort historia
History_SearchMessage                   Sök ämne
History_NoMessages                      Inga meddelanden

Password_Title                          Lösenord
Password_Enter                          Indtast kodeord
Password_Go                             Go!
Password_Error1                         Fel lösenord

Security_Error1                         Den säkra porten måste vara ett tal mellan 1 och 65535
Security_Stealth                        Server körläge
Security_NoStealthMode                  Nej (Lokalt läge)
Security_ExplainStats                   (Data används för att förbättra servern)
Security_ExplainUpdate                  (Om uppdatering finns tillgänglig kommer en logotyp att visas på sidan)
Security_PasswordTitle                  Lösenord till webgränssnittet
Security_Password                       Lösenord
Security_PasswordUpdate                 Uppdaterar lösenord till %s
Security_AUTHTitle                      Lösenord för epostkonto med extra autentisering
Security_SecureServer                   Server
Security_SecureServerUpdate             Uppdaterade servern till %s; denna ändring kommer inte att träda i kraft förrän servern är omstartad
Security_SecurePort                     Port
Security_SecurePortUpdate               Uppdaterade porten till  %s; denna ändring kommer inte att träda i kraft förrän servern är omstartad 
Security_POP3                           Acceptera anslutningar till POP3 från externa källa
Security_UI                             Acceptera HTTP anslutningar från extern källa
Security_UpdateTitle                    Automatisk uppdatering
Security_Update                         Sök efter uppdateringar varje dag
Security_StatsTitle                     Statistikrapportering
Security_Stats                          Skicka statistik till programmets skapare dagligen

Magnet_Error1                           Magnet '%s' finns redan i '%s' 
Magnet_Error2                           Det nya statiska filtret '%s' kommer i konflikt med det statiska filtret '%s' i '%s' och kan skapa tvetydiga resultat. Det nya statiska filtret skapades inte.
Magnet_Error3                           Skapade ny magnet '%s' i '%s'
Magnet_CurrentMagnets                   Aktuella magneter
Magnet_Message1                         Följande magneter garanterar att email alltid hamnar i en viss hink.
Magnet_CreateNew                        Skapa ny magnet
Magnet_Explanation                      Tre typer av magneter är tillgängliga: <ul><li>Från adressen eller namnet:</b> Till exempel: test@företag.se för att matcha en specifik adress, <br>företag.se för att matcha alla avsändare från företaget, <br>John Doe för att matcha en specifik person, John för att matcha alla Johns<li><b>Till adressen eller namnet:</b> Liksom ovan men för to: eller till: -raden. <li><b>Ämnet:</b> Till exempel: Hej! för att matcha alla 'Hej!' i ämnesraden.</ul>
Magnet_MagnetType                       Magnettyper
Magnet_Value                            Värden
Magnet_Always                           Tillhör alltid magneten

Bucket_Error1                           Hinkens namn kan bara innehålla bokstäverna a till z (små bokstäver) samt - och _
Bucket_Error2                           Hinken med namnet %s finns redan
Bucket_Error3                           Upprätta hink med namnet %s
Bucket_Error4                           Var god fyll i ett ord
Bucket_Error5                           Döp inte om hinken %s till %s
Bucket_Error6                           Tog bort hinken %s
Bucket_Title                            Överblick
Bucket_BucketName                       Hinkens namn
Bucket_WordCount                        Antal
Bucket_WordCounts                       Fördelning av ord
Bucket_UniqueWords                      Unika ord
Bucket_SubjectModification              Ämnesrad modifiering
Bucket_ChangeColor                      Byt färg
Bucket_NotEnoughData                    Finns inte data
Bucket_ClassificationAccuracy           Klassifikationens exakthet
Bucket_EmailsClassified                 Antal email
Bucket_EmailsClassifiedUpper            Antal email
Bucket_ClassificationErrors             Antal fel
Bucket_Accuracy                         Exakthet
Bucket_ClassificationCount              Antal klassificeringar
Bucket_ResetStatistics                  Nollställ statistiken
Bucket_LastReset                        Förra nollställningen
Bucket_CurrentColor                     %s nuvarande färg är %s
Bucket_SetColorTo                       Sätt %s färgen till %s
Bucket_Maintenance                      Hantering
Bucket_CreateBucket                     Skapa hink med namnet
Bucket_DeleteBucket                     Ta bort hink med namnet
Bucket_RenameBucket                     Döp om hink
Bucket_Lookup                           Hitta
Bucket_LookupMessage                    Hitta ord i hink
Bucket_LookupMessage2                   Hitta för
Bucket_LookupMostLikely                 Det är mest sannolikt att <b>%s</b> kommer att visas i <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> kommer inte att visas i någon hink
Bucket_DisabledGlobally                 Deaktivera globalt
Bucket_To					    till
Bucket_Quarantine                       Karantän

SingleBucket_Title                      Fler detaljer för %s
SingleBucket_WordCount                  Totalt antal ord i hinken
SingleBucket_TotalWordCount             Totalt antal ord
SingleBucket_Percentage                 Procent
SingleBucket_WordTable                  Ordtabell för %s
SingleBucket_Message1                   Markerat (*) ord har använts till klassifiering i denna sessionen. Tryck på ett ord för att visa dess sannolikhet i alla hinkar.
SingleBucket_Unique                     %s unique

Session_Title				Sessionen har gått ut
Session_Error				Din session har gått ut. Detta kan ha orsakats genom att starta och stänga av servern medan webläsaren har förblivit öppen. Klicka på en av länkarna ovan för att fortsätta använda webgränsnittet.
# New keys added (translations batch 2)
LanguageCharset ISO-8859-1
LanguageDirection ltr
ManualLanguage sv
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpus
NavHistory Historik
NavIMAP IMAP
NavMagnets Magneter
NavSettings Inställningar
NavStatus Status
Corpus_BucketList Kategorier
Corpus_Color Färg
Corpus_Actions Åtgärder
Corpus_Clear Rensa
Corpus_Search Sök
Corpus_StopwordsTitle Stoppord
Corpus_StopwordsDesc Ord i den här listan används aldrig för klassificering.
Corpus_RemoveStopword Ta bort
Corpus_StopwordCandidates Stoppordskandidater
Corpus_StopwordCandidatesDesc Ord som förekommer jämnt i alla kategorier — liten diskriminerande kraft.
Corpus_StopwordRatio Tröskel för max/min-förhållande
Corpus_LoadCandidates Hitta kandidater
Corpus_NoCandidates Inga kandidater hittades vid detta tröskelvärde.
Corpus_AddStopword Lägg till i stoppord
BucketSelect_AddNew Lägg till ny...
BucketSelect_AlreadyExists Finns redan
BucketSelect_CreateError Fel vid skapande av kategori
BucketSelect_InvalidName Endast a-z, 0-9, - och _
BucketSelect_NameRequired Namn krävs
Bucket_InIgnoredWords <b>%s</b> finns i ignorerade ord. POPFile ignorerar detta ord
Bucket_ClassificationFN Falskt negativa
Bucket_ClassificationFP Falskt positiva
Bucket_AccuracyChartSummary Den här tabellen visar grafiskt noggrannheten i meddelandeklassificeringen.
Bucket_BarChartSummary Den här tabellen visar grafiskt en procentuell fördelning för var och en av de olika kategorierna.
Bucket_LookupResultsSummary Den här tabellen visar sannolikheterna för ett givet ord i korpusen.
Bucket_MainTableSummary Den här tabellen ger en översikt över klassificeringskategorierna.
Bucket_MaintenanceTableSummary Den här tabellen innehåller formulär för att skapa, ta bort eller byta namn på kategorier.
Bucket_StatisticsTableSummary Den här tabellen tillhandahåller tre uppsättningar statistik om POPFiles övergripande prestanda.
Bucket_WordListTableSummary Den här tabellen visar alla ord för en viss kategori.
Advanced_MainTableSummary Den här tabellen innehåller en lista med ord som POPFile ignorerar vid klassificering av meddelanden.
ApplyChanges Tillämpa ändringar
Arrived Mottaget
Cc Kopia
Count Antal
Date Datum
FAQ FAQ
Footer_Wiki Dokumentation
Header_MenuSummary Den här tabellen är navigeringsmenyn som ger tillgång till var och en av de olika sidorna i kontrollcentret.
ID ID
Probability Sannolikhet
QuickMagnets SnabbMagneter
Refresh Uppdatera
Scores Poäng
Shutdown_Message POPFile har stängts ned
Size Storlek
Update Uppdatera
Word Ord
Configuration_CurrentLogFile &lt;Visa aktuell loggfil&gt;
Configuration_Error7 XML RPC-lyssningsporten måste vara ett tal mellan 1 och 65535
Configuration_Error8 SOCKS V-proxyport måste vara ett tal mellan 1 och 65535
Configuration_Error9 Användargränssnittsporten kan inte ha samma värde som POP3-lyssningsporten
Configuration_Error10 POP3-lyssningsporten kan inte ha samma värde som användargränssnittsporten
Configuration_Fields Historikkolumner
Configuration_GeneralSkins Teman
Configuration_InsertionTableSummary Den här tabellen innehåller knappar för att bestämma om vissa ändringar görs i meddelandets rubriker eller ämnesrad.
Configuration_MainTableSummary Den här tabellen innehåller ett antal formulär för att styra konfigurationen av POPFile.
Configuration_NNTPFork Tillåt simultana NNTP-anslutningar
Configuration_NNTPPort NNTP-lyssningsport
Configuration_NNTPSeparator NNTP-värddator:port:användare-separatortecken
Configuration_NNTPSepUpdate NNTP-separator uppdaterad till %s
Configuration_NNTPUpdate NNTP-port uppdaterad till %s; ändringen träder i kraft efter omstart av POPFile
Configuration_POP3Separator POP3-värddator:port:användare-separatortecken
Configuration_POP3SepUpdate POP3-separator uppdaterad till %s
Configuration_POPFork Tillåt simultana POP3-anslutningar
Configuration_SmallSkins Små teman
Configuration_SMTPFork Tillåt simultana SMTP-anslutningar
Configuration_SMTPPort SMTP-lyssningsport
Configuration_SMTPUpdate SMTP-port uppdaterad till %s; ändringen träder i kraft efter omstart av POPFile
Configuration_SOCKSPort SOCKS V-proxyport
Configuration_SOCKSPortUpdate SOCKS V-proxyport uppdaterad till %s
Configuration_SOCKSServer SOCKS V-proxyvärd
Configuration_SOCKSServerUpdate SOCKS V-proxyvärd uppdaterad till %s
Configuration_TinySkins Minimala teman
Configuration_XMLRPCPort XML-RPC-lyssningsport
Configuration_XMLRPCUpdate XML-RPC-port uppdaterad till %s; ändringen träder i kraft efter omstart av POPFile
Help_Bucket_Setup POPFile kräver minst två kategorier förutom pseudo-kategorin "oklassificerat". Det som gör POPFile unikt är att det kan klassificera e-post i mer än det; du kan ha valfritt antal kategorier. En enkel konfiguration skulle vara en "skräppost"-, "personlig"- och "arbets"-kategori.
Help_No_More Visa inte detta igen
Help_Training När du använder POPFile för första gången vet det ingenting och behöver träning. POPFile kräver träning med meddelanden för varje kategori; träning sker när du omklassificerar ett meddelande som POPFile felklassificerade till rätt kategori. Innan POPFile klassificerar det första meddelandet måste du ha omklassificerat meddelanden till minst två kategorier.
History_AllBuckets Alla kategorier
History_Automatic Automatisk
History_ChangedClass Skulle nu klassificera som
History_Column_Characters Ändra bredd på Från, Till, Kopia och Ämne-kolumner
History_Decrease Minska
History_FilterBy Filtrera efter
History_HighlightWords Markera ord efter kategori
History_Increase Öka
History_Loading Läser in...
History_Magnet &nbsp;(visar endast magnetklassificerade meddelanden)
History_MainTableSummary Den här tabellen visar avsändare och ämne för nyligen mottagna meddelanden.
History_MagnetBecause <b>Magnet använd</b><p>Klassificerat till <font color="%s">%s</font> på grund av magnet %s </p>
History_MoveTo — flytta till —
History_Moving Flyttar...
History_Negate_Search Invertera sökning/filter
History_NoMagnet &nbsp;(visar endast icke-magnetklassificerade meddelanden)
History_NoMatchingMessages Inga matchande meddelanden
History_OpenMessageSummary Den här tabellen innehåller den fullständiga texten i ett meddelande med ord markerade.
History_Purge Utlöp nu
History_Reclassified Omklassificerat
History_Reclassifying Omklassificerar...
History_ReclassifyUnclassified Omklassificera oklassificerade
History_RemoveChecked Ta bort markerade
History_ResetSearch Återställ
History_Selected valda
History_ShowMagnet magnetiserat
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
Imap_Bucket2Folder Post för kategori '<b>%s</b>' går till mapp
Imap_BucketFolderMappings Kategori -> Mapptilldelningar
Imap_Bytelimit Byte per meddelande för klassificering. Ange 0 för hela meddelandet:
Imap_BytelimitError Ange ett tal.
Imap_Connected Ansluten
Imap_Connection Anslutning
Imap_ConnectionFailed Anslutning misslyckades
Imap_Description Övervaka IMAP-mappar och klassificera automatiskt inkommande meddelanden.
Imap_EnableService Aktivera IMAP-tjänst
Imap_Expunge Ta bort raderade meddelanden från övervakade mappar.
Imap_FetchFolders Hämta mappar
Imap_Fetching Hämtar...
Imap_IMAFFolder IMAP-mapp
Imap_Interval Uppdateringsintervall i sekunder:
Imap_IntervalError Ange ett intervall mellan 10 och 3600 sekunder.
Imap_Login IMAP-konto inloggning:
Imap_LoginError Ange ett användar-/inloggningsnamn!
Imap_MapError Du kan inte mappa mer än en kategori till en enskild mapp!
Imap_MappingsHint Klassificerade meddelanden flyttas till den angivna IMAP-mappen. Lämna omappad kategorier tomma för att hoppa över flytt.
Imap_NoConnectionMessage Konfigurera anslutningsdetaljerna först. Sedan finns fler alternativ på den här sidan.
Imap_NoFoldersWatched Inga mappar övervakas ännu.
Imap_NoMappings Inga tilldelningar definierade.
Imap_Now nu!
Imap_Password Lösenord för IMAP-konto:
Imap_PasswordError Ange ett lösenord för servern!
Imap_Port IMAP-serverport:
Imap_PortError Ange ett giltigt portnummer!
Imap_RefreshFolders Uppdatera mapplista
Imap_SaveAnyway Spara ändå
Imap_SaveConnection Spara anslutning
Imap_SaveFolders Spara mappar
Imap_Saving Sparar...
Imap_Server IMAP-server värdnamn:
Imap_ServerNameError Ange serverns värdnamn!
Imap_Service Tjänst
Imap_TestConnection Testa anslutning
Imap_Testing Testar...
Imap_TrainingHint Träningsläget söker igenom befintliga arkivmappar och tränar klassificeraren på deras innehåll. Flaggan återställs automatiskt när träningen är klar.
Imap_TrainingMode Träningsläge
Imap_UpdateError1 Kunde inte logga in. Kontrollera användarnamn och lösenord.
Imap_UpdateError2 Anslutning till server misslyckades. Kontrollera värdnamn och port och se till att du är online.
Imap_UpdateError3 Konfigurera anslutningsdetaljerna först.
Imap_Use_SSL Använd SSL
Imap_WatchedFolder Övervakad mapp nr.
Imap_WatchedFolders Övervakade mappar
Imap_WatchedHint POPFile övervakar dessa IMAP-mappar för nya meddelanden att klassificera.
Imap_WatchMore en mapp till listan med övervakade mappar
Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magnet skapad
Magnet_Deleted Magnet borttagen
Magnet_Jump Gå till magnetsida
Magnet_MainTableSummary Den här tabellen visar listan med magneter som används för att automatiskt klassificera meddelanden.
Reconnect_Connecting Ansluter...
Reconnect_Message Backend är inte nåbart. Försöker återansluta...
Reconnect_Now Återanslut nu
Reconnect_RetryIn Försöker igen om
Reconnect_Title Anslutning förlorad
Security_MainTableSummary Den här tabellen tillhandahåller kontroller som påverkar säkerheten i den övergripande konfigurationen av POPFile.
Security_NNTP Acceptera NNTP-anslutningar från fjärrmaskiner (kräver omstart av POPFile)
Security_SMTP Acceptera SMTP-anslutningar från fjärrmaskiner (kräver omstart av POPFile)
Security_SMTPPort SMTP-kedjansport
Security_SMTPPortUpdate SMTP-kedjansport uppdaterad till %s; ändringen träder i kraft efter omstart av POPFile
Security_SMTPServer SMTP-kedjansserver
Security_SMTPServerUpdate SMTP-kedjansserver uppdaterad till %s; ändringen träder i kraft efter omstart av POPFile
Security_StealthMode (Stealthläge)
Security_XMLRPC Acceptera XML-RPC-anslutningar från fjärrmaskiner (kräver omstart av POPFile)
Settings_AdminPassword Administratörslösenord
Settings_ArchiveDirectory Arkivkatalog
Settings_ArchiveMessages Arkivera meddelanden
Settings_ArchiveSubdirs Arkiv-underkataloger
Settings_AutoDetect Autoidentifiering
Settings_AutoDetectLanguage Identifiera språk automatiskt
Settings_ChainPort Kedjansport
Settings_ChainServer Kedjansserver
Settings_DateFormat Datumformat
Settings_DescAdminPassword Lämna tomt för att inaktivera lösenordsskydd.
Settings_DescArchiveDir Katalog för arkiverade meddelanden (relativt till användarkatalog).
Settings_DescArchiveMessages Spara en kopia av varje klassificerat meddelande på disk.
Settings_DescArchiveSubdirs Dela arkiv i N underkataloger (0 = inaktiverat).
Settings_DescAutoDetectLang Identifierar språket i varje meddelande och tillämpar matchande stoppord och stemmer. Lägger till ~130% klassificeringsfördröjning; användbart för flerspråkiga postlådor.
Settings_DescChainPort Port för den överordnade SMTP-servern.
Settings_DescChainServer Värdnamn för den överordnade SMTP-servern.
Settings_DescDateFormat strftime-formatsträng. Lämna tomt för locale-standard.
Settings_DescForceFork Skapa en ny process för varje anslutning.
Settings_DescHEADFetchesBody Hämta komplett artikel med HEAD-kommandot.
Settings_DescHTTPPort Port som webbgränssnittet lyssnar på. Kräver omstart.
Settings_DescItemsPerPage Rader visade per sida i Historik och Magneter.
Settings_DescLanguage Visningsspråk för gränssnittet. Lämna tomt för automatisk identifiering från webbläsare.
Settings_DescListenAddress IP-adress att binda till. Tom = alla gränssnitt.
Settings_DescLocalOnly_UI Begränsa webbgränssnittet till lokala anslutningar.
Settings_DescLogDirectory Katalog för loggfiler. Tom = POPFile-root.
Settings_DescLogLevel Detaljnivå för loggutdata.
Settings_DescLogSQLToStdout Skriv ut varje SQL-sats med bundna värden till stdout. Bara aktiv när "Logga till stdout" också är aktiverat.
Settings_DescLogToStdout Spegling av loggutdata till stdout utöver loggfilen.
Settings_DescMessageCutoff Maximalt antal analyserade ord per meddelande (0 = obegränsat).
Settings_DescNNTPLocalOnly Acceptera bara NNTP-anslutningar från localhost.
Settings_DescNNTPPort Port som POPFile lyssnar på för NNTP (standard 119).
Settings_DescNNTPSeparator Tecken som skiljer användare från server.
Settings_DescPOP3LocalOnly Acceptera bara POP3-anslutningar från localhost.
Settings_DescPOP3Port Port som POPFile lyssnar på för POP3 (standard 1110).
Settings_DescPOP3Separator Tecken som skiljer användare från server (t.ex. användare:mailvärd).
Settings_DescRetentionDays Hur många dagar meddelandehistorik sparas.
Settings_DescSessionDividers Visa separatorer mellan webbläsarsessioner i Historik.
Settings_DescSMTPLocalOnly Acceptera bara SMTP-anslutningar från localhost.
Settings_DescSMTPPort Port som POPFile lyssnar på för SMTP (standard 25).
Settings_DescSQLiteJournal SQLite-journal / WAL-läge.
Settings_DescSQLiteTweaks Bitmask: 1 = snabbare skrivningar (mindre säkert), 2 = periodisk säkerhetskopiering.
Settings_DescSSLChainPort Port för den överordnade SSL POP3-servern.
Settings_DescSSLChainServer Värdnamn för den överordnade SSL POP3-servern för SSL-kedja.
Settings_DescSubjectTagLeft Prefix infogat i ämneshuvudet, t.ex. [SKRÄPPOST].
Settings_DescSubjectTagRight Suffix tillagt i ämneshuvudet.
Settings_DescTagPosition Var ämnesmärket ska placeras.
Settings_DescTOPFetchesBody Hämta också meddelandeinnehåll med TOP-kommandot.
Settings_DescUnclassifiedWeight Sannolikhetströskel under vilken post är "oklassificerat".
Settings_DescWordStemming Reducera ord till deras stam innan klassificering (t.ex. "springer" till "spring"). Förbättrar recall för morfologiskt rika språk med ~10% fördröjningskostnad.
Settings_DescWordTable Vad som visas i ordssannolikhetstabellen.
Settings_ErrorSaving Fel vid sparande
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD hämtar innehåll
Settings_HTTPPort HTTP-port
Settings_ItemsPerPage Objekt per sida
Settings_ListenAddress Lyssningsadress
Settings_ListenPort Lyssningsport
Settings_LocalOnly Bara lokalt
Settings_LogDirectory Loggkatalog
Settings_LogLevel Loggnivå
Settings_LogSQLToStdout Logga SQL till stdout
Settings_LogToStdout Logga till stdout
Settings_MessageCutoff Meddelandegräns
Settings_OptDebug Felsökning
Settings_OptEnd Slut
Settings_OptErrorsOnly Bara fel
Settings_OptFrequencies Frekvenser
Settings_OptFront Framsida
Settings_OptHidden Dold
Settings_OptInfo Info
Settings_OptLogScores Logga poäng
Settings_OptProbabilities Sannolikheter
Settings_OptWarnings Varningar
Settings_RetentionDays Bevarande (dagar)
Settings_SaveChanges Spara ändringar
Settings_Saved Sparat
Settings_Saving Sparar...
Settings_Search Sök i inställningar...
Settings_SectionClassifier Klassificerare
Settings_SectionHistory Historik
Settings_SectionLogging Loggning
Settings_SectionNNTP NNTP-proxy
Settings_SectionPOP3 POP3-proxy
Settings_SectionSecurity Säkerhet
Settings_SectionSMTP SMTP-proxy
Settings_SectionUI Användargränssnitt
Settings_ServerSeparator Serveravskiljar
Settings_SessionDividers Sessionsavskiljare
Settings_SQLiteJournalMode SQLite-journalläge
Settings_SQLiteTweaks SQLite-justeringar
Settings_SSLChainPort SSL-kedjansport
Settings_SSLChainServer SSL-kedjansserver
Settings_SubjectTagLeft Ämnesmärke vänster
Settings_SubjectTagRight Ämnesmärke höger
Settings_TagPosition Märkesposition
Settings_TOPFetchesBody TOP hämtar innehåll
Settings_UnclassifiedWeight Oklassificerat vikt
Settings_WordStemming Ordstammning
Settings_WordTable Ordtabell
SingleBucket_ClearBucket Ta bort alla ord
Status_Checking Kontrollerar...
Status_Description Statuskontroller för POPFile-tjänster.
Status_LoadError Det gick inte att läsa in status
Status_NoChecks Inga kontroller tillgängliga.
View_Chart Beslutningsdiagram
View_DownloadMessage Ladda ner meddelande
View_MessageBody Meddelandeinnehåll
View_MessageHeader Meddelandehuvud
View_ShowFrequencies Visa ordfrekvenser
View_ShowProbabilities Visa ordsannolikheter
View_ShowScores Visa ordpoäng och beslutningsdiagram
View_Title Enskilt meddelande
View_WordFrequencies visar ordfrekvenser
View_WordMatrix Ordmatris
View_WordProbabilities visar ordsannolikheter
View_WordScores visar ordpoäng
Windows_Console Kör POPFile i ett konsolfönster?
Windows_NextTime <p><font color="red">Den här ändringen träder inte i kraft förrän nästa gång du startar POPFile</font>
Windows_TrayIcon Visa POPFile-ikonen i Windows systemfält?

Advanced_AllParameters Alla POPFile-parametrar
Advanced_ConfigFile Konfigurationsfil:
Advanced_Parameter Parameter
Advanced_Value Värde
Advanced_Warning Det här är den fullständiga listan över POPFile-parametrar. Endast för avancerade användare: du kan ändra valfri parameter och klicka Uppdatera; det finns ingen giltighetsvalidering. Objekt visade i fetstil har ändrats från standardinställningen.
