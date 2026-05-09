# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-2
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual

ManualLanguage                          en

# Common words that are used on their own all over the interface

Apply                                   Zatwierdź
Add                                     Dodaj
Remove                                  Usuń
Previous                                Poprzedni
Next                                    Następny
From                                    Od
Subject                                 Temat
Reclassify                              Klasyfikuj
Undo                                    Cofnij
Close                                   Zamknij
Bucket                                  Folder
Magnet                                  Musik
Delete                                  Skasuj
Create                                  Utwórz
Total                                   Całkowity
Rename                                  Zmień
Update                                  Aktualizuj
Refresh                                 Odśwież

# The header and footer that appear on every UI page

Configuration_Language                  Język

History_SearchMessage                   Szukaj wg pól Od/Temat
History_ShowNoMagnet                    odmusikowane

Magnet_CurrentMagnets                   Aktualne musiki
Magnet_CreateNew                        Utwórz nowy musik

Bucket_CreateBucket                     Utwórz folder o nazwie
Bucket_RenameBucket                     Zmień nazwę folderu

# New keys added (translations batch 4)
NavCorpus Korpus
NavHistory Historia
NavIMAP IMAP
NavMagnets Magnesy
NavStatus Status
NavWordView Słowa
BucketSelect_AddNew Dodaj nową...
BucketSelect_AlreadyExists Już istnieje
BucketSelect_CreateError Błąd podczas tworzenia kategorii
BucketSelect_InvalidName Tylko a-z, 0-9, - i _
BucketSelect_NameRequired Nazwa jest wymagana
Corpus_BucketList Kategorie
Corpus_Color Kolor
Corpus_Actions Akcje
Corpus_Clear Wyczyść
Corpus_StopwordsTitle Stoplisty
Corpus_StopwordsDesc Słowa na tej liście nigdy nie są używane do klasyfikacji.
Corpus_RemoveStopword Usuń
Corpus_StopwordCandidates Kandydaci na słowa stoplisty
Corpus_StopwordCandidatesDesc Słowa pojawiające się równomiernie we wszystkich kategoriach — mała moc dyskryminacyjna.
Corpus_StopwordRatio Próg współczynnika maks/min
Corpus_LoadCandidates Znajdź kandydatów
Corpus_NoCandidates Nie znaleziono kandydatów przy tym progu.
Corpus_AddStopword Dodaj do stoplisty
Date Data
History_AllBuckets Wszystkie kategorie
History_HighlightWords Podświetl słowa według kategorii
History_Loading Ładowanie...
History_MoveTo — przenieś do —
History_Moving Przenoszenie...
History_Reclassifying Przeklasyfikowywanie...
History_ReclassifyUnclassified Przeklasyfikuj niesklasyfikowane
History_Selected zaznaczono
Imap_BucketFolderMappings Kategoria -> Przypisania folderów
Imap_Connected Połączono
Imap_Connection Połączenie
Imap_ConnectionFailed Połączenie nieudane
Imap_Description Monitoruj foldery IMAP i automatycznie klasyfikuj przychodzące wiadomości.
Imap_Expunge Usuń trwale wiadomości skasowane z monitorowanych folderów.
Imap_FetchFolders Pobierz foldery
Imap_Fetching Pobieranie...
Imap_IMAFFolder Folder IMAP
Imap_Interval Interwał aktualizacji w sekundach:
Imap_Login Nazwa logowania konta IMAP:
Imap_MappingsHint Sklasyfikowane wiadomości są przenoszone do wskazanego folderu IMAP. Zostaw nieprzypisane kategorie puste, aby pominąć przenoszenie.
Imap_NoConnectionMessage Najpierw skonfiguruj szczegóły połączenia. Potem na tej stronie pojawią się dodatkowe opcje.
Imap_NoFoldersWatched Brak monitorowanych folderów.
Imap_NoMappings Nie zdefiniowano przypisań.
Imap_Password Hasło do konta IMAP:
Imap_Port Port serwera IMAP:
Imap_SaveAnyway Zapisz mimo to
Imap_SaveConnection Zapisz połączenie
Imap_SaveFolders Zapisz foldery
Imap_Saving Zapisywanie...
Imap_Server Nazwa hosta serwera IMAP:
Imap_TestConnection Testuj połączenie
Imap_Testing Testowanie...
Imap_TrainingHint Tryb treningowy skanuje istniejące foldery archiwum i trenuje klasyfikator na ich zawartości. Flaga resetuje się automatycznie po zakończeniu treningu.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Tryb treningowy
Imap_TrainingLimit Wiadomości na folder (0 = bez limitu)
Imap_Use_SSL Użyj SSL
Imap_WatchedFolders Monitorowane foldery
Imap_WatchedHint POPFile monitoruje te foldery IMAP w poszukiwaniu nowych wiadomości do sklasyfikowania.

WordView_Title Dokładność słów
WordView_SelectBucket wybierz kategorię
WordView_Words słowa
WordView_Loading Ładowanie...
WordView_Empty Brak słów w tej kategorii.
WordView_ColWord Słowo
WordView_ColCount Liczba
WordView_ColTotal Łącznie
WordView_ColAccuracy Dokładność
WordView_ColActions Akcje
WordView_Remove Usuń
WordView_MoveTo przenieś do
WordView_Move Przenieś
Magnet_Created Magnes utworzony
Magnet_Deleted Magnes usunięty
Reconnect_Connecting Łączenie...
Reconnect_Message Backend jest nieosiągalny. Próba ponownego połączenia...
Reconnect_Now Połącz teraz
Reconnect_RetryIn Ponowna próba za
Reconnect_Title Utracono połączenie
Settings_AdminPassword Hasło administratora
Settings_ArchiveDirectory Katalog archiwum
Settings_ArchiveMessages Archiwizuj wiadomości
Settings_ArchiveSubdirs Podkatalogi archiwum
Settings_AutoDetect Wykryj automatycznie
Settings_AutoDetectLanguage Wykryj język automatycznie
Settings_ChainPort Port łańcucha
Settings_ChainServer Serwer łańcucha
Settings_DateFormat Format daty
Settings_DescAdminPassword Pozostaw puste, aby wyłączyć ochronę hasłem.
Settings_DescArchiveDir Katalog dla zarchiwizowanych wiadomości (względem katalogu użytkownika).
Settings_DescArchiveMessages Zapisz kopię każdej sklasyfikowanej wiadomości na dysk.
Settings_DescArchiveSubdirs Podziel archiwum na N podkatalogów (0 = wyłączone).
Settings_DescAutoDetectLang Wykrywa język każdej wiadomości i stosuje pasujące słowa stoplisty i stemmer. Dodaje ~130% opóźnienia klasyfikacji; przydatne dla skrzynek z wieloma językami.
Settings_DescChainPort Port nadrzędnego serwera SMTP.
Settings_DescChainServer Nazwa hosta nadrzędnego serwera SMTP.
Settings_DescDateFormat Ciąg formatujący strftime. Pozostaw puste dla domyślnego ustawienia regionalnego.
Settings_DescForceFork Utwórz nowy proces dla każdego połączenia.
Settings_DescHEADFetchesBody Pobierz pełny artykuł poleceniem HEAD.
Settings_DescHTTPPort Port, na którym nasłuchuje interfejs webowy. Wymaga restartu.
Settings_DescItemsPerPage Wiersze wyświetlane na stronie w Historii i Magnesach.
Settings_DescLanguage Język wyświetlania interfejsu. Pozostaw puste dla automatycznego wykrywania z przeglądarki.
Settings_DescListenAddress Adres IP do powiązania. Puste = wszystkie interfejsy.
Settings_DescLocalOnly_UI Ogranicz interfejs webowy do połączeń lokalnych.
Settings_DescLogDirectory Katalog dla plików dziennika. Puste = katalog główny POPFile.
Settings_DescLogLevel Szczegółowość dziennika.
Settings_DescLogSQLToStdout Drukuj każde polecenie SQL z wartościami na stdout. Aktywne tylko gdy "Dziennik na stdout" jest też włączony.
Settings_DescLogToStdout Lustrzane kopiowanie dziennika na stdout oprócz pliku dziennika.
Settings_DescMessageCutoff Maksymalna liczba analizowanych słów na wiadomość (0 = bez limitu).
Settings_DescNNTPLocalOnly Akceptuj połączenia NNTP tylko z lokalnego hosta.
Settings_DescNNTPPort Port, na którym POPFile nasłuchuje dla NNTP (domyślnie 119).
Settings_DescNNTPSeparator Znak oddzielający użytkownika od serwera.
Settings_DescPOP3LocalOnly Akceptuj połączenia POP3 tylko z lokalnego hosta.
Settings_DescPOP3Port Port, na którym POPFile nasłuchuje dla POP3 (domyślnie 1110).
Settings_DescPOP3Separator Znak oddzielający użytkownika od serwera (np. użytkownik:serwer).
Settings_DescRetentionDays Ile dni przechowywać historię wiadomości.
Settings_DescSessionDividers Pokaż separatory między sesjami przeglądania w Historii.
Settings_DescSMTPLocalOnly Akceptuj połączenia SMTP tylko z lokalnego hosta.
Settings_DescSMTPPort Port, na którym POPFile nasłuchuje dla SMTP (domyślnie 25).
Settings_DescSQLiteJournal Tryb dziennika SQLite / WAL.
Settings_DescSQLiteTweaks Maska bitowa: 1 = szybszy zapis (mniej bezpieczny), 2 = okresowa kopia zapasowa.
Settings_DescSSLChainPort Port nadrzędnego serwera SSL POP3.
Settings_DescSSLChainServer Nazwa hosta nadrzędnego serwera SSL POP3 dla łańcuchowania SSL.
Settings_DescSubjectTagLeft Prefiks wstawiany do nagłówka Temat, np. [SPAM].
Settings_DescSubjectTagRight Sufiks dołączany do nagłówka Temat.
Settings_DescTagPosition Gdzie umieścić znacznik tematu.
Settings_DescTOPFetchesBody Pobierz też treść wiadomości poleceniem TOP.
Settings_DescUnclassifiedWeight Próg prawdopodobieństwa, poniżej którego poczta jest "niesklasyfikowana".
Settings_DescWordStemming Redukuj słowa do ich rdzenia przed klasyfikacją (np. "bieganie" → "bieg"). Poprawia recall dla języków morfologicznie bogatych przy ~10% koszcie opóźnienia.
Settings_DescWordTable Co wyświetlać w tabeli prawdopodobieństwa słów.
Settings_ErrorSaving Błąd podczas zapisywania
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD pobiera treść
Settings_HTTPPort Port HTTP
Settings_ItemsPerPage Elementów na stronie
Settings_ListenAddress Adres nasłuchu
Settings_ListenPort Port nasłuchu
Settings_LocalOnly Tylko lokalnie
Settings_LogDirectory Katalog dziennika
Settings_LogLevel Poziom dziennika
Settings_LogSQLToStdout Dziennik SQL na stdout
Settings_LogToStdout Dziennik na stdout
Settings_MessageCutoff Limit wiadomości
Settings_OptDebug Debugowanie
Settings_OptEnd Koniec
Settings_OptErrorsOnly Tylko błędy
Settings_OptFrequencies Częstości
Settings_OptFront Przód
Settings_OptHidden Ukryty
Settings_OptInfo Info
Settings_OptLogScores Dziennik wyników
Settings_OptProbabilities Prawdopodobieństwa
Settings_OptWarnings Ostrzeżenia
Settings_RetentionDays Retencja (dni)
Settings_SaveChanges Zapisz zmiany
Settings_Saved Zapisano
Settings_Saving Zapisywanie...
Settings_Search Szukaj ustawień...
Settings_SectionClassifier Klasyfikator
Settings_SectionHistory Historia
Settings_SectionLogging Rejestrowanie
Settings_SectionNNTP Proxy NNTP
Settings_SectionPOP3 Proxy POP3
Settings_SectionSecurity Bezpieczeństwo
Settings_SectionSMTP Proxy SMTP
Settings_SectionUI Interfejs użytkownika
Settings_ServerSeparator Separator serwera
Settings_SessionDividers Separatory sesji
Settings_SQLiteJournalMode Tryb dziennika SQLite
Settings_SQLiteTweaks Ulepszenia SQLite
Settings_SSLChainPort Port łańcucha SSL
Settings_SSLChainServer Serwer łańcucha SSL
Settings_SubjectTagLeft Znacznik tematu po lewej
Settings_SubjectTagRight Znacznik tematu po prawej
Settings_TagPosition Pozycja znacznika
Settings_TOPFetchesBody TOP pobiera treść
Settings_UnclassifiedWeight Waga niesklasyfikowanych
Settings_WordStemming Stemming słów
Settings_WordTable Tabela słów
Status_Checking Sprawdzanie...
Status_Description Kontrole stanu usług POPFile.
Status_LoadError Nie udało się załadować statusu
Status_NoChecks Brak dostępnych kontroli.

Language_Name                           Polski
History_PerPage                          Wpisów na stronę
Imap_Advanced                            Zaawansowane
Imap_Cancel                              Anuluj
Imap_Wizard                              Kreator konfiguracji
Imap_WizardApply                         Utwórz i mapuj
Imap_WizardClose                         Zamknij
Imap_WizardDesc                          Wybierz foldery, dla których utworzyć zasobniki i mapowania.
Imap_WizardDeselectAll                   Odznacz wszystkie
Imap_WizardDone                          Utworzono i zmapowano {count} kategorii.
Imap_WizardEmpty                         Nie znaleziono dodatkowych folderów na serwerze.
Imap_WizardSelectAll                     Zaznacz wszystkie
Imap_WizardTrain                         Trenuj teraz
NavWordSearch                            Szukanie słów
Settings_DescEnableProxy                 Uruchom to proxy przy starcie POPFile.
Settings_DescLogFormat                   Format wyjścia dziennika (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Automatycznie otwórz przeglądarkę przy starcie.
Settings_DescSQLiteBackup                Automatycznie twórz kopię zapasową bazy przed zmianami schematu.
Settings_DescSQLiteFastWrites            Wyłącz synchronizację bazy danych (szybciej, mniej bezpiecznie).
Settings_EnableService                   Włącz usługę
Settings_LogFormat                       Format dziennika
Settings_OpenBrowser                     Otwórz przeglądarkę
Settings_SQLiteBackup                    Kopia zapasowa SQLite
Settings_SQLiteFastWrites                Szybki zapis SQLite
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Dodaj stop słowo
WordSearch_ColumnBuckets                 Kategorie
WordSearch_ColumnWord                    Słowo
WordSearch_IsStopword                    Stop słowo
WordSearch_Loading                       Ładowanie...
WordSearch_NoResults                     Brak wyników.
WordSearch_NoStopwords                   Brak stop słów.
WordSearch_Placeholder                   Wpisz słowo...
WordSearch_RemoveStopword                Usuń stop słowo
WordSearch_Search                        Szukaj
WordSearch_StopwordList                  Lista stop słów
WordSearch_Title                         Szukanie słów
WordSearch_Total                         Razem
