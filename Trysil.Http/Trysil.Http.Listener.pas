(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Listener;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Cors,
  Trysil.Http.Rtti,
  Trysil.Http.Controller,
  Trysil.Http.Authentication;

type

{ TTHttpListener<C> }

  TTHttpListener<C: class, constructor> = class
  strict private
    FCors: TTHttpCors;
    FRttiControllers: TTHttpRttiControllers<C>;
    FFreeControllerIDs: TList<TTHttpControllerID>;
    FRttiAuthentication: TTHttpRttiAuthentication<C>;

    function InternalIsFreeController(
      const AControllerID: TTHttpControllerID): Boolean;

    procedure InternalCheckAuthentication(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse);

    procedure CheckAuthentication(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse);

    procedure CheckAreas(
      const ARequest: TTHttpRequest;
      const ARttiControllerMethod: TTHttpRttiControllerMethod<C>);

    procedure InitializeResponse(const AResponse: TTHttpResponse);

    procedure InternalHandleRequest(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);

    procedure MakeResponse(
      const AResponse: TTHttpResponse;
      const AStatusCode: Integer;
      const AContent: String);
  public
    constructor Create(
      const ACors: TTHttpCors;
      const ARttiControllers: TTHttpRttiControllers<C>;
      const AFreeControllerIDs: TList<TTHttpControllerID>);

    procedure SetRttiAuthentication(
      const ARttiAuthentication: TTHttpRttiAuthentication<C>);

    procedure HandleRequest(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
  end;

implementation

{ TTHttpListener<C> }

constructor TTHttpListener<C>.Create(
  const ACors: TTHttpCors;
  const ARttiControllers: TTHttpRttiControllers<C>;
  const AFreeControllerIDs: TList<TTHttpControllerID>);
begin
  inherited Create;
  FCors := ACors;
  FRttiControllers := ARttiControllers;
  FFreeControllerIDs := AFreeControllerIDs;
  FRttiAuthentication := nil;
end;

procedure TTHttpListener<C>.SetRttiAuthentication(
  const ARttiAuthentication: TTHttpRttiAuthentication<C>);
begin
  FRttiAuthentication := ARttiAuthentication;
end;

procedure TTHttpListener<C>.HandleRequest(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
begin
  try
    InitializeResponse(AResponse);
    if ARequest.ControllerID.MethodType = TTHttpMethodType.OPTIONS then
      FCors.AddCorsHeaders(ARequest.ControllerID.Uri, AResponse)
    else
      InternalHandleRequest(ARequest, AResponse);
  except
    on E: ETHttpException do
      MakeResponse(AResponse, E.StatusCode, E.ToJSon());
    on E: Exception do
      MakeResponse(
        AResponse,
        TTHttpStatusCodeTypes.InternalServerError,
        E.ToJSon());
  end;
end;

procedure TTHttpListener<C>.InternalHandleRequest(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
var
  LContext: C;
  LParams: TList<Integer>;
  LRttiControllerMethod: TTHttpRttiControllerMethod<C>;
  LController: TTHttpController<C>;
begin
  LContext := C.Create;
  try
    LParams := TList<Integer>.Create;
    try
      InternalCheckAuthentication(LContext, ARequest, AResponse);
      LRttiControllerMethod := FRttiControllers.Get(
        ARequest.ControllerID, LParams);
      CheckAreas(ARequest, LRttiControllerMethod);
      LController := LRttiControllerMethod.Controller.CreateController(
        LContext, ARequest, AResponse);
      if Assigned(LController) then
        try
          LRttiControllerMethod.Method.Execute(LController, LParams.ToArray);
        finally
          LController.Free;
        end;
    finally
      LParams.Free;
    end;
  finally
    LContext.Free;
  end;
end;

function TTHttpListener<C>.InternalIsFreeController(
  const AControllerID: TTHttpControllerID): Boolean;
var
  LControllerID: TTHttpControllerID;
begin
  result := False;
  for LControllerID in FFreeControllerIDs do
    if LControllerID.Equals(AControllerID) then
    begin
      result := True;
      Break;
    end;
end;

procedure TTHttpListener<C>.InternalCheckAuthentication(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
var
  LNeedAuthentication: Boolean;
begin
  LNeedAuthentication := Assigned(FRttiAuthentication);
  if LNeedAuthentication then
    LNeedAuthentication := not InternalIsFreeController(ARequest.ControllerID);
  if LNeedAuthentication then
    CheckAuthentication(AContext, ARequest, AResponse);
end;

procedure TTHttpListener<C>.CheckAuthentication(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
var
  LAuthentication: TTHttpAbstractAuthentication<C>;
begin
  LAuthentication := FRttiAuthentication.CreateAuthentication(AContext);
  try
    LAuthentication.Check(ARequest, AResponse)
  finally
    LAuthentication.Free;
  end;
end;

procedure TTHttpListener<C>.CheckAreas(
  const ARequest: TTHttpRequest;
  const ARttiControllerMethod: TTHttpRttiControllerMethod<C>);
var
  LArea: String;
begin
  if Assigned(FRttiAuthentication) then
    for LArea in ARttiControllerMethod.Method.Areas do
      if not ARequest.User.Areas.Contains(LArea) then
        raise ETHttpForbidden.CreateFmt(SForbiddenArea, [
          ARequest.ControllerID.Uri, LArea])
end;

procedure TTHttpListener<C>.InitializeResponse(const AResponse: TTHttpResponse);
begin
  FCors.AddAllowOrigin(AResponse);
  AResponse.StatusCode := TTHttpStatusCodeTypes.OK;
  AResponse.ContentType := TTHttpContentTypes.JSon;
  AResponse.ContentEncoding := TTHttpContentEncodingTypes.Utf8;
end;

procedure TTHttpListener<C>.MakeResponse(
  const AResponse: TTHttpResponse;
  const AStatusCode: Integer;
  const AContent: String);
begin
  AResponse.StatusCode := AStatusCode;
  AResponse.Content := AContent;
end;

end.
