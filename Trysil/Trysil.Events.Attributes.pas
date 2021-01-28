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
  System.TypInfo;

type

{ TEventAttribute }

  TEventAttribute = class(TCustomAttribute)
  strict private
    FEventTypeInfo: PTypeInfo;
  public
    constructor Create(const AEventTypeInfo: PTypeInfo);

    property EventTypeInfo: PTypeInfo read FEventTypeInfo;
  end;

{ TInsertEventAttribute }

  TInsertEventAttribute = class(TEventAttribute);

{ TUpdateEventAttribute }

  TUpdateEventAttribute = class(TEventAttribute);

{ TDeleteEventAttribute }

  TDeleteEventAttribute = class(TEventAttribute);

implementation

{ TEventAttribute }

constructor TEventAttribute.Create(const AEventTypeInfo: PTypeInfo);
begin
  inherited Create;
  FEventTypeInfo := AEventTypeInfo;
end;

end.
