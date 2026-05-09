# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

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
Next                                    Seguinte
From                                    Originador
Subject                                 Assunto
Reclassify                              Reclassificar
Undo                                    Desfazer
Close                                   Fechar
Bucket                                  Receptáculo
Magnet                                  Íman
Delete                                  Apagar
Create                                  Criar
Total                                   Total
Rename                                  Renomear
Refresh                                 Refrescar
Update                                  Actualizar



# The header and footer that appear on every UI page


Configuration_Language                  Língua


History_SearchMessage                   Procurar Assunto
History_ShowNoMagnet                    Não magnetizadas



Magnet_CurrentMagnets                   Ímans Actuais
Magnet_CreateNew                        Criar Novo Íman

Bucket_CreateBucket                     Criar um receptáculo com o nome
Bucket_RenameBucket                     Renomear o receptáculo chamado





# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Corpus
NavHistory Histórico
NavIMAP IMAP
NavMagnets Ímanes
NavStatus Estado
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
History_HighlightWords Realçar palavras por categoria
History_Loading A carregar...
History_PerPage Por página:
History_MoveTo — mover para —
History_Moving A mover...
History_Reclassifying A reclassificar...
History_ReclassifyUnclassified Reclassificar não classificados
History_Selected selecionado(s)
Imap_BucketFolderMappings Categoria -> Mapeamentos de pastas
Imap_Connected Ligado
Imap_Connection Ligação
Imap_ConnectionFailed Falha na ligação
Imap_Description Monitorizar pastas IMAP e classificar automaticamente as mensagens recebidas.
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

Date Data
Imap_Expunge Eliminar mensagens apagadas das pastas monitorizadas.
Imap_Interval Intervalo de atualização em segundos:
Imap_Login Nome de utilizador IMAP:
Imap_NoConnectionMessage Por favor, configure primeiro os detalhes de ligação. Depois haverá mais opções disponíveis nesta página.
Imap_Password Palavra-passe para a conta IMAP:
Imap_Port Porto do servidor IMAP:
Imap_Server Nome de host do servidor IMAP:
Imap_Use_SSL Usar SSL


Language_Name                           Português
Wizard_Next                             Próximo
Wizard_Manual                           Configuração manual
Wizard_ManualDesc                       Insira os dados do seu servidor de email.
Wizard_Encryption                       Encriptação
Wizard_None                             Nenhuma
Wizard_Done                             Pronto!
Wizard_Welcome                          Bem-vindo ao POPFile. POPFile ajuda a organizar a sua caixa de entrada. Comece por indicar o seu nome de utilizador — normalmente o seu email.
Wizard_Username                         Utilizador
