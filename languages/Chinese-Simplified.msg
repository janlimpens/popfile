# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens
#   POPFile 1.0.0 Simplified Chinese Translation
#   Created By Jedi Lin, 2004/09/19
#   In fact translated from Traditional Chinese by Encode::HanConvert
#   Modified By Jedi Lin, 2007/12/25

# Identify the language and character set used for the interface
LanguageCode                            cn
LanguageCharset                         UTF8
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          zh-cn

# This is where to find the FAQ on the Wiki
FAQLink                                 FAQ

# Common words that are used on their own all over the interface
Apply                                   套用
ApplyChanges                            套用变更
On                                      开
Off                                     关
TurnOn                                  打开
TurnOff                                 关上
Add                                     加入
Remove                                  移除
Previous                                前一页
Next                                    下一页
From                                    寄件者
Subject                                 主旨
Cc                                      副本
Classification                          邮筒
Reclassify                              重新分类
Probability                             可能性
Scores                                  分数
QuickMagnets                            快速吸铁
Undo                                    还原
Close                                   关闭
Find                                    寻找
Filter                                  过滤器
Yes                                     是
No                                      否
ChangeToYes                             改成是
ChangeToNo                              改成否
Bucket                                  邮筒
Magnet                                  吸铁
Delete                                  删除
Create                                  建立
To                                      收件人
Total                                   全部
Rename                                  更名
Frequency                               频率
Probability                             可能性
Score                                   分数
Lookup                                  查找
Word                                    字词
Count                                   计数
Update                                  更新
Refresh                                 重新整理
FAQ                                     常见问答集
ID                                      ID
Date                                    日期
Arrived                                 收件时间
Size                                    大小

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       ,
Locale_Decimal                         .

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <<format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %m/%d %T %z | %A %Y/%m/%d %T %z

# The header and footer that appear on every UI page
Header_Title                            POPFile 控制中心
Header_Shutdown                         停掉 POPFile
Header_History                          历史
Header_Buckets                          邮筒
Header_Configuration                    组态
Header_Advanced                         进阶
Header_Security                         安全
Header_Magnets                          吸铁

Footer_HomePage                         POPFile 首页
Footer_Manual                           手册
Footer_Forums                           讨论区
Footer_FeedMe                           捐助
Footer_RequestFeature                   功能请求
Footer_MailingList                      邮递论题
Footer_Wiki                             文件集

Configuration_Error1                    分隔符祇能是单一的字符
Configuration_Error2                    使用者接口的连接埠一定要介于 1 和 65535 之间
Configuration_Error3                    POP3 聆听连接埠一定要介于 1 和 65535 之间
Configuration_Error4                    页面大小一定要介于 1 和 1000 之间
Configuration_Error5                    历史里要保留的日数一定要介于 1 和 366 之间
Configuration_Error6                    TCP 逾时值一定要介于 10 和 1800 之间
Configuration_Error7                    XML RPC 聆听连接埠一定要介于 1 和 65535 之间
Configuration_Error8                    SOCKS V 代理服务器连接埠一定要介于 1 和 65535 之间
Configuration_POP3Port                  POP3 聆听连接埠
Configuration_POP3Update                POP3 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_XMLRPCUpdate              XML-RPC 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_XMLRPCPort                XML-RPC 聆听连接埠
Configuration_SMTPPort                  SMTP 聆听连接埠
Configuration_SMTPUpdate                SMTP 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_NNTPPort                  NNTP 聆听连接埠
Configuration_NNTPUpdate                NNTP 连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_POPFork                   允许重复的 POP3 联机
Configuration_SMTPFork                  允许重复的 SMTP 联机
Configuration_NNTPFork                  允许重复的 NNTP 联机
Configuration_POP3Separator             POP3 主机:连接埠:使用者 分隔符
Configuration_NNTPSeparator             NNTP 主机:连接埠:使用者 分隔符
Configuration_POP3SepUpdate             POP3 的分隔符已更新为 %s
Configuration_NNTPSepUpdate             NNTP 的分隔符已更新为 %s
Configuration_UI                        使用者接口网页连接埠
Configuration_UIUpdate                  使用者接口网页连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Configuration_History                   每一页所要列出的邮件讯息数量
Configuration_HistoryUpdate             每一页所要列出的邮件讯息数量已更新为 %s
Configuration_Days                      历史里所要保留的天数
Configuration_DaysUpdate                历史里所要保留的天数已更新为 %s
Configuration_UserInterface             使用者接口
Configuration_Skins                     外观样式
Configuration_SkinsChoose               选择外观样式
Configuration_Language                  语言
Configuration_LanguageChoose            选择语言
Configuration_ListenPorts               模块选项
Configuration_HistoryView               历史检视
Configuration_TCPTimeout                联机逾时
Configuration_TCPTimeoutSecs            联机逾时秒数
Configuration_TCPTimeoutUpdate          联机逾时秒数已更新为 %s
Configuration_ClassificationInsertion   插入邮件讯息文字
Configuration_SubjectLine               变更主旨列
Configuration_XTCInsertion              在标头插入<br>X-Text-Classification
Configuration_XPLInsertion              在标头插入<br>X-POPFile-Link
Configuration_Logging                   日志
Configuration_None                      无
Configuration_ToScreen                  输出至屏幕 (Console)
Configuration_ToFile                    输出至档案
Configuration_ToScreenFile              输出至屏幕及档案
Configuration_LoggerOutput              日志输出方式
Configuration_GeneralSkins              外观样式
Configuration_SmallSkins                小型外观样式
Configuration_TinySkins                 微型外观样式
Configuration_CurrentLogFile            &lt;检视目前的日志档&gt;
Configuration_SOCKSServer               SOCKS V 代理服务器主机
Configuration_SOCKSPort                 SOCKS V 代理服务器连接埠
Configuration_SOCKSPortUpdate           SOCKS V 代理服务器连接埠已更新为 %s
Configuration_SOCKSServerUpdate         SOCKS V 代理服务器主机已更新为 %s
Configuration_Fields                    历史字段

Advanced_Error1                         '%s' 已经在忽略字词清单里了
Advanced_Error2                         要被忽略的字词仅能包含字母数字, ., _, -, 或 @ 字符
Advanced_Error3                         '%s' 已被加入忽略字词清单里了
Advanced_Error4                         '%s' 并不在忽略字词清单里
Advanced_Error5                         '%s' 已从忽略字词清单里被移除了
Advanced_StopWords                      被忽略的字词
Advanced_Message1                       POPFile 会忽略下列这些常用的字词:
Advanced_AddWord                        加入字词
Advanced_RemoveWord                     移除字词
Advanced_AllParameters                  所有的 POPFile 参数
Advanced_Parameter                      参数
Advanced_Value                          值
Advanced_Warning                        这是完整的 POPFile 参数清单.  祇适合进阶使用者: 你可以变更任何参数值并按下 更新; 不过没有任何机制会检查这些参数值的有效性.  以粗体显示的项目表示已经从预设值被加以变更了.  更详尽的选项信息请见 <a href="http://getpopfile.org/docs/OptionReference">OptionReference</a>.
Advanced_ConfigFile                     组态档:

History_Filter                          &nbsp;(祇显示 <font color="%s">%s</font> 邮筒)
History_FilterBy                        过滤条件
History_Search                          &nbsp;(按寄件者/主旨来搜寻 %s)
History_Title                           最近的邮件讯息
History_Jump                            跳到这一页
History_ShowAll                         全部显示
History_ShouldBe                        应该要是
History_NoFrom                          没有寄件者列
History_NoSubject                       没有主旨列
History_ClassifyAs                      分类成
History_MagnetUsed                      使用了吸铁
History_MagnetBecause                   <b>使用了吸铁</b><p>被分类成 <font color="%s">%s</font> 的原因是 %s 吸铁</p>
History_ChangedTo                       已变更为 <font color="%s">%s</font>
History_Already                         重新分类成 <font color="%s">%s</font>
History_RemoveAll                       全部移除
History_RemovePage                      移除本页
History_RemoveChecked                   移除被核选的
History_Remove                          按此移除历史里的项目
History_SearchMessage                   搜寻寄件者/主旨
History_NoMessages                      没有邮件讯息
History_ShowMagnet                      用了吸铁
History_Negate_Search                   负向搜寻/过滤
History_Magnet                          &nbsp;(祇显示由吸铁所分类的邮件讯息)
History_NoMagnet                        &nbsp;(祇显示不是由吸铁所分类的邮件讯息)
History_ResetSearch                     重设
History_ChangedClass                    现在被分类为
History_Purge                           即刻到期
History_Increase                        增加
History_Decrease                        减少
History_Column_Characters               变更寄件者, 收件者, 副本和主旨字段的宽度
History_Automatic                       自动化
History_Reclassified                    已重新分类
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          口令
Password_Enter                          输入口令
Password_Go                             冲!
Password_Error1                         不正确的口令

Security_Error1                         连接埠一定要介于 1 和 65535 之间
Security_Stealth                        鬼鬼祟祟模式/服务器作业
Security_NoStealthMode                  否 (鬼鬼祟祟模式)
Security_StealthMode                    (鬼鬼祟祟模式)
Security_ExplainStats                   (这个选项开启后, POPFile 每天都会传送一次下列三个数值到 getpopfile.org 的一个脚本: bc (你的邮筒数量), mc (被 POPFile 分类过的邮件讯息总数) 和 ec (分类错误的总数).  这些数值会被储存到一个档案里, 然后会被我用来发布一些关于人们使用 POPFile 的情况跟其成效的统计数据.  我的网页服务器会保留其本身的日志档约 5 天, 然后就会加以删除; 我不会储存任何统计与单独 IP 地址间的关联性起来.)
Security_ExplainUpdate                  (这个选项开启后, POPFile 每天都会传送一次下列三个数值到 getpopfile.org 的一个脚本: ma (你的 POPFile 的主要版本编号), mi (你的 POPFile 的次要版本编号) 和 bn (你的 POPFile 的建号).  新版推出时, POPFile 会收到一份图形响应, 并且显示在画面顶端.  我的网页服务器会保留其本身的日志档约 5 天, 然后就会加以删除; 我不会储存任何更新检查与单独 IP 地址间的关联性起来.)
Security_PasswordTitle                  使用者接口口令
Security_Password                       口令
Security_PasswordUpdate                 口令已更新
Security_AUTHTitle                      远程服务器
Security_SecureServer                   远程 POP3 服务器 (SPA/AUTH 或穿透式代理服务器)
Security_SecureServerUpdate             远程 POP3 服务器已更新为 %s
Security_SecurePort                     远程 POP3 连接埠 (SPA/AUTH 或穿透式代理服务器)
Security_SecurePortUpdate               远程 POP3 连接埠已更新为 %s
Security_SMTPServer                     SMTP 连锁服务器
Security_SMTPServerUpdate               SMTP 连锁服务器已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Security_SMTPPort                       SMTP 连锁连接埠
Security_SMTPPortUpdate                 SMTP 连锁连接埠已更新为 %s; 这项更动在你重新激活 POPFile 前都不会生效
Security_POP3                           接受来自远程机器的 POP3 联机 (需要重新激活 POPFile)
Security_SMTP                           接受来自远程机器的 SMTP 联机 (需要重新激活 POPFile)
Security_NNTP                           接受来自远程机器的 NNTP 联机 (需要重新激活 POPFile)
Security_UI                             接受来自远程机器的 HTTP (使用者接口) 联机 (需要重新激活 POPFile)
Security_XMLRPC                         接受来自远程机器的 XML-RPC 联机 (需要重新激活 POPFile)
Security_UpdateTitle                    自动更新检查
Security_Update                         每天检查 POPFile 是否有更新
Security_StatsTitle                     回报统计数据
Security_Stats                          每日送出统计数据

Magnet_Error1                           '%s' 吸铁已经存在于 '%s' 邮筒里了
Magnet_Error2                           新的 '%s' 吸铁跟既有的 '%s' 吸铁起了冲突, 可能会引起 '%s' 邮筒内的歧异结果.  新的吸铁不会被加进去.
Magnet_Error3                           建立新的吸铁 '%s' 于 '%s' 邮筒中
Magnet_CurrentMagnets                   现用的吸铁
Magnet_Message1                         下列的吸铁会让信件总是被分类到特定的邮筒里.
Magnet_CreateNew                        建立新的吸铁
Magnet_Explanation                      有这些类别的吸铁可以用: <ul><li><b>寄件者地址或名字:</b> 举例来说: john@company.com 就祇会吻合特定的地址, <br />company.com 会吻合到任何从 company.com 寄出来的人, <br />John Doe 会吻合特定的人, John 会吻合所有的 Johns</li><li><b>收件者/副本地址或名称:</b> 就跟寄件者一样: 但是吸铁祇会针对邮件讯息里的 To:/Cc: 地址生效</li> <li><b>主旨字词:</b> 例如: hello 会吻合所有主旨里有 hello 的邮件讯息</li></ul>
Magnet_MagnetType                       吸铁类别
Magnet_Value                            值
Magnet_Always                           总是分到邮筒
Magnet_Jump                             跳到吸铁页面

Bucket_Error1                           邮筒名称祇能含有小写 a 到 z 的字母, 0 到 9 的数字, 加上 - 和 _
Bucket_Error2                           已经有名为 %s 的邮筒了
Bucket_Error3                           已经建立了名为 %s 的邮筒
Bucket_Error4                           请输入非空白的字词
Bucket_Error5                           已经把 %s 邮筒改名为 %s 了
Bucket_Error6                           已经删除了 %s 邮筒了
Bucket_Title                            邮筒组态
Bucket_BucketName                       邮筒名称
Bucket_WordCount                        字词计数
Bucket_WordCounts                       字词数目统计
Bucket_UniqueWords                      独特的<br>字词数
Bucket_SubjectModification              修改主旨标头
Bucket_ChangeColor                      邮筒颜色
Bucket_NotEnoughData                    数据不足
Bucket_ClassificationAccuracy           分类准确度
Bucket_EmailsClassified                 已分类的邮件讯息数量
Bucket_EmailsClassifiedUpper            邮件讯息分类结果
Bucket_ClassificationErrors             分类错误
Bucket_Accuracy                         准确度
Bucket_ClassificationCount              分类计数
Bucket_ClassificationFP                 伪阳性分类
Bucket_ClassificationFN                 伪阴性分类
Bucket_ResetStatistics                  重设统计数据
Bucket_LastReset                        前次重设于
Bucket_CurrentColor                     %s 现用的颜色为 %s
Bucket_SetColorTo                       设定 %s 的颜色为 %s
Bucket_Maintenance                      维护
Bucket_CreateBucket                     用这个名字建立邮筒
Bucket_DeleteBucket                     删掉此名称的邮筒
Bucket_RenameBucket                     更改此名称的邮筒
Bucket_Lookup                           查找
Bucket_LookupMessage                    在邮筒里查找字词
Bucket_LookupMessage2                   查找此字词的结果
Bucket_LookupMostLikely                 <b>%s</b> 最像是在 <font color="%s">%s</font> 会出现的单词
Bucket_DoesNotAppear                    <p><b>%s</b> 并未出现于任何邮筒里
Bucket_DisabledGlobally                 已全域停用的
Bucket_To                               至
Bucket_Quarantine                       隔离邮筒

SingleBucket_Title                      %s 的详细数据
SingleBucket_WordCount                  邮筒字词计数
SingleBucket_TotalWordCount             全部的字词计数
SingleBucket_Percentage                 占全部的百分比
SingleBucket_WordTable                  %s 的字词表
SingleBucket_Message1                   按下索引里的字母来看看所有以该字母开头的字词.  按下任何字词就可以查找它在所有邮筒里的可能性.
SingleBucket_Unique                     %s 独有的
SingleBucket_ClearBucket                移除所有的字词

Session_Title                           POPFile 阶段时期已逾时
Session_Error                           你的 POPFile 阶段时期已经逾期了.  这可能是因为你激活并停止了 POPFile 但却保持网页浏览器开启所致.  请按下列的链接之一来继续使用 POPFile.

View_Title                              单一邮件讯息检视
View_ShowFrequencies                    显示字词频率
View_ShowProbabilities                  显示字词可能性
View_ShowScores                         显示字词得分及判定图表
View_WordMatrix                         字词矩阵
View_WordProbabilities                  正在显示字词可能性
View_WordFrequencies                    正在显示字词频率
View_WordScores                         正在显示字词得分
View_Chart                              判定图表
View_DownloadMessage                    下载邮件讯息

Windows_TrayIcon                        是否要在 Windows 的系统常驻列显示 POPFile 图标?
Windows_Console                         是否要在命令列窗口里执行 POPFile?
Windows_NextTime                        <p><font color="red">这项更动在你重新激活 POPFile 前都不会生效</font>

Header_MenuSummary                      这个表格是份导览选单, 能让你存取控制中心里不同的每一个页面.
History_MainTableSummary                这份表格列出了最近收到的邮件讯息的寄件者及主旨, 你也能在此重新加以检视并重新分类这些邮件讯息.  按一下主旨列就会显示出完整的邮件讯息文字, 以及她们为何会被如此分类的信息.  你可以在 '应该要是' 字段指定邮件讯息该归属的邮筒, 或者还原这项变更.  如果有特定的邮件讯息再也不需要了, 你也可以用 '删除' 字段来从历史里加以删除.
History_OpenMessageSummary              这个表格含有某个邮件讯息的全文, 其中被高亮度标示的字词是被用来分类的, 依据的是她们跟那个邮筒最有关联.
Bucket_MainTableSummary                 这个表格提供了分类邮筒的概况.  每一列都会显示出邮筒名称, 该邮筒里的字词总数, 每个邮筒里实际的单独字词数量, 邮件讯息的主旨列是否会在被分类到该邮筒时一并被修改, 是否要隔离被收进该邮筒里的邮件讯息, 以及一个让你挑选颜色的表格, 这个颜色会在控制中心里显示于任何跟该邮筒有关的地方.
Bucket_StatisticsTableSummary           这个表格提供了三组跟 POPFile 整体效能有关的统计数据.  第一组是其分类准确度如何, 第二组是共有多少邮件讯息被加以分类到那个邮筒里, 第三组是每个邮筒里有多少字词及其关联百分比.
Bucket_MaintenanceTableSummary          这个表格含有一个表单, 让你能够建立, 删除, 或重新命名某个邮筒, 也可以在所有的邮筒里查找某个字词, 看看其关联可能性.
Bucket_AccuracyChartSummary             这个表格用图形显示了邮件讯息分类的准确度.
Bucket_BarChartSummary                  这个表格用图形显示了不同邮筒所占据的百分比.  这同时计算了被分类的邮件讯息数量, 以及全部的字词计数.
Bucket_LookupResultsSummary             这个表格显示了与尸体里任何给定字词关联的可能性.  对于每个邮筒来说, 她都会显示出该字词发生的频率, 字词会出现在该邮筒里的可能性, 以及当该字词出现在邮件讯息里时, 对于该邮筒得分的整体影响.
Bucket_WordListTableSummary             这个表格提供了特定邮筒里全部的字词清单, 按照开头的字母逐列整理.
Magnet_MainTableSummary                 这个表格显示了吸铁清单, 这些吸铁是用来按照固定规则把邮件讯息加以分类的.  每一列都会显示出吸铁如何被定义著, 其所觊觎的邮筒, 还有用来删除该吸铁的按钮.
Configuration_MainTableSummary          这个表格含有数个表单, 让你控制 POPFile 的组态.
Configuration_InsertionTableSummary     这个表格含有一些按钮, 判断是否要在邮件讯息递送给邮件用户端程序前, 先行修改标头或主旨列.
Security_MainTableSummary               这个表格提供了几组控制, 能影响 POPFile 整体组态的安全, 是否要自动检查程序更新, 以及是否要把 POPFile 效能统计数据的一般信息传回程序作者的中央数据库.
Advanced_MainTableSummary               这个表格提供了一份 POPFile 分类邮件讯息时所会忽略的字词清单, 因为他们在一般邮件讯息里的关联过于频繁.  她们会被按照字词开头的字亩被逐列整理.

Imap_Bucket2Folder                      '<b>%s</b>' 邮筒的信件至邮件匣
Imap_MapError                           你不能把超过一个的邮筒对应到单一的邮件匣里!
Imap_Server                             IMAP 服务器主机名称:
Imap_ServerNameError                    请输入服务器的主机名称!
Imap_Port                               IMAP 服务器连接埠:
Imap_PortError                          请输入有效的连接埠号码!
Imap_Login                              IMAP 帐号登入:
Imap_LoginError                         请输入使用者/登入名称!
Imap_Password                           IMAP 帐号的口令:
Imap_PasswordError                      请输入要用于服务器的口令!
Imap_Expunge                            从被监视的信件匣里清除已被删除的邮件讯息.
Imap_Interval                           更新间隔秒数:
Imap_IntervalError                      请输入介于 10 秒至 3600 秒间的间隔.
Imap_Bytelimit                          每封邮件讯息要用来分类的字节数. 输入 0 (空) 表示完整的邮件讯息:
Imap_BytelimitError                     请输入数值.
Imap_RefreshFolders                     重新整理邮件匣清单
Imap_Now                                现在!
Imap_UpdateError1                       无法登入. 请验证你的登入名称跟口令.
Imap_UpdateError2                       连接至服务器失败. 请检查主机名称跟连接埠, 并请确认你正在线上.
Imap_UpdateError3                       请先组态联机细节.
Imap_NoConnectionMessage                请先组态联机细节. 当你完成后, 这一页里就会出现更多可用的选项.
Imap_WatchMore                          被监视邮件匣清单的邮件匣
Imap_WatchedFolder                      被监视的邮件匣编号
Imap_Use_SSL                            使用 SSL

Shutdown_Message                        POPFile 已经被停掉了

Help_Training                           当你初次使用 POPFile 时, 她啥也不懂而需要被加以调教. POPFile 的每一个邮筒都需要用邮件讯息来加以调教, 祇有当你重新把某个被 POPFile 错误分类的邮件讯息重新分类到正确的邮筒时, 才真的是在调教她. 同时你也得设定你的邮件用户端程序, 来按照 POPFile 的分类结果加以过滤邮件讯息. 关于设定用户端过滤器的信息可以在 <a href="http://getpopfile.org/docs/FAQ:EmailSorting">POPFile 文件计画</a>里被找到.
Help_Bucket_Setup                       POPFile 除了 "未分类 (unclassified)" 的假邮筒外, 还需要至少两个邮筒. 而 POPFile 的独特之处正在于她对电子邮件的区分更胜于此, 你甚至可以有任意数量的邮筒. 简单的设定会是像 "垃圾 (spam)", "个人 (personal)", 和 "工作 (work)" 邮筒.
Help_No_More                            别再显示这个说明了

# New UI keys added — batch 6
WikiLink	index.php
RequestFeatureLink	RequestFeature
MailingListLink	mailing_lists
DonateLink	Donate
Bucket_InIgnoredWords	忽略词汇
BucketSelect_AddNew	新建类别
BucketSelect_AlreadyExists	该类别名称已存在。
BucketSelect_CreateError	创建类别失败。
BucketSelect_InvalidName	无效的类别名称。
BucketSelect_NameRequired	请输入类别名称。
Configuration_Error9	用户界面端口不能与 POP3 端口相同
Configuration_Error10	POP3 端口不能与用户界面端口相同
Corpus_Actions	操作
Corpus_AddStopword	添加停用词
Corpus_BucketList	类别列表
Corpus_Clear	清除
Corpus_Color	颜色
Corpus_LoadCandidates	加载候选词
Corpus_NoCandidates	未找到候选词。
Corpus_RemoveStopword	删除停用词
Corpus_Search	搜索
Corpus_StopwordCandidates	停用词候选
Corpus_StopwordCandidatesDesc	出现频率过高、可能影响分类的词汇。
Corpus_StopwordRatio	频率阈值
Corpus_StopwordsDesc	POPFile 在分类时忽略的词汇。
Corpus_StopwordsTitle	停用词
Corpus_WordsLink	词语 →
History_AllBuckets	所有类别
History_HighlightWords	高亮词汇
History_Loading	加载中...
History_MoveTo	移至
History_Moving	移动中...
History_NoMatchingMessages	未找到匹配的邮件。
History_Reclassifying	重新分类中...
History_ReclassifyUnclassified	重新分类未分类邮件
History_Selected	已选择
Imap_BucketFolderMappings	类别与文件夹对应
Imap_Connected	已连接
Imap_Connection	连接
Imap_ConnectionFailed	连接失败。
Imap_Description	POPFile 可以通过 IMAP 直接对邮件进行分类。
Imap_EnableService	启用 IMAP
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
Imap_Service	IMAP 服务
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
NavSettings	设置
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
View_MessageBody	邮件正文
View_MessageHeader	邮件头

Language_Name                           中文（简体）
