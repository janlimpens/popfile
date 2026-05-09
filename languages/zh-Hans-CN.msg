# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         GB2312
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          zh-cn

# Common words that are used on their own all over the interface
Apply                                   套用
Add                                     加入
Remove                                  移除
Previous                                前一页
Next                                    下一页
From                                    寄件者
Subject                                 主旨
Reclassify                              重新分类
Undo                                    还原
Close                                   关闭
Bucket                                  邮筒
Magnet                                  吸铁
Delete                                  删除
Create                                  建立
Total                                   全部
Rename                                  更名
Update                                  更新
Refresh                                 重新整理
Date                                    日期

# The header and footer that appear on every UI page

Configuration_Language                  语言

History_SearchMessage                   搜寻寄件者/主旨

Magnet_CurrentMagnets                   现用的吸铁
Magnet_CreateNew                        建立新的吸铁

Bucket_CreateBucket                     用这个名字建立邮筒
Bucket_RenameBucket                     更改此名称的邮筒

Imap_Server                             IMAP 服务器主机名称:
Imap_Port                               IMAP 服务器连接埠:
Imap_Login                              IMAP 帐号登入:
Imap_Password                           IMAP 帐号的口令:
Imap_Expunge                            从被监视的信件匣里清除已被删除的邮件讯息.
Imap_Interval                           更新间隔秒数:
Imap_NoConnectionMessage                请先组态联机细节. 当你完成后, 这一页里就会出现更多可用的选项.
Imap_Use_SSL                            使用 SSL

# New UI keys added — batch 6
BucketSelect_AddNew	新建类别
BucketSelect_AlreadyExists	该类别名称已存在。
BucketSelect_CreateError	创建类别失败。
BucketSelect_InvalidName	无效的类别名称。
BucketSelect_NameRequired	请输入类别名称。
Corpus_Actions	操作
Corpus_AddStopword	添加停用词
Corpus_BucketList	类别列表
Corpus_Clear	清除
Corpus_Color	颜色
Corpus_LoadCandidates	加载候选词
Corpus_NoCandidates	未找到候选词。
Corpus_RemoveStopword	删除停用词
Corpus_StopwordCandidates	停用词候选
Corpus_StopwordCandidatesDesc	出现频率过高、可能影响分类的词汇。
Corpus_StopwordRatio	频率阈值
Corpus_StopwordsDesc	POPFile 在分类时忽略的词汇。
Corpus_StopwordsTitle	停用词
History_AllBuckets	所有类别
History_HighlightWords	高亮词汇
History_Loading	加载中...
History_MoveTo	移至
History_Moving	移动中...
History_Reclassifying	重新分类中...
History_ReclassifyUnclassified	重新分类未分类邮件
History_Selected	已选择
Imap_BucketFolderMappings	类别与文件夹对应
Imap_Connected	已连接
Imap_Connection	连接
Imap_ConnectionFailed	连接失败。
Imap_Description	POPFile 可以通过 IMAP 直接对邮件进行分类。
Imap_FetchFolders	获取文件夹
Imap_Fetching	获取中...
Imap_IMAFFolder	IMAP 文件夹
Imap_MappingsHint	请为每个类别指定对应的 IMAP 文件夹。
Imap_NoFoldersWatched	没有监视中的文件夹。
Imap_NoMappings	未设置对应关系。
Imap_SaveAnyway	仍然保存
Imap_SaveConnection	保存连接
Imap_SaveFolders	保存文件夹
Imap_Saving	保存中...
Imap_TestConnection	测试连接
Imap_Testing	测试中...
Imap_TrainingHint	将邮件移到相应文件夹以进行训练。
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode	训练模式
Imap_TrainingLimit	每文件夹消息数（0 = 不限）
Imap_WatchedFolders	监视中的文件夹
Imap_WatchedHint	请添加要监视的文件夹。

WordView_Title	词语准确率
WordView_SelectBucket	选择类别
WordView_Words	词语
WordView_Loading	加载中...
WordView_Empty	此类别中没有词语。
WordView_ColWord	词语
WordView_ColCount	数量
WordView_ColTotal	总计
WordView_ColAccuracy	准确率
WordView_ColActions	操作
WordView_Remove	删除
WordView_MoveTo	移动到
WordView_Move	移动
Magnet_Created	磁铁已创建。
Magnet_Deleted	磁铁已删除。
NavCorpus	语料库
NavHistory	历史
NavIMAP	IMAP
NavMagnets	磁铁
NavStatus	状态
NavWordView	词语
Reconnect_Connecting	连接中...
Reconnect_Message	POPFile 已断开连接，正在重新连接。
Reconnect_Now	立即连接
Reconnect_RetryIn	重试间隔
Reconnect_Title	连接断开
Settings_AdminPassword	管理员密码
Settings_ArchiveDirectory	归档目录
Settings_ArchiveMessages	归档邮件
Settings_ArchiveSubdirs	归档子目录
Settings_AutoDetect	自动检测
Settings_AutoDetectLanguage	自动检测语言
Settings_ChainPort	链接端口
Settings_ChainServer	链接服务器
Settings_DateFormat	日期格式
Settings_DescAdminPassword	管理界面的登录密码。
Settings_DescArchiveDir	归档邮件的目录。留空则不归档。
Settings_DescArchiveMessages	保存已分类邮件的副本。
Settings_DescArchiveSubdirs	按类别将归档分配到子目录。
Settings_DescAutoDetectLang	自动检测界面语言。
Settings_DescChainPort	链接上游 POP3 服务器的端口。
Settings_DescChainServer	上游 POP3 服务器的主机名。
Settings_DescDateFormat	日期的显示格式。
Settings_DescForceFork	强制使用进程分叉。
Settings_DescHEADFetchesBody	使用 HEAD 命令获取邮件正文。
Settings_DescHTTPPort	POPFile 网页界面端口。
Settings_DescItemsPerPage	历史记录每页显示的条目数。
Settings_DescLanguage	界面语言。
Settings_DescListenAddress	POPFile 监听连接的地址。
Settings_DescLocalOnly_UI	将网页界面限制为仅本地连接。
Settings_DescLogDirectory	日志文件目录。留空则使用 POPFile 根目录。
Settings_DescLogLevel	日志输出详细程度。
Settings_DescLogSQLToStdout	将每条 SQL 语句及其参数值输出到 stdout。
Settings_DescLogToStdout	将日志输出同时复制到 stdout。
Settings_DescMessageCutoff	每封邮件最多分析的词数（0 表示不限）。
Settings_DescNNTPLocalOnly	仅接受本地主机的 NNTP 连接。
Settings_DescNNTPPort	POPFile 监听 NNTP 的端口（默认 119）。
Settings_DescNNTPSeparator	分隔用户名和服务器的字符。
Settings_DescPOP3LocalOnly	仅接受本地主机的 POP3 连接。
Settings_DescPOP3Port	POPFile 监听 POP3 的端口（默认 1110）。
Settings_DescPOP3Separator	分隔用户名和服务器的字符（如 用户名:邮件服务器）。
Settings_DescRetentionDays	邮件历史保留天数。
Settings_DescSessionDividers	在历史记录中显示会话间的分隔线。
Settings_DescSMTPLocalOnly	仅接受本地主机的 SMTP 连接。
Settings_DescSMTPPort	POPFile 监听 SMTP 的端口（默认 25）。
Settings_DescSQLiteJournal	SQLite 日志 / WAL 模式。
Settings_DescSQLiteTweaks	位掩码：1=快速写入（安全性较低），2=定期备份。
Settings_DescSSLChainPort	上游 SSL POP3 服务器端口。
Settings_DescSSLChainServer	SSL 链接用上游 SSL POP3 服务器主机名。
Settings_DescSubjectTagLeft	插入主题头的前缀（如 [垃圾邮件]）。
Settings_DescSubjectTagRight	附加到主题头的后缀。
Settings_DescTagPosition	主题标签的位置。
Settings_DescTOPFetchesBody	使用 TOP 命令获取邮件正文。
Settings_DescUnclassifiedWeight	低于此概率的邮件被视为"未分类"的阈值。
Settings_DescWordStemming	分类前对词语进行词干提取。可提高形态丰富语言的召回率。
Settings_DescWordTable	词语概率表中显示的内容。
Settings_ErrorSaving	保存错误
Settings_ForceFork	强制分叉
Settings_HEADFetchesBody	HEAD 获取正文
Settings_HTTPPort	HTTP 端口
Settings_ItemsPerPage	每页条目数
Settings_ListenAddress	监听地址
Settings_ListenPort	监听端口
Settings_LocalOnly	仅本地
Settings_LogDirectory	日志目录
Settings_LogLevel	日志级别
Settings_LogSQLToStdout	将 SQL 输出到 stdout
Settings_LogToStdout	输出到 stdout
Settings_MessageCutoff	邮件截断数
Settings_OptDebug	调试
Settings_OptEnd	末尾
Settings_OptErrorsOnly	仅错误
Settings_OptFrequencies	频率
Settings_OptFront	前部
Settings_OptHidden	隐藏
Settings_OptInfo	信息
Settings_OptLogScores	记录得分
Settings_OptProbabilities	概率
Settings_OptWarnings	警告
Settings_RetentionDays	保留天数
Settings_SaveChanges	保存更改
Settings_Saved	已保存
Settings_Saving	保存中...
Settings_Search	搜索设置...
Settings_SectionClassifier	分类器
Settings_SectionHistory	历史
Settings_SectionLogging	日志记录
Settings_SectionNNTP	NNTP 代理
Settings_SectionPOP3	POP3 代理
Settings_SectionSecurity	安全
Settings_SectionSMTP	SMTP 代理
Settings_SectionUI	界面
Settings_ServerSeparator	服务器分隔符
Settings_SessionDividers	会话分隔线
Settings_SQLiteJournalMode	SQLite 日志模式
Settings_SQLiteTweaks	SQLite 调整
Settings_SSLChainPort	SSL 链接端口
Settings_SSLChainServer	SSL 链接服务器
Settings_SubjectTagLeft	主题标签（左）
Settings_SubjectTagRight	主题标签（右）
Settings_TagPosition	标签位置
Settings_TOPFetchesBody	TOP 获取正文
Settings_UnclassifiedWeight	未分类权重
Settings_WordStemming	词干提取
Settings_WordTable	词语表
Status_Checking	检查中...
Status_Description	POPFile 状态与统计。
Status_LoadError	加载状态数据失败。
Status_NoChecks	无检查项。

Language_Name                           中文（简体）
History_PerPage                          每页条目
Imap_Advanced                            高级
Imap_Cancel                              取消
Imap_Wizard                              设置向导
Imap_WizardApply                         创建并映射
Imap_WizardClose                         关闭
Imap_WizardDesc                          选择要创建桶和映射的文件夹。
Imap_WizardDeselectAll                   取消全选
Imap_WizardDone                          已创建并映射 {count} 个桶。
Imap_WizardEmpty                         服务器上未找到其他文件夹。
Imap_WizardSelectAll                     全选
Imap_WizardTrain                         立即训练
NavWordSearch                            词搜索
Settings_DescEnableProxy                 POPFile 启动时启动此代理。
Settings_DescLogFormat                   日志输出格式（default、tabbed、csv、plain）。
Settings_DescOpenBrowser                 启动时自动打开浏览器。
Settings_DescSQLiteBackup                在模式更改前自动备份数据库。
Settings_DescSQLiteFastWrites            禁用数据库同步（更快，安全性较低）。
Settings_EnableService                   启用服务
Settings_LogFormat                       日志格式
Settings_OpenBrowser                     打开浏览器
Settings_SQLiteBackup                    SQLite 备份
Settings_SQLiteFastWrites                SQLite 快速写入
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   添加停用词
WordSearch_ColumnBuckets                 桶
WordSearch_ColumnWord                    单词
WordSearch_IsStopword                    停用词
WordSearch_Loading                       加载中...
WordSearch_NoResults                     无结果。
WordSearch_NoStopwords                   无停用词。
WordSearch_Placeholder                   输入单词...
WordSearch_RemoveStopword                移除停用词
WordSearch_Search                        搜索
WordSearch_StopwordList                  停用词列表
WordSearch_Title                         词搜索
WordSearch_Total                         总计
