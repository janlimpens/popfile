# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          de

# Common words that are used on their own all over the interface
Apply                                   Anwenden
Add                                     Hinzufügen
Remove                                  Entfernen
Previous                                Zurück
Next                                    Weiter
From                                    Absender
Subject                                 Betreff
Reclassify                              Neu einstufen
Undo                                    widerrufen
Close                                   Schließen
Bucket                                  Kategorie
Magnet                                  Magnet
Delete                                  Löschen
Create                                  Erstellen
Total                                   Insgesamt
Rename                                  Umbenennen
Update                                  Ändern
Refresh                                 Aktualisieren
Date                                    Datum

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)


# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates


# The header and footer that appear on every UI page


Configuration_Language                  Sprache


History_SearchMessage                   Nach Absender/Betreff suchen



Magnet_CurrentMagnets                   Aktuelle Magnete
Magnet_CreateNew                        Neuen Magnet erstellen

Bucket_CreateBucket                     Erstelle Kategorie
Bucket_RenameBucket                     Benenne Kategorie um






Imap_Server                             IMAP Server Hostname:
Imap_Port                               IMAP Server Port:
Imap_Login                              IMAP Benutzername (Login):
Imap_Password                           Password für IMAP Konto:
Imap_Expunge                            Gelöschte Nachrichten aus den überwachten Ordnern endgültig löschen.
Imap_Interval                           Update Intervall in Sekunden:
Imap_NoConnectionMessage                Bitte konfigurieren Sie erst die Verbindung zum Server. Nachdem Sie das getan haben, werden Sie an dieser Stelle mehr Konfigurationsmöglichkeiten finden.
Imap_Use_SSL							SSL-gesicherte Verbindung



# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Korpus
NavHistory Verlauf
NavIMAP IMAP
NavMagnets Magnete
NavStatus Status
NavWordSearch Words & Stopwords
Corpus_BucketList Kategorien
Corpus_Color Farbe
Corpus_Actions Aktionen
Corpus_Clear Leeren
WordSearch_Title Word Search
WordSearch_Placeholder prefix...
WordSearch_Search Search
WordSearch_ColumnWord Word
WordSearch_ColumnBuckets Buckets
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
History_AllBuckets Alle Kategorien
History_HighlightWords Wörter nach Kategorie hervorheben
History_Loading Lade...
History_PerPage Pro Seite:
History_MoveTo — verschieben nach —
History_Moving Verschiebe...
History_Reclassifying Klassifiziere neu...
History_ReclassifyUnclassified Unkategorisierte neu einstufen
History_Selected ausgewählt
Imap_BucketFolderMappings Kategorie -> Ordner-Zuordnungen
Imap_Connected Verbunden
Imap_Connection Verbindung
Imap_ConnectionFailed Verbindung fehlgeschlagen
Imap_Description IMAP-Ordner überwachen und eingehende Nachrichten automatisch klassifizieren.
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

Language_Name                           Deutsch
Wizard_Next                             Weiter
Wizard_Manual                           Manuelle Einrichtung
Wizard_ManualDesc                       Gib die Zugangsdaten deines Mail-Servers ein.
Wizard_Encryption                       Verschlüsselung
Wizard_None                             Keine
Wizard_Done                             Fertig!
Wizard_Welcome                          Willkommen bei POPFile. POPFile hilft dir, Ordnung in deine Inbox zu bringen. Gib zuerst deinen Benutzernamen ein — meistens deine E-Mail-Adresse.
Wizard_Username                         Benutzername
