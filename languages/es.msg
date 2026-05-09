# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming and contributors
# Copyright (C) 2026 Jan Limpens

# Identify the language and character set used for the interface
LanguageCharset                         ISO-8859-1
LanguageDirection                       ltr

# This is used to get the appropriate subdirectory for the manual
ManualLanguage                          es

# Common words that are used on their own all over the interface
Apply                                   Aplicar
Add                                     Añadir
Remove                                  Quitar
Previous                                Previa
Next                                    Seguir
From                                    De
Subject                                 Asunto
Reclassify                              Reclasificar
Undo                                    Deshacer
Close                                   Cerrar
Bucket                                  Categoría
Magnet                                  Imán
Delete                                  Borrar
Create                                  Crear
Total                                   Total
Rename                                  Renombrar
Update                                  Actualizar
Refresh                                 Refrescar

# The header and footer that appear on every UI page

Configuration_Language                  Lenguaje

History_SearchMessage                   Buscar De/Asunto
History_ShowNoMagnet                    desmagnetizado

Magnet_CurrentMagnets                   Imanes Actuales
Magnet_CreateNew                        Crear Imán Nuevo

Bucket_CreateBucket                     Nombre de categoría
Bucket_RenameBucket                     Renombrar categoría

# New keys added (translations batch 1)
LanguageCharset ISO-8859-1
LanguageDirection ltr
NavCorpus Corpus
NavHistory Historial
NavIMAP IMAP
NavMagnets Imanes
NavStatus Estado
NavWordView Palabras
Corpus_BucketList Categorías
Corpus_Color Color
Corpus_Actions Acciones
Corpus_Clear Vaciar
Corpus_StopwordsTitle Palabras vacías
Corpus_StopwordsDesc Las palabras de esta lista nunca se usan para la clasificación.
Corpus_RemoveStopword Eliminar
Corpus_StopwordCandidates Candidatas a palabras vacías
Corpus_StopwordCandidatesDesc Palabras que aparecen uniformemente en todas las categorías — escaso poder discriminativo.
Corpus_StopwordRatio Umbral de ratio máx/mín
Corpus_LoadCandidates Buscar candidatas
Corpus_NoCandidates No se encontraron candidatas con este umbral.
Corpus_AddStopword Añadir a palabras vacías
BucketSelect_AddNew Añadir nueva...
BucketSelect_AlreadyExists Ya existe
BucketSelect_CreateError Error al crear la categoría
BucketSelect_InvalidName Solo a-z, 0-9, - y _
BucketSelect_NameRequired Nombre requerido
History_AllBuckets Todas las categorías
History_HighlightWords Resaltar palabras por categoría
History_Loading Cargando...
History_MoveTo — mover a —
History_Moving Moviendo...
History_Reclassifying Reclasificando...
History_ReclassifyUnclassified Reclasificar no clasificados
History_Selected seleccionado(s)
Imap_BucketFolderMappings Categoría -> Asignaciones de carpetas
Imap_Connected Conectado
Imap_Connection Conexión
Imap_ConnectionFailed Error de conexión
Imap_Description Supervisar carpetas IMAP y clasificar automáticamente los mensajes entrantes.
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

Date Fecha
Imap_Expunge Eliminar mensajes borrados de las carpetas supervisadas.
Imap_Interval Intervalo de actualización en segundos:
Imap_Login Nombre de usuario IMAP:
Imap_NoConnectionMessage Por favor, configure primero los detalles de conexión. Después habrá más opciones disponibles en esta página.
Imap_Password Contraseña para la cuenta IMAP:
Imap_Port Puerto del servidor IMAP:
Imap_Server Nombre de host del servidor IMAP:
Imap_Use_SSL Usar SSL

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

Language_Name                           Español
History_PerPage                          Entradas por página
Imap_Advanced                            Avanzado
Imap_Cancel                              Cancelar
Imap_Wizard                              Asistente de configuración
Imap_WizardApply                         Crear y mapear
Imap_WizardClose                         Cerrar
Imap_WizardDesc                          Seleccione carpetas para crear buckets y mapeos.
Imap_WizardDeselectAll                   Deseleccionar todo
Imap_WizardDone                          {count} bucket(s) creados y mapeados.
Imap_WizardEmpty                         No se encontraron carpetas adicionales en el servidor.
Imap_WizardSelectAll                     Seleccionar todo
Imap_WizardTrain                         Entrenar ahora
NavWordSearch                            Búsqueda de palabras
Settings_DescEnableProxy                 Iniciar este proxy al arrancar POPFile.
Settings_DescLogFormat                   Formato de salida del registro (default, tabbed, csv, plain).
Settings_DescOpenBrowser                 Abrir automáticamente el navegador al iniciar.
Settings_DescSQLiteBackup                Respaldar automáticamente la base de datos antes de cambios de esquema.
Settings_DescSQLiteFastWrites            Desactivar sincronización de base de datos (más rápido, menos seguro).
Settings_EnableService                   Activar servicio
Settings_LogFormat                       Formato de registro
Settings_OpenBrowser                     Abrir navegador
Settings_SQLiteBackup                    Copia de seguridad SQLite
Settings_SQLiteFastWrites                Escritura rápida SQLite
Settings_SectionIMAP                     IMAP
WordSearch_AddStopword                   Añadir palabra vacía
WordSearch_ColumnBuckets                 Buckets
WordSearch_ColumnWord                    Palabra
WordSearch_IsStopword                    Palabra vacía
WordSearch_Loading                       Cargando...
WordSearch_NoResults                     Sin resultados.
WordSearch_NoStopwords                   Sin palabras vacías.
WordSearch_Placeholder                   Introduzca una palabra...
WordSearch_RemoveStopword                Eliminar palabra vacía
WordSearch_Search                        Buscar
WordSearch_StopwordList                  Lista de palabras vacías
WordSearch_Title                         Búsqueda de palabras
WordSearch_Total                         Total
