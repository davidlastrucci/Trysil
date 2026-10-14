(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Controller;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Classes;

type

{ TTHttpController<C> }

  TTHttpController<C: class> = class abstract
  strict protected
    FContext: C;
    FRequest: TTHttpRequest;
    FResponse: TTHttpResponse;
  public
    constructor Create(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); virtual;
    class function EntityClass: TClass; virtual;
  end;

implementation

{ TTHttpController<C> }

constructor TTHttpController<C>.Create(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create;
  FContext := AContext;
  FRequest := ARequest;
  FResponse := AResponse;
end;

class function TTHttpController<C>.EntityClass: TClass;
begin
  result := nil;
end;

end.
