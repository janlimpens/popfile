# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            bg
LanguageCharset                         Windows-1251
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          bg

# Common words that are used on their own all over the interface
Apply                                   Промени
On                                      Вкл.
Off                                     Изкл.
TurnOn                                  Включи
TurnOff                                 Изключи
Add                                     Добави
Remove                                  Премахни
Previous                                Пред.
Next                                    Следв.
From                                    От
Subject                                 Заглавие 
Classification                          Класификация
Reclassify                              Прекласиф.
Undo                                    Върни
Close                                   Затвори
Find                                    Търси
Filter                                  Филтър
Yes                                     Да
No                                      Не
ChangeToYes                             Направи ДА
ChangeToNo                              Направи НЕ
Bucket                                  Кош
Magnet                                  Магнит
Delete                                  Изтрий
Create                                  Създай
To                                      До
Total                                   Общо
Rename                                  Преименувай
Frequency                               Честота
Probability                             Вероятност
Score                                   Оценка
Lookup                                  Търси

# The header and footer that appear on every UI page
Header_Title                            Панел за управление на POPFile
Header_Shutdown                         Спри POPFile
Header_History                          Хроника
Header_Buckets                          Кошове
Header_Configuration                    Конфигурация
Header_Advanced                         Специални
Header_Security                         Защита
Header_Magnets                          Магнити

Footer_HomePage                         Web страница на POPFile
Footer_Manual                           Ръководство
Footer_Forums                           Форуми
Footer_FeedMe                           Дарение
Footer_RequestFeature                   Идея
Footer_MailingList                      Абонамент

Configuration_Error1                    Въведете за разделител един-единствен знак
Configuration_Error2                    Портът за потребителския интерфейс трябва да бъде число между 1 и 65535
Configuration_Error3                    Работният порт за POP3 трябва да бъде число между 1 и 65535
Configuration_Error4                    Размерът на страницата трябва да бъде число между 1 и 1000
Configuration_Error5                    Броят дни в хрониката трябва да бъде число между 1 и 366
Configuration_Error6                    TCP таймаутът трябва да бъде число между 10 и 1800
Configuration_POP3Port                  Работен порт за POP3
Configuration_POP3Update                Работният порт е променен на %s; тази промяна ще се отрази при следващото стартиране на POPFile.
Configuration_Separator                 Разделител
Configuration_SepUpdate                 Разделителят променен на %s
Configuration_UI                        Порт за потребителски интерфейс
Configuration_UIUpdate                  Портът за потребителски интерфейс е променен на %s; тази промяна ще се отрази при следващото стартиране на POPFile.
Configuration_History                   Брой съобщения на страница
Configuration_HistoryUpdate             Броят съобщения на страница променен на %s
Configuration_Days                      Брой дни за пазене на хроника
Configuration_DaysUpdate                Броят на дните за пазене на хроника променен на %s
Configuration_UserInterface             Потребителски интерфейс
Configuration_Skins                     Skins
Configuration_SkinsChoose               Choose skin
Configuration_Language                  Език
Configuration_LanguageChoose            Избери език
Configuration_ListenPorts               Портове
Configuration_HistoryView               Вид на хрониката
Configuration_TCPTimeout                TCP Таймаут
Configuration_TCPTimeoutSecs            Таймаут на TCP връзките в секунди
Configuration_TCPTimeoutUpdate          TCP таймаутът променен на %s
Configuration_ClassificationInsertion   Обозначаване на класификацията
Configuration_SubjectLine               Промяна на заглавието
Configuration_XTCInsertion              Вмъкване на X-Text-Classification
Configuration_XPLInsertion              Вмъкване на X-POPFile-Link
Configuration_Logging                   Протоколиране
Configuration_None                      Без
Configuration_ToScreen                  На екрана
Configuration_ToFile                    Във файл
Configuration_ToScreenFile              Във файла и на екран
Configuration_LoggerOutput              Място за протоколиране
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' вече присъства в списъка с игнорираните думи
Advanced_Error2                         Игнорираните думи може да съдържат само букви, цифри и знаците ., _, -, или @
Advanced_Error3                         '%s' добавена към списъка с игнорирани думи
Advanced_Error4                         '%s' не присъства в списъка с игнорираните думи
Advanced_Error5                         '%s' премахната към списъка с игнорирани думи
Advanced_StopWords                      Игнорирани думи
Advanced_Message1                       Следните думи се игнорират при класифициране, тъй като се срещат твърде често.
Advanced_AddWord                        Добави дума
Advanced_RemoveWord                     Премахни дума

History_Filter                          &nbsp;(показан е само кош <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(търсене за заглавие %s)
History_Title                           Последни съобщения
History_Jump                            Преход към съобщение
History_ShowAll                         Покажи всички
History_ShouldBe                        Трябва да бъде
History_NoFrom                          Няма подател
History_NoSubject                       Няма заглавие
History_ClassifyAs                      Класифицирай като
History_MagnetUsed                      Според магнит
History_ChangedTo                       Променено на <font color="%s">%s
History_Already                         Вече класифицирано като <font color="%s">%s</font>
History_RemoveAll                       Премахни всички
History_RemovePage                      Премахни тази страница
History_Remove                          За премахване на съобщенията натисни:
History_SearchMessage                   Търси по подател и заглавие
History_NoMessages                      Няма съобщения
History_ShowMagnet                      По магнит
History_Magnet                          &nbsp;(само класифицираните по магнит)
History_ResetSearch                     Изчисти търсенето

Password_Title                          Парола
Password_Enter                          Въведи парола
Password_Go                             ОК
Password_Error1                         Невалидна парола

Security_Error1                         Портът с легитимиране трябва да бъде число между 1 и 65535
Security_Stealth                        Скрит режим
Security_NoStealthMode                  Не (скрит режим)
Security_ExplainStats                   (Когато това е включено, POPFile веднъж дневно изпраща към скрипт на getpopfile.org: bc (броя на кошовете), mc (броя съобщения, класифицирани от POPFile) и ec (броя на грешно класифицираните съобщения). Тези стойности се съхраняват във файл и благодарение на тях аз публикувам статистика за начина, по който хората използват POPFile и колко добре работи. Моят Web сървър съхранява лог-файловете си в продължение на около 5 дни, след което ги изтрива; аз не пазя връзка между статистическите данни и конкретните IP адреси.)
Security_ExplainUpdate                  (Когато това е включено, POPFile веднъж дневно изпраща към скрипт на getpopfile.org: bc (броя на кошовете), mc (броя съобщения, класифицирани от POPFile) и ec (броя на грешно класифицираните съобщения). POPFile получава обратно известие дали има по-нова версия на софтуера и показва съответна картинка на всяка страница. Моят Web сървър съхранява лог-файловете си в продължение на около 5 дни, след което ги изтрива; аз не пазя връзка между запитванията за нова версия и конкретните IP адреси.)
Security_PasswordTitle                  Парола за потребителския интерфейс
Security_Password                       Парола
Security_PasswordUpdate                 Паролата променена на %s
Security_AUTHTitle                      Легитимация пред сървъра/AUTH
Security_SecureServer                   Сървър, изискващ легитимация
Security_SecureServerUpdate             Сървърът с леитимация промене на %s; тази промяна ще бъде отразена при следващото стартиране на POPFile
Security_SecurePort                     Порт за легитимация
Security_SecurePortUpdate               Портът променен на %s; тази промяна ще бъде отразена при следващото стартиране на POPFile
Security_POP3                           Приемане на POP3 връзки от други машини
Security_UI                             Приемане на HTTP връзки (за потребителския интерфейс) от други машини
Security_UpdateTitle                    Автоматична проверка за нови версии
Security_Update                         Ежедневна проверка за нови версии на POPFile
Security_StatsTitle                     Събиране на статистика
Security_Stats                          Ежедневно изпращане на статистически данни на автора

Magnet_Error1                           Магнит '%s' вече е зададен за кош '%s'
Magnet_Error2                           Новият магнит '%s' противоречи на магнит '%s' за кош '%s' и може да предизвика нееднозначност; магнитът не е добавен.
Magnet_Error3                           Създай нов магнит '%s' за кош '%s'
Magnet_CurrentMagnets                   Магнити
Magnet_Message1                         Следните магнити служат за незабавно класифициране на съобщенията в даден кош.
Magnet_CreateNew                        Създай нов магнит
Magnet_Explanation                      Има три вида магнити: <ul><li><b>Адрес или име на подател:</b> Например: john@company.com за конкретен адрес, <br />company.com за всички адреси от company.com, <br />John Doe за конкретен подател, John за всички John-овци</li><li><b>Адрес или име на получател:</b> Подобно на адреса на подател, но за адреса на получателя на съобщението</li><li><b>Думи от заглавието:</b> Например: hello за всички съобщения, чието заглавие съдържа hello</li></ul>
Magnet_MagnetType                       Тип на магнита
Magnet_Value                            Стойност
Magnet_Always                           Класифицирай винаги в кош

Bucket_Error1                           Имената на кошовете може да съдържат само малки латински букви от a до z плюс знаците - и _
Bucket_Error2                           Вече съществува кош %s
Bucket_Error3                           Създаден е кош %s
Bucket_Error4                           Моля въведете нещо
Bucket_Error5                           Кош %s преименуван на %s
Bucket_Error6                           Изтрит е кош %s
Bucket_Title                            Статистика
Bucket_BucketName                       Кош
Bucket_WordCount                        Брой думи
Bucket_WordCounts                       Брой думи
Bucket_UniqueWords                      Уникални думи
Bucket_SubjectModification              Промяна на заглавието
Bucket_ChangeColor                      Промени цвета
Bucket_NotEnoughData                    Недостатъчно данни
Bucket_ClassificationAccuracy           Точност на класификацията
Bucket_EmailsClassified                 Класифицирани съобщения
Bucket_EmailsClassifiedUpper            Класифицирани съобщения
Bucket_ClassificationErrors             Грешки при класификацията
Bucket_Accuracy                         Точност
Bucket_ClassificationCount              Брой класифицирани
Bucket_ResetStatistics                  Нулирай статистиката
Bucket_LastReset                        Последно нулиране
Bucket_CurrentColor                     В момента цветът за %s е %s
Bucket_SetColorTo                       Промени цветът за %s на %s
Bucket_Maintenance                      Промени
Bucket_CreateBucket                     Създай кош с име
Bucket_DeleteBucket                     Изтрий кош с име
Bucket_RenameBucket                     Преименувай кош с име
Bucket_Lookup                           Търсене
Bucket_LookupMessage                    Търсене на дума по кошовете
Bucket_LookupMessage2                   Резултати от търсенето
Bucket_LookupMostLikely                 <b>%s</b> най-често се среща в <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> не присъства в никой кош
Bucket_DisabledGlobally                 Изключено за всички
Bucket_To                               към
Bucket_Quarantine                       Карантина

SingleBucket_Title                      Детайли за %s
SingleBucket_WordCount                  Брой думи в коша
SingleBucket_TotalWordCount             Общо думи
SingleBucket_Percentage                 Процент от общия брой
SingleBucket_WordTable                  Думи, попадащи в %s
SingleBucket_Message1                   Означените със звездичка (*) думи са използвани за класификация при това пускане на POPFile. Щракнете с мишката на някоя дума, за да видите вероятността за попадането й във всички кошове.
SingleBucket_Unique                     %s уникални

Session_Title                           Сеансът на работа с POPFile е приключил
Session_Error                           Вашият сеанс на работа с POPFile е приключил.  Това може да се е получило от спиране и пускане на POPFile и оставен отворен прозорец на браузера. Щракнете на някой от горните връзки, за да продължите работа с POPFile.

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


# New UI keys added — batch 4
WikiLink	index.php
FAQLink	FAQ
RequestFeatureLink	RequestFeature
MailingListLink	mailing_lists
DonateLink	Donate
ApplyChanges	Приложи промените
FAQ	FAQ
ID	ID
Date	Дата
Arrived	Получено
Size	Размер
Word	Дума
Count	Брой
Update	Актуализирай
Refresh	Обнови
Probability	Вероятност
Scores	Оценки
QuickMagnets	Бързи магнити
Locale_Thousands	.
Locale_Decimal	,
Locale_Date	%a %R | %D %R
Footer_Wiki	Документация
Cc	Cc
Advanced_AllParameters	Всички параметри
Advanced_ConfigFile	Конфигурационен файл
Advanced_Parameter	Параметър
Advanced_Value	Стойност
Advanced_Warning	Внимание: промяната на тези параметри може да дестабилизира POPFile.
Bucket_ClassificationFN	Фалшиви отрицателни
Bucket_ClassificationFP	Фалшиви положителни
Bucket_InIgnoredWords	Игнорирани думи
BucketSelect_AddNew	Нова категория
BucketSelect_AlreadyExists	Категория с такова име вече съществува.
BucketSelect_CreateError	Грешка при създаване на категория.
BucketSelect_InvalidName	Невалидно име на категория.
BucketSelect_NameRequired	Въведете име на категория.
Configuration_CurrentLogFile	&lt;Виж текущия лог файл&gt;
Configuration_Error7	Портът за XML RPC трябва да е число между 1 и 65535
Configuration_Error8	Портът за SOCKS V proxy трябва да е число между 1 и 65535
Configuration_Error9	Портът на потребителския интерфейс не може да съвпада с порта на POP3
Configuration_Error10	Портът на POP3 не може да съвпада с порта на потребителския интерфейс
Configuration_Fields	Полета
Configuration_NNTPFork	Позволи паралелни NNTP връзки
Configuration_NNTPPort	NNTP порт за слушане
Configuration_NNTPSeparator	Разделителен знак за NNTP хост:порт:потребител
Configuration_NNTPSepUpdate	Актуализиран NNTP разделител на %s
Configuration_NNTPUpdate	NNTP портът е актуализиран на %s; промяната влиза в сила след рестарт на POPFile
Configuration_POP3Separator	Разделителен знак за POP3 хост:порт:потребител
Configuration_POP3SepUpdate	Актуализиран POP3 разделител на %s
Configuration_POPFork	Позволи паралелни POP3 връзки
Configuration_SMTPFork	Позволи паралелни SMTP връзки
Configuration_SMTPPort	SMTP порт за слушане
Configuration_SMTPUpdate	SMTP портът е актуализиран на %s; промяната влиза в сила след рестарт на POPFile
Configuration_SOCKSPort	Порт на SOCKS прокси
Configuration_SOCKSPortUpdate	Актуализирай порта на SOCKS
Configuration_SOCKSServer	SOCKS сървър
Configuration_SOCKSServerUpdate	Актуализирай SOCKS сървъра
Configuration_XMLRPCPort	XML-RPC порт за слушане
Configuration_XMLRPCUpdate	XML-RPC портът е актуализиран на %s; промяната влиза в сила след рестарт на POPFile
Corpus_Actions	Действия
Corpus_AddStopword	Добави стоп-дума
Corpus_BucketList	Списък категории
Corpus_Clear	Изчисти
Corpus_Color	Цвят
Corpus_LoadCandidates	Зареди кандидати
Corpus_NoCandidates	Не са намерени кандидати.
Corpus_RemoveStopword	Премахни стоп-дума
Corpus_Search	Търсене
Corpus_StopwordCandidates	Кандидати за стоп-думи
Corpus_StopwordCandidatesDesc	Думи, които се срещат твърде често и могат да пречат на класификацията.
Corpus_StopwordRatio	Праг на честота
Corpus_StopwordsDesc	Думи, които POPFile игнорира при класификация.
Corpus_StopwordsTitle	Стоп-думи
Corpus_WordsLink	Думи →
Help_Bucket_Setup	Настройка на категории
Help_No_More	Не показвай повече
Help_Training	Обучение
History_AllBuckets	Всички категории
History_Automatic	Автоматично
History_ChangedClass	Класът е променен
History_Column_Characters	Знаци
History_Decrease	Намали
History_HighlightWords	Открои думи
History_Increase	Увеличи
History_Loading	Зареждане...
History_MagnetBecause	<b>Използван магнит</b><p>Класифицирано в <font color="%s">%s</font> поради магнит %s </p>
History_MoveTo	Премести в
History_Moving	Преместване...
History_Negate_Search	Инвертирай търсенето
History_NoMagnet	&nbsp;(показване само на некласифицирани с магнит съобщения)
History_NoMatchingMessages	Няма намерени съобщения.
History_Purge	Изчисти
History_Reclassified	Прекласифицирано
History_Reclassifying	Прекласифициране...
History_ReclassifyUnclassified	Прекласифицирай некласифицираните
History_RemoveChecked	Премахни отбелязаните
History_Selected	Отбелязани
History_Size_Bytes	Б
History_Size_KiloBytes	КБ
History_Size_MegaBytes	МБ
Imap_Bucket2Folder	Категория → папка
Imap_BucketFolderMappings	Съответствия категория–папка
Imap_Bytelimit	Байтов лимит
Imap_BytelimitError	Байтовият лимит трябва да е число по-голямо от 0.
Imap_Connected	Свързан
Imap_Connection	Връзка
Imap_ConnectionFailed	Грешка при свързване.
Imap_Description	POPFile може да класифицира поща директно чрез IMAP.
Imap_EnableService	Активирай IMAP
Imap_Expunge	Изтривай маркираните съобщения
Imap_FetchFolders	Вземи папки
Imap_Fetching	Зареждане...
Imap_IMAFFolder	IMAP папка
Imap_Interval	Интервал (секунди)
Imap_IntervalError	Интервалът трябва да е число по-голямо от 0.
Imap_Login	Потребителско име
Imap_LoginError	Въведете потребителско име.
Imap_MapError	Грешка при запис на съответствия.
Imap_MappingsHint	За всяка категория посочете IMAP папка.
Imap_NoConnectionMessage	Първо запишете параметрите на връзката.
Imap_NoFoldersWatched	Няма следени папки.
Imap_NoMappings	Няма зададени съответствия.
Imap_Now	Сега
Imap_Password	Парола
Imap_PasswordError	Въведете парола.
Imap_Port	Порт
Imap_PortError	Портът трябва да е число между 1 и 65535.
Imap_RefreshFolders	Обнови папки
Imap_SaveAnyway	Запиши въпреки това
Imap_SaveConnection	Запиши връзката
Imap_SaveFolders	Запиши папки
Imap_Saving	Запис...
Imap_Server	Сървър
Imap_ServerNameError	Въведете име на сървър.
Imap_Service	IMAP услуга
Imap_TestConnection	Тествай връзката
Imap_Testing	Тестване...
Imap_TrainingHint	Преместете съобщение в подходяща папка за обучение.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode	Режим на обучение
Imap_TrainingLimit	Съобщения на папка (0 = без ограничение)
Imap_UpdateError1	Грешка при актуализиране: непозната категория.
Imap_UpdateError2	Грешка при актуализиране: непозната папка.
Imap_UpdateError3	Грешка при актуализиране: неуспешен запис.
Imap_Use_SSL	Използвай SSL
Imap_WatchedFolder	Следена папка
Imap_WatchedFolders	Следени папки
Imap_WatchedHint	Добавете папки за следене.
Imap_WatchMore	Следи още

WordView_Title	Точност на думите
WordView_SelectBucket	избери категория
WordView_Words	думи
WordView_Loading	Зареждане...
WordView_Empty	Няма думи в тази категория.
WordView_ColWord	Дума
WordView_ColCount	Брой
WordView_ColTotal	Общо
WordView_ColAccuracy	Точност
WordView_ColActions	Действия
WordView_Remove	Премахни
WordView_MoveTo	премести в
WordView_Move	Премести
Magnet_Created	Магнитът е създаден.
Magnet_Deleted	Магнитът е изтрит.
Magnet_Jump	Към страница с магнити
MailingListLink	mailing_lists
NavCorpus	Корпус
NavHistory	История
NavIMAP	IMAP
NavMagnets	Магнити
NavSettings	Настройки
NavStatus	Статус
NavWordView	Думи
Reconnect_Connecting	Свързване...
Reconnect_Message	POPFile изгуби връзката. Повторно свързване.
Reconnect_Now	Свържи се сега
Reconnect_RetryIn	Опитай отново след
Reconnect_Title	Прекъсната връзка
Security_NNTP	Приемай NNTP връзки от отдалечени машини (изисква рестарт на POPFile)
Security_SMTP	Приемай SMTP връзки от отдалечени машини (изисква рестарт на POPFile)
Security_SMTPPort	SMTP chain порт
Security_SMTPPortUpdate	SMTP chain портът е актуализиран на %s; промяната влиза в сила след рестарт
Security_SMTPServer	SMTP chain сървър
Security_SMTPServerUpdate	SMTP chain сървърът е актуализиран на %s; промяната влиза в сила след рестарт
Security_StealthMode	Невидим режим
Security_XMLRPC	Приемай XML-RPC връзки от отдалечени машини (изисква рестарт на POPFile)
Settings_AdminPassword	Администраторска парола
Settings_ArchiveDirectory	Директория за архив
Settings_ArchiveMessages	Архивирай съобщения
Settings_ArchiveSubdirs	Поддиректории за архив
Settings_AutoDetect	Автоматично определяне
Settings_AutoDetectLanguage	Автоматично определяне на езика
Settings_ChainPort	Chain порт
Settings_ChainServer	Chain сървър
Settings_DateFormat	Формат на датата
Settings_DescAdminPassword	Парола за административния интерфейс.
Settings_DescArchiveDir	Директория за архивни съобщения. Празно = не архивирай.
Settings_DescArchiveMessages	Запазвай копия на класифицираните съобщения.
Settings_DescArchiveSubdirs	Разпределяй архива в поддиректории по категории.
Settings_DescAutoDetectLang	Автоматично определяне на езика на интерфейса.
Settings_DescChainPort	Порт на upstream POP3 сървър за chain.
Settings_DescChainServer	Хостово име на upstream POP3 сървър.
Settings_DescDateFormat	Формат на показваните дати.
Settings_DescForceFork	Принудително използване на форкване на процеси.
Settings_DescHEADFetchesBody	Получавай тялото на съобщението с команда HEAD.
Settings_DescHTTPPort	Порт на уеб интерфейса на POPFile.
Settings_DescItemsPerPage	Брой елементи на страница в Историята.
Settings_DescLanguage	Език на интерфейса.
Settings_DescListenAddress	Адрес, на който POPFile слуша за връзки.
Settings_DescLocalOnly_UI	Ограничи уеб интерфейса само до локални връзки.
Settings_DescLogDirectory	Директория за лог файлове. Празно = корен на POPFile.
Settings_DescLogLevel	Детайлност на лога.
Settings_DescLogSQLToStdout	Извеждай всяка SQL заявка с параметри в stdout.
Settings_DescLogToStdout	Дублирай лога в stdout в допълнение към файла.
Settings_DescMessageCutoff	Максимален брой анализирани думи на съобщение (0 = без ограничение).
Settings_DescNNTPLocalOnly	Приемай NNTP връзки само от локален хост.
Settings_DescNNTPPort	Порт, на който POPFile слуша за NNTP (по подразбиране 119).
Settings_DescNNTPSeparator	Знак, разделящ потребител и сървър.
Settings_DescPOP3LocalOnly	Приемай POP3 връзки само от локален хост.
Settings_DescPOP3Port	Порт, на който POPFile слуша за POP3 (по подразбиране 1110).
Settings_DescPOP3Separator	Знак, разделящ потребител и сървър (напр. потребител:пощенски_сървър).
Settings_DescRetentionDays	Брой дни за съхранение на историята.
Settings_DescSessionDividers	Показвай разделители между сесии в Историята.
Settings_DescSMTPLocalOnly	Приемай SMTP връзки само от локален хост.
Settings_DescSMTPPort	Порт, на който POPFile слуша за SMTP (по подразбиране 25).
Settings_DescSQLiteJournal	Режим на SQLite журнал / WAL.
Settings_DescSQLiteTweaks	Битова маска: 1 = по-бърз запис (по-малко безопасно), 2 = периодичен архив.
Settings_DescSSLChainPort	Порт на upstream SSL POP3 сървър.
Settings_DescSSLChainServer	Хостово име на upstream SSL POP3 сървър за SSL chain.
Settings_DescSubjectTagLeft	Префикс, добавян в заглавието Тема, напр. [СПАМ].
Settings_DescSubjectTagRight	Суфикс, добавян в заглавието Тема.
Settings_DescTagPosition	Позиция на маркировката на темата.
Settings_DescTOPFetchesBody	Получавай тялото на съобщението с команда TOP.
Settings_DescUnclassifiedWeight	Праг на вероятност, под който поща е "некласифицирана".
Settings_DescWordStemming	Свеждай думи до основата им преди класификация. Подобрява обхвата за морфологично богати езици.
Settings_DescWordTable	Какво да се показва в таблицата с вероятности на думите.
Settings_ErrorSaving	Грешка при запис
Settings_ForceFork	Принудителен fork
Settings_HEADFetchesBody	HEAD взема тялото
Settings_HTTPPort	HTTP порт
Settings_ItemsPerPage	Елементи на страница
Settings_ListenAddress	Адрес за слушане
Settings_ListenPort	Порт за слушане
Settings_LocalOnly	Само локално
Settings_LogDirectory	Директория за лог
Settings_LogLevel	Ниво на лога
Settings_LogSQLToStdout	Записвай SQL в stdout
Settings_LogToStdout	Записвай в stdout
Settings_MessageCutoff	Ограничение на съобщение
Settings_OptDebug	Дебъг
Settings_OptEnd	Край
Settings_OptErrorsOnly	Само грешки
Settings_OptFrequencies	Честоти
Settings_OptFront	Отпред
Settings_OptHidden	Скрит
Settings_OptInfo	Инфо
Settings_OptLogScores	Записвай оценки
Settings_OptProbabilities	Вероятности
Settings_OptWarnings	Предупреждения
Settings_RetentionDays	Съхранение (дни)
Settings_SaveChanges	Запиши промените
Settings_Saved	Записано
Settings_Saving	Запис...
Settings_Search	Търсене в настройки...
Settings_SectionClassifier	Класификатор
Settings_SectionHistory	История
Settings_SectionLogging	Журналиране
Settings_SectionNNTP	NNTP прокси
Settings_SectionPOP3	POP3 прокси
Settings_SectionSecurity	Сигурност
Settings_SectionSMTP	SMTP прокси
Settings_SectionUI	Интерфейс
Settings_ServerSeparator	Разделител на сървър
Settings_SessionDividers	Разделители на сесии
Settings_SQLiteJournalMode	Режим на SQLite журнал
Settings_SQLiteTweaks	Настройки на SQLite
Settings_SSLChainPort	SSL chain порт
Settings_SSLChainServer	SSL chain сървър
Settings_SubjectTagLeft	Лява маркировка на тема
Settings_SubjectTagRight	Дясна маркировка на тема
Settings_TagPosition	Позиция на маркировката
Settings_TOPFetchesBody	TOP взема тялото
Settings_UnclassifiedWeight	Тегло на некласифицираните
Settings_WordStemming	Стемиране на думи
Settings_WordTable	Таблица на думите
Shutdown_Message	POPFile приключва работа. Довиждане.
SingleBucket_ClearBucket	Премахни всички думи
Status_Checking	Проверка...
Status_Description	Статус и статистика на POPFile.
Status_LoadError	Грешка при зареждане на данните за статуса.
Status_NoChecks	Няма проверки.
View_Chart	Диаграма
View_DownloadMessage	Изтегли съобщение
View_MessageBody	Тяло на съобщение
View_MessageHeader	Заглавие на съобщение
View_ShowFrequencies	Покажи честоти
View_ShowProbabilities	Покажи вероятности
View_ShowScores	Покажи оценки
View_Title	Преглед на единично съобщение
View_WordFrequencies	Честоти на думи
View_WordMatrix	Матрица на думи
View_WordProbabilities	Вероятности на думи
View_WordScores	Оценки на думи
Windows_Console	Конзола
Windows_NextTime	Следващия път
Windows_TrayIcon	Икона в системния трей

Language_Name                           Български
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
