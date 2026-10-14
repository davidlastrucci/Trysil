unit Trysil.Languages.IT;

interface

uses
  System.SysUtils,
  System.Classes,
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
  TTLanguage.Instance.Add(SEventsAlreadyRegistered, 'Gli eventi di %0:s sono già registrati.');
  TTLanguage.Instance.Add(SEventClassNotAssigned, 'Impossibile registrare gli eventi di %0:s: la classe evento è nil.');
  TTLanguage.Instance.Add(SEventsAttributeAndRegistration, 'Gli eventi di %0:s sono dichiarati sia con un attributo sia con una registrazione: tenerne solo uno.');
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
  TTLanguage.Instance.Add(SColumnAndDetailColumn,
    'Il membro %0:s porta sia TColumn sia TDetailColumn. Uno mappa un valore di questa riga, l''altro una collezione di un''altra tabella, ' +
    'e quale dei due vincesse dipendeva dall''ordine in cui erano stati scritti gli attributi.');
  TTLanguage.Instance.Add(SDuplicateEntityIdentity, 'Identity map: un''altra istanza di %0:s è già registrata con chiave primaria %1:d.');
  TTLanguage.Instance.Add(SKeyColumnWithChangeTracking,
    'La colonna %0:s è la %1:s e porta anche un attributo di change tracking. Quelle colonne le scrive il framework su insert, update o delete, ' +
    'e nessuna di queste due è roba che spetti al framework spostare.');
  TTLanguage.Instance.Add(SMetadataProbeFailed,
    'Il database ha rifiutato l''elenco delle colonne dell''entità %0:s sulla tabella %1:s. Manca una colonna che l''entità mappa, ' +
    'oppure non è leggibile con il nome sotto cui è mappata. Il motore ha detto: %2:s');
  TTLanguage.Instance.Add(SNoMappedColumns, 'L''entità %0:s non mappa nessuna colonna. Non c''è niente da leggere e niente da scrivere, quindi la query verrebbe costruita vuota.');
  TTLanguage.Instance.Add(SNotAssignedPrimaryKey,
    'La colonna %0:s è la chiave primaria e vale zero: niente ha dato un''identità a questa entità. CreateEntity ne assegna una dalla sequenza, ' +
    'e un''entità riempita da fuori - un corpo JSON, un''importazione - ha bisogno di SetSequenceID prima di essere inserita.');
  TTLanguage.Instance.Add(SNotEscapableObjectName,
    'Il nome %0:s porta un %1:s, e %2:s non ha alcuna fuga per uno dentro un identificatore quotato: il nome finirebbe lì, ' +
    'e quello che segue verrebbe letto come SQL. Rinomina l''oggetto, oppure mappalo con un nome che non ne porti.');
  TTLanguage.Instance.Add(SNotValidParameterName,
    'La colonna %0:s porta un %1:s, che non può comparire nel nome di un parametro: il driver legge il nome fino a quel ' +
    'carattere e il valore non viene mai assegnato, quindi la colonna si legge e non si scrive. Rinominala nel database.');
  TTLanguage.Instance.Add(SNotValidEntityList, 'Lista di entità non valida: "%0:s" non è una TTObjectList<T>.');
  TTLanguage.Instance.Add(SNotValidTableName,
    'L''entità %0:s non ha tabella: una query su di lei leggerebbe "FROM " e fallirebbe nel driver. ' +
    'Aggiungi [TTable(''nome'')], oppure usa RawSelect se la classe è un DTO per una query che scrivi tu.');
  TTLanguage.Instance.Add(SOldEntityAfterCommand,
    'OldEntity è stata letta per la prima volta dopo che il comando era già girato, e a quel punto la riga nel database è quella nuova. ' +
    'Leggila in DoBefore, dove significa quello che dice il nome: il valore viene conservato, quindi DoAfter può usare quello che DoBefore ha letto.');
  TTLanguage.Instance.Add(SPrimaryKeyIsVersionColumn,
    'La colonna %0:s è insieme la chiave primaria e la version column. Un update leggerebbe "SET %0:s = %0:s + 1 WHERE %0:s = :%0:s", ' +
    'cioè sposterebbe la chiave della riga che sta identificando.');
  TTLanguage.Instance.Add(SStopTransactionError,
    'La transazione non si è potuta chiudere mentre l''oggetto che la possiede veniva distrutto, e un distruttore non è un posto da cui sollevare, ' +
    'quindi il fallimento viene riportato qui: %0:s - %1:s.');
  TTLanguage.Instance.Add(SStringTooLong, 'Il valore di "%0:s" è troppo lungo: la colonna tiene %1:d caratteri, ne sono stati dati %2:d.');
end;

end.
