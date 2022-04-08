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

  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Authentication;

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

end.
