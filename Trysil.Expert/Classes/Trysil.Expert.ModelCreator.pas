(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.ModelCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  ToolsAPI,

  Trysil.Expert.Config,
  Trysil.Expert.SourceWriter,
  Trysil.Expert.Model,
  Trysil.Expert.IOTA.ModuleCreator;

type

{ TTModelCreator }

  TTModelCreator = class
  strict private
    FProjectName: String;
    FUnitNames: String;
    FPascalDirectory: String;

    procedure AddUses(
      const ASource: TTSourceWriter;
      const AColumns: TEnumerable<TTAbstractColumn>;
      const AUses: TEnumerable<TTEntity>);
    procedure AddRelations(
      const ASource: TTSourceWriter; const ARelations: TEnumerable<TTRelation>);
    procedure AddFields(
      const ASource: TTSourceWriter;
      const AColumns: TEnumerable<TTAbstractColumn>);
    procedure AddGetterAndSetter(
      const ASource: TTSourceWriter;
      const AColumns: TEnumerable<TTAbstractColumn>);
    procedure AddProperties(
      const ASource: TTSourceWriter;
      const AColumns: TEnumerable<TTAbstractColumn>);
    procedure AddGetterAndSetterImplementation(
      const ASource: TTSourceWriter;
      const AEntity: TTEntity);

    procedure CreateModel(
      const AEntity: TTEntity;
      const AUses: TEnumerable<TTEntity>;
      const ARelations: TEnumerable<TTRelation>);

    procedure CreateUnit(
      const AName: String; const ASource: TTSourceWriter);
  public
    constructor Create(
      const AProjectName: String;
      const AUnitNames: String;
      const APascalDirectory: String);

    procedure CreateModels(
      const AAll: TTEntities; const ASelected: TList<TTEntity>);
  end;

implementation

{ TTModelCreator }

constructor TTModelCreator.Create(
  const AProjectName: String;
  const AUnitNames: String;
  const APascalDirectory: String);
begin
  inherited Create;
  FProjectName := AProjectName;
  FUnitNames := AUnitNames;
  FPascalDirectory := APascalDirectory;
end;

procedure TTModelCreator.CreateModels(
  const AAll: TTEntities; const ASelected: TList<TTEntity>);
var
  LEntity: TTEntity;
begin
  for LEntity in ASelected do
    CreateModel(
      LEntity, AAll.EntityUses[LEntity], AAll.EntityRelations[LEntity]);
end;

procedure TTModelCreator.AddUses(
  const ASource: TTSourceWriter;
  const AColumns: TEnumerable<TTAbstractColumn>;
  const AUses: TEnumerable<TTEntity>);
var
  LGenerics, LLazy: Boolean;
  LColumn: TTAbstractColumn;
  LUses: TList<String>;
  LUse: TTEntity;
  LIndex: Integer;
begin
  LGenerics := False;
  LLazy := False;
  for LColumn in AColumns do
    if LColumn is TTObjectColumn then
    begin
      LLazy := True;
      if LColumn is TTLazyListColumn then
        LGenerics := True;
    end;

  LUses := TList<String>.Create;
  try
    for LUse in AUses do
      LUses.Add(TTUtils.UnitName(FUnitNames, FProjectName, LUse.Name));

    ASource.Append('uses');
    ASource.Append('  System.Classes,');
    ASource.Append('  System.SysUtils,');
    ASource.Append('  Trysil.Types,');
    ASource.Append('  Trysil.Attributes,');

    if not LLazy then
      ASource.Append('  Trysil.Validation.Attributes;')
    else
    begin
      ASource.Append('  Trysil.Validation.Attributes,');
      if LGenerics then
        ASource.Append('  Trysil.Generics.Collections,');
      if LUses.Count = 0 then
        ASource.Append('  Trysil.Lazy;')
      else
      begin
        ASource.Append('  Trysil.Lazy,');

        ASource.AppendLine;
        for LIndex := 0 to LUses.Count - 1 do
          if LIndex = LUses.Count - 1 then
            ASource.Append('  %s;', [LUses[LIndex]])
          else
            ASource.Append('  %s,', [LUses[LIndex]])
      end;
    end;
  finally
    LUses.Free;
  end;
end;

procedure TTModelCreator.AddRelations(
  const ASource: TTSourceWriter; const ARelations: TEnumerable<TTRelation>);
const
  BoolValues: array [boolean] of String = ('False', 'True');
var
  LRelation: TTRelation;
begin
  for LRelation in ARelations do
    ASource.Append('  [TRelation(''%s'', ''%s'', %s)]', [
      LRelation.TableName,
      LRelation.ColumnName,
      BoolValues[LRelation.Cascade]]);
end;

procedure TTModelCreator.AddFields(
  const ASource: TTSourceWriter;
  const AColumns: TEnumerable<TTAbstractColumn>);
var
  LFirst: Boolean;
  LColumn: TTAbstractColumn;
begin
  LFirst := True;
  for LColumn in AColumns do
  begin
    if not LFirst then
      ASource.AppendLine;
    LFirst := False;

    if LColumn.Required then
      ASource.Append('    [TRequired]');
    if LColumn is TTColumn then
    begin
      if TTColumn(LColumn).Size <> 0 then
        ASource.Append('    [TMaxLength(%d)]', [TTColumn(LColumn).Size]);
      case TTColumn(LColumn).DataType of
        TTDataType.dtPrimaryKey:
          ASource.Append('    [TPrimaryKey]');
        TTDataType.dtVersion:
          ASource.Append('    [TVersionColumn]');
      end;
    end;

    if LColumn is TTLazyListColumn then
      ASource.Append('    [TDetailColumn(''ID'', ''%s'')]', [
        LColumn.ColumnName])
    else
      ASource.Append('    [TColumn(''%s'')]', [LColumn.ColumnName]);

    if LColumn is TTColumn then
      ASource.Append('    F%s: %s;', [LColumn.Name, LColumn.ColumnType])
    else if LColumn is TTLazyColumn then
      ASource.Append('    F%s: TTLazy<T%s>;', [
        LColumn.Name, TTObjectColumn(LColumn).ObjectName])
    else if LColumn is TTLazyListColumn then
      ASource.Append('    F%s: TTLazyList<T%s>;', [
        LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
  end;
end;

procedure TTModelCreator.AddGetterAndSetter(const ASource: TTSourceWriter;
  const AColumns: TEnumerable<TTAbstractColumn>);
var
  LFirst: Boolean;
  LColumn: TTAbstractColumn;
begin
  LFirst := True;
  for LColumn in AColumns do
    if LColumn is TTObjectColumn then
    begin
      if LFirst then
        ASource.AppendLine;
      LFirst := False;

      if LColumn is TTLazyColumn then
      begin
        ASource.Append('    function Get%s: T%s;', [
          LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
        ASource.Append('    procedure Set%s(const AValue: T%s);', [
          LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
      end
      else
        ASource.Append('    function Get%s: TTList<T%s>;', [
          LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
    end;
end;

procedure TTModelCreator.AddProperties(
  const ASource: TTSourceWriter;
  const AColumns: TEnumerable<TTAbstractColumn>);
var
  LColumn: TTAbstractColumn;
begin
  for LColumn in AColumns do
    if LColumn is TTColumn then
    begin
      if TTColumn(LColumn).DataType in [
        TTDataType.dtPrimaryKey, TTDataType.dtVersion] then
        ASource.Append('    property %0:s: %1:s read F%0:s;', [
          LColumn.Name, LColumn.ColumnType])
      else
        ASource.Append('    property %0:s: %1:s read F%0:s write F%0:s;', [
          LColumn.Name, LColumn.ColumnType]);
    end
    else if LColumn is TTLazyColumn then
        ASource.Append('    property %0:s: T%1:s read Get%0:s write Set%0:s;', [
          LColumn.Name, TTObjectColumn(LColumn).ObjectName])
    else if LColumn is TTLazyListColumn then
        ASource.Append('    property %0:s: TTList<T%1:s> read Get%0:s;', [
          LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
end;

procedure TTModelCreator.AddGetterAndSetterImplementation(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
var
  LFirst: Boolean;
  LColumn: TTAbstractColumn;
begin
  LFirst := True;
  for LColumn in AEntity.Columns.Columns do
    if LColumn is TTObjectColumn then
    begin
      if LFirst then
      begin
        ASource.Append('{ T%s }', [AEntity.Name]);
        ASource.AppendLine;
      end;
      LFirst := False;

      if LColumn is TTLazyColumn then
        ASource.Append('function T%s.Get%s: T%s;', [
          AEntity.Name, LColumn.Name, TTObjectColumn(LColumn).ObjectName])
      else
        ASource.Append('function T%s.Get%s: TTList<T%s>;', [
          AEntity.Name, LColumn.Name, TTObjectColumn(LColumn).ObjectName]);

      ASource.Append('begin');
      if LColumn is TTLazyColumn then
        ASource.Append('  result := F%s.Entity;', [LColumn.Name])
      else
        ASource.Append('  result := F%s.List;', [LColumn.Name]);
      ASource.Append('end;');
      ASource.AppendLine;

      if LColumn is TTLazyColumn then
      begin
        ASource.Append('procedure T%s.Set%s(const AValue: T%s);', [
          AEntity.Name, LColumn.Name, TTObjectColumn(LColumn).ObjectName]);
        ASource.Append('begin');
        ASource.Append('  F%s.Entity := AValue;', [LColumn.Name]);
        ASource.Append('end;');
        ASource.AppendLine;
      end;
    end;
end;

procedure TTModelCreator.CreateModel(
  const AEntity: TTEntity;
  const AUses: TEnumerable<TTEntity>;
  const ARelations: TEnumerable<TTRelation>);
var
  LSource: TTSourceWriter;
  LUnitName: String;
begin
  LSource := TTSourceWriter.Create;
  try
    LUnitName := TTUtils.UnitName(FUnitNames, FProjectName, AEntity.Name);

    LSource.Append('unit %s;', [LUnitName]);
    LSource.AppendLine;
    LSource.Append('{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}');
    LSource.AppendLine;
    LSource.Append('interface');
    LSource.AppendLine;
    AddUses(LSource, AEntity.Columns.Columns, AUses);
    LSource.AppendLine;
    LSource.Append('type');
    LSource.AppendLine;
    LSource.Append('{ T%s }', [AEntity.Name]);
    LSource.AppendLine;
    LSource.Append('  [TTable(''%s'')]', [AEntity.TableName]);
    LSource.Append('  [TSequence(''%s'')]', [AEntity.SequenceName]);
    AddRelations(LSource, ARelations);
    LSource.Append('  T%s = class', [AEntity.Name]);
    LSource.Append('  strict private');
    AddFields(LSource, AEntity.Columns.Columns);
    AddGetterAndSetter(LSource, AEntity.Columns.Columns);
    LSource.Append('  public');
    AddProperties(LSource, AEntity.Columns.Columns);
    LSource.Append('  end;');
    LSource.AppendLine;
    LSource.Append('implementation');
    LSource.AppendLine;
    AddGetterAndSetterImplementation(LSource, AEntity);
    LSource.Append('end.');

    CreateUnit(TPath.Combine(FPascalDirectory, LUnitName), LSource);
  finally
    LSource.Free;
  end;
end;

procedure TTModelCreator.CreateUnit(
  const AName: String; const ASource: TTSourceWriter);
var
  LModuleServices: IOTAModuleServices;
  LProject: IOTAProject;
  LModule: IOTAModule;
begin
  if BorlandIDEServices.SupportsService(IOTAModuleServices) then
  begin
    LModuleServices := (BorlandIDEServices as IOTAModuleServices);
    LProject := LModuleServices.GetActiveProject;
    if Assigned(LProject) then
    begin
      LModule := LModuleServices.CreateModule(
        TTModuleCreator.Create(AName, ASource.ToString));
      if Assigned(LModule) then
      begin
        LProject.AddFile(LModule.FileName, True);
        // LModule.Save(False, True);
      end;
    end;
  end;
end;

end.
