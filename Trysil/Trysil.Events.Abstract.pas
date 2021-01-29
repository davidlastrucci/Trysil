(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Events.Abstract;

interface

uses
  System.SysUtils,
  System.Classes;

type

{ TTEvent }

  TTEvent = class abstract
  public
    procedure DoBefore; virtual;
    procedure DoAfter; virtual;
  end;

{ TTEventClass }

  TTEventClass = class of TTEvent;

implementation

{ TTEvent }

procedure TTEvent.DoBefore;
begin
  // Do nothing
end;

procedure TTEvent.DoAfter;
begin
  // Do nothing
end;

end.
