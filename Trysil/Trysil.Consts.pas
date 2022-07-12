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
  System.Classes;

resourcestring
  SNotValidEventClass = 'Not valid constructor in TTEvent class: %0:s.';
  SNotEventType = 'Not valid TTEvent type: %0:s.';
  SInvalidRttiObjectType = 'TRttiObject type is not valid.';
  SDuplicateTableAttribute = 'Duplicate TTable Attribute.';
  SDuplicateSequenceAttribute = 'Duplicate TSequence Attribute.';
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
  SBlobParameterValue = 'Value for blob parameter is not accessible.';
  SParameterTypeError = 'Parameter non registered for type %0:s.';
  STableMapNotFound = 'TableMap for class %0:s not found';
  SPrimaryKeyNotDefined = 'Primary key not defined for class %0:s';
  SRecordChanged = 'Entity modified by another user.';
  SSyntaxError = 'Incorrect syntax: too many records affected.';
  SInTransaction = '%0:s: transaction already started.';
  SNotInTransaction = '%0:s: transaction not yet started.';
  SNotValidTransaction = 'Transaction is no longer valid.';

implementation

end.
