(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Consts,

  Trysil.Http,
  Trysil.Http.Rtti,

  Trysil.OpenAPI.Consts,
  Trysil.OpenAPI.Exceptions,
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Generator,
  Trysil.OpenAPI.Controller;

type

{ TTOpenApi<C> }

  TTOpenApi<C: class, constructor> = class
  strict private
    class function IsRegistered(const AServer: TTHttpServer<C>): Boolean;
    class procedure Check(
      const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
    class function CreateDocument(
      const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo): String;
  public
    class procedure Register(
      const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
    class procedure RegisterAnonymous(
      const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
  end;

implementation

{ TTOpenApi<C> }

class function TTOpenApi<C>.IsRegistered(
  const AServer: TTHttpServer<C>): Boolean;
var
  LRoute: TTHttpRoute;
begin
  result := False;
  for LRoute in AServer.Routes do
    result := result or
      LRoute.ControllerClass.InheritsFrom(TTOpenApiController<C>);
end;

class procedure TTOpenApi<C>.Check(
  const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
begin
  if AServer.Started then
    raise ETOpenApiException.Create(
      TTLanguage.Instance.Translate(SOpenApiServerStarted));
  if IsRegistered(AServer) then
    raise ETOpenApiException.Create(
      TTLanguage.Instance.Translate(SOpenApiAlreadyRegistered));
  if not TTOpenApiController<C>.Document.IsEmpty then
    raise ETOpenApiException.Create(
      TTLanguage.Instance.Translate(SOpenApiContextAlreadyRegistered));
  if AInfo.Title.IsEmpty then
    raise ETOpenApiException.Create(
      TTLanguage.Instance.Translate(SOpenApiEmptyTitle));
  if AInfo.Version.IsEmpty then
    raise ETOpenApiException.Create(
      TTLanguage.Instance.Translate(SOpenApiEmptyVersion));
end;

class function TTOpenApi<C>.CreateDocument(
  const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo): String;
var
  LGenerator: TTOpenApiGenerator;
begin
  Check(AServer, AInfo);
  LGenerator := TTOpenApiGenerator.Create(
    AInfo, AServer.Routes, AServer.BaseUri, AServer.AuthenticationClass);
  try
    result := LGenerator.Generate;
  finally
    LGenerator.Free;
  end;
end;

class procedure TTOpenApi<C>.Register(
  const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
var
  LDocument: String;
begin
  LDocument := CreateDocument(AServer, AInfo);
  AServer.RegisterControllerClass(
    TTOpenApiController<C>, SOpenApiDocumentUri);
  TTOpenApiController<C>.Document := LDocument;
end;

class procedure TTOpenApi<C>.RegisterAnonymous(
  const AServer: TTHttpServer<C>; const AInfo: TTOpenApiInfo);
var
  LDocument: String;
begin
  LDocument := CreateDocument(AServer, AInfo);
  AServer.RegisterControllerClass(
    TTOpenApiAnonymousController<C>, SOpenApiDocumentUri);
  TTOpenApiController<C>.Document := LDocument;
end;

end.
