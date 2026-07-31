(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.JWT.Payload.HS256;

interface

uses
  System.SysUtils,
  System.Hash,

  Trysil.Http.JWT.Payload;

type

{ TTHttpJWTHS256Payload }

  TTHttpJWTHS256Payload = class abstract(TTHttpJWTAbstractPayload)
  strict private
    class function ComputeHMAC(
      const ASecret: String; const AInput: TBytes): TBytes;
  strict protected
    function GetSecret: String; virtual; abstract;
    function GetSecretFor(const AKeyID: String): String; virtual;

    class function SameSignature(
      const ALeft: TBytes; const ARight: TBytes): Boolean;
  public
    function Algorithm: String; override;
    function Sign(const ASigningInput: TBytes): TBytes; override;
    function Verify(
      const ASigningInput: TBytes;
      const ASignature: TBytes;
      const AKeyID: String): Boolean; override;

    property Secret: String read GetSecret;
  end;

implementation

{ TTHttpJWTHS256Payload }

function TTHttpJWTHS256Payload.Algorithm: String;
begin
  result := 'HS256';
end;

function TTHttpJWTHS256Payload.GetSecretFor(const AKeyID: String): String;
begin
  result := GetSecret;
end;

class function TTHttpJWTHS256Payload.ComputeHMAC(
  const ASecret: String; const AInput: TBytes): TBytes;
begin
  result := THashSHA2.GetHMACAsBytes(
    TEncoding.UTF8.GetString(AInput),
    ASecret,
    THashSHA2.TSHA2Version.SHA256);
end;

function TTHttpJWTHS256Payload.Sign(const ASigningInput: TBytes): TBytes;
begin
  result := ComputeHMAC(GetSecret, ASigningInput);
end;

function TTHttpJWTHS256Payload.Verify(
  const ASigningInput: TBytes;
  const ASignature: TBytes;
  const AKeyID: String): Boolean;
begin
  result := SameSignature(
    ComputeHMAC(GetSecretFor(AKeyID), ASigningInput), ASignature);
end;

class function TTHttpJWTHS256Payload.SameSignature(
  const ALeft: TBytes; const ARight: TBytes): Boolean;
var
  LIndex: Integer;
  LDiff: Integer;
begin
  LDiff := Length(ALeft) xor Length(ARight);
  for LIndex := 0 to Length(ALeft) - 1 do
    if LIndex < Length(ARight) then
      LDiff := LDiff or (ALeft[LIndex] xor ARight[LIndex]);
  result := (LDiff = 0) and (Length(ALeft) = Length(ARight));
end;

end.
