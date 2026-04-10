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
LanguageCode                            hu
LanguageCharset                         ISO-8859-2
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          hu

# Common words that are used on their own all over the interface
Apply                                   Alkalmaz
On                                      Be
Off                                     Ki
TurnOn                                  Bekapcsol
TurnOff                                 Kikapcsol
Add                                     Hozzáad
Remove                                  Elvesz
Previous                                Előző
Next                                    Következő
From                                    Feladó
Subject                                 Téma
Classification                          Osztályozás
Reclassify                              Újraosztályoz
Undo                                    Undo
Close                                   Bezár
Find                                    Keres
Filter                                  Szűrő
Yes                                     Igen
No                                      Nem
ChangeToYes                             Kapcsold Igen-re
ChangeToNo                              Kapcsold Nem-re
Bucket                                  Tartály
Magnet                                  Mágnes
Delete                                  Töröl
Create                                  Létrehoz
To                                      Cimzett
Total                                   Összesités
Rename                                  Átnevez
Frequency                               Frekvencia
Probability                             Valószinűség
Score                                   Pontszám
Lookup                                  Lookup

# The header and footer that appear on every UI page
Header_Title                            POPFile Vezérlőközpont
Header_Shutdown                         Shutdown POPFile
Header_History                          History
Header_Buckets                          Tartályok
Header_Configuration                    Beállitások
Header_Advanced                         Haladó
Header_Security                         Biztonság
Header_Magnets                          Mágnesek

Footer_HomePage                         POPFile Honlap
Footer_Manual                           Kézikönyv
Footer_Forums                           Fórumok
Footer_FeedMe                           Adj enni!
Footer_RequestFeature                   Tulajdonság kérése
Footer_MailingList                      Levlista

Configuration_Error1                    Az elválasztó karakter nem lehet hosszabb 1 karakternél
Configuration_Error2                    A felhasználói interfész port egy szám kell hogy legyen 1 és 65535 között.
Configuration_Error3                    A POP3 port egy szám kell hogy legyen 1 és 65535 között.
Configuration_Error4                    A lapszám egy szám kell hogy legyen 1 és 1000 között.
Configuration_Error5                    A history-ban lévő napok száma egy szám kell hogy legyen 1 és 366 között.
Configuration_Error6                    A TCP időtúllépés egy szám kell hogy legyen 10 és 1800 között.
Configuration_POP3Port                  POP3 figyelő port
Configuration_POP3Update                Az új port: %s; A változtatás életbeléptetéséhez újra kell inditanod POPFile-t.
Configuration_Separator                 Elválasztó karakter
Configuration_SepUpdate                 Az új elválasztó karakter: %s
Configuration_UI                        Felhasználói interfész web port
Configuration_UIUpdate                  Az új felhasználói interfész web port %s; A változtatás életbeléptetéséhez újra kell inditanod POPFile-t.
Configuration_History                   Egy lapon lévő emailek száma
Configuration_HistoryUpdate             Az egy lapon lévő emailek száma megváltozott: %s
Configuration_Days                      A history-ban megőrizendő napok száma
Configuration_DaysUpdate                A history-ban megőrizendő napok számának új értéke: %s
Configuration_UserInterface             Felhasználói felület
Configuration_Skins                     Skinek
Configuration_SkinsChoose               Válassz skin-t
Configuration_Language                  Nyelv
Configuration_LanguageChoose            Válassz nyelvet
Configuration_ListenPorts               Figyelj portokon
Configuration_HistoryView               History Nézet
Configuration_TCPTimeout                TCP Kapcsolat Timeout
Configuration_TCPTimeoutSecs            TCP kapcsolat timeout másodpercekben
Configuration_TCPTimeoutUpdate          A TCP kapcsolat timeout új értéke: %s
Configuration_ClassificationInsertion   Osztályozás beillesztés
Configuration_SubjectLine               Beillesztés az email témájába
Configuration_XTCInsertion              X-Text-Classification alkalmazása
Configuration_XPLInsertion              X-POPFile-Link beillesztése
Configuration_Logging                   Naplózás
Configuration_None                      Nincs
Configuration_ToScreen                  Képernyőre
Configuration_ToFile                    Fájlba
Configuration_ToScreenFile              Képernyőre és fájlba
Configuration_LoggerOutput              Naplózó kimenet

Advanced_Error1                         '%s' már hozzá lett adva a blokkoló szavakhoz
Advanced_Error2                         A figyelmen kivül hagyott szavak csak betűket, számokat és a következő karaktereket tartalmayhatják:, ., _, -, @
Advanced_Error3                         '%s' hozzáadva a blokkolt szavak listájához
Advanced_Error4                         '%s' nincs a blokkolt szavak között
Advanced_Error5                         '%s' törölve a blokkolt szavak közúl
Advanced_StopWords                      Figyelmen kivűl hagyott szavak
Advanced_Message1                       A következő szavak minden osztályozásból ki fognak maradni, mivel túl sűrűn fordulnak elő.
Advanced_AddWord                        Szó hozzáadása
Advanced_RemoveWord                     Szó törlése

History_Filter                          &nbsp;(csak a <font color=%s>%s</font> konténer tartalma látható)
History_Search                          &nbsp;(Találatok %s témára)
History_Title                           Utoljára beérkezett üzenetek
History_Jump                            Üzenetre ugrás
History_ShowAll                         Mutasd mindet
History_ShouldBe                        Kellene lennie
History_NoFrom                          nincs feladó
History_NoSubject                       nincs téma
History_ClassifyAs                      Osztályozd mint
History_MagnetUsed                      Eltéritő mágnes:
History_ChangedTo                       Új érték: <font color=%s>%s
History_Already                         Újraosztályozva mint <font color=%s>%s</font>
History_RemoveAll                       Mindet töröl
History_RemovePage                      Töröld ezt az oldalt
History_Remove                          Klikkelj hogy töröld a bejegyzéseket a History-ból
History_SearchMessage                   Keress feladó/téma alapján
History_NoMessages                      Nincs üzenet
History_ShowMagnet                      Mágnesezett
History_Magnet                          &nbsp;(Csak mágnesek által osztályozott üzenetek látszanak)
History_ResetSearch                     Nullázás

Password_Title                          Jelszó
Password_Enter                          Ird be a jelszót
Password_Go                             Mehet!
Password_Error1                         Rossz jelszó

Security_Error1                         A secure port egy szám kell hogy legyen 1 és 65535 között
Security_Stealth                        Lopakodó (Stealth) Üzemmód/Szerver Múködés
Security_NoStealthMode                  Nem (Stealth Üzemmód)
Security_ExplainStats                   (Ha ez be van kapcsolva, akkor a POPFile naponta egyszer elküldi a következő 3 változó értékét egy script-nek a getpopfile.org-ra: bc (a konténerek száma) mc (a POPFile által osztályozott üzenetek száma) ec (az osztályozási hibák száma). Ezeket az adatokat egy állomámyban tartom, és arra használom őket hogy néhány statisztikai adatok publikáljak a POPFile hatékonyságáról és arról hogy az emberek hogyan hasynálják a programot. A Web szerverem kb. 5 napig őrzi meg az információt, majd törli. Nem tárolok semmiféle kapcsolatot a begyűjtött adatok és az IP cimek között.)
Security_ExplainUpdate                  (Ha ez be van kapcsolva, akkor a POPFile naponta egyszer elküldi a következő 3 változó értékét egy script-nek a getpopfile.org-ra: ma (az általad használt POPFile fő verziószáma) mi (az általad használt POPFile al-verziószáma) bn (az általad használt POPFile build száma). Az általad használt POPFile kapni fog egy grafikát a szervertől, ami a lap tetején lesz látható ha egy újabb verzió elérhető. Ezeket az adatokat egy állomámyban tartom, és arra használom őket hogy néhány statisztikai adatok publikáljak a POPFile hatékonyságáról és arról hogy az emberek hogyan hasynálják a programot. A Web szerverem kb. 5 napig őrzi meg az információt, majd törli. Nem tárolok semmiféle kapcsolatot a begyűjtött adatok és az IP cimek között.) 
Security_PasswordTitle                  Felhaszálói felület jelszó
Security_Password                       Jelszó
Security_PasswordUpdate                 Az új jelszó: %s
Security_AUTHTitle                      Secure Password Authentication/AUTH
Security_SecureServer                   Secure szerver
Security_SecureServerUpdate             Az új secure szerver: %s; Ez a változás nem fog érvénybe lépni amig ujra nem inditod a POPFile-t.
Security_SecurePort                     Secure port
Security_SecurePortUpdate               Az új port: %s; Ez a változás nem fog érvénybe lépni amig ujra nem inditod a POPFile-t.
Security_POP3                           POP3 kapcsolat engedélyezése távoli gépekkel
Security_UI                             HTTP (Felhasználói felület) engedélyezése távoli gépekkel
Security_UpdateTitle                    Automatikus új verzió ellenőrzés
Security_Update                         Naponta ellenőrizze hogy van-e új POPFile verzió
Security_StatsTitle                     Statisztika küldése
Security_Stats                          Küldd el a statisztikákat Johnünak minden nap

Magnet_Error1                           A mágnes '%s' már létezik a '%s' konténerben
Magnet_Error2                           Az új mágnes '%s' összeragadhat a '%s' mágnessel és hibás eredményeket okozhat a '%s' konténerben. Az új mágnes nem lett hozzáadva a rendszerhez.
Magnet_Error3                           Hozd létre a '%s' mágnest a '%s' konténerben.
Magnet_CurrentMagnets                   Mágnesek
Magnet_Message1                         A következő mágnes minden egyes levelet a megadott konténerbe fog irányitani.
Magnet_CreateNew                        Hozz létre új mágnest
Magnet_Explanation                      Három fajta mágnes létezik: <ul><li><b>Feladó cime vagy neve:</b> Például: john@company.com, ha egy bizonyos email cimet keresünk<br>company.com ha mindenkit meg akarunk találni aki a company.com cimről jön, <br>"John Doe" ha egy bizonyos embert akarunk kiszűrni, John meg fog találni minden John-t<li><b>Cimyett cime vagy neve:</b> Ugyanaz mint a Feladó, de ez a Cimzett nevében és cimében keres.<li><b>Téma:</b> Például: hello meg fog találni minden email-t aminek a szó "hello" a témájában szerepel</ul>
Magnet_MagnetType                       Mágnes tipus
Magnet_Value                            Érték
Magnet_Always                           Mindig a konténerbe megy

Bucket_Error1                           Konténer nevek csak kisbetűket tartalmazhatnak a-tól z-ig, valamint a - és _ jeleket
Bucket_Error2                           Már létezik egy %s nevű konténer
Bucket_Error3                           A %s nevű konténer létrehozva
Bucket_Error4                           Kérem adjon meg egy nem-üres szót
Bucket_Error5                           Konténer átnevezve %-ról %s-ra
Bucket_Error6                           A %s nevű konténert töröltem
Bucket_Title                            Összefoglaló
Bucket_BucketName                       Konténer név
Bucket_WordCount                        Szavak száma
Bucket_WordCounts                       Szavak számai
Bucket_UniqueWords                      Egyedi szavak
Bucket_SubjectModification              Téma megváltoztatás
Bucket_ChangeColor                      Szin megváltoztatása
Bucket_NotEnoughData                    Nincs elég adat
Bucket_ClassificationAccuracy           Az osztályozás pontossága
Bucket_EmailsClassified                 Osztályozott Emailek száma
Bucket_EmailsClassifiedUpper            Osztályozott Emailek száma
Bucket_ClassificationErrors             Osztályozási hibák
Bucket_Accuracy                         Pontosság
Bucket_ClassificationCount              Osztályozások száma
Bucket_ResetStatistics                  Statisztika nullázása
Bucket_LastReset                        Utolsó nullázás
Bucket_CurrentColor                     %s a jelenlgi szin %s
Bucket_SetColorTo                       %s szin %s-ra állitása
Bucket_Maintenance                      Karbantartás
Bucket_CreateBucket                     Konténer létrehozása:
Bucket_DeleteBucket                     Konténer törlése:
Bucket_RenameBucket                     Konténer átnevezése:
Bucket_Lookup                           Keresés
Bucket_LookupMessage                    Szó keresése a konténerekben
Bucket_LookupMessage2                   Keresés eredménye:
Bucket_LookupMostLikely                 <b>%s</b> legvalószinűbben a következő helyen fog megjelenni: <font color=%s>%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> egyik konténerben sem található
Bucket_DisabledGlobally                 Globálisan letiltott
Bucket_To                               to
Bucket_Quarantine                       Karantén

SingleBucket_Title                      %s részletei
SingleBucket_WordCount                  Konténerben lévő szavak száma
SingleBucket_TotalWordCount             Összes szó száma
SingleBucket_Percentage                 Teljes százalék
SingleBucket_WordTable                  Szótáblázat % -nak
SingleBucket_Message1                   A csillaggal jelölt szavak(*) részt vettek az osztályzásban a POPFile legutóbbi inditása óta. Kattints egy szóra hogy megnézd a konténerenkénti valószinűségét.
SingleBucket_Unique                     %s egyedi

Session_Title                           POPFile Session Lejárt
Session_Error                           Ez a POPFile session lejárt.  Egy lehetséges ok hogy elinditotta és leállitotta a POPFile-t, de a böngészőt nyitva hagyta. Kérem kattintson a felül lévő linkek egyikére.

# New keys added (translations batch 3)
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpusz
NavHistory Előzmények
NavIMAP IMAP
NavMagnets Mágnesek
NavSettings Beállítások
NavStatus Állapot
ApplyChanges Változtatások alkalmazása
Arrived Érkezett
Cc Másolat
Count Darab
Date Dátum
FAQ GYIK
Footer_Wiki Dokumentáció
Header_MenuSummary Ez a táblázat a navigációs menü, amely hozzáférést biztosít a vezérlőközpont különböző oldalaihoz.
ID Azonosító
Probability Valószínűség
QuickMagnets GyorsMágnesek
Refresh Frissítés
Scores Pontszámok
Shutdown_Message A POPFile leállt
Size Méret
Update Frissítés
Word Szó
Advanced_AllParameters Összes POPFile-paraméter
Advanced_ConfigFile Konfigurációs fájl:
Advanced_MainTableSummary Ez a táblázat tartalmazza a POPFile által figyelmen kívül hagyott szavak listáját.
Advanced_Parameter Paraméter
Advanced_Value Érték
Advanced_Warning Ez a POPFile-paraméterek teljes listája. Csak haladó felhasználóknak: bármit megváltoztathat és a Frissítés gombra kattinthat; nincs érvényesség-ellenőrzés. A félkövéren szedett elemek az alapértelmezéstől eltérnek.
Bucket_AccuracyChartSummary Ez a táblázat grafikusan ábrázolja az üzenetbesorolás pontosságát.
Bucket_BarChartSummary Ez a táblázat grafikusan ábrázolja a különböző kategóriák százalékos megoszlását.
Bucket_ClassificationFN Téves negatív
Bucket_ClassificationFP Téves pozitív
Bucket_InIgnoredWords <b>%s</b> az figyelmen kívül hagyott szavak között van. A POPFile figyelmen kívül hagyja ezt a szót
Bucket_LookupResultsSummary Ez a táblázat a korpusz bármely adott szavához tartozó valószínűségeket mutatja.
Bucket_MainTableSummary Ez a táblázat áttekintést nyújt a besorolási kategóriákról.
Bucket_MaintenanceTableSummary Ez a táblázat kategóriák létrehozására, törlésére és átnevezésére szolgáló űrlapokat tartalmaz.
Bucket_StatisticsTableSummary Ez a táblázat három statisztikakészletet tartalmaz a POPFile általános teljesítményéről.
Bucket_WordListTableSummary Ez a táblázat egy adott kategória összes szavát listázza.
BucketSelect_AddNew Új hozzáadása...
BucketSelect_AlreadyExists Már létezik
BucketSelect_CreateError Hiba a kategória létrehozásakor
BucketSelect_InvalidName Csak a-z, 0-9, - és _
BucketSelect_NameRequired Név szükséges
Configuration_CurrentLogFile &lt;Jelenlegi naplófájl megtekintése&gt;
Configuration_Error7 Az XML RPC figyelő portnak 1 és 65535 közötti számnak kell lennie
Configuration_Error8 A SOCKS V proxy portnak 1 és 65535 közötti számnak kell lennie
Configuration_Error9 A felhasználói felület portja nem lehet ugyanaz, mint a POP3 figyelő port
Configuration_Error10 A POP3 figyelő port nem lehet ugyanaz, mint a felhasználói felület portja
Configuration_Fields Előzmény-oszlopok
Configuration_GeneralSkins Témák
Configuration_InsertionTableSummary Ez a táblázat gombokat tartalmaz, amelyek meghatározzák, hogy bizonyos módosítások történnek-e az üzenet fejléceiben.
Configuration_MainTableSummary Ez a táblázat számos űrlapot tartalmaz a POPFile konfigurációjának vezérléséhez.
Configuration_NNTPFork Párhuzamos NNTP-kapcsolatok engedélyezése
Configuration_NNTPPort NNTP figyelő port
Configuration_NNTPSeparator NNTP gazdagép:port:felhasználó elválasztó karakter
Configuration_NNTPSepUpdate NNTP elválasztó frissítve erre: %s
Configuration_NNTPUpdate NNTP port frissítve erre: %s; a változás a POPFile újraindítása után lép érvénybe
Configuration_POP3Separator POP3 gazdagép:port:felhasználó elválasztó karakter
Configuration_POP3SepUpdate POP3 elválasztó frissítve erre: %s
Configuration_POPFork Párhuzamos POP3-kapcsolatok engedélyezése
Configuration_SmallSkins Kis témák
Configuration_SMTPFork Párhuzamos SMTP-kapcsolatok engedélyezése
Configuration_SMTPPort SMTP figyelő port
Configuration_SMTPUpdate SMTP port frissítve erre: %s; a változás a POPFile újraindítása után lép érvénybe
Configuration_SOCKSPort SOCKS V proxy port
Configuration_SOCKSPortUpdate SOCKS V proxy port frissítve erre: %s
Configuration_SOCKSServer SOCKS V proxy gazdagép
Configuration_SOCKSServerUpdate SOCKS V proxy gazdagép frissítve erre: %s
Configuration_TinySkins Apró témák
Configuration_XMLRPCPort XML-RPC figyelő port
Configuration_XMLRPCUpdate XML-RPC port frissítve erre: %s; a változás a POPFile újraindítása után lép érvénybe
Corpus_BucketList Kategóriák
Corpus_Color Szín
Corpus_Actions Műveletek
Corpus_Clear Törlés
Corpus_Search Keresés
Corpus_StopwordsTitle Tiltott szavak
Corpus_StopwordsDesc Az ebben a listában szereplő szavakat soha nem használja a rendszer besoroláshoz.
Corpus_RemoveStopword Eltávolítás
Corpus_StopwordCandidates Tiltott szó jelöltek
Corpus_StopwordCandidatesDesc Egyenletesen előforduló szavak az összes kategóriában — csekély megkülönböztető erő.
Corpus_StopwordRatio Max/min arány küszöbérték
Corpus_LoadCandidates Jelöltek keresése
Corpus_NoCandidates Ennél a küszöbértéknél nem találhatók jelöltek.
Corpus_AddStopword Hozzáadás a tiltott szavakhoz
Help_Bucket_Setup A POPFile legalább két kategóriát igényel az "osztályozatlan" álkategórián kívül. A POPFile egyedülállósága abban rejlik, hogy az e-maileket ennél több kategóriába is besorolhatja; tetszőleges számú kategóriát hozhat létre. Egy egyszerű konfiguráció lehet egy "spam", "személyes" és "munka" kategória.
Help_No_More Ne mutasd ezt újra
Help_Training Amikor először használja a POPFile-t, semmit sem tud, és betanításra van szüksége. A POPFile minden kategóriához üzeneteken alapuló betanítást igényel; a betanítás akkor történik, amikor egy tévesen besorolt üzenetet átsorol a helyes kategóriába. Mielőtt a POPFile besorolná az első üzenetet, legalább két kategóriába kell átsorolt üzeneteknek lenniük.
History_AllBuckets Összes kategória
History_Automatic Automatikus
History_ChangedClass Most így sorolná be
History_Column_Characters Feladó, Címzett, Másolat és Tárgy oszlopok szélességének módosítása
History_Decrease Csökkentés
History_FilterBy Szűrés
History_HighlightWords Szavak kiemelése kategória szerint
History_Increase Növelés
History_Loading Betöltés...
History_MagnetBecause <b>Mágnes alkalmazva</b><p>Besorolva ide: <font color="%s">%s</font> a következő mágnes miatt: %s </p>
History_MainTableSummary Ez a táblázat a közelmúltban érkezett üzenetek feladóját és tárgyát mutatja.
History_MoveTo — áthelyezés ide —
History_Moving Áthelyezés...
History_Negate_Search Keresés/szűrő megfordítása
History_NoMagnet &nbsp;(csak nem mágnessel besorolt üzenetek)
History_NoMatchingMessages Nincsenek egyező üzenetek
History_OpenMessageSummary Ez a táblázat egy üzenet teljes szövegét tartalmazza a kiemelésekkel.
History_Purge Lejárat most
History_Reclassified Újrabesorolva
History_Reclassifying Újrabesorolás...
History_ReclassifyUnclassified Osztályozatlanok újrabesorolása
History_RemoveChecked Kijelöltek eltávolítása
History_Selected kijelölve
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
Imap_Bucket2Folder A "<b>%s</b>" kategóriába tartozó levelek a következő mappába kerülnek
Imap_BucketFolderMappings Kategória -> Mappa-hozzárendelések
Imap_Bytelimit Bájt üzenetenként a besoroláshoz. Adjon meg 0-t a teljes üzenethez:
Imap_BytelimitError Kérjük, adjon meg egy számot.
Imap_Connected Csatlakozva
Imap_Connection Kapcsolat
Imap_ConnectionFailed A kapcsolat sikertelen
Imap_Description IMAP-mappák figyelése és a bejövő üzenetek automatikus besorolása.
Imap_EnableService IMAP-szolgáltatás engedélyezése
Imap_Expunge Törölt üzenetek végleges eltávolítása a figyelt mappákból.
Imap_FetchFolders Mappák lekérése
Imap_Fetching Lekérés...
Imap_IMAFFolder IMAP-mappa
Imap_Interval Frissítési időköz másodpercben:
Imap_IntervalError Kérjük, adjon meg 10 és 3600 másodperc közötti időközt.
Imap_Login IMAP-fiók bejelentkezési neve:
Imap_LoginError Kérjük, adjon meg felhasználónevet!
Imap_MapError Egynél több kategóriát nem rendelhet egy mappához!
Imap_MappingsHint A besorolt üzenetek a megadott IMAP-mappába kerülnek. Hagyja üresen a nem hozzárendelt kategóriákat az áthelyezés kihagyásához.
Imap_NoConnectionMessage Kérjük, először konfigurálja a kapcsolati adatokat. Ezután ezen az oldalon több lehetőség is elérhetővé válik.
Imap_NoFoldersWatched Még nincsenek figyelt mappák.
Imap_NoMappings Nincsenek hozzárendelések.
Imap_Now most!
Imap_Password IMAP-fiók jelszava:
Imap_PasswordError Kérjük, adjon meg jelszót a kiszolgálóhoz!
Imap_Port IMAP-kiszolgáló portja:
Imap_PortError Kérjük, adjon meg érvényes portszámot!
Imap_RefreshFolders Mappálista frissítése
Imap_SaveAnyway Mentés mindenképpen
Imap_SaveConnection Kapcsolat mentése
Imap_SaveFolders Mappák mentése
Imap_Saving Mentés...
Imap_Server IMAP-kiszolgáló hosztneve:
Imap_ServerNameError Kérjük, adja meg a kiszolgáló hosztnevét!
Imap_Service Szolgáltatás
Imap_TestConnection Kapcsolat tesztelése
Imap_Testing Tesztelés...
Imap_TrainingHint A betanítási mód átvizsgálja a meglévő archívummappákat, és azok tartalmával betanítja a besorolót. A jelző automatikusan törlődik a betanítás befejezésekor.
Imap_TrainingMode Betanítási mód
Imap_UpdateError1 Nem sikerült bejelentkezni. Ellenőrizze felhasználónevét és jelszavát.
Imap_UpdateError2 Nem sikerült csatlakozni a kiszolgálóhoz. Ellenőrizze a hosztnevet és a portot, és győződjön meg, hogy online van.
Imap_UpdateError3 Kérjük, először konfigurálja a kapcsolati adatokat.
Imap_Use_SSL SSL használata
Imap_WatchedFolder Figyelt mappa sz.
Imap_WatchedFolders Figyelt mappák
Imap_WatchedHint A POPFile ezeket az IMAP-mappákat figyeli az osztályozandó új üzenetek érdekében.
Imap_WatchMore egy mappát a figyelt mappák listájához
Locale_Date %Y.%m.%d %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Mágnes létrehozva
Magnet_Deleted Mágnes törölve
Magnet_Jump Ugrás a mágnesek oldalára
Magnet_MainTableSummary Ez a táblázat az üzenetek automatikus besorolásához használt mágnesek listáját mutatja.
Reconnect_Connecting Csatlakozás...
Reconnect_Message A háttérszolgáltatás nem érhető el. Újracsatlakozás folyamatban...
Reconnect_Now Csatlakozás most
Reconnect_RetryIn Újra próbálkozás
Reconnect_Title Kapcsolat megszakadt
Security_MainTableSummary Ez a táblázat a POPFile általános konfigurációjának biztonságát érintő vezérlőket tartalmaz.
Security_NNTP NNTP-kapcsolatok fogadása távoli gépektől (POPFile újraindítása szükséges)
Security_SMTP SMTP-kapcsolatok fogadása távoli gépektől (POPFile újraindítása szükséges)
Security_SMTPPort SMTP lánc port
Security_SMTPPortUpdate SMTP lánc port frissítve erre: %s; a változás a POPFile újraindítása után lép érvénybe
Security_SMTPServer SMTP lánc kiszolgáló
Security_SMTPServerUpdate SMTP lánc kiszolgáló frissítve erre: %s; a változás a POPFile újraindítása után lép érvénybe
Security_StealthMode (Lopakodó mód)
Security_XMLRPC XML-RPC-kapcsolatok fogadása távoli gépektől (POPFile újraindítása szükséges)
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
SingleBucket_ClearBucket Összes szó eltávolítása
Status_Checking Ellenőrzés...
Status_Description POPFile-szolgáltatások állapotellenőrzései.
Status_LoadError Az állapot betöltése sikertelen
Status_NoChecks Nem állnak rendelkezésre ellenőrzések.
View_Chart Döntési diagram
View_DownloadMessage Üzenet letöltése
View_MessageBody Üzenet törzse
View_MessageHeader Üzenet fejléce
View_ShowFrequencies Szógyakoriságok megjelenítése
View_ShowProbabilities Szóvalószínűségek megjelenítése
View_ShowScores Szópontszámok és döntési diagram megjelenítése
View_Title Egyedi üzenet nézet
View_WordFrequencies szógyakoriságok megjelenítése
View_WordMatrix Szómátrix
View_WordProbabilities szóvalószínűségek megjelenítése
View_WordScores szópontszámok megjelenítése
Windows_Console POPFile futtatása konzolablakban?
Windows_NextTime <p><font color="red">Ez a változtatás csak a POPFile következő indításakor lép érvénybe</font>
Windows_TrayIcon POPFile ikon megjelenítése a Windows rendszertálcán?
