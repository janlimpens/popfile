# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens
# Translation Jan Chochola (jchochola@volny.cz)

# Identify the language and character set used for the interface
LanguageCode                            cz
LanguageCharset                         windows-1250
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Použít
On                                      Zapnuto
Off                                     Vypnuto
TurnOn                                  Zapnout
TurnOff                                 Vypnout
Add                                     Přidat
Remove                                  Odstranit
Previous                                Předchozí
Next                                    Následující
From                                    Od
Subject                                 Předmět
Cc                                      Cc 
Classification                          Klasifikace
Reclassify                              Znova klasifikovat
Probability                             Pravděpodobnost
Scores                                  Skóre
QuickMagnets                            <I>QuickMagnet</I>y
Undo                                    Vrátit
Close                                   Zavřít
Find                                    Hledat
Filter                                  Filtr
Yes                                     Ano
No                                      Ne
ChangeToYes                             Změnit na Ano
ChangeToNo                              Změnit na Ne
Bucket                                  Koš
Magnet                                  Magnet
Delete                                  Odstranit
Create                                  Vytvořit
To                                      Příjemce
Total                                   Celkem
Rename                                  Přejmenovat
Frequency                               Frekvence
Lookup                                  Hledání
Word                                    Slovo
Count                                   Počet
Update                                  Aktualizace
Refresh                                 Obnovit

# The header and footer that appear on every UI page
Header_Title                            Ovládací panel POPFile
Header_Shutdown                         Ukončit POPFile
Header_History                          Historie
Header_Buckets                          Koše
Header_Configuration                    Konfigurace
Header_Advanced                         Rozšířené
Header_Security                         Zabezpečení
Header_Magnets                          Magnety

Footer_HomePage                         Domovská stránka POPFile
Footer_Manual                           Manuál
Footer_Forums                           Fóra
Footer_FeedMe                           Podpořte vývoj
Footer_RequestFeature                   Požadavek na funkci
Footer_MailingList                      Mailing List

Configuration_Error1                    Oddělovač musí být jediný znak
Configuration_Error2                    Port uživatelského rozhraní musí být číslo mezi 1 a 65535
Configuration_Error3                    Port protokolu POP3 musí být číslo mezi 1 a 65535
Configuration_Error4                    Velikost stránky musí být číslo mezi 1 a 1000
Configuration_Error5                    Počet dnů platnosti historie musí být číslo mezi 1 a 366
Configuration_Error6                    Doba čekání TCP musí být číslo mezi 10 a 1800
Configuration_Error7                    Port pro XML-RPC musí být číslo mezi 1 a 65535
Configuration_POP3Port                  Port protokolu POP3
Configuration_POP3Update                Nový port POP3 je %s; tato změna se projeví až po restartu POPFile
Configuration_XMLRPCUpdate              Nový port pro XML-RPC je %s; tato změna se projeví až po restartu POPFile
Configuration_XMLRPCPort                Port pro XML-RPC
Configuration_SMTPPort                  Port protokolu SMTP
Configuration_SMTPUpdate                Nový port pro SMTP je %s; tato změna se projeví až po restartu POPFile
Configuration_NNTPPort                  Port protokolu NNTP
Configuration_NNTPUpdate                Nový port pro NNTP je %s; tato změna se projeví až po restartu POPFile
Configuration_POP3Separator             Oddělovací znak pro POP3 host:port:user
Configuration_NNTPSeparator             Oddělovací znak pro NNTP host:port:user
Configuration_POP3SepUpdate             Nový oddělovač pro POP3 je %s
Configuration_NNTPSepUpdate             Nový oddělovač pro NNTP je %s
Configuration_UI                        Port webového uživatelského rozhraní
Configuration_UIUpdate                  Nový port webového uživatelského rozhraní je %s; tato změna se projeví až po restartu POPFile
Configuration_History                   Počet zpráv na stránce
Configuration_HistoryUpdate             Nový počet zpráv na stránce je %s
Configuration_Days                      Počet dnů platnosti historie
Configuration_DaysUpdate                Nový počet dnů platnosti historie je %s
Configuration_UserInterface             Uživatelské rozhraní
Configuration_Skins                     Vzhled
Configuration_SkinsChoose               Zvolit vzhled
Configuration_Language                  Jazyk
Configuration_LanguageChoose            Zvolit jazyk
Configuration_ListenPorts               Porty
Configuration_HistoryView               Zobrazení historie
Configuration_TCPTimeout                Čekání na spojení 
Configuration_TCPTimeoutSecs            Čekání na spojení v sekundách
Configuration_TCPTimeoutUpdate          Nové čekání na spojení je %s
Configuration_ClassificationInsertion   Vkládání textu do zprávy
Configuration_SubjectLine               Změna předmětu zprávy
Configuration_XTCInsertion              Přidání hlavičky X-Text-Classification
Configuration_XPLInsertion              Přidání hlavičky X-POPFile-Link
Configuration_Logging                   Protokolování
Configuration_None                      Není
Configuration_ToScreen                  Na obrazovku
Configuration_ToFile                    Do souboru
Configuration_ToScreenFile              Na obrazovku i do souboru
Configuration_LoggerOutput              Protokol
Configuration_GeneralSkins              Vzhled
Configuration_SmallSkins                Malý
Configuration_TinySkins                 Drobný
Configuration_CurrentLogFile            &lt;aktuální protokol&gt;

Advanced_Error1                         '%s' je už v seznamu ignorovaných slov
Advanced_Error2                         Ignorovaná slova mohou obsahovat jen alfanumerické znaky a znaky '.', '_', '-' nebo '@'
Advanced_Error3                         '%s' přidáno do seznamu ignorovaných slov
Advanced_Error4                         '%s' není v seznamu ignorovaných slov
Advanced_Error5                         '%s' odstraněno ze seznamu ignorovaných slov
Advanced_StopWords                      Ignorovaná slova
Advanced_Message1                       POPFile ignoruje tato často užívaná slova:
Advanced_AddWord                        Přidat slovo
Advanced_RemoveWord                     Odebrat slovo

History_Filter                          &nbsp;(zobrazuje se koš <font color="%s">%s</font>)
History_FilterBy                        Filtr
History_Search                          &nbsp;(vyhledáno podle Odesílatele/Předmětu %s)
History_Title                           Poslední zprávy
History_Jump                            Přejít ke zprávě
History_ShowAll                         Ukázat vše
History_ShouldBe                        Má být
History_NoFrom                          schází řádek 'Odesílatel'
History_NoSubject                       schází řádek 'Předmět'
History_ClassifyAs                      Klasifikovat jako
History_MagnetUsed                      Použit magnet
History_MagnetBecause                   <b>Použit magnet</b><p>Klasifikováno jako <font color="%s">%s</font>, protože byl použit magnet %s </p>
History_ChangedTo                       Změněno na <font color="%s">%s
History_Already                         Klasifikace již změněna na <font color="%s">%s</font>
History_RemoveAll                       Odstranit vše
History_RemovePage                      Odstranit stránku
History_Remove                          Kliknout pro odstranění položek v historii
History_SearchMessage                   Hledat Odesílatele/Předmět
History_NoMessages                      Zpráva nenalezena
History_ShowMagnet                      zmagnetováno
History_ShowNoMagnet                    nezmagnetováno
History_Magnet                          &nbsp;(jen zprávy klasifikované magnetem)
History_NoMagnet                        &nbsp;(jen zprávy neklasifikované magnetem)
History_ResetSearch                     Vynulovat

Password_Title                          Heslo
Password_Enter                          Vložit heslo
Password_Go                             Vstoupit
Password_Error1                         Nesprávné heslo

Security_Error1                         Port musí být číslo mezi 1 a 65535
Security_Stealth                        Utajený režim/režim serveru
Security_NoStealthMode                  Ne (Utajený režim)
Security_ExplainStats                   (Pokud je to zapnuto, POPFile jedenkrát denně odešle skriptu na getpopfile.org následující údaje: <B>bc</B> [celkový počet košů], <B>mc</B> [celkový počet zpráv, které POPFile klasifikoval] a <B>ec</B> [celkový počet chyb klasifikace]. Tyto údaje jsou ukládány a použiji je pro statistiku o tom, jak lidé POPFile používají a jak je úspěšný. Můj web server data udržuje 5 dnů a pak je ruší. Neukládá se žádná informace o propojení mezi statistikami a příslušnými IP adresami.)
Security_ExplainUpdate                  (Pokud je to zapnuto, POPFile jedenkrát denně odešle skriptu na getpopfile.org následující údaje: <B>ma</B> [hlavní číslo verze vašeho POPFile], <B>mi</B> [vedlejší číslo verze] a <B>bn</B> (číslo sestavení POPFile). Pokud je dostupná nová verze, POPFile to graficky zobrazí v horní části stránky. Můj web server data udržuje 5 dnů a pak je ruší. Neukládá se žádná informace o propojení mezi údaji a příslušnými IP adresami.)
Security_PasswordTitle                  Heslo uživatelského rozhraní
Security_Password                       Heslo
Security_PasswordUpdate                 Nové heslo je %s
Security_AUTHTitle                      Vzdálené servery
Security_SecureServer                   Server POP3 SPA/AUTH
Security_SecureServerUpdate             Nový bezpečný server POP3 SPA/AUTH je %s; tato změna se projeví až po restartu POPFile
Security_SecurePort                     Port pro POP3 SPA/AUTH
Security_SecurePortUpdate               Nový port pro POP3 SPA/AUTH je %s; tato změna se projeví až po restartu POPFile
Security_SMTPServer                     Zřetězený SMTP server
Security_SMTPServerUpdate               Nový zřetězený SMTP server je %s; tato změna se projeví až po restartu POPFile
Security_SMTPPort                       Port pro zřetězený SMTP server
Security_SMTPPortUpdate                 Nový port pro zřetězený SMTP server je %s; tato změna se projeví až po restartu POPFile
Security_POP3                           Přijmout POP3 spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_SMTP                           Přijmout SMTP spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_NNTP                           Přijmout NNTP spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_UI                             Přijmout HTTP (uživatelské rozhraní) spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_XMLRPC                         Přijmout XML-RPC spojení od vzdálených počítačů (vyžaduje restart POPFile)
Security_UpdateTitle                    Automatická kontrola verze
Security_Update                         Denně kontrolovat dostupnost aktualizace POPFile
Security_StatsTitle                     Hlášení statistik
Security_Stats                          Denně odesílat statistiky

Magnet_Error1                           Magnet '%s' už je v koši '%s'
Magnet_Error2                           Nový magnet '%s' koliduje s magnetem '%s' v koši '%s' a mohl by způsobit nejednoznačné výsledky. Nový magnet nebyl přidán.
Magnet_Error3                           Vytvořit nový magnet '%s' v koši '%s'
Magnet_CurrentMagnets                   Platné magnety
Magnet_Message1                         Následující magnety způsobí, že zprávy budou vždy zařazeny do určeného koše.
Magnet_CreateNew                        Založit nový magnet
Magnet_Explanation                      Jsou dostupné tyto typy magnetů: <ul><li><b>From: Adresa nebo jméno odesílatele:</b> Například: john@company.com pro konkrétní adresu, <br />company.com pro všechny odesílatele z company.com, <br />John Doe pro konkrétní osobu, John pro všechny Johny</li><li><b>To/Cc: Adresa nebo jméno příjemce/příjemců:</b> Obdobně jako magnet From: pro adresy příjemců (hlavičky To: a Cc:).</li> <li><b>Subject: slova v předmětu</b>Například: hello pro všechny zprávy se slovem hello v předmětu</li></ul>
Magnet_MagnetType                       Typ magnetu
Magnet_Value                            Hodnota
Magnet_Always                           Zařadit vždy do koše
Magnet_Jump                             Přechod na stránku magnetů

Bucket_Error1                           Jména košů mohou obsahovat jen malá písmena 'a' až 'z', číslice '0' až '9', a znaky '-' a '_'
Bucket_Error2                           Koš %s již existuje
Bucket_Error3                           Koš %s byl založen
Bucket_Error4                           Vložte neprázdné slovo
Bucket_Error5                           Koš %s byl přejmenován na %s
Bucket_Error6                           Koš %s byl odstraněn
Bucket_Title                            Shrnutí
Bucket_BucketName                       Jméno koše
Bucket_WordCount                        Počet slov
Bucket_WordCounts                       Počty slov
Bucket_UniqueWords                      Unikátní slova
Bucket_SubjectModification              Modifikace předmětu
Bucket_ChangeColor                      Změna barvy
Bucket_NotEnoughData                    Příliš málo dat
Bucket_ClassificationAccuracy           Přesnost klasifikace
Bucket_EmailsClassified                 Počet klasifikovaných zpráv
Bucket_EmailsClassifiedUpper            Počet klasifikovaných zpráv
Bucket_ClassificationErrors             Chyby klasifikace
Bucket_Accuracy                         Přesnost
Bucket_ClassificationCount              Počet klasifikací
Bucket_ClassificationFP                 Počet chyb "False Positive"
Bucket_ClassificationFN                 Počet chyb "False Negative"
Bucket_ResetStatistics                  Vynulovat statistiky
Bucket_LastReset                        Poslední nulování
Bucket_CurrentColor                     %s má barvu %s
Bucket_SetColorTo                       Nastavit barvu %s na %s
Bucket_Maintenance                      Údržba
Bucket_CreateBucket                     Založit koš s názvem
Bucket_DeleteBucket                     Odstranit koš s názvem
Bucket_RenameBucket                     Přejmenovat koš s názvem
Bucket_Lookup                           Vyhledání
Bucket_LookupMessage                    Vyhledat slovo v koších
Bucket_LookupMessage2                   Výsledky hledání
Bucket_LookupMostLikely                 <b>%s</b> se nejčastěji objevuje v koši <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> se nenašlo v žádném koši
Bucket_DisabledGlobally                 Globálně vypnuto
Bucket_To                               na
Bucket_Quarantine                       Karanténa

SingleBucket_Title                      Detail %s
SingleBucket_WordCount                  Počet slov v koši
SingleBucket_TotalWordCount             Celkový počet slov
SingleBucket_Percentage                 Procento
SingleBucket_WordTable                  Tabulka slov pro %s
SingleBucket_Message1                   Pro zobrazení slov začínajících určitým písmenem je možno kliknout na toto písmeno v indexu. Kliknutím na slovo se zobrazí jeho pravděpodobnosti pro všechny koše.
SingleBucket_Unique                     %s unikátních
SingleBucket_ClearBucket                Odstranit všechna slova

Session_Title                           Relace POPFile vypršela
Session_Error                           Vaše relace POPFile vypršela. To může být způsobeno zastavením a novým spuštěním POPFile, zatímco prohlížeč zůstal otevřený. Pro pokračování práce s POPFile je nutno kliknout na některý z odkazů nahoře.

View_Title                              Pohled na jednu zprávu

Header_MenuSummary                      Tato tabulka tvoří navigační menu umožňující přístup k jednotlivým stránkám Ovládacího panelu.

History_MainTableSummary                Tato tabulka zobrazuje odesílatele a předmět doručených zpráv a umožňuje jejich prohlédnutí a změnu klasifikace. Po kliknutí na předmět se zobrazí celý text zprávy současně s informací, proč byla klasifikována tak, jak byla. Sloupec 'Má být' umožňuje určit koš, do kterého zpráva patří, nebo odvolat tuto změnu. Sloupec 'Odstranit' umožňuje zrušit zprávy, které již nejsou zapotřebí.

History_OpenMessageSummary              Tato tabulka obsahuje celý text zprávy. Slova použitá při klasifikaci jsou označena barvou koše, pro který jsou nejvíce relevantní.

Bucket_MainTableSummary                 Tato tabulka poskytuje přehled klasifikačních košů. Každý řádek obsahuje jméno koše, celkový počet slov pro daný koš, aktuální počet slov, zda je při klasifikaci modifikován předmět zprávy, zda jsou zprávy umisťovány do karantény, a tabulka pro výběr barvy koše.

Bucket_StatisticsTableSummary           Tato tabulka poskytuje tři sady statistických údajů o činnosti POPFile. První z nich zobrazuje přesnost klasifikace, druhá počet klasifikovaných zpráv pro jednotlivé koše a třetí počty slov v jednotlivých koších a jejich relativní zastoupení.

Bucket_MaintenanceTableSummary          Tato tabulka obsahuje formuláře pro zakládání, rušení a přejmenovávání košů a pro vyhledání slova v koších a zjištění jeho relativní pravděpodobnosti.

Bucket_AccuracyChartSummary             Tato tabulka graficky znázorňuje přesnost klasifikace zpráv.

Bucket_BarChartSummary                  Tato tabulka graficky znázorňuje relativní zastoupení klasifikovaných zpráv a celkového počtu slov pro jednotlivé koše. 

Bucket_LookupResultsSummary             Tato tabulka poskytuje pravděpodobnosti pro každé slovo z korpusu. Pro každý koš je zobrazena frekvence výskytu slova, pravděpodobnost, že se v koši objeví, a celkový vliv na skóre pro daný koš, pokud se ve zprávě vyskytuje.

Bucket_WordListTableSummary             Tato tabulka nabízí seznam všech slov pro daný koš.

Magnet_MainTableSummary                 Tato tabulka zobrazuje seznam všech magnetů, které jsou použity pro automatickou klasifikaci zpráv podle pevných pravidel. Každý řádek obsahuje informace o tom, jak je magnet definován a pro který koš je určen, a tlačítko pro jeho zrušení.

Configuration_MainTableSummary          Tato tabulka obsahuje řadu formulářů určených k nastavování konfigurace POPFile.

Configuration_InsertionTableSummary     Tato tabulka osahuje tlačítka určující, zda se budou provádět určité modifikace hlavičky zprávy před jejím předáním poštovnímu klientu.

Security_MainTableSummary               Tato tabulka umožňuje nastavit zabezpečení konfigurace POPFile, automatickou kontrolu nových verzí programu a zasílání statistických údajů do centrálního úložiště autora.

Advanced_MainTableSummary               Tato tabulka obsahuje seznam slov, která POPFile při klasifikaci pro jejich vysokou četnost ve zprávách ignoruje.


# New keys added (translations batch 4)
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Korpus
NavHistory Historie
NavIMAP IMAP
NavMagnets Magnety
NavSettings Nastavení
NavStatus Stav
NavWordView Slova
Advanced_AllParameters Všechny parametry POPFile
Advanced_ConfigFile Konfigurační soubor:
Advanced_Parameter Parametr
Advanced_Value Hodnota
Advanced_Warning Toto je úplný seznam parametrů POPFile. Pouze pro pokročilé uživatele: můžete změnit libovolný parametr a kliknout na Aktualizovat; neexistuje žádná kontrola platnosti. Tučně zobrazené položky byly změněny z výchozího nastavení.
ApplyChanges Použít změny
Arrived Přijato
Bucket_InIgnoredWords <b>%s</b> je v ignorovaných slovech. POPFile toto slovo ignoruje
BucketSelect_AddNew Přidat novou...
BucketSelect_AlreadyExists Již existuje
BucketSelect_CreateError Chyba při vytváření kategorie
BucketSelect_InvalidName Pouze a-z, 0-9, - a _
BucketSelect_NameRequired Název je povinný
Configuration_Error8 Port proxy SOCKS V musí být číslo mezi 1 a 65535
Configuration_Error9 Port uživatelského rozhraní nemůže mít stejnou hodnotu jako port pro naslouchání POP3
Configuration_Error10 Port pro naslouchání POP3 nemůže mít stejnou hodnotu jako port uživatelského rozhraní
Configuration_Fields Sloupce historie
Configuration_NNTPFork Povolit souběžná připojení NNTP
Configuration_POPFork Povolit souběžná připojení POP3
Configuration_SMTPFork Povolit souběžná připojení SMTP
Configuration_SOCKSPort Port proxy SOCKS V
Configuration_SOCKSPortUpdate Aktualizován port proxy SOCKS V na %s
Configuration_SOCKSServer Hostitel proxy SOCKS V
Configuration_SOCKSServerUpdate Aktualizován hostitel proxy SOCKS V na %s
Corpus_BucketList Kategorie
Corpus_Color Barva
Corpus_Actions Akce
Corpus_Clear Vymazat
Corpus_Search Hledat
Corpus_StopwordsTitle Stopslova
Corpus_StopwordsDesc Slova v tomto seznamu se nikdy nepoužívají pro klasifikaci.
Corpus_RemoveStopword Odebrat
Corpus_StopwordCandidates Kandidáti na stopslova
Corpus_StopwordCandidatesDesc Slova vyskytující se rovnoměrně ve všech kategoriích — malá rozlišovací schopnost.
Corpus_StopwordRatio Prahová hodnota poměru max/min
Corpus_LoadCandidates Najít kandidáty
Corpus_NoCandidates Při tomto prahu nebyli nalezeni žádní kandidáti.
Corpus_AddStopword Přidat do stopslov
Corpus_WordsLink Slova →
Date Datum
FAQ FAQ
Footer_Wiki Dokumentace
Help_Bucket_Setup POPFile vyžaduje alespoň dvě kategorie kromě pseudokategorie "neklasifikované". Co dělá POPFile unikátním je, že může klasifikovat e-mail do více než toho; můžete mít libovolný počet kategorií. Jednoduché nastavení by bylo kategorie "spam", "osobní" a "práce".
Help_No_More Příště nezobrazovat
Help_Training Když poprvé používáte POPFile, nic neví a bude potřebovat trénink. POPFile vyžaduje trénink na zprávách pro každou kategorii; trénink probíhá, když překlasifikujete zprávu, kterou POPFile špatně klasifikoval, do správné kategorie.
History_AllBuckets Všechny kategorie
History_Automatic Automaticky
History_ChangedClass Nyní by klasifikoval jako
History_Column_Characters Změnit šířku sloupců Od, Komu, Kopie a Předmět
History_Decrease Zmenšit
History_HighlightWords Zvýraznit slova podle kategorie
History_Increase Zvětšit
History_Loading Načítání...
History_MoveTo — přesunout do —
History_Moving Přesouvám...
History_Negate_Search Invertovat hledání/filtr
History_NoMatchingMessages Žádné odpovídající zprávy
History_Purge Vypršet nyní
History_Reclassified Překlasifikováno
History_Reclassifying Překlasifikování...
History_ReclassifyUnclassified Překlasifikovat neklasifikované
History_RemoveChecked Odebrat zaškrtnuté
History_Selected vybráno
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
ID ID
Imap_Bucket2Folder Pošta pro kategorii '<b>%s</b>' jde do složky
Imap_BucketFolderMappings Kategorie -> Mapování složek
Imap_Bytelimit Bajty na zprávu pro klasifikaci. Zadejte 0 pro celou zprávu:
Imap_BytelimitError Zadejte prosím číslo.
Imap_Connected Připojeno
Imap_Connection Připojení
Imap_ConnectionFailed Připojení selhalo
Imap_Description Sledovat složky IMAP a automaticky klasifikovat příchozí zprávy.
Imap_EnableService Povolit službu IMAP
Imap_Expunge Trvale odstranit smazané zprávy ze sledovaných složek.
Imap_FetchFolders Načíst složky
Imap_Fetching Načítám...
Imap_IMAFFolder Složka IMAP
Imap_Interval Interval aktualizace v sekundách:
Imap_IntervalError Zadejte prosím interval mezi 10 a 3600 sekundami.
Imap_Login Přihlašovací jméno účtu IMAP:
Imap_LoginError Zadejte prosím uživatelské/přihlašovací jméno!
Imap_MapError Nemůžete mapovat více než jednu kategorii na jednu složku!
Imap_MappingsHint Klasifikované zprávy jsou přesunuty do zadané složky IMAP. Nechte nemapované kategorie prázdné pro přeskočení přesunu.
Imap_NoConnectionMessage Nejprve nakonfigurujte podrobnosti připojení. Poté budou na této stránce k dispozici další možnosti.
Imap_NoFoldersWatched Zatím žádné sledované složky.
Imap_NoMappings Nejsou definována žádná mapování.
Imap_Now nyní!
Imap_Password Heslo pro účet IMAP:
Imap_PasswordError Zadejte prosím heslo pro server!
Imap_Port Port serveru IMAP:
Imap_PortError Zadejte prosím platné číslo portu!
Imap_RefreshFolders Obnovit seznam složek
Imap_SaveAnyway Uložit tak jako tak
Imap_SaveConnection Uložit připojení
Imap_SaveFolders Uložit složky
Imap_Saving Ukládám...
Imap_Server Název hostitele serveru IMAP:
Imap_ServerNameError Zadejte prosím název hostitele serveru!
Imap_Service Služba
Imap_TestConnection Testovat připojení
Imap_Testing Testuji...
Imap_TrainingHint Tréninkový režim prohledává existující archivní složky a trénuje klasifikátor na jejich obsahu. Příznak se automaticky resetuje po dokončení tréninku.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Tréninkový režim
Imap_TrainingLimit Zpráv na složku (0 = neomezeno)
Imap_UpdateError1 Nelze se přihlásit. Ověřte prosím své přihlašovací jméno a heslo.
Imap_UpdateError2 Nepodařilo se připojit k serveru. Zkontrolujte prosím název hostitele a port a ujistěte se, že jste online.
Imap_UpdateError3 Nejprve nakonfigurujte podrobnosti připojení.
Imap_Use_SSL Použít SSL
Imap_WatchedFolder Sledovaná složka č.
Imap_WatchedFolders Sledované složky
Imap_WatchedHint POPFile sleduje tyto složky IMAP kvůli novým zprávám ke klasifikaci.
Imap_WatchMore složku do seznamu sledovaných složek

WordView_Title Přesnost slov
WordView_SelectBucket vybrat kategorii
WordView_Words slova
WordView_Loading Načítám...
WordView_Empty V této kategorii nejsou žádná slova.
WordView_ColWord Slovo
WordView_ColCount Počet
WordView_ColTotal Celkem
WordView_ColAccuracy Přesnost
WordView_ColActions Akce
WordView_Remove Odebrat
WordView_MoveTo přesunout do
WordView_Move Přesunout
Locale_Date %d.%m.%Y %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Magnet vytvořen
Magnet_Deleted Magnet odstraněn
Reconnect_Connecting Připojování...
Reconnect_Message Backend není dostupný. Pokus o opětovné připojení...
Reconnect_Now Připojit nyní
Reconnect_RetryIn Zkusit znovu za
Reconnect_Title Ztraceno připojení
Security_StealthMode (Tajný režim)
Settings_AdminPassword Heslo správce
Settings_ArchiveDirectory Adresář archivu
Settings_ArchiveMessages Archivovat zprávy
Settings_ArchiveSubdirs Podadresáře archivu
Settings_AutoDetect Automaticky detekovat
Settings_AutoDetectLanguage Automaticky detekovat jazyk
Settings_ChainPort Port řetězce
Settings_ChainServer Server řetězce
Settings_DateFormat Formát data
Settings_DescAdminPassword Nechte prázdné pro zakázání ochrany heslem.
Settings_DescArchiveDir Adresář pro archivované zprávy (relativní k adresáři uživatele).
Settings_DescArchiveMessages Uložit kopii každé klasifikované zprávy na disk.
Settings_DescArchiveSubdirs Rozdělit archiv do N podadresářů (0 = zakázáno).
Settings_DescAutoDetectLang Detekuje jazyk každé zprávy a použije odpovídající stopslova a stemmer. Přidává ~130% latence klasifikace; užitečné pro vícejazyčné schránky.
Settings_DescChainPort Port nadřazeného SMTP serveru.
Settings_DescChainServer Název hostitele nadřazeného SMTP serveru.
Settings_DescDateFormat Formátovací řetězec strftime. Nechte prázdné pro výchozí nastavení locale.
Settings_DescForceFork Vytvořit nový proces pro každé připojení.
Settings_DescHEADFetchesBody Načíst celý článek příkazem HEAD.
Settings_DescHTTPPort Port, na kterém naslouchá webové rozhraní. Vyžaduje restart.
Settings_DescItemsPerPage Řádků zobrazených na stránku v Historii a Magnetech.
Settings_DescLanguage Jazyk zobrazení rozhraní. Nechte prázdné pro automatickou detekci z prohlížeče.
Settings_DescListenAddress IP adresa pro navázání. Prázdné = všechna rozhraní.
Settings_DescLocalOnly_UI Omezit webové rozhraní na lokální připojení.
Settings_DescLogDirectory Adresář pro soubory protokolu. Prázdné = kořen POPFile.
Settings_DescLogLevel Podrobnost výstupu protokolu.
Settings_DescLogSQLToStdout Tisknout každý SQL příkaz s vázanými hodnotami na stdout. Aktivní pouze pokud je povoleno také "Protokol na stdout".
Settings_DescLogToStdout Zrcadlit výstup protokolu na stdout kromě souboru protokolu.
Settings_DescMessageCutoff Maximální počet analyzovaných slov na zprávu (0 = neomezeno).
Settings_DescNNTPLocalOnly Přijímat připojení NNTP pouze z lokálního hostitele.
Settings_DescNNTPPort Port, na kterém POPFile naslouchá pro NNTP (výchozí 119).
Settings_DescNNTPSeparator Znak oddělující uživatele od serveru.
Settings_DescPOP3LocalOnly Přijímat připojení POP3 pouze z lokálního hostitele.
Settings_DescPOP3Port Port, na kterém POPFile naslouchá pro POP3 (výchozí 1110).
Settings_DescPOP3Separator Znak oddělující uživatele od serveru (např. uživatel:poštovní_server).
Settings_DescRetentionDays Kolik dní uchovávat historii zpráv.
Settings_DescSessionDividers Zobrazit oddělovače mezi relacemi prohlížení v Historii.
Settings_DescSMTPLocalOnly Přijímat připojení SMTP pouze z lokálního hostitele.
Settings_DescSMTPPort Port, na kterém POPFile naslouchá pro SMTP (výchozí 25).
Settings_DescSQLiteJournal Režim deníku SQLite / WAL.
Settings_DescSQLiteTweaks Bitová maska: 1 = rychlejší zápisy (méně bezpečné), 2 = pravidelná záloha.
Settings_DescSSLChainPort Port nadřazeného SSL POP3 serveru.
Settings_DescSSLChainServer Název hostitele nadřazeného SSL POP3 serveru pro SSL řetězení.
Settings_DescSubjectTagLeft Předpona vložená do záhlaví Předmět, např. [SPAM].
Settings_DescSubjectTagRight Přípona přidaná k záhlaví Předmět.
Settings_DescTagPosition Kam umístit značku předmětu.
Settings_DescTOPFetchesBody Načíst také tělo zprávy příkazem TOP.
Settings_DescUnclassifiedWeight Práh pravděpodobnosti, pod kterým je pošta "neklasifikovaná".
Settings_DescWordStemming Redukovat slova na jejich kořen před klasifikací (např. "běžení" → "běž"). Zlepšuje recall pro morfologicky bohaté jazyky při ~10% nákladech na latenci.
Settings_DescWordTable Co zobrazit v tabulce pravděpodobností slov.
Settings_ErrorSaving Chyba při ukládání
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD načítá tělo
Settings_HTTPPort HTTP port
Settings_ItemsPerPage Položek na stránku
Settings_ListenAddress Adresa naslouchání
Settings_ListenPort Port naslouchání
Settings_LocalOnly Pouze lokálně
Settings_LogDirectory Adresář protokolu
Settings_LogLevel Úroveň protokolu
Settings_LogSQLToStdout Protokolovat SQL na stdout
Settings_LogToStdout Protokolovat na stdout
Settings_MessageCutoff Limit zprávy
Settings_OptDebug Ladění
Settings_OptEnd Konec
Settings_OptErrorsOnly Pouze chyby
Settings_OptFrequencies Četnosti
Settings_OptFront Vpředu
Settings_OptHidden Skrytý
Settings_OptInfo Info
Settings_OptLogScores Protokolovat skóre
Settings_OptProbabilities Pravděpodobnosti
Settings_OptWarnings Varování
Settings_RetentionDays Uchování (dny)
Settings_SaveChanges Uložit změny
Settings_Saved Uloženo
Settings_Saving Ukládám...
Settings_Search Hledat nastavení...
Settings_SectionClassifier Klasifikátor
Settings_SectionHistory Historie
Settings_SectionLogging Protokolování
Settings_SectionNNTP NNTP proxy
Settings_SectionPOP3 POP3 proxy
Settings_SectionSecurity Zabezpečení
Settings_SectionSMTP SMTP proxy
Settings_SectionUI Uživatelské rozhraní
Settings_ServerSeparator Oddělovač serveru
Settings_SessionDividers Oddělovače relací
Settings_SQLiteJournalMode Režim deníku SQLite
Settings_SQLiteTweaks Vylepšení SQLite
Settings_SSLChainPort Port SSL řetězce
Settings_SSLChainServer Server SSL řetězce
Settings_SubjectTagLeft Značka předmětu vlevo
Settings_SubjectTagRight Značka předmětu vpravo
Settings_TagPosition Pozice značky
Settings_TOPFetchesBody TOP načítá tělo
Settings_UnclassifiedWeight Váha neklasifikovaných
Settings_WordStemming Stemming slov
Settings_WordTable Tabulka slov
Shutdown_Message POPFile byl ukončen
Size Velikost
Status_Checking Kontroluji...
Status_Description Kontroly stavu služeb POPFile.
Status_LoadError Nepodařilo se načíst stav
Status_NoChecks Nejsou dostupné žádné kontroly.
View_Chart Graf rozhodnutí
View_DownloadMessage Stáhnout zprávu
View_MessageBody Tělo zprávy
View_MessageHeader Záhlaví zprávy
View_ShowFrequencies Zobrazit četnosti slov
View_ShowProbabilities Zobrazit pravděpodobnosti slov
View_ShowScores Zobrazit skóre slov a graf rozhodnutí
View_WordFrequencies zobrazuje četnosti slov
View_WordMatrix Matice slov
View_WordProbabilities zobrazuje pravděpodobnosti slov
View_WordScores zobrazuje skóre slov
Windows_Console Spustit POPFile v okně konzole?
Windows_NextTime <p><font color="red">Tato změna nevstoupí v platnost do příštího spuštění POPFile</font>
Windows_TrayIcon Zobrazit ikonu POPFile na hlavním panelu Windows?

Probability	Věrohodnost
Score	Skóre

Language_Name                           Čeština
