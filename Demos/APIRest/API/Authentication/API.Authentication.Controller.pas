(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit API.Authentication.Controller;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSon,
  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Attributes,
  Trysil.Http.Exceptions,
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
    procedure CheckCredentials(
      const AUsername: String; const APassword: String);
    procedure ResponseToken;
  public
    [TPost]
    procedure Logon;
  end;

implementation

{ TAPILogonController }

procedure TAPILogonController.CheckCredentials(
  const AUsername: String; const APassword: String);
begin
  // TODO: Check username & password
  if (not AUsername.Equals('Guest')) or (not APassword.Equals('Test')) then
    raise ETHttpForbidden.Create('Invalid logon credentials.');
end;

procedure TAPILogonController.Logon;
var
  LUsername, LPassword: String;
begin
  LUsername := FRequest.JSonContent.GetValue<String>('username', '');
  LPassword := FRequest.JSonContent.GetValue<String>('password', '');

  CheckCredentials(LUsername, LPassword);

  FRequest.User.Username := LUsername;
  FRequest.User.Password := LPassword;

  ResponseToken;
end;

procedure TAPILogonController.ResponseToken;
var
  LPayload: TAPIJWTPayload;
  LJWT: TTHttpJWT<TAPIJWTPayload>;
  LJSon: TJSonObject;
begin
  LPayload := TAPIJWTPayload.Create;
  try
    LPayload.Username := FRequest.User.Username;

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
