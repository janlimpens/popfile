# Copyright (c) 2001-2011 John Graham-Cumming

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          br

# Common words that are used on their own all over the interface
Apply                                   Aplicar
Add                                     Adicionar
Remove                                  Remover
Previous                                Anterior
Next                                    Próximo
From                                    De
Subject                                 Assunto
Reclassify                              Reclassificar
Undo                                    Desfazer
Close                                   Fechar
Bucket                                  Categoria
Magnet                                  Ímã
Delete                                  Excluir
Create                                  Criar
Total                                   Total
Rename                                  Renomear
Update                                  Alterar
Refresh                                 Atualizar
Date                                    Data

# The header and footer that appear on every UI page

Configuration_Language                  Linguagem

History_SearchMessage                   Procurar Remetente/Assunto

Magnet_CurrentMagnets                   Ímãs Atuais
Magnet_CreateNew                        Criar Novo Ímã

Bucket_CreateBucket                     Criar categoria com o nome
Bucket_RenameBucket                     Renomear a categoria chamado

Imap_Server                             Nome do servidor IMAP:
Imap_Port                               Porta do servidor IMAP:
Imap_Login                              Conta de login IMAP:
Imap_Password                           Senha para a conta IMAP:
Imap_Expunge                            Expurgar mensagens deletadas de pastas em observação.
Imap_Interval                           Intervalo de atualização em segundos:
Imap_NoConnectionMessage                Por favor configure os detalhes da conexão primeiro. Depois disto, mais opções estarão disponíveis nesta página.

# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Corpus
NavHistory Histórico
NavIMAP IMAP
NavMagnets Ímãs
NavStatus Status
NavWordSearch Words & Stopwords
Corpus_BucketList Categorias
Corpus_Color Cor
Corpus_Actions Ações
Corpus_Clear Limpar
WordSearch_Title Word Search
WordSearch_Placeholder prefix...
WordSearch_Search Search
WordSearch_ColumnWord Word
WordSearch_ColumnBuckets Buckets
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
History_AllBuckets Todas as categorias
History_HighlightWords Destacar palavras por categoria
History_Loading Carregando...
History_PerPage Por página:
History_MoveTo — mover para —
History_Moving Movendo...
History_Reclassifying Reclassificando...
History_ReclassifyUnclassified Reclassificar não classificados
History_Selected selecionado(s)
Imap_BucketFolderMappings Categoria -> Mapeamentos de pastas
Imap_Connected Conectado
Imap_Connection Conexão
Imap_ConnectionFailed Falha na conexão
Imap_Description Monitorar pastas IMAP e classificar automaticamente as mensagens recebidas.
Imap_FetchFolders Obter pastas
Imap_Fetching Obtendo...
Imap_IMAFFolder Pasta IMAP
Imap_MappingsHint As mensagens classificadas são movidas para a pasta IMAP especificada. Deixe as categorias não mapeadas vazias para ignorar o movimento.
Imap_NoFoldersWatched Nenhuma pasta monitorada ainda.
Imap_NoMappings Nenhum mapeamento definido.
Imap_SaveAnyway Salvar mesmo assim
Imap_SaveConnection Salvar conexão
Imap_SaveFolders Salvar pastas
Imap_Saving Salvando...
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
Imap_TestConnection Testar conexão
Imap_Testing Testando...
Imap_TrainingHint O modo de treinamento analisa as pastas de arquivo existentes e treina o classificador com seu conteúdo. O indicador é redefinido automaticamente quando o treinamento termina.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Modo de treinamento
Imap_TrainingLimit Mensagens por pasta (0 = ilimitado)
Imap_WatchedFolders Pastas monitoradas
Imap_WatchedHint O POPFile monitora estas pastas IMAP para novas mensagens a classificar.
Magnet_Created Ímã criado
Magnet_Deleted Ímã excluído
Reconnect_Connecting Conectando...
Reconnect_Message O backend não está acessível. Tentando reconectar...
Reconnect_Now Reconectar agora
Reconnect_RetryIn Tentando novamente em
Reconnect_Title Conexão perdida
Settings_AdminPassword Senha do administrador
Settings_ArchiveDirectory Diretório de arquivo
Settings_ArchiveMessages Arquivar mensagens
Settings_ArchiveSubdirs Sub-diretórios de arquivo
Settings_AutoDetect Detecção automática
Settings_AutoDetectLanguage Detectar idioma automaticamente
Settings_ChainPort Porta em cadeia
Settings_ChainServer Servidor em cadeia
Settings_DescAdminPassword Deixar vazio para desativar a proteção por senha.
Settings_DescArchiveDir Diretório para mensagens arquivadas (relativo ao diretório do usuário).
Settings_DescArchiveMessages Salvar uma cópia de cada mensagem classificada no disco.
Settings_DescArchiveSubdirs Dividir o arquivo em N sub-diretórios (0 = desativado).
Settings_DescAutoDetectLang Detecta o idioma de cada mensagem e aplica as palavras de parada e o stemmer correspondentes. Adiciona ~130% de latência de classificação; útil para caixas de correio com múltiplos idiomas.
Settings_DescChainPort Porta do servidor SMTP upstream.
Settings_DescChainServer Nome do host do servidor SMTP upstream.
Settings_DescForceFork Criar um novo processo para cada conexão.
Settings_DescHEADFetchesBody Obter artigo completo com o comando HEAD.
Settings_DescHTTPPort Porta em que a interface web escuta. Requer reinicialização.
Settings_DescItemsPerPage Linhas mostradas por página no Histórico e Ímãs.
Settings_DescLanguage Idioma de exibição da interface. Deixar vazio para detecção automática pelo navegador.
Settings_DescListenAddress Endereço IP para vincular. Vazio = todas as interfaces.
Settings_DescLocalOnly_UI Restringir a interface web a conexões locais.
Settings_DescLogDirectory Diretório para arquivos de log. Vazio = raiz do POPFile.
Settings_DescLogLevel Verbosidade da saída de log.
Settings_DescLogFormat Formato das linhas de log. Use 'plain' para journald ou ambientes que adicionam seus próprios carimbos de data/hora.
Settings_DescLogSQLToStdout Incluir instruções SQL com valores vinculados na saída de log. Segue o mesmo destino que outras mensagens de log (arquivo e/ou stdout).
Settings_DescLogToStdout Espelhar a saída de log no stdout além do arquivo de log.
Settings_DescOpenBrowser Abrir o navegador padrão quando a interface web estiver pronta.
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
Settings_DescSQLiteBackup Copiar o banco de dados para um arquivo .backup a cada hora.
Settings_DescSQLiteFastWrites Desativar a sincronização de escrita SQLite para inserções mais rápidas. Risco mínimo de perda de dados em caso de falha.
Settings_DescSSLChainPort Porta do servidor SSL POP3 upstream.
Settings_DescSSLChainServer Nome do host do servidor SSL POP3 upstream para encadeamento SSL.
Settings_DescSubjectTagLeft Prefixo inserido no cabeçalho Assunto, ex. [SPAM].
Settings_DescSubjectTagRight Sufixo acrescentado ao cabeçalho Assunto.
Settings_DescTagPosition Onde colocar a etiqueta do assunto.
Settings_DescTOPFetchesBody Obter também o corpo da mensagem com o comando TOP.
Settings_DescUnclassifiedWeight Limiar de probabilidade abaixo do qual o e-mail está "não classificado".
Settings_DescWordStemming Reduzir palavras ao seu radical antes da classificação (ex. "correndo" para "corr"). Melhora a recuperação para idiomas morfologicamente ricos com ~10% de custo de latência.
Settings_DescWordTable O que mostrar na tabela de probabilidade de palavras.
Settings_ErrorSaving Erro ao salvar
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD obtém o corpo
Settings_HTTPPort Porta HTTP
Settings_ItemsPerPage Itens por página
Settings_ListenAddress Endereço de escuta
Settings_ListenPort Porta de escuta
Settings_LocalOnly Apenas local
Settings_LogDirectory Diretório de log
Settings_LogLevel Nível de log
Settings_LogFormat Formato de log
Settings_LogSQLToStdout Registar consultas SQL
Settings_LogToStdout Log no stdout
Settings_OpenBrowser Abrir navegador ao iniciar
Settings_MessageCutoff Limite de mensagem
Settings_OptDebug Depuração
Settings_OptEnd Fim
Settings_OptErrorsOnly Apenas erros
Settings_OptFrequencies Frequências
Settings_OptFront Frente
Settings_OptHidden Oculto
Settings_OptInfo Info
Settings_OptLogScores Log de pontuações
Settings_OptProbabilities Probabilidades
Settings_OptWarnings Avisos
Settings_RetentionDays Retenção (dias)
Settings_SaveChanges Salvar alterações
Settings_Saved Salvo
Settings_Saving Salvando...
Settings_Search Pesquisar configurações...
Settings_EnableService Ativar serviço
Settings_SectionClassifier Classificador
Settings_SectionHistory Histórico
Settings_SectionLogging Log
Settings_SectionNNTP NNTP
Settings_DescNNTP                        Proxy NNTP — fica entre seu leitor de notícias e o servidor NNTP. Classifica artigos e adiciona cabeçalhos. Aponte seu leitor de notícias para o host e porta onde o POPFile está rodando (padrão 119).
Settings_SectionPOP3 POP3
Settings_DescPOP3                        Proxy POP3 — fica entre seu cliente de email e o servidor POP3. Classifica cada mensagem e adiciona um cabeçalho X-Text-Classification. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 1110) em vez do servidor POP3 real.
Settings_SectionIMAP                    IMAP
Settings_SectionSecurity Segurança
Settings_SectionSMTP SMTP
Settings_DescSMTP                        Proxy SMTP — fica entre seu cliente de email e o servidor SMTP. Classifica mensagens enviadas e as encaminha ao servidor real. Aponte seu cliente de email para o host e porta onde o POPFile está rodando (padrão 25).
Settings_SectionUI Interface do usuário
Settings_ServerSeparator Separador de servidor
Settings_SessionDividers Divisores de sessão
Settings_SQLiteJournalMode Modo de diário SQLite
Settings_SQLiteBackup SQLite: backup periódico
Settings_SQLiteFastWrites SQLite: escrita rápida (menos seguro)
Settings_SSLChainPort Porta SSL em cadeia
Settings_SSLChainServer Servidor SSL em cadeia
Settings_SubjectTagLeft Etiqueta assunto esquerda
Settings_SubjectTagRight Etiqueta assunto direita
Settings_TagPosition Posição da etiqueta
Settings_TOPFetchesBody TOP obtém o corpo
Settings_UnclassifiedWeight Peso não classificado
Settings_WordStemming Stemming de palavras
Settings_WordTable Tabela de palavras
Status_Checking Verificando...
Status_Description Verificações de status para os serviços do POPFile.
Status_LoadError Falha ao carregar o status
Status_NoChecks Nenhuma verificação disponível.

Imap_Use_SSL Usar SSL

Language_Name                           Português (Brasil)
Wizard_Next                             Próximo
Wizard_Manual                           Configuração manual
Wizard_ManualDesc                       Insira os dados do seu servidor de email.
Wizard_Encryption                       Criptografia
Wizard_None                             Nenhuma
Wizard_Done                             Pronto!
Wizard_Welcome                          Seja bem-vindo! POPFile te ajuda a organizar sua caixa de entrada. Comece digitando seu nome de usuário — geralmente seu email.
Wizard_Username                         Usuário
