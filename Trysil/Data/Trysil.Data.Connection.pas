(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Classes,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Logger,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Filter,
  Trysil.Transaction,
  Trysil.Events.Abstract,
  Trysil.Data.SqlSyntax;

type

{ TTGenericConnection }

  TTGenericConnection = class abstract(TTConnection)
  strict private
    FConnectionID: String;
    FSyntaxClasses: TTSyntaxClasses;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; virtual; abstract;

    function FindColumnMap(
      const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;

    function GetColumnMap(
      const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;

    function GetConnectionID: String; override;
    procedure ProbeFailed(
      const ATableMap: TTTableMap;
      const AException: Exception);
    function GetSqlReference(
      const AColumnMap: TTColumnMap;
      const AColumnName: String): String;
    procedure ReadMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const ADataset: TDataset);
    procedure CheckParameterNames(
      const ATableMetadata: TTTableMetadata);
    procedure InternalGetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const ASyntax: TTMetadataSyntax);
    function GetDatabaseVersion: String; override;

    function CheckExists(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Boolean; override;

    procedure InternalStartTransaction; virtual; abstract;
    procedure InternalCommitTransaction; virtual; abstract;
    procedure InternalRollbackTransaction; virtual; abstract;

    procedure RollbackFailedCommit;
  public
    constructor Create;
    destructor Destroy; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    function SelectCount(
      const ATableMap: TTTableMap;
      const AFilter: TTFilter): Int64; override;

    function CreateReader(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTReader; override;

    function CreateInsertCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateUpdateCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateSoftDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateUndeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ATableMap: TTTableMap): TTPrimaryKey; override;

    property SyntaxClasses: TTSyntaxClasses read FSyntaxClasses;
  end;

{ TTGenericReader }

  TTGenericReader = class(TTReader)
  strict private
    FConnection: TTGenericConnection;
    FSyntax: TTSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTGenericCommand }

  TTGenericCommand = class(TTAbstractCommand)
  strict protected
    FConnection: TTGenericConnection;

    procedure InvokeEvents(
      const AEntity: TObject;
      const AEventMethodType: TTEventMethodType); virtual;

    procedure BeforeExecute(
      const AEntity: TObject;
      const AEvent: TTEvent;
      const AEventMethodType: TTEventMethodType); virtual;
    procedure AfterExecute(
      const AEntity: TObject;
      const AEvent: TTEvent;
      const AEventMethodType: TTEventMethodType); virtual;

    procedure ExecuteCommand(
      const ASQL: String;
      const AEntity: TObject;
      const AEvent: TTEvent;
      const ABeforeEventMethodType: TTEventMethodType;
      const AAfterEventMethodType: TTEventMethodType);
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AUpdateMode: TTUpdateMode);
  end;

{ TTGenericInsertCommand }

  TTGenericInsertCommand = class(TTGenericCommand)
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
  end;

{ TTGenericUpdateCommand }

  TTGenericUpdateCommand = class(TTGenericCommand)
  strict protected
    function GetSyntaxClass: TTCommandSyntaxClass; virtual;
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
  end;

{ TTGenericUndeleteCommand }

  TTGenericUndeleteCommand = class(TTGenericUpdateCommand)
  strict protected
    function GetSyntaxClass: TTCommandSyntaxClass; override;
  end;

{ TTGenericSoftDeleteCommand }

  TTGenericSoftDeleteCommand = class(TTGenericCommand)
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
  end;

{ TTGenericDeleteCommand }

  TTGenericDeleteCommand = class(TTGenericCommand)
  strict protected
    procedure BeforeExecute(
      const AEntity: TObject;
      const AEvent: TTEvent;
      const AEventMethodType: TTEventMethodType); override;
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
  end;

implementation

{ TTGenericConnection }

constructor TTGenericConnection.Create;
begin
  inherited Create;
  FConnectionID := TGUID.NewGuid().ToString().ToLower().Substring(1, 36);
  FSyntaxClasses := CreateSyntaxClasses;
end;

destructor TTGenericConnection.Destroy;
begin
  FSyntaxClasses.Free;
  inherited Destroy;
end;

procedure TTGenericConnection.StartTransaction;
begin
  if InTransaction then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SInTransaction), ['StartTransaction']);
  TTLogger.Instance.LogStartTransaction(FConnectionID);
  InternalStartTransaction;
  inherited StartTransaction;
end;

procedure TTGenericConnection.RollbackFailedCommit;
begin
  TTLogger.Instance.LogRollback(FConnectionID);
  try
    try
      if InTransaction then
        InternalRollbackTransaction;
    except
      on E: Exception do
        TTLogger.Instance.LogError(FConnectionID, E.Message);
    end;
  finally
    inherited RollbackTransaction;
  end;
end;

procedure TTGenericConnection.CommitTransaction;
begin
  if not InTransaction then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotInTransaction), ['CommitTransaction']);
  TTLogger.Instance.LogCommit(FConnectionID);
  try
    InternalCommitTransaction;
  except
    RollbackFailedCommit;
    raise;
  end;
  inherited CommitTransaction;
end;

procedure TTGenericConnection.RollbackTransaction;
begin
  if not InTransaction then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotInTransaction), ['RollbackTransaction']);
  TTLogger.Instance.LogRollback(FConnectionID);
  try
    InternalRollbackTransaction;
  finally
    inherited RollbackTransaction;
  end;
end;

function TTGenericConnection.SelectCount(
  const ATableMap: TTTableMap; const AFilter: TTFilter): Int64;
var
  LSyntax: TTSelectCountSyntax;
  LSql: String;
  LDataset: TDataset;
begin
  LSyntax := FSyntaxClasses.SelectCount.Create(Self, ATableMap, AFilter);
  try
    LSql := LSyntax.SQL;
    LDataset := CreateDataSet(LSql, LSyntax.Filter);
    try
      result := LDataset.Fields[0].AsLargeInt;
    finally
      LDataset.Free;
    end;
  finally
    LSyntax.Free;
  end;
end;

function TTGenericConnection.CreateReader(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTReader;
begin
  result := TTGenericReader.Create(
    Self, ATableMap, ATableMetadata, AFilter);
end;

function TTGenericConnection.CreateInsertCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericInsertCommand.Create(
    Self, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateUpdateCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericUpdateCommand.Create(
    Self, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateUndeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericUndeleteCommand.Create(
    Self, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateSoftDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericSoftDeleteCommand.Create(
    Self, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericDeleteCommand.Create(
    Self, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.FindColumnMap(
  const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;
begin
  result := ATableMap.Columns.Find(AColumnName);
end;

function TTGenericConnection.GetColumnMap(
  const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;
begin
  result := FindColumnMap(ATableMap, AColumnName);
  if not Assigned(result) then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SColumnNotFound), [AColumnName]);
end;

function TTGenericConnection.GetConnectionID: String;
begin
  result := FConnectionID;
end;

function TTGenericConnection.GetDatabaseVersion: String;
var
  LSyntax: TTVersionSyntax;
  LDataSet: TDataset;
begin
  result := string.Empty;
  LSyntax := SyntaxClasses.Version.Create;
  try
    LDataset := CreateDataSet(LSyntax.SQL, TTFilter.Empty);
    try
      TTLogger.Instance.LogSyntax(FConnectionID, LSyntax.SQL);
      if not LDataSet.IsEmpty then
        result := LDataSet.Fields[0].AsString;
    finally
      LDataSet.Free;
    end;
  finally
    LSyntax.Free;
  end;
end;

procedure TTGenericConnection.ProbeFailed(
  const ATableMap: TTTableMap; const AException: Exception);
begin
  raise ETException.CreateFmt(
    TTLanguage.Instance.Translate(SMetadataProbeFailed), [
      String(ATableMap.EntityTypeInfo^.Name),
      ATableMap.Name,
      AException.Message]);
end;

function TTGenericConnection.GetSqlReference(
  const AColumnMap: TTColumnMap; const AColumnName: String): String;
begin
  if Assigned(AColumnMap) then
    result := GetDatabaseObjectName(AColumnMap.SqlReference)
  else
    result := GetDatabaseObjectName(AColumnName);
end;

procedure TTGenericConnection.ReadMetadata(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const ADataset: TDataset);
var
  LIndex: Integer;
  LColumnMap: TTColumnMap;
begin
  for LIndex := 0 to ADataset.FieldDefs.Count - 1 do
  begin
    LColumnMap := FindColumnMap(ATableMap, ADataset.FieldDefs[LIndex].Name);
    ATableMetadata.Columns.Add(
      ADataset.FieldDefs[LIndex].Name,
      GetSqlReference(LColumnMap, ADataset.FieldDefs[LIndex].Name),
      TTColumnType.Create(
        ADataset.FieldDefs[LIndex].DataType,
        ADataset.FieldDefs[LIndex].Size,
        ADataset.FieldDefs[LIndex].Precision),
      LColumnMap);
  end;
end;

procedure TTGenericConnection.CheckParameterNames(
  const ATableMetadata: TTTableMetadata);
var
  LColumn: TTColumnMetadata;
  LName: String;
  LNames: TDictionary<String, String>;
begin
  LNames := TDictionary<String, String>.Create(TTIdentifier.Comparer);
  try
    for LColumn in ATableMetadata.Columns do
    begin
      LName := GetParameterName(LColumn.ColumnName);
      if LNames.ContainsKey(LName) then
        raise ETException.CreateFmt(
          TTLanguage.Instance.Translate(SDuplicateParameterName), [
            LNames[LName],
            LColumn.ColumnName,
            LName]);
      LNames.Add(LName, LColumn.ColumnName);
    end;
  finally
    LNames.Free;
  end;
end;

procedure TTGenericConnection.InternalGetMetadata(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const ASyntax: TTMetadataSyntax);
var
  LDataset: TDataset;
begin
  LDataset := CreateDataSet(ASyntax.SQL, ASyntax.Filter);
  try
    ReadMetadata(ATableMap, ATableMetadata, LDataset);
    CheckParameterNames(ATableMetadata);
  finally
    LDataset.Free;
  end;
end;

procedure TTGenericConnection.GetMetadata(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTMetadataSyntax;
begin
  LSyntax := FSyntaxClasses.Metadata.Create(Self, ATableMap);
  try
    try
      InternalGetMetadata(ATableMap, ATableMetadata, LSyntax);
    except
      on E: ETException do
        raise;
      on E: Exception do
        ProbeFailed(ATableMap, E);
    end;
  finally
    LSyntax.Free;
  end;
end;

function TTGenericConnection.GetSequenceID(
  const ATableMap: TTTableMap): TTPrimaryKey;
var
  LSyntax: TTSequenceSyntax;
  LDataset: TDataset;
  LValue: Int64;
begin
  LSyntax := FSyntaxClasses.Sequence.Create(Self, ATableMap);
  try
    LDataset := CreateDataSet(LSyntax.SQL, TTFilter.Empty);
    try
      TTLogger.Instance.LogSyntax(FConnectionID, LSyntax.SQL);
      LValue := LDataset.Fields[0].AsLargeInt;
      if (LValue < Low(TTPrimaryKey)) or (LValue > High(TTPrimaryKey)) then
        raise ETException.CreateFmt(
          TTLanguage.Instance.Translate(SSequenceOutOfRange), [
            ATableMap.Name,
            LValue]);
      result := TTPrimaryKey(LValue);
    finally
      LDataset.Free;
    end;
  finally
    LSyntax.Free;
  end;
end;

function TTGenericConnection.CheckExists(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Boolean;
var
  LID: TTPrimaryKey;
  LSyntax: TTCheckExistsSyntax;
  LDataset: TDataset;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := FSyntaxClasses.CheckExists.Create(
    Self, ATableMap, ATableName, AColumnName, LID);
  try
    LDataset := CreateDataSet(LSyntax.SQL, TTFilter.Empty);
    try
      result := (LDataset.Fields[0].AsInteger > 0);
    finally
      LDataset.Free;
    end;
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericReader }

constructor TTGenericReader.Create(
  const AConnection: TTGenericConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FConnection := AConnection;
  FSyntax := AConnection.SyntaxClasses.Select.Create(
    AConnection, ATableMap, AFilter);
end;

destructor TTGenericReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTGenericReader.GetDataset: TDataset;
var
  LSql: String;
begin
  LSql := FSyntax.SQL;
  result := FConnection.CreateDataset(LSql, FSyntax.Filter);
  TTLogger.Instance.LogSyntax(FConnection.ConnectionID, LSql);
end;

{ TTGenericCommand }

constructor TTGenericCommand.Create(
  const AConnection: TTGenericConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTGenericCommand.InvokeEvents(
  const AEntity: TObject; const AEventMethodType: TTEventMethodType);
var
  LEventMethodMap: TTTableEventMethodMap;
begin
  for LEventMethodMap in FTableMap.EventMethods do
    if AEventMethodType = LEventMethodMap.EventMethodType then
      LEventMethodMap.Method.Invoke(AEntity, []);
end;

procedure TTGenericCommand.BeforeExecute(
  const AEntity: TObject;
  const AEvent: TTEvent;
  const AEventMethodType: TTEventMethodType);
begin
  if Assigned(AEvent) then
    AEvent.DoBefore;
  InvokeEvents(AEntity, AEventMethodType);
end;

procedure TTGenericCommand.AfterExecute(
  const AEntity: TObject;
  const AEvent: TTEvent;
  const AEventMethodType: TTEventMethodType);
begin
  if Assigned(AEvent) then
  begin
    AEvent.CommandExecuted;
    AEvent.DoAfter;
  end;
  InvokeEvents(AEntity, AEventMethodType);
end;

procedure TTGenericCommand.ExecuteCommand(
  const ASQL: String;
  const AEntity: TObject;
  const AEvent: TTEvent;
  const ABeforeEventMethodType: TTEventMethodType;
  const AAfterEventMethodType: TTEventMethodType);
begin
  TTTransaction.Run(
    FConnection,
    procedure
    var
      LRowsAffected: Integer;
    begin
      BeforeExecute(AEntity, AEvent, ABeforeEventMethodType);

      TTLogger.Instance.LogCommand(FConnection.ConnectionID, ASQL);

      LRowsAffected := FConnection.Execute(
        ASQL,
        FTableMap,
        FTableMetadata,
        AEntity);

      if LRowsAffected = 0 then
        raise ETConcurrentUpdateException.Create(TTLanguage.Instance.Translate(SRecordChanged))
      else if LRowsAffected > 1 then
        raise ETDataIntegrityException.Create(TTLanguage.Instance.Translate(SSyntaxError));

      AfterExecute(AEntity, AEvent, AAfterEventMethodType);
    end);
end;

{ TTGenericInsertCommand }

procedure TTGenericInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Insert.Create(FConnection, FTableMap);
  try
    ExecuteCommand(
      LSyntax.GetSqlSyntax([]),
      AEntity,
      AEvent,
      TTEventMethodType.BeforeInsert,
      TTEventMethodType.AfterInsert);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericUpdateCommand }

function TTGenericUpdateCommand.GetSyntaxClass: TTCommandSyntaxClass;
begin
  result := FConnection.SyntaxClasses.Update;
end;

procedure TTGenericUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := GetSyntaxClass.Create(FConnection, FTableMap);
  try
    ExecuteCommand(
      LSyntax.GetSqlSyntax(GetWhereColumns),
      AEntity,
      AEvent,
      TTEventMethodType.BeforeUpdate,
      TTEventMethodType.AfterUpdate);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericUndeleteCommand }

function TTGenericUndeleteCommand.GetSyntaxClass: TTCommandSyntaxClass;
begin
  result := FConnection.SyntaxClasses.Undelete;
end;

{ TTGenericSoftDeleteCommand }

procedure TTGenericSoftDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.SoftDelete.Create(
    FConnection, FTableMap);
  try
    ExecuteCommand(
      LSyntax.GetSqlSyntax(GetWhereColumns),
      AEntity,
      AEvent,
      TTEventMethodType.BeforeDelete,
      TTEventMethodType.AfterDelete);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericDeleteCommand }

procedure TTGenericDeleteCommand.BeforeExecute(
  const AEntity: TObject;
  const AEvent: TTEvent;
  const AEventMethodType: TTEventMethodType);
var
  LID: TTPrimaryKey;
  LSyntax: TTDeleteCascadeSyntax;
  LSQL: String;
  LRelation: TTRelationMap;
begin
  inherited BeforeExecute(AEntity, AEvent, AEventMethodType);
  LID := FTableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := FConnection.SyntaxClasses.DeleteCascade.Create;
  try
    LSQL := LSyntax.GetSqlSyntax;
    for LRelation in FTableMap.Relations do
      if LRelation.IsCascade then
      begin
        FConnection.Execute(Format(LSQL, [
          FConnection.GetDatabaseObjectName(LRelation.TableName),
          FConnection.GetDatabaseObjectName(LRelation.ColumnName),
          TTPrimaryKeyHelper.SqlValue(LID)]));
      end;
  finally
    LSyntax.Free;
  end;
end;

procedure TTGenericDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Delete.Create(FConnection, FTableMap);
  try
    ExecuteCommand(
      LSyntax.GetSqlSyntax(GetWhereColumns),
      AEntity,
      AEvent,
      TTEventMethodType.BeforeDelete,
      TTEventMethodType.AfterDelete);
  finally
    LSyntax.Free;
  end;
end;

end.
