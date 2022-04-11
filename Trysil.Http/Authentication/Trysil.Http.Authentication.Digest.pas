(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Authentication.Digest;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Hash,

  Trysil.Http.Classes,
  Trysil.Http.Authentication;

type

{ TTHttpAuthenticationDigestContext }

  TTHttpAuthenticationDigestContext = record
  strict private
    FUsername: String;
    FRealm: String;
    FNonce: String;
    FUri: String;
    FResponse: String;

    function GetValue(
      const ADictionary: TDictionary<String, String>;
      const AID: String): String;
  public
    constructor Create(const AAuthContext: String);

    property Username: String read FUsername;
    property Realm: String read FRealm;
    property Nonce: String read FNonce;
    property Uri: String read FUri;
    property Response: String read FResponse;
  end;

{ TTHttpAuthenticationDigest<C> }

  TTHttpAuthenticationDigest<C: class> =
    class abstract(TTHttpAbstractAuthentication<C>)
  strict private
    FRealm: String;

    function GetContext(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse): TTHttpAuthenticationDigestContext;
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;

    function GetNonce: String; virtual; abstract;
    function IsValidNonce(const ANonce: String): Boolean; virtual; abstract;

    function GetUserMD5(
      const AUser: TTHttpUser;
      const ARealm: String): Boolean; virtual; abstract;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;

    property Realm: String read FRealm write FRealm;
  end;

implementation

{ TTHttpAuthenticationDigestContext }

constructor TTHttpAuthenticationDigestContext.Create(const AAuthContext: String);
var
  LAuthContext: TDictionary<String, String>;
  LValues: TArray<String>;
  LValue, LKey, LAuthValue: String;
  LIndex: Integer;
begin
  LAuthContext := TDictionary<String, String>.Create;
  try
    LValues := AAuthContext.Split([',']);
    for LValue in LValues do
    begin
      LIndex := LValue.IndexOf('=');
      if LIndex >= 0 then
      begin
        LKey := LValue.Substring(0, LIndex).ToLower();
        LAuthValue := LValue.Substring(LIndex + 1);
        LAuthValue := LAuthValue.Substring(1, LAuthValue.Length - 2);
        LAuthContext.Add(LKey.TrimLeft(), LAuthValue);
      end;
    end;

    FUsername := GetValue(LAuthContext, 'username');
    FRealm := GetValue(LAuthContext, 'realm');
    FNonce := GetValue(LAuthContext, 'nonce');
    FUri := GetValue(LAuthContext, 'uri');
    FResponse := GetValue(LAuthContext, 'response');
  finally
    LAuthContext.Free;
  end;
end;

function TTHttpAuthenticationDigestContext.GetValue(
  const ADictionary: TDictionary<String, String>; const AID: String): String;
begin
  if not ADictionary.TryGetValue(AID, result) then
    result := String.Empty;
end;

{ TTHttpAuthenticationDigest<C> }

class function TTHttpAuthenticationDigest<C>.GetName: String;
begin
  result := 'Digest';
end;

function TTHttpAuthenticationDigest<C>.GetHeader: String;
begin
  result := Format('%s realm="%s", nonce="%s"', [GetName, FRealm, GetNonce]);
end;

function TTHttpAuthenticationDigest<C>.GetContext(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse): TTHttpAuthenticationDigestContext;
var
  LValue: String;
begin
  LValue := GetValue(ARequest, AResponse);
  result := TTHttpAuthenticationDigestContext.Create(LValue);
  if result.Username.IsEmpty or result.Realm.IsEmpty or
    result.Response.IsEmpty then
    ResponseForbiddenError(ARequest, AResponse);

  if not IsValidNonce(result.Nonce) then
    ResponseForbiddenError(ARequest, AResponse);

  if not result.Realm.Equals(FRealm) then
    ResponseForbiddenError(ARequest, AResponse);

  if not result.Uri.StartsWith(ARequest.ControllerID.Uri) then
    ResponseForbiddenError(ARequest, AResponse);
end;

procedure TTHttpAuthenticationDigest<C>.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
var
  LContext: TTHttpAuthenticationDigestContext;
  LHA, LCorrect: String;
begin
  LContext := GetContext(ARequest, AResponse);
  ARequest.User.Username := LContext.Username;
  if not GetUserMD5(ARequest.User, FRealm) then
    ResponseForbiddenError(ARequest, AResponse);

  LHA := THashMD5.GetHashString(Format('%s:%s', [
    ARequest.ControllerID.Method, LContext.Uri]));
  LCorrect := THashMD5.GetHashString(Format('%s:%s:%s', [
    ARequest.User.Password, LContext.Nonce, LHA]));

  if not LCorrect.Equals(LContext.Response) then
    ResponseForbiddenError(ARequest, AResponse);
end;

end.

