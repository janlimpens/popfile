# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            de



# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          de







# Common words that are used on their own all over the interface
Apply                                   Anwenden
ApplyChanges                            Änderungen übernehmen
On                                      Ein
Off                                     Aus
TurnOn                                  Einschalten
TurnOff                                 Ausschalten
Add                                     Hinzufügen
Remove                                  Entfernen
Previous                                Zurück
Next                                    Weiter
From                                    Absender
Subject                                 Betreff
Cc                                      Cc
Classification                          Einstufung
Reclassify                              Neu einstufen
Probability                             Wahrscheinlichkeit
Scores                                  Auswertung
QuickMagnets                            Sofort-Magnete
Undo                                    widerrufen
Close                                   Schließen
Find                                    Suchen
Filter                                  Filtern
Yes                                     Ja
No                                      Nein
ChangeToYes                             Ändern in Ja
ChangeToNo                              Ändern in Nein
Bucket                                  Kategorie
Magnet                                  Magnet
Delete                                  Löschen
Create                                  Erstellen
To                                      Empfänger
Total                                   Insgesamt
Rename                                  Umbenennen
Frequency                               Häufigkeit
Probability                             Wahrscheinlichkeit
Score                                   Bewertung
Lookup                                  Nachschlagen
Word                                    Wort
Count                                   Anzahl
Update                                  Ändern
Refresh                                 Aktualisieren
FAQ                                     FAQ
ID                                      ID
Date                                    Datum
Arrived                                 Eingang
Size                                    Größe

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       .
Locale_Decimal                         ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %d.%m.%y %R

# The header and footer that appear on every UI page
Header_Title                            POPFile Kontrollzentrum
Header_Shutdown                         Herunterfahren
Header_History                          Verlauf
Header_Buckets                          Kategorien
Header_Configuration                    Konfiguration
Header_Advanced                         Erweitert
Header_Security                         Sicherheit
Header_Magnets                          Magnete

Footer_HomePage                         POPFile Homepage
Footer_Manual                           Handbuch
Footer_Forums                           Foren
Footer_FeedMe                           Spenden
Footer_RequestFeature                   Verbesserung vorschlagen
Footer_MailingList                      Mailing Liste
Footer_Wiki                             Zusätzliche Dokumentation

Configuration_Error1                    Das Trennzeichen muß ein einzelnes Zeichen sein.
Configuration_Error2                    Der Port für das Kontrollzentrum muß zwischen 1 und 65535 liegen.
Configuration_Error3                    Der POP3 Port muß zwischen 1 und 65535 liegen.
Configuration_Error4                    Die Seitengröße muß zwischen 1 und 1000 liegen.
Configuration_Error5                    Die Anzahl der Tage im Verlauf muß zwischen 1 und 366 liegen.
Configuration_Error6                    Der TCP Timeout muß zwischen 10 und 1800 liegen.
Configuration_Error7                    Der XML-RPC Port muß zwischen 1 und 65535 liegen.
Configuration_Error8                    Der SOCKS V Proxy Port muß zwischen 1 und 65535 liegen.
Configuration_Error9                    Der HTML-Port darf nicht den gleichen Wert haben wie der POP3-Port.
Configuration_Error10                   Der POP3-Port darf nicht den gleichen Wert haben wie der HTML-Port.
Configuration_POP3Port                  POP3 Port
Configuration_POP3Update                Neuer POP3 Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_XMLRPCUpdate              Neuer XML-RPC Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_XMLRPCPort                XML-RPC Port
Configuration_SMTPPort                  SMTP Port
Configuration_SMTPUpdate                Neuer SMTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_NNTPPort                  NNTP Port
Configuration_NNTPUpdate                Neuer NNTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_POPFork                   Simultane POP3-Verbindungen erlauben
Configuration_SMTPFork                  Simultane SMTP-Verbindungen erlauben
Configuration_NNTPFork                  Simultane NNTP-Verbindungen erlauben
Configuration_POP3Separator             POP3 Server:Port:Benutzer Trennzeichen
Configuration_NNTPSeparator             NNTP Server:Port:Benutzer Trennzeichen
Configuration_POP3SepUpdate             Neues POP3 Trennzeichen: %s
Configuration_NNTPSepUpdate             Neues NNTP Trennzeichen: %s
Configuration_UI                        Web Port für Kontrollzentrum
Configuration_UIUpdate                  Neuer Web Port für Kontrollzentrum: %s - Dieser Änderung wird erst nach einem Neustart von POPFile wirksam.
Configuration_History                   Anzahl Nachrichten pro Seite
Configuration_HistoryUpdate             Neue Anzahl Nachrichten pro Seite: %s
Configuration_Days                      Nachrichten x Tage im Verlauf speichern
Configuration_DaysUpdate                Nachrichten werden nun %s Tage im Verlauf gespeichert
Configuration_UserInterface             Benutzeroberfläche
Configuration_Skins                     Skins
Configuration_SkinsChoose               Skin auswählen
Configuration_Language                  Sprache
Configuration_LanguageChoose            Sprache auswählen
Configuration_ListenPorts               Moduleinstellungen
Configuration_HistoryView               Verlaufsansicht
Configuration_TCPTimeout                Verbindungstimeout
Configuration_TCPTimeoutSecs            Verbindungstimeout in Sekunden
Configuration_TCPTimeoutUpdate          Neuer Verbidungstimeout: %s
Configuration_ClassificationInsertion   Einstufung anzeigen
Configuration_SubjectLine               Betreff-Zeile ändern
Configuration_XTCInsertion              X-Text-Classification einfügen
Configuration_XPLInsertion              X-POPFile-Link einfügen
Configuration_Logging                   Protokollierung
Configuration_None                      Keine Ausgabe
Configuration_ToScreen                  Auf den Bildschirm
Configuration_ToFile                    In eine Datei
Configuration_ToScreenFile              Bildschirm und Datei
Configuration_LoggerOutput              Protokoll ausgeben
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                kleine Skins
Configuration_TinySkins                 sehr kleine Skins
Configuration_CurrentLogFile            &lt;aktuelle Protokolldatei&gt;
Configuration_SOCKSServer               SOCKS V Proxy Host
Configuration_SOCKSPort                 SOCKS V Proxy Port
Configuration_SOCKSPortUpdate           SOCKS V Proxy Port geändert auf %s
Configuration_SOCKSServerUpdate         SOCKS V Proxy Host geändert auf %s
Configuration_Fields                    Spalten im Verlauf

Advanced_Error1                         '%s' ist bereits in der Liste der ignorierten Wörter
Advanced_Error2                         Ignorierte Wörtern können nur alphanumerische, ., _, -, oder @ Zeichen enthalten
Advanced_Error3                         '%s' zu den ignorierten Wörtern hinzugefügt
Advanced_Error4                         '%s' ist nicht in der Liste der ignorierten Wörter
Advanced_Error5                         '%s' von der Liste der ignorierten Wörter entfernt
Advanced_StopWords                      Ignorierte Wörter
Advanced_Message1                       POPFile ignoriert die folgenden, häufig verwendeten Wörter:
Advanced_AddWord                        Wort hinzufügen
Advanced_RemoveWord                     Wort löschen
Advanced_AllParameters                  POPFile Konfigurationsparameter
Advanced_Parameter                      Parameter
Advanced_Value                          Wert
Advanced_Warning                        Dies ist eine komplette Liste aller Parameter Ihrer POPFile Konfiguration. Nur für fortgeschrittene Anwender: Sie können jeden Wert ändern und durch einen Klick auf "Ändern" bestätigen. Eingaben werden nicht auf Gültigkeit überprüft!
Advanced_ConfigFile                     Konfigurationsdatei:

History_Filter                          &nbsp;(zeige nur Kategorie <font color="%s">%s</font>)
History_FilterBy                        Filtern nach
History_Search                          &nbsp;(gesuchter Absender/Betreff: %s)
History_Title                           Aktuelle Nachrichten
History_Jump                            zu Seite gehen
History_ShowAll                         Alle anzeigen
History_ShouldBe                        Sollte sein
History_NoFrom                          kein Absender angegeben
History_NoSubject                       kein Betreff
History_ClassifyAs                      eingestuft als
History_MagnetUsed                      Magnet benutzt
History_MagnetBecause                   <b>Magnet benutzt</b><p>Eingestuft als <font color="%s">%s</font> durch Magnet %s </p>
History_ChangedTo                       Geändert: <font color="%s">%s</font>
History_Already                         Neu eingestuft als <font color="%s">%s</font>
History_RemoveAll                       Alle entfernen
History_RemovePage                      Diese Seite entfernen
History_RemoveChecked                   Ausgewählte Einträge löschen
History_Remove                          Um Einträge im Verlauf zu löschen, klicken Sie auf
History_SearchMessage                   Nach Absender/Betreff suchen
History_NoMessages                      keine Nachrichten
History_ShowMagnet                      magnetisiert
History_Negate_Search                   Filter invertieren
History_Magnet                          &nbsp;(zeige nur durch Magnet eingestufte Nachrichten)
History_NoMagnet                        &nbsp;(zeige nicht durch Magnet eingestufte Nachrichten)
History_ResetSearch                     Zurücksetzen
History_ChangedClass                    Würde jetzt eingestuft als
History_Purge                           Jetzt löschen
History_Increase                        größer
History_Decrease                        kleiner
History_Column_Characters               Größe der Spalten für From, To, Cc und Subject
History_Automatic                       automatisch
History_Reclassified                    Neu eingestuft
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          Paßwort
Password_Enter                          Paßwort eingeben
Password_Go                             Anmelden
Password_Error1                         Falsches Paßwort

Security_Error1                         Der Port muß zwischen 1 und 65535 liegen.
Security_Stealth                        Stealth Modus/Serverbetrieb
Security_NoStealthMode                  Nein (Stealth Modus)
Security_StealthMode                    (Stealth Modus)
Security_ExplainStats                   (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf getpopfile.org: bc (Anzahl von Ihnen eingerichteter Kategorien), mc (Anzahl von POPFile eingestufter Nachrichten) und ec (Anzahl der Einstufungsfehler). Diese werden in einer Datei gespeichert und benutzt, um öffentliche Statistiken darüber zu erstellen, wie POPFile genutzt wird und wie gut es dabei funktioniert. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_ExplainUpdate                  (Wenn Sie diese Funktion einschalten, sendet POPFile täglich die drei folgenden Werte an ein Skript auf getpopfile.org: ma (die Hauptversionsnummer der POPFile-Installation), mi (die Nebenversionsnummer der POPFile-Installation) und bn (die build-Nummer der POPFile-Installation). POPFile erhält die Antwort in Form einer Grafik, die am Kopf einer Seite erscheint, wenn eine neue Version verfügbar ist. Die Daten werden etwa 5 Tage auf dem Server gespeichert und dann gelöscht. Zuordnungen zwischen IP-Adressen und statistischen Daten werden nicht gespeichert.)
Security_PasswordTitle                  Paßwort für Benutzeroberfläche
Security_Password                       Paßwort
Security_PasswordUpdate                 Passwort geändert
Security_AUTHTitle                      externe Server
Security_SecureServer                   POP3 Server (SPA/AUTH oder transparenter Proxy)
Security_SecureServerUpdate             Neuer externer POP3 Server: %s
Security_SecurePort                     POP3 Port (SPA/AUTH oder transparenter Proxy)
Security_SecurePortUpdate               Neuer POP3 Port %s
Security_SMTPServer                     externer SMTP Server
Security_SMTPServerUpdate               Neuer externer SMTP Server: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_SMTPPort                       externer SMTP port
Security_SMTPPortUpdate                 Neuer externer SMTP Port: %s - Diese Änderung wird erst nach einem Neustart von POPFile wirksam.
Security_POP3                           POP3 Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_SMTP                           SMTP Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFILE)
Security_NNTP                           NNTP Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_UI                             HTTP (Benutzeroberfläche) Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_XMLRPC                         XML-RPC Verbindungen von fremden Rechnern erlauben (erfordert Neustart von POPFile)
Security_UpdateTitle                    Automatisch auf Updates prüfen
Security_Update                         Täglich nach POPFile Updates suchen
Security_StatsTitle                     Statistik Report
Security_Stats                          Täglich Statistiken senden

Magnet_Error1                           Magnet '%s' existiert bereits in Kategorie '%s'
Magnet_Error2                           Neuer Magnet '%s' kollidiert mit Magnet '%s' in Kategorie '%s' und könnte unklare Ergebnisse verursachen. Magnet wurde nicht unzugefügt.
Magnet_Error3                           Erstelle neuen Magnet '%s' in Kategorie '%s'
Magnet_CurrentMagnets                   Aktuelle Magnete
Magnet_Message1                         Die folgenden Magnete ordnen neue Post zwingend in eine angegebene Kategorie ein.
Magnet_CreateNew                        Neuen Magnet erstellen
Magnet_Explanation                      Diese Arten von Magneten sind verfügbar: <ul><li>Absenderadresse oder -name:</b> z.B.: hans@firma.de, um eine bestimmte Adresse zu erfassen, <br />firma.de, um jeden zu erfassen, der von firma.de sendet, <br />Hans Mustermann, um eine bestimmte Person zu erfassen; Hans erfaßt jeden Hans</li><li><b>Empfänger/CC-Adresse oder -Name:</b> Wie beim Absender-Magnet nur für die Empfänger/CC-Adresse der Nachricht.</li><li><b>Wörter im Betreff:</b> z.B.: "Hallo", um alle Nachrichten mit "Hallo" im Betreff zu erfassen</li></ul>
Magnet_MagnetType                       Typ des Magnets
Magnet_Value                            Wert
Magnet_Always                           Immer dieser Kategorie zuordnen
Magnet_Jump                             Gehe zu Magnet Seite

Bucket_Error1                           Kategorienamen können nur Kleinbuchstaben von a bis z, Ziffern von 0 bis 9, - oder _ enthalten
Bucket_Error2                           Kategoriename %s existiert bereits
Bucket_Error3                           Kategorie %s erstellt
Bucket_Error4                           Bitte geben Sie ein nicht-leeres Wort ein
Bucket_Error5                           Kategorie %s in %s umbenannt
Bucket_Error6                           Kategorie %s gelöscht
Bucket_Title                            Kategorien konfigurieren
Bucket_BucketName                       Name der Kategorie
Bucket_WordCount                        Wortanzahl
Bucket_WordCounts                       Wortanzahl
Bucket_UniqueWords                      verschiedene Wörter
Bucket_SubjectModification              Betreffzeile ändern
Bucket_ChangeColor                      Farbe ändern
Bucket_NotEnoughData                    Nicht genügend Daten
Bucket_ClassificationAccuracy           Genauigkeit
Bucket_EmailsClassified                 Nachrichten klassifiziert
Bucket_EmailsClassifiedUpper            Nachrichten klassifiziert
Bucket_ClassificationErrors             Einstufungsfehler
Bucket_Accuracy                         Genauigkeit
Bucket_ClassificationCount              Anzahl Einstufungen
Bucket_ClassificationFP                 falsch positiv
Bucket_ClassificationFN                 falsch negativ
Bucket_ResetStatistics                  Statistiken zurücksetzen
Bucket_LastReset                        Läuft seit
Bucket_CurrentColor                     Derzeitige Farbe von %s ist %s
Bucket_SetColorTo                       Setze Farbe von %s auf %s
Bucket_Maintenance                      Verwaltung
Bucket_CreateBucket                     Erstelle Kategorie
Bucket_DeleteBucket                     Lösche Kategorie
Bucket_RenameBucket                     Benenne Kategorie um
Bucket_Lookup                           Nachschlagen
Bucket_LookupMessage                    Wort in Kategorie nachschlagen
Bucket_LookupMessage2                   Ergebnis für
Bucket_LookupMostLikely                 <b>%s</b> erscheint am wahrscheinlichsten in <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> erscheint in keiner Kategorie
Bucket_DisabledGlobally                 Global deaktiviert
Bucket_To                               in
Bucket_Quarantine                       Nachricht in Quarantäne

SingleBucket_Title                      Details für %s
SingleBucket_WordCount                  Anzahl Worte in dieser Kategorie
SingleBucket_TotalWordCount             Anzahl Worte insgesamt
SingleBucket_Percentage                 Anteil an der Gesamtzahl
SingleBucket_WordTable                  Worttabelle für %s
SingleBucket_Message1                   Klicken Sie auf einen Buchstaben, um eine Liste der Wörter aufzurufen, die mit diesem beginnen. Klicken Sie auf ein beliebiges Wort, um die Wahrscheinlichkeit seines Erscheinens für alle Kategorien anzusehen.
SingleBucket_Unique                     %s verschiedene
SingleBucket_ClearBucket                Alle Wörter entfernen

Session_Title                           POPFile Sitzung abgelaufen
Session_Error                           Ihre POPFile-Sitzung ist abgelaufen. Dies könnte dadurch verursacht worden sein, daß Sie POPFile neu gestartet haben, das Kontrollzentrum aber noch im Browser geöffnet war. Bitte klicken Sie auf einen der oben angezeigten Verweise, um mit der Benutzung von POPFile weitermachen zu können.

View_Title                              Nachrichtenansicht
View_ShowFrequencies                    Zeige Häufigkeit des Auftretens
View_ShowProbabilities                  Zeige Wahrscheinlichkeit des Auftretens
View_ShowScores                         Zeige Bewertung des Wortes
View_WordMatrix                         Wort Matrix
View_WordProbabilities                  zeige Wahrscheinlichkeit des Auftretens
View_WordFrequencies                    zeige Häufigkeit des Auftretens
View_WordScores                         zeige Bewertung des Wortes
View_Chart                              Entscheidungs-Diagramm
View_DownloadMessage                    Nachricht herunterladen

Windows_TrayIcon                        POPFile-Symbol neben der Uhr anzeigen?
Windows_Console                         POPFile in einem Konsolenfenster ausführen?
Windows_NextTime                        <p><font color="red">Diese Änderung wird erst beim nächsten Start von POPFile wirksam.</font>

Header_MenuSummary                      Diese Tabelle ist das Navigationsmenü, das Zugang zu den einzelnen Bereichen des Kontrollzentrums bietet.
History_MainTableSummary                Diese Tabelle zeigt Absender und Betreff der letzten empfangenen Nachrichten an und ermöglicht es, diese durchzusehen und zu reklassifizieren. Ein Klick auf den Betreff zeigt die vollständige Nachricht an sowie Details, warum diese so und nicht anders klassifiziert wurde. Die Spalte "Sollte sein" ermöglicht es, anzugeben, in welche Kategorie die Nachricht gehört bzw. entsprechende Änderungen rückgängig zu machen. Die Spalte "Delete" ermöglicht es, einzelne Nachrichten aus dem Verlauf zu löschen, falls Sie diese nicht mehr benötigen.
History_OpenMessageSummary              Diese Tabelle enthält den kompletten Text einer Nachricht. Die Wörter sind entsprechend der Kategorie eingefärbt, in die sie am wahrscheinlichsten passen.
Bucket_MainTableSummary                 Diese Tabelle bietet einen Überblick über die einzelnen Kategorien. Jede Reihe zeigt Name, Gesamtzahl der Wörter und die Anzahl verschiedener Wörter pro Kategorie an, ob die Betreff-Zeile der Nachricht bei der Klassifizierung geändert wird, ob die Nachrichten dieser Kategorie in Quarantäne gestellt werden sollen, sowie eine Tabelle zur Auswahl einer Farbe, in der alle zu dieser Kategorie gehörenden Elemente im Kontrollzentrum dargestellt werden sollen.
Bucket_StatisticsTableSummary           Diese Tabelle zeigt drei verschiedene Statistiken bezüglich POPFiles Gesamtleistung an. Die erste: Wie fehlerfrei ist die Einordnung in die entsprechenden Kategorien? Die zweite: Wie viele Nachrichten wurden analysiert und wie wurden sie eingeordnet? Die dritte: Wie viele Wörter gehören zu jeder Kategorie und wie hoch ist der Prozentsatz zur Gesamtzahl?
Bucket_MaintenanceTableSummary          Diese Tabelle enthält Formulare zum Erstellen, Löschen und Umbenennen von Kategorien und um die relative Wahrscheinlichkeit der Wörter in jeder einzelnen Kategorie nachzuschlagen.
Bucket_AccuracyChartSummary             Diese Tabelle stellt die Genauigkeit der Nachrichten-Sortierung grafisch dar.
Bucket_BarChartSummary                  Diese Tabelle stellt einen Prozentanteil grafisch dar. Sie wird sowohl für die Anzahl der eingestuften Nachrichten als auch für die Gesamtzahl der Wörter genutzt.
Bucket_LookupResultsSummary             Diese Tabelle stellt die Wahrscheinlichkeiten bezüglich jedes angegebenen Wortes dar. Für jede Kategorie wird folgendes angezeigt: Die Häufigkeit, mit der das Wort auftritt, die Wahrscheinlichkeit, daß es in dieser Kategorie auftritt und die Auswirkungen auf die Punktzahl der Kategorie insgesamt, falls das Wort in einer Nachricht auftaucht.
Bucket_WordListTableSummary             Diese Tabelle bietet eine Liste aller Wörter einer bestimmten Kategorie - reihenweise sortiert nach dem ersten Buchstaben.
Magnet_MainTableSummary                 Diese Tabelle zeigt eine Liste der Magnete an, die dazu benutzt werden, um Nachrichten automatisch nach festen Kriterien zu sortieren. Jede Reihe zeigt an, wie der Magnet definiert ist, in welche Kategorie er einsortiert und eine Schaltfläche, um den Magnet zu löschen.
Configuration_MainTableSummary          Diese Tabelle enthält einige Formulare zur Konfiguration von POPFile.
Configuration_InsertionTableSummary     Diese Tabelle enthält Schaltflächen zur Konfiguration, ob bestimmte Änderungen an Kopfzeilen oder Betreff der Nachricht gemacht werden sollen, bevor diese an das entsprechende Programm weitergegeben wird.
Security_MainTableSummary               Diese Tabelle bietet Einstellungsmöglichkeiten, die die Sicherheit von POPFile insgesamt betreffen, ob es automatisch auf neue Versionen prüfen soll oder ob Statistiken über die Leistung von POPFile an eine zentrale Datenbank zwecks der Erstellung von Gesamtstatistiken geschickt werden sollen.
Advanced_MainTableSummary               Diese Tabelle enthält eine Liste von Wörtern, die POPFile ignoriert, wenn es eine Nachricht analysiert. Dies betrifft Wörter, die besonders häufig in Nachrichten auftauchen. Diese sind reihenweise alphabetisch nach dem ersten Buchstaben sortiert.

Imap_Bucket2Folder                      Mail der Kategorie '<b>%s</b>' kommt in den Ordner
Imap_MapError                           Sie können nicht mehr als eine Kategorie einem einzelnen Ordner zuordnen!
Imap_Server                             IMAP Server Hostname:
Imap_ServerNameError                    Bitte geben Sie den Namen des Servers ein!
Imap_Port                               IMAP Server Port:
Imap_PortError                          Bitte geben Sie eine gültige Portnummer ein!
Imap_Login                              IMAP Benutzername (Login):
Imap_LoginError                         Bitte geben Sie einen gültigen Benuternamen ein!
Imap_Password                           Password für IMAP Konto:
Imap_PasswordError                      Bitte geben Sie ein Passwort an!
Imap_Expunge                            Gelöschte Nachrichten aus den überwachten Ordnern endgültig löschen.
Imap_Interval                           Update Intervall in Sekunden:
Imap_IntervalError                      Bitte geben Sie ein Intervall zwischen 10 und 3600 Sekunden ein.
Imap_Bytelimit                          Bytes pro Email, die zur Klassifikation genutzt werden. Geben Sie bitte 0 (Null) ein, um die komplette Nachricht zu nutzen.
Imap_BytelimitError                     Bitte geben Sie eine Zahl ein.
Imap_RefreshFolders                     Ordnerliste neu laden:
Imap_Now                                jetzt!
Imap_UpdateError1                       Login war nicht erfolgreich. Bitte überprüfen Sie Ihren Benutzernamen und das Passwort.
Imap_UpdateError2                       Verbindung zum Server fehlgeschlagen! Bitte überprüfen Sie den Namen des Servers, den Port und stellen Sie sicher, dass Sie Zugang zum Internet haben.
Imap_UpdateError3                       Bitte konfigurieren Sie erst die Verbindung zum Server.
Imap_NoConnectionMessage                Bitte konfigurieren Sie erst die Verbindung zum Server. Nachdem Sie das getan haben, werden Sie an dieser Stelle mehr Konfigurationsmöglichkeiten finden.
Imap_WatchMore                          : einen weiteren zu überwachenden Ordner
Imap_WatchedFolder                      Überwachter Ordner Nr.
Imap_Use_SSL							SSL-gesicherte Verbindung

Shutdown_Message                        POPFile wurde beendet

Help_Training                           POPFile weiss zunächst einmal nichts über Ihre Nachrichten und muss deshalb erst trainiert werden. Für jede Kategorie muss mindestens eine Nachricht neu eingestuft worden sein, damit POPFile selber eine Einstufung vornehmen kann. Außerdem müssen Sie Ihr Mail-Programm so konfigurieren, dass es aufgrund der POPFile-Einstufung Ihre Emails filtert. Informationen über die Konfiguration verschiedener Mail-Programme finden Sie (auf English) im <a href="http://getpopfile.org/docs/FAQ:EmailSorting">POPFile Documentation Project</a>.
Help_Bucket_Setup                       POPFile braucht mindestens zwei Kategorien zusätzlich zu der "unclassified" Pseudo-Kategorie. POPFile zeichnet sich durch die Fähigkeit aus, Emails in eine unbgrenzte Zahl von Kategorien einsortieren zu können. Eine einfache Konfiguration könnte zum Beispiel die Kategorien "spam", "beruflich" und "privat" enthalten.
Help_No_More                            Diesen Hinweis nicht mehr zeigen

# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpus
NavHistory Verlauf
NavIMAP IMAP
NavMagnets Magnete
NavSettings Einstellungen
NavStatus Status
NavWordSearch Words & Stopwords
Corpus_BucketList Kategorien
Corpus_Color Farbe
Corpus_Actions Aktionen
Corpus_Clear Leeren
Corpus_Search Suchen
Corpus_WordsLink Wörter →
WordSearch_Title Word Search
WordSearch_Placeholder prefix...
WordSearch_Search Search
WordSearch_ColumnWord Word
WordSearch_ColumnBuckets Buckets
WordSearch_Coverage coverage
WordSearch_AddStopword + Stopword
WordSearch_RemoveStopword Stopword
WordSearch_IsStopword stopword
WordSearch_StopwordList Stopwords
WordSearch_NoResults No words found.
WordSearch_NoStopwords No stopwords defined.
WordSearch_Loading Loading...
WordSearch_Total words
BucketSelect_AddNew Neu hinzufügen...
BucketSelect_AlreadyExists Existiert bereits
BucketSelect_CreateError Fehler beim Erstellen der Kategorie
BucketSelect_InvalidName Nur a-z, 0-9, - und _
BucketSelect_NameRequired Name erforderlich
Bucket_InIgnoredWords <b>%s</b> ist in der Ignorierliste. POPFile ignoriert dieses Wort
History_AllBuckets Alle Kategorien
History_HighlightWords Wörter nach Kategorie hervorheben
History_Loading Lade...
History_PerPage Pro Seite:
History_MoveTo — verschieben nach —
History_Moving Verschiebe...
History_NoMatchingMessages Keine übereinstimmenden Nachrichten
History_Reclassifying Klassifiziere neu...
History_ReclassifyUnclassified Unkategorisierte neu einstufen
History_Selected ausgewählt
Imap_BucketFolderMappings Kategorie -> Ordner-Zuordnungen
Imap_Connected Verbunden
Imap_Connection Verbindung
Imap_ConnectionFailed Verbindung fehlgeschlagen
Imap_Description IMAP-Ordner überwachen und eingehende Nachrichten automatisch klassifizieren.
Imap_EnableService IMAP-Dienst aktivieren
Imap_FetchFolders Ordner abrufen
Imap_Fetching Abrufe...
Imap_IMAFFolder IMAP-Ordner
Imap_MappingsHint Klassifizierte Nachrichten werden in den angegebenen IMAP-Ordner verschoben. Lassen Sie nicht zugeordnete Kategorien leer, um das Verschieben zu überspringen.
Imap_NoFoldersWatched Noch keine Ordner überwacht.
Imap_NoMappings Keine Zuordnungen definiert.
Imap_SaveAnyway Trotzdem speichern
Imap_SaveConnection Verbindung speichern
Imap_SaveFolders Ordner speichern
Imap_Saving Speichere...
Imap_Advanced                           Erweitert
Imap_Wizard                             Einrichtungs-Assistent
Imap_WizardDesc                         Ordner auswählen, für die Buckets und Zuordnungen erstellt werden sollen.
Imap_WizardEmpty                        Keine weiteren Ordner auf dem Server gefunden.
Imap_WizardApply                        Erstellen & zuordnen
Imap_WizardSelectAll                    Alle auswählen
Imap_WizardDeselectAll                  Alle abwählen
Imap_WizardDone                         {count} Bucket(s) erstellt und zugeordnet.
Imap_WizardTrain                        Jetzt trainieren
Imap_WizardClose                        Schließen
Imap_Cancel                             Abbrechen
Imap_Service Dienst
Imap_TestConnection Verbindung testen
Imap_Testing Teste...
Imap_TrainingHint Der Trainingsmodus durchsucht vorhandene Archivordner und trainiert den Klassifizierer anhand ihrer Inhalte. Das Flag wird automatisch zurückgesetzt, wenn das Training abgeschlossen ist.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingLimit Nachrichten pro Ordner (0 = unbegrenzt)
Imap_TrainingMode Trainingsmodus
Imap_WatchedFolders Überwachte Ordner
Imap_WatchedHint POPFile überwacht diese IMAP-Ordner auf neue Nachrichten zur Klassifizierung.
Magnet_Created Magnet erstellt
Magnet_Deleted Magnet gelöscht
Reconnect_Connecting Verbinde...
Reconnect_Message Das Backend ist nicht erreichbar. Versuche, die Verbindung wiederherzustellen...
Reconnect_Now Jetzt verbinden
Reconnect_RetryIn Erneuter Versuch in
Reconnect_Title Verbindung unterbrochen
Settings_AdminPassword Admin-Passwort
Settings_ArchiveDirectory Archivverzeichnis
Settings_ArchiveMessages Nachrichten archivieren
Settings_ArchiveSubdirs Archiv-Unterverzeichnisse
Settings_AutoDetect Automatisch erkennen
Settings_AutoDetectLanguage Sprache automatisch erkennen
Settings_ChainPort Chain-Port
Settings_ChainServer Chain-Server
Settings_DescAdminPassword Leer lassen, um den Passwortschutz zu deaktivieren.
Settings_DescArchiveDir Verzeichnis für archivierte Nachrichten (relativ zum Benutzerverzeichnis).
Settings_DescArchiveMessages Eine Kopie jeder klassifizierten Nachricht auf dem Datenträger speichern.
Settings_DescArchiveSubdirs Archiv in N Unterverzeichnisse aufteilen (0 = deaktiviert).
Settings_DescAutoDetectLang Erkennt die Sprache jeder Nachricht und wendet passende Stoppwörter und Stemmer an. Erhöht die Klassifizierungslatenz um ~130%; nützlich für Postfächer mit gemischten Sprachen.
Settings_DescChainPort Port des vorgelagerten SMTP-Servers.
Settings_DescChainServer Hostname des vorgelagerten SMTP-Servers.
Settings_DescForceFork Für jede Verbindung einen neuen Prozess forken.
Settings_DescHEADFetchesBody Vollständigen Artikel mit dem HEAD-Befehl abrufen.
Settings_DescHTTPPort Port, auf dem die Web-Oberfläche lauscht. Neustart erforderlich.
Settings_DescItemsPerPage Angezeigte Zeilen pro Seite in Verlauf und Magneten.
Settings_DescLanguage Anzeigesprache der Oberfläche. Leer lassen für automatische Erkennung aus dem Browser.
Settings_DescListenAddress IP-Adresse zum Binden. Leer = alle Schnittstellen.
Settings_DescLocalOnly_UI Web-Oberfläche auf lokale Verbindungen beschränken.
Settings_DescLogDirectory Verzeichnis für Log-Dateien. Leer = POPFile-Wurzel.
Settings_DescLogLevel Ausführlichkeit der Log-Ausgabe.
Settings_DescLogFormat Format der Log-Zeilen. 'plain' für journald oder Umgebungen, die eigene Zeitstempel hinzufügen.
Settings_DescLogSQLToStdout SQL-Anweisungen mit gebundenen Werten in die Log-Ausgabe aufnehmen. Folgt demselben Ziel wie andere Log-Meldungen (Datei und/oder stdout).
Settings_DescLogToStdout Log-Ausgabe zusätzlich zur Log-Datei auf stdout spiegeln.
Settings_DescOpenBrowser Standardbrowser öffnen, wenn die Web-Oberfläche bereit ist.
Settings_DescMessageCutoff Maximale analysierte Wörter pro Nachricht (0 = unbegrenzt).
Settings_DescNNTP                        NNTP-Proxy — sitzt zwischen Newsreader und NNTP-Server, klassifiziert Artikel und fügt Klassifikations-Header ein. Trage in deinem Newsreader den Host und Port ein, auf dem POPFile läuft (Standard 119).
Settings_DescNNTP                        NNTP-Proxy — sitzt zwischen Newsreader und NNTP-Server, klassifiziert Artikel und fügt Klassifikations-Header ein. Trage in deinem Newsreader den Host und Port ein, auf dem POPFile läuft (Standard 119).
Settings_DescNNTP                        NNTP-Proxy — sitzt zwischen Newsreader und NNTP-Server, klassifiziert Artikel und fügt Klassifikations-Header ein. Trage in deinem Newsreader den Host und Port ein, auf dem POPFile läuft (Standard 119).
Settings_DescEnableProxy Diesen Proxy-Listener beim Start von POPFile starten.
Settings_DescPOP3                        POP3-Proxy — sitzt zwischen Mail-Client und POP3-Server, klassifiziert Nachrichten und fügt einen X-Text-Classification-Header ein. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 1110), statt des echten POP3-Servers.
Settings_DescPOP3                        POP3-Proxy — sitzt zwischen Mail-Client und POP3-Server, klassifiziert Nachrichten und fügt einen X-Text-Classification-Header ein. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 1110), statt des echten POP3-Servers.
Settings_DescPOP3                        POP3-Proxy — sitzt zwischen Mail-Client und POP3-Server, klassifiziert Nachrichten und fügt einen X-Text-Classification-Header ein. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 1110), statt des echten POP3-Servers.
Settings_DescRetentionDays Wie viele Tage der Nachrichtenverlauf aufbewahrt wird.
Settings_DescSessionDividers Trennlinien zwischen Browsersitzungen im Verlauf anzeigen.
Settings_DescSMTP                        SMTP-Proxy — sitzt zwischen Mail-Client und SMTP-Server, klassifiziert ausgehende Nachrichten und leitet sie weiter. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 25).
Settings_DescSMTP                        SMTP-Proxy — sitzt zwischen Mail-Client und SMTP-Server, klassifiziert ausgehende Nachrichten und leitet sie weiter. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 25).
Settings_DescSQLiteJournal SQLite Journal / WAL-Modus.
Settings_DescSQLiteBackup Datenbank stündlich als .backup-Datei sichern.
Settings_DescSQLiteFastWrites SQLite-Schreib-Sync deaktivieren für schnellere Einfügeoperationen. Geringes Datenverlustrisiko bei Absturz.
Settings_DescSSLChainPort Port des vorgelagerten SSL POP3-Servers.
Settings_DescSSLChainServer Hostname des vorgelagerten SSL POP3-Servers für SSL-Verkettung.
Settings_DescSubjectTagLeft Präfix, das in den Betreff-Header eingefügt wird, z.B. [SPAM].
Settings_DescSubjectTagRight Suffix, das an den Betreff-Header angehängt wird.
Settings_DescTagPosition Wo das Betreff-Tag platziert werden soll.
Settings_DescTOPFetchesBody Nachrichteninhalt auch mit dem TOP-Befehl abrufen.
Settings_DescUnclassifiedWeight Wahrscheinlichkeitsschwelle, unterhalb derer E-Mails "unkategorisiert" sind.
Settings_DescWordStemming Wörter vor der Klassifizierung auf ihren Stamm reduzieren (z.B. "laufen" zu "lauf"). Verbessert den Recall für morphologisch reiche Sprachen bei ~10% Latenzkosten.
Settings_DescWordTable Was in der Wort-Wahrscheinlichkeitstabelle angezeigt werden soll.
Settings_ErrorSaving Fehler beim Speichern
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD ruft Body ab
Settings_HTTPPort HTTP-Port
Settings_ItemsPerPage Einträge pro Seite
Settings_ListenAddress Listen-Adresse
Settings_ListenPort Listen-Port
Settings_LocalOnly Nur lokal
Settings_LogDirectory Log-Verzeichnis
Settings_LogLevel Log-Stufe
Settings_LogFormat Log-Format
Settings_LogSQLToStdout SQL-Abfragen loggen
Settings_LogToStdout Nach stdout loggen
Settings_OpenBrowser Browser beim Start öffnen
Settings_MessageCutoff Nachrichtengrenze
Settings_OptDebug Debug
Settings_OptEnd Ende
Settings_OptErrorsOnly Nur Fehler
Settings_OptFrequencies Häufigkeiten
Settings_OptFront Vorne
Settings_OptHidden Versteckt
Settings_OptInfo Info
Settings_OptLogScores Bewertungen protokollieren
Settings_OptProbabilities Wahrscheinlichkeiten
Settings_OptWarnings Warnungen
Settings_RetentionDays Aufbewahrung (Tage)
Settings_SaveChanges Änderungen speichern
Settings_Saved Gespeichert
Settings_Saving Speichere...
Settings_Search Einstellungen suchen...
Settings_EnableService Dienst aktivieren
Settings_SectionClassifier Klassifizierer
Settings_SectionHistory Verlauf
Settings_SectionLogging Protokollierung
Settings_SectionNNTP NNTP
Settings_DescNNTP                        NNTP-Proxy — sitzt zwischen Newsreader und NNTP-Server, klassifiziert Artikel und fügt Klassifikations-Header ein. Trage in deinem Newsreader den Host und Port ein, auf dem POPFile läuft (Standard 119).
Settings_SectionPOP3 POP3
Settings_DescPOP3                        POP3-Proxy — sitzt zwischen Mail-Client und POP3-Server, klassifiziert Nachrichten und fügt einen X-Text-Classification-Header ein. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 1110), statt des echten POP3-Servers.
Settings_SectionIMAP                    IMAP
Settings_SectionSecurity Sicherheit
Settings_SectionSMTP SMTP
Settings_DescSMTP                        SMTP-Proxy — sitzt zwischen Mail-Client und SMTP-Server, klassifiziert ausgehende Nachrichten und leitet sie weiter. Trage in deinem Mail-Client den Host und Port ein, auf dem POPFile läuft (Standard 25).
Settings_SectionUI Benutzeroberfläche
Settings_ServerSeparator Server-Trennzeichen
Settings_SessionDividers Sitzungstrennlinien
Settings_SQLiteJournalMode SQLite-Journalmodus
Settings_SQLiteBackup SQLite: regelmäßige Sicherung
Settings_SQLiteFastWrites SQLite: schnelles Schreiben (weniger sicher)
Settings_SSLChainPort SSL-Chain-Port
Settings_SSLChainServer SSL-Chain-Server
Settings_SubjectTagLeft Betreff-Tag links
Settings_SubjectTagRight Betreff-Tag rechts
Settings_TagPosition Tag-Position
Settings_TOPFetchesBody TOP ruft Body ab
Settings_UnclassifiedWeight Unkategorisiert-Gewichtung
Settings_WordStemming Wortstammung
Settings_WordTable Worttabelle
Status_Checking Überprüfe...
Status_Description Systemprüfungen für POPFile-Dienste.
Status_LoadError Status konnte nicht geladen werden
Status_NoChecks Keine Prüfungen verfügbar.
View_MessageBody Nachrichteninhalt
View_MessageHeader Nachrichtenkopf

Language_Name                           Deutsch
Wizard_Next                             Weiter
Wizard_Manual                           Manuelle Einrichtung
Wizard_ManualDesc                       Gib die Zugangsdaten deines Mail-Servers ein.
Wizard_Encryption                       Verschlüsselung
Wizard_Done                             Fertig!
Wizard_Welcome                          Willkommen bei POPFile. POPFile hilft dir, Ordnung in deine Inbox zu bringen. Gib zuerst deinen Benutzernamen ein — meistens deine E-Mail-Adresse.
Wizard_Username                         Benutzername
