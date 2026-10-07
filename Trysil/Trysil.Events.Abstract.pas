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

{$SCOPEDENUMS ON}

{ TTEventOperation }

  TTEventOperation = (Insert, Update, Delete);

{ TTEvent }

  TTEvent = class abstract
  strict private
    FOperation: TTEventOperation;
  strict protected
    property Operation: TTEventOperation read FOperation;
  public
    constructor Create(const AOperation: TTEventOperation);

    procedure CommandExecuted; virtual;

    procedure DoBefore; virtual;
    procedure DoAfter; virtual;
  end;

{ TTEventClass }

  TTEventClass = class of TTEvent;

implementation

{ TTEvent }

constructor TTEvent.Create(const AOperation: TTEventOperation);
begin
  inherited Create;
  FOperation := AOperation;
end;

procedure TTEvent.CommandExecuted;
begin
  // Do nothing
end;

procedure TTEvent.DoBefore;
begin
  // Do nothing
end;

procedure TTEvent.DoAfter;
begin
  // Do nothing
end;

end.
