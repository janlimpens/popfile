# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            ko
LanguageCharset                         euc-kr
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          kr

# Common words that are used on their own all over the interface
Apply                                   적용
On                                      사용 중
Off                                     사용 않음
TurnOn                                  사     용
TurnOff                                 사용 안함
Add                                     추가
Remove                                  제거
Previous                                이전
Next                                    다음
From                                    발신자
Subject                                 제목 
Cc                                      참조
Classification                          분류
Reclassify                              재분류
Probability                             확률
Scores                                  점수
QuickMagnets                            빠른 자석
Undo                                    취소
Close                                   닫기
Find                                    찾기
Filter                                  걸러냄
Yes                                     예
No                                      아니오
ChangeToYes                             '예'로 바꿈
ChangeToNo                              '아니오'로 바꿈
Bucket                                  버킷
Magnet                                  자석
Delete                                  삭제
Create                                  생성
To                                      수신자
Total                                   전체
Rename                                  이름바꾸기
Frequency                               빈도
Probability                             확률
Score                                   점수
Lookup                                  검색
Word                                    단어
Count                                   수
Update                                  수정
Refresh                                 경신

# The header and footer that appear on every UI page
Header_Title                            팝파일 제어 센터
Header_Shutdown                         팝파일 종료
Header_History                          히스토리
Header_Buckets                          버킷
Header_Configuration                    설정
Header_Advanced                         고급
Header_Security                         보안
Header_Magnets                          자석

Footer_HomePage                         팝파일 홈페이지
Footer_Manual                           설명서
Footer_Forums                           게시판
Footer_FeedMe                           기부
Footer_RequestFeature                   기능요청
Footer_MailingList                      메일링 리스트

Configuration_Error1                    구분글자는 반드시 1글자여야 합니다.
Configuration_Error2                    사용자 인터페이스의 포트는 반드시 1부터 65535 사이의 숫자여야 합니다.
Configuration_Error3                    POP3 포트는 반드시 1부터 65535 사이의 숫자여야 합니다.
Configuration_Error4                    페이지 크기는 반드시 1부터 1000 사이의 숫자여야 합니다.
Configuration_Error5                    히스토리의 보존 기간은 반드시 1부터 366 사이의 숫자여야 합니다. 
Configuration_Error6                    TCP 타임아웃은 반드시 10부터 1800 사이의 숫자여야 합니다. The TCP timeout must be a number between 10 and 1800
Configuration_Error7                    XML RPC 리슨 포트는 반드시 1부터 65535 사이의 숫자여야 합니다.
Configuration_POP3Port                  POP3 포트
Configuration_POP3Update                %s로 포트를 변경했습니다. 이것은 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_XMLRPCUpdate              XML-RPC 포트를 %s 로 경신하였습니다. 이것은 팝파일을 재기동하여야 적용됩니다.
Configuration_XMLRPCPort                XML-RPC 리슨 포트
Configuration_SMTPPort                  SMTP 리슨 포트
Configuration_SMTPUpdate                SMTP 포트를 %s로 경신하였습니다. 이것은 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_NNTPPort                  NNTP 리슨 포트
Configuration_NNTPUpdate                NNTP 리슨 포트를 %s로 경신하였습니다. 이것은 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_POPFork                   POP3 동시 연결 허용
Configuration_SMTPFork                  SMTP 동시 연결 허용
Configuration_NNTPFork                  NNTP 동시 연결 허용
Configuration_POP3Separator             POP3 host:port:user 구분글자
Configuration_NNTPSeparator             NNTP host:port:user 구분글자
Configuration_POP3SepUpdate             POP3 구분글자를 %s로 경신하였습니다.
Configuration_NNTPSepUpdate             NNTP 구분글자를 %s로 경신하였습니다.
Configuration_UI                        사용자 인터페이스 웹 포트
Configuration_UIUpdate                  사용자 인터페이스 웹 포트를 %s로 변경했습니다. 팝파일을 재시작하기 전까지는 적용되지 않습니다.
Configuration_History                   페이지당 이메일 갯수
Configuration_HistoryUpdate             페이지당 이메일 갯수를 %s로 변경했습니다.
Configuration_Days                      히스토리에 남겨둘 기간(일)
Configuration_DaysUpdate                히스토리에 남겨둘 기간(일)을 %s로 변경했습니다.
Configuration_UserInterface             사용자 인터페이스
Configuration_Skins                     스킨
Configuration_SkinsChoose               스킨 선택
Configuration_Language                  언어
Configuration_LanguageChoose            언어 선택
Configuration_ListenPorts               리슨 포트
Configuration_HistoryView               히스토리 보기
Configuration_TCPTimeout                TCP 컨넥션 타임아웃
Configuration_TCPTimeoutSecs            TCP 컨넥션 타임아웃(초)
Configuration_TCPTimeoutUpdate          TCP 컨넥션 타임아웃을 %s로 변경하였습니다.
Configuration_ClassificationInsertion   이메일 문자열 삽입
Configuration_SubjectLine               제목 바꿈
Configuration_XTCInsertion              X-Text-Classification 헤더
Configuration_XPLInsertion              X-POPFile-Link 헤더
Configuration_Logging                   로깅
Configuration_None                      없음
Configuration_ToScreen                  화면으로
Configuration_ToFile                    파일로
Configuration_ToScreenFile              화면과 파일로
Configuration_LoggerOutput              로그 출력
Configuration_GeneralSkins              스킨
Configuration_SmallSkins                작은 스킨
Configuration_TinySkins                 아주 작은 스킨
Configuration_CurrentLogFile            &lt;현재 로그 파일&gt;

Advanced_Error1                         '%s' 는 이미 무시되는 단어로 등록된 듯
Advanced_Error2                         무시되는 단어는 알파벳, 숫자,., _, -, 또는 @ 만을 쓸 수 있습니다.
Advanced_Error3                         '%s' 가 무시되는 단어 목록에 추가되었습니다.
Advanced_Error4                         '%s' 는 무시되는 단어 목록에 없습니다.
Advanced_Error5                         '%s' 가 무시되는 단어 목록에서 제거되었습니다
Advanced_StopWords                      무시되는 단어들
Advanced_Message1                       팝파일은 다음의 자주 사용되는 단어를 무시합니다:
Advanced_AddWord                        단어 추가
Advanced_RemoveWord                     단어 제거
Advanced_AllParameters                  모든 팝파일 파라미터
Advanced_Parameter                      파라미터
Advanced_Value                          값
Advanced_Warning                        이것은 팝파일의 모든 파라미터입니다. 고급사용자용입니다. 어느 항목이든 변경할 수 있으며 변경 후에 경신 버튼을 누르십시오. 제대로 변경했는가에 대한 검사는 제공되지 않습니다.

History_Filter                          &nbsp;(다음 버킷만을 보임:<font color="%s">%s</font>)
History_FilterBy                        걸러낼 기준
History_Search                          &nbsp;(발신/제목으로 검색: %s)
History_Title                           최근 메일
History_Jump                            메일로 가기
History_ShowAll                         모두 보임
History_ShouldBe                        맞는 분류
History_NoFrom                          발신자 없음
History_NoSubject                       제목 없음
History_ClassifyAs                      다음으로 분류함:
History_MagnetUsed                      사용된 자석
History_MagnetBecause                   <b>자석 사용됨</b><p><font color="%s">%s</font>(으)로 분류됨. 자석 %s 때문임. </p>
History_ChangedTo                       다음으로 변경됨:<font color="%s">%s
History_Already                         현재 분류:<font color="%s">%s</font>
History_RemoveAll                       모두 제거
History_RemovePage                      현재 보이는 목록만 제거
History_Remove                          히스토리로부터 제거하기 위해서는 클릭하십시오
History_SearchMessage                   발신/제목으로부터 검색
History_NoMessages                      메일 없음
History_ShowMagnet                      자석으로 분류됨
History_ShowNoMagnet                    자석으로 분류되지 않음
History_Magnet                          &nbsp;(자석으로 분류된 것만 보임)
History_NoMagnet                        &nbsp;(자석으로 분류되지 않은 것만 보임)
History_ResetSearch                     초기화

Password_Title                          비밀번호
Password_Enter                          비밀번호 입력
Password_Go                             시작
Password_Error1                         잘못된 비밀번호

Security_Error1                         보안포트는 반드시 1부터 65535사이의 숫자여야 합니다.
Security_Stealth                        스텔스 모드 / 서버 동작
Security_NoStealthMode                  아니오 (스텔스 모드)
Security_ExplainStats                   (이것이 켜지면 팝파일은 하루에 한번씩 다음의 세가지 값을 getpopfile.org에 보냅니다 - bc (만드신 버킷 수), mc (팝파일이 분류한 메시지 수) and ec (분류 오류 건수).  이것들은 파일로 저장되며 팝파일이 어떻게 사용되며 얼마나 잘 작동하는지에 관한 통계를 공표할때 사용됩니다. 제 웹서버는 5일간 로그파일을 보존하고 그 후 삭제합니다. 개개의 IP주소와 통계 간에 어떠한 연관관계도 저장되지 않습니다.)
Security_ExplainUpdate                  (이것이 켜지면 팝파일은 하루에 한번씩 다음의 세가지 값을 getpopfile.org에 보냅니다 - ma (설치하신 팝파일의 메이저 버전 번호), mi (설치하신 팝파일의 마이너 버전 번호), bn (설치하신 팝파일의 빌드 번호). 팝파일은 새 버전이 있으면 페이지 맨 위쪽에 그래픽 형태로 그 결과를 표시합니다. 제 웹서버는 5일간 로그파일을 보존하고 그 후 삭제합니다. 개개의 IP주소와 업데이트 체크 간에 어떠한 연관관계도 저장되지 않습니다.)
Security_PasswordTitle                  사용자 인터페이스 비밀번호
Security_Password                       비밀번호
Security_PasswordUpdate                 비밀번호를 %s로 변경했습니다.
Security_AUTHTitle                      보안 패스워드 인증
Security_SecureServer                   보안 서버
Security_SecureServerUpdate             보안 서버를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_SecurePort                     보안 포트
Security_SecurePortUpdate               포트를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_SMTPServer                     SMTP 체인 서버
Security_SMTPServerUpdate               SMTP 체인 서버를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_SMTPPort                       SMTP 체인 포트
Security_SMTPPortUpdate                 SMTP 체인 포트를 %s로 변경했습니다. 팝파일을 다시 시작할때 적용됩니다.
Security_POP3                           원격 기계로부터의 POP3 연결을 허용(팝파일 재시작 필요)
Security_SMTP                           원격 기계로부터의 SMTP 연결을 허용(팝파일 재시작 필요)
Security_NNTP                           원격 기계로부터의 NNTP 연결을 허용(팝파일 재시작 필요)
Security_UI                             원격 기계로부터의 HTTP (유저 인터페이스 화면) 연결을 허용(팝파일 재시작 필요)
Security_XMLRPC                         원격 기계로부터의 XML-RPC 연결을 허용(팝파일 재시작 필요)
Security_UpdateTitle                    자동 업데이트 체크
Security_Update                         팝파일 최신 버전을 매일 체크함
Security_StatsTitle                     통계 보고
Security_Stats                          매일 통계를 보냄

Magnet_Error1                           자석 '%s' 는 이미 버킷 '%s'에 존재합니다.
Magnet_Error2                           새 자석 '%s' 는 '%s' 자석과 충돌함(버킷:'%s'). 따라서 혼동의 우려가 있으므로 새 자석은 추가되지 않았습니다.
Magnet_Error3                           새 자석인 '%s' 을 버킷 '%s' 에 생성
Magnet_CurrentMagnets                   현재 자석
Magnet_Message1                         다음 자석은 지정된 버킷으로 메일이 항상 분류되도록 합니다.
Magnet_CreateNew                        새 자석 생성
Magnet_Explanation                      세 종류의 자석이 가능합니다: <ul><li><b>발신주소 또는 이름:</b> 예: john@company.com (특정 이메일 주소로), <br />company.com (company.com에서 보내는 모든 메일), <br />John Doe:Jonh Doe만 일치, John:첫단어가 John이면 모두 일치</li><li><b>수신자 메일주소 또는 이름:</b> 발신주소용 자석과 동일하나 수신자에 작용함</li> <li><b>제목의 단어:</b> 예)안녕하세요 는 제목란의 모든 안녕하세요 와 일치</li></ul>
Magnet_MagnetType                       자석 종류
Magnet_Value                            값
Magnet_Always                           항상 다음 버킷으로
Magnet_Jump                             자석 페이지로

Bucket_Error1                           영어 소문자와 - 와 _만을 사용하실 수 있습니다.
Bucket_Error2                           %s(이)라는 이름의 버킷은 이미 있습니다.
Bucket_Error3                           %s(이)라는 이름으로 버킷을 생성
Bucket_Error4                           공백이 아닌 단어를 입력하십시오.
Bucket_Error5                           %s 버킷을 %s 로 변경하였습니다.
Bucket_Error6                           삭제된 버킷 %s
Bucket_Title                            요약
Bucket_BucketName                       버킷 이름
Bucket_WordCount                        단어 수
Bucket_WordCounts                       단어 수
Bucket_UniqueWords                      유일한 단어
Bucket_SubjectModification              제목 변경
Bucket_ChangeColor                      색상 변경
Bucket_NotEnoughData                    데이터가 충분치 않음
Bucket_ClassificationAccuracy           분류 정확도
Bucket_EmailsClassified                 분류된 이메일
Bucket_EmailsClassifiedUpper            분류된 이메일
Bucket_ClassificationErrors             분류 오류
Bucket_Accuracy                         정확도
Bucket_ClassificationCount              분류 수
Bucket_ClassificationFP                 잘못 포함시킴
Bucket_ClassificationFN                 잘못 제외시킴
Bucket_ResetStatistics                  통계 초기화
Bucket_LastReset                        마지막 초기화
Bucket_CurrentColor                     %s의 현재 색상은 %s입니다.
Bucket_SetColorTo                       %s의 색상을 %s으로 설정
Bucket_Maintenance                      유지 보수
Bucket_CreateBucket                     다음 이름의 버킷 생성
Bucket_DeleteBucket                     다음 이름의 버킷 삭제
Bucket_RenameBucket                     다음 이름의 버킷 이름 변경
Bucket_Lookup                           검색
Bucket_LookupMessage                    버킷에서 다음 단어를 검색
Bucket_LookupMessage2                   다음 단어에 대한 검색 결과
Bucket_LookupMostLikely                 <b>%s</b> 는 <font color="%s">%s</font>에 나타날 확률이 가장 높습니다.
Bucket_DoesNotAppear                    <p><b>%s</b> 는 어느 버킷에도 나타나지 않습니다.
Bucket_DisabledGlobally                 적용안함
Bucket_To                               =>
Bucket_Quarantine                       격리

SingleBucket_Title                      %s의 상세내용
SingleBucket_WordCount                  버킷 단어 수
SingleBucket_TotalWordCount             전체 단어 수
SingleBucket_Percentage                 전체의 비율
SingleBucket_WordTable                  %s의 단어 표
SingleBucket_Message1                   별표 붙은(*) 단어들은 이번 팝파일 세션에서 분류에 사용되었습니다. 단어를 클릭하시면 버킷에 포함될 확률을 화면 아래 오른쪽에서 보실 수 있습니다.
SingleBucket_Unique                     %s : 유일
SingleBucket_ClearBucket                모든 단어 제거

Session_Title                           팝파일 세션이 만료되었습니다.
Session_Error                           팝파일 세션이 만료되었습니다. 팝파일을 종료 후 재시작 했기 때문일 것이며, 위의 링크 중 하나를 누르시면 계속하실 수 있습니다. 

View_Title                              메일 자세히 보기
View_ShowFrequencies                    단어 빈도 보기
View_ShowProbabilities                  단어 확률 보기
View_ShowScores                         단어 점수 보기
View_WordMatrix                         단어 표
View_WordProbabilities                  단어 확률 표시 중
View_WordFrequencies                    단어 빈도 표시 중
View_WordScores                         단어 점수 표시 중

Windows_TrayIcon                        팝파일 아이콘을 윈도우즈 시스템 트레이에 표시하시겠습니까?
Windows_Console                         팝파일 메시지를 콘솔창에 표시하시겠습니까?
Windows_NextTime                        <p><font color="red">이 변경은 다음번 팝파일 실행시부터 적용됩니다.</font>

Header_MenuSummary                      이것은 제어센터의 각기 다른 페이지를 접근할 수 있는 메뉴입니다.
History_MainTableSummary                이것은 최근 수신된 메일의 발신인과 제목을 보여주며 재검토하고 재분류할 수 있도록 해주는 메뉴입니다. 제목 라인을 클릭하시면 메일 내용을 보실 수 있으며 아울러, 분류가 된 이유를 보실 수 있습니다. 맞는 분류 칸에서는 메일이 어느 버킷에 속하는지 지정하시거나 분류를 취소하실 수 있습니다. '삭제' 칸에서는 특정 메시지를 히스토리로부터 지울 수 있습니다.
History_OpenMessageSummary              이것은 이메일의 본문을 담고 있으며, 분류에 사용된 단어가 가장 관련높은 버킷에 따라 하이라이트되어 있습니다.
Bucket_MainTableSummary                 이것은 분류 버킷에 대한 개관을 제공합니다. 각 행은 버킷명, 버킷의 총 단어 수, 각 버킷에 속한 개별 단어 수, 메일이 분류 되었을때 제목이 변경 되었는지 여부, 메일을 그 버킷으로 격리 시킬 것인지 여부, 그리고 버킷과 관련된 사항을 표시할 색깔을 고를 수 있는 표로 구성되어 있습니다.
Bucket_StatisticsTableSummary           이것은 팝파일의 전반적인 성능에 관한 세 종류의 통계를 제공합니다. 1. 분류가 얼마나 정확한가, 2. 얼마나 많은 메일이, 어느 버킷에 분류되었는가, 3. 얼마나 많은 단어가 각 버킷에 속하며, 그들의 상대적인 퍼센트 비율이 어떻게 되는가.
Bucket_MaintenanceTableSummary          이것은 버킷의 생성/삭제/변경 할수 있는 페이지를 제공하며 상대적인 확률보기 위해 모든 버킷에 담긴 단어를 검색하는 메뉴입니다.
Bucket_AccuracyChartSummary             이것은 이메일 분류의 정확도를 그래픽으로 표시합니다.
Bucket_BarChartSummary                  이것은 각각의 버킷에 대한 할당 비율(퍼센트)를 그래픽으로 표시합니다. 이것은 분류된 메일의 수와 총 단어 수에 모두 사용됩니다.
Bucket_LookupResultsSummary             이것은 코퍼스(단어집)의 단어가 가지는 확률을 보여줍니다. 각각의 버킷에 대해, 단어 출현 빈도와 그 버킷에 포함될 확률, 그리고 그 단어가 메일에 존재할 경우 버킷 점수에 미치는 전반적인 영향을 보여줍니다.
Bucket_WordListTableSummary             이것은 특정 버킷에 대한 모든 단어를 각 행의 첫 단어로 정렬하여 나열합니다.
Magnet_MainTableSummary                 이것은 고정된 단어에 따라 자동적으로 메일을 분류하기 위한 자석들을 보여줍니다. 각 줄은 어떻게 자석이 정의되어 있는지, 어느 버킷에 넣을 것인지, 그리고 자석을 지울 버튼을 보여줍니다.
Configuration_MainTableSummary          이것은 팝파일의 설정을 조절하기 위한 여러 폼으로 구성됩니다. 
Configuration_InsertionTableSummary     이것은 이메일 프로그램(아웃룩 등등)에 메일을 넘겨주기 전에 헤더나 제목란을 변경할 것인지 설정할 버튼을 보여줍니다.
Security_MainTableSummary               이것은 팝파일의 전체 구성의 보안에 영향을 주는 제어 항목을 제공합니다. 즉, 자동적으로 업데이트를 체크할 것인가, 개발에 참고하기 위해 팝파일의 성능에 대한 통계를 프로그램 제작자의 웹사이트로 전송할 것인가를 정할 수 있습니다.
Advanced_MainTableSummary               이것은 팝파일이 메일을 분류할때 무시하는 단어(너무 흔한 단어) 목록을 제공합니다. 단어들은 첫 글자에 의해 정렬되어 있습니다.



# New UI keys added — batch 5
WikiLink	index.php
FAQLink	FAQ
RequestFeatureLink	RequestFeature
MailingListLink	mailing_lists
DonateLink	Donate
ApplyChanges	변경 사항 적용
FAQ	자주 묻는 질문
ID	ID
Date	날짜
Arrived	수신
Size	크기
Footer_Wiki	문서
Locale_Thousands	,
Locale_Decimal	.
Locale_Date	%a %R | %D %R
Advanced_ConfigFile	설정 파일
Bucket_InIgnoredWords	무시된 단어
BucketSelect_AddNew	새 카테고리
BucketSelect_AlreadyExists	같은 이름의 카테고리가 이미 존재합니다.
BucketSelect_CreateError	카테고리 생성에 실패했습니다.
BucketSelect_InvalidName	유효하지 않은 카테고리 이름입니다.
BucketSelect_NameRequired	카테고리 이름을 입력하세요.
Configuration_Error8	SOCKS V 프록시 포트는 1에서 65535 사이의 숫자여야 합니다
Configuration_Error9	사용자 인터페이스 포트는 POP3 포트와 같을 수 없습니다
Configuration_Error10	POP3 포트는 사용자 인터페이스 포트와 같을 수 없습니다
Configuration_Fields	필드
Configuration_SOCKSPort	SOCKS 프록시 포트
Configuration_SOCKSPortUpdate	SOCKS 포트 업데이트
Configuration_SOCKSServer	SOCKS 서버
Configuration_SOCKSServerUpdate	SOCKS 서버 업데이트
Corpus_Actions	작업
Corpus_AddStopword	불용어 추가
Corpus_BucketList	카테고리 목록
Corpus_Clear	지우기
Corpus_Color	색상
Corpus_LoadCandidates	후보 불러오기
Corpus_NoCandidates	후보가 없습니다.
Corpus_RemoveStopword	불용어 제거
Corpus_Search	검색
Corpus_StopwordCandidates	불용어 후보
Corpus_StopwordCandidatesDesc	분류에 영향을 줄 수 있는 고빈도 단어입니다.
Corpus_StopwordRatio	빈도 임계값
Corpus_StopwordsDesc	POPFile이 분류 시 무시하는 단어입니다.
Corpus_StopwordsTitle	불용어
Corpus_WordsLink	단어 →
Help_Bucket_Setup	카테고리 설정
Help_No_More	다시 표시 안 함
Help_Training	학습
History_AllBuckets	모든 카테고리
History_Automatic	자동
History_ChangedClass	분류 변경됨
History_Column_Characters	문자
History_Decrease	줄이기
History_HighlightWords	단어 강조
History_Increase	늘리기
History_Loading	불러오는 중...
History_MoveTo	이동할 곳
History_Moving	이동 중...
History_Negate_Search	검색 반전
History_NoMatchingMessages	일치하는 메시지가 없습니다.
History_Purge	지우기
History_Reclassified	재분류됨
History_Reclassifying	재분류 중...
History_ReclassifyUnclassified	미분류 항목 재분류
History_RemoveChecked	선택 항목 제거
History_Selected	선택됨
History_Size_Bytes	B
History_Size_KiloBytes	KB
History_Size_MegaBytes	MB
Imap_Bucket2Folder	카테고리 → 폴더
Imap_BucketFolderMappings	카테고리-폴더 매핑
Imap_Bytelimit	바이트 제한
Imap_BytelimitError	바이트 제한은 0보다 큰 숫자여야 합니다.
Imap_Connected	연결됨
Imap_Connection	연결
Imap_ConnectionFailed	연결에 실패했습니다.
Imap_Description	POPFile은 IMAP을 통해 직접 메일을 분류할 수 있습니다.
Imap_EnableService	IMAP 활성화
Imap_Expunge	표시된 메시지 삭제
Imap_FetchFolders	폴더 가져오기
Imap_Fetching	가져오는 중...
Imap_IMAFFolder	IMAP 폴더
Imap_Interval	간격 (초)
Imap_IntervalError	간격은 0보다 큰 숫자여야 합니다.
Imap_Login	로그인
Imap_LoginError	로그인 이름을 입력하세요.
Imap_MapError	매핑 저장 오류.
Imap_MappingsHint	각 카테고리에 IMAP 폴더를 지정하세요.
Imap_NoConnectionMessage	먼저 연결 설정을 저장하세요.
Imap_NoFoldersWatched	감시 중인 폴더가 없습니다.
Imap_NoMappings	매핑이 설정되지 않았습니다.
Imap_Now	지금
Imap_Password	비밀번호
Imap_PasswordError	비밀번호를 입력하세요.
Imap_Port	포트
Imap_PortError	포트는 1에서 65535 사이의 숫자여야 합니다.
Imap_RefreshFolders	폴더 새로 고침
Imap_SaveAnyway	그대로 저장
Imap_SaveConnection	연결 저장
Imap_SaveFolders	폴더 저장
Imap_Saving	저장 중...
Imap_Server	서버
Imap_ServerNameError	서버 이름을 입력하세요.
Imap_Service	IMAP 서비스
Imap_TestConnection	연결 테스트
Imap_Testing	테스트 중...
Imap_TrainingHint	학습하려면 메시지를 적절한 폴더로 이동하세요.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode	학습 모드
Imap_TrainingLimit	폴더당 메시지 수 (0 = 무제한)
Imap_UpdateError1	업데이트 오류: 알 수 없는 카테고리.
Imap_UpdateError2	업데이트 오류: 알 수 없는 폴더.
Imap_UpdateError3	업데이트 오류: 변경 사항 저장 실패.
Imap_Use_SSL	SSL 사용
Imap_WatchedFolder	감시 폴더
Imap_WatchedFolders	감시 폴더 목록
Imap_WatchedHint	감시할 폴더를 추가하세요.
Imap_WatchMore	폴더 더 감시

WordView_Title	단어 정확도
WordView_SelectBucket	카테고리 선택
WordView_Words	단어
WordView_Loading	불러오는 중...
WordView_Empty	이 카테고리에 단어가 없습니다.
WordView_ColWord	단어
WordView_ColCount	개수
WordView_ColTotal	합계
WordView_ColAccuracy	정확도
WordView_ColActions	작업
WordView_Remove	삭제
WordView_MoveTo	이동할 곳
WordView_Move	이동
Magnet_Created	자석이 생성되었습니다.
Magnet_Deleted	자석이 삭제되었습니다.
NavCorpus	코퍼스
NavHistory	기록
NavIMAP	IMAP
NavMagnets	자석
NavSettings	설정
NavStatus	상태
NavWordView	단어
Reconnect_Connecting	연결 중...
Reconnect_Message	POPFile이 연결을 잃었습니다. 재연결 중입니다.
Reconnect_Now	지금 연결
Reconnect_RetryIn	재시도까지
Reconnect_Title	연결 끊김
Security_StealthMode	스텔스 모드
Settings_AdminPassword	관리자 비밀번호
Settings_ArchiveDirectory	보관 디렉터리
Settings_ArchiveMessages	메시지 보관
Settings_ArchiveSubdirs	보관 하위 디렉터리
Settings_AutoDetect	자동 감지
Settings_AutoDetectLanguage	언어 자동 감지
Settings_ChainPort	체인 포트
Settings_ChainServer	체인 서버
Settings_DateFormat	날짜 형식
Settings_DescAdminPassword	관리 인터페이스 로그인 비밀번호.
Settings_DescArchiveDir	보관 메시지 디렉터리. 비어 있으면 보관하지 않습니다.
Settings_DescArchiveMessages	분류된 메시지의 복사본을 저장합니다.
Settings_DescArchiveSubdirs	카테고리별 하위 디렉터리에 보관을 분배합니다.
Settings_DescAutoDetectLang	인터페이스 언어를 자동으로 감지합니다.
Settings_DescChainPort	체인용 업스트림 POP3 서버 포트.
Settings_DescChainServer	업스트림 POP3 서버 호스트명.
Settings_DescDateFormat	날짜 표시 형식.
Settings_DescForceFork	프로세스 포크 사용을 강제합니다.
Settings_DescHEADFetchesBody	HEAD 명령으로 메시지 본문을 가져옵니다.
Settings_DescHTTPPort	POPFile 웹 인터페이스 포트.
Settings_DescItemsPerPage	기록 페이지당 항목 수.
Settings_DescLanguage	인터페이스 언어.
Settings_DescListenAddress	POPFile이 연결을 수신하는 주소.
Settings_DescLocalOnly_UI	웹 인터페이스를 로컬 연결로만 제한합니다.
Settings_DescLogDirectory	로그 파일 디렉터리. 비어 있으면 POPFile 루트.
Settings_DescLogLevel	로그 출력 상세 수준.
Settings_DescLogSQLToStdout	각 SQL 문을 바인드 값과 함께 stdout에 출력합니다.
Settings_DescLogToStdout	로그 출력을 파일 외에 stdout에도 복제합니다.
Settings_DescMessageCutoff	메시지당 최대 분석 단어 수 (0=무제한).
Settings_DescNNTPLocalOnly	로컬 호스트에서만 NNTP 연결을 수락합니다.
Settings_DescNNTPPort	POPFile이 NNTP를 수신하는 포트 (기본값 119).
Settings_DescNNTPSeparator	사용자와 서버를 구분하는 문자.
Settings_DescPOP3LocalOnly	로컬 호스트에서만 POP3 연결을 수락합니다.
Settings_DescPOP3Port	POPFile이 POP3를 수신하는 포트 (기본값 1110).
Settings_DescPOP3Separator	사용자와 서버를 구분하는 문자 (예: 사용자:메일서버).
Settings_DescRetentionDays	메시지 기록 보관 일수.
Settings_DescSessionDividers	기록에서 세션 간 구분선을 표시합니다.
Settings_DescSMTPLocalOnly	로컬 호스트에서만 SMTP 연결을 수락합니다.
Settings_DescSMTPPort	POPFile이 SMTP를 수신하는 포트 (기본값 25).
Settings_DescSQLiteJournal	SQLite 저널 / WAL 모드.
Settings_DescSQLiteTweaks	비트 마스크: 1=빠른 쓰기(덜 안전), 2=주기적 백업.
Settings_DescSSLChainPort	업스트림 SSL POP3 서버 포트.
Settings_DescSSLChainServer	SSL 체인용 업스트림 SSL POP3 서버 호스트명.
Settings_DescSubjectTagLeft	제목 헤더에 삽입하는 접두사 (예: [스팸]).
Settings_DescSubjectTagRight	제목 헤더에 추가하는 접미사.
Settings_DescTagPosition	제목 태그 위치.
Settings_DescTOPFetchesBody	TOP 명령으로 메시지 본문을 가져옵니다.
Settings_DescUnclassifiedWeight	이 확률 이하의 메일을 "미분류"로 처리하는 임계값.
Settings_DescWordStemming	분류 전 단어를 어근으로 축약합니다. 형태론적으로 풍부한 언어의 재현율을 향상시킵니다.
Settings_DescWordTable	단어 확률 표에 표시할 내용.
Settings_ErrorSaving	저장 오류
Settings_ForceFork	포크 강제
Settings_HEADFetchesBody	HEAD로 본문 가져오기
Settings_HTTPPort	HTTP 포트
Settings_ItemsPerPage	페이지당 항목 수
Settings_ListenAddress	수신 주소
Settings_ListenPort	수신 포트
Settings_LocalOnly	로컬만
Settings_LogDirectory	로그 디렉터리
Settings_LogLevel	로그 수준
Settings_LogSQLToStdout	SQL을 stdout에 기록
Settings_LogToStdout	stdout에 기록
Settings_MessageCutoff	메시지 제한
Settings_OptDebug	디버그
Settings_OptEnd	끝
Settings_OptErrorsOnly	오류만
Settings_OptFrequencies	빈도
Settings_OptFront	앞
Settings_OptHidden	숨김
Settings_OptInfo	정보
Settings_OptLogScores	점수 기록
Settings_OptProbabilities	확률
Settings_OptWarnings	경고
Settings_RetentionDays	보관 기간 (일)
Settings_SaveChanges	변경 사항 저장
Settings_Saved	저장됨
Settings_Saving	저장 중...
Settings_Search	설정 검색...
Settings_SectionClassifier	분류기
Settings_SectionHistory	기록
Settings_SectionLogging	로깅
Settings_SectionNNTP	NNTP 프록시
Settings_SectionPOP3	POP3 프록시
Settings_SectionSecurity	보안
Settings_SectionSMTP	SMTP 프록시
Settings_SectionUI	인터페이스
Settings_ServerSeparator	서버 구분자
Settings_SessionDividers	세션 구분선
Settings_SQLiteJournalMode	SQLite 저널 모드
Settings_SQLiteTweaks	SQLite 조정
Settings_SSLChainPort	SSL 체인 포트
Settings_SSLChainServer	SSL 체인 서버
Settings_SubjectTagLeft	제목 태그 (왼쪽)
Settings_SubjectTagRight	제목 태그 (오른쪽)
Settings_TagPosition	태그 위치
Settings_TOPFetchesBody	TOP으로 본문 가져오기
Settings_UnclassifiedWeight	미분류 가중치
Settings_WordStemming	단어 어근화
Settings_WordTable	단어 표
Shutdown_Message	POPFile이 종료 중입니다. 안녕히 계세요.
Status_Checking	확인 중...
Status_Description	POPFile 상태 및 통계.
Status_LoadError	상태 데이터 로드 오류.
Status_NoChecks	확인 항목 없음.
View_Chart	차트
View_DownloadMessage	메시지 다운로드
View_MessageBody	메시지 본문
View_MessageHeader	메시지 헤더

Language_Name                           한국어
