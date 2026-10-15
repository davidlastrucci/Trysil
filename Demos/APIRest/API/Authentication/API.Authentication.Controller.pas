(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Authentication.Controller;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.JWT,
  Trysil.JSon.Types,
  Trysil.OpenAPI.Types,
  Trysil.OpenAPI.Attributes,

  API.Context,
  API.Controller,
  API.Authentication.JWT;

type

{ TAPILogonRequest }

  TAPILogonRequest = class
  strict private
    [TColumn('Username')]
    [TRequired]
    FUsername: String;

    [TColumn('Password')]
    [TRequired]
    FPassword: String;
  public
    property Username: String read FUsername;
    property Password: String read FPassword;
  end;

{ TAPILogonResponse }

  TAPILogonResponse = class
  strict private
    [TColumn('Token')]
    FToken: String;
  public
    constructor Create(const AToken: String);

    property Token: String read FToken;
  end;

{ TAPILogonController }

  [TUri('/logon')]
  [TAuthorizationType(TTHttpAuthorizationType.None)]
  TAPILogonController = class(TAPIController)
  strict private
    FAreas: TList<String>;

    procedure CheckCredentials(const ARequest: TAPILogonRequest);
    function CreateToken(const AUsername: String): String;
    procedure ResponseToken(const AToken: String);
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TPost]
    [TSummary('Logon')]
    [TRequestBody(TAPILogonRequest, TTOpenApiShape.Single, 'Credentials')]
    [TResponse(
      200, TAPILogonResponse, TTOpenApiShape.Single, 'The access token')]
    [TResponse(403, 'Invalid credentials')]
    procedure Logon;
  end;

implementation

{ TAPILogonResponse }

constructor TAPILogonResponse.Create(const AToken: String);
begin
  inherited Create;
  FToken := AToken;
end;

{ TAPILogonController }

procedure TAPILogonController.CheckCredentials(
  const ARequest: TAPILogonRequest);
begin
  // TODO: Check username & password
  if (not ARequest.Username.Equals('Guest')) or
    (not ARequest.Password.Equals('Test')) then
    raise ETHttpForbidden.Create('Invalid logon credentials.');

  // TODO: Areas
  FAreas.Add('read');
  FAreas.Add('write');
end;

constructor TAPILogonController.Create(
  const AContext: TAPIContext;
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  inherited Create(AContext, ARequest, AResponse);
  FAreas := TList<String>.Create;
end;

destructor TAPILogonController.Destroy;
begin
  FAreas.Free;
  inherited Destroy;
end;

function TAPILogonController.CreateToken(const AUsername: String): String;
var
  LPayload: TAPIJWTPayload;
  LArea: String;
  LJWT: TTHttpJWT<TAPIJWTPayload>;
begin
  LPayload := TAPIJWTPayload.Create;
  try
    LPayload.Username := AUsername;
    for LArea in FAreas do
      LPayload.Areas.Add(LArea);

    LJWT := TTHttpJWT<TAPIJWTPayload>.Create(LPayload);
    try
      result := LJWT.ToToken();
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TAPILogonController.Logon;
var
  LRequest: TAPILogonRequest;
begin
  LRequest := TAPILogonRequest.Create;
  try
    FContext.Context.EntityFromJSonObject<TAPILogonRequest>(
      FRequest.JSonContent, LRequest);
    FContext.Context.Validate<TAPILogonRequest>(LRequest);
    CheckCredentials(LRequest);
    ResponseToken(CreateToken(LRequest.Username));
  finally
    LRequest.Free;
  end;
end;

procedure TAPILogonController.ResponseToken(const AToken: String);
var
  LResponse: TAPILogonResponse;
begin
  LResponse := TAPILogonResponse.Create(AToken);
  try
    FResponse.Content := FContext.Context.EntityToJSon<TAPILogonResponse>(
      LResponse, TTJSonSerializerConfig.Default);
  finally
    LResponse.Free;
  end;
end;

end.
