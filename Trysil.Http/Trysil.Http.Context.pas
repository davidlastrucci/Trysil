(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Context;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,
  Trysil.Types,
  Trysil.Mapping,
  Trysil.Exceptions,
  Trysil.Resolver,
  Trysil.JSon.Context,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Resolver;

type

{ TTHttpContext }

  TTHttpContext = class(TTJSonContext)
  strict protected
    procedure CheckSave; override;
    function CreateResolver: TTResolver; override;
  public
    function GetID<T: class>(const AEntity: T): TTPrimaryKey;
    procedure SetSequenceID<T: class>(const AEntity: T);
    procedure SetVersionID<T: class>(
      const AEntity: T; const AVersionID: TTVersion);

    procedure Delete<T: class>(
      const AID: TTPrimaryKey; const AVersionID: TTVersion); overload;
  end;

implementation

{ TTHttpContext }

procedure TTHttpContext.CheckSave;
begin
  raise ETHttpServerException.Create(
    TTLanguage.Instance.Translate(SNoSaveOnHttpContext));
end;

function TTHttpContext.CreateResolver: TTResolver;
begin
  result := TTHttpResolver.Create(FWriteConnection, Self, FMetadata);
end;

function TTHttpContext.GetID<T>(const AEntity: T): TTPrimaryKey;
begin
  result := FProvider.GetID<T>(AEntity);
end;

procedure TTHttpContext.SetSequenceID<T>(const AEntity: T);
begin
  FProvider.SetSequenceID<T>(AEntity);
end;

procedure TTHttpContext.SetVersionID<T>(
  const AEntity: T; const AVersionID: TTVersion);
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  if Assigned(LTableMap.VersionColumn) then
    LTableMap.VersionColumn.Member.SetValue(AEntity, AVersionID);
end;

procedure TTHttpContext.Delete<T>(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
var
  LEntity: T;
begin
  if not TryGet<T>(AID, LEntity) then
    raise ETHttpNotFound.CreateFmt(
      TTLanguage.Instance.Translate(SEntityNotFound), [AID]);
  try

    SetVersionID<T>(LEntity, AVersionID);
    Delete<T>(LEntity);
  finally
    FreeEntity<T>(LEntity);
  end;
end;

end.
