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
# Translation Martin Minka (support@k2s.sk)

# Identify the language and character set used for the interface
LanguageCode                            sk
LanguageCharset                         windows-1250
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Použiť
On                                      Zapnuté
Off                                     Vypnuté
TurnOn                                  Zapnúť
TurnOff                                 Vypnúť
Add                                     Pridať
Remove                                  Odstrániť
Previous                                Predchádzajúci
Next                                    Nasledujúci
From                                    Odosielateľ
Subject                                 Subjekt
Classification                          Klasifikácia
Reclassify                              Preklasifikovanie
Undo                                    Vrátiť
Close                                   Zatvoriť
Find                                    Nájsť
Filter                                  Filter
Yes                                     Áno
No                                      Nie
ChangeToYes                             Zmeniť na Áno
ChangeToNo                              Zmeniť na Nie
Bucket                                  Kôš
Magnet                                  Magnet
Delete                                  Zmazať
Create                                  Vytvoriť
To                                      Príjemca
Total                                   Celkom
Rename                                  Premenovať
Frequency                               Frekvencia
Probability                             Pravdepodobnosť
Score                                   Hodnotenie
Lookup                                  Hľadanie

# The header and footer that appear on every UI page
Header_Title                            POPFile riadiaci panel
Header_Shutdown                         Zastaviť POPFile
Header_History                          História
Header_Buckets                          Koše
Header_Configuration                    Konfigurácia
Header_Advanced                         Rozšírené
Header_Security                         Bezpečnosť
Header_Magnets                          Magnety

Footer_HomePage                         POPFile domovská stránka
Footer_Manual                           Manuál
Footer_Forums                           Diskusie
Footer_FeedMe                           Podporiť
Footer_RequestFeature                   Požiadavka na funkcionalitu
Footer_MailingList                      Poštová skupina

Configuration_Error1                    Znak oddelovača musí byť len jeden znak
Configuration_Error2                    Port užívateľského rozhrania musí byť v rozpätí čísel 1 až 65535
Configuration_Error3                    Port pre POP3 musí byť v rozpätí čísel 1 až 65535
Configuration_Error4                    Veľkosť stránky musí byť v rozpätí čísel 1 až 1000
Configuration_Error5                    Počet dní v histórii musí byť v rozpätí čísel 1 až 366
Configuration_Error6                    Hodnota čakania na TCP musí byť v rozpätí čísel 10 až 1800
Configuration_POP3Port                  Port pre POP3
Configuration_POP3Update                Port zmenený na %s; this change will not take affect until you restart POPFile
Configuration_Separator                 Znak oddelovača
Configuration_SepUpdate                 Oddelovač zmenený na %s
Configuration_UI                        Port užívateľského rozhrania
Configuration_UIUpdate                  Port užívateľského rozhrania zmenený na %s; this change will not take affect until you restart POPFile
Configuration_History                   Počet správ na stránku
Configuration_HistoryUpdate             Zmenený počet správ na stránku na %s
Configuration_Days                      Počet dní uchovania histórie
Configuration_DaysUpdate                Zmenený počet dní uchovania histórie na %s
Configuration_UserInterface             Užívateľské rozhranie
Configuration_Skins                     Vzhľad
Configuration_SkinsChoose               Zvol vzhľad
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvol jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazenie histórie
Configuration_TCPTimeout                Čakanie na pripojenie TCP
Configuration_TCPTimeoutSecs            Čakanie na pripojenie TCP v sekundách
Configuration_TCPTimeoutUpdate          Čakanie na pripojenie TCP zmenené na %s
Configuration_ClassificationInsertion   Vkladanie textov do správy
Configuration_SubjectLine               Zmena textu subjektu
Configuration_XTCInsertion              Pridanie hlavičky X-Text-Classification
Configuration_XPLInsertion              Pridanie hlavičky X-POPFile-Link
Configuration_Logging                   Protokol spracovania
Configuration_None                      Žiadny
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do súboru
Configuration_ToScreenFile              Na obrazovku a do súboru
Configuration_LoggerOutput              Výstup protokolu
Configuration_GeneralSkins              Vzhľad
Configuration_SmallSkins                Malý vzhľad
Configuration_TinySkins                 Drobný vzhľad

Advanced_Error1                         '%s' sa už nachádza v zozname Ignorované slová
Advanced_Error2                         Ignorované slová môžu obsahovať len: alfanumerické znaky, ., _, -, @
Advanced_Error3                         '%s' pridané do zoznamu Ignorované slová
Advanced_Error4                         '%s' sa nenachádza v zozname Ignorované slová
Advanced_Error5                         '%s' odstránené zo zoznamu Ignorované slová
Advanced_StopWords                      Ignorované slová
Advanced_Message1                       POPFile ignoruje nasledovné, často používané slová:
Advanced_AddWord                        Pridať slovo
Advanced_RemoveWord                     Odstrániť slovo

History_Filter                          &nbsp;(zobrazuje sa len kôš <font color="%s">%s</font>)
History_FilterBy                        Filtrovať podľa
History_Search                          &nbsp;(vyhľadané podľa odosielateľa/subjektu %s)
History_Title                           Posledné správy
History_Jump                            Prejdi na správu
History_ShowAll                         Zobraz všetky
History_ShouldBe                        Má byť
History_NoFrom                          prazdny riadok odosielateľa
History_NoSubject                       prazdny riadok subjektu
History_ClassifyAs                      Klasifikuj ako
History_MagnetUsed                      Použitý magnet
History_ChangedTo                       Zmeň na <font color="%s">%s
History_Already                         Už reklasifikované na <font color="%s">%s</font>
History_RemoveAll                       Odstráň všetko
History_RemovePage                      Odstáň stranu
History_Remove                          Ak chceš zmazať záznamy z histórie, klikni
History_SearchMessage                   Hľadaj odosielateľa/subjekt
History_NoMessages                      Žiadne správy
History_ShowMagnet                      zmagnetizované
History_Magnet                          &nbsp;(zobrazujú sa len záznamy klasifikované magnetom)
History_ResetSearch                     Vyprázdniť

Password_Title                          Heslo
Password_Enter                          Zadaj heslo
Password_Go                             Vstúp!
Password_Error1                         Nesprávne heslo

Security_Error1                         Bezpečnostný port musí byť v rozpätí čísel 1 až 65535
Security_Stealth                        Utajený mód/Činnosť servera
Security_NoStealthMode                  Nie (Utajený mód)
Security_ExplainStats                   (Ak je toto zapnuté, POPFile pošle raz za deň nasledovné tri hodnoty na stránku getpopfile.org: bc (celkový počet košov, ktoré máš), mc (celkový počet správ, ktoré POPFile klasifikoval) a ec (celkový počet chybných klasifikácii).  Tieto hodnoty sa ukladajú do súboru a budú použité na vyhodnotenie niektorých štatistík o tom ako ľudia používajú POPFile a ako dobre funguje.  Môj web server uchováva tieto informácie približne 5 dní a potom ich zmaže; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_ExplainUpdate                  (Ak je toto zapnuté, POPFile pošle raz za deň nasledovné tri hodnoty na stránku getpopfile.org: ma (hlavné číslo verzie používaného POPFile), mi (vedľajšie číslo verzie používaného POPFile) a bn (číslo kompilácie používaného POPFile).  POPFile dostane odpoveď vo forme obrázku, ktorý sa zobrazí na vrchu stránku, ak je k dispozícii nová verzia.  Môj web server uchováva tieto informácie približne 5 dní a potom ich zmaže; Neuchovávam informácie prepojujúce štatistické údaje s konkrétnymi IP adresami.)
Security_PasswordTitle                  Heslo užívateľského rozhrania
Security_Password                       Heslo
Security_PasswordUpdate                 Heslo zmenené na %s
Security_AUTHTitle                      Bezpečné overovanie hesla/AUTH
Security_SecureServer                   Bezpečnostný server
Security_SecureServerUpdate             Bezpečnostný server zmenený na %s; táto zmena vstúpi do platnosti až po reštarte POPFile
Security_SecurePort                     Bezpečnostný port
Security_SecurePortUpdate               Port zmenený na %s; táto zmena vstúpi do platnosti až po reštarte POPFile
Security_POP3                           Povoľ POP3 pripojenia zo vzdialených počítačov (vyžaduje reštart POPFile)
Security_UI                             Povoľ HTTP (užívateľské rozhranie) pripojenia zo vzdialených počítačov  (vyžaduje reštart POPFile)
Security_UpdateTitle                    Automatická kontrola nových verzií
Security_Update                         Kontroluj denne nové verzie programu POPFile
Security_StatsTitle                     Oznamovať štatistiky
Security_Stats                          Posielať štatistiky denne

Magnet_Error1                           Magnet '%s' už existuje v koši '%s'
Magnet_Error2                           Nový magnet '%s' by sa bil s existujúcim magnetom '%s' v koši '%s' a mohol by spôsobovať dvojzmyselné výsledky.  Nový magnet nebol pridaný.
Magnet_Error3                           Vytvorený nový magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Aktuálne magnety
Magnet_Message1                         Nasledovné magnety klasifikujú poštu vždy do určeného koša.
Magnet_CreateNew                        Vytvoriť nový magnet
Magnet_Explanation                      Existujú tri typy magnetov: <ul><li><b>Adresa alebo meno odosielaťeľa:</b> (políčko From: v pošte) Napr.: john@company.com pre konkrétnu adresu, <br />company.com pre každého odosielateľa z adresy company.com, <br />John Doe pre konkrétnu osobu, John pre každného Johna</li><li><b>Adresa alebo meno príjemcu:</b> To isté ako predchádzajúce, ale pre políčko To: pošty</li> <li><b>Slová v subjekte:</b> Napr.: hello zaradí každú poštu, ktorá má hello v subjekte</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zaradí sa vždy do koša

Bucket_Error1                           Názvy košov môžu obsahovať len znaky od a do z (malé písmo) plus - a _
Bucket_Error2                           Kôš s názvom  %s už existuje
Bucket_Error3                           Vytvorený kôš s názvom %s
Bucket_Error4                           Prosím, nezadávaj prázdne názvy
Bucket_Error5                           Kôš je premenovaný z %s na %s
Bucket_Error6                           Zmazaný kôš %s
Bucket_Title                            Prehľad
Bucket_BucketName                       Názov koša
Bucket_WordCount                        Počet slov
Bucket_WordCounts                       Počty slov
Bucket_UniqueWords                      Jedinečné slová
Bucket_SubjectModification              Modifikácia subjektu
Bucket_ChangeColor                      Zmena farby
Bucket_NotEnoughData                    Nedostatok údajov
Bucket_ClassificationAccuracy           Presnosť klasifikácie
Bucket_EmailsClassified                 Klasifikovaná pošta
Bucket_EmailsClassifiedUpper            Klasifikovaná pošta
Bucket_ClassificationErrors             Chyby klasifikácie
Bucket_Accuracy                         Presnosť
Bucket_ClassificationCount              Počty klasifikácie
Bucket_ResetStatistics                  Vynulovanie štatistiky
Bucket_LastReset                        Posledné vynulovanie
Bucket_CurrentColor                     aktuálna farba %s je %s
Bucket_SetColorTo                       Nastav farbu %s na %s
Bucket_Maintenance                      Údržba
Bucket_CreateBucket                     Vytvor kôš s názvom
Bucket_DeleteBucket                     Zmaž kôš s názvom
Bucket_RenameBucket                     Premenuj kôš s názvom
Bucket_Lookup                           Vyhľadanie
Bucket_LookupMessage                    Vyhľadaj slovo v košoch
Bucket_LookupMessage2                   Výsledok hľadania pre
Bucket_LookupMostLikely                 <b>%s</b> sa najčastejšie nachádza v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> sa nenachádza v ani jednom koši
Bucket_DisabledGlobally                 Globálne vypnuté
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail pre %s
SingleBucket_WordCount                  Počet slov v koši
SingleBucket_TotalWordCount             Celkový počet slov
SingleBucket_Percentage                 Percento z celku
SingleBucket_WordTable                  Tabuľka slov pre %s
SingleBucket_Message1                   Slová označené s (*) boli použité na klasifikáciu počas aktuálneho spustenia POPFile.  Klikni na ktorékoľvek slovo, ak chceš vidieť jeho výskyt vo všetkých košoch.
SingleBucket_Unique                     %s jedinečných

Session_Title                           POPFile session has expired
Session_Error                           Your POPFile session has expired.  Mohlo to nastať vypnutím a zapnutím POPFile, pričom ste nechali otvorený web browser.  Prosím, ak chcete pokračovať v práci s POPFile, kliknite na niektorú z vrchných liniek.


Header_MenuSummary                      Táto tabuľka je navigačné menu, ktoré sprístupňuje všetky ostatné stránky riadiaceho panelu.
History_MainTableSummary                Táto tabuľka zobrazuje odosielateľov a subjekty aktuálne prijatých správ a umožnuje ich prezerať a klasifikovať.  Kliknutím na text subjektu sa zobrazí znenie správy, spolu s informáciou prečo bola klasifikovaná tak, ako bola.  Stĺpec 'Má byť' umožňuje určiť, do ktorého koša správa patrí, alebo zrušiť takúto zmenu.  Stĺpec 'Odstrániť' ti umožňuje zmazať danú správu z histórie, ak ju viac nepotrebuješ.
History_OpenMessageSummary              Táto tabuľka obsahuje celý text správy, spolu so zvýraznenými slovami, ktoré boli použité pri klasifikácii do daného koša.
Bucket_MainTableSummary                 Táto tabuľka obsahuje prehľad klasifikačných košov.  Každý riadok zobrazuje názov koša, celkový počet slov v tomto koši, aktuálny počet individuálnych slov v každom koši, či bude text subjektu správy zmenený ak bude správa klasifikovaná, či zaradiť správy v tomto koši do karantény a tabuľku, kde sa dá vybrať farba ktoru sa bude zobrazovať všetko na riadiacom panely, týkajúce sa tohto koša.
Bucket_StatisticsTableSummary           Táto tabuľka ponúka tri štatistické prehľady o výkone POPFile.  Prvý zobrazuje presnosť klasifikácie, druhý koľko správ bolo klasifikovaných a do ktorých košov a tretí zobrazuje koľko slov obsahuje ktorý kôš a aké je ich relatívne percentuálne zastúpenie.
Bucket_MaintenanceTableSummary          Táto tabuľka obsahuje formuláre, ktoré ti umožnujú vytvoriť, zmazať alebo premenovať koše a vyhľadať zastúpenie slova vo všetkých košoch a jeho relatívne zastúpenie.
Bucket_AccuracyChartSummary             Táto tabuľka graficky zobrazuje  presnosť klasifikácie správ.
Bucket_BarChartSummary                  Táto tabuľka graficky zobrazuje percentuálne zaplnenie jednotlivých košov.  Je použitá zároveň pre počet klasifikovaných správ a celkový počet slov.
Bucket_LookupResultsSummary             Táto tabuľka zobrazuje pravdepodobnosť priradenú k jednotlivým slovám v korpuse.  Pre každý kôš zobrazuje frekvenciu výskytu slova, pravdepodobnosť s akou sa vyskytuje v koši a celkový vplyv slova na zaradenie správy do koša ak sa v nej dané slovo vyskytuje.
Bucket_WordListTableSummary             Táto tabuľka zobrazuje zoznam všetkých slov pre kôš, slová sú zoradené podľa začiatočných znakov po riadkoch.
Magnet_MainTableSummary                 Táto tabuľka zobrazuje zoznam magnetov, ktoré sú používané na automatické klasifikovanie správ podľa presných pravidiel.  Každý riadok zobrazuje ako je magnet definovaný, pre ktorý kôš slúži a tlačidlo na zmazanie magnetu.
Configuration_MainTableSummary          Táto tabuľka obsahuje formuláre ktoré ti umožňujú konfigurovať POPFile.
Configuration_InsertionTableSummary     Táto tabuľka obsahuje tlačidlá, ktoré určujú či sa majú alebo nemajú vykonať niektoré zmeny v záhlaví alebo texte subjektu správy skôr, ako sa posunie k poštovému klientovi.
Security_MainTableSummary               Táto tabuľka poskytuje niekoľko nastavení, ktoré ovplyvňujú bezpečnosť celkovej konfigurácie POPFile, či sa má vykonávať automatická kontrola existencie zmien programu a či sa má zasielať štatistika spracovania do centrálnej databázy autora programu.
Advanced_MainTableSummary               Táto tabuľka zobrazuje zoznam slov, ktoré POPFile ignoruje pri klasifikovaní správ z dôvodu ich relatívne častého výskytu vo všeobecných správach. Sú zobrazené v riadkoch v závislosti od prvého znaku.



# New keys added (translations batch 4)
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpus
NavHistory História
NavIMAP IMAP
NavMagnets Magnety
NavSettings Nastavenia
NavStatus Stav
Advanced_AllParameters Všetky parametre POPFile
Advanced_ConfigFile Konfiguračný súbor:
Advanced_Parameter Parameter
Advanced_Value Hodnota
Advanced_Warning Toto je úplný zoznam parametrov POPFile. Len pre pokročilých používateľov: môžete zmeniť ľubovoľný parameter a kliknúť na Aktualizovať; neexistuje žiadna kontrola platnosti. Tučne zobrazené položky boli zmenené z predvoleného nastavenia.
ApplyChanges Použiť zmeny
Arrived Prijaté
Bucket_ClassificationFN Falošne negatívne
Bucket_ClassificationFP Falošne pozitívne
Bucket_InIgnoredWords <b>%s</b> je v ignorovaných slovách. POPFile toto slovo ignoruje
BucketSelect_AddNew Pridať novú...
BucketSelect_AlreadyExists Už existuje
BucketSelect_CreateError Chyba pri vytváraní kategórie
BucketSelect_InvalidName Iba a-z, 0-9, - a _
BucketSelect_NameRequired Názov je povinný
Cc Kópia
Configuration_CurrentLogFile &lt;Zobraziť aktuálny súbor protokolu&gt;
Configuration_Error7 Port XML RPC musí byť číslo medzi 1 a 65535
Configuration_Error8 Port proxy SOCKS V musí byť číslo medzi 1 a 65535
Configuration_Error9 Port používateľského rozhrania nemôže mať rovnakú hodnotu ako port pre počúvanie POP3
Configuration_Error10 Port pre počúvanie POP3 nemôže mať rovnakú hodnotu ako port používateľského rozhrania
Configuration_Fields Stĺpce histórie
Configuration_NNTPFork Povoliť súbežné pripojenia NNTP
Configuration_NNTPPort Port počúvania NNTP
Configuration_NNTPSeparator Oddeľovač host:port:používateľ pre NNTP
Configuration_NNTPSepUpdate Aktualizovaný oddeľovač NNTP na %s
Configuration_NNTPUpdate Aktualizovaný port NNTP na %s; zmena nadobudne účinnosť po reštarte POPFile
Configuration_POP3Separator Oddeľovač host:port:používateľ pre POP3
Configuration_POP3SepUpdate Aktualizovaný oddeľovač POP3 na %s
Configuration_POPFork Povoliť súbežné pripojenia POP3
Configuration_SMTPFork Povoliť súbežné pripojenia SMTP
Configuration_SMTPPort Port počúvania SMTP
Configuration_SMTPUpdate Aktualizovaný port SMTP na %s; zmena nadobudne účinnosť po reštarte POPFile
Configuration_SOCKSPort Port proxy SOCKS V
Configuration_SOCKSPortUpdate Aktualizovaný port proxy SOCKS V na %s
Configuration_SOCKSServer Hostiteľ proxy SOCKS V
Configuration_SOCKSServerUpdate Aktualizovaný hostiteľ proxy SOCKS V na %s
Configuration_XMLRPCPort Port počúvania XML-RPC
Configuration_XMLRPCUpdate Aktualizovaný port XML-RPC na %s; zmena nadobudne účinnosť po reštarte POPFile
Corpus_BucketList Kategórie
Corpus_Color Farba
Corpus_Actions Akcie
Corpus_Clear Vymazať
Corpus_Search Hľadať
Corpus_StopwordsTitle Stopslová
Corpus_StopwordsDesc Slová v tomto zozname sa nikdy nepoužívajú na klasifikáciu.
Corpus_RemoveStopword Odstrániť
Corpus_StopwordCandidates Kandidáti na stopslová
Corpus_StopwordCandidatesDesc Slová vyskytujúce sa rovnomerne vo všetkých kategóriách — malá rozlišovacia schopnosť.
Corpus_StopwordRatio Prahová hodnota pomeru max/min
Corpus_LoadCandidates Nájsť kandidátov
Corpus_NoCandidates Pri tomto prahu neboli nájdení žiadni kandidáti.
Corpus_AddStopword Pridať do stopslov
Count Počet
Date Dátum
FAQ FAQ
Footer_Wiki Dokumentácia
Help_Bucket_Setup POPFile vyžaduje aspoň dve kategórie okrem pseudokategórie "neklasifikované". To, čo robí POPFile jedinečným, je, že môže klasifikovať e-mail do viac ako toho; môžete mať ľubovoľný počet kategórií. Jednoduché nastavenie by bolo kategória "spam", "osobné" a "práca".
Help_No_More Ďalej nezobrazovať
Help_Training Keď POPFile používate prvýkrát, nič nevie a bude potrebovať tréning. POPFile vyžaduje tréning na správach pre každú kategóriu; tréning prebieha, keď preklasifikujete správu, ktorú POPFile nesprávne klasifikoval, do správnej kategórie.
History_AllBuckets Všetky kategórie
History_Automatic Automaticky
History_ChangedClass Teraz by klasifikoval ako
History_Column_Characters Zmeniť šírku stĺpcov Od, Komu, Kópia a Predmet
History_Decrease Zmenšiť
History_HighlightWords Zvýrazniť slová podľa kategórie
History_Increase Zväčšiť
History_Loading Načítavanie...
History_MagnetBecause <b>Použitý magnet</b><p>Klasifikované do <font color="%s">%s</font> kvôli magnetu %s </p>
History_MoveTo — presunúť do —
History_Moving Presúvam...
History_Negate_Search Invertovať hľadanie/filter
History_NoMagnet &nbsp;(iba správy neklasifikované magnetom)
History_NoMatchingMessages Žiadne zodpovedajúce správy
History_Purge Vypršať teraz
History_Reclassified Preklasifikované
History_Reclassifying Preklasifikovanie...
History_ReclassifyUnclassified Preklasifikovať neklasifikované
History_RemoveChecked Odstrániť zaškrtnuté
History_ResetSearch Resetovať
History_Selected vybraté
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
ID ID
Imap_Bucket2Folder Pošta pre kategóriu '<b>%s</b>' ide do priečinka
Imap_BucketFolderMappings Kategória -> Mapovanie priečinkov
Imap_Bytelimit Bajty na správu na klasifikáciu. Zadajte 0 pre celú správu:
Imap_BytelimitError Zadajte prosím číslo.
Imap_Connected Pripojené
Imap_Connection Pripojenie
Imap_ConnectionFailed Pripojenie zlyhalo
Imap_Description Sledovať priečinky IMAP a automaticky klasifikovať prichádzajúce správy.
Imap_EnableService Povoliť službu IMAP
Imap_Expunge Trvalo odstrániť zmazané správy zo sledovaných priečinkov.
Imap_FetchFolders Načítať priečinky
Imap_Fetching Načítavam...
Imap_IMAFFolder Priečinok IMAP
Imap_Interval Interval aktualizácie v sekundách:
Imap_IntervalError Zadajte prosím interval medzi 10 a 3600 sekundami.
Imap_Login Prihlasovacie meno účtu IMAP:
Imap_LoginError Zadajte prosím používateľské/prihlasovacie meno!
Imap_MapError Nemôžete mapovať viac ako jednu kategóriu na jeden priečinok!
Imap_MappingsHint Klasifikované správy sú presunuté do zadaného priečinka IMAP. Nechajte nemapované kategórie prázdne na preskočenie presunu.
Imap_NoConnectionMessage Najprv nakonfigurujte podrobnosti pripojenia. Potom budú na tejto stránke k dispozícii ďalšie možnosti.
Imap_NoFoldersWatched Zatiaľ žiadne sledované priečinky.
Imap_NoMappings Nie sú definované žiadne mapovania.
Imap_Now teraz!
Imap_Password Heslo pre účet IMAP:
Imap_PasswordError Zadajte prosím heslo pre server!
Imap_Port Port servera IMAP:
Imap_PortError Zadajte prosím platné číslo portu!
Imap_RefreshFolders Obnoviť zoznam priečinkov
Imap_SaveAnyway Uložiť aj tak
Imap_SaveConnection Uložiť pripojenie
Imap_SaveFolders Uložiť priečinky
Imap_Saving Ukladám...
Imap_Server Názov hostiteľa servera IMAP:
Imap_ServerNameError Zadajte prosím názov hostiteľa servera!
Imap_Service Služba
Imap_TestConnection Testovať pripojenie
Imap_Testing Testujem...
Imap_TrainingHint Tréningový režim prehľadáva existujúce archívne priečinky a trénuje klasifikátor na ich obsahu. Príznak sa automaticky resetuje po dokončení tréningu.
Imap_TrainingMode Tréningový režim
Imap_UpdateError1 Nedá sa prihlásiť. Skontrolujte prosím svoje prihlasovacie meno a heslo.
Imap_UpdateError2 Nepodarilo sa pripojiť k serveru. Skontrolujte prosím názov hostiteľa a port a uistite sa, že ste online.
Imap_UpdateError3 Najprv nakonfigurujte podrobnosti pripojenia.
Imap_Use_SSL Použiť SSL
Imap_WatchedFolder Sledovaný priečinok č.
Imap_WatchedFolders Sledované priečinky
Imap_WatchedHint POPFile sleduje tieto priečinky IMAP kvôli novým správam na klasifikáciu.
Imap_WatchMore priečinok do zoznamu sledovaných priečinkov
Locale_Date %d.%m.%Y %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magnet vytvorený
Magnet_Deleted Magnet odstránený
Magnet_Jump Prejsť na stránku magnetov
Probability Pravdepodobnosť
QuickMagnets RýchleMagnety
Reconnect_Connecting Pripájam...
Reconnect_Message Backend nie je dostupný. Pokus o opätovné pripojenie...
Reconnect_Now Pripojiť teraz
Reconnect_RetryIn Skúsiť znova za
Reconnect_Title Stratené pripojenie
Refresh Obnoviť
Scores Skóre
Security_NNTP Prijímať pripojenia NNTP zo vzdialených počítačov (vyžaduje reštart POPFile)
Security_SMTP Prijímať pripojenia SMTP zo vzdialených počítačov (vyžaduje reštart POPFile)
Security_SMTPPort Port reťazca SMTP
Security_SMTPPortUpdate Port reťazca SMTP aktualizovaný na %s; zmena nadobudne účinnosť po reštarte POPFile
Security_SMTPServer Server reťazca SMTP
Security_SMTPServerUpdate Server reťazca SMTP aktualizovaný na %s; zmena nadobudne účinnosť po reštarte POPFile
Security_StealthMode (Tajný režim)
Security_XMLRPC Prijímať pripojenia XML-RPC zo vzdialených počítačov (vyžaduje reštart POPFile)
Settings_AdminPassword Heslo správcu
Settings_ArchiveDirectory Adresár archívu
Settings_ArchiveMessages Archivovať správy
Settings_ArchiveSubdirs Podadresáre archívu
Settings_AutoDetect Automaticky zistiť
Settings_AutoDetectLanguage Automaticky zistiť jazyk
Settings_ChainPort Port reťazca
Settings_ChainServer Server reťazca
Settings_DateFormat Formát dátumu
Settings_DescAdminPassword Nechajte prázdne pre zakázanie ochrany heslom.
Settings_DescArchiveDir Adresár pre archivované správy (relatívne k adresáru používateľa).
Settings_DescArchiveMessages Uložiť kópiu každej klasifikovanej správy na disk.
Settings_DescArchiveSubdirs Rozdeliť archív do N podadresárov (0 = zakázané).
Settings_DescAutoDetectLang Zistí jazyk každej správy a použije zodpovedajúce stopslová a stemmer. Pridáva ~130% latencie klasifikácie; užitočné pre viacjazyčné schránky.
Settings_DescChainPort Port nadriadeného SMTP servera.
Settings_DescChainServer Názov hostiteľa nadriadeného SMTP servera.
Settings_DescDateFormat Formátovací reťazec strftime. Nechajte prázdne pre predvolené nastavenie locale.
Settings_DescForceFork Vytvoriť nový proces pre každé pripojenie.
Settings_DescHEADFetchesBody Načítať celý článok príkazom HEAD.
Settings_DescHTTPPort Port, na ktorom počúva webové rozhranie. Vyžaduje reštart.
Settings_DescItemsPerPage Riadkov zobrazených na stránku v Histórii a Magnetoch.
Settings_DescLanguage Jazyk zobrazenia rozhrania. Nechajte prázdne pre automatické zistenie z prehliadača.
Settings_DescListenAddress IP adresa na naviazanie. Prázdne = všetky rozhrania.
Settings_DescLocalOnly_UI Obmedziť webové rozhranie na lokálne pripojenia.
Settings_DescLogDirectory Adresár pre súbory protokolu. Prázdne = koreň POPFile.
Settings_DescLogLevel Podrobnosť výstupu protokolu.
Settings_DescLogSQLToStdout Tlačiť každý príkaz SQL s viazanými hodnotami na stdout. Aktívne iba ak je povolené aj "Protokol na stdout".
Settings_DescLogToStdout Zrkadliť výstup protokolu na stdout okrem súboru protokolu.
Settings_DescMessageCutoff Maximálny počet analyzovaných slov na správu (0 = neobmedzené).
Settings_DescNNTPLocalOnly Prijímať pripojenia NNTP iba z lokálneho hostiteľa.
Settings_DescNNTPPort Port, na ktorom POPFile počúva pre NNTP (predvolené 119).
Settings_DescNNTPSeparator Znak oddeľujúci používateľa od servera.
Settings_DescPOP3LocalOnly Prijímať pripojenia POP3 iba z lokálneho hostiteľa.
Settings_DescPOP3Port Port, na ktorom POPFile počúva pre POP3 (predvolené 1110).
Settings_DescPOP3Separator Znak oddeľujúci používateľa od servera (napr. používateľ:poštový_server).
Settings_DescRetentionDays Koľko dní uchovávať históriu správ.
Settings_DescSessionDividers Zobraziť oddeľovače medzi reláciami prehliadania v Histórii.
Settings_DescSMTPLocalOnly Prijímať pripojenia SMTP iba z lokálneho hostiteľa.
Settings_DescSMTPPort Port, na ktorom POPFile počúva pre SMTP (predvolené 25).
Settings_DescSQLiteJournal Režim denníka SQLite / WAL.
Settings_DescSQLiteTweaks Bitová maska: 1 = rýchlejšie zápisy (menej bezpečné), 2 = pravidelná záloha.
Settings_DescSSLChainPort Port nadriadeného SSL POP3 servera.
Settings_DescSSLChainServer Názov hostiteľa nadriadeného SSL POP3 servera pre SSL reťazenie.
Settings_DescSubjectTagLeft Predpona vložená do záhlavia Predmet, napr. [SPAM].
Settings_DescSubjectTagRight Prípona pridaná k záhlaviu Predmet.
Settings_DescTagPosition Kam umiestniť značku predmetu.
Settings_DescTOPFetchesBody Načítať tiež telo správy príkazom TOP.
Settings_DescUnclassifiedWeight Prah pravdepodobnosti, pod ktorým je pošta "neklasifikovaná".
Settings_DescWordStemming Redukovať slová na ich koreň pred klasifikáciou (napr. "bežanie" → "bež"). Zlepšuje recall pre morfologicky bohaté jazyky pri ~10% nákladoch na latenciu.
Settings_DescWordTable Čo zobraziť v tabuľke pravdepodobností slov.
Settings_ErrorSaving Chyba pri ukladaní
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD načítava telo
Settings_HTTPPort HTTP port
Settings_ItemsPerPage Položiek na stránku
Settings_ListenAddress Adresa počúvania
Settings_ListenPort Port počúvania
Settings_LocalOnly Iba lokálne
Settings_LogDirectory Adresár protokolu
Settings_LogLevel Úroveň protokolu
Settings_LogSQLToStdout Protokolovať SQL na stdout
Settings_LogToStdout Protokolovať na stdout
Settings_MessageCutoff Limit správy
Settings_OptDebug Ladenie
Settings_OptEnd Koniec
Settings_OptErrorsOnly Iba chyby
Settings_OptFrequencies Frekvencie
Settings_OptFront Vpredu
Settings_OptHidden Skrytý
Settings_OptInfo Info
Settings_OptLogScores Protokolovať skóre
Settings_OptProbabilities Pravdepodobnosti
Settings_OptWarnings Varovania
Settings_RetentionDays Uchovávania (dni)
Settings_SaveChanges Uložiť zmeny
Settings_Saved Uložené
Settings_Saving Ukladám...
Settings_Search Hľadať nastavenia...
Settings_SectionClassifier Klasifikátor
Settings_SectionHistory História
Settings_SectionLogging Protokolovanie
Settings_SectionNNTP NNTP proxy
Settings_SectionPOP3 POP3 proxy
Settings_SectionSecurity Zabezpečenie
Settings_SectionSMTP SMTP proxy
Settings_SectionUI Používateľské rozhranie
Settings_ServerSeparator Oddeľovač servera
Settings_SessionDividers Oddeľovače relácií
Settings_SQLiteJournalMode Režim denníka SQLite
Settings_SQLiteTweaks Vylepšenia SQLite
Settings_SSLChainPort Port SSL reťazca
Settings_SSLChainServer Server SSL reťazca
Settings_SubjectTagLeft Značka predmetu vľavo
Settings_SubjectTagRight Značka predmetu vpravo
Settings_TagPosition Pozícia značky
Settings_TOPFetchesBody TOP načítava telo
Settings_UnclassifiedWeight Váha neklasifikovaných
Settings_WordStemming Stemming slov
Settings_WordTable Tabuľka slov
SingleBucket_ClearBucket Odstrániť všetky slová
Shutdown_Message POPFile bol ukončený
Size Veľkosť
Status_Checking Kontrolujem...
Status_Description Kontroly stavu služieb POPFile.
Status_LoadError Nepodarilo sa načítať stav
Status_NoChecks Nie sú dostupné žiadne kontroly.
Update Aktualizovať
View_Chart Graf rozhodnutí
View_DownloadMessage Stiahnuť správu
View_MessageBody Telo správy
View_MessageHeader Záhlavie správy
View_ShowFrequencies Zobraziť frekvencie slov
View_ShowProbabilities Zobraziť pravdepodobnosti slov
View_ShowScores Zobraziť skóre slov a graf rozhodnutí
View_Title Zobrazenie jednej správy
View_WordFrequencies zobrazuje frekvencie slov
View_WordMatrix Matica slov
View_WordProbabilities zobrazuje pravdepodobnosti slov
View_WordScores zobrazuje skóre slov
Windows_Console Spustiť POPFile v okne konzoly?
Windows_NextTime <p><font color="red">Táto zmena nenadobudne účinnosť do ďalšieho spustenia POPFile</font>
Windows_TrayIcon Zobraziť ikonu POPFile na paneli úloh Windows?
Word Slovo

Language_Name                           Slovenčina
