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

{ TTTenant<T> }

  TTTenant<T: TTTenantConfig> = class
  strict private
    FName: String;
    FConfig: T;
    FConnection: TTTenantConnection;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;

    property Name: String read FName;
    property Config: T read FConfig;
    property Connection: TTTenantConnection read FConnection;
  end;

{ TTMultiTenant<C> }

  TTMultiTenant<T: TTTenantConfig> = class
  strict private
    class var FInstance: TTMultiTenant<T>;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FCriticalSection: TTCriticalSection;
    FOwner: TObjectList<TTTenant<T>>;
    FTenants: TDictionary<String, TTTenant<T>>;

    function CreateTenant(const AName: String): TTTenant<T>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetOrAdd(const AName: String): TTTenant<T>;
    function GetAll: TArray<string>;
    procedure Remove(const AName: String);

    class property Instance: TTMultiTenant<T> read FInstance;
  end;

implementation

{ TTTenant<T> }

constructor TTTenant<T>.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
  FConfig := T.Create(AName);
  FConnection := TTTenantConnection.Create(FConfig);
end;

destructor TTTenant<T>.Destroy;
begin
  FConnection.Free;
  FConfig.Free;
  inherited Destroy;
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
  FCriticalSection := TTCriticalSection.Create;
  FOwner := TObjectList<TTTenant<T>>.Create(True);
  FTenants := TDictionary<String, TTTenant<T>>.Create;
end;

destructor TTMultiTenant<T>.Destroy;
begin
  FTenants.Free;
  FOwner.Free;
  FCriticalSection.Free;
  inherited Destroy;
end;

function TTMultiTenant<T>.CreateTenant(const AName: String): TTTenant<T>;
begin
  result := TTTenant<T>.Create(AName);
  try
    FTenants.Add(AName.ToLower(), result);
    FOwner.Add(result);
  except
    result.Free;
    raise;
  end;
end;

function TTMultiTenant<T>.GetOrAdd(const AName: String): TTTenant<T>;
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

function TTMultiTenant<T>.GetAll: TArray<string>;
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

procedure TTMultiTenant<T>.Remove(const AName: String);
var
  LName: String;
  LTenant: TTTenant<T>;
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
