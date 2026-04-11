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
LanguageCode                            ar
LanguageCharset                         utf-8
LanguageDirection                       rtl

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          ar

# This is where to find the FAQ on the Wiki
FAQLink                                 FAQ

# Common words that are used on their own all over the interface
Apply                                   تطبيق
On                                      نشط
Off                                     مقفل
TurnOn                                  نشّط
TurnOff                                 إقفل
Add                                     أضف
Remove                                  إحذف
Previous                                السابق
Next                                    التالي
From                                    مُرسل
Subject                                 موضوع
Cc                                      نسخة خفية (Cc)
Classification                          تصنيف
Reclassify                              أعد التصنيف
Probability                             إحتمالية
Scores                                  نتائج
QuickMagnets                            مغناطيس سريع
Undo                                    تراجع
Close                                   أغلق
Find                                    إبحث
Filter                                  صنّف
Yes                                     نعم
No                                      لا
ChangeToYes                             غيّر الى نعم
ChangeToNo                              غيّر الى لا
Bucket                                  دلو
Magnet                                  مغناطيس
Delete                                  إحذف
Create                                  إصنع
To                                      مستقبل
Total                                   إجمالي
Rename                                  أعادة تسمية
Frequency                               تكرار
Probability                             إحتمالية
Score                                   نتيجة
Lookup                                  إبحث
Word                                    كلمة
Count                                   مجموع
Update                                  تحديث
Refresh                                 تحديث
FAQ                                     أسئلة شائعة
ID                                      ID
Date                                    تاريخ
Arrived                                 وصول
Size                                    حجم

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

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            مركز تحكم POPFile
Header_Shutdown                         إنهاء البرنامج
Header_History                          محفوظات
Header_Buckets                          دلاء
Header_Configuration                    إعدادات
Header_Advanced                         خيارات متقدمة
Header_Security                         الأمان
Header_Magnets                          مغناطيس

Footer_HomePage                         صفحة البداية
Footer_Manual                           تعليمات
Footer_Forums                           منتدى
Footer_FeedMe                           تبرّع
Footer_RequestFeature                   أطلب ميزة
Footer_MailingList                      مجموعة بريدية
Footer_Wiki                             وثائق

Configuration_Error1                    حرف الفصل يحب أن يكون مفرداً
Configuration_Error2                    بوابة الإتصال لواجهة المستخدم يجب أن تكون رقماً بين 1 و 65535
Configuration_Error3                    بوابة الإتصال لـِ POP3 يجب أن تكون رقماً بين 1 و 65535
Configuration_Error4                    حجم الصفحة يحب أن يكون رقماً بين 1 و 1000
Configuration_Error5                    عدد أيام المحفوظات يحب أن يكون رقماً بين 1 و 366
Configuration_Error6                    زمن إنهاء إتصال TCP يجب أن يكون رقماً بين 10 و 1800
Configuration_Error7                    بوابة إتصال XML RPC يجب أن تكون رقماً بين 1 و 65535
Configuration_Error8                    بوابة إتصال Socks V يجب أن تكون رقماً بين 1 و 65535
Configuration_POP3Port                  بوابة إتصال POP3
Configuration_POP3Update                لقد تم تعديل بوابة إتصال POP3 إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Configuration_XMLRPCUpdate              لقد تم تعديل بوابة إتصال XML-RPC إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Configuration_XMLRPCPort                بوابة إتصال XML-RPC
Configuration_SMTPPort                  بوابة إتصال SMTP
Configuration_SMTPUpdate                لقد تم تعديل بوابة إتصال SMTP إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Configuration_NNTPPort                  بوابة الاتصال إلى NNTP
Configuration_NNTPUpdate                لقد تم تعديل بوابة إتصال NNTP إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Configuration_POPFork                   إسمح لعدة اتصالات POP3 بشكل متزامن
Configuration_SMTPFork                  إسمح لعدة اتصالات SMTP بشكل متزامن
Configuration_NNTPFork                  إسمح لعدة اتصالات NNTP بشكل متزامن
Configuration_POP3Separator             حرف فصل POP3 بين host:port:user
Configuration_NNTPSeparator             حرف فصل NNTP  بين host:port:user
Configuration_POP3SepUpdate             تم تعديل حرف فصل POP3 إلى %s
Configuration_NNTPSepUpdate             تم تعديل حرف فصل NNTP إلى %s
Configuration_UI                        بوابة الإتصال لواجهة المستخدم
Configuration_UIUpdate                  لقد تم تعديل بوابة إتصال واجهة المستخدم إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Configuration_History                   عدد الرسائل في كل صفحة
Configuration_HistoryUpdate             لقد تم تعديل عدد الرسائل في كل صفحة إلى %s
Configuration_Days                      عدد أيام المحفوظات للإبقاء
Configuration_DaysUpdate                لقد تم تعديل عدد أيام المحفوظات للإبقاء إلى %s
Configuration_UserInterface             واجهة المستخدم
Configuration_Skins                     سمة الواجهة
Configuration_SkinsChoose               إختر سمة الواجهة
Configuration_Language                  لغة
Configuration_LanguageChoose            إختر اللغة
Configuration_ListenPorts               اختيارات البُريمج
Configuration_HistoryView               عرض المحفوظات
Configuration_TCPTimeout                زمن إنهاء الإتصال
Configuration_TCPTimeoutSecs            زمن إنهاء الإتصال (ثوان)
Configuration_TCPTimeoutUpdate          تم تعديل زمن إنهاء الإتصال إلى %s
Configuration_ClassificationInsertion   إضافة إلى نص رسالة
Configuration_SubjectLine               تعديل<br>سطر الموضوع
Configuration_XTCInsertion              رأسية<br>X-Text-Classification
Configuration_XPLInsertion              رأسية<br>X-POPFile-Link
Configuration_Logging                   سجلات
Configuration_None                      بلا
Configuration_ToScreen                  إلى الشاشة
Configuration_ToFile                    إلى ملف
Configuration_ToScreenFile              إلى الشاشة وملف
Configuration_LoggerOutput              ناتج السجل
Configuration_GeneralSkins              سمة الواجهة
Configuration_SmallSkins                سمات صغيرة
Configuration_TinySkins                 سمات صغيرة جداً
Configuration_CurrentLogFile            &lt;ملف السجل الحالي&gt;
Configuration_SOCKSServer               ملقم وكيل خادم SOCKS V
Configuration_SOCKSPort                 بوابة إتصال ملقم وكيل SOCKS V
Configuration_SOCKSPortUpdate           تم تعديل بوابة إتصال ملقم وكيل SOCKS V إلى %s
Configuration_SOCKSServerUpdate         تم تعديل خادم ملقم وكيل SOCKS V إلى %s
Configuration_Fields                    أعمدة المحفوظات

Advanced_Error1                         '%s' موجودة مسبقاً في لائحة الكلمات المهملة
Advanced_Error2                         الكلمات المهملة يمكن أن تحتوي فقط احرف أو ارقام أو . أو _ أو - أو @
Advanced_Error3                         لقد تم إضافة '%s' إلى لائحة الكلمات المهملة
Advanced_Error4                         '%s' ليست في لائحة الكلمات المهملة
Advanced_Error5                         لقد تم إزالة '%s' من لائحة الكلمات المهملة
Advanced_StopWords                      كلمات مهملة
Advanced_Message1                       POPFile يهمل الكلمات الشائعة الإستعمال التالية:
Advanced_AddWord                        أضف كلمة
Advanced_RemoveWord                     إحذف كلمة
Advanced_AllParameters                  كافة معايير POPFile
Advanced_Parameter                      معيار
Advanced_Value                          قيمة
Advanced_Warning                        هذه قائمة كاملة بكافة معايير POPFile. للمستخدمين المحترفين فقط: يمكنكم تغيير أي قيمة ومن ثم الضغط على "تحديث"؛ لا يوجد تدقيق على صحة المعلومات.
Advanced_ConfigFile                     ملف الإعدادات:

History_Filter                          &nbsp;(عرض الدلو <font color="%s">%s</font>)
History_FilterBy                        صنّف على
History_Search                          &nbsp;(جرى البحث عن مُرسل/موضوع %s)
History_Title                           رسائل حديثة
History_Jump                            إذهب الى صفحة
History_ShowAll                         إعرض الكل
History_ShouldBe                        يفضّل أن يكون
History_NoFrom                          لا يوجد سطر "from"
History_NoSubject                       لا يوجد سطر "subject"
History_ClassifyAs                      صنّف مثل
History_MagnetUsed                      مغناطيس مستعمل
History_MagnetBecause                   <b>مغناطيس مستعمل</b><p>صنف إلى <font color="%s">%s</font> بسبب المغناطيس %s </p>
History_ChangedTo                       تم تغيره إلى <font color="%s">%s</font>
History_Already                         أعيد تصنيفه إلى <font color="%s">%s</font>
History_RemoveAll                       حذف الكل
History_RemovePage                      حذف الصفحة
History_RemoveChecked                   حذف المختار
History_Remove                          لحذف مدخلات من المحفوظات إضغط
History_SearchMessage                   إبحث مرسل/موضوع
History_NoMessages                      لا توجد رسائل
History_ShowMagnet                      ممغنط
History_Negate_Search                   أعكس البحث/التصنيف
History_Magnet                          &nbsp;(عرض الرسائل المصنفة مغناطيسياً فقط)
History_NoMagnet                        &nbsp;(عرض الرسائل غير المصنفة مغناطيسياً فقط)
History_ResetSearch                     تصفير البحث
History_ChangedClass                    سيتم تصنيفه الآن كما
History_Purge                           إحذف الآن
History_Increase                        زِد
History_Decrease                        خفّض
History_Column_Characters               قم بتغيير عرض أعمدة مرسل، مستقبل، Cc، موضوع
History_Automatic                       تلقائي
History_Reclassified                    أعيد تصنيقه
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          كلمة المرور
Password_Enter                          أدخل كلمة المرور
Password_Go                             أدخل
Password_Error1                         كلمة المرور خاطئة

Security_Error1                         البوابة يجب أن تكون رقماً بين 1 و 65535
Security_Stealth                        نظام الإخفاء/عمليات الخادم
Security_NoStealthMode                  لا (نظام الإخفاء)
Security_StealthMode                    (Stealth Mode)
Security_ExplainStats                   (عندما يكون فعالاً يقوم POPFile بإرسال القيم الثلاث التالية إلى getpopfile.org مرة واحدة في اليوم: bc (إجمالي عدد الدلاء التي عندك)، mc (إجمالي عدد الرسائل التي صنفها POPFile) و ec (إجمالي عدد أخطاء التصنيف). هذه القيم تخزن في ملف ومن ثم يتم إستعمالها لنشر إحصاءات عن كيفية استعمال الناس لـ POPFile ومدى نجاهة. الخادم الأساسي يقوم بحفظ السجلات لمدة 5 أيام ومن ثم يتم حذفها؛ ليس هناك سجلات تربط بين الإحصاءات وعناوين IP الفردية).
Security_ExplainUpdate                  (عندما يكون فعالاً يقوم POPFile بإرسال القيم الثلاث التالية إلى getpopfile.org مرة واحدة في اليوم: ma (رقم الإصدار الأعلى لنسخة POPFile المركبة)، mi (رقم الإصدار الأدنى لنسخة POPFile المركبة) و bn (رقم البنية لنسخة POPFile المركبة). POPFile يحصل على جواب على شكل صورة تظهر في أعلى الصفحة إذا ما كان هناك تحديث. الخادم الأساسي يقوم بحفظ السجلات لمدة 5 أيام ومن ثم يتم حذفها؛ ليس هناك سجلات تربط بين تفحص التحديثات وعناوين IP الفردية).
Security_PasswordTitle                  كلمة المرور لواجهة المستخدم
Security_Password                       كلمة المرور
Security_PasswordUpdate                 تم تعديل كلمة المرور
Security_AUTHTitle                      خادم عن بعد
Security_SecureServer                   خادم POP3 SPA/AUTH
Security_SecureServerUpdate             لقد تم تعديل الخادم الآمن إلى %s؛ هذا التعديل لن يكون فعالا إلى أن يتم إعادة تشغيل POPFile
Security_SecurePort                     بوابة إتصال POP3 SPA/AUTH
Security_SecurePortUpdate               لقد تم تعديل بوابة إتصال POP3 SPA/AUTH إلى %s؛ هذا التعديل لن يكون فعالا  إلى أن يتم إعادة تشغيل POPFile
Security_SMTPServer                     خادم SMTP المتسلسل
Security_SMTPServerUpdate               لقد تم تعديل خادم SMTP المتسلسل إلى %s؛ هذا التعديل لن يكون فعالا  إلى أن يتم إعادة تشغيل POPFile
Security_SMTPPort                       بوابة إتصال SMTP المتسلسلة
Security_SMTPPortUpdate                 لقد تم تعديل بوابة إتصال SMTP المتسلسلة إلى %s؛ هذا التعديل لن يكون فعالا  إلى أن يتم إعادة تشغيل POPFile
Security_POP3                           تقبّل إتصالات POP3 من أجهزة عن بعد (يتطلب إعادة تشغيل POPFile)
Security_SMTP                           تقبّل إتصالات SMTP من أجهزة عن بعد (يتطلب إعادة تشغيل POPFile)
Security_NNTP                           تقبّل إتصالات NNTP من أجهزة عن بعد (يتطلب إعادة تشغيل POPFile)
Security_UI                             تقبّل إتصالات HTTP (واجهة المستخدم) من أجهزة عن بعد (يتطلب إعادة تشغيل POPFile)
Security_XMLRPC                         تقبّل إتصالات XML-RPC من أجهزة عن بعد (يتطلب إعادة تشغيل POPFile)
Security_UpdateTitle                    التحديث التلقائي
Security_Update                         تفحص التحديثات يومياً
Security_StatsTitle                     التقارير الإحصائية
Security_Stats                          ارسل الإحصاءات يومياً

Magnet_Error1                           المغناطيس '%s' موجود مسبقاً في الدلو '%s'
Magnet_Error2                           المغناطيس الجديد '%s' يتضارب مع المغناطيس '%s' في الدلو '%s' ويمكن أن يتسبب في نتائج غريبة. لم يتم إضافة المغناطيس.
Magnet_Error3                           إصنع مغناطيس جديد '%s' في الدلو '%s'
Magnet_CurrentMagnets                   مغناطيسات حالية
Magnet_Message1                         المغناطيسات التالية تجعل البريد أن يتصنف في الدلو المذكور.
Magnet_CreateNew                        صنع مغناطيس جديد
Magnet_Explanation                      توجد هذه الأنواع من المغناطسيات: <ul><li><b>إسم أو عنوان المرسل</b> مثال: john@company.com لمطابقة وفق عنوان محدد، <br />company.com لمطابقة كل المرسلين من company.com، <br />John Doe لمطابقة وفق اسم شخص محدد، <br />John لمطابقة كل الأشخاص بذلك الأسم</li><li><b>إسم أو عنوان المستقبل:</b> نفس مثال المرسل: لكن يتم التصنيف على على عنوان To/Cc في الرسالة</li> <li><b>كلمات الموضوع:</b> مثال: hello لمطابقة كل الرسائل التي بها hello في سطر الموضوع</li></ul>
Magnet_MagnetType                       نوع المغناطيس
Magnet_Value                            قيمة
Magnet_Always                           يذهب فوراً إلى الدلو
Magnet_Jump                             إذهب إلى صفحة

Bucket_Error1                           أسامي الدلاء يمكن أن تحتوي فقط أحرف من a إلى z بأحرف صغيرة، أرقام من 0 إلى 9، - و _
Bucket_Error2                           دلو بإسم %s موجود مسبقاً
Bucket_Error3                           تم صنع دلو بإسم %s
Bucket_Error4                           الرجاء إدخال كلمة غير فارغة
Bucket_Error5                           أعد تسمية الدلو %s إلى %s
Bucket_Error6                           تم حذف الدلو %s
Bucket_Title                            إعدادات الدلاء
Bucket_BucketName                       إسم<br>الدلو
Bucket_WordCount                        عدد الكلمات
Bucket_WordCounts                       أعداد الكلمات
Bucket_UniqueWords                      كلمات<br>مختلفة
Bucket_SubjectModification              تعديل<br>الموضوع
Bucket_ChangeColor                      لون<br>الدلو
Bucket_NotEnoughData                    المعلومات غير كافية
Bucket_ClassificationAccuracy           دقّة التصنيف
Bucket_EmailsClassified                 رسائل مصنفة
Bucket_EmailsClassifiedUpper            رسائل مصنفة
Bucket_ClassificationErrors             أخطاء تصنيف
Bucket_Accuracy                         دقّة
Bucket_ClassificationCount              عدد التصنيفات
Bucket_ClassificationFP                 خطأ إيجابي
Bucket_ClassificationFN                 خطأ سلبي
Bucket_ResetStatistics                  تصفير الإحصاءات
Bucket_LastReset                        آخر تصفير
Bucket_CurrentColor                     %s حالياً له لون %s
Bucket_SetColorTo                       غيّر لون %s إلى %s
Bucket_Maintenance                      صيانة
Bucket_CreateBucket                     إصنع دلو بإسم
Bucket_DeleteBucket                     إحذف الدلو المسمى
Bucket_RenameBucket                     إعادة تسمية الدلو المسمى
Bucket_Lookup                           إبحث
Bucket_LookupMessage                    جد كلمة في دلاء
Bucket_LookupMessage2                   نتائج البحث عن
Bucket_LookupMostLikely                 <b>%s</b> على الأرجح أن تكون في <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> غير موجودة في ايٍ من الدلاء
Bucket_DisabledGlobally                 عطل بشكل عام
Bucket_To                               إلى
Bucket_Quarantine                       عزل<br>الرسالة

SingleBucket_Title                      تفاصيل %s
SingleBucket_WordCount                  عدد كلمات الدلو
SingleBucket_TotalWordCount             إجمالي عدد الكلمات
SingleBucket_Percentage                 النسبة من الإجمالي
SingleBucket_WordTable                  جدول كلمات %s
SingleBucket_Message1                   إضغط على حرف في الفهرس لعرض الكلمات التي تبدأ بذلك الحرف. إضغط على أية كلمة لعرض إحتماليتها في كافة الدلاء.
SingleBucket_Unique                     %s مختلفة
SingleBucket_ClearBucket                إحذف كافة الكلمات

Session_Title                           إنتهت صلاحية جلسة POPFile
Session_Error                           إنتهت صلاحية جلسة POPFile. هذا يمكن أن يحصل إذا ام إقفال وإعادة تشغيل POPFile وترك المتصفح مفتوح. الرجاء الضغظ على إحدى الروابط في الأعلى للمتابعة في إستعمال POPFile.

View_Title                              عرض رسالة مفردة
View_ShowFrequencies                    عرض تردد الكلمات
View_ShowProbabilities                  عرض إحتمالية الكلمات
View_ShowScores                         عرض نتائج الكلمات
View_WordMatrix                         مصفوفة الكلمات
View_WordProbabilities                  عرض إحتمالية الكلمات
View_WordFrequencies                    عرض تردد الكلمات
View_WordScores                         عرض نتائج الكلمات
View_Chart                              رسْم القرار

Windows_TrayIcon                        عرض ايقونة POPFile في شريط المهام؟
Windows_Console                         تشغيل POPFile في نافذة نصية؟
Windows_NextTime                        <p><font color="red">هذا التعديل لن يكون فقالاً إلى أن يتم إعادة تشغيل POPFile</font>

Header_MenuSummary                      This table is the navigation menu which allows access to each of the different pages of the control center.
History_MainTableSummary                This table shows the sender and subject of recently received messages and allows them to be reviewed and reclassified.  Clicking on the subject line will show the full message text, along with information about why it was classified as it was.  The 'Should be' column allows you to specify which bucket the message belongs in, or to undo that change.  The 'Delete' column allows you to delete specific messages from the history if you don't need them anymore.
History_OpenMessageSummary              This table contains the full text of a message message, with the words that are used for classification highlighted according to the bucket that was most relevant for each.
Bucket_MainTableSummary                 This table provides an overview of the classification buckets.  Each row shows the bucket name, the word count total for that bucket, the actual number of individual words in each bucket, whether the message's subject line will be modified when it gets classified to that bucket, whether to quarantine the messages received in that bucket, and a table to pick the color used in displaying anything related to that bucket in the control center.
Bucket_StatisticsTableSummary           This table provides three sets of statistics on the overall performance of POPFile.  The first is how accurate its classification is, the second is how many messages have been classified, and to which buckets, and the third is how many words are in each bucket, and what their relative percentages are.
Bucket_MaintenanceTableSummary          This table contains forms that allow you to create, delete or rename buckets, and to lookup a word in all of the buckets to see its relative probabilities.
Bucket_AccuracyChartSummary             This table graphically represents the accuracy of the message classification.
Bucket_BarChartSummary                  This table graphically represents a percentage allocation for each of the different buckets.  It is used for both number of messages classified, and total word counts.
Bucket_LookupResultsSummary             This table shows the probabilities associated with any given word of the corpus.  For each bucket, it shows the frequency that that word occurs, the probability that it will occur in that bucket, and the overall effect on the score of the bucket if that word exists in a message.
Bucket_WordListTableSummary             This table provides a listing of all the words for a particular bucket, organized by common first letter for each row.
Magnet_MainTableSummary                 This table shows the list of magnets that are used to automatically classify message according to fixed rules.  Each row shows how the magnet is defined, what bucket it is intended for, and a button to delete the magnet.
Configuration_MainTableSummary          This table contains a number of forms to allow you to control the configuration of POPFile.
Configuration_InsertionTableSummary     This table contains buttons that determine whether or not certain modifications are made to the headers or subject line of the message before it is passed on to the message client.
Security_MainTableSummary               This table provides sets of controls that affect the security of the overall configuration of POPFile, whether it should automatically check for updates to the program, and whether statistics about POPFile's performance should be sent to the central datastore of the program's author for general information.
Advanced_MainTableSummary               This table provides a list of words that POPFile ignores when classifying message due to their relative frequency in message in general.  They are organized per row according to the first letter of the words.

Imap_Bucket2Folder                      البريد للدلو <b>%s</b> يذهب للمجلد
Imap_MapError                           لا يمكن تحويل اكثر من دلو واحد لكل مجلد!
Imap_Server                             خادم IMAP:
Imap_ServerNameError                    الرجاء إدخال اسم الحادم!
Imap_Port                               بوابة إتصال IMAP:
Imap_PortError                          الرجاء إدخال رقم بوابة صحيح!
Imap_Login                              إسم مستخدم IMAP:
Imap_LoginError                         الرجاء إدخال إسم المستخدم!
Imap_Password                           كلمة المرور لحساب IMAP:
Imap_PasswordError                      الرجاء إدخال كلمة المرور!
Imap_Expunge                            مسح الرسائل المحذوفه من المجلدات المراقبة.
Imap_Interval                           فترة التحديث بالثواني:
Imap_IntervalError                      الرجاء إدخال فترة بين 10 و 3600 ثانية.
Imap_Bytelimit                          بايت لكل رسالة من أجل التصنيف. أدخل 0 (Null) لإستعمال الرسالة كاملة:
Imap_BytelimitError                     الرجاء إدخال رقم.
Imap_RefreshFolders                     تحديث قائمة المجلدات
Imap_Now                                الآن!
Imap_UpdateError1                       لم تتم عملية الدخول. الرجاء التأكد من إسم المستخدم وكلمة المرور.
Imap_UpdateError2                       فشلت عملية الإتصال بالخادم. الرجاء التأكد من إسم الخادم ورقم بوابة الإتصال والتأكد من أن الإتصال مع الشبكة موجود.
Imap_UpdateError3                       الرجاء إعداد تفاصيل الإتصال أولاً.
Imap_NoConnectionMessage                الرجاء إعداد تفاصيل الإتصال أولاً. بعد الإنتهاء منه، سوف تظهر في هذه الصفحة المزيد من الخيارات.
Imap_WatchMore                          مجلد لعرض المجلدات المراقبة
Imap_WatchedFolder                      مجلد مراقب رقم

Shutdown_Message                        تم إقفال POPFile

Help_Training                           عند إستعمالك POPFile لأول مرة، فإنه لا يعرف أي شيء ويحتاج لبعض التدريب. يحتاج POPFile للتدريب على رسائل لكل دلو، التدريب يتم عند إعادة تصنيف رسالة قام POPFile بتصنيفها بشكل خاطئ. ستحتاج أيضاً إلى إعداد برنامج البريد ليقوم بترتيب البريد حسب تصنيفات POPFile. يمكن العثور على التعليمات لإعداد برامج البريد في <a href="http://getpopfile.org/docs/FAQ:EmailSorting">صفحات تعليمات POPFile</a>.
Help_Bucket_Setup                       يحتاج POPFile إلى دلوين على الأقل بالإضافة إلى دلو غير-المصنف. ما يجعل POPFile فريداً هو أنه يستطيع تصنيف بريد اكثر من هذا، تستطيع ان يكون عندك أي عدد من الدلاء. أبسط إعداد هو أن يكون عندك الدلاء "spam"، "personal"، "work".
Help_No_More                            لا تعرض هذا مرة أخرى
ApplyChanges                            تطبيق التغييرات
Bucket_InIgnoredWords                   <b>%s</b> موجودة في قائمة الكلمات المتجاهلة. POPFile يتجاهل هذه الكلمة
BucketSelect_AddNew                     إضافة جديد...
BucketSelect_AlreadyExists              موجود مسبقاً
BucketSelect_CreateError                خطأ في إنشاء الفئة
BucketSelect_InvalidName                يُسمح فقط بـ a-z، 0-9، - و _
BucketSelect_NameRequired               الاسم مطلوب
Configuration_Error10                   منفذ استماع POP3 لا يمكن أن يكون نفس قيمة منفذ واجهة المستخدم
Configuration_Error9                    منفذ واجهة المستخدم لا يمكن أن يكون نفس قيمة منفذ استماع POP3
Corpus_Actions                          إجراءات
Corpus_AddStopword                      إضافة إلى الكلمات المتوقفة
Corpus_BucketList                       الفئات
Corpus_Clear                            مسح
Corpus_Color                            اللون
Corpus_LoadCandidates                   البحث عن المرشحين
Corpus_NoCandidates                     لم يتم العثور على مرشحين عند هذا الحد.
Corpus_RemoveStopword                   إزالة
Corpus_Search                           بحث
Corpus_StopwordCandidates               مرشحو الكلمات المتوقفة
Corpus_StopwordCandidatesDesc           كلمات تظهر بالتساوي عبر جميع الفئات — قدرة تمييزية منخفضة.
Corpus_StopwordRatio                    نسبة الحد الأقصى/الأدنى
Corpus_StopwordsDesc                    الكلمات في هذه القائمة لا تُستخدم أبداً للتصنيف.
Corpus_StopwordsTitle                   الكلمات المتوقفة
DonateLink                              Donate
History_AllBuckets                      جميع الفئات
History_HighlightWords                  تمييز الكلمات حسب الفئة
History_Loading                         جارٍ التحميل...
History_MoveTo                          — نقل إلى —
History_Moving                          جارٍ النقل...
History_NoMatchingMessages              لا توجد رسائل مطابقة
History_Reclassifying                   جارٍ إعادة التصنيف...
History_ReclassifyUnclassified          إعادة تصنيف غير المصنفة
History_Selected                        محدد
Imap_BucketFolderMappings               تعيينات الفئة -> المجلد
Imap_Connected                          متصل
Imap_Connection                         الاتصال
Imap_ConnectionFailed                   فشل الاتصال
Imap_Description                        مراقبة مجلدات IMAP وتصنيف الرسائل الواردة تلقائياً.
Imap_EnableService                      تفعيل خدمة IMAP
Imap_FetchFolders                       جلب المجلدات
Imap_Fetching                           جارٍ الجلب...
Imap_IMAFFolder                         مجلد IMAP
Imap_MappingsHint                       يتم نقل الرسائل المصنفة إلى مجلد IMAP المحدد. اتركها فارغة لتخطي النقل.
Imap_NoFoldersWatched                   لا توجد مجلدات مراقبة حتى الآن.
Imap_NoMappings                         لا توجد تعيينات محددة.
Imap_SaveAnyway                         حفظ على أي حال
Imap_SaveConnection                     حفظ الاتصال
Imap_SaveFolders                        حفظ المجلدات
Imap_Saving                             جارٍ الحفظ...
Imap_Service                            الخدمة
Imap_TestConnection                     اختبار الاتصال
Imap_Testing                            جارٍ الاختبار...
Imap_TrainingHint                       وضع التدريب يفحص مجلدات الأرشيف الموجودة ويدرب المصنف على محتوياتها. تتم إعادة تعيين العلامة تلقائياً عند اكتمال التدريب.
Imap_TrainingMode                       وضع التدريب
Imap_Use_SSL                            استخدام SSL
Imap_WatchedFolders                     المجلدات المراقبة
Imap_WatchedHint                        يراقب POPFile مجلدات IMAP هذه بحثاً عن رسائل جديدة للتصنيف.
Magnet_Created                          تم إنشاء المغناطيس
Magnet_Deleted                          تم حذف المغناطيس
MailingListLink                         mailing_lists
NavCorpus                               المتن
NavHistory                              السجل
NavIMAP                                 IMAP
NavMagnets                              المغانط
NavSettings                             الإعدادات
NavStatus                               الحالة
Reconnect_Connecting                    جارٍ الاتصال...
Reconnect_Message                       الخادم الخلفي غير متاح. جارٍ محاولة إعادة الاتصال...
Reconnect_Now                           إعادة الاتصال الآن
Reconnect_RetryIn                       إعادة المحاولة في
Reconnect_Title                         انقطع الاتصال
RequestFeatureLink                      RequestFeature
Settings_AdminPassword                  كلمة مرور المسؤول
Settings_ArchiveDirectory               مجلد الأرشيف
Settings_ArchiveMessages                أرشفة الرسائل
Settings_ArchiveSubdirs                 المجلدات الفرعية للأرشيف
Settings_AutoDetect                     الاكتشاف التلقائي
Settings_AutoDetectLanguage             الاكتشاف التلقائي للغة
Settings_ChainPort                      منفذ السلسلة
Settings_ChainServer                    خادم السلسلة
Settings_DateFormat                     تنسيق التاريخ
Settings_DescAdminPassword              اتركها فارغة لتعطيل حماية كلمة المرور.
Settings_DescArchiveDir                 مجلد الرسائل المؤرشفة (نسبياً لمجلد المستخدم).
Settings_DescArchiveMessages            حفظ نسخة من كل رسالة مصنفة على القرص.
Settings_DescArchiveSubdirs             تقسيم الأرشيف إلى N مجلداً فرعياً (0 = معطل).
Settings_DescAutoDetectLang             اكتشاف لغة كل رسالة وتطبيق الكلمات المتوقفة والجذر المطابق. يضيف ~130% تأخيراً في التصنيف؛ مفيد لصناديق البريد متعددة اللغات.
Settings_DescChainPort                  منفذ خادم SMTP الأعلى.
Settings_DescChainServer                اسم مضيف خادم SMTP الأعلى.
Settings_DescDateFormat                 سلسلة تنسيق strftime. اتركها فارغة للإعداد الافتراضي.
Settings_DescForceFork                  تفرع عملية جديدة لكل اتصال.
Settings_DescHEADFetchesBody            استرداد المقال الكامل باستخدام أمر HEAD.
Settings_DescHTTPPort                   المنفذ الذي تستمع عليه واجهة الويب. يتطلب إعادة تشغيل.
Settings_DescItemsPerPage               الصفوف المعروضة لكل صفحة في السجل والمغانط.
Settings_DescLanguage                   لغة عرض واجهة المستخدم. اتركها فارغة للاكتشاف التلقائي من المتصفح.
Settings_DescListenAddress              عنوان IP للربط. فارغ = جميع الواجهات.
Settings_DescLocalOnly_UI               تقييد واجهة الويب على اتصالات المضيف المحلي.
Settings_DescLogDirectory               مجلد ملفات السجل. فارغ = مجلد popfile الجذر.
Settings_DescLogLevel                   مستوى تفصيل السجل.
Settings_DescLogSQLToStdout             طباعة كل جملة SQL مع القيم المرتبطة إلى stdout. نشط فقط عند تفعيل "تسجيل إلى stdout".
Settings_DescLogToStdout                نسخ مخرجات السجل إلى stdout بالإضافة إلى ملف السجل.
Settings_DescMessageCutoff              الحد الأقصى للكلمات المحللة لكل رسالة (0 = غير محدود).
Settings_DescNNTPLocalOnly              قبول اتصالات NNTP من المضيف المحلي فقط.
Settings_DescNNTPPort                   المنفذ الذي يستمع عليه POPFile لـ NNTP (الافتراضي 119).
Settings_DescNNTPSeparator              حرف يفصل المستخدم عن الخادم.
Settings_DescPOP3LocalOnly              قبول اتصالات POP3 من المضيف المحلي فقط.
Settings_DescPOP3Port                   المنفذ الذي يستمع عليه POPFile لـ POP3 (الافتراضي 1110).
Settings_DescPOP3Separator              الحرف الفاصل بين المستخدم والخادم (مثلاً user:mailhost).
Settings_DescRetentionDays              عدد الأيام للاحتفاظ بسجل الرسائل.
Settings_DescSessionDividers            عرض فواصل بين جلسات التصفح في السجل.
Settings_DescSMTPLocalOnly              قبول اتصالات SMTP من المضيف المحلي فقط.
Settings_DescSMTPPort                   المنفذ الذي يستمع عليه POPFile لـ SMTP (الافتراضي 25).
Settings_DescSQLiteJournal              وضع مجلة/WAL لـ SQLite.
Settings_DescSQLiteTweaks               قناع بت: 1 = كتابة أسرع (أقل أمان)، 2 = نسخ احتياطي دوري.
Settings_DescSSLChainPort               منفذ خادم SSL POP3 الأعلى.
Settings_DescSSLChainServer             اسم مضيف خادم SSL POP3 الأعلى لتسلسل SSL.
Settings_DescSubjectTagLeft             بادئة تُدرج في ترويسة الموضوع، مثلاً [SPAM].
Settings_DescSubjectTagRight            لاحقة تُضاف إلى ترويسة الموضوع.
Settings_DescTagPosition                موضع وضع وسم الموضوع.
Settings_DescTOPFetchesBody             استرداد نص الرسالة أيضاً باستخدام أمر TOP.
Settings_DescUnclassifiedWeight         حد الاحتمالية الذي يُعد البريد دونه "غير مصنف".
Settings_DescWordStemming               تحويل الكلمات إلى جذرها قبل التصنيف (مثلاً "running" إلى "run"). يحسن الاستدعاء للغات الغنية صرفياً بتكلفة ~10% تأخير.
Settings_DescWordTable                  ما يُعرض في جدول احتمالية الكلمات.
Settings_ErrorSaving                    خطأ في الحفظ
Settings_ForceFork                      فرض التفرع
Settings_HEADFetchesBody                HEAD يجلب النص
Settings_HTTPPort                       منفذ HTTP
Settings_ItemsPerPage                   عناصر لكل صفحة
Settings_ListenAddress                  عنوان الاستماع
Settings_ListenPort                     منفذ الاستماع
Settings_LocalOnly                      محلي فقط
Settings_LogDirectory                   مجلد السجل
Settings_LogLevel                       مستوى السجل
Settings_LogSQLToStdout                 تسجيل SQL إلى stdout
Settings_LogToStdout                    تسجيل إلى stdout
Settings_MessageCutoff                  حد الرسالة
Settings_OptDebug                       تصحيح
Settings_OptEnd                         نهاية
Settings_OptErrorsOnly                  أخطاء فقط
Settings_OptFrequencies                 التكرارات
Settings_OptFront                       أمام
Settings_OptHidden                      مخفي
Settings_OptInfo                        معلومات
Settings_OptLogScores                   تسجيل النقاط
Settings_OptProbabilities               الاحتمالات
Settings_OptWarnings                    تحذيرات
Settings_RetentionDays                  الاحتفاظ (أيام)
Settings_SaveChanges                    حفظ التغييرات
Settings_Saved                          تم الحفظ
Settings_Saving                         جارٍ الحفظ...
Settings_Search                         البحث في الإعدادات...
Settings_SectionClassifier              المصنف
Settings_SectionHistory                 السجل
Settings_SectionLogging                 التسجيل
Settings_SectionNNTP                    وكيل NNTP
Settings_SectionPOP3                    وكيل POP3
Settings_SectionSecurity                الأمان
Settings_SectionSMTP                    وكيل SMTP
Settings_SectionUI                      واجهة المستخدم
Settings_ServerSeparator                فاصل الخادم
Settings_SessionDividers                فواصل الجلسة
Settings_SQLiteJournalMode              وضع مجلة SQLite
Settings_SQLiteTweaks                   تعديلات SQLite
Settings_SSLChainPort                   منفذ سلسلة SSL
Settings_SSLChainServer                 خادم سلسلة SSL
Settings_SubjectTagLeft                 وسم الموضوع الأيسر
Settings_SubjectTagRight                وسم الموضوع الأيمن
Settings_TagPosition                    موضع الوسم
Settings_TOPFetchesBody                 TOP يجلب النص
Settings_UnclassifiedWeight             وزن غير المصنف
Settings_WordStemming                   جذر الكلمات
Settings_WordTable                      جدول الكلمات
Status_Checking                         جارٍ الفحص...
Status_Description                      فحوصات صحة خدمات POPFile.
Status_LoadError                        فشل تحميل الحالة
Status_NoChecks                         لا توجد فحوصات متاحة.
View_DownloadMessage                    تنزيل الرسالة
View_MessageBody                        نص الرسالة
View_MessageHeader                      ترويسة الرسالة
WikiLink                                index.php
