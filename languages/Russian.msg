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

# При переводе на русский язык всплыли самые разные ошибки и недочёты
# самого веб-интерфейса -- слишком многое намертво зашито в код.
# Если я и дальше буду пользоваться POPFile, я постараюсь найти время
# отделить интерфейс от кода, и адаптировать интерфейс к русскому
# языку.
#
# Предложения и замечания с благодарностью принимаются по электронной
# почте: alexander saltanov <asdgray.at.yandex.ru>

# Identify the language and character set used for the interface
LanguageCode                            ru
LanguageCharset                         koi8-r
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Запомнить
On                                      Вкл.
Off                                     Выкл.
TurnOn                                  Включить
TurnOff                                 Выключить
Add                                     Добавить
Remove                                  Удалить
Previous                                Предыдущий
Next                                    Следующий
From                                    Отправитель
Subject                                 Тема
Classification                          Классификация
Reclassify                              Переклассифицировать
Undo                                    Отменить
Close                                   Закрыть
Find                                    Найти
Filter                                  Выбрать
Yes                                     Да
No                                      Нет
ChangeToYes                             Изменить на &laquo;Да&raquo;
ChangeToNo                              Изменить на &laquo;Нет&raquo;
Bucket                                  Ведро
Magnet                                  Магнит
Delete                                  Удалить
Create                                  Создать
To                                      Получатель
Total                                   Всего
Rename                                  Переименовать
Frequency                               Частота
Probability                             Вероятность
Score                                   Счёт
Lookup                                  Искать

# The header and footer that appear on every UI page
Header_Title                            Центр управления POPFile
Header_Shutdown                         Выключить POPFile
Header_History                          История
Header_Buckets                          Вёдра
Header_Configuration                    Настройка
Header_Advanced                         Стоп-слова
Header_Security                         Безопасность
Header_Magnets                          Магниты

Footer_HomePage                         Страничка POPFile в Интернете
Footer_Manual                           Руководство пользователя
Footer_Forums                           Форумы
Footer_FeedMe                           Накормите автора!
Footer_RequestFeature                   Нужна новая функция?
Footer_MailingList                      Список рассылки

Configuration_Error1                    Разделитель должен быть <stong>одним</strong> символом
Configuration_Error2                    Номер порта для web-интерфейса должен быть числом от 1 до 65535
Configuration_Error3                    Номер порта POP3 должен быть числом от 1 до 65535
Configuration_Error4                    Размер страницы должен быть числом от 1 до 1000
Configuration_Error5                    Число дней истории должно быть числом от 1 до 366
Configuration_Error6                    Значение таймаута TCP должно быть числом от 10 до 1800
Configuration_POP3Port                  Слушать POP3 порт
Configuration_POP3Update                Номер порта изменён на %s; изменения вступят в силу после перезапуска POPFile
Configuration_Separator                 Разделитель
Configuration_SepUpdate                 Разделитель изменён на %s
Configuration_UI                        Порт веб-интерфейса
Configuration_UIUpdate                  Номер порта веб-интерфейса изменён на %s; изменения вступят в силу после перезапуска POPFile
Configuration_History                   Сколько писем показывать на одной странице
Configuration_HistoryUpdate             Теперь на странице будет показываться %s писем
Configuration_Days                      Сколько дней хранить историю
Configuration_DaysUpdate                Теперь история будет храниться %s дней
Configuration_UserInterface             Веб-интерфейс
Configuration_Skins                     Оформление
Configuration_SkinsChoose               Выбрать вариант оформления
Configuration_Language                  Язык
Configuration_LanguageChoose            Выбрать язык
Configuration_ListenPorts               POP3 порт
Configuration_HistoryView               История
Configuration_TCPTimeout                Таймаут TCP-соединения
Configuration_TCPTimeoutSecs            Таймаут TCP-соединения в секундах
Configuration_TCPTimeoutUpdate          Таймаут изменён на %s секунд
Configuration_ClassificationInsertion   Куда записывать классификатор
Configuration_SubjectLine               Записывать классификатор в тему письма
Configuration_XTCInsertion              Добавлять поле X-Text-Classification в заголовок
Configuration_XPLInsertion              Добавлять поле X-POPFile-Link в заголовок
Configuration_Logging                   Логи
Configuration_None                      Никуда
Configuration_ToScreen                  На экран
Configuration_ToFile                    В файл
Configuration_ToScreenFile              На экран и в файл
Configuration_LoggerOutput              Куда выводить лог
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins

Advanced_Error1                         '%s' уже есть в списке стоп-слов
Advanced_Error2                         Стоп-слово может содержать буквы, цифры, и символы ., _, -, @
Advanced_Error3                         Слово '%s' добавлено в список стоп-слов
Advanced_Error4                         '%s' нет в списке стоп-слов
Advanced_Error5                         Слово '%s' удалено из списка стоп-слов
Advanced_StopWords                      Стоп-слова
Advanced_Message1                       Эти слова игнорируются при классификации писем, поскольку встречаются очень часто.
Advanced_AddWord                        Добавить слово
Advanced_RemoveWord                     Удалить слово

History_Filter                          &nbsp;(лежащие в ведре <font color="%s">%s</font>)
History_FilterBy                        Filter By
History_Search                          &nbsp;(найденные по теме &laquo;i<em>%s</em>&raquo;)
History_Title                           Последние обработанные письма
History_Jump                            Перейти к письму
History_ShowAll                         Показывать всё
History_ShouldBe                        Должно быть в&nbsp;
History_NoFrom                          не задан отправитель
History_NoSubject                       не задана тема
History_ClassifyAs                      Классифицировать как
History_MagnetUsed                      Использовался магнит
History_ChangedTo                       Изменено на <font color="%s">%s
History_Already                         Уже переклассифицировано как <font color="%s">%s</font>
History_RemoveAll                       Удалить всю историю
History_RemovePage                      Удалить эту страницу
History_Remove                          Чтобы удалить записи из истории нажмите
History_SearchMessage                   Искать в поле <em>Тема</em>
History_NoMessages                      Нет писем
History_ShowMagnet                      Только примагниченные
History_Magnet                          &nbsp;(среди классифицированных с помощью магнитов)
 
Password_Title                          Пароль
Password_Enter                          Скажите пароль
Password_Go                             Войти
Password_Error1                         Пароль оказался неправильным

Security_Error1                         Номер безопасного порта должен быть числом от 1 до 65535
Security_Stealth                        Режим невидимости/Настройка сервера
Security_NoStealthMode                  Нет (режим невидимости)
Security_ExplainStats                   (Если включено, POPFile раз в день будет отправлять скрипту на getpopfile.org три числа: bc (число ваших вёдер), mc (сколько писем было классифицировано с помощью POPFile) и ec (число ошибок классификации). Эти значения сохранятся в файле и автор будет использовать их для опубликования статистических данных о том, как используется POPFile и насколько хорошо он работает. Веб-сервер автора хранит логи в течение 5 дней, после чего они удаляются, автор не занимается сопоставлением статистики и IP-адресов пользователей.)
Security_ExplainUpdate                  (Если включено, POPFile раз в день будет отправлять скрипту на getpopfile.org три числа: ma (старший номер версии установленного POPFile), mi (младший номер версии) и bn (номер сборки). POPFile получит ответ от сервера в виде картинки, которая появится вверху страницы, если доступна новая версия. Веб-сервер автора хранит логи в течение 5 дней, после чего они удаляются, автор не занимается сопоставлением запросов об обновлении и IP-адресов пользователей.)
Security_PasswordTitle                  Пароль для веб-интерфейса
Security_Password                       Пароль
Security_PasswordUpdate                 Пароль изменён на '%s'
Security_AUTHTitle                      Secure Password Authentication/AUTH
Security_SecureServer                   Безопасный сервер
Security_SecureServerUpdate             Безопасным теперь считается сервер '%s'. Изменение вступит в силу только после перезапуска POPFile
Security_SecurePort                     Безопасный порт
Security_SecurePortUpdate               Безопасным теперь считается порт %s. Изменение вступит в силу только после перезапуска POPFile
Security_POP3                           Разрешать POP3-соединения с удалёнными машинами
Security_UI                             Разрешать HTTP-соединения (веб-интерфейс) с удалёнными машинами
Security_UpdateTitle                    Автоматическое обновление
Security_Update                         Ежедневно проверять, не обновился ли POPFile
Security_StatsTitle                     Статистические отчёты
Security_Stats                          Ежедневно отправлять статистику Джону

Magnet_Error1                           Магнит '%s' уже существует в ведре '%s'
Magnet_Error2                           Новый магнит '%s' совпадает с магнитом '%s' в ведре '%s' и может спровоцировать двусмысленные результаты. Новый магнит не был добавлен.
Magnet_Error3                           Создан новый магнит '%s' в ведре '%s'
Magnet_CurrentMagnets                   Существующие магниты
Magnet_Message1                         Магниты позволяют складывать все подходящие к ним сообщения в указанные ведра.
Magnet_CreateNew                        Создать новый магнит
Magnet_Explanation                      Существует три типа магнитов:<ul><li><b>Адрес или имя отправителя:</b> например, &quot;john@company.com&quot; сработает для писем, пришедших с указанного адреса, <br />&quot;company.com&quot; сработает для любых писем, пришедших из company.com, <br />&quot;John Doe&quot; сработает если в поле &quot;Отправитель&quot; присутствует указанное имя, в то время как, &quot;John&quot; сработает для любых Джонов, написавших вам письмо</li><li> <b>Адрес или имя получателя:</b> работает как предыдущий, только оперирует полем &quot;Получатель&quot;</li><li> <b>Слова в теме письма:</b> например, &quot;hello&quot; сработает на всех письмах с этим приветствием в теме</li></ul>
Magnet_MagnetType                       Тип магнита
Magnet_Value                            Значение
Magnet_Always                           Всегда складывать в ведро

Bucket_Error1                           Название ведра может состоять из строчныхлатинских букв от 'a' до 'z' и знаков - и _
Bucket_Error2                           Ведро '%s' уже существует
Bucket_Error3                           Создано ведро '%s'
Bucket_Error4                           Please enter a non-blank word
Bucket_Error5                           Ведро '%s' переименовано в '%s'
Bucket_Error6                           Удалено ведро '%s'
Bucket_Title                            Отчёт
Bucket_BucketName                       Название ведра
Bucket_WordCount                        Количество слов
Bucket_WordCounts                       Слова
Bucket_UniqueWords                      Уникальных слов
Bucket_SubjectModification              Изменение темы письма
Bucket_ChangeColor                      Изменить цвет
Bucket_NotEnoughData                    Недостаточно данных
Bucket_ClassificationAccuracy           Точность классификации
Bucket_EmailsClassified                 Классифицированные письма
Bucket_EmailsClassifiedUpper            Классифицированные письма
Bucket_ClassificationErrors             Ошибки классификации
Bucket_Accuracy                         Точность
Bucket_ClassificationCount              Классифицировано
Bucket_ResetStatistics                  Сброс статистики
Bucket_LastReset                        Последний сброс был
Bucket_CurrentColor                     %s текущий цвет&nbsp;&mdash; %s
Bucket_SetColorTo                       Установить %s цвет в %s
Bucket_Maintenance                      Управление
Bucket_CreateBucket                     Создать ведро
Bucket_DeleteBucket                     Удалить ведро
Bucket_RenameBucket                     Переименовать ведро
Bucket_Lookup                           Поиск
Bucket_LookupMessage                    Искать слово в вёдрах
Bucket_LookupMessage2                   Результаты поиска
Bucket_LookupMostLikely                 <b>%s</b> чаще всего встречается в <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> не встречается ни в одном из вёдер
Bucket_DisabledGlobally                 Выключено глобально
Bucket_To                               в
Bucket_Quarantine                       Карантин

SingleBucket_Title                      Подробнее о %s
SingleBucket_WordCount                  Слов в ведре
SingleBucket_TotalWordCount             Слов вообще
SingleBucket_Percentage                 Процентов от всего
SingleBucket_WordTable                  Таблица слов для %s
SingleBucket_Message1                   Слова со звёздочкой (*) были использованы при классификации в этой сессии POPFile. Щёлкните мышкой на любом слове, и вы увидите его вероятность для всех вёдер.
SingleBucket_Unique                     %s уникально

Session_Title                           Сессия POPFile устарела
Session_Error                           Ваша сессия POPFile устарела. Обычно такое случается, если если остановить и снова запустит POPFile, а в броузере оставить открытым &laquo;Центр управления&raquo;. Пожалуйста, щёлкните по любой ссылке сверху, чтобы продолжить работу с POPFile.

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


# New keys added (translations batch 4)
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Корпус
NavHistory История
NavIMAP IMAP
NavMagnets Магниты
NavSettings Настройки
NavStatus Статус
Advanced_AllParameters Все параметры POPFile
Advanced_ConfigFile Файл конфигурации:
Advanced_Parameter Параметр
Advanced_Value Значение
Advanced_Warning Это полный список параметров POPFile. Только для опытных пользователей: вы можете изменить любой параметр и нажать Обновить; проверка правильности не выполняется. Элементы, выделенные жирным шрифтом, изменены по сравнению с настройками по умолчанию.
ApplyChanges Применить изменения
Arrived Получено
Bucket_ClassificationFN Ложноотрицательные
Bucket_ClassificationFP Ложноположительные
Bucket_InIgnoredWords <b>%s</b> находится в игнорируемых словах. POPFile игнорирует это слово
BucketSelect_AddNew Добавить новую...
BucketSelect_AlreadyExists Уже существует
BucketSelect_CreateError Ошибка при создании категории
BucketSelect_InvalidName Только a-z, 0-9, - и _
BucketSelect_NameRequired Требуется имя
Cc Копия
Configuration_CurrentLogFile &lt;Просмотр текущего файла журнала&gt;
Configuration_Error7 Порт прослушивания XML RPC должен быть числом от 1 до 65535
Configuration_Error8 Порт прокси SOCKS V должен быть числом от 1 до 65535
Configuration_Error9 Порт пользовательского интерфейса не может совпадать с портом прослушивания POP3
Configuration_Error10 Порт прослушивания POP3 не может совпадать с портом пользовательского интерфейса
Configuration_Fields Столбцы истории
Configuration_NNTPFork Разрешить одновременные подключения NNTP
Configuration_NNTPPort Порт прослушивания NNTP
Configuration_NNTPSeparator Разделитель хост:порт:пользователь для NNTP
Configuration_NNTPSepUpdate Разделитель NNTP обновлён до %s
Configuration_NNTPUpdate Порт NNTP обновлён до %s; изменение вступит в силу после перезапуска POPFile
Configuration_POP3Separator Разделитель хост:порт:пользователь для POP3
Configuration_POP3SepUpdate Разделитель POP3 обновлён до %s
Configuration_POPFork Разрешить одновременные подключения POP3
Configuration_SMTPFork Разрешить одновременные подключения SMTP
Configuration_SMTPPort Порт прослушивания SMTP
Configuration_SMTPUpdate Порт SMTP обновлён до %s; изменение вступит в силу после перезапуска POPFile
Configuration_SOCKSPort Порт прокси SOCKS V
Configuration_SOCKSPortUpdate Порт прокси SOCKS V обновлён до %s
Configuration_SOCKSServer Хост прокси SOCKS V
Configuration_SOCKSServerUpdate Хост прокси SOCKS V обновлён до %s
Configuration_XMLRPCPort Порт прослушивания XML-RPC
Configuration_XMLRPCUpdate Порт XML-RPC обновлён до %s; изменение вступит в силу после перезапуска POPFile
Corpus_BucketList Категории
Corpus_Color Цвет
Corpus_Actions Действия
Corpus_Clear Очистить
Corpus_Search Поиск
Corpus_StopwordsTitle Стоп-слова
Corpus_StopwordsDesc Слова в этом списке никогда не используются для классификации.
Corpus_RemoveStopword Удалить
Corpus_StopwordCandidates Кандидаты в стоп-слова
Corpus_StopwordCandidatesDesc Слова, равномерно встречающиеся во всех категориях — малая различающая сила.
Corpus_StopwordRatio Порог соотношения макс/мин
Corpus_LoadCandidates Найти кандидатов
Corpus_NoCandidates При данном пороге кандидаты не найдены.
Corpus_AddStopword Добавить в стоп-слова
Count Количество
Date Дата
FAQ FAQ
Footer_Wiki Документация
Help_Bucket_Setup POPFile требует как минимум двух категорий в дополнение к псевдокатегории "неклассифицированное". Уникальность POPFile в том, что он может классифицировать почту по большему числу категорий; вы можете иметь любое количество категорий. Простая настройка — категории "спам", "личное" и "работа".
Help_No_More Больше не показывать
Help_Training При первом использовании POPFile он ничего не знает и нуждается в обучении. POPFile требует обучения на сообщениях для каждой категории; обучение происходит, когда вы переклассифицируете сообщение, неверно классифицированное POPFile, в правильную категорию.
History_AllBuckets Все категории
History_Automatic Автоматически
History_ChangedClass Сейчас классифицировал бы как
History_Column_Characters Изменить ширину столбцов От, Кому, Копия и Тема
History_Decrease Уменьшить
History_HighlightWords Выделить слова по категориям
History_Increase Увеличить
History_Loading Загрузка...
History_MagnetBecause <b>Использован магнит</b><p>Классифицировано в <font color="%s">%s</font> из-за магнита %s </p>
History_MoveTo — переместить в —
History_Moving Перемещение...
History_Negate_Search Инвертировать поиск/фильтр
History_NoMagnet &nbsp;(только сообщения без магнитной классификации)
History_NoMatchingMessages Нет совпадающих сообщений
History_Purge Истечь сейчас
History_Reclassified Переклассифицировано
History_Reclassifying Переклассификация...
History_ReclassifyUnclassified Переклассифицировать неклассифицированные
History_RemoveChecked Удалить отмеченные
History_ResetSearch Сбросить
History_Selected выбрано
History_Size_Bytes %d&nbsp;Б
History_Size_KiloBytes %.1f&nbsp;КБ
History_Size_MegaBytes %.1f&nbsp;МБ
ID ИД
Imap_Bucket2Folder Почта для категории '<b>%s</b>' попадает в папку
Imap_BucketFolderMappings Категория -> Сопоставление папок
Imap_Bytelimit Байт на сообщение для классификации. Введите 0 для полного сообщения:
Imap_BytelimitError Введите число.
Imap_Connected Подключено
Imap_Connection Подключение
Imap_ConnectionFailed Ошибка подключения
Imap_Description Мониторинг папок IMAP и автоматическая классификация входящих сообщений.
Imap_EnableService Включить сервис IMAP
Imap_Expunge Окончательно удалить удалённые сообщения из отслеживаемых папок.
Imap_FetchFolders Получить папки
Imap_Fetching Получение...
Imap_IMAFFolder Папка IMAP
Imap_Interval Интервал обновления в секундах:
Imap_IntervalError Введите интервал от 10 до 3600 секунд.
Imap_Login Логин учётной записи IMAP:
Imap_LoginError Введите имя пользователя/логин!
Imap_MapError Нельзя назначить более одной категории одной папке!
Imap_MappingsHint Классифицированные сообщения перемещаются в указанную папку IMAP. Оставьте несопоставленные категории пустыми, чтобы пропустить перемещение.
Imap_NoConnectionMessage Сначала настройте параметры подключения. После этого на этой странице будут доступны дополнительные параметры.
Imap_NoFoldersWatched Нет отслеживаемых папок.
Imap_NoMappings Сопоставления не определены.
Imap_Now сейчас!
Imap_Password Пароль учётной записи IMAP:
Imap_PasswordError Введите пароль для сервера!
Imap_Port Порт сервера IMAP:
Imap_PortError Введите допустимый номер порта!
Imap_RefreshFolders Обновить список папок
Imap_SaveAnyway Сохранить в любом случае
Imap_SaveConnection Сохранить подключение
Imap_SaveFolders Сохранить папки
Imap_Saving Сохранение...
Imap_Server Имя хоста сервера IMAP:
Imap_ServerNameError Введите имя хоста сервера!
Imap_Service Сервис
Imap_TestConnection Проверить подключение
Imap_Testing Тестирование...
Imap_TrainingHint Режим обучения сканирует существующие архивные папки и обучает классификатор на их содержимом. Флаг автоматически сбрасывается по завершении обучения.
Imap_TrainingMode Режим обучения
Imap_UpdateError1 Не удалось войти. Проверьте имя пользователя и пароль.
Imap_UpdateError2 Не удалось подключиться к серверу. Проверьте имя хоста и порт и убедитесь, что вы в сети.
Imap_UpdateError3 Сначала настройте параметры подключения.
Imap_Use_SSL Использовать SSL
Imap_WatchedFolder Отслеживаемая папка №
Imap_WatchedFolders Отслеживаемые папки
Imap_WatchedHint POPFile отслеживает эти папки IMAP для новых сообщений для классификации.
Imap_WatchMore папку в список отслеживаемых папок
Locale_Date %d.%m.%Y %R
Locale_Decimal ,
Locale_Thousands .
Magnet_Created Магнит создан
Magnet_Deleted Магнит удалён
Magnet_Jump Перейти на страницу магнитов
Probability Вероятность
QuickMagnets БыстрыеМагниты
Reconnect_Connecting Подключение...
Reconnect_Message Серверная часть недоступна. Попытка повторного подключения...
Reconnect_Now Подключиться сейчас
Reconnect_RetryIn Повторная попытка через
Reconnect_Title Соединение потеряно
Refresh Обновить
Scores Оценки
Security_NNTP Принимать подключения NNTP с удалённых машин (требуется перезапуск POPFile)
Security_SMTP Принимать подключения SMTP с удалённых машин (требуется перезапуск POPFile)
Security_SMTPPort Порт цепочки SMTP
Security_SMTPPortUpdate Порт цепочки SMTP обновлён до %s; изменение вступит в силу после перезапуска POPFile
Security_SMTPServer Сервер цепочки SMTP
Security_SMTPServerUpdate Сервер цепочки SMTP обновлён до %s; изменение вступит в силу после перезапуска POPFile
Security_StealthMode (Скрытный режим)
Security_XMLRPC Принимать подключения XML-RPC с удалённых машин (требуется перезапуск POPFile)
Settings_AdminPassword Пароль администратора
Settings_ArchiveDirectory Каталог архива
Settings_ArchiveMessages Архивировать сообщения
Settings_ArchiveSubdirs Подкаталоги архива
Settings_AutoDetect Автоопределение
Settings_AutoDetectLanguage Автоматически определить язык
Settings_ChainPort Порт цепочки
Settings_ChainServer Сервер цепочки
Settings_DateFormat Формат даты
Settings_DescAdminPassword Оставьте пустым для отключения защиты паролем.
Settings_DescArchiveDir Каталог для архивированных сообщений (относительно каталога пользователя).
Settings_DescArchiveMessages Сохранять копию каждого классифицированного сообщения на диск.
Settings_DescArchiveSubdirs Разделить архив на N подкаталогов (0 = отключено).
Settings_DescAutoDetectLang Определяет язык каждого сообщения и применяет соответствующие стоп-слова и стеммер. Добавляет ~130% задержки классификации; полезно для многоязычных почтовых ящиков.
Settings_DescChainPort Порт вышестоящего SMTP-сервера.
Settings_DescChainServer Имя хоста вышестоящего SMTP-сервера.
Settings_DescDateFormat Строка формата strftime. Оставьте пустым для локали по умолчанию.
Settings_DescForceFork Создавать новый процесс для каждого подключения.
Settings_DescHEADFetchesBody Получить полную статью командой HEAD.
Settings_DescHTTPPort Порт, на котором прослушивает веб-интерфейс. Требуется перезапуск.
Settings_DescItemsPerPage Строк, отображаемых на страницу в Истории и Магнитах.
Settings_DescLanguage Язык отображения интерфейса. Оставьте пустым для автоопределения из браузера.
Settings_DescListenAddress IP-адрес для привязки. Пусто = все интерфейсы.
Settings_DescLocalOnly_UI Ограничить веб-интерфейс локальными подключениями.
Settings_DescLogDirectory Каталог для файлов журнала. Пусто = корень POPFile.
Settings_DescLogLevel Подробность вывода журнала.
Settings_DescLogSQLToStdout Выводить каждый SQL-оператор со связанными значениями в stdout. Активно только когда также включён "Журнал в stdout".
Settings_DescLogToStdout Дублировать вывод журнала в stdout в дополнение к файлу журнала.
Settings_DescMessageCutoff Максимальное количество анализируемых слов на сообщение (0 = без ограничений).
Settings_DescNNTPLocalOnly Принимать подключения NNTP только с локального хоста.
Settings_DescNNTPPort Порт, на котором POPFile прослушивает NNTP (по умолчанию 119).
Settings_DescNNTPSeparator Символ, разделяющий пользователя и сервер.
Settings_DescPOP3LocalOnly Принимать подключения POP3 только с локального хоста.
Settings_DescPOP3Port Порт, на котором POPFile прослушивает POP3 (по умолчанию 1110).
Settings_DescPOP3Separator Символ, разделяющий пользователя и сервер (напр. пользователь:почтовый_сервер).
Settings_DescRetentionDays Сколько дней хранить историю сообщений.
Settings_DescSessionDividers Показывать разделители между сеансами просмотра в Истории.
Settings_DescSMTPLocalOnly Принимать подключения SMTP только с локального хоста.
Settings_DescSMTPPort Порт, на котором POPFile прослушивает SMTP (по умолчанию 25).
Settings_DescSQLiteJournal Режим журнала SQLite / WAL.
Settings_DescSQLiteTweaks Битовая маска: 1 = более быстрая запись (менее безопасно), 2 = периодическое резервное копирование.
Settings_DescSSLChainPort Порт вышестоящего SSL POP3-сервера.
Settings_DescSSLChainServer Имя хоста вышестоящего SSL POP3-сервера для SSL-цепочки.
Settings_DescSubjectTagLeft Префикс, вставляемый в заголовок Тема, напр. [СПАМ].
Settings_DescSubjectTagRight Суффикс, добавляемый к заголовку Тема.
Settings_DescTagPosition Где размещать метку темы.
Settings_DescTOPFetchesBody Также получать тело сообщения командой TOP.
Settings_DescUnclassifiedWeight Порог вероятности, ниже которого почта является "неклассифицированной".
Settings_DescWordStemming Сводить слова к основе перед классификацией (напр. "бежать" → "беж"). Улучшает полноту для морфологически богатых языков при ~10% затратах на задержку.
Settings_DescWordTable Что отображать в таблице вероятностей слов.
Settings_ErrorSaving Ошибка при сохранении
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD получает тело
Settings_HTTPPort HTTP-порт
Settings_ItemsPerPage Элементов на страницу
Settings_ListenAddress Адрес прослушивания
Settings_ListenPort Порт прослушивания
Settings_LocalOnly Только локально
Settings_LogDirectory Каталог журнала
Settings_LogLevel Уровень журнала
Settings_LogSQLToStdout Записывать SQL в stdout
Settings_LogToStdout Записывать в stdout
Settings_MessageCutoff Ограничение сообщения
Settings_OptDebug Отладка
Settings_OptEnd Конец
Settings_OptErrorsOnly Только ошибки
Settings_OptFrequencies Частоты
Settings_OptFront Спереди
Settings_OptHidden Скрытый
Settings_OptInfo Инфо
Settings_OptLogScores Записывать оценки
Settings_OptProbabilities Вероятности
Settings_OptWarnings Предупреждения
Settings_RetentionDays Хранение (дни)
Settings_SaveChanges Сохранить изменения
Settings_Saved Сохранено
Settings_Saving Сохранение...
Settings_Search Поиск настроек...
Settings_SectionClassifier Классификатор
Settings_SectionHistory История
Settings_SectionLogging Ведение журнала
Settings_SectionNNTP NNTP-прокси
Settings_SectionPOP3 POP3-прокси
Settings_SectionSecurity Безопасность
Settings_SectionSMTP SMTP-прокси
Settings_SectionUI Пользовательский интерфейс
Settings_ServerSeparator Разделитель сервера
Settings_SessionDividers Разделители сеансов
Settings_SQLiteJournalMode Режим журнала SQLite
Settings_SQLiteTweaks Настройки SQLite
Settings_SSLChainPort Порт SSL-цепочки
Settings_SSLChainServer Сервер SSL-цепочки
Settings_SubjectTagLeft Метка темы слева
Settings_SubjectTagRight Метка темы справа
Settings_TagPosition Позиция метки
Settings_TOPFetchesBody TOP получает тело
Settings_UnclassifiedWeight Вес неклассифицированных
Settings_WordStemming Стемминг слов
Settings_WordTable Таблица слов
SingleBucket_ClearBucket Удалить все слова
Shutdown_Message POPFile был остановлен
Size Размер
Status_Checking Проверка...
Status_Description Проверки состояния сервисов POPFile.
Status_LoadError Не удалось загрузить статус
Status_NoChecks Проверки недоступны.
Update Обновить
View_Chart График решений
View_DownloadMessage Загрузить сообщение
View_MessageBody Тело сообщения
View_MessageHeader Заголовок сообщения
View_ShowFrequencies Показать частоты слов
View_ShowProbabilities Показать вероятности слов
View_ShowScores Показать оценки слов и график решений
View_Title Просмотр одного сообщения
View_WordFrequencies показывает частоты слов
View_WordMatrix Матрица слов
View_WordProbabilities показывает вероятности слов
View_WordScores показывает оценки слов
Windows_Console Запустить POPFile в окне консоли?
Windows_NextTime <p><font color="red">Это изменение вступит в силу только при следующем запуске POPFile</font>
Windows_TrayIcon Показать значок POPFile в системном трее Windows?
Word Слово

Language_Name                           Русский
