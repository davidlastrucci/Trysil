(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.FirebirdSQL;

interface

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Phys.IBBase, 
  FireDAC.Phys.FB,
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
  Trysil.Data.FireDAC.FirebirdSQL.SqlSyntax;

type

{ TTDataFirebirdSQLConnection }

  TTDataFirebirdSQLConnection = class(TTDataConnection)
  strict private
    class var VendorLib: String;
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FFBDriverLink: TFDPhysFBDriverLink;
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

    class procedure RegisterConnection(
      const AName: String;
      const AServer: String;
      const AUsername: String;
      const APassword: String;
      const ADatabaseName: String;
      const AVendorLib: String); overload;
  end;

{ TTDataFirebirdSQLDataReader }

  TTDataFirebirdSQLDataReader = class(TTDataReader)
  strict private
    FSyntax: TTDataFirebirdSQLSelectSyntax;
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

{ TTDataFirebirdSQLDataInsertCommand }

  TTDataFirebirdSQLDataInsertCommand = class(TTDataInsertCommand)
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

{ TTDataFirebirdSQLDataUpdateCommand }

  TTDataFirebirdSQLDataUpdateCommand = class(TTDataUpdateCommand)
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

{ TTDataFirebirdSQLDataDeleteCommand }

  TTDataFirebirdSQLDataDeleteCommand = class(TTDataDeleteCommand)
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

{ TTDataFirebirdSQLConnection }

constructor TTDataFirebirdSQLConnection.Create(const AConnectionName: String);
begin
    inherited Create;
    FConnectionName := AConnectionName;

    FWaitCursor := TFDGUIxWaitCursor.Create(nil);
    FFBDriverLink := TFDPhysFBDriverLink.Create(nil);
    FConnection := TFDConnection.Create(nil);
end;

destructor TTDataFirebirdSQLConnection.Destroy;
begin
    FConnection.Free;
    FFBDriverLink.Free;
    FWaitCursor.Free;
    inherited Destroy;
end;

procedure TTDataFirebirdSQLConnection.AfterConstruction;
begin
    inherited AfterConstruction;
    FWaitCursor.Provider := 'Console';
    FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;
    FFBDriverLink.VendorLib := VendorLib;

    FConnection.ConnectionDefName := FConnectionName;
    FConnection.Open;
end;

procedure TTDataFirebirdSQLConnection.StartTransaction;
begin
  if FConnection.InTransaction then
    raise ETException.CreateFmt(SInTransaction, ['StartTransaction']);
  FConnection.StartTransaction;
end;

procedure TTDataFirebirdSQLConnection.CommitTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['CommitTransaction']);
  FConnection.Commit;
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(const AName,
  AServer, AUsername, APassword, ADatabaseName, AVendorLib: String);
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

    VendorLib := AVendorLib;

    TTDataFireDACConnectionPool.Instance.RegisterConnection(
      AName, 'FB', LParameters);
  finally
    LParameters.Free;
  end;
end;

procedure TTDataFirebirdSQLConnection.RollbackTransaction;
begin
  if not FConnection.InTransaction then
    raise ETException.CreateFmt(SNotInTransaction, ['RollbackTransaction']);
  FConnection.Rollback;
end;

function TTDataFirebirdSQLConnection.SelectCount(
  const ATableMap: TTTableMap;
  const ATableName: String;
  const AColumnName: String;
  const AEntity: TObject): Integer;
var
  LID: TTPrimaryKey;
  LSyntax: TTDataFirebirdSQLSelectCountSyntax;
begin
  LID := ATableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
  LSyntax := TTDataFirebirdSQLSelectCountSyntax.Create(
    FConnection, ATableMap, ATableName, AColumnName, LID);
  try
    result := LSyntax.Count;
  finally
    LSyntax.Free;
  end;
end;

function TTDataFirebirdSQLConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

procedure TTDataFirebirdSQLConnection.GetMetadata(
  const ATableMap: TTTableMap; const ATableMetadata: TTTableMetadata);
var
  LSyntax: TTDataFirebirdSQLMetadataSyntax;
  LIndex: Integer;
begin
  LSyntax := TTDataFirebirdSQLMetadataSyntax.Create(
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

function TTDataFirebirdSQLConnection.GetSequenceID(
  const ASequenceName: String): TTPrimaryKey;
var
  LSyntax: TTDataFirebirdSQLSequenceSyntax;
begin
  LSyntax := TTDataFirebirdSQLSequenceSyntax.Create(FConnection, ASequenceName);
  try
    result := LSyntax.ID;
  finally
    LSyntax.Free;
  end;
end;

function TTDataFirebirdSQLConnection.CreateReader(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter): TTDataReader;
begin
  result := TTDataFirebirdSQLDataReader.Create(
    FConnection, ATableMap, ATableMetadata, AFilter);
end;

function TTDataFirebirdSQLConnection.CreateInsertCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataInsertCommand;
begin
  result := TTDataFirebirdSQLDataInsertCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

function TTDataFirebirdSQLConnection.CreateUpdateCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataUpdateCommand;
begin
  result := TTDataFirebirdSQLDataUpdateCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

function TTDataFirebirdSQLConnection.CreateDeleteCommand(
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata): TTDataDeleteCommand;
begin
  result := TTDataFirebirdSQLDataDeleteCommand.Create(
    FConnection, ATableMap, ATableMetadata);
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const ADatabaseName: String);
begin
  RegisterConnection(
    AName, AServer, String.Empty, String.Empty, ADatabaseName);
end;

class procedure TTDataFirebirdSQLConnection.RegisterConnection(
  const AName: String;
  const AServer: String;
  const AUsername: String;
  const APassword: String;
  const ADatabaseName: String);
begin
  RegisterConnection(AName, AServer, AUsername, APassword, ADatabaseName, '');
end;

{ TTDataFirebirdSQLDataReader }

constructor TTDataFirebirdSQLDataReader.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AFilter: TTFilter);
begin
  inherited Create(ATableMap);
  FSyntax := TTDataFirebirdSQLSelectSyntax.Create(
    AConnection, ATableMap, ATableMetadata, AFilter);
end;

destructor TTDataFirebirdSQLDataReader.Destroy;
begin
  FSyntax.Free;
  inherited Destroy;
end;

function TTDataFirebirdSQLDataReader.GetDataset: TDataset;
begin
  result := FSyntax.Dataset;
end;

{ TTDataFirebirdSQLDataInsertCommand }

constructor TTDataFirebirdSQLDataInsertCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataFirebirdSQLDataInsertCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataFirebirdSQLInsertSyntax;
begin
  LSyntax := TTDataFirebirdSQLInsertSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataFirebirdSQLDataUpdateCommand }

constructor TTDataFirebirdSQLDataUpdateCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataFirebirdSQLDataUpdateCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataFirebirdSQLUpdateSyntax;
begin
  LSyntax := TTDataFirebirdSQLUpdateSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

{ TTDataFirebirdSQLDataDeleteCommand }

constructor TTDataFirebirdSQLDataDeleteCommand.Create(
  const AConnection: TFDConnection;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata);
begin
  inherited Create(ATableMap, ATableMetadata);
  FConnection := AConnection;
end;

procedure TTDataFirebirdSQLDataDeleteCommand.Execute(
  const AEntity: TObject; const AEvent: TTEvent);
var
  LSyntax: TTDataFirebirdSQLDeleteSyntax;
begin
  LSyntax := TTDataFirebirdSQLDeleteSyntax.Create(
    FConnection, FTableMap, FTableMetadata);
  try
    LSyntax.Execute(AEntity, AEvent);
  finally
    LSyntax.Free;
  end;
end;

end.
