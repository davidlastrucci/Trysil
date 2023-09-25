(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.SQLCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.Model,
  Trysil.Expert.SourceWriter;

type

{ TTIndex }

  TTIndex = record
  strict private
    FTableName: String;
    FColumnName: String;
  public
    constructor Create(
      const ATableName: String; const AColumnName: String);

    property TableName: String read FTableName;
    property ColumnName: String read FColumnName;
  end;

{ TTAbstractSQLCreator }

  TTAbstractSQLCreator = class abstract
  strict private
    procedure AddCreateTable(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure AddColumns(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure AddPrimaryKey(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    function GetNull(
      const AColumn: TTAbstractColumn): String;
  strict protected
    FIndexes: TList<TTIndex>;

    procedure AddCreateSequence(
      const ASource: TTSourceWriter;
      const AEntity: TTEntity); virtual; abstract;

    function GetType(
      const ADatatype: TTDataType;
      const ASize: Integer): String; virtual; abstract;
    function GetPrimaryKeySyntax(
      const AColumnName: String;
      const AEntity: TTEntity): String; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateSQL(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure CreateIndexes(const ASource: TTSourceWriter);
  end;

{ TTAbstractSQLCreatorClass }

  TTAbstractSQLCreatorClass = class of TTAbstractSQLCreator;

{ TTFirebirdSQLCreator }

  TTFirebirdSQLCreator = class(TTAbstractSQLCreator)
  strict protected
    procedure AddCreateSequence(
      const ASource: TTSourceWriter; const AEntity: TTEntity); override;

    function GetType(
      const ADatatype: TTDataType;
      const ASize: Integer): String; override;
    function GetPrimaryKeySyntax(
      const AColumnName: String; const AEntity: TTEntity): String; override;
  end;

{ TTMSSQLCreator }

  TTMSSQLCreator = class(TTAbstractSQLCreator)
  strict protected
    procedure AddCreateSequence(
      const ASource: TTSourceWriter; const AEntity: TTEntity); override;

    function GetType(
      const ADatatype: TTDataType;
      const ASize: Integer): String; override;
    function GetPrimaryKeySyntax(
      const AColumnName: String; const AEntity: TTEntity): String; override;
  end;

{ TTPostgreSQLCreator }

  TTPostgreSQLCreator = class(TTAbstractSQLCreator)
  strict protected
    procedure
      AddCreateSequence(
        const ASource: TTSourceWriter; const AEntity: TTEntity); override;

    function GetType(
      const ADatatype: TTDataType;
      const ASize: Integer): String; override;
    function GetPrimaryKeySyntax(
      const AColumnName: String; const AEntity: TTEntity): String; override;
  end;

{ TTSQLiteCreator }

  TTSQLiteCreator = class(TTAbstractSQLCreator)
  strict protected
    procedure
      AddCreateSequence(const ASource: TTSourceWriter; const AEntity: TTEntity); override;

    function GetType(
      const ADatatype: TTDataType;
      const ASize: Integer): String; override;
    function GetPrimaryKeySyntax(
      const AColumnName: String; const AEntity: TTEntity): String; override;
  end;

{ TTSQLCreatorType }

  TTSQLCreatorType = (
    ctFirebird,
    ctMSSQL,
    ctPostgreSQL,
    ctSQLite);

{ TTSQLCreator }

  TTSQLCreator = class
  strict private
    FCreatorType: TTSQLCreatorType;
    FSource: TTSourceWriter;
  public
    constructor Create(const ACreatorType: TTSQLCreatorType);
    destructor Destroy; override;

    procedure CreateEntities(const AEntities: TList<TTEntity>);

    function ToString: String; override;
  end;

implementation

{ TTIndex }

constructor TTIndex.Create(
  const ATableName: String; const AColumnName: String);
begin
  FTableName := ATableName;
  FColumnName := AColumnName;
end;

{ TTAbstractSQLCreator }

constructor TTAbstractSQLCreator.Create;
begin
  inherited Create;
  FIndexes := TList<TTIndex>.Create;
end;

destructor TTAbstractSQLCreator.Destroy;
begin
  FIndexes.Free;
  inherited Destroy;
end;

procedure TTAbstractSQLCreator.CreateSQL(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  AddCreateSequence(ASource, AEntity);
  AddCreateTable(ASource, AEntity);
end;

procedure TTAbstractSQLCreator.CreateIndexes(const ASource: TTSourceWriter);
var
  LIndex: TTIndex;
begin
  for LIndex in FIndexes do
    ASource.Append('CREATE INDEX %0:s_%1:s_Index ON %0:s (%1:s);', [
      LIndex.TableName, LIndex.ColumnName]);
end;

function TTAbstractSQLCreator.GetNull(const AColumn: TTAbstractColumn): String;
var
  LRequired: Boolean;
begin
  LRequired := (AColumn is TTColumn) and
    (TTColumn(AColumn).DataType in [TTDataType.dtPrimaryKey, TTDataType.dtVersion]);
  if not LRequired then
    LRequired := AColumn.Required;
  if LRequired then
    result := 'NOT NULL'
  else
    result := 'NULL';
end;

procedure TTAbstractSQLCreator.AddCreateTable(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('CREATE TABLE %s(', [AEntity.TableName]);
  AddColumns(ASource, AEntity);
  AddPrimaryKey(ASource, AEntity);
  ASource.Append(');');
  ASource.AppendLine;
end;

procedure TTAbstractSQLCreator.AddColumns(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
var
  LColumn: TTAbstractColumn;
  LType, LNull: String;
begin
  for LColumn in AEntity.Columns.Columns do
  begin
    if LColumn is TTColumn then
      LType := GetType(TTColumn(LColumn).DataType, TTColumn(LColumn).Size)
    else if LColumn is TTLazyColumn then
      LType := GetType(TTDataType.dtInteger, 0)
    else if LColumn is TTLazyListColumn then
    begin
      FIndexes.Add(TTIndex.Create(
        TTLazyListColumn(LColumn).ObjectName,
        TTLazyListColumn(LColumn).ColumnName));
      Continue;
    end;

    LNull := GetNull(LColumn);
    ASource.Append('  %s %s %s,', [LColumn.ColumnName, LType, LNull]);
  end;
end;

procedure TTAbstractSQLCreator.AddPrimaryKey(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
var
  LColumn: TTAbstractColumn;
begin
  for LColumn in AEntity.Columns.Columns do
    if (LColumn is TTColumn) and
      (TTColumn(LColumn).DataType = TTDataType.dtPrimaryKey) then
    begin
      ASource.Append('  %s', [GetPrimaryKeySyntax(LColumn.Name, AEntity)]);
      Break;
    end;
end;

{ TTFirebirdSQLCreator }

procedure TTFirebirdSQLCreator.AddCreateSequence(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('CREATE SEQUENCE %s;', [AEntity.SequenceName]);
  ASource.AppendLine;
end;

function TTFirebirdSQLCreator.GetType(
  const ADatatype: TTDataType; const ASize: Integer): String;
begin
  case ADatatype of
    dtPrimaryKey:
      result := 'INTEGER';
    dtString:
      result := Format('VARCHAR(%d)', [ASize]);
    dtMemo:
      result := 'BLOB';
    dtSmallint:
      result := 'SMALLINT';
    dtInteger:
      result := 'INTEGER';
    dtLargeInteger:
      result := 'BIGINT';
    dtDouble:
      result := 'FLOAT';
    dtBoolean:
      result := 'BOOLEAN';
    dtDateTime:
      result := 'TIMESTAMP';
    dtGuid:
      result := '???';
    dtBlob:
      result := 'BLOB';
    dtVersion:
      result := 'INTEGER';

    else
      raise ETExpertException.Create(SInvalidColumnType);
  end;
end;

function TTFirebirdSQLCreator.GetPrimaryKeySyntax(
  const AColumnName: String; const AEntity: TTEntity): String;
begin
  result := Format('CONSTRAINT PK_%s PRIMARY KEY (%s)', [
    AEntity.TableName, AColumnName]);
end;

{ TTMSSQLCreator }

procedure TTMSSQLCreator.AddCreateSequence(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('CREATE SEQUENCE %s', [AEntity.SequenceName]);
  ASource.Append('  AS int');
  ASource.Append('  START WITH 1');
  ASource.Append('  INCREMENT BY 1;');
  ASource.AppendLine;
end;

function TTMSSQLCreator.GetType(
  const ADatatype: TTDataType; const ASize: Integer): String;
begin
  case ADatatype of
    dtPrimaryKey:
      result := 'int';
    dtString:
      result := Format('nvarchar(%d)', [ASize]);
    dtMemo:
      result := 'nvarchar(max)';
    dtSmallint:
      result := 'smallint';
    dtInteger:
      result := 'int';
    dtLargeInteger:
      result := 'bigint';
    dtDouble:
      result := 'float';
    dtBoolean:
      result := 'bit';
    dtDateTime:
      result := 'datetime';
    dtGuid:
      result := 'uniqueidentifier';
    dtBlob:
      result := 'varbinary(max)';
    dtVersion:
      result := 'int';

    else
      raise ETExpertException.Create(SInvalidColumnType);
  end;
end;

function TTMSSQLCreator.GetPrimaryKeySyntax(
  const AColumnName: String; const AEntity: TTEntity): String;
begin
  result := Format('CONSTRAINT PK_%s PRIMARY KEY CLUSTERED (%s ASC)', [
    AEntity.TableName, AColumnName]);
end;

{ TTPostgreSQLCreator }

procedure TTPostgreSQLCreator.AddCreateSequence(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('CREATE SEQUENCE %s START 1;', [AEntity.SequenceName]);
  ASource.AppendLine;
end;

function TTPostgreSQLCreator.GetType(
  const ADatatype: TTDataType; const ASize: Integer): String;
begin
  case ADatatype of
    dtPrimaryKey:
      result := 'integer';
    dtString:
      result := Format('varchar(%d)', [ASize]);
    dtMemo:
      result := 'varchar';
    dtSmallint:
      result := 'smallint';
    dtInteger:
      result := 'integer';
    dtLargeInteger:
      result := 'bigint';
    dtDouble:
      result := 'decimal';
    dtBoolean:
      result := 'boolean';
    dtDateTime:
      result := 'timestamp';
    dtGuid:
      result := 'uuid';
    dtBlob:
      result := 'bytea';
    dtVersion:
      result := 'integer';

    else
      raise ETExpertException.Create(SInvalidColumnType);
  end;
end;

function TTPostgreSQLCreator.GetPrimaryKeySyntax(
  const AColumnName: String; const AEntity: TTEntity): String;
begin
  result := Format('PRIMARY KEY (%s)', [AColumnName]);
end;

{ TTSQLiteCreator }

procedure TTSQLiteCreator.AddCreateSequence;
begin
  // Do nothing
end;


function TTSQLiteCreator.GetType(
  const ADatatype: TTDataType; const ASize: Integer): String;
begin
  case ADatatype of
    dtPrimaryKey:
      result := 'INT';
    dtString:
      result := Format('NVARCHAR(%d)', [ASize]);
    dtMemo:
      result := 'TEXT';
    dtSmallint:
      result := 'SMALLINT';
    dtInteger:
      result := 'INT';
    dtLargeInteger:
      result := 'BIGINT';
    dtDouble:
      result := 'DOUBLE';
    dtBoolean:
      result := 'BOOLEAN';
    dtDateTime:
      result := 'DATETIME';
    dtGuid:
      result := '???';
    dtBlob:
      result := 'BLOB';
    dtVersion:
      result := 'INT';

    else
      raise ETExpertException.Create(SInvalidColumnType);
  end;
end;

function TTSQLiteCreator.GetPrimaryKeySyntax(
  const AColumnName: String; const AEntity: TTEntity): String;
begin
  result := Format('PRIMARY KEY (%s)', [AColumnName]);
end;

{ TTSQLCreator }

constructor TTSQLCreator.Create(const ACreatorType: TTSQLCreatorType);
begin
  inherited Create;
  FCreatorType := ACreatorType;
  FSource := TTSourceWriter.Create;
end;

destructor TTSQLCreator.Destroy;
begin
  FSource.Free;
  inherited Destroy;
end;

procedure TTSQLCreator.CreateEntities(const AEntities: TList<TTEntity>);
const
  CreatorClasses: array [TTSQLCreatorType] of TTAbstractSQLCreatorClass = (
    TTFirebirdSQLCreator, TTMSSQLCreator, TTPostgreSQLCreator, TTSQLiteCreator);
var
  LCreator: TTAbstractSQLCreator;
  LEntity: TTEntity;
begin
  FSource.Clear;
  LCreator := CreatorClasses[FCreatorType].Create;
  try
    for LEntity in AEntities do
      LCreator.CreateSQL(FSource, LEntity);
    LCreator.CreateIndexes(FSource);
  finally
    LCreator.Free;
  end;
end;

function TTSQLCreator.ToString: String;
begin
  result := FSource.ToString;
end;

end.
