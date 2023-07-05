(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit API.Authentication;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes,
  Trysil.Http.JWT,
  Trysil.Http.Authentication,
  Trysil.Http.Authentication.Bearer,

  API.Context,
  API.Authentication.JWT;

type

{ TAPIAuthentication }

  TAPIAuthentication = class(TTHttpAuthenticationBearer<
    TAPIContext, TAPIJWTPayload>)
  strict private
    FRequest: TTHttpRequest;
    FResponse: TTHttpResponse;
  strict protected
    function CreatePayload: TAPIJWTPayload; override;
    function IsValid(const APayload: TAPIJWTPayload): Boolean; override;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

implementation

{ TAPIAuthentication }

procedure TAPIAuthentication.Check(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
begin
  FRequest := ARequest;
  FResponse := AResponse;
  inherited Check(ARequest, AResponse);
end;

function TAPIAuthentication.CreatePayload: TAPIJWTPayload;
begin
  result := TAPIJWTPayload.Create;
end;

function TAPIAuthentication.IsValid(const APayload: TAPIJWTPayload): Boolean;
begin
  result := APayload.IsValid;
  if result then
    FRequest.User.Username := APayload.Username;
end;

end.

