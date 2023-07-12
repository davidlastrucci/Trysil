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
  System.JSon,
  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.JWT,

  API.Context,
  API.Controller,
  API.Authentication.JWT;

type

{ TAPILogonController }

  [TUri('/logon')]
  [TAuthorizationType(TTHttpAuthorizationType.None)]
  TAPILogonController = class(TAPIController)
  strict private
    FUsername: String;
    FPassword: String;
    FAreas: TList<String>;

    procedure CheckCredentials;
    procedure ResponseToken;
  public
    constructor Create(
      const AContext: TAPIContext;
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
    destructor Destroy; override;

    [TPost]
    procedure Logon;
  end;

implementation

{ TAPILogonController }

procedure TAPILogonController.CheckCredentials;
begin
  // TODO: Check username & password
  if (not FUsername.Equals('Guest')) or (not FPassword.Equals('Test')) then
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

procedure TAPILogonController.Logon;
begin
  FUsername := FRequest.JSonContent.GetValue<String>('username', '');
  FPassword := FRequest.JSonContent.GetValue<String>('password', '');

  CheckCredentials;
  ResponseToken;
end;

procedure TAPILogonController.ResponseToken;
var
  LPayload: TAPIJWTPayload;
  LArea: String;
  LJWT: TTHttpJWT<TAPIJWTPayload>;
  LJSon: TJSonObject;
begin
  LPayload := TAPIJWTPayload.Create;
  try
    LPayload.Username := FUsername;
    for LArea in FAreas do
      LPayload.Areas.Add(LArea);

    LJWT := TTHttpJWT<TAPIJWTPayload>.Create(LPayload);
    try
      LJSon := TJSonObject.Create;
      try
        LJSon.AddPair('token', LJWT.ToToken());
        FResponse.Content := LJSon.ToJSon();
      finally
        LJSon.Free;
      end;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

end.
