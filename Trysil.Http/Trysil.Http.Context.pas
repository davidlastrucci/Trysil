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
  System.Classes;

type

{ TTHttpContext<A> }

  TTHttpContext<A: class> = class
  strict private
    FApplicationContext: A;
  public
    constructor Create(const AApplicationContext: A); virtual;

    property ApplicationContext: A read FApplicationContext;
  end;

implementation

{ TTHttpContext<A> }

constructor TTHttpContext<A>.Create(const AApplicationContext: A);
begin
  inherited Create;
  FApplicationContext := AApplicationContext;
end;

end.
