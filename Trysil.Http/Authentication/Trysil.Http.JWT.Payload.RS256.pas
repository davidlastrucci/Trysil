(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.JWT.Payload.RS256;

interface

uses
  System.SysUtils,

  Trysil.Http.JWT.Payload,
  Trysil.Http.JWT.RSAKey;

type

{ TTHttpJWTRS256Payload }

  TTHttpJWTRS256Payload = class abstract(TTHttpJWTAbstractPayload)
  strict protected
    function GetSigningKey: TTHttpJWTRSAPrivateKey; virtual;
    function GetVerificationKey(
      const AKeyID: String): TTHttpJWTRSAAbstractKey; virtual; abstract;
    function GetSigningKeyID: String; override;
  public
    function Algorithm: String; override;
    function Sign(const ASigningInput: TBytes): TBytes; override;
    function Verify(
      const ASigningInput: TBytes;
      const ASignature: TBytes;
      const AKeyID: String): Boolean; override;

    property SigningKey: TTHttpJWTRSAPrivateKey read GetSigningKey;
  end;

implementation

{ TTHttpJWTRS256Payload }

function TTHttpJWTRS256Payload.GetSigningKey: TTHttpJWTRSAPrivateKey;
begin
  result := nil;
end;

function TTHttpJWTRS256Payload.GetSigningKeyID: String;
var
  LKey: TTHttpJWTRSAPrivateKey;
begin
  LKey := GetSigningKey;
  if Assigned(LKey) then
    result := LKey.KeyID
  else
    result := String.Empty;
end;

function TTHttpJWTRS256Payload.Algorithm: String;
begin
  result := 'RS256';
end;

function TTHttpJWTRS256Payload.Sign(const ASigningInput: TBytes): TBytes;
var
  LKey: TTHttpJWTRSAPrivateKey;
begin
  LKey := GetSigningKey;
  if not Assigned(LKey) then
    raise ETHttpJWTException.Create('RS256: private key required to sign.');

  result := LKey.Sign(ASigningInput);
end;

function TTHttpJWTRS256Payload.Verify(
  const ASigningInput: TBytes;
  const ASignature: TBytes;
  const AKeyID: String): Boolean;
var
  LKey: TTHttpJWTRSAAbstractKey;
begin
  LKey := GetVerificationKey(AKeyID);
  if Assigned(LKey) then
    result := LKey.Verify(ASigningInput, ASignature)
  else
    result := False;
end;

end.
