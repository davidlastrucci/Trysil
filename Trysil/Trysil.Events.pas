(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Events;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Events.Abstract,
  Trysil.Context;

type

{ TTEvent<T> }

  TTEvent<T: class> = class(TTEvent)
  strict private
    FContext: TTContext;
    FOldEntity: T;
    FEntity: T;

    function GetOldEntity: T;
  strict protected
    property Context: TTContext read FContext;
    property OldEntity: T read GetOldEntity;
    property Entity: T read FEntity;
  public
    constructor Create(const AContext: TTContext; const AEntity: T);
    destructor Destroy; override;
  end;

implementation

{ TTEvent<T> }

constructor TTEvent<T>.Create(const AContext: TTContext; const AEntity: T);
begin
  inherited Create;
  FContext := AContext;
  FOldEntity := nil;
  FEntity := AEntity;
end;

destructor TTEvent<T>.Destroy;
begin
  if Assigned(FOldEntity) then
    FOldEntity.Free;
  inherited Destroy;
end;

function TTEvent<T>.GetOldEntity: T;
begin
  if not Assigned(FOldEntity) then
  begin
    FOldEntity := FContext.CloneEntity<T>(FEntity);
    try
      FContext.Refresh<T>(FOldEntity);
    except
      FOldEntity.Free;
      FOldEntity := nil;
      raise;
    end;
  end;

  result := FOldEntity;
end;

end.
