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
  System.Generics.Collections,
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

procedure TTHttpAuthenticationBasic<C>.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
var
  LValue: String;
  LIndex: Integer;
begin
  LValue := GetValue(ARequest, AResponse);
  LValue := TNetEncoding.Base64.Decode(LValue);
  LIndex := LValue.IndexOf(':');
  if LIndex < 0 then
    ResponseForbiddenError(ARequest, AResponse);

  ARequest.User.Username := LValue.Substring(0, LIndex);
  ARequest.User.Password := LValue.Substring(LIndex + 1);
  if not IsValid(ARequest.User) then
    ResponseForbiddenError(ARequest, AResponse);
end;

end.
