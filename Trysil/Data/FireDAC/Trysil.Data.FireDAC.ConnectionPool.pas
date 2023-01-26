(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.FireDAC.ConnectionPool;

interface

uses
  System.Classes,
  System.SysUtils,
  FireDAC.Stan.Consts,
  FireDAC.UI.Intf,
  FireDAC.Comp.Client,

  Trysil.Data.FireDAC.Common;

type

{ FireDACConfigConnectionPool }

  FireDACConfigConnectionPool = class
  strict private
    FEnabled: Boolean;
    FMaximumItems: Integer;
    FCleanupTimeout: Cardinal;
    FExpireTimeout: Cardinal;
  public
    constructor Create;

    property Enabled: Boolean read FEnabled write FEnabled;
    property MaximumItems: Integer read FMaximumItems write FMaximumItems;
    property CleanupTimeout: Cardinal read FCleanupTimeout write FCleanupTimeout;
    property ExpireTimeout: Cardinal read FExpireTimeout write FExpireTimeout;
  end;

{ TTFireDACConnectionPool }

  TTFireDACConnectionPool = class
  strict private
    class var FInstance: TTFireDACConnectionPool;

    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TTFireDACConnectionPool; static;
  strict private
    FManager: TFDManager;
    FConfig: FireDACConfigConnectionPool;

    procedure AddConnectionPooling(const AParameters: TStrings);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterConnection(
      const AName: String;
      const ADriver: String;
      const AParameters: TStrings);

    property Config: FireDACConfigConnectionPool read FConfig;

    class property Instance: TTFireDACConnectionPool read GetInstance;
  end;

implementation

{ FireDACConfigConnectionPool }

constructor FireDACConfigConnectionPool.Create;
begin
  inherited Create;
  FEnabled := False;
  FMaximumItems := C_FD_PoolMaximumItems;
  FCleanupTimeout := C_FD_PoolCleanupTimeout;
  FExpireTimeout := C_FD_PoolExpireTimeout;
end;

{ TTFireDACConnectionPool }

class constructor TTFireDACConnectionPool.ClassCreate;
begin
  FInstance := nil;
end;

class destructor TTFireDACConnectionPool.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

class function TTFireDACConnectionPool.GetInstance:
  TTFireDACConnectionPool;
begin
  if not Assigned(FInstance) then
    FInstance := TTFireDACConnectionPool.Create;
  result := FInstance;
end;

constructor TTFireDACConnectionPool.Create;
begin
  inherited Create;
  FManager := TFDManager.Create(nil);
  FConfig := FireDACConfigConnectionPool.Create;
end;

destructor TTFireDACConnectionPool.Destroy;
begin
  FConfig.Free;
  FManager.Free;
  inherited Destroy;
end;

procedure TTFireDACConnectionPool.AfterConstruction;
begin
  inherited AfterConstruction;
  FManager.WaitCursor := TFDGUIxScreenCursor.gcrNone;
  FManager.ConnectionDefFileAutoLoad := False;
  FManager.Open;
end;

procedure TTFireDACConnectionPool.AddConnectionPooling(
  const AParameters: TStrings);
begin
  if FConfig.Enabled then
  begin
    AParameters.Add('Pooled=True');
    AParameters.Add(Format('POOL_MaximumItems=%d', [FConfig.MaximumItems]));
    AParameters.Add(Format('POOL_CleanupTimeout=%d', [FConfig.CleanupTimeout]));
    AParameters.Add(Format('POOL_ExpireTimeout=%d', [FConfig.ExpireTimeout]));
  end;
end;

procedure TTFireDACConnectionPool.RegisterConnection(
  const AName: String;
  const ADriver: String;
  const AParameters: TStrings);
var
  LParameters: TStrings;
begin
  LParameters := TStringList.Create;
  try
    AddConnectionPooling(AParameters);
    LParameters.Add(Format('DriverID=%s', [ADriver]));

    LParameters.AddStrings(AParameters);

    FManager.AddConnectionDef(AName, ADriver, LParameters);
  finally
    LParameters.Free;
  end;
end;

end.
