(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Consts;

interface

resourcestring
  SNotValidEventClass = 'Not valid constructor in TTEvent class: %0:s.';
  SNotEventType = 'Not valid TTEvent type: %0:s.';
  SInvalidRttiObjectType = 'TRttiObject type is not valid.';
  SDuplicateTableAttribute = 'Duplicate TTable Attribute.';
  SDuplicateSequenceAttribute = 'Duplicate TSequence Attribute.';
  SDuplicateWhereClauseAttribute = 'Duplicate TWhereClause Attribute.';
  SDuplicatePrimaryKeyAttribute = 'Duplicate TPrimaryKey Attribute.';
  SDuplicateVersionColumnAttribute = 'Duplicate TVersionColumn Attribute.';
  SInsertEventAttribute = 'Duplicate TInsertEventAttribute Attribute.';
  SUpdateEventAttribute = 'Duplicate TUpdateEventAttribute Attribute.';
  SDeleteEventAttribute = 'Duplicate TDeleteEventAttribute Attribute.';
  SNotDefinedPrimaryKey = 'Primary key: not defined.';
  SNotValidPrimaryKeyType = 'Primary key: not valid type.';
  SNotDefinedSequence = 'Sequence: not defined.';
  SReadOnly = '"Primary Key" or "Version Column" are not defined.';
  SReadOnlyPrimaryKey = '"Primary Key" is not defined.';
  SRequiredValidation = '%0:s cannot be empty.';
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
  SDeletedEntity = 'Cloned entity "%0:s" was deleted.';
  SSessionNotTwice = 'Session can not be used twice.';
  SNullableTypeHasNoValue = 'Nullable type has no value: invalid operation.';
  SCannotAssignPointerToNullable = 'Cannot assign non-null pointer to nullable type.';
  SDuplicateColumn = 'Duplicate column definition: %0:s.';
  SColumnNotFound = 'Column %0:s not found.';
  SRelationError = '"%0:s" is currently in use, unable to delete.';
  SColumnTypeError = 'Column non registered for type %0:s.';
  SParameterTypeError = 'Parameter non registered for type %0:s.';
  STableMapNotFound = 'TableMap for class %0:s not found';
  SPrimaryKeyNotDefined = 'Primary key not defined for class %0:s';
  SRecordChanged = 'Entity modified by another user.';
  SSyntaxError = 'Incorrect syntax: too many records affected.';
  STransactionNotSupported = 'The connection does not support transactions.';
  SInTransaction = '%0:s: transaction already started.';
  SNotInTransaction = '%0:s: transaction not yet started.';
  SNotValidTransaction = 'Transaction is no longer valid.';

implementation

end.
