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

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Events.Abstract,
  Trysil.Context;

type

{ TTEvent<T> }

  TTEvent<T: class> = class(TTEvent)
  strict private
    FContext: TTContext;
    FOldEntity: T;
    FOldEntityLoaded: Boolean;
    FCommandExecuted: Boolean;
    FEntity: T;

    function GetOldEntity: T;
  strict protected
    property Context: TTContext read FContext;
    property OldEntity: T read GetOldEntity;
    property Entity: T read FEntity;
  public
    constructor Create(const AContext: TTContext; const AEntity: T);
    destructor Destroy; override;

    procedure CommandExecuted; override;
  end;

implementation

{ TTEvent<T> }

constructor TTEvent<T>.Create(const AContext: TTContext; const AEntity: T);
begin
  inherited Create;
  FContext := AContext;
  FOldEntity := nil;
  FOldEntityLoaded := False;
  FCommandExecuted := False;
  FEntity := AEntity;
end;

destructor TTEvent<T>.Destroy;
begin
  FContext.FreeClone<T>(FOldEntity);
  inherited Destroy;
end;

procedure TTEvent<T>.CommandExecuted;
begin
  inherited CommandExecuted;
  FCommandExecuted := True;
end;

function TTEvent<T>.GetOldEntity: T;
begin
  if not FOldEntityLoaded then
  begin
    if FCommandExecuted then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SOldEntityAfterCommand));

    FOldEntity := FContext.OldEntity<T>(FEntity);
    FOldEntityLoaded := True;
  end;
  result := FOldEntity;
end;

end.
