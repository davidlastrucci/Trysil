(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Authentication.Bearer;

interface

uses
  System.Classes,
  System.SysUtils,

  Trysil.Http.Classes,
  Trysil.Http.Authentication,
  Trysil.Http.JWT;

type

{ TTHttpAuthenticationBearer<C, P> }

  TTHttpAuthenticationBearer<C: class; P: TTHttpJWTAbstractPayload> =
    class abstract(TTHttpAbstractAuthentication<C>)
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;

    function CreatePayload: P; virtual; abstract;
    function IsValid(const APayload: P): Boolean; virtual; abstract;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

implementation

{ TTHttpAuthenticationBearer<C, P> }

class function TTHttpAuthenticationBearer<C, P>.GetName: String;
begin
  result := 'Bearer';
end;

function TTHttpAuthenticationBearer<C, P>.GetHeader: String;
begin
  result := GetName;
end;

procedure TTHttpAuthenticationBearer<C, P>.Check(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
var
  LToken: String;
  LPayload: P;
  LJWT: TTHttpJWT<P>;
begin
  LToken := GetValue(ARequest, AResponse);

  LPayload := CreatePayload;
  try
    LJWT := TTHttpJWT<P>.Create(LPayload);
    try
      if not LJWT.LoadFromToken(LToken) then
        ResponseForbiddenError(ARequest, AResponse);
      if not IsValid(LJWT.Payload) then
        ResponseForbiddenError(ARequest, AResponse);
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

end.
