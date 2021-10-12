(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.IdentityMap;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.TypInfo,

  Trysil.Types,
  Trysil.Cache;

type

{ TTEntityIdentityMap }

  TTEntityIdentityMap = class
  strict private
    FCache: TObjectDictionary<TTPrimaryKey, TObject>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const APrimaryKey: TTPrimaryKey; const AEntity: TObject);
    function TryGetValue(
      const APrimaryKey: TTPrimaryKey; var AEntity: TObject): Boolean;
    procedure Remove(const APrimaryKey: TTPrimaryKey);
  end;

{ TTIdentityMap }

  TTIdentityMap = class
  strict private
    FCache: TObjectDictionary<PTypeInfo, TTEntityIdentityMap>;

    function GetEntityIdentityMap(
      const ATypeInfo: PTypeInfo): TTEntityIdentityMap;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddEntity<T: class>(
      const APrimaryKey: TTPrimaryKey; const AEntity: T);
    function GetEntity<T: class>(const APrimaryKey: TTPrimaryKey): T;
    procedure RemoveEntity<T: class>(const APrimaryKey: TTPrimaryKey);
  end;

implementation

{ TTEntityIdentityMap }

constructor TTEntityIdentityMap.Create;
begin
  inherited Create;
  FCache := TObjectDictionary<TTPrimaryKey, TObject>.Create([doOwnsValues]);
end;

destructor TTEntityIdentityMap.Destroy;
begin
  FCache.Free;
  inherited Destroy;
end;

procedure TTEntityIdentityMap.Add(
  const APrimaryKey: TTPrimaryKey; const AEntity: TObject);
begin
  if not FCache.ContainsKey(APrimaryKey) then
    FCache.Add(APrimaryKey, AEntity);
end;

function TTEntityIdentityMap.TryGetValue(
  const APrimaryKey: TTPrimaryKey; var AEntity: TObject): Boolean;
begin
  result := FCache.TryGetValue(APrimaryKey, AEntity);
end;

procedure TTEntityIdentityMap.Remove(const APrimaryKey: TTPrimaryKey);
begin
  if FCache.ContainsKey(APrimaryKey) then
    FCache.Remove(APrimaryKey);
end;

{ TTIdentityMap }

constructor TTIdentityMap.Create;
begin
  inherited Create;
  FCache := TObjectDictionary<
    PTypeInfo, TTEntityIdentityMap>.Create([doOwnsValues]);
end;

destructor TTIdentityMap.Destroy;
begin
  FCache.Free;
  inherited Destroy;
end;

function TTIdentityMap.GetEntityIdentityMap(
  const ATypeInfo: PTypeInfo): TTEntityIdentityMap;
begin
  if not FCache.TryGetValue(ATypeInfo, result) then
  begin
    result := TTEntityIdentityMap.Create;
    try
      FCache.Add(ATypeInfo, result);
    except
      result.Free;
      raise;
    end;
  end;
end;

procedure TTIdentityMap.AddEntity<T>(
  const APrimaryKey: TTPrimaryKey; const AEntity: T);
begin
  GetEntityIdentityMap(TypeInfo(T)).Add(APrimaryKey, AEntity);
end;

function TTIdentityMap.GetEntity<T>(const APrimaryKey: TTPrimaryKey): T;
var
  LResult: TObject;
begin
  result := default(T);
  if GetEntityIdentityMap(TypeInfo(T)).TryGetValue(APrimaryKey, LResult) then
    result := T(LResult);
end;

procedure TTIdentityMap.RemoveEntity<T>(const APrimaryKey: TTPrimaryKey);
begin
  GetEntityIdentityMap(TypeInfo(T)).Remove(APrimaryKey);
end;

end.
