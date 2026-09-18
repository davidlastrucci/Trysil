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
  Trysil.Consts,
  Trysil.Exceptions,

  Trysil.JSon.Exceptions,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Cors,
  Trysil.Http.Rtti,
  Trysil.Http.Controller,
  Trysil.Http.Authentication,
  Trysil.Http.Log;

type

{ TTHttpListener<C> }

  TTHttpListener<C: class, constructor> = class
  strict private
    FCors: TTHttpCors;
    FRttiControllers: TTHttpRttiControllers<C>;
    FLog: TTHttpLog;
    FRttiAuthentication: TTHttpRttiAuthentication<C>;
    FAllowMethodOverride: Boolean;

    procedure CheckMethodOverride(const ARequest: TTHttpRequest);

    function ResolveControllerMethod(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AParams: TList<Integer>): TTHttpRttiControllerMethod<C>;

    procedure InternalCheckAuthentication(
      const AContext: C;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const ARttiControllerMethod: TTHttpRttiControllerMethod<C>);

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

    procedure MakeHttpExceptionResponse(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AException: ETHttpException);

    procedure AddAllowHeader(
      const AResponse: TTHttpResponse;
      const AException: ETHttpMethodNotAllowed);

    class function ActionText(
      const AStatusCode: Integer;
      const AException: Exception): String; static;
    procedure MakeOrmResponse(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AStatusCode: Integer;
      const AException: Exception);

    procedure MakeInternalServerErrorResponse(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse;
      const AStatusCode: Integer;
      const AException: Exception);
  public
    constructor Create(
      const ACors: TTHttpCors;
      const ARttiControllers: TTHttpRttiControllers<C>;
      const ALog: TTHttpLog);

    procedure SetRttiAuthentication(
      const ARttiAuthentication: TTHttpRttiAuthentication<C>);

    procedure HandleRequest(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);

    property AllowMethodOverride: Boolean
      read FAllowMethodOverride write FAllowMethodOverride;
  end;

implementation

{ TTHttpListener<C> }

constructor TTHttpListener<C>.Create(
  const ACors: TTHttpCors;
  const ARttiControllers: TTHttpRttiControllers<C>;
  const ALog: TTHttpLog);
begin
  inherited Create;
  FCors := ACors;
  FRttiControllers := ARttiControllers;
  FLog := ALog;
  FRttiAuthentication := nil;
  FAllowMethodOverride := False;
end;

procedure TTHttpListener<C>.CheckMethodOverride(
  const ARequest: TTHttpRequest);
begin
  if (not FAllowMethodOverride) and ARequest.IsMethodOverridden then
    raise ETHttpBadRequest.CreateFmt(
      TTLanguage.Instance.Translate(SMethodOverrideRefused), [
        ARequest.Method, ARequest.SentMethod]);
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
    CheckMethodOverride(ARequest);
    if ARequest.ControllerID.MethodType = TTHttpMethodType.OPTIONS then
      FCors.AddCorsHeaders(ARequest.ControllerID.Uri, AResponse)
    else
      InternalHandleRequest(ARequest, AResponse);
  except
    on E: ETHttpException do
      MakeHttpExceptionResponse(ARequest, AResponse, E);
    on E: ETConcurrentUpdateException do
      MakeOrmResponse(ARequest, AResponse, TTHttpStatusCodeTypes.Conflict, E);
    on E: ETValidationException do
      MakeOrmResponse(
        ARequest, AResponse, TTHttpStatusCodeTypes.UnprocessableContent, E);
    on E: ETJSonServerException do
      MakeInternalServerErrorResponse(
        ARequest, AResponse, TTHttpStatusCodeTypes.InternalServerError, E);
    on E: ETJSonException do
      MakeOrmResponse(
        ARequest, AResponse, TTHttpStatusCodeTypes.BadRequest, E);
    on E: Exception do
      MakeInternalServerErrorResponse(
        ARequest, AResponse, TTHttpStatusCodeTypes.InternalServerError, E);
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
      LRttiControllerMethod := ResolveControllerMethod(
        LContext, ARequest, AResponse, LParams);
      InternalCheckAuthentication(
        LContext, ARequest, AResponse, LRttiControllerMethod);
      CheckAreas(ARequest, LRttiControllerMethod);
      LController := LRttiControllerMethod.Controller.CreateController(
        LContext, ARequest, AResponse);
      if Assigned(LController) then
        try
          AResponse.MarkHeaders;
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

function TTHttpListener<C>.ResolveControllerMethod(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AParams: TList<Integer>): TTHttpRttiControllerMethod<C>;
begin
  try
    result := FRttiControllers.Get(ARequest.ControllerID, AParams);
  except
    on ETHttpException do
    begin
      if Assigned(FRttiAuthentication) then
        CheckAuthentication(AContext, ARequest, AResponse);
      raise;
    end;
  end;
end;

procedure TTHttpListener<C>.InternalCheckAuthentication(
  const AContext: C;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const ARttiControllerMethod: TTHttpRttiControllerMethod<C>);
var
  LNeedAuthentication: Boolean;
begin
  LNeedAuthentication := Assigned(FRttiAuthentication);
  if LNeedAuthentication then
    LNeedAuthentication := (
      ARttiControllerMethod.Method.AuthorizationType <>
      TTHttpAuthorizationType.None);
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
  for LArea in ARttiControllerMethod.Method.Areas do
    if not ARequest.User.Areas.Contains(LArea) then
    begin
      FLog.LogAction(
        ARequest.TaskID.ToString,
        Format(
          TTLanguage.Instance.Translate(SForbiddenAreaLog), [
            ARequest.ControllerID.Uri, LArea]));
      raise ETHttpForbidden.CreateFmt(
        TTLanguage.Instance.Translate(SForbidden), [
          ARequest.ControllerID.Uri]);
    end;
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
  AResponse.ResetToMark;
  AResponse.StatusCode := AStatusCode;
  AResponse.Content := AContent;
end;

procedure TTHttpListener<C>.MakeHttpExceptionResponse(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AException: ETHttpException);
begin
  if AException.StatusCode >= TTHttpStatusCodeTypes.InternalServerError then
    MakeInternalServerErrorResponse(
      ARequest, AResponse, AException.StatusCode, AException)
  else
  begin
    MakeResponse(AResponse, AException.StatusCode, AException.ToJSon());
    if AException is ETHttpMethodNotAllowed then
      AddAllowHeader(AResponse, ETHttpMethodNotAllowed(AException));
  end;
end;

procedure TTHttpListener<C>.AddAllowHeader(
  const AResponse: TTHttpResponse;
  const AException: ETHttpMethodNotAllowed);
begin
  if not AException.AllowedMethods.IsEmpty then
    AResponse.AddHeader('Allow', AException.AllowedMethods);
end;

class function TTHttpListener<C>.ActionText(
  const AStatusCode: Integer;
  const AException: Exception): String;
begin
  result := Format('%d %s', [AStatusCode, AException.Message]);
  if Assigned(AException.InnerException) then
    result := Format(
      '%s (%s)', [result, AException.InnerException.ClassName]);
end;

procedure TTHttpListener<C>.MakeOrmResponse(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AStatusCode: Integer;
  const AException: Exception);
var
  LException: ETHttpException;
begin
  FLog.LogAction(
    ARequest.TaskID.ToString, ActionText(AStatusCode, AException));
  LException := ETHttpException.Create(AStatusCode, AException.Message);
  try
    MakeResponse(AResponse, AStatusCode, LException.ToJSon());
  finally
    LException.Free;
  end;
end;

procedure TTHttpListener<C>.MakeInternalServerErrorResponse(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse;
  const AStatusCode: Integer;
  const AException: Exception);
begin
  FLog.LogError(ARequest, AException);
  MakeResponse(
    AResponse,
    AStatusCode,
    TTHttpErrorResponse.ToJSon(AStatusCode, ARequest.TaskID.ToString()));
end;

end.
