(*

  Trysil
  Copyright © David Lastrucci
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
  Trysil.Sync,
  Trysil.Data.FireDAC,

  Trysil.Http.MultiTenant.Config,
  Trysil.Http.MultiTenant.Connection;

type

{ TTTenant<T, C> }

  TTTenant<T: TTTenantConnection; C: TTTenantConfig> = class
  strict private
    FName: String;
    FConfig: C;
    FConnection: T;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;

    property Name: String read FName;
    property Config: C read FConfig;
    property Connection: T read FConnection;
  end;

{ TTMultiTenant<T, C> }

  TTMultiTenant<T: TTTenantConnection; C: TTTenantConfig> = class
  strict private
    class var FInstance: TTMultiTenant<T, C>;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FCriticalSection: TTCriticalSection;
    FOwner: TObjectList<TTTenant<T, C>>;
    FTenants: TDictionary<String, TTTenant<T, C>>;

    function CreateTenant(const AName: String): TTTenant<T, C>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetOrAdd(const AName: String): TTTenant<T, C>;
    function GetAll: TArray<string>;
    procedure Remove(const AName: String);

    class property Instance: TTMultiTenant<T, C> read FInstance;
  end;

implementation

{ TTTenant<T, C> }

constructor TTTenant<T, C>.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
  FConfig := C.Create(AName);
  FConnection := T.Create(FConfig);
end;

destructor TTTenant<T, C>.Destroy;
begin
  FConnection.Free;
  FConfig.Free;
  inherited Destroy;
end;

{ TTMultiTenant<T, C> }

class constructor TTMultiTenant<T, C>.ClassCreate;
begin
  FInstance := TTMultiTenant<T, C>.Create;
end;

class destructor TTMultiTenant<T, C>.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTMultiTenant<T, C>.Create;
begin
  inherited Create;
  FCriticalSection := TTCriticalSection.Create;
  FOwner := TObjectList<TTTenant<T, C>>.Create(True);
  FTenants := TDictionary<String, TTTenant<T, C>>.Create;
end;

destructor TTMultiTenant<T, C>.Destroy;
begin
  FTenants.Free;
  FOwner.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

function TTMultiTenant<T, C>.CreateTenant(
  const AName: String): TTTenant<T, C>;
begin
  result := TTTenant<T, C>.Create(AName);
  try
    FTenants.Add(AName.ToLower(), result);
    FOwner.Add(result);
  except
    result.Free;
    raise;
  end;
end;

function TTMultiTenant<T, C>.GetOrAdd(const AName: String): TTTenant<T, C>;
var
  LName: String;
begin
  LName := AName.ToLower();
  if not FTenants.TryGetValue(LName, result) then
  begin
    FCriticalSection.Acquire;
    try
      if not FTenants.TryGetValue(LName, result) then
        result := CreateTenant(AName);
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

function TTMultiTenant<T, C>.GetAll: TArray<string>;
var
  LLength, LIndex: Integer;
begin
  FCriticalSection.Acquire;
  try
    LLength := FOwner.Count;
    SetLength(result, LLength);
    for LIndex := 0 to LLength - 1 do
      result[LIndex] := FOwner[LIndex].Name;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TTMultiTenant<T, C>.Remove(const AName: String);
var
  LName: String;
  LTenant: TTTenant<T, C>;
begin
  LName := AName.ToLower();
  FCriticalSection.Acquire;
  try
    if FTenants.TryGetValue(LName, LTenant) then
    begin
        FTenants.Remove(LName);
        FOwner.Remove(LTenant);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

end.
