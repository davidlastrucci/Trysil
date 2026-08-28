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
  Trysil.Consts,
  Trysil.Exceptions,

  Trysil.Http.Consts;

type

{ ETHttpServerException }

  ETHttpServerException = class(ETException);

{ ETHttpException }

  ETHttpException = class(ETException)
  strict private
    FStatusCode: Integer;
  public
    constructor CreateFmt(
      const AStatusCode: Integer;
      const AMessage: String;
      const AArgs: array of const);

    constructor Create(
      const AStatusCode: Integer; const AMessage: String);

    function ToJSon(): String;

    property StatusCode: Integer read FStatusCode;
  end;

{ ETHttpBadRequest }

  ETHttpBadRequest = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpUnauthorized }

  ETHttpUnauthorized = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpForbidden }

  ETHttpForbidden = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpNotFound }

  ETHttpNotFound = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpMethodNotAllowed }

  ETHttpMethodNotAllowed = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpConflict }

  ETHttpConflict = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ ETHttpInternalServerError }

  ETHttpInternalServerError = class(ETHttpException)
  public
    constructor CreateFmt(const AMessage: String; const AArgs: array of const);
    constructor Create(const AMessage: String);
  end;

{ TTHttpErrorResponse }

  TTHttpErrorResponse = record
  public
    class function ToJSon(const ATaskID: String): String; overload; static;
    class function ToJSon(
      const AStatusCode: Integer;
      const ATaskID: String): String; overload; static;
  end;

implementation

{ ETHttpException }

constructor ETHttpException.CreateFmt(
  const AStatusCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  Create(AStatusCode, Format(AMessage, AArgs));
end;

constructor ETHttpException.Create(
  const AStatusCode: Integer; const AMessage: String);
begin
  inherited Create(AMessage);
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

constructor ETHttpBadRequest.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.BadRequest, AMessage, AArgs);
end;

constructor ETHttpBadRequest.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.BadRequest, AMessage);
end;

{ ETHttpUnauthorized }

constructor ETHttpUnauthorized.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Unauthorized, AMessage, AArgs);
end;

constructor ETHttpUnauthorized.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Unauthorized, AMessage);
end;

{ ETHttpForbidden }

constructor ETHttpForbidden.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Forbidden, AMessage, AArgs);
end;

constructor ETHttpForbidden.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Forbidden, AMessage);
end;

{ ETHttpNotFound }

constructor ETHttpNotFound.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.NotFound, AMessage, AArgs);
end;

constructor ETHttpNotFound.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.NotFound, AMessage);
end;

{ ETHttpMethodNotAllowed }

constructor ETHttpMethodNotAllowed.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage, AArgs);
end;

constructor ETHttpMethodNotAllowed.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage);
end;

{ ETHttpConflict }

constructor ETHttpConflict.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Conflict, AMessage, AArgs);
end;

constructor ETHttpConflict.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Conflict, AMessage);
end;

{ ETHttpInternalServerError }

constructor ETHttpInternalServerError.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.InternalServerError, AMessage, AArgs);
end;

constructor ETHttpInternalServerError.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.InternalServerError, AMessage);
end;

{ TTHttpErrorResponse }

class function TTHttpErrorResponse.ToJSon(const ATaskID: String): String;
begin
  result := ToJSon(TTHttpStatusCodeTypes.InternalServerError, ATaskID);
end;

class function TTHttpErrorResponse.ToJSon(
  const AStatusCode: Integer;
  const ATaskID: String): String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('status', TJSonNumber.Create(AStatusCode));
    LResult.AddPair(
      'message', TTLanguage.Instance.Translate(SInternalServerError));
    LResult.AddPair('taskId', ATaskID);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

end.

