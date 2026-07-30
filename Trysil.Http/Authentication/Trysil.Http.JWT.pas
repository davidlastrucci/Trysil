(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.JWT;

interface

uses
  System.SysUtils,
  System.JSon,
  System.NetEncoding,

  Trysil.Http.JWT.Payload;

type

{ TTHttpJWTEncoding }

  TTHttpJWTEncoding = class
  public
    class function Encode(const ABytes: TBytes): String;
    class function Decode(const AValue: String): TBytes;
  end;

{ TTHttpJWT<P> }

  TTHttpJWT<P: TTHttpJWTAbstractPayload> = class
  strict private
    FPayload: P;

    function BuildHeader: String;
    function LoadHeader(const AHeaderSegment: String): Boolean;
  public
    constructor Create(const APayload: P);

    function ToToken: String;
    function LoadFromToken(const AToken: String): Boolean;

    property Payload: P read FPayload;
  end;

implementation

{ TTHttpJWTEncoding }

class function TTHttpJWTEncoding.Encode(const ABytes: TBytes): String;
begin
  // base64url senza padding
  result := TNetEncoding.Base64.EncodeBytesToString(ABytes).
    Replace(#13#10, '', [rfReplaceAll]).
    Replace(#13, '', [rfReplaceAll]).
    Replace(#10, '', [rfReplaceAll]).
    Replace('+', '-', [rfReplaceAll]).
    Replace('/', '_', [rfReplaceAll]).
    TrimRight(['=']);
end;

class function TTHttpJWTEncoding.Decode(const AValue: String): TBytes;
var
  LValue: String;
begin
  LValue := AValue.
    Replace('-', '+', [rfReplaceAll]).
    Replace('_', '/', [rfReplaceAll]);
  LValue := LValue + StringOfChar('=', (4 - (LValue.Length mod 4)) mod 4);
  result := TNetEncoding.Base64.DecodeStringToBytes(LValue);
end;

{ TTHttpJWT<P> }

constructor TTHttpJWT<P>.Create(const APayload: P);
begin
  inherited Create;
  FPayload := APayload;
end;

function TTHttpJWT<P>.BuildHeader: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('alg', FPayload.Algorithm);
    if not FPayload.SigningKeyID.IsEmpty then
      LJSon.AddPair('kid', FPayload.SigningKeyID);
    LJSon.AddPair('typ', 'JWT');
    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

function TTHttpJWT<P>.ToToken: String;
var
  LHeaderSeg, LPayloadSeg, LSignatureSeg: String;
  LSigningInput: TBytes;
begin
  LHeaderSeg := TTHttpJWTEncoding.Encode(
    TEncoding.UTF8.GetBytes(BuildHeader));
  LPayloadSeg := TTHttpJWTEncoding.Encode(
    TEncoding.UTF8.GetBytes(FPayload.ToJSon()));
  LSigningInput := TEncoding.UTF8.GetBytes(
    Format('%s.%s', [LHeaderSeg, LPayloadSeg]));
  LSignatureSeg := TTHttpJWTEncoding.Encode(FPayload.Sign(LSigningInput));
  result := Format('%s.%s.%s', [LHeaderSeg, LPayloadSeg, LSignatureSeg]);
end;

function TTHttpJWT<P>.LoadHeader(const AHeaderSegment: String): Boolean;
var
  LJSon: TJSonObject;
  LAlgorithm: String;
begin
  result := False;
  FPayload.TokenKeyID := String.Empty;
  LJSon := TJSonObject.ParseJSonValue(
    TEncoding.UTF8.GetString(
      TTHttpJWTEncoding.Decode(AHeaderSegment))) as TJSonObject;
  if Assigned(LJSon) then
    try
      LAlgorithm := LJSon.GetValue<String>('alg', String.Empty);
      FPayload.TokenKeyID := LJSon.GetValue<String>('kid', String.Empty);
      result := (not FPayload.Algorithm.IsEmpty) and
        SameText(LAlgorithm, FPayload.Algorithm);
    finally
      LJSon.Free;
    end;
end;

function TTHttpJWT<P>.LoadFromToken(const AToken: String): Boolean;
var
  LParts: TArray<String>;
  LSigningInput, LSignature: TBytes;
begin
  result := False;
  LParts := AToken.Split(['.']);
  if Length(LParts) = 3 then
    if LoadHeader(LParts[0]) then
    begin
      LSigningInput := TEncoding.UTF8.GetBytes(
        Format('%s.%s', [LParts[0], LParts[1]]));
      LSignature := TTHttpJWTEncoding.Decode(LParts[2]);
      if FPayload.Verify(LSigningInput, LSignature) then
      begin
        FPayload.FromJSon(
          TEncoding.UTF8.GetString(TTHttpJWTEncoding.Decode(LParts[1])));
        result := True;
      end;
    end;
end;

end.
