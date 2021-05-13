unit Trysil.Data.Connection;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Filter,
  Trysil.Events.Abstract,
  Trysil.Data.SqlSyntax;

type

{ TTGenericConnection }

  TTGenericConnection = class abstract(TTConnection)
  strict private
    FSyntaxClasses: TTSyntaxClasses;
  strict protected
    function CreateSyntaxClasses: TTSyntaxClasses; virtual; abstract;

    function GetColumnMap(
      const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;

    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; override;
  public
    function CreateReader(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTReader; override;

    function CreateInsertCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateUpdateCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    function CreateDeleteCommand(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTAbstractCommand; override;

    procedure GetMetadata(
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ATableMap: TTTableMap): TTPrimaryKey; override;
  public
    constructor Create;
    destructor Destroy; override;

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
      const AMapper: TTMapper;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTGenericCommand }

  TTGenericCommand = class(TTAbstractCommand)
  strict protected
    FConnection: TTGenericConnection;

    procedure BeforeExecute(
      const AEntity: TObject; const AEvent: TTEvent); virtual;
    procedure AfterExecute(
      const AEntity: TObject; const AEvent: TTEvent); virtual;

    procedure ExecuteCommand(
      const ASQL: String;
      const AEntity: TObject;
      const AEvent: TTEvent);
  public
    constructor Create(
      const AConnection: TTGenericConnection;
      const AMapper: TTMapper;
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
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTGenericDeleteCommand }

  TTGenericDeleteCommand = class(TTGenericCommand)
  strict protected
    procedure BeforeExecute(
      const AEntity: TObject; const AEvent: TTEvent); override;
  public
    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

implementation

{ TTGenericConnection }

constructor TTGenericConnection.Create;
begin
  inherited Create;
  FSyntaxClasses := CreateSyntaxClasses;
end;

destructor TTGenericConnection.Destroy;
begin
  FSyntaxClasses.Free;
  inherited Destroy;
end;

function TTGenericConnection.CreateReader(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTReader;
begin
  result := TTGenericReader.Create(
    Self, AMapper, ATableMap, ATableMetadata, AFilter);
end;

function TTGenericConnection.CreateInsertCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericInsertCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateUpdateCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericUpdateCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.CreateDeleteCommand(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTAbstractCommand;
begin
  result := TTGenericDeleteCommand.Create(
    Self, AMapper, ATableMap, ATableMetadata, FUpdateMode);
end;

function TTGenericConnection.GetColumnMap(
  const ATableMap: TTTableMap; const AColumnName: String): TTColumnMap;
var
  LColumn: TTColumnMap;
begin
  result := nil;
  for LColumn in ATableMap.Columns do
    if LColumn.Name.Equals(AColumnName) then
    begin
      result := LColumn;
      Break;
    end;

  if not Assigned(result) then
    raise ETException.CreateFmt(SColumnNotFound, [AColumnName]);
end;

procedure TTGenericConnection.GetMetadata(
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTMetadataSyntax;
  LDataset: TDataset;
  LIndex: Integer;
begin
  LSyntax := FSyntaxClasses.Metadata.Create(
    Self, AMapper, ATableMap, ATableMetadata);
  try
    LDataset := CreateDataSet(LSyntax.SQL);
    try
      for LIndex := 0 to LDataset.FieldDefs.Count - 1 do
        ATableMetadata.Columns.Add(
          LDataset.FieldDefs[LIndex].Name,
          LDataset.FieldDefs[LIndex].DataType,
          LDataset.FieldDefs[LIndex].Size);
    finally
      LDataset.Free;
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
begin
  LSyntax := FSyntaxClasses.Sequence.Create(Self, ATableMap);
  try
    LDataset := CreateDataSet(LSyntax.SQL);
    try
      LDataset.Open;
      result := LDataset.Fields[0].AsInteger;
    finally
      LDataset.Free;
    end;
  finally
    LSyntax.Free;
  end;
end;

function TTGenericConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTSelectCountSyntax;
  LDataset: TDataset;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := FSyntaxClasses.SelectCount.Create(
    Self, ATableMap, ATableName, AColumnName, LID);
  try
    LDataset := CreateDataSet(LSyntax.SQL);
    try
      LDataset.Open;
      result := LDataset.Fields[0].AsInteger;
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
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FConnection := AConnection;
  FSyntax := AConnection.SyntaxClasses.Select.Create(
    AConnection, AMapper, ATableMap, ATableMetadata, AFilter);
end;

destructor TTGenericReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTGenericReader.GetDataset: TDataset;
begin
  result := FConnection.CreateDataset(FSyntax.SQL);
end;

{ TTGenericCommand }

constructor TTGenericCommand.Create(
  const AConnection: TTGenericConnection;
  const AMapper: TTMapper;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AUpdateMode: TTUpdateMode);
begin
  inherited Create(AMapper, ATableMap, ATableMetadata, AUpdateMode);
  FConnection := AConnection;
end;

procedure TTGenericCommand.BeforeExecute(
  const AEntity: TObject; const AEvent: TTEvent);
begin
  if Assigned(AEvent) then
    AEvent.DoBefore;
end;

procedure TTGenericCommand.AfterExecute(
  const AEntity: TObject; const AEvent: TTEvent);
begin
  if Assigned(AEvent) then
    AEvent.DoAfter;
end;

procedure TTGenericCommand.ExecuteCommand(
  const ASQL: String;
  const AEntity: TObject;
  const AEvent: TTEvent);
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
      ASQL,
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

{ TTGenericInsertCommand }

procedure TTGenericInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Insert.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    ExecuteCommand(LSyntax.GetSqlSyntax([]), AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericUpdateCommand }

procedure TTGenericUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTCommandSyntax;
begin
  LSyntax := FConnection.SyntaxClasses.Update.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    ExecuteCommand(LSyntax.GetSqlSyntax(GetWhereColumns), AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTGenericDeleteCommand }

procedure TTGenericDeleteCommand.BeforeExecute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LID: TTPrimaryKey;
  LSyntax: TTDeleteCascadeSyntax;
  LSQL: String;
  LRelation: TTRelationMap;
begin
  inherited BeforeExecute(AEntity, AEvent);
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
  LSyntax := FConnection.SyntaxClasses.Delete.Create(
    FConnection, FMapper, FTableMap, FTableMetadata);
  try
    ExecuteCommand(LSyntax.GetSqlSyntax(GetWhereColumns), AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

end.
