(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Exceptions;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,

  Trysil.Http.Consts;

type

{ ETHttpServerException }

  ETHttpServerException = class(Exception);

{ ETHttpException }

  ETHttpException = class(Exception)
  strict private
    FStatusCode: Integer;
    FInternalErrorCode: Integer;
  public
    constructor Create(
      const AStatusCode: Integer;
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AStatusCode: Integer;
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);

    function ToJSon(): String;

    property StatusCode: Integer read FStatusCode;
  end;

{ ETHttpBadRequest }

  ETHttpBadRequest = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ ETHttpUnauthorized }

  ETHttpUnauthorized = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ ETHttpForbidden }

  ETHttpForbidden = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ ETHttpNotFound }

  ETHttpNotFound = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ ETHttpMethodNotAllowed }

  ETHttpMethodNotAllowed = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ ETHttpInternalServerError }

  ETHttpInternalServerError = class(ETHttpException)
  public
    constructor Create(
      const AInternalErrorCode: Integer;
      const AMessage: String);

    constructor CreateFmt(
      const AInternalErrorCode: Integer;
      const AMessage: String;
      const AArgs: array of const);
  end;

{ TExceptionHelper }

  TExceptionHelper = class helper for Exception
  public
    function ToJSon(const AInternalErrorCode: Integer): String;
  end;

implementation

{ ETHttpException }

constructor ETHttpException.Create(
  const AStatusCode: Integer;
  const AInternalErrorCode: Integer;
  const AMessage: String);
begin
  inherited Create(AMessage);
  FStatusCode := AStatusCode;
  FInternalErrorCode := AInternalErrorCode;
end;

constructor ETHttpException.CreateFmt(
  const AStatusCode: Integer;
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(AMessage, AArgs);
  FStatusCode := AStatusCode;
  FInternalErrorCode := AInternalErrorCode;
end;

function ETHttpException.ToJSon: String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('errorCode', TJSonNumber.Create(FInternalErrorCode));
    LResult.AddPair('errorMessage', Self.Message);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

{ ETHttpBadRequest }

constructor ETHttpBadRequest.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.BadRequest, AInternalErrorCode, AMessage);
end;

constructor ETHttpBadRequest.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.BadRequest, AInternalErrorCode, AMessage, AArgs);
end;

{ ETHttpUnauthorized }

constructor ETHttpUnauthorized.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.Unauthorized, AInternalErrorCode, AMessage);
end;

constructor ETHttpUnauthorized.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.Unauthorized, AInternalErrorCode, AMessage, AArgs);
end;

{ ETHttpForbidden }

constructor ETHttpForbidden.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.Forbidden, AInternalErrorCode, AMessage);
end;

constructor ETHttpForbidden.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.Forbidden, AInternalErrorCode, AMessage, AArgs);
end;

{ ETHttpNotFound }

constructor ETHttpNotFound.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.NotFound, AInternalErrorCode, AMessage);
end;

constructor ETHttpNotFound.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.NotFound, AInternalErrorCode, AMessage, AArgs);
end;

{ ETHttpMethodNotAllowed }

constructor ETHttpMethodNotAllowed.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.MethodNotAllowed, AInternalErrorCode, AMessage);
end;

constructor ETHttpMethodNotAllowed.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.MethodNotAllowed, AInternalErrorCode, AMessage, AArgs);
end;

{ ETHttpInternalServerError }

constructor ETHttpInternalServerError.Create(
  const AInternalErrorCode: Integer; const AMessage: String);
begin
  inherited Create(
    TTHttpStatusCodeTypes.InternalServerError, AInternalErrorCode, AMessage);
end;

constructor ETHttpInternalServerError.CreateFmt(
  const AInternalErrorCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.InternalServerError, AInternalErrorCode, AMessage, AArgs);
end;

{ TExceptionHelper }

function TExceptionHelper.ToJSon(const AInternalErrorCode: Integer): String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('errorCode', TJSonNumber.Create(AInternalErrorCode));
    LResult.AddPair('errorMessage', Self.Message);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

end.

