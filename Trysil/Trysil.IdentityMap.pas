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

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions;

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
var
  LEntityIdentityMap: TTEntityIdentityMap;
  LEntity: TObject;
begin
  LEntityIdentityMap := GetEntityIdentityMap(TypeInfo(T));
  if LEntityIdentityMap.TryGetValue(APrimaryKey, LEntity) and
    (LEntity <> TObject(AEntity)) then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SDuplicateEntityIdentity), [
        TObject(AEntity).ClassName, APrimaryKey]);

  LEntityIdentityMap.Add(APrimaryKey, AEntity);
end;

function TTIdentityMap.GetEntity<T>(const APrimaryKey: TTPrimaryKey): T;
var
  LResult: TObject;
begin
  result := default(T);
  if GetEntityIdentityMap(TypeInfo(T)).TryGetValue(APrimaryKey, LResult) then
    result := T(LResult);
end;

end.
