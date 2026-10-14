(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Controller;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Controller;

type

{ TTOpenApiController<C> }

  TTOpenApiController<C: class> = class(TTHttpController<C>)
  strict private
    class var FDocument: String;
  public
    [TGet]
    procedure Get;

    class property Document: String read FDocument write FDocument;
  end;

{ TTOpenApiAnonymousController<C> }

  [TAuthorizationType(TTHttpAuthorizationType.None)]
  TTOpenApiAnonymousController<C: class> = class(TTOpenApiController<C>);

implementation

{ TTOpenApiController<C> }

procedure TTOpenApiController<C>.Get;
begin
  FResponse.Content := FDocument;
end;

end.
