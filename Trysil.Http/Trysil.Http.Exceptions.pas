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
  public
    constructor Create(const AStatusCode: Integer; const AMessage: String);

    constructor CreateFmt(
      const AStatusCode: Integer;
      const AMessage: String;
      const AArgs: array of const);

    function ToJSon(): String;

    property StatusCode: Integer read FStatusCode;
  end;

{ ETHttpBadRequest }

  ETHttpBadRequest = class(ETHttpException)
  public
    constructor Create(const AMessage: String);
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ ETHttpUnauthorized }

  ETHttpUnauthorized = class(ETHttpException)
  public
    constructor Create(const AMessage: String);
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ ETHttpForbidden }

  ETHttpForbidden = class(ETHttpException)
  public
    constructor Create(const AMessage: String);
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ ETHttpNotFound }

  ETHttpNotFound = class(ETHttpException)
  public
    constructor Create(const AMessage: String);
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ ETHttpMethodNotAllowed }

  ETHttpMethodNotAllowed = class(ETHttpException)
  public
    constructor Create(const AMessage: String);

    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ ETHttpInternalServerError }

  ETHttpInternalServerError = class(ETHttpException)
  public
    constructor Create(const AMessage: String);
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
  end;

{ TExceptionHelper }

  TExceptionHelper = class helper for Exception
  public
    function ToJSon(): String;
  end;

implementation

{ ETHttpException }

constructor ETHttpException.Create(
  const AStatusCode: Integer;
  const AMessage: String);
begin
  inherited Create(AMessage);
  FStatusCode := AStatusCode;
end;

constructor ETHttpException.CreateFmt(
  const AStatusCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  inherited CreateFmt(AMessage, AArgs);
  FStatusCode := AStatusCode;
end;

function ETHttpException.ToJSon: String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('status', TJSonNumber.Create(FStatusCode));
    LResult.AddPair('message', Self.Message);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

{ ETHttpBadRequest }

constructor ETHttpBadRequest.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.BadRequest, AMessage);
end;

constructor ETHttpBadRequest.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.BadRequest, AMessage, AArgs);
end;

{ ETHttpUnauthorized }

constructor ETHttpUnauthorized.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Unauthorized, AMessage);
end;

constructor ETHttpUnauthorized.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Unauthorized, AMessage, AArgs);
end;

{ ETHttpForbidden }

constructor ETHttpForbidden.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Forbidden, AMessage);
end;

constructor ETHttpForbidden.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Forbidden, AMessage, AArgs);
end;

{ ETHttpNotFound }

constructor ETHttpNotFound.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.NotFound, AMessage);
end;

constructor ETHttpNotFound.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.NotFound, AMessage, AArgs);
end;

{ ETHttpMethodNotAllowed }

constructor ETHttpMethodNotAllowed.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage);
end;

constructor ETHttpMethodNotAllowed.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage, AArgs);
end;

{ ETHttpInternalServerError }

constructor ETHttpInternalServerError.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.InternalServerError, AMessage);
end;

constructor ETHttpInternalServerError.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.InternalServerError, AMessage, AArgs);
end;

{ TExceptionHelper }

function TExceptionHelper.ToJSon(): String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('status', TJSonNumber.Create(500));
    LResult.AddPair('message', Self.Message);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

end.

