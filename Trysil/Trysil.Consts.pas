(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Consts;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type

{ TTAbstractLanguageResolver }

  TTAbstractLanguageResolver = class abstract
  strict protected
    function GetCurrentLanguage: String; virtual; abstract;
  public
    function TryTranslate(
      const AKey: String; out AValue: String): Boolean; virtual; abstract;

    property CurrentLanguage: String read GetCurrentLanguage;
  end;

{ TTLanguage }

  TTLanguage = class
  strict private
    class var FInstance: TTLanguage;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FStrings: TDictionary<String, String>;
    FResolver: TTAbstractLanguageResolver;

    function GetCurrentLanguage: String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AKey: String; const AValue: String);

    function Translate(const AKey: String): String;

    property Resolver: TTAbstractLanguageResolver
      read FResolver write FResolver;

    property CurrentLanguage: String read GetCurrentLanguage;

    class property Instance: TTLanguage read FInstance;
  end;

resourcestring
  SNotValidEventClass = 'Not valid constructor in TTEvent class: %0:s.';
  SNotEventType = 'Not valid TTEvent type: %0:s.';
  SInvalidRttiObjectType = 'TRttiObject type is not valid.';
  SDuplicateTableAttribute = 'Duplicate TTable Attribute.';
  SDuplicateSequenceAttribute = 'Duplicate TSequence Attribute.';
  SDuplicateWhereClauseAttribute = 'Duplicate TWhereClause Attribute.';
  SDuplicatePrimaryKeyAttribute = 'Duplicate TPrimaryKey Attribute.';
  SDuplicateVersionColumnAttribute = 'Duplicate TVersionColumn Attribute.';
  SDuplicateChangedAtAttribute = 'Duplicate change tracking "At" attribute: %0:s.';
  SDuplicateChangedByAttribute = 'Duplicate change tracking "By" attribute: %0:s.';
  SInvalidChangedAtType = 'Change tracking "At" attribute requires TTNullable<TDateTime> field: %0:s.';
  SInvalidChangedByType = 'Change tracking "By" attribute requires String field: %0:s.';
  SDeletedByWithoutDeletedAt = 'TDeletedBy requires a TDeletedAt column: %0:s.';
  SDuplicateChangeTrackingColumn =
    'Column %0:s carries more than one change tracking attribute.';
  SPrimaryKeyIsVersionColumn = 'Column %0:s is both the primary key and ' +
    'the version column. An update would read "SET %0:s = %0:s + 1 ' +
    'WHERE %0:s = :%0:s", which moves the key of the row it is ' +
    'identifying by.';
  SKeyColumnWithChangeTracking = 'Column %0:s is the %1:s and also ' +
    'carries a change tracking attribute. Those columns are written by ' +
    'the framework on insert, update or delete, and neither of these ' +
    'two is the framework''s to move.';
  SColumnAndDetailColumn = 'Member %0:s carries both TColumn and ' +
    'TDetailColumn. One maps a value of this row, the other a collection ' +
    'of another table, and which of the two won depended on the order ' +
    'the attributes were written in.';
  SMetadataProbeFailed = 'The database refused the column list of ' +
    'entity %0:s on table %1:s. A column the entity maps is missing, or ' +
    'is not readable with the name it is mapped under. The engine said: ' +
    '%2:s';
  SNotEscapableObjectName = 'Name %0:s carries a %1:s, and %2:s has no ' +
    'escape for one inside a quoted identifier: the name would end there, ' +
    'and what follows it would be read as SQL. Rename the object, or map ' +
    'it under a name that does not carry one.';
  SNotValidParameterName = 'Column %0:s carries a %1:s, which cannot ' +
    'appear in the name of a parameter: the driver reads the name up to ' +
    'that character and the value is never bound, so the column can be ' +
    'read and not written. Rename it in the database.';
  SNotValidTableName = 'Entity %0:s has no table: a query on it would ' +
    'read "FROM " and fail in the driver. Add [TTable(''name'')], or use ' +
    'RawSelect if the class is a DTO for a query you write yourself.';
  SNoMappedColumns = 'Entity %0:s maps no column. There is nothing to ' +
    'select and nothing to write, so the query would be built empty.';
  SInstanceDestroyed =
    'Instance of %0:s is no longer available: the unit is finalized.';
  SInsertEventAttribute = 'Duplicate TInsertEventAttribute Attribute.';
  SUpdateEventAttribute = 'Duplicate TUpdateEventAttribute Attribute.';
  SDeleteEventAttribute = 'Duplicate TDeleteEventAttribute Attribute.';
  SOldEntityAfterCommand = 'OldEntity was read for the first time after ' +
    'the command had run, and by then the row in the database is the new ' +
    'one. Read it in DoBefore, where it means what its name says: the ' +
    'value is kept, so DoAfter can use what DoBefore read.';
  SNotAssignedPrimaryKey = 'Column %0:s is the primary key and it is ' +
    'zero: nothing has given this entity an identity. CreateEntity ' +
    'assigns one from the sequence, and an entity filled from outside - ' +
    'a JSON body, an import - needs SetSequenceID before it is inserted.';
  SNotDefinedPrimaryKey = 'Primary key: not defined.';
  SNotValidPrimaryKeyType = 'Primary key: not valid type.';
  SNotDefinedSequence = 'Sequence: not defined.';
  SReadOnly = '"Primary Key" and "Version Column" must both be defined.';
  SReadOnlyPrimaryKey = '"Primary Key" is not defined.';
  SRequiredValidation = '%0:s cannot be empty.';
  SRequiredRelationValidation =
    '%0:s refers to a row that does not exist.';
  SNotInvalidTypeValidation = '%0:s type not valid for validation.';
  SMaxLengthValidation = '%0:s cannot be longer than %1:d characters.';
  SMinLengthValidation = '%0:s cannot be shorter than %1:d characters.';
  SMinValueValidation = '%0:s cannot be less than %1:s.';
  SMaxValueValidation = '%0:s cannot exceed %1:s.';
  SLessValidation = '%0:s must be less than %1:s.';
  SGreaterValidation = '%0:s must be greater than %1:s.';
  SRangeValidation = '%0:s must be between %1:s and %2:s.';
  SRegexValidation = '%1:s is not a valid value for %0:s.';
  SEMailValidation = '%0:s: %1:s is not a valid email address.';
  SNotValidValidator = 'Validator method is not valid: %0:s method of %1:s entity.';
  SInvalidNullableType = 'Null type is invalid.';
  SPropertyIDNotFound = 'Property ID not found';
  STypeIsNotAList = 'Type %0:s is not a generic list.';
  STypeHasNotValidConstructor = 'Type %0:s has not a valid constructor.';
  SClonedEntity = 'Can not insert a cloned entity: "%0:s".';
  SNotValidEntity = 'Not valid cloned entity: "%0:s".';
  SDuplicateEntityIdentity = 'Identity map: another %0:s instance is already registered with primary key %1:d.';
  SNotValidEntityList = 'Not valid entity list: "%0:s" is not a TTObjectList<T>.';
  SStringTooLong = 'Value for "%0:s" is too long: the column holds ' +
    '%1:d characters, %2:d given.';
  SDeletedEntity = 'Cloned entity "%0:s" was deleted.';
  SSessionNotTwice = 'Session can not be used twice.';
  SNullableTypeHasNoValue = 'Nullable type has no value: invalid operation.';
  SCannotAssignPointerToNullable = 'Cannot assign non-null pointer to nullable type.';
  SDuplicateColumn = 'Duplicate column definition: %0:s.';
  SColumnNotFound = 'Column %0:s not found.';
  SDuplicateParameterName = 'Columns %0:s and %1:s both name the ' +
    'parameter %2:s: one would write over the other without a word.';
  SDetailColumnOnJoinEntity = 'Detail column %0:s cannot be resolved on ' +
    '%1:s, which maps a join: the metadata of a join entity are keyed on ' +
    'the output alias of each column, so the name the [TDetailColumn] ' +
    'carries never matches one, and the reference would reach the engine ' +
    'unqualified and ambiguous. Load the detail through a filter on a ' +
    'single-table entity instead.';
  SRawFilterOnlyParameters = 'A raw SQL filter carries parameters only: ' +
    'write the WHERE, the ORDER BY and the paging in the SQL itself.';
  SNoUpdatableColumns = 'Table %0:s has no updatable column: every ' +
    'mapped column is the primary key, or a creation or deletion change ' +
    'tracking column.';
  SRelationError = '"%0:s" is currently in use, unable to delete.';
  SColumnTypeError = 'Column non registered for type %0:s.';
  SParameterTypeError = 'Parameter non registered for type %0:s.';
  SStopTransactionError = 'The transaction could not be closed while the ' +
    'object that owns it was being destroyed, and a destructor is not a ' +
    'place to raise from, so the failure is reported here: %0:s - %1:s.';
  STableMapNotFound = 'TableMap for class %0:s not found';
  SPrimaryKeyNotDefined = 'Primary key not defined for class %0:s';
  SRecordChanged = 'Entity modified by another user, or no longer available.';
  SSyntaxError = 'Data integrity error: too many records affected.';
  SSequenceOutOfRange = 'Sequence for table "%0:s" returned %1:d: the ' +
    'value does not fit a primary key. Declare the sequence with a 32-bit ' +
    'ceiling so the database refuses it at the source.';
  STransactionNotSupported = 'The connection does not support transactions.';
  SInTransaction = '%0:s: transaction already started.';
  SNotInTransaction = '%0:s: transaction not yet started.';
  SNotValidTransaction = 'Transaction is no longer valid.';
  SProcNotAssigned = 'The procedure is not assigned.';
  SNestedRollbackNotSupported =
    'RollbackOnDestroy is not supported inside another transaction.';
  SNotValidConnectionDriver = 'Connection not found for "%s" driver.';
  SNotValidConnection = 'Connection not found "%s".';
  SConnectionAlreadyRegistered =
    'Connection "%s" is already registered with other parameters.';
  SPagingStartWithoutLimit = 'A paging start needs a limit: %0:d rows are ' +
    'skipped but no page size is given.';
  SPoolConfigConnectionRegistered = 'Pool parameters for connection "%s" ' +
    'cannot be changed: the connection is already registered, and pooling ' +
    'is applied at registration time.';
  SJoinEntityReadOnly = 'Join entities are read-only: Insert, Update, and Delete are not supported.';
  SUndeleteNotSupported = 'Undelete is not supported: the entity has no soft-delete column.';
  SUndeleteNotImplemented = '%s does not implement CreateUndeleteCommand.';

implementation

{ TTLanguage }

class constructor TTLanguage.ClassCreate;
begin
  FInstance := TTLanguage.Create;
end;

class destructor TTLanguage.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTLanguage.Create;
begin
  inherited Create;
  FStrings := TDictionary<String, String>.Create;
  FResolver := nil;
end;

destructor TTLanguage.Destroy;
begin
  FStrings.Free;
  inherited Destroy;
end;

procedure TTLanguage.Add(const AKey: String; const AValue: String);
begin
  FStrings.AddOrSetValue(AKey, AValue);
end;

function TTLanguage.GetCurrentLanguage: String;
begin
  if Assigned(FResolver) then
    result := FResolver.CurrentLanguage
  else
    result := String.Empty;
end;

function TTLanguage.Translate(const AKey: String): String;
begin
  if (not Assigned(FResolver)) or
    (not FResolver.TryTranslate(AKey, result)) then
    if not FStrings.TryGetValue(AKey, result) then
      result := AKey;
end;

end.
