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
  System.Generics.Collections,
  FireDAC.Stan.Consts,
  FireDAC.UI.Intf,
  FireDAC.Comp.Client,

  Trysil.Sync,
  Trysil.Data.FireDAC.Common;

type

{ TTFireDACPoolParameters }

  TTFireDACPoolParameters = record
  strict private
    FAssigned: Boolean;
    FEnabled: Boolean;
    FMaximumItems: Integer;
    FCleanupTimeout: Cardinal;
    FExpireTimeout: Cardinal;
  public
    constructor Create(
      const AEnabled: Boolean;
      const AMaximumItems: Integer); overload;

    constructor Create(
      const AEnabled: Boolean;
      const AMaximumItems: Integer;
      const ACleanupTimeout: Cardinal;
      const AExpireTimeout: Cardinal); overload;

    property IsAssigned: Boolean read FAssigned;
    property Enabled: Boolean read FEnabled;
    property MaximumItems: Integer read FMaximumItems;
    property CleanupTimeout: Cardinal read FCleanupTimeout;
    property ExpireTimeout: Cardinal read FExpireTimeout;
  end;

{ TTFireDACConfigConnectionPool }

  TTFireDACConfigConnectionPool = class
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
    class var FInstanceLock: TObject;

    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TTFireDACConnectionPool; static;
  strict private
    FManager: TFDManager;
    FConfig: TTFireDACConfigConnectionPool;
    FLock: TTMultiReadExclusiveWriteLock;
    FPoolParameters: TDictionary<String, TTFireDACPoolParameters>;

    function GetPoolParameters(
      const AName: String): TTFireDACPoolParameters;
    procedure AddConnectionPooling(
      const AName: String; const AParameters: TStrings);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure RegisterConfig(
      const AName: String; const AParameters: TTFireDACPoolParameters);
    procedure RegisterConnection(
      const AName: String;
      const ADriver: String;
      const AParameters: TStrings);
    procedure UnregisterConnection(const AName: String);

    property Config: TTFireDACConfigConnectionPool read FConfig;

    class property Instance: TTFireDACConnectionPool read GetInstance;
  end;

implementation

{ TTFireDACPoolParameters }

constructor TTFireDACPoolParameters.Create(
  const AEnabled: Boolean;
  const AMaximumItems: Integer);
begin
  FAssigned := True;
  FEnabled := AEnabled;
  FMaximumItems := AMaximumItems;
  FCleanupTimeout := C_FD_PoolCleanupTimeout;
  FExpireTimeout := C_FD_PoolExpireTimeout;
end;

constructor TTFireDACPoolParameters.Create(
  const AEnabled: Boolean;
  const AMaximumItems: Integer;
  const ACleanupTimeout: Cardinal;
  const AExpireTimeout: Cardinal);
begin
  FAssigned := True;
  FEnabled := AEnabled;
  FMaximumItems := AMaximumItems;
  FCleanupTimeout := ACleanupTimeout;
  FExpireTimeout := AExpireTimeout;
end;

{ TTFireDACConfigConnectionPool }

constructor TTFireDACConfigConnectionPool.Create;
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
  FInstanceLock := TObject.Create;
end;

class destructor TTFireDACConnectionPool.ClassDestroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
  FInstanceLock.Free;
end;

class function TTFireDACConnectionPool.GetInstance:
  TTFireDACConnectionPool;
begin
  TMonitor.Enter(FInstanceLock);
  try
    if not Assigned(FInstance) then
      FInstance := TTFireDACConnectionPool.Create;
    result := FInstance;
  finally
    TMonitor.Exit(FInstanceLock);
  end;
end;

constructor TTFireDACConnectionPool.Create;
begin
  inherited Create;
  FManager := TFDManager.Create(nil);
  FConfig := TTFireDACConfigConnectionPool.Create;
  FLock := TTMultiReadExclusiveWriteLock.Create;
  FPoolParameters :=
    TDictionary<String, TTFireDACPoolParameters>.Create;
end;

destructor TTFireDACConnectionPool.Destroy;
begin
  FPoolParameters.Free;
  FLock.Free;
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

function TTFireDACConnectionPool.GetPoolParameters(
  const AName: String): TTFireDACPoolParameters;
begin
  FLock.BeginRead;
  try
    if not FPoolParameters.TryGetValue(AName.ToLower(), result) then
      result := TTFireDACPoolParameters.Create(
        FConfig.Enabled,
        FConfig.MaximumItems,
        FConfig.CleanupTimeout,
        FConfig.ExpireTimeout);
  finally
    FLock.EndRead;
  end;
end;

procedure TTFireDACConnectionPool.AddConnectionPooling(
  const AName: String; const AParameters: TStrings);
var
  LPool: TTFireDACPoolParameters;
begin
  LPool := GetPoolParameters(AName);
  if LPool.Enabled then
  begin
    AParameters.Add('Pooled=True');
    AParameters.Add(Format('POOL_MaximumItems=%d', [LPool.MaximumItems]));
    AParameters.Add(Format(
      'POOL_CleanupTimeout=%d', [LPool.CleanupTimeout]));
    AParameters.Add(Format('POOL_ExpireTimeout=%d', [LPool.ExpireTimeout]));
  end;
end;

procedure TTFireDACConnectionPool.RegisterConfig(
  const AName: String; const AParameters: TTFireDACPoolParameters);
begin
  if AParameters.IsAssigned then
  begin
    FLock.BeginWrite;
    try
      FPoolParameters.AddOrSetValue(AName.ToLower(), AParameters);
    finally
      FLock.EndWrite;
    end;
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
    LParameters.Add(Format('DriverID=%s', [ADriver]));
    LParameters.AddStrings(AParameters);
    AddConnectionPooling(AName, LParameters);

    FManager.AddConnectionDef(AName, ADriver, LParameters);
  finally
    LParameters.Free;
  end;
end;

procedure TTFireDACConnectionPool.UnregisterConnection(const AName: String);
begin
  FLock.BeginWrite;
  try
    FPoolParameters.Remove(AName.ToLower());
  finally
    FLock.EndWrite;
  end;
  FManager.DeleteConnectionDef(AName);
end;

end.
