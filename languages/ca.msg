# Copyright (c) 2001-2011 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          en

# Common words that are used on their own all over the interface
Apply                                   Aplicar
Add                                     Afegir
Remove                                  Suprimir
Previous                                Anterior
Next                                    Següent
From                                    Des de
Subject                                 Assumpte
Reclassify                              Reclassificar
Undo                                    Desfer
Close                                   Tancar
Bucket                                  Cistella
Magnet                                  Imant
Delete                                  Esborrar
Create                                  Crear
Total                                   Total
Rename                                  Redenominar
Update                                  Actualitzar
Refresh                                 Recarregar
Date                                    Data

# The header and footer that appear on every UI page

Configuration_Language                  Idioma

History_SearchMessage                   Cercar Des de/Assumpte

Magnet_CurrentMagnets                   Imants actuals
Magnet_CreateNew                        Crear imant nou

Bucket_CreateBucket                     Crear una cistella de nom
Bucket_RenameBucket                     Redenominar la cistella anomenada

Imap_Server                             Nom del servidor IMAP:
Imap_Port                               Port del servidor IMAP:
Imap_Login                              Nom del compte IMAP:
Imap_Password                           Contrasenya del compte IMAP:
Imap_Expunge                            Destruir de les carpetes mirades els missatges esborrats.
Imap_Interval                           Interval d'actualització, en segons:
Imap_NoConnectionMessage                Configureu abans els detalls de la connexió. Després que hi hagueu fet, hi haurà més opcions disponibles.

# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Corpus
NavHistory Historial
NavIMAP IMAP
NavMagnets Imants
NavStatus Estat
NavWordView Paraules
Corpus_BucketList Categories
Corpus_Color Color
Corpus_Actions Accions
Corpus_Clear Buida
Corpus_StopwordsTitle Paraules buides
Corpus_StopwordsDesc Les paraules d'aquesta llista no s'utilitzen mai per a la classificació.
Corpus_RemoveStopword Elimina
Corpus_StopwordCandidates Candidates a paraules buides
Corpus_StopwordCandidatesDesc Paraules que apareixen uniformement a totes les categories — poc poder discriminatiu.
Corpus_StopwordRatio Llindar màx/mín del ràtio
Corpus_LoadCandidates Cerca candidates
Corpus_NoCandidates No s'han trobat candidates amb aquest llindar.
Corpus_AddStopword Afegeix a paraules buides
BucketSelect_AddNew Afegeix nova...
BucketSelect_AlreadyExists Ja existeix
BucketSelect_CreateError Error en crear la categoria
BucketSelect_InvalidName Només a-z, 0-9, - i _
BucketSelect_NameRequired Nom obligatori
History_AllBuckets Totes les categories
History_HighlightWords Ressalta paraules per categoria
History_Loading Carregant...
History_MoveTo — mou a —
History_Moving Movent...
History_Reclassifying Reclassificant...
History_ReclassifyUnclassified Reclassifica no classificats
History_Selected seleccionat(s)
Imap_BucketFolderMappings Categoria -> Assignacions de carpetes
Imap_Connected Connectat
Imap_Connection Connexió
Imap_ConnectionFailed Error de connexió
Imap_Description Supervisa les carpetes IMAP i classifica automàticament els missatges entrants.
Imap_FetchFolders Obtén carpetes
Imap_Fetching Obtenint...
Imap_IMAFFolder Carpeta IMAP
Imap_MappingsHint Els missatges classificats es mouen a la carpeta IMAP especificada. Deixeu buides les categories no assignades per ometre el moviment.
Imap_NoFoldersWatched Encara cap carpeta supervisada.
Imap_NoMappings Cap assignació definida.
Imap_SaveAnyway Desa igualment
Imap_SaveConnection Desa connexió
Imap_SaveFolders Desa carpetes
Imap_Saving Desant...
Imap_TestConnection Prova connexió
Imap_Testing Provant...
Imap_TrainingHint El mode d'entrenament analitza les carpetes d'arxiu existents i entrena el classificador amb el seu contingut. L'indicador es restableix automàticament quan acaba l'entrenament.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Mode d'entrenament
Imap_TrainingLimit Missatges per carpeta (0 = il·limitat)
Imap_WatchedFolders Carpetes supervisades
Imap_WatchedHint POPFile supervisa aquestes carpetes IMAP per a nous missatges a classificar.
Magnet_Created Imant creat
Magnet_Deleted Imant eliminat
Reconnect_Connecting Connectant...
Reconnect_Message El backend no és accessible. Intentant reconectar...
Reconnect_Now Reconnecta ara
Reconnect_RetryIn Reintentant en
Reconnect_Title Connexió perduda
Settings_AdminPassword Contrasenya d'administrador
Settings_ArchiveDirectory Directori d'arxiu
Settings_ArchiveMessages Arxiva missatges
Settings_ArchiveSubdirs Subdirectoris d'arxiu
Settings_AutoDetect Detecció automàtica
Settings_AutoDetectLanguage Detecta l'idioma automàticament
Settings_ChainPort Port en cadena
Settings_ChainServer Servidor en cadena
Settings_DateFormat Format de data
Settings_DescAdminPassword Deixeu en blanc per desactivar la protecció per contrasenya.
Settings_DescArchiveDir Directori per als missatges arxivats (relatiu al directori d'usuari).
Settings_DescArchiveMessages Desa una còpia de cada missatge classificat al disc.
Settings_DescArchiveSubdirs Divideix l'arxiu en N subdirectoris (0 = desactivat).
Settings_DescAutoDetectLang Detecta l'idioma de cada missatge i aplica les paraules buides i l'stemmer corresponents. Afegeix ~130% de latència de classificació; útil per a bústies multilingües.
Settings_DescChainPort Port del servidor SMTP aigües amunt.
Settings_DescChainServer Nom d'host del servidor SMTP aigües amunt.
Settings_DescDateFormat Cadena de format strftime. Deixeu en blanc per al valor predeterminat del locale.
Settings_DescForceFork Crea un nou procés per a cada connexió.
Settings_DescHEADFetchesBody Recupera l'article complet amb l'ordre HEAD.
Settings_DescHTTPPort Port on escolta la interfície web. Requereix reinici.
Settings_DescItemsPerPage Files mostrades per pàgina a Historial i Imants.
Settings_DescLanguage Idioma de visualització de la interfície. Deixeu en blanc per a la detecció automàtica des del navegador.
Settings_DescListenAddress Adreça IP a la qual vincular-se. Buit = totes les interfícies.
Settings_DescLocalOnly_UI Restringeix la interfície web a connexions locals.
Settings_DescLogDirectory Directori per als fitxers de registre. Buit = arrel de POPFile.
Settings_DescLogLevel Verbositat de la sortida de registre.
Settings_DescLogSQLToStdout Imprimeix cada instrucció SQL amb valors vinculats a stdout. Actiu només quan "Registre a stdout" també està activat.
Settings_DescLogToStdout Reflecteix la sortida de registre a stdout a més del fitxer de registre.
Settings_DescMessageCutoff Nombre màxim de paraules analitzades per missatge (0 = il·limitat).
Settings_DescNNTPLocalOnly Accepta només connexions NNTP des de localhost.
Settings_DescNNTPPort Port on POPFile escolta per a NNTP (predeterminat 119).
Settings_DescNNTPSeparator Caràcter que separa l'usuari del servidor.
Settings_DescPOP3LocalOnly Accepta només connexions POP3 des de localhost.
Settings_DescPOP3Port Port on POPFile escolta per a POP3 (predeterminat 1110).
Settings_DescPOP3Separator Caràcter que separa l'usuari del servidor (p.ex. usuari:mailhost).
Settings_DescRetentionDays Quants dies conservar l'historial de missatges.
Settings_DescSessionDividers Mostra divisors entre sessions de navegació a l'Historial.
Settings_DescSMTPLocalOnly Accepta només connexions SMTP des de localhost.
Settings_DescSMTPPort Port on POPFile escolta per a SMTP (predeterminat 25).
Settings_DescSQLiteJournal Mode de diari SQLite / WAL.
Settings_DescSQLiteTweaks Màscara de bits: 1 = escriptures més ràpides (menys segures), 2 = còpia de seguretat periòdica.
Settings_DescSSLChainPort Port del servidor SSL POP3 aigües amunt.
Settings_DescSSLChainServer Nom d'host del servidor SSL POP3 aigües amunt per a l'encadenament SSL.
Settings_DescSubjectTagLeft Prefix inserit a la capçalera Assumpte, p.ex. [SPAM].
Settings_DescSubjectTagRight Sufix afegit a la capçalera Assumpte.
Settings_DescTagPosition On col·locar l'etiqueta de l'assumpte.
Settings_DescTOPFetchesBody Recupera també el cos del missatge amb l'ordre TOP.
Settings_DescUnclassifiedWeight Llindar de probabilitat per sota del qual el correu és "no classificat".
Settings_DescWordStemming Redueix les paraules a la seva arrel abans de la classificació (p.ex. "corrent" a "corr"). Millora la recuperació per a idiomes morfològicament rics amb ~10% de cost de latència.
Settings_DescWordTable Què mostrar a la taula de probabilitat de paraules.
Settings_ErrorSaving Error en desar
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD recupera el cos
Settings_HTTPPort Port HTTP
Settings_ItemsPerPage Elements per pàgina
Settings_ListenAddress Adreça d'escolta
Settings_ListenPort Port d'escolta
Settings_LocalOnly Només local
Settings_LogDirectory Directori de registre
Settings_LogLevel Nivell de registre
Settings_LogSQLToStdout Registre SQL a stdout
Settings_LogToStdout Registre a stdout
Settings_MessageCutoff Límit de missatge
Settings_OptDebug Depuració
Settings_OptEnd Final
Settings_OptErrorsOnly Només errors
Settings_OptFrequencies Freqüències
Settings_OptFront Davant
Settings_OptHidden Ocult
Settings_OptInfo Info
Settings_OptLogScores Registra puntuacions
Settings_OptProbabilities Probabilitats
Settings_OptWarnings Advertències
Settings_RetentionDays Retenció (dies)
Settings_SaveChanges Desa els canvis
Settings_Saved Desat
Settings_Saving Desant...
Settings_Search Cerca configuració...
Settings_SectionClassifier Classificador
Settings_SectionHistory Historial
Settings_SectionLogging Registre
Settings_SectionNNTP Proxy NNTP
Settings_SectionPOP3 Proxy POP3
Settings_SectionSecurity Seguretat
Settings_SectionSMTP Proxy SMTP
Settings_SectionUI Interfície d'usuari
Settings_ServerSeparator Separador de servidor
Settings_SessionDividers Divisors de sessió
Settings_SQLiteJournalMode Mode de diari SQLite
Settings_SQLiteTweaks Ajustos de SQLite
Settings_SSLChainPort Port SSL en cadena
Settings_SSLChainServer Servidor SSL en cadena
Settings_SubjectTagLeft Etiqueta assumpte esquerra
Settings_SubjectTagRight Etiqueta assumpte dreta
Settings_TagPosition Posició de l'etiqueta
Settings_TOPFetchesBody TOP recupera el cos
Settings_UnclassifiedWeight Pes no classificat
Settings_WordStemming Stemming de paraules
Settings_WordTable Taula de paraules
Status_Checking Comprovant...
Status_Description Comprovacions d'estat per als serveis de POPFile.
Status_LoadError Error en carregar l'estat
Status_NoChecks Cap comprovació disponible.

Imap_Use_SSL Utilitza SSL

WordView_Title Precisió de paraules
WordView_SelectBucket selecciona categoria
WordView_Words paraules
WordView_Loading Carregant...
WordView_Empty No hi ha paraules en aquesta categoria.
WordView_ColWord Paraula
WordView_ColCount Recompte
WordView_ColTotal Total
WordView_ColAccuracy Precisió
WordView_ColActions Accions
WordView_Remove Elimina
WordView_MoveTo mou a
WordView_Move Mou

Language_Name                           Català
History_PerPage                          Entrades per pàgina
Imap_Advanced                            Avançat
Imap_Cancel                              Cancel·lar
Imap_Wizard                              Assistent de configuració
Imap_WizardApply                         Crear i mapar
Imap_WizardClose                         Tancar
Imap_WizardDesc                          Seleccioneu carpetes per crear-hi buckets i mapatges.
Imap_WizardDeselectAll                   Deseleccionar tot
Imap_WizardDone                          {count} bucket(s) creats i mapats.
Imap_WizardEmpty                         No sha trobat cap carpeta addicional al servidor.
Imap_WizardSelectAll                     Seleccionar tot
Imap_WizardTrain                         Entrenar ara
NavWordSearch                            Cerca de paraules
Settings_DescEnableProxy                 Iniciar aquest servidor intermediari en iniciar POPFile.
Settings_DescLogFormat                   Format de sortida del registre (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Obrir automàticament el navegador en iniciar.
Settings_DescSQLiteBackup                Fer còpia de seguretat automàtica abans de canvis desperma.
Settings_DescSQLiteFastWrites            Desactivar la sincronització de la base de dades (més ràpid, menys segur).
Settings_EnableService                   Activar servei
Settings_LogFormat                       Format del registre
Settings_OpenBrowser                     Obrir navegador
Settings_SQLiteBackup                    Còpia de seguretat SQLite
Settings_SQLiteFastWrites                Escriptura ràpida SQLite
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Afegir stopword
WordSearch_ColumnBuckets                 Buckets
WordSearch_ColumnWord                    Paraula
WordSearch_IsStopword                    Stopword
WordSearch_Loading                       Carregant...
WordSearch_NoResults                     Sense resultats.
WordSearch_NoStopwords                   Sense stopwords.
WordSearch_Placeholder                   Introduïu una paraula...
WordSearch_RemoveStopword                Eliminar stopword
WordSearch_Search                        Cercar
WordSearch_StopwordList                  Llista de stopwords
WordSearch_Title                         Cerca de paraules
WordSearch_Total                         Total
