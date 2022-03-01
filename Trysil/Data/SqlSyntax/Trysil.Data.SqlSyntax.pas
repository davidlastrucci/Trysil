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

{ TTSequenceSyntax }

  TTSequenceSyntax = class abstract
  strict private
    function GetSQL: String;
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;

    function GetSequenceSyntax: String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTConnection; const ATableMap: TTTableMap);

    property SQL: String read GetSQL;
  end;

  TTSequenceSyntaxClass = class of TTSequenceSyntax;

{ TTCheckExistsSyntax }

  TTCheckExistsSyntax = class
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;
    FTableName: String;
    FColumnName: String;
    FID: TTPrimaryKey;

    function GetSQL: String; virtual;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AID: TTPrimaryKey);

    property SQL: String read GetSQL;
  end;

  TTCheckExistsSyntaxClass = class of TTCheckExistsSyntax;

{ TTSelectCountSyntax }

  TTSelectCountSyntax = class
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;

    function GetSQL: String; virtual;
  public
    constructor Create(
      const AConnection: TTConnection; const ATableMap: TTTableMap);

    property SQL: String read GetSQL;
  end;

  TTSelectCountSyntaxClass = class of TTSelectCountSyntax;

{ TTAbstractSqlSyntax }

  TTAbstractSyntax = class abstract
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;
    FTableMetadata: TTTableMetadata;

    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);
  end;

{ TTSelectSyntax }

  TTSelectSyntax = class abstract(TTAbstractSyntax)
  strict private
    function GetSQL: String;
  strict protected
    FFilter: TTFilter;

    function GetColumns: String; virtual;
    function GetOrderBy: String; virtual;

    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;

    function GetFilterPagingSyntax: String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);

    property SQL: String read GetSQL;
  end;

  TTSelectSyntaxClass = class of TTSelectSyntax;

{ TTMetadataSyntax }

  TTMetadataSyntax = class(TTSelectSyntax)
  strict protected
    function GetFilterPagingSyntax: String; override;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);
  end;

  TTMetadataSyntaxClass = class of TTMetadataSyntax;

{ TTCommandSyntax }

  TTCommandSyntax = class abstract(TTAbstractSyntax)
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    function GetSqlSyntax(const AWhereColumns: TArray<TTColumnMap>): String;
  end;

  TTCommandSyntaxClass = class of TTCommandSyntax;

{ TTInsertSyntax }

  TTInsertSyntax = class(TTCommandSyntax)
  strict protected
    function GetColumns: String; virtual;
    function GetParameters: String; virtual;
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTUpdateSyntax }

  TTUpdateSyntax = class(TTCommandSyntax)
  strict protected
    function GetColumns: String; virtual;
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTDeleteSyntax }

  TTDeleteSyntax = class(TTCommandSyntax)
  strict protected
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTDeleteCascadeSyntax }

  TTDeleteCascadeSyntax = class(TTCommandSyntax)
  strict protected
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  public
    constructor Create;

    function GetSqlSyntax: String;
  end;

  TTDeleteCascadeSyntaxClass = class of TTDeleteCascadeSyntax;

{ TTVersionSyntax }

  TTVersionSyntax = class
  strict protected
    function GetSQL: String; virtual; abstract;
  public
    property SQL: String read GetSQL;
  end;

  TTVersionSyntaxClass = class of TTVersionSyntax;

{ TTSyntaxClasses }

  TTSyntaxClasses = class abstract
  public
    function Sequence: TTSequenceSyntaxClass; virtual; abstract;
    function CheckExists: TTCheckExistsSyntaxClass; virtual;
    function SelectCount: TTSelectCountSyntaxClass; virtual;
    function Select: TTSelectSyntaxClass; virtual; abstract;
    function Metadata: TTMetadataSyntaxClass; virtual;
    function Insert: TTCommandSyntaxClass; virtual;
    function Update: TTCommandSyntaxClass; virtual;
    function Delete: TTCommandSyntaxClass; virtual;
    function DeleteCascade: TTDeleteCascadeSyntaxClass; virtual;
    function Version: TTVersionSyntaxClass; virtual; abstract;
  end;

implementation

{ TTSequenceSyntax }

constructor TTSequenceSyntax.Create(
  const AConnection: TTConnection; const ATableMap: TTTableMap);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
end;

function TTSequenceSyntax.GetSQL: String;
begin
  result := GetSequenceSyntax;
end;

{ TTCheckExistsSyntax }

constructor TTCheckExistsSyntax.Create(
  const AConnection: TTConnection;
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

function TTCheckExistsSyntax.GetSQL: String;
begin
  result := Format('SELECT COUNT(*) FROM %0:s WHERE %1:s = %2:d', [
    FConnection.GetDatabaseObjectName(FTableName),
    FConnection.GetDatabaseObjectName(FColumnName),
    FID]);
end;

{ TTSelectCountSyntax }

constructor TTSelectCountSyntax.Create(
  const AConnection: TTConnection; const ATableMap: TTTableMap);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
end;

function TTSelectCountSyntax.GetSQL: String;
begin
  result := Format('SELECT COUNT(*) FROM %0:s', [
    FConnection.GetDatabaseObjectName(FTableMap.Name)]);
end;

{ TTAbstractSyntax }

constructor TTAbstractSyntax.Create(
  const AConnection: TTConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
  FTableMetadata := ATableMetadata;
end;

{ TTSelectSyntax }

constructor TTSelectSyntax.Create(
  const AConnection: TTConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(AConnection, ATableMap, ATableMetadata);
  FFilter := AFilter;
end;

function TTSelectSyntax.GetColumns: String;
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

function TTSelectSyntax.GetOrderBy: String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append(' ORDER BY ');
    if not FFilter.Paging.OrderBy.IsEmpty then
      LResult.Append(FFilter.Paging.OrderBy)
    else if Assigned(FTableMap.PrimaryKey) then
      LResult.Append(
        FConnection.GetDatabaseObjectName(FTableMap.PrimaryKey.Name));

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTSelectSyntax.InternalGetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append('SELECT ');
    LResult.Append(GetColumns());
    LResult.AppendFormat(' FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    if not FFilter.Where.IsEmpty then
      LResult.AppendFormat(' WHERE %s', [FFilter.Where]);
    LResult.Append(GetOrderBy());
    if not FFilter.Paging.IsEmpty then
      LResult.AppendFormat(' %s', [GetFilterPagingSyntax()]);

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTSelectSyntax.GetSQL: String;
begin
  result := InternalGetSqlSyntax([]);
end;

{ TTMetadataSyntax }

constructor TTMetadataSyntax.Create(
  const AConnection: TTConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(
    AConnection, ATableMap, ATableMetadata, TTFilter.Create('0 = 1'));
end;

function TTMetadataSyntax.GetFilterPagingSyntax: string;
begin
  result := String.Empty;
end;

{ TTCommandSyntax }

constructor TTCommandSyntax.Create(
  const AConnection: TTConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(AConnection, ATableMap, ATableMetadata);
end;

function TTCommandSyntax.GetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
begin
  result := InternalGetSqlSyntax(AWhereColumns);
end;

{ TTInsertSyntax }

function TTInsertSyntax.GetColumns: String;
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

function TTInsertSyntax.GetParameters: String;
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

function TTInsertSyntax.InternalGetSqlSyntax(
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

{ TTUpdateSyntax }

function TTUpdateSyntax.GetColumns: String;
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

function TTUpdateSyntax.InternalGetSqlSyntax(
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

{ TTDeleteSyntax }

function TTDeleteSyntax.InternalGetSqlSyntax(
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

{ TTDeleteCascadeSyntax }

constructor TTDeleteCascadeSyntax.Create;
begin
  inherited Create(nil, nil, nil);
end;

function TTDeleteCascadeSyntax.GetSqlSyntax: String;
begin
  result := InternalGetSqlSyntax([]);
end;

function TTDeleteCascadeSyntax.InternalGetSqlSyntax(
  const AWhereColumns: TArray<TTColumnMap>): String;
begin
  result := 'DELETE FROM %0:s WHERE %1:s = %2:s';
end;

{ TTSyntaxClasses }

function TTSyntaxClasses.CheckExists: TTCheckExistsSyntaxClass;
begin
  result := TTCheckExistsSyntax;
end;

function TTSyntaxClasses.SelectCount: TTSelectCountSyntaxClass;
begin
  result := TTSelectCountSyntax;
end;

function TTSyntaxClasses.Metadata: TTMetadataSyntaxClass;
begin
  result := TTMetadataSyntax;
end;

function TTSyntaxClasses.Insert: TTCommandSyntaxClass;
begin
  result := TTInsertSyntax;
end;

function TTSyntaxClasses.Update: TTCommandSyntaxClass;
begin
  result := TTUpdateSyntax;
end;

function TTSyntaxClasses.Delete: TTCommandSyntaxClass;
begin
  result := TTDeleteSyntax;
end;

function TTSyntaxClasses.DeleteCascade: TTDeleteCascadeSyntaxClass;
begin
  result := TTDeleteCascadeSyntax;
end;

end.
