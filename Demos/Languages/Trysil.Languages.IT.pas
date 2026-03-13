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
  TTLanguage.Instance.Add(SInvalidRttiObjectType, 'Il tipo TRttiObject non � valido.');
  TTLanguage.Instance.Add(SDuplicateTableAttribute, 'Attributo TTable duplicato.');
  TTLanguage.Instance.Add(SDuplicateSequenceAttribute, 'Attributo TSequence duplicato.');
  TTLanguage.Instance.Add(SDuplicateWhereClauseAttribute, 'Attributo TWhereClause duplicato.');
  TTLanguage.Instance.Add(SDuplicatePrimaryKeyAttribute, 'Attributo TPrimaryKey duplicato.');
  TTLanguage.Instance.Add(SDuplicateVersionColumnAttribute, 'Attributo TVersionColumn duplicato.');
  TTLanguage.Instance.Add(SInsertEventAttribute, 'Attributo TInsertEventAttribute duplicato.');
  TTLanguage.Instance.Add(SUpdateEventAttribute, 'Attributo TUpdateEventAttribute duplicato.');
  TTLanguage.Instance.Add(SDeleteEventAttribute, 'Attributo TDeleteEventAttribute duplicato.');
  TTLanguage.Instance.Add(SNotDefinedPrimaryKey, 'Chiave primaria: non definita.');
  TTLanguage.Instance.Add(SNotValidPrimaryKeyType, 'Chiave primaria: tipo non valido.');
  TTLanguage.Instance.Add(SNotDefinedSequence, 'Sequenza: non definita.');
  TTLanguage.Instance.Add(SReadOnly, '"Chiave primaria" e "Colonna versione" devono essere entrambe definite.');
  TTLanguage.Instance.Add(SReadOnlyPrimaryKey, '"Chiave primaria" non � definita.');
  TTLanguage.Instance.Add(SRequiredValidation, '%0:s non pu� essere vuoto.');
  TTLanguage.Instance.Add(SNotInvalidTypeValidation, 'Tipo di %0:s non valido per la validazione.');
  TTLanguage.Instance.Add(SMaxLengthValidation, '%0:s non pu� essere pi� lungo di %1:d caratteri.');
  TTLanguage.Instance.Add(SMinLengthValidation, '%0:s non pu� essere pi� corto di %1:d caratteri.');
  TTLanguage.Instance.Add(SMinValueValidation, '%0:s non pu� essere inferiore a %1:s.');
  TTLanguage.Instance.Add(SMaxValueValidation, '%0:s non pu� superare %1:s.');
  TTLanguage.Instance.Add(SLessValidation, '%0:s deve essere inferiore a %1:s.');
  TTLanguage.Instance.Add(SGreaterValidation, '%0:s deve essere superiore a %1:s.');
  TTLanguage.Instance.Add(SRangeValidation, '%0:s deve essere compreso tra %1:s e %2:s.');
  TTLanguage.Instance.Add(SRegexValidation, '%1:s non � un valore valido per %0:s.');
  TTLanguage.Instance.Add(SEMailValidation, '%0:s: %1:s non � un indirizzo email valido.');
  TTLanguage.Instance.Add(SNotValidValidator, 'Metodo di validazione non valido: metodo %0:s dell''entit� %1:s.');
  TTLanguage.Instance.Add(SInvalidNullableType, 'Il tipo nullable non � valido.');
  TTLanguage.Instance.Add(SPropertyIDNotFound, 'ID propriet� non trovato');
  TTLanguage.Instance.Add(STypeIsNotAList, 'Il tipo %0:s non � una lista generica.');
  TTLanguage.Instance.Add(STypeHasNotValidConstructor, 'Il tipo %0:s non ha un costruttore valido.');
  TTLanguage.Instance.Add(SClonedEntity, 'Impossibile inserire un''entit� clonata: "%0:s".');
  TTLanguage.Instance.Add(SNotValidEntity, 'Entit� clonata non valida: "%0:s".');
  TTLanguage.Instance.Add(SDeletedEntity, 'L''entit� clonata "%0:s" � stata eliminata.');
  TTLanguage.Instance.Add(SSessionNotTwice, 'La sessione non pu� essere utilizzata due volte.');
  TTLanguage.Instance.Add(SNullableTypeHasNoValue, 'Il tipo nullable non ha un valore: operazione non valida.');
  TTLanguage.Instance.Add(SCannotAssignPointerToNullable, 'Impossibile assegnare un puntatore non nullo a un tipo nullable.');
  TTLanguage.Instance.Add(SDuplicateColumn, 'Definizione di colonna duplicata: %0:s.');
  TTLanguage.Instance.Add(SColumnNotFound, 'Colonna %0:s non trovata.');
  TTLanguage.Instance.Add(SRelationError, '"%0:s" � attualmente in uso, impossibile eliminare.');
  TTLanguage.Instance.Add(SColumnTypeError, 'Colonna non registrata per il tipo %0:s.');
  TTLanguage.Instance.Add(SParameterTypeError, 'Parametro non registrato per il tipo %0:s.');
  TTLanguage.Instance.Add(STableMapNotFound, 'TableMap per la classe %0:s non trovata');
  TTLanguage.Instance.Add(SPrimaryKeyNotDefined, 'Chiave primaria non definita per la classe %0:s');
  TTLanguage.Instance.Add(SRecordChanged, 'Entit� modificata da un altro utente.');
  TTLanguage.Instance.Add(SSyntaxError, 'Errore di integrità dei dati: troppi record interessati.');
  TTLanguage.Instance.Add(STransactionNotSupported, 'La connessione non supporta le transazioni.');
  TTLanguage.Instance.Add(SInTransaction, '%0:s: transazione gi� avviata.');
  TTLanguage.Instance.Add(SNotInTransaction, '%0:s: transazione non ancora avviata.');
  TTLanguage.Instance.Add(SNotValidTransaction, 'La transazione non � pi� valida.');
  TTLanguage.Instance.Add(SNotValidConnectionDriver, 'Connessione non trovata per il driver "%s".');
  TTLanguage.Instance.Add(SNotValidConnection, 'Connessione non trovata "%s".');
end;

end.
