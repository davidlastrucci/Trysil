(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.SQLUpdateCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Expert.Consts,
  Trysil.Expert.Model,
  Trysil.Expert.SourceWriter,
  Trysil.Expert.SQLCreator,
  Trysil.Expert.Schema;

type

{ TTSQLUpdateCreator }

  TTSQLUpdateCreator = class
  strict private
    const DifferenceFormat: String = '-- %0:s.%1:s: model %2:s, database %3:s';
  strict private
    FCreator: TTAbstractSQLCreator;
    FSchema: TTSchema;
    FDifferences: TTSourceWriter;
    FStatements: TTSourceWriter;
    FHasDifferences: Boolean;
    FHasStatements: Boolean;
    FCreatedTables: TList<String>;

    function ModelFamilies(const AColumn: TTAbstractColumn): TTSchemaFamilies;
    function NullText(const ARequired: Boolean): String;
    function SameType(
      const AColumn: TTAbstractColumn;
      const ASchemaColumn: TTSchemaColumn): Boolean;
    procedure AddDifference(
      const AEntity: TTEntity;
      const AColumn: TTAbstractColumn;
      const AModel: String;
      const ADatabase: String);
    procedure CompareColumn(
      const AEntity: TTEntity;
      const AColumn: TTAbstractColumn;
      const ASchemaColumn: TTSchemaColumn);
    function AlignColumns(
      const AEntity: TTEntity; const ATable: TTSchemaTable): Boolean;
    procedure AlignTable(const AEntity: TTEntity; const ATable: TTSchemaTable);
    procedure AlignEntity(const AEntity: TTEntity);
    function IndexNeeded(const AIndex: TTIndex): Boolean;
    procedure AlignIndexes;
  public
    constructor Create(
      const ACreatorType: TTSQLCreatorType; const ASchema: TTSchema);
    destructor Destroy; override;

    procedure AlignEntities(const AEntities: TList<TTEntity>);

    function ToString: String; override;

    class procedure AddTableNames(
      const AEntities: TList<TTEntity>; const ATableNames: TList<String>);
  end;

implementation

{ TTSQLUpdateCreator }

constructor TTSQLUpdateCreator.Create(
  const ACreatorType: TTSQLCreatorType; const ASchema: TTSchema);
begin
  inherited Create;
  FSchema := ASchema;
  FCreator := TTSQLCreator.CreatorClass(ACreatorType).Create;
  FDifferences := TTSourceWriter.Create;
  FStatements := TTSourceWriter.Create;
  FCreatedTables := TList<String>.Create;
  FHasDifferences := False;
  FHasStatements := False;
end;

destructor TTSQLUpdateCreator.Destroy;
begin
  FCreatedTables.Free;
  FStatements.Free;
  FDifferences.Free;
  FCreator.Free;
  inherited Destroy;
end;

class procedure TTSQLUpdateCreator.AddTableNames(
  const AEntities: TList<TTEntity>; const ATableNames: TList<String>);
var
  LEntity: TTEntity;
  LColumn: TTAbstractColumn;
begin
  for LEntity in AEntities do
  begin
    ATableNames.Add(LEntity.TableName);
    for LColumn in LEntity.Columns.Columns do
      if (LColumn is TTLazyListColumn) and
        not TTLazyListColumn(LColumn).TableName.IsEmpty then
        ATableNames.Add(TTLazyListColumn(LColumn).TableName);
  end;
end;

function TTSQLUpdateCreator.ModelFamilies(
  const AColumn: TTAbstractColumn): TTSchemaFamilies;
begin
  result := [TTSchemaFamily.sfNumber];
  if AColumn is TTColumn then
    case TTColumn(AColumn).DataType of
      TTDataType.dtString:
        result := [TTSchemaFamily.sfText];
      TTDataType.dtMemo:
        result := [TTSchemaFamily.sfText, TTSchemaFamily.sfBinary];
      TTDataType.dtBoolean:
        result := [TTSchemaFamily.sfBoolean, TTSchemaFamily.sfNumber];
      TTDataType.dtDateTime:
        result := [TTSchemaFamily.sfDateTime];
      TTDataType.dtGuid:
        result := [
          TTSchemaFamily.sfGuid,
          TTSchemaFamily.sfText,
          TTSchemaFamily.sfBinary];
      TTDataType.dtBlob:
        result := [TTSchemaFamily.sfBinary];
    end;
end;

function TTSQLUpdateCreator.NullText(const ARequired: Boolean): String;
begin
  if ARequired then
    result := 'NOT NULL'
  else
    result := 'NULL';
end;

function TTSQLUpdateCreator.SameType(
  const AColumn: TTAbstractColumn;
  const ASchemaColumn: TTSchemaColumn): Boolean;
begin
  result := ASchemaColumn.Family in
    ModelFamilies(AColumn) + [TTSchemaFamily.sfOther];
  if result and ASchemaColumn.Bounded and (AColumn is TTColumn) and
    (TTColumn(AColumn).DataType = TTDataType.dtString) then
    result := ASchemaColumn.Length = TTColumn(AColumn).Size;
end;

procedure TTSQLUpdateCreator.AddDifference(
  const AEntity: TTEntity;
  const AColumn: TTAbstractColumn;
  const AModel: String;
  const ADatabase: String);
begin
  FDifferences.Append(DifferenceFormat, [
    AEntity.TableName, AColumn.ColumnName, AModel, ADatabase]);
  FHasDifferences := True;
end;

procedure TTSQLUpdateCreator.CompareColumn(
  const AEntity: TTEntity;
  const AColumn: TTAbstractColumn;
  const ASchemaColumn: TTSchemaColumn);
var
  LRequired: Boolean;
begin
  if not SameType(AColumn, ASchemaColumn) then
    AddDifference(
      AEntity,
      AColumn,
      FCreator.ColumnType(AColumn),
      ASchemaColumn.TypeDescription);

  LRequired := FCreator.IsRequired(AColumn);
  if LRequired = ASchemaColumn.AllowNull then
    AddDifference(
      AEntity,
      AColumn,
      NullText(LRequired),
      NullText(not ASchemaColumn.AllowNull));
end;

function TTSQLUpdateCreator.AlignColumns(
  const AEntity: TTEntity; const ATable: TTSchemaTable): Boolean;
var
  LColumn: TTAbstractColumn;
  LSchemaColumn: TTSchemaColumn;
begin
  result := False;
  for LColumn in AEntity.Columns.Columns do
    if not (LColumn is TTLazyListColumn) then
    begin
      LSchemaColumn := ATable.FindColumn(LColumn.ColumnName);
      if Assigned(LSchemaColumn) then
        CompareColumn(AEntity, LColumn, LSchemaColumn)
      else
      begin
        FCreator.AddColumn(FStatements, AEntity, LColumn);
        result := True;
      end;
    end;
end;

procedure TTSQLUpdateCreator.AlignTable(
  const AEntity: TTEntity; const ATable: TTSchemaTable);
begin
  if not FSchema.HasSequence(AEntity.SequenceName) then
  begin
    FCreator.CreateSequence(FStatements, AEntity);
    FHasStatements := True;
  end;

  if AlignColumns(AEntity, ATable) then
  begin
    FStatements.AppendLine;
    FHasStatements := True;
  end;
end;

procedure TTSQLUpdateCreator.AlignEntity(const AEntity: TTEntity);
var
  LTable: TTSchemaTable;
begin
  LTable := FSchema.FindTable(AEntity.TableName);
  if Assigned(LTable) then
    AlignTable(AEntity, LTable)
  else
  begin
    FCreator.CreateSQL(FStatements, AEntity);
    FCreatedTables.Add(AEntity.TableName.ToUpper);
    FHasStatements := True;
  end;
  FCreator.CollectIndexes(AEntity);
end;

function TTSQLUpdateCreator.IndexNeeded(const AIndex: TTIndex): Boolean;
var
  LTable: TTSchemaTable;
begin
  LTable := FSchema.FindTable(AIndex.TableName);
  if Assigned(LTable) then
    result := not LTable.HasIndexOn(AIndex.ColumnName)
  else
    result := FCreatedTables.Contains(AIndex.TableName.ToUpper);
end;

procedure TTSQLUpdateCreator.AlignIndexes;
var
  LIndex: TTIndex;
begin
  for LIndex in FCreator.Indexes do
    if IndexNeeded(LIndex) then
    begin
      FCreator.CreateIndex(FStatements, LIndex);
      FHasStatements := True;
    end;
end;

procedure TTSQLUpdateCreator.AlignEntities(const AEntities: TList<TTEntity>);
var
  LEntity: TTEntity;
begin
  for LEntity in AEntities do
    AlignEntity(LEntity);
  AlignIndexes;
end;

function TTSQLUpdateCreator.ToString: String;
begin
  if not (FHasDifferences or FHasStatements) then
    result := Format('-- %s%s', [SDatabaseAligned, sLineBreak])
  else if not FHasDifferences then
    result := FStatements.ToString
  else
    result := Format('-- %s%s%s%s%s', [
      SDatabaseDifferences,
      sLineBreak,
      FDifferences.ToString,
      sLineBreak,
      FStatements.ToString]);
end;

end.
