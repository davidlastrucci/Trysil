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
  System.TypInfo,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Events.Abstract,
  Trysil.Events.Factory,
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

    function LoadOldEntity: T;
    function GetOldEntity: T;
  strict protected
    property Context: TTContext read FContext;
    property OldEntity: T read GetOldEntity;
    property Entity: T read FEntity;
  public
    constructor Create(
      const AContext: TTContext;
      const AEntity: T;
      const AOperation: TTEventOperation);
    destructor Destroy; override;

    procedure CommandExecuted; override;
  end;

{ TTEntityEvents<T> }

  TTEntityEvents<T: class> = class(TTEvent<T>)
  strict protected
    procedure BeforeInsert; virtual;
    procedure AfterInsert; virtual;
    procedure BeforeUpdate; virtual;
    procedure AfterUpdate; virtual;
    procedure BeforeDelete; virtual;
    procedure AfterDelete; virtual;
  public
    procedure DoBefore; override;
    procedure DoAfter; override;
  end;

{ TTEventRegistration }

  TTEventRegistration = class
  public
    class procedure RegisterEvents<T: class; E: TTEntityEvents<T>>;
  end;

implementation

{ TTEvent<T> }

constructor TTEvent<T>.Create(
  const AContext: TTContext;
  const AEntity: T;
  const AOperation: TTEventOperation);
begin
  inherited Create(AOperation);
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

function TTEvent<T>.LoadOldEntity: T;
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

function TTEvent<T>.GetOldEntity: T;
begin
  if Operation = TTEventOperation.Insert then
    result := nil
  else
    result := LoadOldEntity;
end;

{ TTEntityEvents<T> }

procedure TTEntityEvents<T>.BeforeInsert;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.AfterInsert;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.BeforeUpdate;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.AfterUpdate;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.BeforeDelete;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.AfterDelete;
begin
  // Do nothing
end;

procedure TTEntityEvents<T>.DoBefore;
begin
  inherited DoBefore;
  case Operation of
    TTEventOperation.Insert: BeforeInsert;
    TTEventOperation.Update: BeforeUpdate;
    TTEventOperation.Delete: BeforeDelete;
  end;
end;

procedure TTEntityEvents<T>.DoAfter;
begin
  inherited DoAfter;
  case Operation of
    TTEventOperation.Insert: AfterInsert;
    TTEventOperation.Update: AfterUpdate;
    TTEventOperation.Delete: AfterDelete;
  end;
end;

{ TTEventRegistration }

class procedure TTEventRegistration.RegisterEvents<T, E>;
begin
  TTEventRegistry.Instance.RegisterEvents(
    TypeInfo(T), TTEventClass(GetTypeData(TypeInfo(E)).ClassType));
end;

end.
