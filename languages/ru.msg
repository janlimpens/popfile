# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         koi8-r
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Запомнить
Add                                     Добавить
Remove                                  Удалить
Previous                                Предыдущий
Next                                    Следующий
From                                    Отправитель
Subject                                 Тема
Reclassify                              Переклассифицировать
Undo                                    Отменить
Close                                   Закрыть
Bucket                                  Ведро
Magnet                                  Магнит
Delete                                  Удалить
Create                                  Создать
Total                                   Всего
Rename                                  Переименовать

# The header and footer that appear on every UI page

Configuration_Separator                 Разделитель
Configuration_SepUpdate                 Разделитель изменён на %s
Configuration_Language                  Язык

History_SearchMessage                   Искать в поле <em>Тема</em>
 
Magnet_CurrentMagnets                   Существующие магниты
Magnet_CreateNew                        Создать новый магнит

Bucket_CreateBucket                     Создать ведро
Bucket_RenameBucket                     Переименовать ведро

# New keys added (translations batch 4)
NavCorpus Корпус
NavHistory История
NavIMAP IMAP
NavMagnets Магниты
NavStatus Статус
NavWordView Слова
BucketSelect_AddNew Добавить новую...
BucketSelect_AlreadyExists Уже существует
BucketSelect_CreateError Ошибка при создании категории
BucketSelect_InvalidName Только a-z, 0-9, - и _
BucketSelect_NameRequired Требуется имя
Corpus_BucketList Категории
Corpus_Color Цвет
Corpus_Actions Действия
Corpus_Clear Очистить
Corpus_StopwordsTitle Стоп-слова
Corpus_StopwordsDesc Слова в этом списке никогда не используются для классификации.
Corpus_RemoveStopword Удалить
Corpus_StopwordCandidates Кандидаты в стоп-слова
Corpus_StopwordCandidatesDesc Слова, равномерно встречающиеся во всех категориях — малая различающая сила.
Corpus_StopwordRatio Порог соотношения макс/мин
Corpus_LoadCandidates Найти кандидатов
Corpus_NoCandidates При данном пороге кандидаты не найдены.
Corpus_AddStopword Добавить в стоп-слова
Date Дата
History_AllBuckets Все категории
History_HighlightWords Выделить слова по категориям
History_Loading Загрузка...
History_MoveTo — переместить в —
History_Moving Перемещение...
History_Reclassifying Переклассификация...
History_ReclassifyUnclassified Переклассифицировать неклассифицированные
History_Selected выбрано
Imap_BucketFolderMappings Категория -> Сопоставление папок
Imap_Connected Подключено
Imap_Connection Подключение
Imap_ConnectionFailed Ошибка подключения
Imap_Description Мониторинг папок IMAP и автоматическая классификация входящих сообщений.
Imap_Expunge Окончательно удалить удалённые сообщения из отслеживаемых папок.
Imap_FetchFolders Получить папки
Imap_Fetching Получение...
Imap_IMAFFolder Папка IMAP
Imap_Interval Интервал обновления в секундах:
Imap_Login Логин учётной записи IMAP:
Imap_MappingsHint Классифицированные сообщения перемещаются в указанную папку IMAP. Оставьте несопоставленные категории пустыми, чтобы пропустить перемещение.
Imap_NoConnectionMessage Сначала настройте параметры подключения. После этого на этой странице будут доступны дополнительные параметры.
Imap_NoFoldersWatched Нет отслеживаемых папок.
Imap_NoMappings Сопоставления не определены.
Imap_Password Пароль учётной записи IMAP:
Imap_Port Порт сервера IMAP:
Imap_SaveAnyway Сохранить в любом случае
Imap_SaveConnection Сохранить подключение
Imap_SaveFolders Сохранить папки
Imap_Saving Сохранение...
Imap_Server Имя хоста сервера IMAP:
Imap_TestConnection Проверить подключение
Imap_Testing Тестирование...
Imap_TrainingHint Режим обучения сканирует существующие архивные папки и обучает классификатор на их содержимом. Флаг автоматически сбрасывается по завершении обучения.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Режим обучения
Imap_TrainingLimit Сообщений на папку (0 = без ограничений)
Imap_Use_SSL Использовать SSL
Imap_WatchedFolders Отслеживаемые папки
Imap_WatchedHint POPFile отслеживает эти папки IMAP для новых сообщений для классификации.

WordView_Title Точность слов
WordView_SelectBucket выбрать категорию
WordView_Words слова
WordView_Loading Загрузка...
WordView_Empty В этой категории нет слов.
WordView_ColWord Слово
WordView_ColCount Количество
WordView_ColTotal Всего
WordView_ColAccuracy Точность
WordView_ColActions Действия
WordView_Remove Удалить
WordView_MoveTo переместить в
WordView_Move Переместить
Magnet_Created Магнит создан
Magnet_Deleted Магнит удалён
Reconnect_Connecting Подключение...
Reconnect_Message Серверная часть недоступна. Попытка повторного подключения...
Reconnect_Now Подключиться сейчас
Reconnect_RetryIn Повторная попытка через
Reconnect_Title Соединение потеряно
Refresh Обновить
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
Status_Checking Проверка...
Status_Description Проверки состояния сервисов POPFile.
Status_LoadError Не удалось загрузить статус
Status_NoChecks Проверки недоступны.
Update Обновить

Language_Name                           Русский
History_PerPage                          Записей на странице
Imap_Advanced                            Расширенные
Imap_Cancel                              Отмена
Imap_Wizard                              Мастер настройки
Imap_WizardApply                         Создать и сопоставить
Imap_WizardClose                         Закрыть
Imap_WizardDesc                          Выберите папки для создания категорий и сопоставлений.
Imap_WizardDeselectAll                   Снять выделение
Imap_WizardDone                          Создано и сопоставлено категорий: {count}.
Imap_WizardEmpty                         Дополнительные папки на сервере не найдены.
Imap_WizardSelectAll                     Выбрать все
Imap_WizardTrain                         Обучить сейчас
NavWordSearch                            Поиск слов
Settings_DescEnableProxy                 Запускать этот прокси при старте POPFile.
Settings_DescLogFormat                   Формат вывода журнала (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Автоматически открывать браузер при запуске.
Settings_DescSQLiteBackup                Автоматически создавать резервную копию БД перед изменениями схемы.
Settings_DescSQLiteFastWrites            Отключить синхронизацию БД (быстрее, менее безопасно).
Settings_EnableService                   Включить службу
Settings_LogFormat                       Формат журнала
Settings_OpenBrowser                     Открыть браузер
Settings_SQLiteBackup                    Резервная копия SQLite
Settings_SQLiteFastWrites                Быстрая запись SQLite
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Добавить стоп-слово
WordSearch_ColumnBuckets                 Категории
WordSearch_ColumnWord                    Слово
WordSearch_IsStopword                    Стоп-слово
WordSearch_Loading                       Загрузка...
WordSearch_NoResults                     Нет результатов.
WordSearch_NoStopwords                   Нет стоп-слов.
WordSearch_Placeholder                   Введите слово...
WordSearch_RemoveStopword                Удалить стоп-слово
WordSearch_Search                        Искать
WordSearch_StopwordList                  Список стоп-слов
WordSearch_Title                         Поиск слов
WordSearch_Total                         Всего
