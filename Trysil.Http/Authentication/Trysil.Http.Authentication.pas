(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.Authentication;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Http.Consts,
  Trysil.Http.Exceptions,
  Trysil.Http.Classes;

type

{ TTHttpAbstractAuthentication<C> }

  TTHttpAbstractAuthentication<C: class> = class abstract
  strict private
    FContext: C;
  strict protected
    class function GetName: String; virtual; abstract;
    function GetHeader: String; virtual; abstract;
    function GetValue(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse): String;

    procedure ResponseUnauthorizedError(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);

    procedure ResponseForbiddenError(
      const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);

    property Context: C read FContext;
  public
    constructor Create(const AContext: C); virtual;

    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); virtual; abstract;
  end;

implementation

{ TTHttpAbstractAuthentication<C> }

constructor TTHttpAbstractAuthentication<C>.Create(
  const AContext: C);
begin
  inherited Create;
  FContext := AContext;
end;

function TTHttpAbstractAuthentication<C>.GetValue(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse): String;
var
  LAuthorization, LAuthenticationType: String;
begin
  LAuthorization := ARequest.Headers.Value['Authorization'];
  if LAuthorization.IsEmpty then
    ResponseUnauthorizedError(ARequest, AResponse);

  LAuthenticationType := Format('%s ', [GetName]);
  if not LAuthorization.StartsWith(LAuthenticationType, True) then
    ResponseUnauthorizedError(ARequest, AResponse);

  result := LAuthorization.Substring(LAuthenticationType.Length).Trim;
end;

procedure TTHttpAbstractAuthentication<C>.ResponseUnauthorizedError(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
var
  LHeader: String;
begin
  LHeader := GetHeader;
  if not LHeader.IsEmpty then
    AResponse.AddHeader('WWW-Authenticate', LHeader);
  raise ETHttpUnauthorized.CreateFmt(
    SUnauthorized, [ARequest.ControllerID.Uri]);
end;

procedure TTHttpAbstractAuthentication<C>.ResponseForbiddenError(
  const ARequest: TTHttpRequest; const AResponse: TTHttpResponse);
begin
  raise ETHttpForbidden.CreateFmt(SForbidden, [ARequest.ControllerID.Uri])
end;

end.
