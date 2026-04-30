# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            pt
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          br
 
# Common words that are used on their own all over the interface
Apply                                   Aplicar
ApplyChanges                            Aplicar Alterações
On                                      Ligado
Off                                     Desligado
TurnOn                                  Ligar
TurnOff                                 Desligar
Add                                     Adicionar
Remove                                  Remover
Previous                                Anterior
Next                                    Seguinte
From                                    Originador
Subject                                 Assunto
Cc                                      Cc
Classification                          Classificação
Reclassify                              Reclassificar
Undo                                    Desfazer
Close                                   Fechar
Find                                    Procurar
Filter                                  Filtrar
Yes                                     Sim
No                                      Não
ChangeToYes                             Alterar para Sim
ChangeToNo                              Alterar para Não
Bucket                                  Receptáculo
Magnet                                  Íman
Delete                                  Apagar
Create                                  Criar
To                                      Para
Total                                   Total
Rename                                  Renomear
Frequency                               Frequência
Probability                             Probabilidade
Score                                   Pontuação
Lookup                                  Procurar
Refresh                                 Refrescar
Word                                    Palavra
Update                                  Actualizar
Count                                   Ocorrências
Scores                                  Classificações
QuickMagnets                             Criar Íman


View_Title                              Detalhes da mensagem

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle POPFile
Header_Shutdown                         Desligar POPFile
Header_History                          Histórico
Header_Buckets                          Receptáculos
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Magnets                          Ímans

Footer_HomePage                         POPFile na internet
Footer_Manual                           Manual
Footer_Forums                           Fórums
Footer_FeedMe                           Doações
Footer_RequestFeature                   Pedir uma funcionalidade
Footer_MailingList                      Lista de Email

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface do utilizador deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 1800
Configuration_Error7                    A porta de escuta XML RPC deve ser um número entre 1 e 65535
Configuration_POP3Port                  Porta de escuta POP3
Configuration_POP3Update                Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_NNTPPort                  Porta de escuta NNTP
Configuration_NNTPUpdate                Alterada a porta NNTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_SMTPPort                  Porta de escuta SMTP
Configuration_SMTPUpdate                Alterada a porta SMTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_XMLRPCPort                Porta de escuta XML RPC
Configuration_XMLRPCUpdate              Alterada a porta XML RPC para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_POP3Separator             Caracter separador POP3 (host:port:user)
Configuration_NNTPSeparator             Caracter separador NNTP (host:port:user)
Configuration_POP3SepUpdate             Alterado o separador POP3 para %s
Configuration_NNTPSepUpdate             Alterado o separador NNTP para %s
Configuration_UI                        Porta da interface do utilizador (web)
Configuration_UIUpdate                  Alterada a porta da interface web do utilizador para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_History                   Número de emails por página
Configuration_HistoryUpdate             Alterado o número de emails por página para %s
Configuration_Days                      Número de dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface do Utilizador
Configuration_Skins                     Aspecto
Configuration_SkinsChoose               Escolha o aspecto
Configuration_Language                  Língua
Configuration_LanguageChoose            Escolha a língua
Configuration_ListenPorts               Portas de Escuta
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão TCP
Configuration_TCPTimeoutSecs            Tempo limite de conexão TCP em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão TCP para %s
Configuration_ClassificationInsertion   Inserção de Classificação
Configuration_SubjectLine               Modificação do assunto
Configuration_XTCInsertion              Inserção de X-Text-Classification
Configuration_XPLInsertion              Inserção de X-POPFile-Link
Configuration_Logging                   Registo de actividade
Configuration_None                      em nenhum lado
Configuration_ToScreen                  no ecrã
Configuration_ToFile                    num ficheiro
Configuration_ToScreenFile              no ecrãn e num ficheiro
Configuration_LoggerOutput              Registar actividade
Configuration_GeneralSkins              Aspecto normal
Configuration_SmallSkins                Aspecto pequeno
Configuration_TinySkins                 Aspecto minúsculo
Configuration_CurrentLogFile            &lt;registo de actividade actual&gt;

Advanced_Error1                         '%s' já está na lista de palavras ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de palavras ignoradas
Advanced_Error4                         '%s' não estã na lista de palavras ignoradas
Advanced_Error5                         '%s' removido da lista de palavras ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       As seguintes palavras são ignoradas de todas as classificações porque ocorrem muito frequentemente.
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra

History_Filter                          &nbsp;(apenas mostrando o receptáculo <font color="%s">%s</font>)
History_FilterBy                        Filtrar por
History_ResetSearch                     Mostar todos
History_Search                          &nbsp;(procurar pelo assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a mensagem
History_ShowAll                         Exibir Tudo
History_ShouldBe                        Deveria ser
History_NoFrom                          sem originador
History_NoSubject                       sem assunto
History_ClassifyAs                      Classificar como
History_MagnetUsed                      Íman usado
History_MagnetBecause                   <b>Íman usado</b><p>Classificado em <font color="%s">%s</font> por causa do íman %s </p>
History_ChangedTo                       Alterado para <font color="%s">%s
History_Already                         Já reclassificado como <font color="%s">%s</font>
History_RemoveAll                       Remover Tudo
History_RemovePage                      Remover esta Página
History_Remove                          Para remover entradas do histórico use
History_SearchMessage                   Procurar Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      Magnetizadas
History_ShowNoMagnet                    Não magnetizadas
History_Magnet                          &nbsp;(mensagens classificadas por íman)
History_NoMagnet                        &nbsp;(mensagens não classificadas por íman)

Password_Title                          Senha
Password_Enter                          Digite a senha
Password_Go                             Entrar!
Password_Error1                         Senha incorreta

Security_Error1                         A porta segura deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em getpopfile.org: bc (o número total de receptáculos que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado num arquivo que eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  O meu servidor web mantém o seus arquivos de log por mais ou menos 5 dias antes de os apagar; Eu não guardo nenhuma ligação entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em getpopfile.org: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) and bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 antes de os apagar; Eu não guardo nenhuma ligação entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de utilizador
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha para %s
Security_AUTHTitle                      Autenticação Segura de Senha/AUTH
Security_SecureServer                   Servidor Seguro
Security_SecureServerUpdate             Alterado o servidor seguro para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SecurePort                     Porta segura
Security_SecurePortUpdate               Alterada a porta para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SMTPServer                     Servidor SMTP real
Security_SMTPServerUpdate               Alterado o servidor SMTP real para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SMTPPort                       Porta do servidor SMTP real
Security_SMTPPortUpdate                 Alterada a porta do servidor SMTP real para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_POP3                           Aceitar conexões POP3 de máquinas remotas
Security_NNTP                           Aceitar conexões NNTP de máquinas remotas
Security_XMLRPC                         Aceitar conexões XMLRPC de máquinas remotas
Security_SMTP                           Aceitar conexões SMTP de máquinas remotas
Security_UI                             Aceitar conexões HTTP (Interface de utilizador) de máquinas remotas
Security_UpdateTitle                    Verificação Automática de Atualizações
Security_Update                         Verificar diariamente atualizações para o POPFile
Security_StatsTitle                     Reportar Estatísticas
Security_Stats                          Enviar estatísticas para o John diariamente

Magnet_Error1                           Íman '%s' já existe no receptáculo '%s'
Magnet_Error2                           O novo íman '%s' colide com o íman '%s' no receptáculo '%s' e pode causar resultados ambíguos.  O novo íman não foi adicionado.
Magnet_Error3                           Criar novo íman '%s' no receptáculo '%s'
Magnet_CurrentMagnets                   Ímans Actuais
Magnet_Message1                         Os seguintes ímans atraem as mensagens para receptáculo especificado.
Magnet_CreateNew                        Criar Novo Íman
Magnet_Explanation                      Três tipos de íman estão disponíveis: <ul><li>De um endereço ou nome:</b> Por exemplo: adriano@companhia.com para apanhar um endereço específico, <br />companhia.com para apanhar todo mundo que manda mensagens de companhia.com, <br />Adriano Gomes para apanhar uma pessoa específica, Adriano para apanhar todos os Adrianos</li><li><b>Para um endereço ou nome:</b> Como um íman Originador: mas para o endereço Para: de uma mensagem </li><li><b>Palavras no assunto:</b> Por exemplo: olá para apanhar todas as mensagens com olá no assunto</li></ul>
Magnet_MagnetType                       Tipo do íman
Magnet_Value                            Valor
Magnet_Always                           Colocar sempre no receptáculo
Magnet_Jump                             Detalhes do íman

Bucket_Error1                           Nomes de receptáculos apenas podem conter as letras de a até z minúsculas mais - e _
Bucket_Error2                           O receptáculo %s já existe
Bucket_Error3                           Criado o receptáculo %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado o receptáculo %s para %s
Bucket_Error6                           Apagado o receptáculo %s
Bucket_Title                            Sumário
Bucket_BucketName                       Nome do receptáculo
Bucket_WordCount                        Palavras
Bucket_WordCounts                       Distribuição de Palavras
Bucket_UniqueWords                      Palavras Únicas
Bucket_SubjectModification              Modificação do Assunto
Bucket_ChangeColor                      Alterar Cor
Bucket_NotEnoughData                    Dados insuficientes
Bucket_ClassificationAccuracy           Exactidão da Classificação
Bucket_EmailsClassified                 Mensagens classificadas
Bucket_EmailsClassifiedUpper            Distribuição de Mensagens
Bucket_ClassificationErrors             Erros de classificação
Bucket_Accuracy                         Exactidão
Bucket_ClassificationCount              Mensagens
Bucket_ClassificationFP                 Falsos Positivos
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ResetStatistics                  Reiniciar contagem
Bucket_LastReset                        Início da contagem
Bucket_CurrentColor                     A côr actual do receptáculo "%s" é "%s"
Bucket_SetColorTo                       Alterar a côr do receptáculo "%s" para "%s"
Bucket_Maintenance                      Manutenção
Bucket_CreateBucket                     Criar um receptáculo com o nome
Bucket_DeleteBucket                     Apagar o receptáculo chamado
Bucket_RenameBucket                     Renomear o receptáculo chamado
Bucket_Lookup                           Procurar
Bucket_LookupMessage                    Procurar por palavra nos receptáculos
Bucket_LookupMessage2                   Procurar no resultado por
Bucket_LookupMostLikely                 <b>%s</b> é mais provável aparecer em <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> não aparece em nenhum dos receptáculos
Bucket_DisabledGlobally                 Desligado globalmente
Bucket_To                               para
Bucket_Quarantine                       Quarentena

SingleBucket_Title                      Detalhes do receptáculo %s
SingleBucket_WordCount                  Contagem de palavras do receptáculo
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentagem do total
SingleBucket_WordTable                  Tabela de palavras do receptáculo %s
SingleBucket_Message1                   Palavras com asterisco (*) foram usadas para classificação durante esta sessão do POPFile.  Clique em qualquer palavra para procurar sua probabilidade para todos os receptáculos.
SingleBucket_Unique                     %s únicas
SingleBucket_ClearBucket                Apagar todas as palavras do receptáculo

Session_Title                           Sessão Expirada
Session_Error                           A sua sessão POPFile expirou. Isto ocorre quando se reinicia o POPFile com o browser aberto. Por favor clique nos links do topo do ecran para continuar.

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


# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Corpus
NavHistory Histórico
NavIMAP IMAP
NavMagnets Ímanes
NavSettings Definições
NavStatus Estado
NavWordSearch Words & Stopwords
Corpus_BucketList Categorias
Corpus_Color Cor
Corpus_Actions Ações
Corpus_Clear Limpar
Corpus_Search Pesquisar
Corpus_WordsLink Palavras →
WordSearch_Title Word Search
WordSearch_Placeholder prefix...
WordSearch_Search Search
WordSearch_ColumnWord Word
WordSearch_ColumnBuckets Buckets
WordSearch_Coverage coverage
WordSearch_AddStopword + Stopword
WordSearch_RemoveStopword Stopword
WordSearch_IsStopword stopword
WordSearch_StopwordList Stopwords
WordSearch_NoResults No words found.
WordSearch_NoStopwords No stopwords defined.
WordSearch_Loading Loading...
WordSearch_Total words
BucketSelect_AddNew Adicionar nova...
BucketSelect_AlreadyExists Já existe
BucketSelect_CreateError Erro ao criar categoria
BucketSelect_InvalidName Apenas a-z, 0-9, - e _
BucketSelect_NameRequired Nome obrigatório
Bucket_InIgnoredWords <b>%s</b> está nas palavras ignoradas. POPFile ignora esta palavra
History_AllBuckets Todas as categorias
History_HighlightWords Realçar palavras por categoria
History_Loading A carregar...
History_PerPage Por página:
History_MoveTo — mover para —
History_Moving A mover...
History_NoMatchingMessages Nenhuma mensagem correspondente
History_Reclassifying A reclassificar...
History_ReclassifyUnclassified Reclassificar não classificados
History_Selected selecionado(s)
Imap_BucketFolderMappings Categoria -> Mapeamentos de pastas
Imap_Connected Ligado
Imap_Connection Ligação
Imap_ConnectionFailed Falha na ligação
Imap_Description Monitorizar pastas IMAP e classificar automaticamente as mensagens recebidas.
Imap_EnableService Ativar serviço IMAP
Imap_FetchFolders Obter pastas
Imap_Fetching A obter...
Imap_IMAFFolder Pasta IMAP
Imap_MappingsHint As mensagens classificadas são movidas para a pasta IMAP especificada. Deixe as categorias não mapeadas vazias para ignorar o movimento.
Imap_NoFoldersWatched Nenhuma pasta monitorizada ainda.
Imap_NoMappings Nenhum mapeamento definido.
Imap_SaveAnyway Guardar mesmo assim
Imap_SaveConnection Guardar ligação
Imap_SaveFolders Guardar pastas
Imap_Saving A guardar...
Imap_Advanced                           Avançado
Imap_Wizard                             Einrichtungs-Assistent
Imap_WizardDesc                         Ordner auswählen, für die Buckets und Zuordnungen erstellt werden sollen.
Imap_WizardEmpty                        Keine weiteren Ordner auf dem Server gefunden.
Imap_WizardApply                        Erstellen & zuordnen
Imap_WizardSelectAll                    Alle auswählen
Imap_WizardDeselectAll                  Alle abwählen
Imap_WizardDone                         {count} Bucket(s) erstellt und zugeordnet.
Imap_WizardTrain                        Jetzt trainieren
Imap_WizardClose                        Schließen
Imap_Cancel                             Abbrechen
Imap_Service Serviço
Imap_TestConnection Testar ligação
Imap_Testing A testar...
Imap_TrainingHint O modo de treino analisa as pastas de arquivo existentes e treina o classificador com o seu conteúdo. O indicador é reposto automaticamente quando o treino termina.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Modo de treino
Imap_TrainingLimit Mensagens por pasta (0 = ilimitado)
Imap_WatchedFolders Pastas monitorizadas
Imap_WatchedHint O POPFile monitoriza estas pastas IMAP para novas mensagens a classificar.
Magnet_Created Íman criado
Magnet_Deleted Íman eliminado
Reconnect_Connecting A ligar...
Reconnect_Message O backend não está acessível. A tentar reconectar...
Reconnect_Now Reconectar agora
Reconnect_RetryIn A tentar novamente em
Reconnect_Title Ligação perdida
Settings_AdminPassword Palavra-passe de administrador
Settings_ArchiveDirectory Diretório de arquivo
Settings_ArchiveMessages Arquivar mensagens
Settings_ArchiveSubdirs Sub-diretórios de arquivo
Settings_AutoDetect Deteção automática
Settings_AutoDetectLanguage Detetar idioma automaticamente
Settings_ChainPort Porto de cadeia
Settings_ChainServer Servidor de cadeia
Settings_DescAdminPassword Deixar vazio para desativar a proteção por palavra-passe.
Settings_DescArchiveDir Diretório para mensagens arquivadas (relativo ao diretório do utilizador).
Settings_DescArchiveMessages Guardar uma cópia de cada mensagem classificada no disco.
Settings_DescArchiveSubdirs Dividir o arquivo em N sub-diretórios (0 = desativado).
Settings_DescAutoDetectLang Deteta o idioma de cada mensagem e aplica as palavras de paragem e o stemmer correspondentes. Adiciona ~130% de latência de classificação; útil para caixas de correio com múltiplos idiomas.
Settings_DescChainPort Porto do servidor SMTP a montante.
Settings_DescChainServer Nome do host do servidor SMTP a montante.
Settings_DescForceFork Criar um novo processo para cada ligação.
Settings_DescHEADFetchesBody Obter artigo completo com o comando HEAD.
Settings_DescHTTPPort Porto em que a interface web escuta. Requer reinício.
Settings_DescItemsPerPage Linhas mostradas por página no Histórico e Ímanes.
Settings_DescLanguage Idioma de apresentação da interface. Deixar vazio para deteção automática a partir do browser.
Settings_DescListenAddress Endereço IP a vincular. Vazio = todas as interfaces.
Settings_DescLocalOnly_UI Restringir a interface web a ligações locais.
Settings_DescLogDirectory Diretório para ficheiros de registo. Vazio = raiz do POPFile.
Settings_DescLogLevel Verbosidade da saída de registo.
Settings_DescLogFormat Formato das linhas de registo. Use 'plain' para journald ou ambientes que adicionam os seus próprios carimbos de data/hora.
Settings_DescLogSQLToStdout Incluir instruções SQL com valores vinculados na saída de registo. Segue o mesmo destino que outras mensagens de registo (ficheiro e/ou stdout).
Settings_DescLogToStdout Espelhar a saída de registo no stdout além do ficheiro de registo.
Settings_DescOpenBrowser Abrir o navegador predefinido quando a interface web estiver pronta.
Settings_DescMessageCutoff Número máximo de palavras analisadas por mensagem (0 = ilimitado).
Settings_DescNNTP                        Proxy NNTP — fica entre seu leitor de notícias e o servidor NNTP. Classifica artigos e adiciona cabeçalhos. Aponte seu leitor de notícias para o host e porta onde o POPFile está rodando (padrão 119).
Settings_DescNNTP                        Proxy NNTP — fica entre seu leitor de notícias e o servidor NNTP. Classifica artigos e adiciona cabeçalhos. Aponte seu leitor de notícias para o host e porta onde o POPFile está rodando (padrão 119).
Settings_DescNNTP                        Proxy NNTP — fica entre seu leitor de notícias e o servidor NNTP. Classifica artigos e adiciona cabeçalhos. Aponte seu leitor de notícias para o host e porta onde o POPFile está rodando (padrão 119).
Settings_DescEnableProxy Iniciar este proxy quando o POPFile iniciar.
Settings_DescPOP3                        Proxy POP3 — fica entre seu cliente de email e o servidor POP3. Classifica cada mensagem e adiciona um cabeçalho X-Text-Classification. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 1110) em vez do servidor POP3 real.
Settings_DescPOP3                        Proxy POP3 — fica entre seu cliente de email e o servidor POP3. Classifica cada mensagem e adiciona um cabeçalho X-Text-Classification. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 1110) em vez do servidor POP3 real.
Settings_DescPOP3                        Proxy POP3 — fica entre seu cliente de email e o servidor POP3. Classifica cada mensagem e adiciona um cabeçalho X-Text-Classification. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 1110) em vez do servidor POP3 real.
Settings_DescRetentionDays Quantos dias manter o histórico de mensagens.
Settings_DescSessionDividers Mostrar divisores entre sessões de navegação no Histórico.
Settings_DescSMTP                        Proxy SMTP — fica entre seu cliente de email e o servidor SMTP. Classifica mensagens enviadas e as encaminha ao servidor real. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 25).
Settings_DescSMTP                        Proxy SMTP — fica entre seu cliente de email e o servidor SMTP. Classifica mensagens enviadas e as encaminha ao servidor real. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 25).
Settings_DescSQLiteJournal Modo de diário SQLite / WAL.
Settings_DescSQLiteBackup Copiar a base de dados para um ficheiro .backup a cada hora.
Settings_DescSQLiteFastWrites Desactivar a sincronização de escrita SQLite para inserções mais rápidas. Risco mínimo de perda de dados em caso de falha.
Settings_DescSSLChainPort Porto do servidor SSL POP3 a montante.
Settings_DescSSLChainServer Nome do host do servidor SSL POP3 a montante para encadeamento SSL.
Settings_DescSubjectTagLeft Prefixo inserido no cabeçalho Assunto, p.ex. [SPAM].
Settings_DescSubjectTagRight Sufixo acrescentado ao cabeçalho Assunto.
Settings_DescTagPosition Onde colocar a etiqueta do assunto.
Settings_DescTOPFetchesBody Obter também o corpo da mensagem com o comando TOP.
Settings_DescUnclassifiedWeight Limiar de probabilidade abaixo do qual o correio está "não classificado".
Settings_DescWordStemming Reduzir palavras ao seu radical antes da classificação (p.ex. "correndo" para "corr"). Melhora a recuperação para idiomas morfologicamente ricos com ~10% de custo de latência.
Settings_DescWordTable O que mostrar na tabela de probabilidade de palavras.
Settings_ErrorSaving Erro ao guardar
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD obtém o corpo
Settings_HTTPPort Porto HTTP
Settings_ItemsPerPage Itens por página
Settings_ListenAddress Endereço de escuta
Settings_ListenPort Porto de escuta
Settings_LocalOnly Apenas local
Settings_LogDirectory Diretório de registo
Settings_LogLevel Nível de registo
Settings_LogFormat Formato de registo
Settings_LogSQLToStdout Registar consultas SQL
Settings_LogToStdout Registar no stdout
Settings_OpenBrowser Abrir navegador ao iniciar
Settings_MessageCutoff Limite de mensagem
Settings_OptDebug Depuração
Settings_OptEnd Fim
Settings_OptErrorsOnly Apenas erros
Settings_OptFrequencies Frequências
Settings_OptFront Frente
Settings_OptHidden Oculto
Settings_OptInfo Info
Settings_OptLogScores Registar pontuações
Settings_OptProbabilities Probabilidades
Settings_OptWarnings Avisos
Settings_RetentionDays Retenção (dias)
Settings_SaveChanges Guardar alterações
Settings_Saved Guardado
Settings_Saving A guardar...
Settings_Search Pesquisar definições...
Settings_EnableService Activar serviço
Settings_SectionClassifier Classificador
Settings_SectionHistory Histórico
Settings_SectionLogging Registo
Settings_SectionNNTP NNTP
Settings_DescNNTP                        Proxy NNTP — fica entre seu leitor de notícias e o servidor NNTP. Classifica artigos e adiciona cabeçalhos. Aponte seu leitor de notícias para o host e porta onde o POPFile está rodando (padrão 119).
Settings_SectionPOP3 POP3
Settings_DescPOP3                        Proxy POP3 — fica entre seu cliente de email e o servidor POP3. Classifica cada mensagem e adiciona um cabeçalho X-Text-Classification. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 1110) em vez do servidor POP3 real.
Settings_SectionIMAP                    IMAP
Settings_SectionSecurity Segurança
Settings_SectionSMTP SMTP
Settings_DescSMTP                        Proxy SMTP — fica entre seu cliente de email e o servidor SMTP. Classifica mensagens enviadas e as encaminha ao servidor real. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 25).
Settings_SectionUI Interface do utilizador
Settings_ServerSeparator Separador de servidor
Settings_SessionDividers Divisores de sessão
Settings_SQLiteJournalMode Modo de diário SQLite
Settings_SQLiteBackup SQLite: cópia de segurança periódica
Settings_SQLiteFastWrites SQLite: escrita rápida (menos seguro)
Settings_SSLChainPort Porto SSL de cadeia
Settings_SSLChainServer Servidor SSL de cadeia
Settings_SubjectTagLeft Etiqueta assunto esquerda
Settings_SubjectTagRight Etiqueta assunto direita
Settings_TagPosition Posição da etiqueta
Settings_TOPFetchesBody TOP obtém o corpo
Settings_UnclassifiedWeight Peso não classificado
Settings_WordStemming Stemming de palavras
Settings_WordTable Tabela de palavras
Status_Checking A verificar...
Status_Description Verificações de estado para os serviços do POPFile.
Status_LoadError Falha ao carregar o estado
Status_NoChecks Nenhuma verificação disponível.
View_MessageBody Corpo da mensagem
View_MessageHeader Cabeçalho da mensagem

Advanced_AllParameters Todos os parâmetros POPFile
Advanced_ConfigFile Ficheiro de configuração:
Advanced_Parameter Parâmetro
Advanced_Value Valor
Advanced_Warning Esta é a lista completa de parâmetros do POPFile. Apenas para utilizadores avançados: pode alterar qualquer um e clicar em Atualizar; não há verificação de validade. Os itens a negrito foram alterados da configuração predefinida.
Arrived Recebido
Configuration_Error10 O porto de escuta POP3 não pode ter o mesmo valor que o porto da interface do utilizador
Configuration_Error8 O porto do proxy SOCKS V deve ser um número entre 1 e 65535
Configuration_Error9 O porto da interface do utilizador não pode ter o mesmo valor que o porto de escuta POP3
Configuration_Fields Colunas do histórico
Configuration_NNTPFork Permitir ligações NNTP simultâneas
Configuration_POPFork Permitir ligações POP3 simultâneas
Configuration_SMTPFork Permitir ligações SMTP simultâneas
Configuration_SOCKSPort Porto do proxy SOCKS V
Configuration_SOCKSPortUpdate Porto do proxy SOCKS V atualizado para %s
Configuration_SOCKSServer Host do proxy SOCKS V
Configuration_SOCKSServerUpdate Host do proxy SOCKS V atualizado para %s
Date Data
FAQ FAQ
Footer_Wiki Documentação
Help_Bucket_Setup O POPFile requer pelo menos duas categorias além da pseudocategoria "não classificado". O que torna o POPFile único é que pode classificar o correio em mais do que isso; pode ter qualquer número de categorias. Uma configuração simples seria uma categoria "spam", "pessoal" e "trabalho".
Help_No_More Não mostrar isto novamente
Help_Training Quando usar o POPFile pela primeira vez, ele não sabe nada e precisará de treino. O POPFile requer treino em mensagens para cada categoria; o treino ocorre quando reclassifica uma mensagem que o POPFile classificou incorretamente para a categoria correta. Antes de o POPFile classificar a primeira mensagem, terá de ter reclassificado mensagens para pelo menos duas categorias.
History_Automatic Automático
History_ChangedClass Agora classificaria como
History_Column_Characters Alterar largura das colunas De, Para, Cc e Assunto
History_Decrease Diminuir
History_Increase Aumentar
History_Negate_Search Inverter pesquisa/filtro
History_Purge Expirar agora
History_Reclassified Reclassificado
History_RemoveChecked Remover selecionados
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
ID ID
Imap_Bucket2Folder O correio da categoria '<b>%s</b>' vai para a pasta
Imap_Bytelimit Bytes por mensagem para usar na classificação. Introduzir 0 para a mensagem completa:
Imap_BytelimitError Por favor, introduza um número.
Imap_Expunge Eliminar mensagens apagadas das pastas monitorizadas.
Imap_Interval Intervalo de atualização em segundos:
Imap_IntervalError Por favor, introduza um intervalo entre 10 e 3600 segundos.
Imap_Login Nome de utilizador IMAP:
Imap_LoginError Por favor, introduza um nome de utilizador!
Imap_MapError Não pode mapear mais de uma categoria para uma única pasta!
Imap_NoConnectionMessage Por favor, configure primeiro os detalhes de ligação. Depois haverá mais opções disponíveis nesta página.
Imap_Now agora!
Imap_Password Palavra-passe para a conta IMAP:
Imap_PasswordError Por favor, introduza uma palavra-passe para o servidor!
Imap_Port Porto do servidor IMAP:
Imap_PortError Por favor, introduza um número de porto válido!
Imap_RefreshFolders Atualizar lista de pastas
Imap_Server Nome de host do servidor IMAP:
Imap_ServerNameError Por favor, introduza o nome de host do servidor!
Imap_UpdateError1 Não foi possível iniciar sessão. Verifique o seu nome de utilizador e palavra-passe.
Imap_UpdateError2 Falha ao ligar ao servidor. Verifique o nome de host e o porto e certifique-se de que está online.
Imap_UpdateError3 Por favor, configure primeiro os detalhes de ligação.
Imap_Use_SSL Usar SSL
Imap_WatchedFolder Pasta monitorizada nº
Imap_WatchMore uma pasta à lista de pastas monitorizadas

Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Probability Probabilidade
Security_StealthMode (Modo furtivo)
Shutdown_Message POPFile foi encerrado
Size Tamanho
View_Chart Gráfico de decisão
View_DownloadMessage Descarregar mensagem
View_ShowFrequencies Mostrar frequências de palavras
View_ShowProbabilities Mostrar probabilidades de palavras
View_ShowScores Mostrar pontuações de palavras e gráfico de decisão
View_WordFrequencies a mostrar frequências de palavras
View_WordMatrix Matriz de palavras
View_WordProbabilities a mostrar probabilidades de palavras
View_WordScores a mostrar pontuações de palavras
Windows_Console Executar POPFile numa janela de consola?
Windows_NextTime <p><font color="red">Esta alteração não terá efeito até da próxima vez que iniciar o POPFile</font>
Windows_TrayIcon Mostrar ícone do POPFile na barra de sistema do Windows?

Language_Name                           Português
