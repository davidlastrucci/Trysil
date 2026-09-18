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

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Attributes,
  Trysil.Data,
  Trysil.Filter,
  Trysil.Mapping;

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

{ TTAbstractSelectSyntax }

  TTAbstractSelectSyntax = class abstract
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;
    FFilter: TTFilter;

    procedure AddWhereClause(const AResult: TStringBuilder); virtual;
    procedure AddSoftDeleteWhere(const AResult: TStringBuilder);
    procedure AddFilterWhere(const AResult: TStringBuilder);
    function GetJoins: String;
    function GetWhere: String;
  public
    constructor Create(
      const AConnection: TTConnection;
      const ATableMap: TTTableMap;
      const AFilter: TTFilter);

    property Filter: TTFilter read FFilter;
  end;

{ TTSelectCountSyntax }

  TTSelectCountSyntax = class(TTAbstractSelectSyntax)
  strict protected
    function GetCountSyntax: String; virtual;
    function GetSQL: String; virtual;
  public
    property SQL: String read GetSQL;
  end;

  TTSelectCountSyntaxClass = class of TTSelectCountSyntax;

{ TTSelectSyntax }

  TTSelectSyntax = class abstract(TTAbstractSelectSyntax)
  strict private
    function GetJoinColumn(const AColumnMap: TTColumnMap): String;
  strict protected
    function GetColumns: String; virtual;
    function GetOrderBy: String; virtual;

    function GetSQL: String; virtual;
    function GetFilterPagingSyntax: String; virtual;
  public
    property SQL: String read GetSQL;
  end;

  TTSelectSyntaxClass = class of TTSelectSyntax;

{ TTAbstractSqlSyntax }

  TTAbstractSyntax = class abstract
  strict protected
    FConnection: TTConnection;
    FTableMap: TTTableMap;

    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; virtual; abstract;
  public
    constructor Create(
      const AConnection: TTConnection; const ATableMap: TTTableMap);
  end;

{ TTMetadataSyntax }

  TTMetadataSyntax = class(TTSelectSyntax)
  strict protected
    procedure AddWhereClause(const AResult: TStringBuilder); override;
    function GetFilterPagingSyntax: String; override;
  public
    constructor Create(
      const AConnection: TTConnection; const ATableMap: TTTableMap);
  end;

  TTMetadataSyntaxClass = class of TTMetadataSyntax;

{ TTCommandSyntax }

  TTCommandSyntax = class abstract(TTAbstractSyntax)
  strict protected
    procedure AppendSoftDeleteGuard(
      const AResult: TStringBuilder; const AFirst: Boolean);
  public
    constructor Create(
      const AConnection: TTConnection; const ATableMap: TTTableMap);

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
    function IsUpdatableColumn(const AColumnMap: TTColumnMap): Boolean;
    function GetColumns: String; virtual;
    function GuardsAgainstDeleted: Boolean; virtual;
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTUndeleteSyntax }

  TTUndeleteSyntax = class(TTUpdateSyntax)
  strict private
    procedure AppendValue(
      const AResult: TStringBuilder;
      const AColumnMap: TTColumnMap;
      const AValue: String);
    procedure AppendParameter(
      const AResult: TStringBuilder;
      const AColumnMap: TTColumnMap);
    procedure AppendVersion(const AResult: TStringBuilder);
  strict protected
    function GetColumns: String; override;
    function GuardsAgainstDeleted: Boolean; override;
  end;

{ TTDeleteSyntax }

  TTDeleteSyntax = class(TTCommandSyntax)
  strict protected
    function InternalGetSqlSyntax(
      const AWhereColumns: TArray<TTColumnMap>): String; override;
  end;

{ TTSoftDeleteSyntax }

  TTSoftDeleteSyntax = class(TTCommandSyntax)
  strict private
    procedure AppendAssignment(
      const AResult: TStringBuilder; const AColumnMap: TTColumnMap);
  strict protected
    function GetColumns: String; virtual;
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
    function Select: TTSelectSyntaxClass; virtual;
    function Metadata: TTMetadataSyntaxClass; virtual;
    function Insert: TTCommandSyntaxClass; virtual;
    function Update: TTCommandSyntaxClass; virtual;
    function Delete: TTCommandSyntaxClass; virtual;
    function SoftDelete: TTCommandSyntaxClass; virtual;
    function Undelete: TTCommandSyntaxClass; virtual;
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

{ TTAbstractSelectSyntax }

constructor TTAbstractSelectSyntax.Create(
  const AConnection: TTConnection;
  const ATableMap: TTTableMap;
  const AFilter: TTFilter);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
  FFilter := AFilter;
end;

procedure TTAbstractSelectSyntax.AddWhereClause(const AResult: TStringBuilder);
var
  LParameter: TTWhereParameterMap;
begin
  if not FTableMap.WhereClause.IsEmpty then
  begin
    AResult.AppendFormat('(%s)', [FTableMap.WhereClause]);
    for LParameter in FTableMap.WhereParameters do
      FFilter.AddParameter(
        LParameter.Name, LParameter.DataType, LParameter.Size, LParameter.Value);
  end;
end;

procedure TTAbstractSelectSyntax.AddSoftDeleteWhere(
  const AResult: TStringBuilder);
var
  LDeletedAt: TTColumnMap;
begin
  LDeletedAt := FTableMap.Columns.DeletedChangeTracking.ChangedAt;
  if Assigned(LDeletedAt) then
  begin
    if AResult.Length > 0 then
      AResult.Append(' AND ');
    AResult.AppendFormat('%s IS NULL', [
      FConnection.GetDatabaseObjectName(LDeletedAt.SqlReference)]);
  end;
end;

procedure TTAbstractSelectSyntax.AddFilterWhere(const AResult: TStringBuilder);
begin
  if not FFilter.Where.IsEmpty then
  begin
    if AResult.Length > 0 then
      AResult.Append(' AND ');
    AResult.AppendFormat('(%s)', [FFilter.Where]);
  end;
end;

function TTAbstractSelectSyntax.GetJoins: String;
var
  LResult: TStringBuilder;
  LJoinMap: TTJoinMap;
  LJoinKeyword: String;
begin
  LResult := TStringBuilder.Create;
  try
    for LJoinMap in FTableMap.Joins do
    begin
      case LJoinMap.JoinKind of
        TJoinKind.Inner: LJoinKeyword := 'INNER JOIN';
        TJoinKind.Left: LJoinKeyword := 'LEFT JOIN';
        TJoinKind.Right: LJoinKeyword := 'RIGHT JOIN';
      end;
      LResult.AppendFormat(' %s %s %s ON %s.%s = %s.%s', [
        LJoinKeyword,
        FConnection.GetDatabaseObjectName(LJoinMap.TableName),
        FConnection.GetDatabaseObjectName(LJoinMap.Alias),
        FConnection.GetDatabaseObjectName(LJoinMap.SourceTableOrAlias),
        FConnection.GetDatabaseObjectName(LJoinMap.SourceColumnName),
        FConnection.GetDatabaseObjectName(LJoinMap.Alias),
        FConnection.GetDatabaseObjectName(LJoinMap.TargetColumnName)]);
    end;
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTAbstractSelectSyntax.GetWhere: String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    AddWhereClause(LResult);
    if not FFilter.IncludeDeleted then
      AddSoftDeleteWhere(LResult);
    AddFilterWhere(LResult);
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTSelectCountSyntax }

function TTSelectCountSyntax.GetCountSyntax: String;
begin
  result := 'COUNT(*)';
end;

function TTSelectCountSyntax.GetSQL: String;
var
  LWhere: String;
begin
  result := Format('SELECT %0:s FROM %1:s', [
    GetCountSyntax(),
    FConnection.GetDatabaseObjectName(FTableMap.Name)]);
  if FTableMap.HasJoins then
    result := result + GetJoins();
  LWhere := GetWhere;
  if not LWhere.IsEmpty then
    result := Format('%s WHERE %s', [result, LWhere]);
end;

{ TTSelectSyntax }

function TTSelectSyntax.GetJoinColumn(
  const AColumnMap: TTColumnMap): String;
var
  LTableRef: String;
begin
  if AColumnMap.TableName.IsEmpty then
    LTableRef := FTableMap.Name
  else
    LTableRef := AColumnMap.TableName;

  result := Format('%s.%s AS %s', [
    FConnection.GetDatabaseObjectName(LTableRef),
    FConnection.GetDatabaseObjectName(AColumnMap.Name),
    FConnection.GetDatabaseObjectName(AColumnMap.AliasName)]);
end;

function TTSelectSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
      if FTableMap.HasJoins then
        LResult.AppendFormat('%s, ', [GetJoinColumn(LColumnMap)])
      else
        LResult.AppendFormat('%s, ', [
          FConnection.GetDatabaseObjectName(LColumnMap.Name)]);

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTSelectSyntax.GetFilterPagingSyntax: String;
begin
  result := Format('LIMIT %d OFFSET %d', [
    FFilter.Paging.Limit, FFilter.Paging.Start]);
end;

function TTSelectSyntax.GetOrderBy: String;
var
  LResult: TStringBuilder;
begin
  LResult := TStringBuilder.Create;
  try
    if not FFilter.Paging.OrderBy.IsEmpty then
      LResult.Append(FFilter.Paging.OrderBy)
    else if Assigned(FTableMap.PrimaryKey) then
    begin
      LResult.Append(FConnection.GetDatabaseObjectName(
        FTableMap.PrimaryKey.SqlReference));
    end;

    result := LResult.ToString();
    if not result.IsEmpty then
      result := Format(' ORDER BY %s', [result]);
  finally
    LResult.Free;
  end;
end;

function TTSelectSyntax.GetSQL: String;
var
  LResult: TStringBuilder;
  LWhere: String;
begin
  LResult := TStringBuilder.Create;
  try
    LResult.Append('SELECT ');
    LResult.Append(GetColumns());
    LResult.AppendFormat(' FROM %s', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    if FTableMap.HasJoins then
      LResult.Append(GetJoins());
    LWhere := GetWhere();
    if not LWhere.IsEmpty then
      LResult.AppendFormat(' WHERE %s', [LWhere]);
    LResult.Append(GetOrderBy());
    if not FFilter.Paging.IsEmpty then
      LResult.AppendFormat(' %s', [GetFilterPagingSyntax()]);

    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTAbstractSyntax }

constructor TTAbstractSyntax.Create(
  const AConnection: TTConnection; const ATableMap: TTTableMap);
begin
  inherited Create;
  FConnection := AConnection;
  FTableMap := ATableMap;
end;

{ TTMetadataSyntax }

constructor TTMetadataSyntax.Create(
  const AConnection: TTConnection; const ATableMap: TTTableMap);
begin
  inherited Create(AConnection, ATableMap, TTFilter.Create('0 = 1'));
end;

procedure TTMetadataSyntax.AddWhereClause(const AResult: TStringBuilder);
begin
end;

function TTMetadataSyntax.GetFilterPagingSyntax: string;
begin
  result := String.Empty;
end;

{ TTCommandSyntax }

procedure TTCommandSyntax.AppendSoftDeleteGuard(
  const AResult: TStringBuilder; const AFirst: Boolean);
var
  LDeletedAt: TTColumnMap;
begin
  LDeletedAt := FTableMap.Columns.DeletedChangeTracking.ChangedAt;
  if Assigned(LDeletedAt) then
  begin
    if AFirst then
      AResult.Append(' WHERE ')
    else
      AResult.Append(' AND ');
    AResult.AppendFormat('%s IS NULL', [
      FConnection.GetDatabaseObjectName(LDeletedAt.Name)]);
  end;
end;

constructor TTCommandSyntax.Create(
  const AConnection: TTConnection; const ATableMap: TTTableMap);
begin
  inherited Create(AConnection, ATableMap);
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

function TTUpdateSyntax.IsUpdatableColumn(
  const AColumnMap: TTColumnMap): Boolean;
begin
  result := (AColumnMap <> FTableMap.PrimaryKey) and
    (not FTableMap.Columns.IsCreatedChangeTracking(AColumnMap)) and
    (not FTableMap.Columns.IsDeletedChangeTracking(AColumnMap));
end;

function TTUpdateSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    for LColumnMap in FTableMap.Columns do
      if IsUpdatableColumn(LColumnMap) then
        if LColumnMap = FTableMap.VersionColumn then
          LResult.AppendFormat('%0:s = %0:s + 1, ', [
            FConnection.GetDatabaseObjectName(LColumnMap.Name)])
        else
          LResult.AppendFormat('%0:s = :%1:s, ', [
            FConnection.GetDatabaseObjectName(LColumnMap.Name),
            FConnection.GetParameterName(LColumnMap.Name)]);

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
  LColumns: String;
  LFirst: Boolean;
  LColumnMap: TTColumnMap;
begin
  LColumns := GetColumns();
  if LColumns.IsEmpty then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNoUpdatableColumns), [FTableMap.Name]);

  LResult := TStringBuilder.Create;
  try
    LResult.AppendFormat('UPDATE %s SET ', [
      FConnection.GetDatabaseObjectName(FTableMap.Name)]);
    LResult.Append(LColumns);
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
    if GuardsAgainstDeleted then
      AppendSoftDeleteGuard(LResult, LFirst);
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

function TTUpdateSyntax.GuardsAgainstDeleted: Boolean;
begin
  result := True;
end;

{ TTUndeleteSyntax }

procedure TTUndeleteSyntax.AppendValue(
  const AResult: TStringBuilder;
  const AColumnMap: TTColumnMap;
  const AValue: String);
begin
  if Assigned(AColumnMap) then
    AResult.AppendFormat('%s = %s, ', [
      FConnection.GetDatabaseObjectName(AColumnMap.Name), AValue]);
end;

procedure TTUndeleteSyntax.AppendParameter(
  const AResult: TStringBuilder;
  const AColumnMap: TTColumnMap);
begin
  if Assigned(AColumnMap) then
    AResult.AppendFormat('%0:s = :%1:s, ', [
      FConnection.GetDatabaseObjectName(AColumnMap.Name),
      FConnection.GetParameterName(AColumnMap.Name)]);
end;

procedure TTUndeleteSyntax.AppendVersion(const AResult: TStringBuilder);
begin
  if Assigned(FTableMap.VersionColumn) then
    AResult.AppendFormat('%0:s = %0:s + 1, ', [
      FConnection.GetDatabaseObjectName(FTableMap.VersionColumn.Name)]);
end;

function TTUndeleteSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LDeleted: TTChangeTrackingMap;
  LUpdated: TTChangeTrackingMap;
begin
  LResult := TStringBuilder.Create;
  try
    LDeleted := FTableMap.Columns.DeletedChangeTracking;
    LUpdated := FTableMap.Columns.UpdatedChangeTracking;
    AppendVersion(LResult);
    AppendValue(LResult, LDeleted.ChangedAt, 'NULL');
    AppendValue(LResult, LDeleted.ChangedBy, '''''');
    AppendParameter(LResult, LUpdated.ChangedAt);
    AppendParameter(LResult, LUpdated.ChangedBy);
    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTUndeleteSyntax.GuardsAgainstDeleted: Boolean;
begin
  result := False;
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

{ TTSoftDeleteSyntax }

procedure TTSoftDeleteSyntax.AppendAssignment(
  const AResult: TStringBuilder; const AColumnMap: TTColumnMap);
begin
  if Assigned(AColumnMap) then
    AResult.AppendFormat('%0:s = :%1:s, ', [
      FConnection.GetDatabaseObjectName(AColumnMap.Name),
      FConnection.GetParameterName(AColumnMap.Name)]);
end;

function TTSoftDeleteSyntax.GetColumns: String;
var
  LResult: TStringBuilder;
  LColumnMap: TTColumnMap;
begin
  LResult := TStringBuilder.Create;
  try
    AppendAssignment(
      LResult, FTableMap.Columns.DeletedChangeTracking.ChangedAt);
    AppendAssignment(
      LResult, FTableMap.Columns.DeletedChangeTracking.ChangedBy);

    LColumnMap := FTableMap.VersionColumn;
    if Assigned(LColumnMap) then
      LResult.AppendFormat('%0:s = %0:s + 1, ', [
        FConnection.GetDatabaseObjectName(LColumnMap.Name)]);

    result := LResult.ToString();
    if not result.IsEmpty then
      result := result.Substring(0, result.Length - 2);
  finally
    LResult.Free;
  end;
end;

function TTSoftDeleteSyntax.InternalGetSqlSyntax(
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
    AppendSoftDeleteGuard(LResult, LFirst);
    result := LResult.ToString();
  finally
    LResult.Free;
  end;
end;

{ TTDeleteCascadeSyntax }

constructor TTDeleteCascadeSyntax.Create;
begin
  inherited Create(nil, nil);
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

function TTSyntaxClasses.Select: TTSelectSyntaxClass;
begin
  result := TTSelectSyntax;
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

function TTSyntaxClasses.SoftDelete: TTCommandSyntaxClass;
begin
  result := TTSoftDeleteSyntax;
end;

function TTSyntaxClasses.Undelete: TTCommandSyntaxClass;
begin
  result := TTUndeleteSyntax;
end;

function TTSyntaxClasses.DeleteCascade: TTDeleteCascadeSyntaxClass;
begin
  result := TTDeleteCascadeSyntax;
end;

end.
