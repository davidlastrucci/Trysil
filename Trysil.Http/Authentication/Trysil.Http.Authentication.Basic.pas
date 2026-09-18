(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Authentication.Basic;

interface

uses
  System.SysUtils,
  System.Classes,
  System.NetEncoding,

  Trysil.Http.Classes,
  Trysil.Http.Authentication;

type

{ TTHttpAuthenticationBasic<C> }

  TTHttpAuthenticationBasic<C: class> =
    class abstract(TTHttpAbstractAuthentication<C>)
  strict private
    FRealm: String;
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;

    function TryDecodeCredentials(
      const AValue: String; out ACredentials: String): Boolean;

    function IsValid(const AUser: TTHttpUser): Boolean; virtual; abstract;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;

    property Realm: String read FRealm write FRealm;
  end;

implementation

{ TTHttpAuthenticationBasic<C> }

class function TTHttpAuthenticationBasic<C>.GetName: String;
begin
  result := 'Basic';
end;

function TTHttpAuthenticationBasic<C>.GetHeader: String;
begin
  result := Format('%s realm="%s"', [GetName, FRealm]);
end;

function TTHttpAuthenticationBasic<C>.TryDecodeCredentials(
  const AValue: String; out ACredentials: String): Boolean;
begin
  result := True;
  try
    ACredentials := TNetEncoding.Base64.Decode(AValue);
  except
    result := False;
  end;
end;

procedure TTHttpAuthenticationBasic<C>.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
var
  LValue: String;
  LCredentials: String;
  LIndex: Integer;
begin
  LValue := GetValue(ARequest, AResponse);
  if not TryDecodeCredentials(LValue, LCredentials) then
    ResponseForbiddenError(ARequest, AResponse);

  LIndex := LCredentials.IndexOf(':');
  if LIndex < 0 then
    ResponseForbiddenError(ARequest, AResponse);

  ARequest.User.Username := LCredentials.Substring(0, LIndex);
  ARequest.User.Password := LCredentials.Substring(LIndex + 1);
  if not IsValid(ARequest.User) then
    ResponseForbiddenError(ARequest, AResponse);
end;

end.
