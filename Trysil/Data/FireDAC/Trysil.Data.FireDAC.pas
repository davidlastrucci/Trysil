(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Data.DB,
  FireDAC.UI.Intf,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.Comp.Client,
  FireDAC.Phys,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Filter,
  Trysil.Exceptions,
  Trysil.Metadata,
  Trysil.Mapping,
  Trysil.Data,
  Trysil.Data.SqlSyntax,
  Trysil.Data.Connection,
  Trysil.Data.Parameters,
  Trysil.Events.Abstract,
  Trysil.Data.FireDAC.ConnectionPool;

type

{ TTFDParam }

  TTFDParam = class(TTParam)
  strict private
    FParam: TFDParam;
  strict protected
    function GetName: String; override;
    function GetSize: Integer; override;

    function GetAsString: String; override;
    procedure SetAsString(const AValue: String); override;
    function GetAsInteger: Integer; override;
    procedure SetAsInteger(const AValue: Integer); override;
    function GetAsLargeInt: Int64; override;
    procedure SetAsLargeInt(const AValue: Int64); override;
    function GetAsDouble: Double; override;
    procedure SetAsDouble(const AValue: Double); override;
    function GetAsBoolean: Boolean; override;
    procedure SetAsBoolean(const AValue: Boolean); override;
    function GetAsDateTime: TDateTime; override;
    procedure SetAsDateTime(const AValue: TDateTime); override;
    function GetAsGuid: TGUID; override;
    procedure SetAsGuid(const AValue: TGUID); override;
    procedure SetAsBytes(const AValue: TBytes); override;
  public
    constructor Create(const AParam: TFDParam);

    procedure Clear; override;
  end;

{ TTFireDACDriver }

  TTFireDACDriver = class abstract
  strict private
    function GetVendorHome: String;
    procedure SetVendorHome(const AValue: String);
    function GetVendorLib: String;
    procedure SetVendorLib(const AValue: String);
  strict protected
    function GetDriverLink: TFDPhysDriverLink; virtual; abstract;
  private // internal
    class function GetDriverID(const ABaseDriverID: String): String;
  public
    procedure AfterConstruction; override;

    property DriverLink: TFDPhysDriverLink read GetDriverLink;
    property VendorHome: String read GetVendorHome write SetVendorHome;
    property VendorLib: String read GetVendorLib write SetVendorLib;
  end;

{ TTFireDACConnectionParameters }

  TTFireDACConnectionParameters = record
  strict private
    FDriver: String;
    FServer: String;
    FPort: Integer;
    FUsername: String;
    FPassword: String;
    FDatabaseName: String;
  public
    property Driver: String read FDriver write FDriver;
    property Server: String read FServer write FServer;
    property Port: Integer read FPort write FPort;
    property Username: String read FUsername write FUsername;
    property Password: String read FPassword write FPassword;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
  end;

{ TTFireDACConnection }

  TTFireDACConnection = class abstract(TTGenericConnection)
  strict private
    FConnectionName: String;

    FWaitCursor: TFDGUIxWaitCursor;
    FConnection: TFDConnection;

    procedure SetParameter(
      const ADataset: TFDQuery;
      const AParameter: TTFilterParameter);
    procedure SetParameters(
      const ADataSet: TFDQuery;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject);
  strict protected
    function InternalCreateDataSet(
      const ASQL: String; const AFilter: TTFilter): TDataSet; override;
    function GetInTransaction: Boolean; override;
    function GetSupportTransaction: Boolean; override;
  protected // internal
    class procedure InternalRegisterConnection(
      const AName: String;
      const AParameter: TTFireDACConnectionParameters); virtual; abstract;
    class function GetDriver: String; virtual; abstract;
  public
    constructor Create(const AConnectionName: String);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure StartTransaction; override;
    procedure CommitTransaction; override;
    procedure RollbackTransaction; override;

    function Execute(
      const ASQL: String;
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata;
      const AEntity: TObject): Integer; override;

    class procedure UnregisterConnection(const AName: String); virtual;
  end;

{ TTFireDACConnectionClass }

  TTFireDACConnectionClass = class of TTFireDACConnection;

{ TTFireDACConnectionFactory }

  TTFireDACConnectionFactory = class
  strict private
    class var FInstance: TTFireDACConnectionFactory;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FDrivers: TDictionary<String, TTFireDACConnectionClass>;
    FConnections: TDictionary<String, TTFireDACConnectionClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterDriver<T: TTFireDACConnection>();

    procedure RegisterConnection(
      const AName: String; const AParameters: TTFireDACConnectionParameters);

    function CreateConnection(const AName: String): TTConnection;

    class property Instance: TTFireDACConnectionFactory read FInstance;
  end;

implementation

{ TTFDParam }

constructor TTFDParam.Create(const AParam: TFDParam);
begin
  inherited Create;
  FParam := AParam;
end;

procedure TTFDParam.Clear;
begin
  FParam.Clear;
end;

function TTFDParam.GetName: String;
begin
  result := FParam.Name;
end;

function TTFDParam.GetSize: Integer;
begin
  result := FParam.Size;
end;

function TTFDParam.GetAsString: String;
begin
  result := FParam.AsString;
end;

procedure TTFDParam.SetAsString(const AValue: String);
begin
  FParam.AsString := AValue;
end;

function TTFDParam.GetAsInteger: Integer;
begin
  result := FParam.AsInteger;
end;

procedure TTFDParam.SetAsInteger(const AValue: Integer);
begin
  FParam.AsInteger := AValue;
end;

function TTFDParam.GetAsLargeInt: Int64;
begin
  result := FParam.AsLargeInt;
end;

procedure TTFDParam.SetAsLargeInt(const AValue: Int64);
begin
  FParam.AsLargeInt := AValue;
end;

function TTFDParam.GetAsDouble: Double;
begin
  result := FParam.AsFloat;
end;

procedure TTFDParam.SetAsDouble(const AValue: Double);
begin
  FParam.AsFloat := AValue;
end;

function TTFDParam.GetAsBoolean: Boolean;
begin
  result := FParam.AsBoolean;
end;

procedure TTFDParam.SetAsBoolean(const AValue: Boolean);
begin
  FParam.AsBoolean := AValue;
end;

function TTFDParam.GetAsDateTime: TDateTime;
begin
  result := FParam.AsDateTime;
end;

procedure TTFDParam.SetAsDateTime(const AValue: TDateTime);
begin
  FParam.AsDateTime := AValue;
end;

function TTFDParam.GetAsGuid: TGUID;
begin
  result := FParam.AsGUID;
end;

procedure TTFDParam.SetAsGuid(const AValue: TGUID);
begin
  FParam.AsGUID := AValue;
end;

procedure TTFDParam.SetAsBytes(const AValue: TBytes);
var
  LStream: TMemoryStream;
begin
  LStream := TMemoryStream.Create;
  try
    LStream.Write(AValue, Length(AValue));
    LStream.Position := 0;
    FParam.LoadFromStream(LStream, FParam.DataType);
  finally
    LStream.Free;
  end;
end;

{ TTFireDACDriver }

procedure TTFireDACDriver.AfterConstruction;
begin
  inherited AfterConstruction;
  DriverLink.DriverID := GetDriverID(DriverLink.BaseDriverID);
end;

class function TTFireDACDriver.GetDriverID(const ABaseDriverID: String): String;
begin
  result := Format('Trysil_%s', [ABaseDriverID]);
end;

function TTFireDACDriver.GetVendorHome: String;
begin
  result := DriverLink.VendorHome;
end;

procedure TTFireDACDriver.SetVendorHome(const AValue: String);
begin
  DriverLink.VendorHome := AValue;
end;

function TTFireDACDriver.GetVendorLib: String;
begin
  result := DriverLink.VendorLib;
end;

procedure TTFireDACDriver.SetVendorLib(const AValue: String);
begin
  DriverLink.VendorLib := AValue;
end;

{ TTFireDACConnection }

constructor TTFireDACConnection.Create(const AConnectionName: String);
begin
  inherited Create;
  FConnectionName := AConnectionName;

  FWaitCursor := TFDGUIxWaitCursor.Create(nil);
  FConnection := TFDConnection.Create(nil);
end;

destructor TTFireDACConnection.Destroy;
begin
  FConnection.Free;
  FWaitCursor.Free;
  inherited Destroy;
end;

procedure TTFireDACConnection.AfterConstruction;
begin
  inherited AfterConstruction;
  FWaitCursor.Provider := 'Console';
  FWaitCursor.ScreenCursor := TFDGUIxScreenCursor.gcrNone;

  FConnection.ConnectionDefName := FConnectionName;
  FConnection.LoginPrompt := False;
  FConnection.Open;
end;

function TTFireDACConnection.Execute(
  const ASQL: String;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject): Integer;
var
  LDataSet: TFDQuery;
begin
  LDataSet := TFDQuery.Create(nil);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;

    if Assigned(ATableMap) and
      Assigned(ATableMetadata) and
      Assigned(AEntity) then
      SetParameters(
        LDataSet, ATableMap, ATableMetadata, AEntity);

    LDataSet.ExecSQL;
    result := LDataSet.RowsAffected;
  finally
    LDataSet.Free;
  end;
end;

procedure TTFireDACConnection.StartTransaction;
begin
  inherited StartTransaction;
  FConnection.StartTransaction;
end;

procedure TTFireDACConnection.CommitTransaction;
begin
  inherited CommitTransaction;
  FConnection.Commit;
end;

procedure TTFireDACConnection.RollbackTransaction;
begin
  inherited RollbackTransaction;
  FConnection.Rollback;
end;

function TTFireDACConnection.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

function TTFireDACConnection.GetSupportTransaction: Boolean;
begin
  result := True;
end;

procedure TTFireDACConnection.SetParameter(
  const ADataset: TFDQuery;
  const AParameter: TTFilterParameter);
var
  LFireDACParam: TFDParam;
  LParam: TTParam;
  LParameter: TTParameter;
begin
  LFireDACParam := ADataset.Params.FindParam(AParameter.Name);
  if Assigned(LFireDACParam) then
  begin
    LFireDACParam.ParamType := TParamType.ptInput;
    LFireDACParam.DataType := AParameter.DataType;
    LFireDACParam.Size := AParameter.Size;

    LParam := TTFDParam.Create(LFireDACParam);
    try
      LParameter := TTParameterFactory.Instance.CreateParameter(
        ConnectionID, AParameter.DataType, LParam);
      try
        LParameter.SetValue(AParameter.Value);
      finally
        LParameter.Free;
      end;
    finally
      LParam.Free;
    end;
  end;
end;

procedure TTFireDACConnection.SetParameters(
  const ADataSet: TFDQuery;
  const ATableMap: TTTableMap;
  const ATableMetadata: TTTableMetadata;
  const AEntity: TObject);
var
  LColumn: TTColumnMetadata;
  LFireDACParam: TFDParam;
  LParam: TTParam;
  LParameter: TTParameter;
begin
  for LColumn in ATableMetadata.Columns do
  begin
    LFireDACParam := ADataset.Params.FindParam(
      GetParameterName(LColumn.ColumnName));
    if Assigned(LFireDACParam) then
    begin
      LFireDACParam.ParamType := TParamType.ptInput;
      LFireDACParam.DataType := LColumn.DataType;
      LFireDACParam.Size := LColumn.DataSize;

      LParam := TTFDParam.Create(LFireDACParam);
      try
        LParameter := TTParameterFactory.Instance.CreateParameter(
          ConnectionID,
          LColumn.DataType,
          LParam,
          GetColumnMap(ATableMap, LColumn.ColumnName));
        try
          LParameter.SetValue(AEntity);
        finally
          LParameter.Free;
        end;
      finally
        LParam.Free;
      end;
    end;
  end;
end;

function TTFireDACConnection.InternalCreateDataSet(
  const ASQL: String; const AFilter: TTFilter): TDataSet;
var
  LDataSet: TFDQuery;
  LParameter: TTFilterParameter;
begin
  LDataSet := TFDQuery.Create(nil);
  try
    LDataSet.Connection := FConnection;
    LDataSet.SQL.Text := ASQL;
    if not AFilter.IsEmpty then
      for LParameter in AFilter.Parameters do
        SetParameter(LDataSet, LParameter);
  except
    LDataSet.Free;
    raise;
  end;
  result := LDataSet;
end;

class procedure TTFireDACConnection.UnregisterConnection(const AName: String);
begin
  TTFireDACConnectionPool.Instance.UnregisterConnection(AName);
end;

{ TTFireDACConnectionFactory }

class constructor TTFireDACConnectionFactory.ClassCreate;
begin
  FInstance := TTFireDACConnectionFactory.Create;
end;

class destructor TTFireDACConnectionFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTFireDACConnectionFactory.Create;
begin
  inherited Create;
  FDrivers := TDictionary<String, TTFireDACConnectionClass>.Create;
  FConnections := TDictionary<String, TTFireDACConnectionClass>.Create;
end;

destructor TTFireDACConnectionFactory.Destroy;
begin
  FConnections.Free;
  FDrivers.Free;
  inherited Destroy;
end;

procedure TTFireDACConnectionFactory.RegisterDriver<T>();
begin
  FDrivers.Add(T.GetDriver().ToLower(), T);
end;

procedure TTFireDACConnectionFactory.RegisterConnection(
  const AName: String;
  const AParameters: TTFireDACConnectionParameters);
var
  LConnectionClass: TTFireDACConnectionClass;
begin
  if not FDrivers.TryGetValue(
    TTFireDACDriver.GetDriverID(AParameters.Driver).ToLower(),
    LConnectionClass) then
    raise ETException.CreateFmt(
      SNotValidConnectionDriver, [AParameters.Driver]);
  FConnections.Add(AName.ToLower(), LConnectionClass);
  LConnectionClass.InternalRegisterConnection(AName, AParameters);
end;

function TTFireDACConnectionFactory.CreateConnection(
  const AName: String): TTConnection;
var
  LConnectionClass: TTFireDACConnectionClass;
begin
  if not FConnections.TryGetValue(AName.ToLower(), LConnectionClass) then
    raise ETException.CreateFmt(SNotValidConnection, [AName]);
  result := LConnectionClass.Create(AName);
end;

end.
