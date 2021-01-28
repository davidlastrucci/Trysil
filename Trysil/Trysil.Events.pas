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
  strict protected
    FContext: TTContext;
    FEntity: T;
  public
    constructor Create(const AContext: TTContext; const AEntity: T);
  end;

implementation

{ TTEvent<T> }

constructor TTEvent<T>.Create(const AContext: TTContext; const AEntity: T);
begin
  inherited Create;
  FContext := AContext;
  FEntity := AEntity;
end;

end.
