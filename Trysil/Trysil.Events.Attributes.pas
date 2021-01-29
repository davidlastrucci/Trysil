(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Events.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Events.Abstract;

type

{ TEventAttribute }

  TEventAttribute = class(TCustomAttribute)
  strict private
    FEventClass: TTEventClass;
  public
    constructor Create(const AEventClass: TTEventClass);

    property EventClass: TTEventClass read FEventClass;
  end;

{ TInsertEventAttribute }

  TInsertEventAttribute = class(TEventAttribute);

{ TUpdateEventAttribute }

  TUpdateEventAttribute = class(TEventAttribute);

{ TDeleteEventAttribute }

  TDeleteEventAttribute = class(TEventAttribute);

implementation

{ TEventAttribute }

constructor TEventAttribute.Create(const AEventClass: TTEventClass);
begin
  inherited Create;
  FEventClass := AEventClass;
end;

end.
