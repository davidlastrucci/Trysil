(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.SqlServer;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys.MSSQL,
  FireDAC.Comp.Client,

  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data,
  Trysil.Events.Abstract,
  Trysil.Data.FireDAC.Common,
  Trysil.Data.FireDAC,
  Trysil.Data.FireDAC.SqlServer.SqlSyntax;

type

{ TTDataSqlServerConnection }

  TTDataSqlServerConnection = class(TTDataConnection)
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FMSSQLDriverLink: TFDPhysMSSQLDriverLink;
    FConnection: TFDConnection;
  strict protected
    function GetInTransaction: Boolean; override;
    function SelectCount(
      const ATableMap: TTTableMap;
      const ATableName: String;
      const AColumnName: String;
      const AEntity: TObject): Integer; override;
  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); override;

    function GetSequenceID(const ASequenceName: String): TTPrimaryKey; override;

    function CreateReader(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter): TTDataReader; override;

    function CreateInsertCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataInsertCommand; override;

    function CreateUpdateCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataUpdateCommand; override;

    function CreateDeleteCommand(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata): TTDataDeleteCommand; override;
  public
    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const ADatabaseName: String); overload;

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String); overload;
  end;

{ TTDataSqlServerDataReader }

  TTDataSqlServerDataReader = class(TTDataReader)
  strict private
    FSyntax: TTDataSqlServerSelectSyntax;
  strict protected
    function GetDataset: TDataset; override;
  public
    constructor Create(
      const AConnection: TFDConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AFilter: TTFilter);
    destructor Destroy; override;
  end;

{ TTDataSqlServerDataInsertCommand }

  TTDataSqlServerDataInsertCommand = class(TTDataInsertCommand)
  strict private
    FConnection: TFDConnection;
  public
    constructor Create(
      const AConnection: TFDConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSqlServerDataUpdateCommand }

  TTDataSqlServerDataUpdateCommand = class(TTDataUpdateCommand)
  strict private
    FConnection: TFDConnection;
  public
    constructor Create(
      const AConnection: TFDConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ TTDataSqlServerDataDeleteCommand }

  TTDataSqlServerDataDeleteCommand = class(TTDataDeleteCommand)
  strict private
    FConnection: TFDConnection;
  public
    constructor Create(
      const AConnection: TFDConnection;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata);

    procedure Execute(
      const AEntity: TObject; const AEvent: TTEvent); override;
end;

{ resourcestring }

resourcestring
  SInTransaction = '%s: Transaction already started.';
  SNotInTransaction = '%s: Transaction not yet started.';

implementation

{ TTDataSqlServerConnection }

constructor TTDataSqlServerConnection.Create(const AConnectionName: String);
begin
    inherited Create;
    FConnectionName := AConnectionName;

    FWaitCursor := TFDGUIxWaitCursor.Create(nil);
    FMSSQLDriverLink := TFDPhysMSSQLDriverLink.Create(nil);
    FConnection := TFDConnection.Create(nil);
end;

destructor TTDataSqlServerConnection.Destroy;
begin
    FConnection.Free;
    FMSSQLDriverLink.Free;
    FWaitCursor.Free;
    inherited Destroy;
end;

procedure TTDataSqlServerConnection.AfterConstruction;
begin
    inherited AfterConstruction;
    FWaitCursor.Provider := 'Console';
    FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;

    FConnection.ConnectionDefName := FConnectionName;
    FConnection.Open;
end;

procedure TTDataSqlServerConnection.StartTransaction;
begin
  if FConnection.InTransaction then
    raise ETException.CreateFmt(SInTransaction, ['StartTransaction']);
  FConnection.StartTransaction;
end;

procedure TTDataSqlServerConnection.CommitTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['CommitTransaction']);
  FConnection.Commit;
end;

procedure TTDataSqlServerConnection.RollbackTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['RollbackTransaction']);
  FConnection.Rollback;
end;

function TTDataSqlServerConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTDataSqlServerSelectCountSyntax;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := TTDataSqlServerSelectCountSyntax.Create(
    FConnection, ATableMap, ATableName, AColumnName, LID);
  try
    result := LSyntax.Count;
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

procedure TTDataSqlServerConnection.GetMetadata(
  const ATableMap: TTTableMap; const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTDataSqlServerMetadataSyntax;
  LIndex: Integer;
begin
  LSyntax := TTDataSqlServerMetadataSyntax.Create(
    FConnection, ATableMap, ATableMetadata);
  try
    for LIndex := 0 to LSyntax.Dataset.FieldDefs.Count - 1 do
      ATableMetadata.Columns.Add(
        LSyntax.Dataset.FieldDefs[LIndex].Name,
        LSyntax.Dataset.FieldDefs[LIndex].DataType,
        LSyntax.Dataset.FieldDefs[LIndex].Size);
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.GetSequenceID(
  const ASequenceName: String): TTPrimaryKey;
var
  LSyntax: TTDataSqlServerSequenceSyntax;
begin
  LSyntax := TTDataSqlServerSequenceSyntax.Create(FConnection, ASequenceName);
  try
    result := LSyntax.ID;
  finally
    LSyntax.Free;
  end;
end;

function TTDataSqlServerConnection.CreateReader(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTDataReader;
begin
  result := TTDataSqlServerDataReader.Create(
    FConnection, ATableMap, ATableMetadata, AFilter);
end;

function TTDataSqlServerConnection.CreateInsertCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataInsertCommand;
begin
  result := TTDataSqlServerDataInsertCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

function TTDataSqlServerConnection.CreateUpdateCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataUpdateCommand;
begin
  result := TTDataSqlServerDataUpdateCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

function TTDataSqlServerConnection.CreateDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataDeleteCommand;
begin
  result := TTDataSqlServerDataDeleteCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

class procedure TTDataSqlServerConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTDataSqlServerConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    LParameters.Add(Format('Server=%s', [AServer]));
    LParameters.Add(Format('Database=%s', [ADatabaseName]));
    if AUsername.IsEmpty then
        LParameters.Add('OSAuthent=Yes')
    else
    begin
        LParameters.Add(Format('User_Name=%s', [AUserName]));
        LParameters.Add(Format('Password=%s', [APassword]));
    end;

    TTDataFireDACConnectionPool.Instance.RegisterConnection(
      AName, 'MSSQL', LParameters);
  finally
    LParameters.Free;
  end;
end;

{ TTDataSqlServerDataReader }

constructor TTDataSqlServerDataReader.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := TTDataSqlServerSelectSyntax.Create(
    AConnection, ATableMap, ATableMetadata, AFilter);
end;

destructor TTDataSqlServerDataReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTDataSqlServerDataReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTDataSqlServerDataInsertCommand }

constructor TTDataSqlServerDataInsertCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerInsertSyntax;
begin
  LSyntax := TTDataSqlServerInsertSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataSqlServerDataUpdateCommand }

constructor TTDataSqlServerDataUpdateCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerUpdateSyntax;
begin
  LSyntax := TTDataSqlServerUpdateSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataSqlServerDataDeleteCommand }

constructor TTDataSqlServerDataDeleteCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataSqlServerDataDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataSqlServerDeleteSyntax;
begin
  LSyntax := TTDataSqlServerDeleteSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

end.
