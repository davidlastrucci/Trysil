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

  Trysil.Http.Resolver;

type

{ TTHttpContext }

  TTHttpContext = class(TTJSonContext)
  strict protected
    function CreateResolver: TTResolver; override;
  public
    function GetID<T: class>(const AEntity: T): TTPrimaryKey;
    procedure SetSequenceID<T: class>(const AEntity: T);

    procedure Delete<T: class>(
      const AID: TTPrimaryKey; const AVersionID: TTVersion); overload;
  end;

implementation

{ TTHttpContext }

function TTHttpContext.CreateResolver: TTResolver;
begin
  result := TTHttpResolver.Create(FConnection, Self, FMetadata);
end;

function TTHttpContext.GetID<T>(const AEntity: T): TTPrimaryKey;
begin
  result := FProvider.GetID<T>(AEntity);
end;

procedure TTHttpContext.SetSequenceID<T>(const AEntity: T);
begin
  FProvider.SetSequenceID<T>(AEntity);
end;

procedure TTHttpContext.Delete<T>(
  const AID: TTPrimaryKey; const AVersionID: TTVersion);
var
  LTableMap: TTTableMap;
  LEntity: T;
  LVersionID: TTVersion;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LEntity := Get<T>(AID);
  if not Assigned(LEntity) then
    raise ETException.Create(SRecordChanged);
  try
    if Assigned(LTableMap.VersionColumn) then
      LTableMap.VersionColumn.Member.SetValue(LEntity, AVersionID);
    Delete<T>(LEntity);
  finally
    LEntity.Free;
  end;
end;

end.
