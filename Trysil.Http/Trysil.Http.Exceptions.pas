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
      const AArgs: array of const); overload;

    constructor CreateFmt(
      const AStatusCode: Integer;
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(
      const AStatusCode: Integer; const AMessage: String); overload;

    constructor Create(
      const AStatusCode: Integer;
      const AMessage: String;
      const ANestedException: Exception); overload;

    function ToJSon(): String;

    property StatusCode: Integer read FStatusCode;
  end;

{ ETHttpBadRequest }

  ETHttpBadRequest = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ ETHttpUnauthorized }

  ETHttpUnauthorized = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ ETHttpForbidden }

  ETHttpForbidden = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ ETHttpNotFound }

  ETHttpNotFound = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ ETHttpMethodNotAllowed }

  ETHttpMethodNotAllowed = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ ETHttpInternalServerError }

  ETHttpInternalServerError = class(ETHttpException)
  public
    constructor CreateFmt(
      const AMessage: String; const AArgs: array of const); overload;

    constructor CreateFmt(
      const AMessage: String;
      const AArgs: array of const;
      const ANestedException: Exception); overload;

    constructor Create(const AMessage: String); overload;

    constructor Create(
      const AMessage: String; const ANestedException: Exception); overload;
  end;

{ TExceptionHelper }

  TExceptionHelper = class helper for Exception
  public
    function ToJSon(): String; overload;
    procedure ToJSon(const AJSon: TJSonObject); overload;
  end;

implementation

{ ETHttpException }

constructor ETHttpException.CreateFmt(
  const AStatusCode: Integer;
  const AMessage: String;
  const AArgs: array of const);
begin
  CreateFmt(AStatusCode, AMessage, AArgs, nil);
end;

constructor ETHttpException.CreateFmt(
  const AStatusCode: Integer;
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  Create(AStatusCode, Format(AMessage, AArgs), ANestedException);
end;

constructor ETHttpException.Create(
  const AStatusCode: Integer; const AMessage: String);
begin
  Create(AStatusCode, AMessage, nil);
end;

constructor ETHttpException.Create(
  const AStatusCode: Integer;
  const AMessage: String;
  const ANestedException: Exception);
begin
  inherited Create(AMessage, ANestedException);
  FStatusCode := AStatusCode;
end;

function ETHttpException.ToJSon: String;
var
  LResult, LJSon: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    LResult.AddPair('status', TJSonNumber.Create(FStatusCode));
    LResult.AddPair('message', Self.Message);
    result := LResult.ToJSon();

    if Assigned(NestedException) then
    begin
      LJSon := TJSonObject.Create;
      try
        NestedException.ToJSon(LJSon);
        LResult.AddPair('nestedException', LJSon);
      except
        LJSon.Free;
        raise;
      end;
    end;
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

constructor ETHttpBadRequest.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.BadRequest, AMessage, AArgs, ANestedException);
end;

constructor ETHttpBadRequest.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.BadRequest, AMessage);
end;

constructor ETHttpBadRequest.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.BadRequest, AMessage, ANestedException);
end;

{ ETHttpUnauthorized }

constructor ETHttpUnauthorized.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Unauthorized, AMessage, AArgs);
end;

constructor ETHttpUnauthorized.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.Unauthorized, AMessage, AArgs, ANestedException);
end;

constructor ETHttpUnauthorized.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Unauthorized, AMessage);
end;

constructor ETHttpUnauthorized.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.Unauthorized, AMessage, ANestedException);
end;

{ ETHttpForbidden }

constructor ETHttpForbidden.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.Forbidden, AMessage, AArgs);
end;

constructor ETHttpForbidden.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.Forbidden, AMessage, AArgs, ANestedException);
end;

constructor ETHttpForbidden.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.Forbidden, AMessage);
end;

constructor ETHttpForbidden.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.Forbidden, AMessage, ANestedException);
end;

{ ETHttpNotFound }

constructor ETHttpNotFound.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.NotFound, AMessage, AArgs);
end;

constructor ETHttpNotFound.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.NotFound, AMessage, AArgs, ANestedException);
end;

constructor ETHttpNotFound.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.NotFound, AMessage);
end;

constructor ETHttpNotFound.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.NotFound, AMessage, ANestedException);
end;

{ ETHttpMethodNotAllowed }

constructor ETHttpMethodNotAllowed.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage, AArgs);
end;

constructor ETHttpMethodNotAllowed.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.MethodNotAllowed, AMessage, AArgs, ANestedException);
end;

constructor ETHttpMethodNotAllowed.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.MethodNotAllowed, AMessage);
end;

constructor ETHttpMethodNotAllowed.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.MethodNotAllowed, AMessage, ANestedException);
end;

{ ETHttpInternalServerError }

constructor ETHttpInternalServerError.CreateFmt(
  const AMessage: String; const AArgs: array of const);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.InternalServerError, AMessage, AArgs);
end;

constructor ETHttpInternalServerError.CreateFmt(
  const AMessage: String;
  const AArgs: array of const;
  const ANestedException: Exception);
begin
  inherited CreateFmt(
    TTHttpStatusCodeTypes.InternalServerError,
    AMessage,
    AArgs,
    ANestedException);
end;

constructor ETHttpInternalServerError.Create(const AMessage: String);
begin
  inherited Create(TTHttpStatusCodeTypes.InternalServerError, AMessage);
end;

constructor ETHttpInternalServerError.Create(
  const AMessage: String; const ANestedException: Exception);
begin
  inherited Create(
    TTHttpStatusCodeTypes.InternalServerError, AMessage, ANestedException);
end;

{ TExceptionHelper }

function TExceptionHelper.ToJSon(): String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    ToJSon(LResult);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

procedure TExceptionHelper.ToJSon(const AJSon: TJSonObject);
var
  LJSon: TJSonObject;
begin
  AJSon.AddPair('status', TJSonNumber.Create(500));
  AJSon.AddPair('message', Self.Message);
  if (Self is ETException) and Assigned(ETException(Self).NestedException) then
  begin
    LJSon := TJSonObject.Create;
    try
      ETException(Self).NestedException.ToJSon(LJSon);
      AJSon.AddPair('nestedException', LJSon);
    except
      LJSon.Free;
      raise;
    end;
  end;
end;

end.

