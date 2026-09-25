unit Trysil.Languages.IT;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.JSon.Consts,
  Trysil.Http.Log.Consts,
  Trysil.Http.Consts,
  Trysil.Consts;

type

{ TTLanguageIT }

  TTLanguageIT = class
  public
    class procedure Translate;
  end;

implementation

{ TTLanguageIT }

class procedure TTLanguageIT.Translate;
begin
  TTLanguage.Instance.Add(SNotValidEventClass, 'Costruttore non valido nella classe TTEvent: %0:s.');
  TTLanguage.Instance.Add(SNotEventType, 'Tipo TTEvent non valido: %0:s.');
  TTLanguage.Instance.Add(SInvalidRttiObjectType, 'Il tipo TRttiObject non è valido.');
  TTLanguage.Instance.Add(SDuplicateTableAttribute, 'Attributo TTable duplicato.');
  TTLanguage.Instance.Add(SDuplicateSequenceAttribute, 'Attributo TSequence duplicato.');
  TTLanguage.Instance.Add(SDuplicateWhereClauseAttribute, 'Attributo TWhereClause duplicato.');
  TTLanguage.Instance.Add(SDuplicatePrimaryKeyAttribute, 'Attributo TPrimaryKey duplicato.');
  TTLanguage.Instance.Add(SDuplicateVersionColumnAttribute, 'Attributo TVersionColumn duplicato.');
  TTLanguage.Instance.Add(SDuplicateChangedAtAttribute, 'Attributo "At" di change tracking duplicato: %0:s.');
  TTLanguage.Instance.Add(SDuplicateChangedByAttribute, 'Attributo "By" di change tracking duplicato: %0:s.');
  TTLanguage.Instance.Add(SInvalidChangedAtType, 'L''attributo "At" di change tracking richiede un campo TTNullable<TDateTime>: %0:s.');
  TTLanguage.Instance.Add(SInvalidChangedByType, 'L''attributo "By" di change tracking richiede un campo String: %0:s.');
  TTLanguage.Instance.Add(SDeletedByWithoutDeletedAt, 'TDeletedBy richiede una colonna TDeletedAt: %0:s.');
  TTLanguage.Instance.Add(SDuplicateChangeTrackingColumn, 'La colonna %0:s porta piu di un attributo di change tracking.');
  TTLanguage.Instance.Add(SInstanceDestroyed, 'L''istanza di %0:s non e piu disponibile: la unit e stata finalizzata.');
  TTLanguage.Instance.Add(SInsertEventAttribute, 'Attributo TInsertEventAttribute duplicato.');
  TTLanguage.Instance.Add(SUpdateEventAttribute, 'Attributo TUpdateEventAttribute duplicato.');
  TTLanguage.Instance.Add(SDeleteEventAttribute, 'Attributo TDeleteEventAttribute duplicato.');
  TTLanguage.Instance.Add(SNotDefinedPrimaryKey, 'Chiave primaria: non definita.');
  TTLanguage.Instance.Add(SNotValidPrimaryKeyType, 'Chiave primaria: tipo non valido.');
  TTLanguage.Instance.Add(SNotDefinedSequence, 'Sequenza: non definita.');
  TTLanguage.Instance.Add(SReadOnly, '"Chiave primaria" e "Colonna versione" devono essere entrambe definite.');
  TTLanguage.Instance.Add(SReadOnlyPrimaryKey, '"Chiave primaria" non è definita.');
  TTLanguage.Instance.Add(SRequiredValidation, '%0:s non può essere vuoto.');
  TTLanguage.Instance.Add(SRequiredRelationValidation, '%0:s fa riferimento a una riga che non esiste.');
  TTLanguage.Instance.Add(SNotInvalidTypeValidation, 'Tipo di %0:s non valido per la validazione.');
  TTLanguage.Instance.Add(SMaxLengthValidation, '%0:s non può essere più lungo di %1:d caratteri.');
  TTLanguage.Instance.Add(SMinLengthValidation, '%0:s non può essere più corto di %1:d caratteri.');
  TTLanguage.Instance.Add(SMinValueValidation, '%0:s non può essere inferiore a %1:s.');
  TTLanguage.Instance.Add(SMaxValueValidation, '%0:s non può superare %1:s.');
  TTLanguage.Instance.Add(SLessValidation, '%0:s deve essere inferiore a %1:s.');
  TTLanguage.Instance.Add(SGreaterValidation, '%0:s deve essere superiore a %1:s.');
  TTLanguage.Instance.Add(SRangeValidation, '%0:s deve essere compreso tra %1:s e %2:s.');
  TTLanguage.Instance.Add(SRegexValidation, '%1:s non è un valore valido per %0:s.');
  TTLanguage.Instance.Add(SEMailValidation, '%0:s: %1:s non è un indirizzo email valido.');
  TTLanguage.Instance.Add(SNotValidValidator, 'Metodo di validazione non valido: metodo %0:s dell''entità %1:s.');
  TTLanguage.Instance.Add(SInvalidNullableType, 'Il tipo nullable non è valido.');
  TTLanguage.Instance.Add(SPropertyIDNotFound, 'ID proprietà non trovato');
  TTLanguage.Instance.Add(STypeIsNotAList, 'Il tipo %0:s non è una lista generica.');
  TTLanguage.Instance.Add(STypeHasNotValidConstructor, 'Il tipo %0:s non ha un costruttore valido.');
  TTLanguage.Instance.Add(SClonedEntity, 'Impossibile inserire un''entità clonata: "%0:s".');
  TTLanguage.Instance.Add(SNotValidEntity, 'Entità clonata non valida: "%0:s".');
  TTLanguage.Instance.Add(SDeletedEntity, 'L''entità clonata "%0:s" è stata eliminata.');
  TTLanguage.Instance.Add(SSessionNotTwice, 'La sessione non può essere utilizzata due volte.');
  TTLanguage.Instance.Add(SNullableTypeHasNoValue, 'Il tipo nullable non ha un valore: operazione non valida.');
  TTLanguage.Instance.Add(SCannotAssignPointerToNullable, 'Impossibile assegnare un puntatore non nullo a un tipo nullable.');
  TTLanguage.Instance.Add(SDuplicateColumn, 'Definizione di colonna duplicata: %0:s.');
  TTLanguage.Instance.Add(SColumnNotFound, 'Colonna %0:s non trovata.');
  TTLanguage.Instance.Add(SDuplicateParameterName, 'Le colonne %0:s e %1:s danno lo stesso nome di parametro %2:s: una scriverebbe sopra l''altra senza dire niente.');
  TTLanguage.Instance.Add(SDetailColumnOnJoinEntity,
    'La colonna di dettaglio %0:s non è risolvibile su %1:s, che mappa un join: i metadati di un''entità join sono ' +
    'indicizzati sull''alias di output di ogni colonna, quindi il nome che porta [TDetailColumn] non ne incontra mai uno, ' +
    'e il riferimento arriverebbe al motore non qualificato e ambiguo. Carica il dettaglio con un filtro su un''entità a tabella singola.');
  TTLanguage.Instance.Add(SRelationError, '"%0:s" è attualmente in uso, impossibile eliminare.');
  TTLanguage.Instance.Add(SColumnTypeError, 'Colonna non registrata per il tipo %0:s.');
  TTLanguage.Instance.Add(SParameterTypeError, 'Parametro non registrato per il tipo %0:s.');
  TTLanguage.Instance.Add(STableMapNotFound, 'TableMap per la classe %0:s non trovata');
  TTLanguage.Instance.Add(SPrimaryKeyNotDefined, 'Chiave primaria non definita per la classe %0:s');
  TTLanguage.Instance.Add(SRecordChanged, 'Entità modificata da un altro utente, o non più disponibile.');
  TTLanguage.Instance.Add(SSyntaxError, 'Errore di integrità dei dati: troppi record interessati.');
  TTLanguage.Instance.Add(SSequenceOutOfRange, 'La sequenza della tabella "%0:s" ha restituito %1:d: il valore non entra in una chiave primaria. Dichiara la sequenza con un tetto a 32 bit, così il database la rifiuta all''origine.');
  TTLanguage.Instance.Add(STransactionNotSupported, 'La connessione non supporta le transazioni.');
  TTLanguage.Instance.Add(SInTransaction, '%0:s: transazione già avviata.');
  TTLanguage.Instance.Add(SNotInTransaction, '%0:s: transazione non ancora avviata.');
  TTLanguage.Instance.Add(SNotValidTransaction, 'La transazione non è più valida.');
  TTLanguage.Instance.Add(SProcNotAssigned, 'La procedura non è assegnata.');
  TTLanguage.Instance.Add(SNestedRollbackNotSupported, 'RollbackOnDestroy non è supportato dentro un''altra transazione.');
  TTLanguage.Instance.Add(SNotValidConnectionDriver, 'Connessione non trovata per il driver "%s".');
  TTLanguage.Instance.Add(SNotValidConnection, 'Connessione non trovata "%s".');
  TTLanguage.Instance.Add(SJoinEntityReadOnly, 'Le entità di join sono di sola lettura: Insert, Update e Delete non sono supportate.');
  TTLanguage.Instance.Add(SUndeleteNotSupported, 'Undelete non è supportato: l''entità non ha una colonna di cancellazione logica.');
  TTLanguage.Instance.Add(SUndeleteNotImplemented, '%s non implementa CreateUndeleteCommand.');
  TTLanguage.Instance.Add(SConnectionAlreadyRegistered, 'La connessione "%s" è già registrata con altri parametri.');
  TTLanguage.Instance.Add(SNoUpdatableColumns, 'La tabella %0:s non ha colonne aggiornabili: ogni colonna mappata è la chiave primaria, o una colonna di tracciamento di creazione o cancellazione.');
  TTLanguage.Instance.Add(SPagingStartWithoutLimit, 'Un inizio di pagina richiede un limite: %0:d righe saltate ma nessuna dimensione di pagina.');
  TTLanguage.Instance.Add(SPoolConfigConnectionRegistered, 'I parametri di pool della connessione "%s" non si possono cambiare: la connessione è già registrata, e il pooling si applica alla registrazione.');
  TTLanguage.Instance.Add(SRawFilterOnlyParameters, 'Un filtro SQL grezzo porta solo parametri: scrivi WHERE, ORDER BY e paginazione nell''SQL stesso.');
  TTLanguage.Instance.Add(SAlreadyStarted, 'Server Http già avviato.');
  TTLanguage.Instance.Add(SAreaOnAnonymousRoute, 'La rotta %0:s è limitata con [TArea] e aperta con [TAuthorizationType(None)]: nessuno potrà mai raggiungerla.');
  TTLanguage.Instance.Add(SAreasNeedAuthentication, 'Una rotta limitata con [TArea] ha bisogno di una classe di autenticazione: registrane una, o togli l''attributo.');
  TTLanguage.Instance.Add(SAuthAlreadyRegistered, 'Autenticazione: classe già registrata.');
  TTLanguage.Instance.Add(SAuthenticationNotRegistered,
    'Server Http non avviato: uno o più controller richiedono l''autenticazione e non è registrata nessuna classe di autenticazione. ' +
    'Una rotta senza [TAuthorizationType] richiede l''autenticazione per difetto. ' +
    'Chiama RegisterAuthentication, oppure metti AllowAnonymous a True se questo server deve servire ogni rotta in modo anonimo.');
  TTLanguage.Instance.Add(SColumnAndDetailColumn,
    'Il membro %0:s porta sia TColumn sia TDetailColumn. Uno mappa un valore di questa riga, l''altro una collezione di un''altra tabella, ' +
    'e quale dei due vincesse dipendeva dall''ordine in cui erano stati scritti gli attributi.');
  TTLanguage.Instance.Add(SColumnNotFilterable,
    'La colonna %s non si può usare in un filtro: non è una colonna di questa entità, oppure è marcata come non filtrabile.');
  TTLanguage.Instance.Add(SConditionNotValid, 'Condizione %s non valida.');
  TTLanguage.Instance.Add(SConditionNotValidForColumn, 'Condizione %0:s non valida per la colonna %1:s.');
  TTLanguage.Instance.Add(SContentTooLarge,
    'Il corpo della richiesta supera i %0:d byte che questo server accetta. Un corpo viene letto in memoria per intero prima che qualcuno lo guardi, ' +
    'quindi il tetto è ciò che impedisce a una sola richiesta di costare al processo più di quanto abbia. ' +
    'Alza MaxRequestContentLength, o mettilo a zero per accettare qualunque dimensione.');
  TTLanguage.Instance.Add(SDeserializerNotFound, 'Deserializzatore JSon non trovato per %s.');
  TTLanguage.Instance.Add(SSerializerReentered, 'EntityToJSon è stata rientrata %0:d volte senza tornare. Ogni chiamata apre una profondità e un insieme di visitati propri, quindi MaxLevels e la guardia sui cicli non attraversano una rientranza: due entità i cui eventi si serializzano a vicenda ricorrono finché lo stack non finisce. Serializza l''entità collegata fuori dall''evento.');
  TTLanguage.Instance.Add(SDirectionNotValid, 'Direzione %s non valida.');
  TTLanguage.Instance.Add(SDuplicateController, 'ControllerID(Uri/MethodType) duplicato: %0:s.');
  TTLanguage.Instance.Add(SDuplicateBindAddress, 'L''indirizzo di binding %0:s è già registrato: un secondo binding sullo stesso indirizzo e sulla stessa porta non si può aprire.');
  TTLanguage.Instance.Add(SDuplicateEntityIdentity, 'Identity map: un''altra istanza di %0:s è già registrata con chiave primaria %1:d.');
  TTLanguage.Instance.Add(SEmptyJWTSecret,
    'Il segreto HMAC è vuoto: ogni firma che produce può essere riprodotta da chiunque, quindi un token firmato con quello non dimostra niente. ' +
    'Restituisci un segreto vero da GetSecret.');
  TTLanguage.Instance.Add(SEntityNotFound, 'Entità %d non trovata.');
  TTLanguage.Instance.Add(SForbidden, 'Accesso vietato: %s.');
  TTLanguage.Instance.Add(SForbiddenAreaLog, 'Accesso vietato: %0:s - area mancante: %1:s.');
  TTLanguage.Instance.Add(SInternalServerError, 'Errore interno del server.');
  TTLanguage.Instance.Add(SKeyColumnWithChangeTracking,
    'La colonna %0:s è la %1:s e porta anche un attributo di change tracking. Quelle colonne le scrive il framework su insert, update o delete, ' +
    'e nessuna di queste due è roba che spetti al framework spostare.');
  TTLanguage.Instance.Add(SLogError, 'Errore non gestito: %s');
  TTLanguage.Instance.Add(SLogQueueDiscarded, 'Coda di log piena: %d voci scartate per l''host %s');
  TTLanguage.Instance.Add(SLogWriterAlreadyRegistered, 'LogWriter: classe già registrata.');
  TTLanguage.Instance.Add(SMetadataProbeFailed,
    'Il database ha rifiutato l''elenco delle colonne dell''entità %0:s sulla tabella %1:s. Manca una colonna che l''entità mappa, ' +
    'oppure non è leggibile con il nome sotto cui è mappata. Il motore ha detto: %2:s');
  TTLanguage.Instance.Add(SMethodNotAllowed, 'Metodo %0:s non ammesso per il comando %1:s.');
  TTLanguage.Instance.Add(SMethodOverrideRefused,
    'La richiesta chiede di essere trattata come %0:s mentre è stata mandata come %1:s. Un metodo portato in un header scavalca tutto ciò che filtra sulla riga di richiesta, ' +
    'quindi il server la rifiuta. Metti AllowMethodOverride a True se questo server deve onorarlo.');
  TTLanguage.Instance.Add(SNoIdentityMap, 'TTJSonContext non può usare l''IdentityMap.');
  TTLanguage.Instance.Add(SNoMappedColumns, 'L''entità %0:s non mappa nessuna colonna. Non c''è niente da leggere e niente da scrivere, quindi la query verrebbe costruita vuota.');
  TTLanguage.Instance.Add(SNoSaveOnHttpContext,
    'Save non è disponibile su un TTHttpContext. Decide fra un insert e un update da quello che il contesto ha creato e non ha ancora scritto, ' +
    'e un contesto che vive una richiesta non ha questa storia: l''entità è stata riempita dal corpo. ' +
    'Se la richiesta crea o aggiorna lo dice la richiesta, quindi chiama Insert o Update.');
  TTLanguage.Instance.Add(SNotAJSonArray, 'Il JSon non è un array.');
  TTLanguage.Instance.Add(SNotAJSonObjectInArray, 'L''elemento %d dell''array JSon non è un oggetto.');
  TTLanguage.Instance.Add(SNotAJSonObjectInList, 'L''elemento %0:d dell''array "%1:s" non è un oggetto.');
  TTLanguage.Instance.Add(SNotAJSonObject, 'Il JSon non è un oggetto.');
  TTLanguage.Instance.Add(SNotAssignedPrimaryKey,
    'La colonna %0:s è la chiave primaria e vale zero: niente ha dato un''identità a questa entità. CreateEntity ne assegna una dalla sequenza, ' +
    'e un''entità riempita da fuori - un corpo JSON, un''importazione - ha bisogno di SetSequenceID prima di essere inserita.');
  TTLanguage.Instance.Add(SNotEscapableObjectName,
    'Il nome %0:s porta un %1:s, e %2:s non ha alcuna fuga per uno dentro un identificatore quotato: il nome finirebbe lì, ' +
    'e quello che segue verrebbe letto come SQL. Rinomina l''oggetto, oppure mappalo con un nome che non ne porti.');
  TTLanguage.Instance.Add(SNotValidParameterName,
    'La colonna %0:s porta un %1:s, che non può comparire nel nome di un parametro: il driver legge il nome fino a quel ' +
    'carattere e il valore non viene mai assegnato, quindi la colonna si legge e non si scrive. Rinominala nel database.');
  TTLanguage.Instance.Add(SNotFound, 'Comando %s non trovato.');
  TTLanguage.Instance.Add(SNotStarted, 'Server Http non avviato.');
  TTLanguage.Instance.Add(SRedactedNamesWhileServing,
    'La lista di redazione non si può cambiare mentre un server è in esecuzione: viene letta a ogni header e a ogni parametro ' +
    'di ogni richiesta, e aggiungerci qualcosa sotto quei lettori è una corsa. Dichiara cosa non deve finire nel log prima di Start.');
  TTLanguage.Instance.Add(SNotValidAuthentication, 'L''autenticazione %s non è una TTHttpAbstractAuthentication valida.');
  TTLanguage.Instance.Add(SNotValidBaseUri,
    'BaseUri %0:s è un prefisso di percorso, non un indirizzo: viene messo davanti a ogni rotta, quindi un valore che porta uno schema registra rotte che nessuno può raggiungere. ' +
    'L''indirizzo su cui il server ascolta viene da Bindings.');
  TTLanguage.Instance.Add(SNotValidBindAddress,
    'L''indirizzo di binding "%0:s" non è un indirizzo IP. Va scritto come letterale IPv4 o IPv6, per esempio 127.0.0.1 o ::1, ' +
    'senza porta, senza parentesi quadre e senza nome host: la porta viene da Port, e un nome può risolvere a più di un indirizzo.');
  TTLanguage.Instance.Add(SNotValidCommandType, 'Tipo di comando non valido %s.');
  TTLanguage.Instance.Add(SNotValidController, 'Il controller %s non è un TTHttpAbstractController valido.');
  TTLanguage.Instance.Add(SNotValidEntityList, 'Lista di entità non valida: "%0:s" non è una TTObjectList<T>.');
  TTLanguage.Instance.Add(SNotValidFilterValue, 'Il campo "%s" del filtro porta un valore che il filtro non sa leggere. Un filtro che non si può leggere viene rifiutato, non applicato in parte.');
  TTLanguage.Instance.Add(SNotValidJSonArray, 'Il campo "%s" non è un array. Un corpo che il deserializzatore non sa leggere viene rifiutato, non ignorato.');
  TTLanguage.Instance.Add(SNotValidLogWriter, 'Il LogWriter %s non è un TTHttpLogAbstractWriter valido.');
  TTLanguage.Instance.Add(SNotValidParametrizedUri,
    'La rotta %0:s porta un "?" che non sta negli ultimi segmenti. Un segnaposto combacia con qualunque valore, ' +
    'quindi uno messo prima di un segmento fisso fa sovrapporre la rotta a indirizzi che non doveva servire. Sposta i segnaposto in fondo alla rotta.');
  TTLanguage.Instance.Add(SNotValidSqid, 'Il valore di "%s" non è uno sqid valido.');
  TTLanguage.Instance.Add(SNotValidJSon, 'Il JSon non è valido: %s');
  TTLanguage.Instance.Add(SNotValidJSonValue, 'Il valore di "%s" non è valido per il suo tipo.');
  TTLanguage.Instance.Add(SNotValidTableName,
    'L''entità %0:s non ha tabella: una query su di lei leggerebbe "FROM " e fallirebbe nel driver. ' +
    'Aggiungi [TTable(''nome'')], oppure usa RawSelect se la classe è un DTO per una query che scrivi tu.');
  TTLanguage.Instance.Add(SNotValidTenantName,
    'Il nome tenant "%0:s" non è un nome: deve iniziare con una lettera o una cifra, portarne al più 63 più "_", "-" e ".", e nient''altro. ' +
    'Il nome arriva a una definizione di connessione e, nella maggior parte delle applicazioni, a un nome di database o a un percorso, e di solito viene dalla richiesta.');
  TTLanguage.Instance.Add(SNotValidType, 'Tipo non valido');
  TTLanguage.Instance.Add(SOldEntityAfterCommand,
    'OldEntity è stata letta per la prima volta dopo che il comando era già girato, e a quel punto la riga nel database è quella nuova. ' +
    'Leggila in DoBefore, dove significa quello che dice il nome: il valore viene conservato, quindi DoAfter può usare quello che DoBefore ha letto.');
  TTLanguage.Instance.Add(SOrderByItemNotValid, 'Clausola ORDER BY non valida.');
  TTLanguage.Instance.Add(SOrderByNotValid, 'Clausola ORDER BY %s non valida.');
  TTLanguage.Instance.Add(SPrimaryKeyIsVersionColumn,
    'La colonna %0:s è insieme la chiave primaria e la version column. Un update leggerebbe "SET %0:s = %0:s + 1 WHERE %0:s = :%0:s", ' +
    'cioè sposterebbe la chiave della riga che sta identificando.');
  TTLanguage.Instance.Add(SRegisterAuth, 'Autenticazione registrata: %s');
  TTLanguage.Instance.Add(SRegisterAuthError, 'Errore di registrazione dell''autenticazione: %s');
  TTLanguage.Instance.Add(SRegisterController, 'Controller registrato: %s');
  TTLanguage.Instance.Add(SRegisterControllerError, 'Errore di registrazione del controller: %s');
  TTLanguage.Instance.Add(SSerializerNotFound, 'Serializzatore JSon non trovato per %s.');
  TTLanguage.Instance.Add(SSqidsAlphabetInUse, 'L''alfabeto Sqids non si può cambiare dopo che un id è stato codificato o decodificato: configuralo all''avvio.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotLowerCase, 'L''alfabeto Sqids deve contenere solo caratteri ASCII che non siano lettere maiuscole: "%s" non lo è. Gli id vengono riletti in minuscolo.');
  TTLanguage.Instance.Add(SSqidsAlphabetNotUnique, 'L''alfabeto Sqids non deve ripetere un carattere: "%s" compare più di una volta.');
  TTLanguage.Instance.Add(SSqidsAlphabetTooShort, 'L''alfabeto Sqids deve essere lungo almeno %d caratteri.');
  TTLanguage.Instance.Add(SStartWithoutLimit, 'Uno "start" di %0:d ha bisogno di un "limit": l''endpoint è configurato senza una dimensione massima di pagina, quindi non c''è niente su cui ripiegare.');
  TTLanguage.Instance.Add(SNotValidFilterContent,
    'Un filtro è un oggetto JSon. Questo corpo parsa in qualcos''altro, e da lì non si possono leggere né "where" ' +
    'né "orderBy" né "start" né "limit": applicarlo vorrebbe dire, in silenzio, nessun filtro - e un filtro che cade ' +
    'è una restrizione che cade.');
  TTLanguage.Instance.Add(SStarted, 'Server Http avviato');
  TTLanguage.Instance.Add(SStopTransactionError,
    'La transazione non si è potuta chiudere mentre l''oggetto che la possiede veniva distrutto, e un distruttore non è un posto da cui sollevare, ' +
    'quindi il fallimento viene riportato qui: %0:s - %1:s.');
  TTLanguage.Instance.Add(SStopped, 'Server Http fermato');
  TTLanguage.Instance.Add(SStringTooLong, 'Il valore di "%0:s" è troppo lungo: la colonna tiene %1:d caratteri, ne sono stati dati %2:d.');
  TTLanguage.Instance.Add(STooManyOrderByColumns, 'Troppe colonne in ORDER BY: %0:d (massimo %1:d).');
  TTLanguage.Instance.Add(STooManyWhereConditions, 'Troppe condizioni in WHERE: %0:d (massimo %1:d).');
  TTLanguage.Instance.Add(SUnauthorized, 'Accesso non autorizzato: %s.');
  TTLanguage.Instance.Add(SUnhandledRequestError, '%0:s non gestita fuori dal gestore della richiesta: %1:s');
  TTLanguage.Instance.Add(SValueNotValid, 'Valore %0:s non valido per la colonna %1:s.');
  TTLanguage.Instance.Add(SWhereNotValid, 'Clausola WHERE non valida.');
  TTLanguage.Instance.Add(SNotValidJSonContent,
    'Il corpo della richiesta non è JSON valido. Un corpo che non si riesce a leggere viene rifiutato invece di essere trattato come un oggetto vuoto: ' +
    'un filtro costruito da un oggetto vuoto non porta nessuna condizione, e l''endpoint risponderebbe con la tabella intera.');
end;

end.
