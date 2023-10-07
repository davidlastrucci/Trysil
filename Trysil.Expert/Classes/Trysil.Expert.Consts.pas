(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.Consts;

interface

resourcestring
  SInvalidColumnType = 'Invalid column type.';
  SEntityNotFound = 'Entity %s not found.';
  SSelectOneEntity = 'Select at least one entity.';
  SErrors = 'There are errors:';
  SEntityNameEmpty = 'Entity name cannot be empty.';
  STableNameEmpty = 'Table name cannot be empty.';
  SSequenceNameEmpty = 'Sequence name cannot be empty.';
  STableSameSequenceName = 'Table name cannot be the same sequence name.';
  SDuplicateEntityName = 'Another entity has the same name.';
  SDuplicateTableName = 'Entity "%s" has the same table name.';
  SDuplicateSequenceName = 'Entity "%s" has the same sequence name.';
  SSequenceSameTable = 'Entity "%s" has the sequence name same as this table name.';
  STableSameSequence = 'Entity "%s" has the table name same as this sequence name.';
  SColumnNameEmpty = 'Name cannot be empty.';
  SColumnColumnNameEmpty = 'Column name cannot be empty.';
  SInvalidDataType = 'Invalid data type.';
  SStringSizeError = 'Strings columns must be larger than zero.';
  SDuplicateColumnName = 'Another column has the same name.';
  SDuplicateColumnColumnName = 'Column "%s" has the same column name.';
  SInvalidEntityType = 'Invalid entity type.';
  SInvalidColumnName = 'Invalid comlumn name.';

  SDeleteEntity = 'Delete "%s" entity?';
  SDeleteColumn = 'Delete "%s" column?';

implementation

end.
