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

  Trysil.Types,
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

{ TEventMethodAttribute }

  TEventMethodAttribute = class(TCustomAttribute)
  strict private
    FEventMethodType: TTEventMethodType;
  public
    constructor Create(const AEventMethodType: TTEventMethodType);

    property EventMethodType: TTEventMethodType read FEventMethodType;
  end;

{ TBeforeInsertEventAttribute }

  TBeforeInsertEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

{ TAfterInsertEventAttribute }

  TAfterInsertEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

{ TBeforeUpdateEventAttribute }

  TBeforeUpdateEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

{ TAfterUpdateEventAttribute }

  TAfterUpdateEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

{ TBeforeDeleteEventAttribute }

  TBeforeDeleteEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

{ TAfterDeleteEventAttribute }

  TAfterDeleteEventAttribute = class(TEventMethodAttribute)
  public
    constructor Create;
  end;

implementation

{ TEventAttribute }

constructor TEventAttribute.Create(const AEventClass: TTEventClass);
begin
  inherited Create;
  FEventClass := AEventClass;
end;

{ TEventMethodAttribute }

constructor TEventMethodAttribute.Create(
  const AEventMethodType: TTEventMethodType);
begin
  inherited Create;
  FEventMethodType := AEventMethodType;
end;

{ TBeforeInsertEventAttribute }

constructor TBeforeInsertEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.BeforeInsert);
end;

{ TAfterInsertEventAttribute }

constructor TAfterInsertEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.AfterInsert);
end;

{ TBeforeUpdateEventAttribute }

constructor TBeforeUpdateEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.BeforeUpdate);
end;

{ TAfterUpdateEventAttribute }

constructor TAfterUpdateEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.AfterUpdate);
end;

{ TBeforeDeleteEventAttribute }

constructor TBeforeDeleteEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.BeforeDelete);
end;

{ TAfterDeleteEventAttribute }

constructor TAfterDeleteEventAttribute.Create;
begin
  inherited Create(TTEventMethodType.AfterDelete);
end;

end.
