# Copyright (c) 2001-2011 John Graham-Cumming
# Translated by Adriano Rafael Gomes <adrianorg@users.sourceforge.net>
# Updated by Fernando de Alcantara Correia <facorreia@users.sourceforge.net> to v0.19.1
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
LanguageCode                            br
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          br

# This is where to find the FAQ on the Wiki
FAQLink                                 FAQ

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
Next                                    Próximo
From                                    De
Subject                                 Assunto
Cc                                      Cc
Classification                          categoria
Reclassify                              Reclassificar
Probability                             Probabilidade
Scores                                  Pontos
QuickMagnets                            Ímãs Rápidos
Undo                                    Desfazer
Close                                   Fechar
Find                                    Procurar
Filter                                  Filtrar
Yes                                     Sim
No                                      Não
ChangeToYes                             Trocar para Sim
ChangeToNo                              Trocar para Não
Bucket                                  Categoria
Magnet                                  Ímã
Delete                                  Excluir
Create                                  Criar
To                                      Para
Total                                   Total
Rename                                  Renomear
Frequency                               Freqüência
Probability                             Probabilidade
Score                                   Pontuação
Lookup                                  Procurar
Word                                    Palavra
Count                                   Quantidade
Update                                  Alterar
Refresh                                 Atualizar
FAQ                                     FAQ
ID                                      ID
Date                                    Data
Arrived                                 Chegada
Size                                    Tamanho

# This is a regular expression pattern that is used to convert
# a number into a friendly looking number (for the US and UK this
# means comma separated at the thousands)

Locale_Thousands                       .
Locale_Decimal                         ,

# The Locale_Date uses the format strings in Perl's Date::Format
# module to set the date format for the UI.  There are two possible
# ways to specify it.
#
# <format>            Just one simple format used for all dates
# <format> | <format> The first format is used for dates less than
#                     7 days from now, the second for all other dates

Locale_Date                            %a %R | %D %R

# The header and footer that appear on every UI page
Header_Title                            Centro de Controle do POPFile
Header_Shutdown                         Desligar o POPFile
Header_History                          Histórico
Header_Buckets                          Categorias
Header_Configuration                    Configuração
Header_Advanced                         Avançado
Header_Security                         Segurança
Header_Magnets                          Ímãs

Footer_HomePage                         POPFile Home Page
Footer_Manual                           Manual
Footer_Forums                           Forums
Footer_FeedMe                           Contribua
Footer_RequestFeature                   Pedir uma Característica
Footer_MailingList                      Lista de Email
Footer_Wiki                             Documentação

Configuration_Error1                    O caracter separador deve ser um único caracter
Configuration_Error2                    O porta da interface de usuário deve ser um número entre 1 e 65535
Configuration_Error3                    A porta de escuta POP3 deve ser um número entre 1 e 65535
Configuration_Error4                    O tamanho da página deve ser um número entre 1 e 1000
Configuration_Error5                    O número de dias no histórico deve ser um número entre 1 e 366
Configuration_Error6                    O tempo limite TCP deve ser um número entre 10 e 1800
Configuration_Error7                    A porta de escuta XML-RPC deve ser um número entre 1 e 65535
Configuration_Error8                    A porta do proxy SOCKS V deve ser um número entre 1 e 65535
Configuration_POP3Port                  Porta de escuta POP3
Configuration_POP3Update                A porta POP3 foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_XMLRPCUpdate              A porta XML-RPC foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_XMLRPCPort                Porta de escuta XML-RPC
Configuration_SMTPPort                  Porta de escuta SMTP
Configuration_SMTPUpdate                A porta SMTP foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_NNTPPort                  Porta de escuta NNTP
Configuration_NNTPUpdate                A porta NNTP foi alterada para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_POPFork                   Permitir conexões POP3 concorrentes
Configuration_SMTPFork                  Permitir conexões SMTP concorrentes
Configuration_NNTPFork                  Permitir conexões NNTP concorrentes
Configuration_POP3Separator             Caracter de separação POP3 servidor:porta:usuário
Configuration_NNTPSeparator             Caracter de separação NNTP servidor:porta:usuário
Configuration_POP3SepUpdate             Separador POP3 alterado para %s
Configuration_NNTPSepUpdate             Separador NNTP alterado para %s
Configuration_UI                        Porta da interface web de usuário
Configuration_UIUpdate                  Alterada a porta da interface web de usuário para %s; esta alteração não terá efeito até que você reinicie o POPFile
Configuration_History                   Número de mensagens por página
Configuration_HistoryUpdate             Alterado o número de mensagens por página para %s
Configuration_Days                      Número de dias para manter no histórico
Configuration_DaysUpdate                Alterado o número de dias para manter no histórico para %s
Configuration_UserInterface             Interface de Usuário
Configuration_Skins                     Skins
Configuration_SkinsChoose               Escolha o skin
Configuration_Language                  Linguagem
Configuration_LanguageChoose            Escolha a linguagem
Configuration_ListenPorts               Opções de Módulo
Configuration_HistoryView               Exibir Histórico
Configuration_TCPTimeout                Tempo Limite de Conexão
Configuration_TCPTimeoutSecs            Tempo limite de conexão em segundos
Configuration_TCPTimeoutUpdate          Alterado o tempo limite de conexão para %s
Configuration_ClassificationInsertion   Inserção de Texto na Mensagem
Configuration_SubjectLine               Modificação de<br>linha de assunto
Configuration_XTCInsertion              Cabeçalho<br>X-Text-Classification
Configuration_XPLInsertion              Cabeçalho<br>X-POPFile-Link
Configuration_Logging                   Logging
Configuration_None                      Nada
Configuration_ToScreen                  Na Tela (console)
Configuration_ToFile                    Em Arquivo
Configuration_ToScreenFile              Na Tela e em Arquivo
Configuration_LoggerOutput              Saída do Logger
Configuration_GeneralSkins              Skins
Configuration_SmallSkins                Small Skins
Configuration_TinySkins                 Tiny Skins
Configuration_CurrentLogFile            &lt;Exibir arquivo de log atual&gt;
Configuration_SOCKSServer               Endereço do proxy SOCKS V
Configuration_SOCKSPort                 Porta do proxy SOCKS V
Configuration_SOCKSPortUpdate           Alterada a porta do proxy SOCKS V para %s
Configuration_SOCKSServerUpdate         Alterado o endereço do proxy SOCKS V para %s
Configuration_Fields                    Colunas do Histórico

Advanced_Error1                         '%s' já está na lista de Palavras Ignoradas
Advanced_Error2                         Palavras ignoradas podem somente conter caracteres alfanuméricos, ., _, -, ou @
Advanced_Error3                         '%s' adicionado na lista de Palavras Ignoradas
Advanced_Error4                         '%s' não está na lista de Palavras Ignoradas
Advanced_Error5                         '%s' removido da lista de Palavras Ignoradas
Advanced_StopWords                      Palavras Ignoradas
Advanced_Message1                       O POPFile ignora as seguintes palavras freqüentemente usadas:
Advanced_AddWord                        Adicionar palavra
Advanced_RemoveWord                     Remover palavra
Advanced_AllParameters                  Todos os Parâmetros do POPFile
Advanced_Parameter                      Parâmetro
Advanced_Value                          Valor
Advanced_Warning                        Esta é a lista completa dos parâmetros do POPFile.  Somente para usuários avançados: você pode alterar qualquer um e clicar em Alterar; não há verificação de validade.  Ítens em negrito estão diferentes da configuração padrão. Veja <a href="http://getpopfile.org/docs/OptionReference">OptionReference</a> para mais informação sobre as opções.
Advanced_ConfigFile                     Arquivo de configuração:

History_Filter                          &nbsp;(apenas mostrando a categoria <font color="%s">%s</font>)
History_FilterBy                        Filtrar Por
History_Search                          &nbsp;(procurado por remetente/assunto %s)
History_Title                           Mensagens Recentes
History_Jump                            Ir para a página
History_ShowAll                         Exibir Tudo
History_ShouldBe                        Deveria ser
History_NoFrom                          sem linha de
History_NoSubject                       sem linha de assunto
History_ClassifyAs                      Classificar como
History_MagnetUsed                      Ímã usado
History_MagnetBecause                   <b>Ímã Utilizado</b><p>Classificado para <font color="%s">%s</font> por causa do ímã %s </p>
History_ChangedTo                       Alterado para <font color="%s">%s</font>
History_Already                         Reclassificado como <font color="%s">%s</font>
History_RemoveAll                       Remover Tudo
History_RemovePage                      Remover a Página
History_RemoveChecked                   Remover Marcados
History_Remove                          Para remover entradas do histórico clique
History_SearchMessage                   Procurar Remetente/Assunto
History_NoMessages                      Nenhuma mensagem
History_ShowMagnet                      magnetizado
History_Negate_Search                   Inverter procura/filtro
History_Magnet                          &nbsp;(mostrando apenas mensagens classificadas por ímã)
History_NoMagnet                        &nbsp;(mostrando apenas mensagens não classificadas por ímã)
History_ResetSearch                     Limpar
History_ChangedClass                    Deveria classificar agora como
History_Purge                           Expirar Agora
History_Increase                        Incrementar
History_Decrease                        Decrementar
History_Column_Characters               Alterar a largura das colunas De, Para, Cc e Assunto
History_Automatic                       Automático
History_Reclassified                    Reclassificado
History_Size_Bytes                      %d&nbsp;B
History_Size_KiloBytes                  %.1f&nbsp;KB
History_Size_MegaBytes                  %.1f&nbsp;MB

Password_Title                          Senha
Password_Enter                          Digite a senha
Password_Go                             Ir!
Password_Error1                         Senha incorreta

Security_Error1                         A porta deve ser um número entre 1 e 65535
Security_Stealth                        Modo Stealth/Operação Servidor
Security_NoStealthMode                  Não (Modo Stealth)
Security_StealthMode                    (Modo Stealth)
Security_ExplainStats                   (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em getpopfile.org: bc (o número total de categorias que você tem), mc (o número total de mensagens que o POPFile classificou) e ec (o número total de erros de classificação).  Isto fica guardado em um arquivo e eu vou usar para publicar algumas estatísticas sobre como as pessoas usam o POPFile e o quão bem ele funciona.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as estatístcas e os endereços IP de cada um.)
Security_ExplainUpdate                  (Com isto ligado o POPFile envia uma vez por dia os seguintes três valores para um script em getpopfile.org: ma (o número maior da versão do seu POPFile), mi (o número menor da versão do seu POPFile) e bn (o número do build da sua versão do POPFile). O POPFile recebe uma resposta na forma de um gráfico que aparece no topo da página se uma nova versão estiver disponível.  Meu servidor web mantém seus arquivos de log por mais ou menos 5 dias e então os deleta; eu não estou guardando nenhuma conexão entre as verificações de versão e os endereços IP de cada um.)
Security_PasswordTitle                  Senha da Interface de Usuário
Security_Password                       Senha
Security_PasswordUpdate                 Alterada a senha
Security_AUTHTitle                      Servidores Remotos
Security_SecureServer                   Servidor POP3 remoto (SPA/AUTH ou proxy transparente)
Security_SecureServerUpdate             Alterado o servidor POP3 remoto para %s
Security_SecurePort                     Porta POP3 remota (SPA/AUTH ou proxy transparente)
Security_SecurePortUpdate               Alterada a porta do servidor POP3 remoto para %s
Security_SMTPServer                     Servidor da cadeia SMTP
Security_SMTPServerUpdate               Alterado o servidor da cadeia SMTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_SMTPPort                       Porta da cadeia SMTP
Security_SMTPPortUpdate                 Alterada a porta da cadeia SMTP para %s; esta alteração não terá efeito até que você reinicie o POPFile
Security_POP3                           Aceitar conexões POP3 de máquinas remotas (requer reiniciar o POPFile)
Security_SMTP                           Aceitar conexões SMTP de máquinas remotas (requer reiniciar o POPFile)
Security_NNTP                           Aceitar conexões NNTP de máquinas remotas (requer reiniciar o POPFile)
Security_UI                             Aceitar conexões HTTP (Interface de Usuário) de máquinas remotas (requer reiniciar o POPFile)
Security_XMLRPC                         Aceitar conexões XML-RPC de máquinas remotas (requer reiniciar o POPFile)
Security_UpdateTitle                    Verificação Automática de Atualização
Security_Update                         Verificar diariamente atualizações para o POPFile
Security_StatsTitle                     Reportar Estatísticas
Security_Stats                          Enviar estatísticas diariamente

Magnet_Error1                           Ímã '%s' já existe na categoria '%s'
Magnet_Error2                           O novo ímã '%s' conflita com o ímã '%s' na categoria '%s' e pode causar resultados ambíguos.  O novo ímã não foi adicionado.
Magnet_Error3                           Criar novo ímã '%s' na categoria '%s'
Magnet_CurrentMagnets                   Ímãs Atuais
Magnet_Message1                         Os seguintes ímãs fazem as mensagens serem sempre classificadas na categoria especificado.
Magnet_CreateNew                        Criar Novo Ímã
Magnet_Explanation                      Estes tipos de ímã estão disponíveis: <ul><li><b>Endereço ou nome do remetente:</b> Por exemplo: fulano@empresa.com para pegar um endereço específico, <br />empresa.com para pegar todo mundo que envia de empresa.com, <br />Fulano de Tal para pegar uma pessoa específica, Fulano para pegar todos os Fulanos.</li><li><b>Endereço ou nome de destinatário/cópia:</b> Como um ímã de remetente mas para o endereço Para:/Cc: de uma mensagem.</li> <li><b>Palavras no assunto:</b> Por exemplo: olá para pegar todas as mensagens com olá no assunto.</li></ul>
Magnet_MagnetType                       Tipo do ímã
Magnet_Value                            Valores
Magnet_Always                           Sempre vai para a categoria
Magnet_Jump                             Ir para a página de ímãs

Bucket_Error1                           Nomes de categoria somente podem conter as letras de a até z minúsculas, números de 0 a 9, mais - e _
Bucket_Error2                           a categoria %s já existe
Bucket_Error3                           Criado a categoria %s
Bucket_Error4                           Por favor digite uma palavra que não seja em branco
Bucket_Error5                           Renomeado a categoria %s para %s
Bucket_Error6                           Excluído a categoria %s
Bucket_Title                            Configuração da categoria
Bucket_BucketName                       Nome do<br>categoria
Bucket_WordCount                        Contagem de Palavras
Bucket_WordCounts                       Contagens de Palavras
Bucket_UniqueWords                      Palavras Distintas
Bucket_SubjectModification              Modificação do<br>Cabeçalho Assunto
Bucket_ChangeColor                      Cor do<br>categoria
Bucket_NotEnoughData                    Dados insuficientes
Bucket_ClassificationAccuracy           Precisão da Classificação
Bucket_EmailsClassified                 Mensagens classificadas
Bucket_EmailsClassifiedUpper            Mensagens Classificadas
Bucket_ClassificationErrors             Erros de classificação
Bucket_Accuracy                         Precisão
Bucket_ClassificationCount              Contagem da Classificação
Bucket_ClassificationFP                 Falsos Positivos
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ResetStatistics                  Reiniciar Estatísticas
Bucket_LastReset                        Último Reinício
Bucket_CurrentColor                     A cor atual de %s é %s
Bucket_SetColorTo                       Ajustar a cor de %s para %s
Bucket_Maintenance                      Manutenção
Bucket_CreateBucket                     Criar categoria com o nome
Bucket_DeleteBucket                     Excluir a categoria chamado
Bucket_RenameBucket                     Renomear a categoria chamado
Bucket_Lookup                           Procurar
Bucket_LookupMessage                    Procurar por palavra nas categorias
Bucket_LookupMessage2                   Procurar no resultado por
Bucket_LookupMostLikely                 <b>%s</b> é mais provável de aparecer em <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> não aparece em nenhum das categorias
Bucket_DisabledGlobally                 Desabilitado globalmente
Bucket_To                               para
Bucket_Quarantine                       Mensagem de<br>Quarentena

SingleBucket_Title                      Detalhes para %s
SingleBucket_WordCount                  Contagem de palavras da categoria
SingleBucket_TotalWordCount             Contagem total de palavras
SingleBucket_Percentage                 Percentual do total
SingleBucket_WordTable                  Tabela de Palavras para %s
SingleBucket_Message1                   Clique em uma letra no índice para ver a lista de palavras que começam com tal letra.  Clique em qualquer palavra para procurar sua probabilidade para todos as categorias.
SingleBucket_Unique                     %s distinta
SingleBucket_ClearBucket                Remover Todas Palavras

Session_Title                           Sessão do POPFile Expirada
Session_Error                           A sua sessão do POPFile expirou.  Isto pode ter sido causado por iniciar e parar o POPFile mas deixando o navegador web aberto.  Por favor clique em um dos atalhos acima para continuar a usar o POPFile.

View_Title                              Visão de Única Mensagem
View_ShowFrequencies                    Exibir freqüência das palavras
View_ShowProbabilities                  Exibir probabilidade das palavras
View_ShowScores                         Exibir pontuação das palavras e gráfico de decisão
View_WordMatrix                         Matriz de palavras
View_WordProbabilities                  exibindo probabilidade das palavras
View_WordFrequencies                    exibindo freqüência das palavras
View_WordScores                         exibindo pontuação das palavras
View_Chart                              Gráfico de Decisão

Windows_TrayIcon                        Exibir o ícone do POPFile na bandeja do sistema?
Windows_Console                         Executar o POPFile em uma janela de console?
Windows_NextTime                        <p><font color="red">Esta alteração não terá efeito até que você reinicie o POPFile</font>

Header_MenuSummary                      Esta tabela é o menu de navegação que possibilita acesso a cada uma das diferentes páginas do centro de controle.
History_MainTableSummary                Esta tabela mostra o remetente e o assunto das mensagens recebidas recentemente e permite que elas sejam revisadas e reclassificadas.  Clicar na linha de assunto vai mostrar o texto inteiro da mensagem, juntamente com informação sobre por que ela foi classificada como o foi.  A coluna 'Deveria ser' permite que você especifique a que categoria a mensagem pertence, ou desfazer esta mudança.  A coluna 'Remover' permite que você exclua mensagens específicas do histórico se você não precisar mais delas.
History_OpenMessageSummary              Esta tabela contém o texto integral de uma mensagem, com as palavras que são usadas para classificação destacadas de acordo com a categoria que foi mais relevante para elas.
Bucket_MainTableSummary                 Esta tabela fornece uma visão geral das categorias de classificação.  Cada linha mostra o nome da categoria, a contagem total de palavras para aquela categoria, o número real de palavras individuais em cada categoria, se o assunto da mensagem vai ser modificado quando ele for classificado para aquela categoria, se as mensagens recebidas naquela categoria devem ficar em quarentena, e uma tabela para escolher a cor usada para mostrar qualquer coisa relacionada àquele categoria no centro de controle.
Bucket_StatisticsTableSummary           Esta tabela fornece três conjuntos de estatísticas sobre o desempenho geral do PopFile.  A primeira é a exatidão da classificação, a segunda é quantas mensagens foram classificadas, e para quais categorias, e a terceira é quantas palavras existem em cada categoria, e as suas porcentagens relativas.
Bucket_MaintenanceTableSummary          Esta tabela contém formulários que permitem que você crie, exclua ou renomeie categorias, e para procurar uma palavra em todos as categorias e ver as suas probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabela representa graficamente a exatidão da classificação de mensagens.
Bucket_BarChartSummary                  Esta tabela representa graficamente a uma alocação porcentual para cada um dos diferentes categorias.  Ela é usada tanto para o número de mensagens classificadas como para o número total de palavras.
Bucket_LookupResultsSummary             Esta tabela mostra as probabilidades associadas com qualquer palavra específica do corpus.  Para cada categoria, ela mostra a freqüência com que cada palavra ocorre, a probabilidade de que ela ocorra naquela categoria, e o efeito geral na pontuação da categoria se aquela palavra existir em uma mensagem.
Bucket_WordListTableSummary             Esta tabela fornece uma relação de todas as palavras para uma categoria específico, organizada pela primeira letra comum para cada linha.
Magnet_MainTableSummary                 Esta tabela mostra a lista de ímãs que são usados para classificar automaticamente mensagens de acordo com regras fixas.  Cada linha mostra como o ímã está definido, para qual categoria ele foi concebido, e um botão para excluir aquele ímã.
Configuration_MainTableSummary          Esta tabela contém alguns formulários que permitem que você controle a configuração do PopFile.
Configuration_InsertionTableSummary     Esta tabela contém botões para determinar se certas modificações são feitas no cabeçalho ou no assunto da mensagem antes que ela seja encaminhada para o programa cliente de mensagens.
Security_MainTableSummary               Esta tabela fornece conjuntos de controles que afetam a segurança da configuração geral do PopFile, se ele deve procurar automaticamente por atualizações do programa, e se estatísticas sobre o desempenho do PopFile devem ser enviadas ao banco de dados central do autor do programa para informação geral.
Advanced_MainTableSummary               Esta tabela fornece uma lista de palavras que o PopFile ignora quando classifica mensagens por causa da sua freqüência relativa nas mensagens em geral.  Elas são organizadas por linha de acordo com a primeira letra das palavras.

Imap_Bucket2Folder                      Email para a categoria '<b>%s</b>' vai para a pasta
Imap_MapError                           Você não pode mapear mais de uma categoria para uma única pasta!
Imap_Server                             Nome do servidor IMAP:
Imap_ServerNameError                    Por favor informe o nome do servidor!
Imap_Port                               Porta do servidor IMAP:
Imap_PortError                          Por favor informe um número de porta válido!
Imap_Login                              Conta de login IMAP:
Imap_LoginError                         Por favor informe um nome de usuário/login!
Imap_Password                           Senha para a conta IMAP:
Imap_PasswordError                      Por favor informe uma senha para o servidor!
Imap_Expunge                            Expurgar mensagens deletadas de pastas em observação.
Imap_Interval                           Intervalo de atualização em segundos:
Imap_IntervalError                      Por favor informe um intervalo entre 10 e 3600 segundos.
Imap_Bytelimit                          Bytes por mensagem para usar para classificação. Informe 0 (Nulo) para usar a mensagem completa:
Imap_BytelimitError                     Por favor informe um número.
Imap_RefreshFolders                     Atualizar a lista de pastas
Imap_Now                                agora!
Imap_UpdateError1                       Não é possível logar. Verifique seu nome de usuário e senha, por favor.
Imap_UpdateError2                       Falha na conexão ao servidor. Por favor verifique o nome e porta do servidor e certifique-se que você está online.
Imap_UpdateError3                       Por favor configure os detalhes da conexão primeiro.
Imap_NoConnectionMessage                Por favor configure os detalhes da conexão primeiro. Depois disto, mais opções estarão disponíveis nesta página.
Imap_WatchMore                          uma pasta para lista de pastas em observação
Imap_WatchedFolder                      Pasta em observação nº

Shutdown_Message                        O POPFile foi desligado

Help_Training                           Quando você usa o POPFile pela primeira vez, ele ainda não sabe nada e precisa de treinamento. O POPFile requer treinamento nas mensagens para cada categoria, e o treinamento acontece quando você reclassifica para a categoria correto uma mensagem que o POPFile classificou incorretamente. Você deve também configurar seu cliente de email para filtrar mensagens baseado na classificação do POPFile. Informação para configurar os filtros no seu cliente de email pode ser encontrado no <a href="http://getpopfile.org/docs/FAQ:EmailSorting">Projeto de Documentação do POPFile</a>.
Help_Bucket_Setup                       O POPFile requer pelo menos duas categorias além do pseudo-categoria "unclassified". O que torna o POPFile único é que ele pode classificar email, mais do que isso, você pode ter qualquer número de categorias. Uma configuração simples poderia ser uma categoria "spam", "pessoal", e uma categoria "trabalho".
Help_No_More                            Não mostre isto novamente

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
NavMagnets Ímãs
NavSettings Configurações
NavStatus Status
NavWordView Palavras
Corpus_BucketList Categorias
Corpus_Color Cor
Corpus_Actions Ações
Corpus_Clear Limpar
Corpus_Search Pesquisar
Corpus_StopwordsTitle Palavras de parada
Corpus_StopwordsDesc As palavras nesta lista nunca são usadas para classificação.
Corpus_RemoveStopword Remover
Corpus_StopwordCandidates Candidatas a palavras de parada
Corpus_StopwordCandidatesDesc Palavras que aparecem uniformemente em todas as categorias — pouco poder discriminativo.
Corpus_StopwordRatio Limiar máx/mín do índice
Corpus_LoadCandidates Encontrar candidatas
Corpus_NoCandidates Nenhuma candidata encontrada neste limiar.
Corpus_AddStopword Adicionar às palavras de parada
Corpus_WordsLink Palavras →
BucketSelect_AddNew Adicionar nova...
BucketSelect_AlreadyExists Já existe
BucketSelect_CreateError Erro ao criar categoria
BucketSelect_InvalidName Apenas a-z, 0-9, - e _
BucketSelect_NameRequired Nome obrigatório
Bucket_InIgnoredWords <b>%s</b> está nas palavras ignoradas. POPFile ignora esta palavra
History_AllBuckets Todas as categorias
History_HighlightWords Destacar palavras por categoria
History_Loading Carregando...
History_PerPage Por página:
History_MoveTo — mover para —
History_Moving Movendo...
History_NoMatchingMessages Nenhuma mensagem correspondente
History_Reclassifying Reclassificando...
History_ReclassifyUnclassified Reclassificar não classificados
History_Selected selecionado(s)
Imap_BucketFolderMappings Categoria -> Mapeamentos de pastas
Imap_Connected Conectado
Imap_Connection Conexão
Imap_ConnectionFailed Falha na conexão
Imap_Description Monitorar pastas IMAP e classificar automaticamente as mensagens recebidas.
Imap_EnableService Ativar serviço IMAP
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
Imap_Service Serviço
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
Settings_DescNNTPLocalOnly Aceitar apenas conexões NNTP do localhost.
Settings_DescNNTPPort Porta em que o POPFile escuta para NNTP (padrão 119).
Settings_DescNNTPSeparator Caractere que separa o usuário do servidor.
Settings_DescEnableProxy Iniciar este proxy quando o POPFile iniciar.
Settings_DescPOP3LocalOnly Aceitar apenas conexões POP3 do localhost.
Settings_DescPOP3Port Porta em que o POPFile escuta para POP3 (padrão 1110).
Settings_DescPOP3Separator Caractere que separa o usuário do servidor (ex. usuário:mailhost).
Settings_DescRetentionDays Quantos dias manter o histórico de mensagens.
Settings_DescSessionDividers Mostrar divisores entre sessões de navegação no Histórico.
Settings_DescSMTPLocalOnly Aceitar apenas conexões SMTP do localhost.
Settings_DescSMTPPort Porta em que o POPFile escuta para SMTP (padrão 25).
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
Settings_SectionNNTP Proxy NNTP
Settings_SectionPOP3 Proxy POP3
Settings_SectionSecurity Segurança
Settings_SectionSMTP Proxy SMTP
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
View_MessageBody Corpo da mensagem
View_MessageHeader Cabeçalho da mensagem

Configuration_Error10 A porta de escuta POP3 não pode ter o mesmo valor que a porta da interface do usuário
Configuration_Error9 A porta da interface do usuário não pode ter o mesmo valor que a porta de escuta POP3
Imap_Use_SSL Usar SSL

WordView_Title Precisão de palavras
WordView_SelectBucket selecionar categoria
WordView_Words palavras
WordView_Loading Carregando...
WordView_Empty Nenhuma palavra nesta categoria.
WordView_ColWord Palavra
WordView_ColCount No bucket
WordView_ColTotal Em todos os buckets
WordView_ColAccuracy Proporção
WordView_TipCount Quantas vezes esta palavra aparece neste bucket.
WordView_TipTotal Quantas vezes esta palavra aparece em todos os buckets combinados.
WordView_TipAccuracy Fração de ocorrências neste bucket. Ordenado por relevância suavizada por Laplace.
WordView_ColActions Ações
WordView_Remove Remover
WordView_MoveTo mover para
WordView_Move Mover
View_DownloadMessage Baixar mensagem

Language_Name                           Português (Brasil)
