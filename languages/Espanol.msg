# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCode                            es
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          es

# Common words that are used on their own all over the interface
Apply                                   Aplicar
On                                      Activo
Off                                     Inactivo
TurnOn                                  Activar
TurnOff                                 Desactivar
Add                                     Añadir
Remove                                  Quitar
Previous                                Previa
Next                                    Seguir
From                                    De
Subject                                 Asunto
Cc                                      Cc 
Classification                          Clasificación
Reclassify                              Reclasificar
Probability                             Probabilidad
Scores                                  Puntuaciones
QuickMagnets                            Superimanes
Undo                                    Deshacer
Close                                   Cerrar
Find                                    Buscar
Filter                                  Filtro
Yes                                     Si
No                                      No
ChangeToYes                             cambiar a Sí
ChangeToNo                              cambiar a No
Bucket                                  Categoría
Magnet                                  Imán
Delete                                  Borrar
Create                                  Crear
To                                      Para
Total                                   Total
Rename                                  Renombrar
Frequency                               Frequencia
Probability                             Probabilidad
Score                                   Puntuación
Lookup                                  Búsqueda
Word                                    Palabra
Count                                   Cuenta
Update                                  Actualizar
Refresh                                 Refrescar

# The header and footer that appear on every UI page
Header_Title                            POPFile - Centro de Control
Header_Shutdown                         Apagar POPFile
Header_History                          Historial
Header_Buckets                          Categorías
Header_Configuration                    Configuración
Header_Advanced                         Avanzado
Header_Security                         Seguridad
Header_Magnets                          Imanes

Footer_HomePage                         Página Web de POPFile
Footer_Manual                           Manual
Footer_Forums                           Foros
Footer_FeedMe                           Donar
Footer_RequestFeature                   Pedir Característica
Footer_MailingList                      Lista de Correo

Configuration_Error1                    El carácter separador tiene que ser uno solo
Configuration_Error2                    El puerto del GUI tiene que ser un nº entre 1 y 65535
Configuration_Error3                    El puerto de escucha POP3 tiene que ser un nº entre 1 y 65535
Configuration_Error4                    El tamaño de la página tiene que ser un nº entre 1 y 1000
Configuration_Error5                    El nº de dias en el historial tiene que ser un nº entre 1 y 366
Configuration_Error6                    La temporización TCP debe ser un nº entre 10 y 1800
Configuration_Error7                    El puerto de escucha XML RPC listen debe ser un número entre 1 y 65535
Configuration_POP3Port                  Puerto de escucha POP3
Configuration_POP3Update                Puerto actualizado a %s; este cambio será efectivo al siguiente reinicio de POPFile
Configuration_XMLRPCUpdate              Puerto XML-RPC actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_XMLRPCPort                Puerto de escucha XML-RPC
Configuration_SMTPPort                  Puerto de escucha SMTP
Configuration_SMTPUpdate                Puerto SMTP actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_NNTPPort                  Puerto de escucha NNTP
Configuration_NNTPUpdate                Puerto NNTP actualizado a %s; este cambio será efectivo en el siguiente arranque de POPFile
Configuration_POPFork                   Permitir conexiones concurrentes POP3
Configuration_SMTPFork                  Permitir conexiones concurrentes SMTP
Configuration_NNTPFork                  Permitir conexiones concurrentes NNTP
Configuration_POP3Separator             POP3 host:puerto:usuario caracter separador
Configuration_NNTPSeparator             NNTP host:puerto:usuario caracter separador
Configuration_POP3SepUpdate             Separador POP3 actualizado a %s
Configuration_NNTPSepUpdate             Separador NNTP actualizado a %s
Configuration_UI                        Puerto web del interface de Usuario
Configuration_UIUpdate                  El puerto web del interface de usuario ha sido actualizado a %s ; este cambio será efectivo en el siguiente reinicio de POPFile
Configuration_History                   Número de correos por página
Configuration_HistoryUpdate             Nº de correos por página actualizado a %s
Configuration_Days                      Nº de dias que se guarda el historial
Configuration_DaysUpdate                Actualizado el número de días en historial a %s
Configuration_UserInterface             Interface de Usuario
Configuration_Skins                     Apariencias
Configuration_SkinsChoose               Elegir una apariencia
Configuration_Language                  Lenguaje
Configuration_LanguageChoose            Elegir lenguaje
Configuration_ListenPorts               Puertos de escucha
Configuration_HistoryView               Vista de Historial
Configuration_TCPTimeout                Temporización de la conexión TCP
Configuration_TCPTimeoutSecs            Temporización en segundos
Configuration_TCPTimeoutUpdate          Temporización de la conexión TCP establecida en %s
Configuration_ClassificationInsertion   Inserción de texto en E-Mail
Configuration_SubjectLine               Modificar la línea de<br>asunto
Configuration_XTCInsertion              Insertar la<br>cabecera X-Text-Classification
Configuration_XPLInsertion              Insertar la <br>cabecera X-POPFile-Link
Configuration_Logging                   Registro
Configuration_None                      Nada
Configuration_ToScreen                  A Pantalla
Configuration_ToFile                    A Fichero
Configuration_ToScreenFile              A Pantalla y Fichero
Configuration_LoggerOutput              Salida
Configuration_GeneralSkins              Apariencias
Configuration_SmallSkins                Apariencias pequeñas
Configuration_TinySkins                 Apariencias enanas
Configuration_CurrentLogFile            &lt;arch. de registro actual&gt;

Advanced_Error1                         '%s' ya está en la lista de palabras ignoradas
Advanced_Error2                         Las palabras ignoradas solo pueden contener caracteres alfanuméricos, ., _, -, ó @
Advanced_Error3                         '%s' añadida a la lista de palabras ignoradas
Advanced_Error4                         '%s' no está en la lista de palabras ignoradas
Advanced_Error5                         '%s' quitada de la lista de palabras ignoradas
Advanced_StopWords                      Palabras Ignoradas
Advanced_Message1                       POPFile ignora las siguientes palabras de uso frecuente:
Advanced_AddWord                        Añadir palabra
Advanced_RemoveWord                     Quitar palabra
Advanced_AllParameters                  Todos los Parametros de POPFile
Advanced_Parameter                      Parametro
Advanced_Value                          Valor
Advanced_Warning                        Esta es la lista completa de los parametros de POPFile.  Solo para usuarios avanzados: puedes cambiar cualquiera y pinchar en Actualizar; no hay comprobacion para validarlos.

History_Filter                          &nbsp;(mostrando sólo la categoría <font color="%s">%s</font>)
History_FilterBy                        Filtrar Por
History_Search                          &nbsp;(buscando en de/asunto %s)
History_Title                           Mensajes Recientes
History_Jump                            Ir al mensaje
History_ShowAll                         Mostrar Todo
History_ShouldBe                        Debería ser
History_NoFrom                          sin línea de
History_NoSubject                       sin línea de asunto
History_ClassifyAs                      Clasificar como
History_MagnetUsed                      Imán utilizado
History_MagnetBecause                   <b>Iman usado</b><p>Clasificado a <font color="%s">%s</font> por el iman %s </p>
History_ChangedTo                       Cambiado a <font color="%s">%s
History_Already                         Anteriormente clasificado como <font color="%s">%s</font>
History_RemoveAll                       Quitar Todo
History_RemovePage                      Quitar Página
History_Remove                          Para borrar las entradas en el historial clic
History_SearchMessage                   Buscar De/Asunto
History_NoMessages                      Sin mensajes
History_ShowMagnet                      magnetizado
History_ShowNoMagnet                    desmagnetizado
History_Magnet                          &nbsp;(mostrando solo mensajes clasificados por imán)
History_NoMagnet                        &nbsp;(Mostrando sólo mensajes no-clasificados magnéticamente)
History_ResetSearch                     Reiniciar

Password_Title                          Contraseña
Password_Enter                          Escriba contraseña
Password_Go                             ¡Venga!
Password_Error1                         Contraseña incorrecta

Security_Error1                         El puerto seguro tiene que ser un nº entre 1 y 65535
Security_Stealth                        Modo Oculto/Operación del Servidor
Security_NoStealthMode                  No (Modo Oculto)
Security_ExplainStats                   Con esto activado POPFile envia una vez al día los tres valores siguientes a un script en getpopfile.org: <b>bc</b> (el nº de categorías que tienes), <b>mc</b> (el nº total de mensajes que ha clasificado POPFile) y <b>ec</b> (el nº total de errores de clasificación).  Estos se guardan en un archivo que yo utilizaré para publicar algunas estadísticas acerca de cómo usa la gente POPFile y cómo de bien les funciona.  Mi servidor web mantiene sus archivos log unos 5 días y luego se borran; Yo no guardo ninguna relación entre las estadísticas y sus direcciones IP individuales.
Security_ExplainUpdate                  Con esto activado POPFile envia una vez al día los tres valores siguientes a un script en getpopfile.org: <b>ma</b> (el nº de versión de tu POPFile), <b>mi</b> (el nº de revisión de tu POPFile) y <b>bn</b> (el nº de compilación de tu POPFile).  Si existe una nueva versión, POPFile recibe una respuesta en forma de gráfico que se muestra en la parte superior de la página.  Mi servidor web mantiene sus archivos log unos 5 días y luego se borran; Yo no guardo ninguna relación entre las comprobaciones de actualización y sus direcciones IP individuales.
Security_PasswordTitle                  Contraseña del Interface de Usuario
Security_Password                       Contraseña
Security_PasswordUpdate                 Contraseña actualizada
Security_AUTHTitle                      Autentificación por Contraseña Segura/AUTH
Security_SecureServer                   Servidor seguro
Security_SecureServerUpdate             Actualizado el servidor seguro a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SecurePort                     Puerto seguro
Security_SecurePortUpdate               Puerto actualizado a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SMTPServer                     servidor chain SMTP
Security_SMTPServerUpdate               Actualizado el servidor chain SMTP a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_SMTPPort                       Puerto chain SMTP
Security_SMTPPortUpdate                 Actualizado elpuerto chain SMTP a %s; este cambio será efectivo en el siguiente reinicio de POPFile
Security_POP3                           Aceptar conexiones POP3 desde máquinas remotas (necesita reiniciar POPFile)
Security_SMTP                           Aceptar conexiones SMTP desde máquinas remotas (necesita reiniciar POPFile)
Security_NNTP                           Aceptar conexiones NNTP desde máquinas remotas (necesita reiniciar POPFile)
Security_UI                             Aceptar conexiones HTTP (Interface del Usuario) desde máquinas remotas (necesita reiniciar POPFile)
Security_XMLRPC                         Aceptar conexiones XML-RPC desde máquinas remotas (necesita reiniciar POPFile)
Security_UpdateTitle                    Comprobación automática de actualización
Security_Update                         Buscar actualizaciones POPFile a diario
Security_StatsTitle                     Enviar Estadísticas
Security_Stats                          Enviar estadísticas diariamente

Magnet_Error1                           El imán '%s' ya existía en la categoría '%s'
Magnet_Error2                           El nuevo imán '%s' interfiere con el imán '%s' de la categoría '%s' y puede dar lugar a resultados ambiguos.  No se ha añadido el nuevo.
Magnet_Error3                           Crear imán nuevo '%s' en la categoría '%s'
Magnet_CurrentMagnets                   Imanes Actuales
Magnet_Message1                         Los siguientes imanes hacen que el correo sea clasificado siempre en la categoría especificada.
Magnet_CreateNew                        Crear Imán Nuevo
Magnet_Explanation                      Hay tres tipos de imanes disponibles: <ul><li><b>Dirección de procedencia o nombre del remitente:</b> Por ejemplo:<br /> <i>felipe@company.com</i> para capturar esta dirección específica, <br /><i>company.com</i> para capturar a cualquiera que envíe desde <i>company.com</i>, <br /><i>Felipe Martinez</i> para capturar esa persona específica,<br /> <i>Felipe</i> para capturar a todos los Felipes</li><li><b>Dirección <i>Para:</i> o nombre del destinatario:</b> Como un imán De: pero con la dirección <i>Para:</i> en un correo</li> <li><b>Palabras en el Asunto:</b> Por ejem.: <i>hola</i> para capturar todos los mensajes con <i>hola</i> en el asunto</li></ul>
Magnet_MagnetType                       Tipo de Imán
Magnet_Value                            Valor
Magnet_Always                           Ir siempre a categoría
Magnet_Jump                             Ir a la página iman

Bucket_Error1                           Los nombres de categoría sólo pueden contener las letras de la "a" a la "z" en minusculas, - y _
Bucket_Error2                           Ya existe la categoría %s
Bucket_Error3                           Categoría %s creada
Bucket_Error4                           Ponga por favor una palabra no-vacía
Bucket_Error5                           Categoría %s renombrada a %s
Bucket_Error6                           Categoría %s borrada
Bucket_Title                            Configuracion de la Categoria
Bucket_BucketName                       Nombre de<br>Categoría
Bucket_WordCount                        Contador de Palabras
Bucket_WordCounts                       Nº de palabras
Bucket_UniqueWords                      Palabras<br>únicas
Bucket_SubjectModification              Modificación del<br>asunto
Bucket_ChangeColor                      Cambiar<br>Color
Bucket_NotEnoughData                    No hay bastantes datos
Bucket_ClassificationAccuracy           Exactitud de la Clasificación
Bucket_EmailsClassified                 correos clasificados
Bucket_EmailsClassifiedUpper            Correos Clasificados
Bucket_ClassificationErrors             Errores de clasificación
Bucket_Accuracy                         Exactitud
Bucket_ClassificationCount              Contador de Clasificación
Bucket_ClassificationFP                 Falsos Positivos
Bucket_ClassificationFN                 Falsos Negativos
Bucket_ResetStatistics                  Reiniciar Estadísticas
Bucket_LastReset                        Ultimo Reinicio
Bucket_CurrentColor                     El color actual de %s es %s
Bucket_SetColorTo                       Cambiar el color de %s a %s
Bucket_Maintenance                      Mantenimiento
Bucket_CreateBucket                     Nombre de categoría
Bucket_DeleteBucket                     Borrar categoría
Bucket_RenameBucket                     Renombrar categoría
Bucket_Lookup                           Búsqueda
Bucket_LookupMessage                    Buscar palabra en categorías
Bucket_LookupMessage2                   Buscar en resultados por
Bucket_LookupMostLikely                 <b>%s</b> en su mayoría aparece en <font color="%s">%s</font>
Bucket_DoesNotAppear                    <p><b>%s</b> no aparece en ninguna de las categorías
Bucket_DisabledGlobally                 Desactivado globalmente
Bucket_To                               a
Bucket_Quarantine                       Mensaje en<br>Cuarentena

SingleBucket_Title                      Detalle de %s
SingleBucket_WordCount                  Categoría nº de palabras
SingleBucket_TotalWordCount             Nº total de palabras
SingleBucket_Percentage                 Porcentaje del total
SingleBucket_WordTable                  Palabra Table for %s
SingleBucket_Message1                   Las palabras con estrellas (*) se han usado para clasificar en esta sesión de POPFile.  Clic en cualquier palabra para buscar su probabilidad para todos las categorías.
SingleBucket_Unique                     %s único
SingleBucket_ClearBucket                Borrar Todas las Palabras

Session_Title                           Terminada la Sesión POPFile
Session_Error                           Ha expirado tu sesión en POPFile, y puede ser debido a arrancar y parar POPFile dejando tu navegador abierto.  Por favor, pincha uno de los enlaces de arriba para seguir con POPFile.

View_Title                              Vista de un solo mensaje
View_ShowFrequencies                    Mostrar la frecuencia de las palabras
View_ShowProbabilities                  Mostrar las probabilidades de las palabras
View_ShowScores                         Mostrar las puntuaciones de las palabras
View_WordMatrix                         Matriz de palabras
View_WordProbabilities                  mostrando probabilidades de la palabra
View_WordFrequencies                    mostrando frecuencia de la palabra
View_WordScores                         mostrando puntuaciones de la palabra

Windows_TrayIcon                        Mostrar el icono de POPFile en la bandeja del sistema?
Windows_Console                         Hacer funcionar POPFile en una ventana de comandos?
Windows_NextTime                        <p><font color="red">Este cambio sera efectivo la proxima vez que arranques POPFile</font>

Header_MenuSummary                      Esta tabla es el menú de navegación que le permite acceder a cada una de las páginas del centro de control.
History_MainTableSummary                Esta tabla muestra el remitente y asunto de los mensajes recibidos recientemente y permite que sean revisados y reclasificados.  Pinchando en la línea de asunto se mostrará el texto completo del mensaje, junto con información acerca del porqué se clasificó así.  La columna 'Debería ser' le permite especificar a qué categoría pertenece el mensaje, o deshacer el cambio.  La columna 'Borrar' le permite borrar mensajes específicos del historial si usted ya no los necesita.
History_OpenMessageSummary              Esta tabla contiene el texto completo de un mensaje de correo, enfatizando las palabras que se han utilizado para clasificarlos acorde con la categoría que era más relevante para cada una.
Bucket_MainTableSummary                 Esta tabla proporciona una visión global de las categorías de clasificación.  Cada fila muestra el nombre de la categoría, el nº total de palabras de esta categoría, el nº actual de palabras unicas en cada categoría, si el asunto del correo se modificará al clasificarlo es esa categoría, si pondrá en cuarentena los mensajes recibidos en esa categoría, y una tabla de la que escoger el color con el que se visualizará en el centro de control lo relacionado con esa categoría.
Bucket_StatisticsTableSummary           Esta tabla proporciona tres conjuntos de estadísticas sobre el comportamiento global de POPFile.  El 1º es sobre lo acertada des su clasificación, el 2º es cuántos correos se han clasificado, y en qué categorías, y el 3º es cuántas palabras hay en cada categoría, y cuáles son sus porcentajes relativos.
Bucket_MaintenanceTableSummary          Esta tabla confiene formularios que te permiten crear, borrar o renombrar categorías, y buscar palabras en todas las categorías para ver sus probabilidades relativas.
Bucket_AccuracyChartSummary             Esta tabla representa gráficamente la exactitud de la clasificación de correo.
Bucket_BarChartSummary                  Esta tabla representa gráficamente un distribución percentual de cada una de las diferentes categorías.  Esto se necesita para al nº de correos clasificados, y el conteo total de palabras.
Bucket_LookupResultsSummary             Esta tabla muestra las probabilidades asociadas con una palabra dada en el corpus.  Para cada categoría, muestra la frecuencia con que se encuentra esa palabra, la probabilidad de que vuelava a encontrarse en esa categoría, y el efecto en general sobre la puntuación de la categoría si esa palabra existe en un correo.
Bucket_WordListTableSummary             Esta tabla proporciona un listado de todas las palabras de una categoría en particular, ordenadas por la primera letra común de cada fila.
Magnet_MainTableSummary                 Esta tabla muestra la lista de imanes que se han usado para autoclasificar el correo de acuerdo a reglas fijas.  Cada fila muestra cómo está definido el imán, para qué categoría se ha ideado, y un botón para borrar el imán.
Configuration_MainTableSummary          Esta tabla contiene los formularios que te permitirán controlar la configuración de POPFile.
Configuration_InsertionTableSummary     Esta tabla contiene botones que determinan cuando se harán o no, ciertas modificaciones a la cabecera o al título del correo antes de enviarlo al cliente de correo.
Security_MainTableSummary               Esta tabla proporciona grupos de controles que afectan a la seguridad de la configuración global de POPFile, si tiene que comprobar automáticamente la existencia de actualizaciones del programa, y si las estadísticas sobre el comportamiento de POPFile tienen que enviarse al almacén de datos centralizado del autor del programa (para obtener información general).
Advanced_MainTableSummary               Esta tabla proporciona un listado de palabras que POPFile ignora cuando clasifica correos debido a su frecuencia relativa en todos ellos.  Están ordenadas por filas de acuerdo con la primera letra de las palabras.


# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
WikiLink index.php
FAQLink FAQ
RequestFeatureLink RequestFeature
MailingListLink mailing_lists
DonateLink Donate
NavCorpus Corpus
NavHistory Historial
NavIMAP IMAP
NavMagnets Imanes
NavSettings Configuración
NavStatus Estado
NavWordView Palabras
Corpus_BucketList Categorías
Corpus_Color Color
Corpus_Actions Acciones
Corpus_Clear Vaciar
Corpus_Search Buscar
Corpus_StopwordsTitle Palabras vacías
Corpus_StopwordsDesc Las palabras de esta lista nunca se usan para la clasificación.
Corpus_RemoveStopword Eliminar
Corpus_StopwordCandidates Candidatas a palabras vacías
Corpus_StopwordCandidatesDesc Palabras que aparecen uniformemente en todas las categorías — escaso poder discriminativo.
Corpus_StopwordRatio Umbral de ratio máx/mín
Corpus_LoadCandidates Buscar candidatas
Corpus_NoCandidates No se encontraron candidatas con este umbral.
Corpus_AddStopword Añadir a palabras vacías
Corpus_WordsLink Palabras →
BucketSelect_AddNew Añadir nueva...
BucketSelect_AlreadyExists Ya existe
BucketSelect_CreateError Error al crear la categoría
BucketSelect_InvalidName Solo a-z, 0-9, - y _
BucketSelect_NameRequired Nombre requerido
Bucket_InIgnoredWords <b>%s</b> está en las palabras ignoradas. POPFile ignora esta palabra
History_AllBuckets Todas las categorías
History_HighlightWords Resaltar palabras por categoría
History_Loading Cargando...
History_MoveTo — mover a —
History_Moving Moviendo...
History_NoMatchingMessages No hay mensajes coincidentes
History_Reclassifying Reclasificando...
History_ReclassifyUnclassified Reclasificar no clasificados
History_Selected seleccionado(s)
Imap_BucketFolderMappings Categoría -> Asignaciones de carpetas
Imap_Connected Conectado
Imap_Connection Conexión
Imap_ConnectionFailed Error de conexión
Imap_Description Supervisar carpetas IMAP y clasificar automáticamente los mensajes entrantes.
Imap_EnableService Activar servicio IMAP
Imap_FetchFolders Obtener carpetas
Imap_Fetching Obteniendo...
Imap_IMAFFolder Carpeta IMAP
Imap_MappingsHint Los mensajes clasificados se mueven a la carpeta IMAP especificada. Deje las categorías sin asignar vacías para omitir el movimiento.
Imap_NoFoldersWatched Aún no se supervisa ninguna carpeta.
Imap_NoMappings No hay asignaciones definidas.
Imap_SaveAnyway Guardar de todos modos
Imap_SaveConnection Guardar conexión
Imap_SaveFolders Guardar carpetas
Imap_Saving Guardando...
Imap_Service Servicio
Imap_TestConnection Probar conexión
Imap_Testing Probando...
Imap_TrainingHint El modo de entrenamiento analiza las carpetas de archivo existentes y entrena al clasificador con su contenido. El indicador se restablece automáticamente cuando finaliza el entrenamiento.
Imap_Train                              Train
Imap_TrainAll                           Train all buckets
Imap_TrainQueued                        Training queued
Imap_TrainingMode Modo de entrenamiento
Imap_TrainingLimit Mensajes por carpeta (0 = ilimitado)
Imap_WatchedFolders Carpetas supervisadas
Imap_WatchedHint POPFile supervisa estas carpetas IMAP para nuevos mensajes a clasificar.
Magnet_Created Imán creado
Magnet_Deleted Imán eliminado
Reconnect_Connecting Conectando...
Reconnect_Message El backend no es accesible. Intentando reconectar...
Reconnect_Now Reconectar ahora
Reconnect_RetryIn Reintentando en
Reconnect_Title Conexión perdida
Settings_AdminPassword Contraseña de administrador
Settings_ArchiveDirectory Directorio de archivo
Settings_ArchiveMessages Archivar mensajes
Settings_ArchiveSubdirs Subdirectorios de archivo
Settings_AutoDetect Detección automática
Settings_AutoDetectLanguage Detectar idioma automáticamente
Settings_ChainPort Puerto en cadena
Settings_ChainServer Servidor en cadena
Settings_DateFormat Formato de fecha
Settings_DescAdminPassword Dejar vacío para deshabilitar la protección por contraseña.
Settings_DescArchiveDir Directorio para mensajes archivados (relativo al directorio de usuario).
Settings_DescArchiveMessages Guardar una copia de cada mensaje clasificado en disco.
Settings_DescArchiveSubdirs Dividir el archivo en N subdirectorios (0 = deshabilitado).
Settings_DescAutoDetectLang Detecta el idioma de cada mensaje y aplica las palabras vacías y el stemmer correspondientes. Añade ~130% de latencia de clasificación; útil para buzones con varios idiomas.
Settings_DescChainPort Puerto del servidor SMTP aguas arriba.
Settings_DescChainServer Nombre de host del servidor SMTP aguas arriba.
Settings_DescDateFormat Cadena de formato strftime. Dejar vacío para el predeterminado del locale.
Settings_DescForceFork Crear un nuevo proceso para cada conexión.
Settings_DescHEADFetchesBody Obtener el artículo completo con el comando HEAD.
Settings_DescHTTPPort Puerto en el que escucha la interfaz web. Requiere reinicio.
Settings_DescItemsPerPage Filas mostradas por página en Historial e Imanes.
Settings_DescLanguage Idioma de visualización de la interfaz. Dejar vacío para detección automática desde el navegador.
Settings_DescListenAddress Dirección IP a la que enlazarse. Vacío = todas las interfaces.
Settings_DescLocalOnly_UI Restringir la interfaz web a conexiones locales.
Settings_DescLogDirectory Directorio para archivos de registro. Vacío = raíz de POPFile.
Settings_DescLogLevel Verbosidad de la salida del registro.
Settings_DescLogSQLToStdout Imprimir cada sentencia SQL con valores enlazados en stdout. Solo activo cuando "Registrar en stdout" también está habilitado.
Settings_DescLogToStdout Reflejar la salida del registro en stdout además del archivo de registro.
Settings_DescMessageCutoff Máximo de palabras analizadas por mensaje (0 = ilimitado).
Settings_DescNNTPLocalOnly Solo aceptar conexiones NNTP desde localhost.
Settings_DescNNTPPort Puerto en el que POPFile escucha para NNTP (predeterminado 119).
Settings_DescNNTPSeparator Carácter que separa el usuario del servidor.
Settings_DescPOP3LocalOnly Solo aceptar conexiones POP3 desde localhost.
Settings_DescPOP3Port Puerto en el que POPFile escucha para POP3 (predeterminado 1110).
Settings_DescPOP3Separator Carácter que separa el usuario del servidor (p.ej. usuario:mailhost).
Settings_DescRetentionDays Cuántos días se conserva el historial de mensajes.
Settings_DescSessionDividers Mostrar separadores entre sesiones de navegación en el Historial.
Settings_DescSMTPLocalOnly Solo aceptar conexiones SMTP desde localhost.
Settings_DescSMTPPort Puerto en el que POPFile escucha para SMTP (predeterminado 25).
Settings_DescSQLiteJournal Modo de diario SQLite / WAL.
Settings_DescSQLiteTweaks Máscara de bits: 1 = escrituras más rápidas (menos seguro), 2 = copia de seguridad periódica.
Settings_DescSSLChainPort Puerto del servidor SSL POP3 aguas arriba.
Settings_DescSSLChainServer Nombre de host del servidor SSL POP3 aguas arriba para encadenamiento SSL.
Settings_DescSubjectTagLeft Prefijo insertado en el encabezado Asunto, p.ej. [SPAM].
Settings_DescSubjectTagRight Sufijo añadido al encabezado Asunto.
Settings_DescTagPosition Dónde colocar la etiqueta del asunto.
Settings_DescTOPFetchesBody Obtener también el cuerpo del mensaje con el comando TOP.
Settings_DescUnclassifiedWeight Umbral de probabilidad por debajo del cual el correo está "sin clasificar".
Settings_DescWordStemming Reducir palabras a su raíz antes de la clasificación (p.ej. "corriendo" a "corr"). Mejora la recuperación para idiomas morfológicamente ricos con ~10% de coste de latencia.
Settings_DescWordTable Qué mostrar en la tabla de probabilidad de palabras.
Settings_ErrorSaving Error al guardar
Settings_ForceFork Force Fork
Settings_HEADFetchesBody HEAD obtiene el cuerpo
Settings_HTTPPort Puerto HTTP
Settings_ItemsPerPage Elementos por página
Settings_ListenAddress Dirección de escucha
Settings_ListenPort Puerto de escucha
Settings_LocalOnly Solo local
Settings_LogDirectory Directorio de registro
Settings_LogLevel Nivel de registro
Settings_LogSQLToStdout Registrar SQL en stdout
Settings_LogToStdout Registrar en stdout
Settings_MessageCutoff Límite de mensaje
Settings_OptDebug Depuración
Settings_OptEnd Final
Settings_OptErrorsOnly Solo errores
Settings_OptFrequencies Frecuencias
Settings_OptFront Frente
Settings_OptHidden Oculto
Settings_OptInfo Info
Settings_OptLogScores Registrar puntuaciones
Settings_OptProbabilities Probabilidades
Settings_OptWarnings Advertencias
Settings_RetentionDays Retención (días)
Settings_SaveChanges Guardar cambios
Settings_Saved Guardado
Settings_Saving Guardando...
Settings_Search Buscar configuración...
Settings_SectionClassifier Clasificador
Settings_SectionHistory Historial
Settings_SectionLogging Registro
Settings_SectionNNTP Proxy NNTP
Settings_SectionPOP3 Proxy POP3
Settings_SectionSecurity Seguridad
Settings_SectionSMTP Proxy SMTP
Settings_SectionUI Interfaz de usuario
Settings_ServerSeparator Separador de servidor
Settings_SessionDividers Separadores de sesión
Settings_SQLiteJournalMode Modo de diario SQLite
Settings_SQLiteTweaks Ajustes de SQLite
Settings_SSLChainPort Puerto SSL en cadena
Settings_SSLChainServer Servidor SSL en cadena
Settings_SubjectTagLeft Etiqueta asunto izquierda
Settings_SubjectTagRight Etiqueta asunto derecha
Settings_TagPosition Posición de etiqueta
Settings_TOPFetchesBody TOP obtiene el cuerpo
Settings_UnclassifiedWeight Peso sin clasificar
Settings_WordStemming Lematización de palabras
Settings_WordTable Tabla de palabras
Status_Checking Comprobando...
Status_Description Comprobaciones de estado para los servicios de POPFile.
Status_LoadError Error al cargar el estado
Status_NoChecks No hay comprobaciones disponibles.
View_MessageBody Cuerpo del mensaje
View_MessageHeader Encabezado del mensaje

Advanced_ConfigFile Archivo de configuración:
ApplyChanges Aplicar cambios
Arrived Recibido
Configuration_Error10 El puerto de escucha POP3 no puede tener el mismo valor que el puerto de la interfaz de usuario
Configuration_Error8 El puerto del proxy SOCKS V debe ser un número entre 1 y 65535
Configuration_Error9 El puerto de la interfaz de usuario no puede tener el mismo valor que el puerto de escucha POP3
Configuration_Fields Columnas del historial
Configuration_SOCKSPort Puerto del proxy SOCKS V
Configuration_SOCKSPortUpdate Puerto del proxy SOCKS V actualizado a %s
Configuration_SOCKSServer Host del proxy SOCKS V
Configuration_SOCKSServerUpdate Host del proxy SOCKS V actualizado a %s
Date Fecha
FAQ FAQ
Footer_Wiki Documentación
Help_Bucket_Setup POPFile requiere al menos dos categorías además de la pseudocategoría "sin clasificar". Lo que hace único a POPFile es que puede clasificar el correo en más de eso; puede tener cualquier número de categorías. Una configuración simple sería una categoría "spam", "personal" y "trabajo".
Help_No_More No mostrar esto de nuevo
Help_Training Cuando use POPFile por primera vez, no sabe nada y necesitará entrenamiento. POPFile requiere entrenamiento con mensajes para cada categoría; el entrenamiento ocurre cuando reclasifica un mensaje que POPFile clasificó incorrectamente a la categoría correcta. Antes de que POPFile clasifique el primer mensaje, deberá haber reclasificado mensajes a al menos dos categorías.
History_Automatic Automático
History_ChangedClass Ahora clasificaría como
History_Column_Characters Cambiar el ancho de las columnas De, Para, Cc y Asunto
History_Decrease Reducir
History_Increase Aumentar
History_Negate_Search Invertir búsqueda/filtro
History_Purge Caducar ahora
History_Reclassified Reclasificado
History_RemoveChecked Eliminar seleccionados
History_Size_Bytes %d&nbsp;B
History_Size_KiloBytes %.1f&nbsp;KB
History_Size_MegaBytes %.1f&nbsp;MB
ID ID
Imap_Bucket2Folder El correo de la categoría '<b>%s</b>' va a la carpeta
Imap_Bytelimit Bytes por mensaje para usar en la clasificación. Introducir 0 para el mensaje completo:
Imap_BytelimitError Por favor, introduzca un número.
Imap_Expunge Eliminar mensajes borrados de las carpetas supervisadas.
Imap_Interval Intervalo de actualización en segundos:
Imap_IntervalError Por favor, introduzca un intervalo entre 10 y 3600 segundos.
Imap_Login Nombre de usuario IMAP:
Imap_LoginError ¡Por favor, introduzca un nombre de usuario!
Imap_MapError ¡No puede asignar más de una categoría a una sola carpeta!
Imap_NoConnectionMessage Por favor, configure primero los detalles de conexión. Después habrá más opciones disponibles en esta página.
Imap_Now ¡ahora!
Imap_Password Contraseña para la cuenta IMAP:
Imap_PasswordError ¡Por favor, introduzca una contraseña para el servidor!
Imap_Port Puerto del servidor IMAP:
Imap_PortError ¡Por favor, introduzca un número de puerto válido!
Imap_RefreshFolders Actualizar lista de carpetas
Imap_Server Nombre de host del servidor IMAP:
Imap_ServerNameError ¡Por favor, introduzca el nombre de host del servidor!
Imap_UpdateError1 No se pudo iniciar sesión. Verifique su nombre de usuario y contraseña.
Imap_UpdateError2 Error al conectar con el servidor. Verifique el nombre de host y el puerto y asegúrese de estar en línea.
Imap_UpdateError3 Por favor, configure primero los detalles de conexión.
Imap_Use_SSL Usar SSL
Imap_WatchedFolder Carpeta supervisada nº
Imap_WatchMore una carpeta a la lista de carpetas supervisadas

WordView_Title Precisión de palabras
WordView_SelectBucket seleccionar categoría
WordView_Words palabras
WordView_Loading Cargando...
WordView_Empty No hay palabras en esta categoría.
WordView_ColWord Palabra
WordView_ColCount Recuento
WordView_ColTotal Total
WordView_ColAccuracy Precisión
WordView_ColActions Acciones
WordView_Remove Eliminar
WordView_MoveTo mover a
WordView_Move Mover
Locale_Date %a %R | %D %R
Locale_Decimal ,
Locale_Thousands .
Security_StealthMode (Modo sigiloso)
Shutdown_Message POPFile se ha cerrado
Size Tamaño
View_Chart Gráfico de decisión
View_DownloadMessage Descargar mensaje

Language_Name                           Español
