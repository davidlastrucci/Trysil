(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Http.MultiTenant;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Trysil.Exceptions,
  Trysil.Sync,

  Trysil.Http.MultiTenant.Config,
  Trysil.Http.MultiTenant.Connection;

type

{ TTTenant<T> }

  TTTenant<T: TTTenantConfig> = class
  strict private
    FName: String;
    FConfig: T;
    FConnection: TTTenantConnection;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;

    procedure RegisterConnection;

    property Name: String read FName;
    property Config: T read FConfig;
    property Connection: TTTenantConnection read FConnection;
  end;

{ ETTenantUnavailable }

  ETTenantUnavailable = class(ETException)
  strict private
    FTenantName: String;
    FOriginalClassName: String;
  public
    constructor Create(
      const ATenantName: String;
      const AOriginalClassName: String;
      const AMessage: String);

    property TenantName: String read FTenantName;
    property OriginalClassName: String read FOriginalClassName;
  end;

{ TTTenantFailure }

  TTTenantFailure = record
  strict private
    FExpiration: UInt64;
    FExceptionClassName: String;
    FMessage: String;
  public
    constructor Create(
      const AException: Exception; const ACooldown: Cardinal);

    function IsExpired: Boolean;

    property Expiration: UInt64 read FExpiration;
    property ExceptionClassName: String read FExceptionClassName;
    property Message: String read FMessage;
  end;

{ TTMultiTenant<C> }

  TTMultiTenant<T: TTTenantConfig> = class
  strict private
    class var FInstance: TTMultiTenant<T>;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    const DefaultFailureCooldown: Cardinal = 5000;
    const MaxFailures: Integer = 128;
  strict private
    FLock: TTMultiReadExclusiveWriteLock;
    FOwner: TObjectList<TTTenant<T>>;
    FTenants: TDictionary<String, TTTenant<T>>;
    FFailures: TDictionary<String, TTTenantFailure>;
    FFailureCooldown: Cardinal;

    function TryGetTenant(
      const AName: String; out ATenant: TTTenant<T>): Boolean;
    function CreateTenant(const AName: String): TTTenant<T>;
    function CreateTenantOrFail(const AName: String): TTTenant<T>;
    procedure CheckFailure(const AName: String);
    procedure AddFailure(const AName: String; const AException: Exception);
    procedure RemoveFailure(const AName: String);
    procedure RemoveExpiredFailures;
    procedure RemoveOldestFailure;
    function GetFailureCooldown: Cardinal;
    procedure SetFailureCooldown(const AValue: Cardinal);
  public
    constructor Create;
    destructor Destroy; override;

    function TryGet(
      const AName: String; out ATenant: TTTenant<T>): Boolean;
    function GetOrAdd(const AName: String): TTTenant<T>;
    function GetAll: TArray<string>;
    procedure Remove(const AName: String);

    property FailureCooldown: Cardinal
      read GetFailureCooldown write SetFailureCooldown;

    class property Instance: TTMultiTenant<T> read FInstance;
  end;

implementation

{ TTTenant<T> }

constructor TTTenant<T>.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
  FConfig := T.Create(AName);
  FConnection := nil;
end;

destructor TTTenant<T>.Destroy;
begin
  if Assigned(FConnection) then
    FConnection.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TTTenant<T>.RegisterConnection;
begin
  FConnection := TTTenantConnection.Create(FConfig);
end;

{ ETTenantUnavailable }

constructor ETTenantUnavailable.Create(
  const ATenantName: String;
  const AOriginalClassName: String;
  const AMessage: String);
begin
  inherited Create(AMessage);
  FTenantName := ATenantName;
  FOriginalClassName := AOriginalClassName;
end;

{ TTTenantFailure }

constructor TTTenantFailure.Create(
  const AException: Exception; const ACooldown: Cardinal);
begin
  FExpiration := TThread.GetTickCount64 + ACooldown;
  FExceptionClassName := AException.ClassName;
  FMessage := AException.Message;
end;

function TTTenantFailure.IsExpired: Boolean;
begin
  result := TThread.GetTickCount64 >= FExpiration;
end;

{ TTMultiTenant<T> }

class constructor TTMultiTenant<T>.ClassCreate;
begin
  FInstance := TTMultiTenant<T>.Create;
end;

class destructor TTMultiTenant<T>.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTMultiTenant<T>.Create;
begin
  inherited Create;
  FLock := TTMultiReadExclusiveWriteLock.Create;
  FOwner := TObjectList<TTTenant<T>>.Create(True);
  FTenants := TDictionary<String, TTTenant<T>>.Create;
  FFailures := TDictionary<String, TTTenantFailure>.Create;
  FFailureCooldown := DefaultFailureCooldown;
end;

destructor TTMultiTenant<T>.Destroy;
begin
  FFailures.Free;
  FTenants.Free;
  FOwner.Free;
  FLock.Free;
  inherited Destroy;
end;

function TTMultiTenant<T>.TryGetTenant(
  const AName: String; out ATenant: TTTenant<T>): Boolean;
begin
  FLock.BeginRead;
  try
    result := FTenants.TryGetValue(AName, ATenant);
  finally
    FLock.EndRead;
  end;
end;

function TTMultiTenant<T>.CreateTenant(const AName: String): TTTenant<T>;
var
  LFreeTenant: Boolean;
  LTenant: TTTenant<T>;
begin
  LFreeTenant := True;
  LTenant := TTTenant<T>.Create(AName);
  try
    FLock.BeginWrite;
    try
      if not FTenants.TryGetValue(AName, result) then
      begin
        LTenant.RegisterConnection;
        FOwner.Add(LTenant);
        LFreeTenant := False;
        FTenants.Add(AName, LTenant);
        result := LTenant;
      end;
    finally
      FLock.EndWrite;
    end;
  finally
    if LFreeTenant then
      LTenant.Free;
  end;
end;

function TTMultiTenant<T>.TryGet(
  const AName: String; out ATenant: TTTenant<T>): Boolean;
begin
  result := TryGetTenant(AName.ToLower(), ATenant);
end;

function TTMultiTenant<T>.CreateTenantOrFail(
  const AName: String): TTTenant<T>;
begin
  try
    result := CreateTenant(AName);
  except
    on E: Exception do
    begin
      AddFailure(AName, E);
      raise ETTenantUnavailable.Create(AName, E.ClassName, E.Message);
    end;
  end;
  RemoveFailure(AName);
end;

procedure TTMultiTenant<T>.CheckFailure(const AName: String);
var
  LFailure: TTTenantFailure;
  LFound: Boolean;
begin
  FLock.BeginRead;
  try
    LFound := FFailures.TryGetValue(AName, LFailure);
  finally
    FLock.EndRead;
  end;

  if LFound and (not LFailure.IsExpired) then
    raise ETTenantUnavailable.Create(
      AName, LFailure.ExceptionClassName, LFailure.Message);
end;

procedure TTMultiTenant<T>.AddFailure(
  const AName: String; const AException: Exception);
begin
  FLock.BeginWrite;
  try
    RemoveExpiredFailures;
    if not FFailures.ContainsKey(AName) then
      RemoveOldestFailure;
    FFailures.AddOrSetValue(
      AName, TTTenantFailure.Create(AException, FFailureCooldown));
  finally
    FLock.EndWrite;
  end;
end;

function TTMultiTenant<T>.GetFailureCooldown: Cardinal;
begin
  FLock.BeginRead;
  try
    result := FFailureCooldown;
  finally
    FLock.EndRead;
  end;
end;

procedure TTMultiTenant<T>.SetFailureCooldown(const AValue: Cardinal);
begin
  FLock.BeginWrite;
  try
    FFailureCooldown := AValue;
  finally
    FLock.EndWrite;
  end;
end;

procedure TTMultiTenant<T>.RemoveFailure(const AName: String);
begin
  FLock.BeginWrite;
  try
    FFailures.Remove(AName);
  finally
    FLock.EndWrite;
  end;
end;

procedure TTMultiTenant<T>.RemoveExpiredFailures;
var
  LPair: TPair<String, TTTenantFailure>;
  LExpired: TList<String>;
  LName: String;
begin
  LExpired := TList<String>.Create;
  try
    for LPair in FFailures do
      if LPair.Value.IsExpired then
        LExpired.Add(LPair.Key);
    for LName in LExpired do
      FFailures.Remove(LName);
  finally
    LExpired.Free;
  end;
end;

procedure TTMultiTenant<T>.RemoveOldestFailure;
var
  LPair: TPair<String, TTTenantFailure>;
  LName: String;
  LExpiration: UInt64;
begin
  if FFailures.Count >= MaxFailures then
  begin
    LName := String.Empty;
    LExpiration := High(UInt64);
    for LPair in FFailures do
      if LPair.Value.Expiration <= LExpiration then
      begin
        LExpiration := LPair.Value.Expiration;
        LName := LPair.Key;
      end;

    if not LName.IsEmpty then
      FFailures.Remove(LName);
  end;
end;

function TTMultiTenant<T>.GetOrAdd(const AName: String): TTTenant<T>;
var
  LName: String;
begin
  LName := AName.ToLower();
  if not TryGetTenant(LName, result) then
  begin
    CheckFailure(LName);
    result := CreateTenantOrFail(LName);
  end;
end;

function TTMultiTenant<T>.GetAll: TArray<string>;
var
  LTenant: TTTenant<T>;
  LIndex: Integer;
begin
  FLock.BeginRead;
  try
    SetLength(result, FTenants.Count);
    LIndex := 0;
    for LTenant in FTenants.Values do
    begin
      result[LIndex] := LTenant.Name;
      Inc(LIndex);
    end;
  finally
    FLock.EndRead;
  end;
end;

procedure TTMultiTenant<T>.Remove(const AName: String);
var
  LName: String;
begin
  LName := AName.ToLower();
  FLock.BeginWrite;
  try
    FTenants.Remove(LName);
    FFailures.Remove(LName);
  finally
    FLock.EndWrite;
  end;
end;

end.
