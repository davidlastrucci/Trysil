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

  TTEntityIdentityMap = class(TTCache<TTPrimaryKey, TObject>);

{ TTIdentityMap }

  TTIdentityMap = class(TTCacheEx<PTypeInfo, TTEntityIdentityMap>)
  strict protected
    function CreateObject(
      const ATypeInfo: PTypeInfo): TTEntityIdentityMap; override;
  public
    procedure AddEntity<T: class>(
      const APrimaryKey: TTPrimaryKey; const AEntity: T);
    function GetEntity<T: class>(const APrimaryKey: TTPrimaryKey): T;
    procedure RemoveEntity<T: class>(const APrimaryKey: TTPrimaryKey);
  end;

implementation

{ TTIdentityMap }

function TTIdentityMap.CreateObject(
  const ATypeInfo: PTypeInfo): TTEntityIdentityMap;
begin
  result := TTEntityIdentityMap.Create;
end;

procedure TTIdentityMap.AddEntity<T>(
  const APrimaryKey: TTPrimaryKey; const AEntity: T);
begin
  GetValueOrCreate(TypeInfo(T)).Add(APrimaryKey, AEntity);
end;

function TTIdentityMap.GetEntity<T>(const APrimaryKey: TTPrimaryKey): T;
var
  LResult: TObject;
begin
  result := default(T);
  if GetValueOrCreate(TypeInfo(T)).TryGetValue(APrimaryKey, LResult) then
    result := T(LResult);
end;

procedure TTIdentityMap.RemoveEntity<T>(const APrimaryKey: TTPrimaryKey);
begin
  GetValueOrCreate(TypeInfo(T)).Remove(APrimaryKey);
end;

end.
