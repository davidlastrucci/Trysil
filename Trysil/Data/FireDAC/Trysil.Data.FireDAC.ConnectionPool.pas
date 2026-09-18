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
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
  System.SyncObjs,
  System.Generics.Collections,
  FireDAC.Stan.Consts,
  FireDAC.UI.Intf,
  FireDAC.Comp.Client,

  Trysil.Consts,
  Trysil.Exceptions,
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
    class var FInstanceLock: TSpinLock;
    class var FDestroyed: Boolean;

    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetInstance: TTFireDACConnectionPool; static;
  strict private
    FManager: TFDManager;
    FConfig: TTFireDACConfigConnectionPool;
    FLock: TTMultiReadExclusiveWriteLock;
    FPoolParameters: TDictionary<String, TTFireDACPoolParameters>;
    FRegistered: TDictionary<String, String>;

    class function ParametersSignature(
      const AParameters: TStrings): String; static;
    class function SameParameters(
      const ALeft: TTFireDACPoolParameters;
      const ARight: TTFireDACPoolParameters): Boolean; static;

    function IsPoolParametersChange(
      const AKey: String;
      const AParameters: TTFireDACPoolParameters): Boolean;

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
  FEnabled := True;
  FMaximumItems := C_FD_PoolMaximumItems;
  FCleanupTimeout := C_FD_PoolCleanupTimeout;
  FExpireTimeout := C_FD_PoolExpireTimeout;
end;

{ TTFireDACConnectionPool }

class constructor TTFireDACConnectionPool.ClassCreate;
begin
  FInstance := nil;
  FDestroyed := False;
  FInstanceLock := TSpinLock.Create(False);
end;

class destructor TTFireDACConnectionPool.ClassDestroy;
begin
  FInstanceLock.Enter;
  try
    FDestroyed := True;
    if Assigned(FInstance) then
      FInstance.Free;
    FInstance := nil;
  finally
    FInstanceLock.Exit;
  end;
end;

class function TTFireDACConnectionPool.GetInstance:
  TTFireDACConnectionPool;
begin
  FInstanceLock.Enter;
  try
    if FDestroyed then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SInstanceDestroyed), [ClassName]);

    if not Assigned(FInstance) then
      FInstance := TTFireDACConnectionPool.Create;
    result := FInstance;
  finally
    FInstanceLock.Exit;
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
  FRegistered := TDictionary<String, String>.Create;
end;

destructor TTFireDACConnectionPool.Destroy;
begin
  FRegistered.Free;
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
    if not FPoolParameters.TryGetValue(AName.ToLowerInvariant, result) then
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

class function TTFireDACConnectionPool.SameParameters(
  const ALeft: TTFireDACPoolParameters;
  const ARight: TTFireDACPoolParameters): Boolean;
begin
  result :=
    (ALeft.Enabled = ARight.Enabled) and
    (ALeft.MaximumItems = ARight.MaximumItems) and
    (ALeft.CleanupTimeout = ARight.CleanupTimeout) and
    (ALeft.ExpireTimeout = ARight.ExpireTimeout);
end;

function TTFireDACConnectionPool.IsPoolParametersChange(
  const AKey: String;
  const AParameters: TTFireDACPoolParameters): Boolean;
var
  LCurrent: TTFireDACPoolParameters;
begin
  result := not (
    FPoolParameters.TryGetValue(AKey, LCurrent) and
    SameParameters(LCurrent, AParameters));
end;

procedure TTFireDACConnectionPool.RegisterConfig(
  const AName: String; const AParameters: TTFireDACPoolParameters);
var
  LKey: String;
begin
  if AParameters.IsAssigned then
  begin
    LKey := AName.ToLowerInvariant;
    FLock.BeginWrite;
    try
      if FRegistered.ContainsKey(LKey) and
        IsPoolParametersChange(LKey, AParameters) then
        raise ETException.CreateFmt(
          TTLanguage.Instance.Translate(SPoolConfigConnectionRegistered), [
            AName]);
      FPoolParameters.AddOrSetValue(LKey, AParameters);
    finally
      FLock.EndWrite;
    end;
  end;
end;

class function TTFireDACConnectionPool.ParametersSignature(
  const AParameters: TStrings): String;
var
  LValues: TStringList;
begin
  LValues := TStringList.Create;
  try
    LValues.CaseSensitive := True;
    LValues.Duplicates := TDuplicates.dupAccept;
    LValues.AddStrings(AParameters);
    LValues.Sort;
    result := LValues.Text;
  finally
    LValues.Free;
  end;
end;

procedure TTFireDACConnectionPool.RegisterConnection(
  const AName: String;
  const ADriver: String;
  const AParameters: TStrings);
var
  LParameters: TStrings;
  LSignature: String;
  LRegistered: String;
begin
  FLock.BeginWrite;
  try
    LParameters := TStringList.Create;
    try
      LParameters.Add(Format('DriverID=%s', [ADriver]));
      LParameters.AddStrings(AParameters);
      LSignature := ParametersSignature(LParameters);
      AddConnectionPooling(AName, LParameters);

      if not FRegistered.TryGetValue(AName.ToLowerInvariant, LRegistered) then
      begin
        FManager.AddConnectionDef(AName, ADriver, LParameters);
        FRegistered.Add(AName.ToLowerInvariant, LSignature);
      end
      else if not LRegistered.Equals(LSignature) then
        raise ETException.CreateFmt(
          TTLanguage.Instance.Translate(SConnectionAlreadyRegistered), [AName]);
    finally
      LParameters.Free;
    end;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTFireDACConnectionPool.UnregisterConnection(const AName: String);
begin
  FLock.BeginWrite;
  try
    FManager.CloseConnectionDef(AName);
    FManager.DeleteConnectionDef(AName);
    FPoolParameters.Remove(AName.ToLowerInvariant);
    FRegistered.Remove(AName.ToLowerInvariant);
  finally
    FLock.EndWrite;
  end;
end;

end.
