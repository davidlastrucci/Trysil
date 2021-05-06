(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.SqlSyntax;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Data,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Rtti,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Events.Abstract,
  Trysil.Data.Parameters;

type

{ TTDataSequenceSyntax }

  TTDataSequenceSyntax = class abstract
  strict protected
    FConnection: TTDataConnection;
    FSequenceName: String;

    function GetID: TTPrimaryKey; virtual;
    function GetSequenceSyntax: String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTDataConnection; const ASequenceName: String);

    property ID: TTPrimaryKey read GetID;
  end;

  TTDataSequenceSyntaxClass = class of TTDataSequenceSyntax;

{ TTDataSelectCountSyntax }

  TTDataSelectCountSyntax = class
  strict protected
    FConnection: TTDataConnection;
    FTableMap: TTTableMap;
    FTableName: String;
    FColumnName: String;
    FID: TTPrimaryKey;

    function GetCount: Integer; virtual;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AID: TTPrimaryKey);

    property Count: Integer read GetCount;
  end;

  TTDataSelectCountSyntaxClass = class of TTDataSelectCountSyntax;

{ TTDataAbstractSqlSyntax }

  TTDataAbstractSyntax = class abstract
  strict protected
    FConnection: TTDataConnection;
    FMapper: TTMapper;
    FTableMap: TTTableMap;
    FTableMetadata: TTTableMetadata;

    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);
  end;

{ TTDataSelectSyntax }

  TTDataSelectSyntax = class abstract(TTDataAbstractSyntax)
  strict private
    FDataset: TDataSet;

    function GetDataset: TDataset;
  strict protected
    FFilter: TTFilter;

    function GetColumns: String; virtual;
    function GetOrderBy: String; virtual;
    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;

    function GetFilterTopSyntax: String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property Dataset: TDataset read GetDataset;
  end;

  TTDataSelectSyntaxClass = class of TTDataSelectSyntax;

{ TTDataMetadataSyntax }

  TTDataMetadataSyntax = class(TTDataSelectSyntax)
  strict protected
    function GetFilterTopSyntax: String; override;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);
  end;

  TTDataMetadataSyntaxClass = class of TTDataMetadataSyntax;

{ TTDataCommandSyntax }

  TTDataCommandSyntax = class abstract(TTDataAbstractSyntax)
  strict protected
    procedure BeforeExecute(
      const AEntity: TObject; const AEvent: TTEvent); virtual;
    procedure AfterExecute(
      const AEntity: TObject; const AEvent: TTEvent); virtual;
  public
    constructor Create(
      const AConnection: TTDataConnection;
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject;
      const AEvent: TTEvent;
      const AWhereColumns: TArray<TTColumnMap>);
  end;

  TTDataCommandSyntaxClass = class of TTDataCommandSyntax;

{ TTDataInsertSyntax }

  TTDataInsertSyntax = class(TTDataCommandSyntax)
  strict protected
    function GetColumns: String; virtual;
    function GetParameters: String; virtual;
    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTDataUpdateSyntax }

  TTDataUpdateSyntax = class(TTDataCommandSyntax)
  strict protected
    function GetColumns: String; virtual;
    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTDataDeleteSyntax }

  TTDataDeleteSyntax = class(TTDataCommandSyntax)
  strict protected
    procedure BeforeExecute(
      const AEntity: TObject; const AEvent: TTEvent); override;
    function GetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTDataSyntaxClasses }

  TTDataSyntaxClasses = class abstract
  public
    function Sequence: TTDataSequenceSyntaxClass; virtual; abstract;
    function SelectCount: TTDataSelectCountSyntaxClass; virtual;
    function Select: TTDataSelectSyntaxClass; virtual; abstract;
    function Metadata: TTDataMetadataSyntaxClass; virtual;
    function Insert: TTDataCommandSyntaxClass; virtual;
    function Update: TTDataCommandSyntaxClass; virtual;
    function Delete: TTDataCommandSyntaxClass; virtual;
  end;

implementation

{ TTDataSequenceSyntax }

constructor TTDataSequenceSyntax.Create(
  const AConnection: TTDataConnection; const ASequenceName: String);
begin
  inherited Create;
  FConnection := AConnection;
  FSequenceName := ASequenceName;
end;

function TTDataSequenceSyntax.GetID: TTPrimaryKey;
var
  LDataset: TDataSet;
begin
  LDataset := FConnection.CreateDataSet(GetSequenceSyntax);
  try
    LDataset.Open;
    result := LDataset.Fields[0].AsInteger;
  finally
    LDataset.Free;
  end;
end;

{ TTDataSelectCountSyntax }

constructor TTDataSelectCountSyntax.Create(
  const AConnection: TTDataConnection;
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AID: TTPrimaryKey);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FID := AID;
end;

function TTDataSelectCountSyntax.GetCount: Integer;
var
  LDataset: TDataSet;
begin
  LDataset := FConnection.CreateDataSet(
    Format('SELECT COUNT(*) FROM %0:s WHERE %1:s = %2:d', [
      FConnection.GetDatabaseObjectName(FTableName),
      FConnection.GetDatabaseObjectName(FColumnName),
      FID]));
  try
    LDataset.Open;
    result := LDataset.Fields[0].AsInteger;
  finally
    LDataset.Free;
  end;
end;

{ TTDataAbstractSyntax }

constructor TTDataAbstractSyntax.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create;
  FConnection := AConnection;
  FMapper := AMapper;
  FTableMap := ATableMap;
  FTableMetadata := ATableMetadata;
end;

{ TTDataSelectSyntax }

constructor TTDataSelectSyntax.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(AConnection, AMapper, ATableMap, ATableMetadata);
  FFilter := AFilter;
end;

destructor TTDataSelectSyntax.Destroy;
begin
  FDataset.Free;
  inherited;
end;

procedure TTDataSelectSyntax.AfterConstruction;
begin
  inherited AfterConstruction;
  FDataset := FConnection.CreateDataSet(GetSqlSyntax([]));
  FDataset.Open;
end;

function TTDataSelectSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
      LResult.AppendFormat('%s, ', [
        FConnection.GetDatabaseObjectName(LColumnMap.Name)]);

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTDataSelectSyntax.GetDataset: TDataset;
begin
  result := FDataset;
end;

function TTDataSelectSyntax.GetOrderBy: String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    if (not FFilter.Top.OrderBy.IsEmpty) then
      LResult.AppendFormat(' ORDER BY %s, ', [FFilter.Top.OrderBy])
    else if Assigned(FTableMap.PrimaryKey) then
      LResult.AppendFormat(' ORDER BY %s, ', [
        FConnection.GetDatabaseObjectName(FTableMap.PrimaryKey.Name)]);

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTDataSelectSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append('SELECT ');
    if FFilter.Top.MaxRecord > 0 then
      LResult.AppendFormat('%s ', [GetFilterTopSyntax]);
    LResult.Append(GetColumns());
    LResult.AppendFormat(' FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    if not FFilter.Where.IsEmpty then
      LResult.AppendFormat(' WHERE %s', [FFilter.Where]);
    LResult.Append(GetOrderBy());

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTDataMetadataSyntax }

constructor TTDataMetadataSyntax.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(
    AConnection, AMapper, ATableMap, ATableMetadata, TTFilter.Create('0 = 1'));
end;

function TTDataMetadataSyntax.GetFilterTopSyntax: String;
begin
  result := String.Empty;
end;

{ TTDataCommandSyntax }

constructor TTDataCommandSyntax.Create(
  const AConnection: TTDataConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(AConnection, AMapper, ATableMap, ATableMetadata);
end;

procedure TTDataCommandSyntax.BeforeExecute(
  const AEntity: TObject; const AEvent: TTEvent);
begin
  if Assigned(AEvent) then
    AEvent.DoBefore;
end;

procedure TTDataCommandSyntax.AfterExecute(
  const AEntity: TObject; const AEvent: TTEvent);
begin
  if Assigned(AEvent) then
    AEvent.DoAfter;
end;

procedure TTDataCommandSyntax.Execute(
  const AEntity: TObject;
  const AEvent: TTEvent;
  const AWhereColumns: TArray<TTColumnMap>);
var
  LLocalTransaction: Boolean;
  LRowsAffected: Integer;
begin
  LLocalTransaction := not FConnection.InTransaction;
  if LLocalTransaction then
    FConnection.StartTransaction;
  try
    BeforeExecute(AEntity, AEvent);

    LRowsAffected := FConnection.Execute(
      GetSqlSyntax(AWhereColumns),
      FMapper,
      FTableMap,
      FTableMetadata,
      AEntity);

    if LRowsAffected = 0 then
      raise ETException.Create(SRecordChanged)
    else if LRowsAffected > 1 then
      raise ETException.Create(SSyntaxError);

    AfterExecute(AEntity, AEvent);

    if LLocalTransaction then
      FConnection.CommitTransaction;
  except
    if LLocalTransaction then
      FConnection.RollbackTransaction;
    raise;
  end;
end;

{ TTDataInsertSyntax }

function TTDataInsertSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
      LResult.AppendFormat('%s, ', [
        FConnection.GetDatabaseObjectName(LColumnMap.Name)]);

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTDataInsertSyntax.GetParameters: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
      if (LColumnMap <> FTableMap.VersionColumn) then
        LResult.AppendFormat(':%s, ', [
          FConnection.GetParameterName(LColumnMap.Name)])
      else
        LResult.Append('0, ');

    result := LResult.ToString();
    result := result.SubString(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTDataInsertSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.AppendFormat('INSERT INTO %s (', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    LResult.Append(GetColumns());
    LResult.Append(') VALUES (');
    LResult.Append(GetParameters());
    LResult.Append(')');

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTDataUpdateSyntax }

function TTDataUpdateSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
    begin
      if LColumnMap = FTableMap.PrimaryKey then
      else if LColumnMap = FTableMap.VersionColumn then
        LResult.AppendFormat('%0:s = %0:s + 1, ', [
          FConnection.GetDatabaseObjectName(LColumnMap.Name)])
      else
        LResult.AppendFormat('%0:s = :%1:s, ', [
          FConnection.GetDatabaseObjectName(LColumnMap.Name),
          FConnection.GetParameterName(LColumnMap.Name)]);
    end;

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTDataUpdateSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
  LFirst: Boolean;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.AppendFormat('UPDATE %s SET ', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    LResult.Append(GetColumns());
    LFirst := True;
    for LColumnMap in AWhereColumns do
    begin
      if LFirst then
        LResult.Append(' WHERE ')
      else
        LResult.Append(' AND ');

      LResult.AppendFormat('%0:s = :%1:s', [
        FConnection.GetDatabaseObjectName(LColumnMap.Name),
        FConnection.GetParameterName(LColumnMap.Name)]);

      LFirst := False;
    end;
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTDataDeleteSyntax }

procedure TTDataDeleteSyntax.BeforeExecute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LID: TTPrimaryKey;
  LRelation: TTRelationMap;
begin
  inherited BeforeExecute(AEntity, AEvent);
  LID := FTableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  for LRelation in FTableMap.Relations do
    if LRelation.IsCascade then
    begin
      FConnection.Execute(Format('DELETE FROM %0:s WHERE %1:s = %1:d', [
        FConnection.GetDatabaseObjectName(LRelation.TableName),
        FConnection.GetDatabaseObjectName(LRelation.ColumnName),
        LID]));
    end;
end;

function TTDataDeleteSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
  LFirst: Boolean;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.AppendFormat('DELETE FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    LFirst := True;
    for LColumnMap in AWhereColumns do
    begin
      if LFirst then
        LResult.Append(' WHERE ')
      else
        LResult.Append(' AND ');

      LResult.AppendFormat('%0:s = :%1:s', [
        FConnection.GetDatabaseObjectName(LColumnMap.Name),
        FConnection.GetParameterName(LColumnMap.Name)]);

      LFirst := False;
    end;
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTDataSyntaxClasses }

function TTDataSyntaxClasses.SelectCount: TTDataSelectCountSyntaxClass;
begin
  result := TTDataSelectCountSyntax;
end;

function TTDataSyntaxClasses.Metadata: TTDataMetadataSyntaxClass;
begin
  result := TTDataMetadataSyntax;
end;

function TTDataSyntaxClasses.Insert: TTDataCommandSyntaxClass;
begin
  result := TTDataInsertSyntax;
end;

function TTDataSyntaxClasses.Update: TTDataCommandSyntaxClass;
begin
  result := TTDataUpdateSyntax;
end;

function TTDataSyntaxClasses.Delete: TTDataCommandSyntaxClass;
begin
  result := TTDataDeleteSyntax;
end;

end.
