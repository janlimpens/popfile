# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-2
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          hu

# Common words that are used on their own all over the interface
Apply                                   Alkalmaz
Add                                     Hozzáad
Remove                                  Elvesz
Previous                                Előző
Next                                    Következő
From                                    Feladó
Subject                                 Téma
Reclassify                              Újraosztályoz
Undo                                    Undo
Close                                   Bezár
Bucket                                  Tartály
Magnet                                  Mágnes
Delete                                  Töröl
Create                                  Létrehoz
Total                                   Összesités
Rename                                  Átnevez

# The header and footer that appear on every UI page


Configuration_Separator                 Elválasztó karakter
Configuration_SepUpdate                 Az új elválasztó karakter: %s
Configuration_Language                  Nyelv


History_SearchMessage                   Keress feladó/téma alapján



Magnet_CurrentMagnets                   Mágnesek
Magnet_CreateNew                        Hozz létre új mágnest

Bucket_CreateBucket                     Konténer létrehozása:
Bucket_RenameBucket                     Konténer átnevezése:



# New keys added (translations batch 3)
NavCorpus Korpusz
NavHistory Előzmények
NavIMAP IMAP
NavMagnets Mágnesek
NavStatus Állapot
NavWordView Szavak
Date Dátum
Refresh Frissítés
Update Frissítés
BucketSelect_AddNew Új hozzáadása...
BucketSelect_AlreadyExists Már létezik
BucketSelect_CreateError Hiba a kategória létrehozásakor
BucketSelect_InvalidName Csak a-z, 0-9, - és _
BucketSelect_NameRequired Név szükséges
Corpus_BucketList Kategóriák
Corpus_Color Szín
Corpus_Actions Műveletek
Corpus_Clear Törlés
Corpus_StopwordsTitle Tiltott szavak
Corpus_StopwordsDesc Az ebben a listában szereplő szavakat soha nem használja a rendszer besoroláshoz.
Corpus_RemoveStopword Eltávolítás
Corpus_StopwordCandidates Tiltott szó jelöltek
Corpus_StopwordCandidatesDesc Egyenletesen előforduló szavak az összes kategóriában — csekély megkülönböztető erő.
Corpus_StopwordRatio Max/min arány küszöbérték
Corpus_LoadCandidates Jelöltek keresése
Corpus_NoCandidates Ennél a küszöbértéknél nem találhatók jelöltek.
Corpus_AddStopword Hozzáadás a tiltott szavakhoz
History_AllBuckets Összes kategória
History_HighlightWords Szavak kiemelése kategória szerint
History_Loading Betöltés...
History_MoveTo — áthelyezés ide —
History_Moving Áthelyezés...
History_Reclassifying Újrabesorolás...
History_ReclassifyUnclassified Osztályozatlanok újrabesorolása
History_Selected kijelölve
Imap_BucketFolderMappings Kategória -> Mappa-hozzárendelések
Imap_Connected Csatlakozva
Imap_Connection Kapcsolat
Imap_ConnectionFailed A kapcsolat sikertelen
Imap_Description IMAP-mappák figyelése és a bejövő üzenetek automatikus besorolása.
Imap_Expunge Törölt üzenetek végleges eltávolítása a figyelt mappákból.
Imap_FetchFolders Mappák lekérése
Imap_Fetching Lekérés...
Imap_IMAFFolder IMAP-mappa
Imap_Interval Frissítési időköz másodpercben:
Imap_Login IMAP-fiók bejelentkezési neve:
Imap_MappingsHint A besorolt üzenetek a megadott IMAP-mappába kerülnek. Hagyja üresen a nem hozzárendelt kategóriákat az áthelyezés kihagyásához.
Imap_NoConnectionMessage Kérjük, először konfigurálja a kapcsolati adatokat. Ezután ezen az oldalon több lehetőség is elérhetővé válik.
Imap_NoFoldersWatched Még nincsenek figyelt mappák.
Imap_NoMappings Nincsenek hozzárendelések.
Imap_Password IMAP-fiók jelszava:
Imap_Port IMAP-kiszolgáló portja:
Imap_SaveAnyway Mentés mindenképpen
Imap_SaveConnection Kapcsolat mentése
Imap_SaveFolders Mappák mentése
Imap_Saving Mentés...
Imap_Server IMAP-kiszolgáló hosztneve:
Imap_TestConnection Kapcsolat tesztelése
Imap_Testing Tesztelés...
Imap_TrainingHint A betanítási mód átvizsgálja a meglévő archívummappákat, és azok tartalmával betanítja a besorolót. A jelző automatikusan törlődik a betanítás befejezésekor.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Betanítási mód
Imap_TrainingLimit Üzenet mappánként (0 = korlátlan)
Imap_Use_SSL SSL használata
Imap_WatchedFolders Figyelt mappák
Imap_WatchedHint A POPFile ezeket az IMAP-mappákat figyeli az osztályozandó új üzenetek érdekében.

WordView_Title Szó pontosság
WordView_SelectBucket kategória kiválasztása
WordView_Words szavak
WordView_Loading Betöltés...
WordView_Empty Nincsenek szavak ebben a kategóriában.
WordView_ColWord Szó
WordView_ColCount Darab
WordView_ColTotal Összesen
WordView_ColAccuracy Pontosság
WordView_ColActions Műveletek
WordView_Remove Eltávolítás
WordView_MoveTo áthelyezés ide
WordView_Move Áthelyezés
Magnet_Created Mágnes létrehozva
Magnet_Deleted Mágnes törölve
Reconnect_Connecting Csatlakozás...
Reconnect_Message A háttérszolgáltatás nem érhető el. Újracsatlakozás folyamatban...
Reconnect_Now Csatlakozás most
Reconnect_RetryIn Újra próbálkozás
Reconnect_Title Kapcsolat megszakadt
Settings_AdminPassword Rendszergazdai jelszó
Settings_ArchiveDirectory Archívum könyvtár
Settings_ArchiveMessages Üzenetek archiválása
Settings_ArchiveSubdirs Archívum alkönyvtárak
Settings_AutoDetect Automatikus felismerés
Settings_AutoDetectLanguage Nyelv automatikus felismerése
Settings_ChainPort Lánc port
Settings_ChainServer Lánc kiszolgáló
Settings_DateFormat Dátumformátum
Settings_DescAdminPassword Hagyja üresen a jelszóvédelem letiltásához.
Settings_DescArchiveDir Könyvtár az archivált üzenetek számára (a felhasználói könyvtárhoz képest).
Settings_DescArchiveMessages Minden besorolt üzenetről másolat mentése lemezre.
Settings_DescArchiveSubdirs Archívum felosztása N alkönyvtárra (0 = letiltva).
Settings_DescAutoDetectLang Felismeri az egyes üzenetek nyelvét, és alkalmazza a megfelelő tiltott szavakat és szótövesítőt. ~130%-os osztályozási késleltetést ad hozzá; vegyes nyelvű postaládákhoz hasznos.
Settings_DescChainPort A felsőbb szintű SMTP-kiszolgáló portja.
Settings_DescChainServer A felsőbb szintű SMTP-kiszolgáló hosztneve.
Settings_DescDateFormat strftime formátumszöveg. Hagyja üresen a helyi alapértelmezés használatához.
Settings_DescForceFork Új folyamat létrehozása minden egyes kapcsolathoz.
Settings_DescHEADFetchesBody Teljes cikk lekérése a HEAD paranccsal.
Settings_DescHTTPPort A webes felhasználói felület által figyelt port. Újraindítás szükséges.
Settings_DescItemsPerPage Sorok száma oldalanként az Előzmények és Mágnesek nézetben.
Settings_DescLanguage Felhasználói felület megjelenítési nyelve. Hagyja üresen a böngészőből való automatikus felismeréshez.
Settings_DescListenAddress IP-cím, amelyhez kötni kell. Üres = minden interfész.
Settings_DescLocalOnly_UI A webes felhasználói felület korlátozása helyi kapcsolatokra.
Settings_DescLogDirectory Naplófájlok könyvtára. Üres = POPFile gyökér.
Settings_DescLogLevel Naplókimenet részletessége.
Settings_DescLogSQLToStdout Minden SQL-utasítás kiírása a kötött értékekkel együtt stdout-ra. Csak akkor aktív, ha a "Napló stdout-ra" is engedélyezve van.
Settings_DescLogToStdout Naplókimenet tükrözése stdout-ra a naplófájlon kívül.
Settings_DescMessageCutoff Üzenetenkénti elemzett szavak maximális száma (0 = korlátlan).
Settings_DescNNTPLocalOnly Csak helyi géptől érkező NNTP-kapcsolatok fogadása.
Settings_DescNNTPPort A POPFile által NNTP-hez figyelt port (alapértelmezett: 119).
Settings_DescNNTPSeparator A felhasználót a kiszolgálótól elválasztó karakter.
Settings_DescPOP3LocalOnly Csak helyi géptől érkező POP3-kapcsolatok fogadása.
Settings_DescPOP3Port A POPFile által POP3-hoz figyelt port (alapértelmezett: 1110).
Settings_DescPOP3Separator A felhasználót a kiszolgálótól elválasztó karakter (pl. felhasználó:levelezőkiszolgáló).
Settings_DescRetentionDays Hány napig kell megőrizni az üzenetek előzményeit.
Settings_DescSessionDividers Elválasztók megjelenítése a böngészési munkamenetek között az Előzmények nézetben.
Settings_DescSMTPLocalOnly Csak helyi géptől érkező SMTP-kapcsolatok fogadása.
Settings_DescSMTPPort A POPFile által SMTP-hez figyelt port (alapértelmezett: 25).
Settings_DescSQLiteJournal SQLite napló / WAL mód.
Settings_DescSQLiteTweaks Bitmaszk: 1 = gyorsabb írások (kevésbé biztonságos), 2 = időszakos mentés.
Settings_DescSSLChainPort A felsőbb szintű SSL POP3-kiszolgáló portja.
Settings_DescSSLChainServer A felsőbb szintű SSL POP3-kiszolgáló hosztneve SSL-láncoláshoz.
Settings_DescSubjectTagLeft A Tárgy fejlécbe beillesztett előtag, pl. [SPAM].
Settings_DescSubjectTagRight A Tárgy fejlécbe hozzáfűzött utótag.
Settings_DescTagPosition Hová kerüljön a tárgycímke.
Settings_DescTOPFetchesBody Az üzenet törzsének lekérése is a TOP paranccsal.
Settings_DescUnclassifiedWeight Valószínűségi küszöb, amely alatt a levél "osztályozatlan".
Settings_DescWordStemming Szavak visszavezetése szótövükre osztályozás előtt (pl. "fut" → "fut"). Javítja a visszahívást morfológiailag gazdag nyelveken ~10%-os késleltetési költséggel.
Settings_DescWordTable Mi jelenjen meg a szó-valószínűségi táblázatban.
Settings_ErrorSaving Mentési hiba
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD lekéri a törzset
Settings_HTTPPort HTTP port
Settings_ItemsPerPage Elemek oldalanként
Settings_ListenAddress Figyelési cím
Settings_ListenPort Figyelési port
Settings_LocalOnly Csak helyi
Settings_LogDirectory Napló könyvtár
Settings_LogLevel Naplószint
Settings_LogSQLToStdout SQL naplózása stdout-ra
Settings_LogToStdout Naplózás stdout-ra
Settings_MessageCutoff Üzenet korlát
Settings_OptDebug Hibakeresés
Settings_OptEnd Vége
Settings_OptErrorsOnly Csak hibák
Settings_OptFrequencies Gyakoriságok
Settings_OptFront Elöl
Settings_OptHidden Rejtett
Settings_OptInfo Info
Settings_OptLogScores Pontszámok naplózása
Settings_OptProbabilities Valószínűségek
Settings_OptWarnings Figyelmeztetések
Settings_RetentionDays Megőrzés (nap)
Settings_SaveChanges Változtatások mentése
Settings_Saved Mentve
Settings_Saving Mentés...
Settings_Search Beállítások keresése...
Settings_SectionClassifier Osztályozó
Settings_SectionHistory Előzmények
Settings_SectionLogging Naplózás
Settings_SectionNNTP NNTP proxy
Settings_SectionPOP3 POP3 proxy
Settings_SectionSecurity Biztonság
Settings_SectionSMTP SMTP proxy
Settings_SectionUI Felhasználói felület
Settings_ServerSeparator Kiszolgáló elválasztó
Settings_SessionDividers Munkamenet elválasztók
Settings_SQLiteJournalMode SQLite naplómód
Settings_SQLiteTweaks SQLite finomhangolás
Settings_SSLChainPort SSL lánc port
Settings_SSLChainServer SSL lánc kiszolgáló
Settings_SubjectTagLeft Tárgycímke bal
Settings_SubjectTagRight Tárgycímke jobb
Settings_TagPosition Címke pozíció
Settings_TOPFetchesBody TOP lekéri a törzset
Settings_UnclassifiedWeight Osztályozatlan súly
Settings_WordStemming Szótövesítés
Settings_WordTable Szótáblázat
Status_Checking Ellenőrzés...
Status_Description POPFile-szolgáltatások állapotellenőrzései.
Status_LoadError Az állapot betöltése sikertelen
Status_NoChecks Nem állnak rendelkezésre ellenőrzések.

Language_Name                           Magyar
History_PerPage                          Bejegyzés oldalanként
Imap_Advanced                            Haladó
Imap_Cancel                              Mégse
Imap_Wizard                              Beállítási varázsló
Imap_WizardApply                         Létrehozás és hozzárendelés
Imap_WizardClose                         Bezárás
Imap_WizardDesc                          Válasszon mappákat, amelyekhez vödröket és hozzárendeléseket hoz létre.
Imap_WizardDeselectAll                   Kijelölés megszüntetése
Imap_WizardDone                          {count} kategória létrehozva és hozzárendelve.
Imap_WizardEmpty                         Nem található további mappa a kiszolgálón.
Imap_WizardSelectAll                     Összes kiválasztása
Imap_WizardTrain                         Edzés most
NavWordSearch                            Szókeresés
Settings_DescEnableProxy                 Proxy indítása a POPFile indulásakor.
Settings_DescLogFormat                   Napló kimeneti formátuma (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Böngésző automatikus megnyitása indításkor.
Settings_DescSQLiteBackup                Adatbázis automatikus biztonsági mentése séma módosítása előtt.
Settings_DescSQLiteFastWrites            Adatbázis szinkronizáció letiltása (gyorsabb, kevésbé biztonságos).
Settings_EnableService                   Szolgáltatás engedélyezése
Settings_LogFormat                       Napló formátum
Settings_OpenBrowser                     Böngésző megnyitása
Settings_SQLiteBackup                    SQLite biztonsági mentés
Settings_SQLiteFastWrites                SQLite gyors írás
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Tiltószó hozzáadása
WordSearch_ColumnBuckets                 Kategóriák
WordSearch_ColumnWord                    Szó
WordSearch_IsStopword                    Tiltószó
WordSearch_Loading                       Betöltés...
WordSearch_NoResults                     Nincs találat.
WordSearch_NoStopwords                   Nincsenek tiltószavak.
WordSearch_Placeholder                   Írjon be egy szót...
WordSearch_RemoveStopword                Tiltószó eltávolítása
WordSearch_Search                        Keresés
WordSearch_StopwordList                  Tiltószó lista
WordSearch_Title                         Szókeresés
WordSearch_Total                         Összesen
