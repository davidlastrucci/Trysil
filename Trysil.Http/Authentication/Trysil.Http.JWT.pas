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

{$BOOLEVAL OFF}

type

{ TTHttpJWTEncoding }

  TTHttpJWTEncoding = class
  strict private
    class function IsBase64Url(const AValue: String): Boolean;
    class function IsCanonical(const AValue: String): Boolean;
  public
    class function Encode(const ABytes: TBytes): String;
    class function Decode(const AValue: String): TBytes;
    class function IsValid(const AValue: String): Boolean;
  end;

{ TTHttpJWT<P> }

  TTHttpJWT<P: TTHttpJWTAbstractPayload> = class
  strict private
    FPayload: P;

    function BuildHeader: String;
    function GetStringValue(
      const AJSon: TJSonValue; const AName: String): String;
    function LoadHeader(
      const AHeaderSegment: String; out AKeyID: String): Boolean;
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

class function TTHttpJWTEncoding.IsBase64Url(const AValue: String): Boolean;
var
  LIndex: Integer;
begin
  result := True;
  LIndex := 1;
  while result and (LIndex <= AValue.Length) do
  begin
    result := CharInSet(
      AValue.Chars[LIndex - 1], ['A'..'Z', 'a'..'z', '0'..'9', '-', '_']);
    Inc(LIndex);
  end;
end;

class function TTHttpJWTEncoding.IsCanonical(const AValue: String): Boolean;
begin
  try
    result := Encode(Decode(AValue)) = AValue;
  except
    result := False;
  end;
end;

class function TTHttpJWTEncoding.IsValid(const AValue: String): Boolean;
begin
  result := (not AValue.IsEmpty) and IsBase64Url(AValue) and
    IsCanonical(AValue);
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

function TTHttpJWT<P>.GetStringValue(
  const AJSon: TJSonValue; const AName: String): String;
begin
  try
    result := AJSon.GetValue<String>(AName, String.Empty);
  except
    result := String.Empty;
  end;
end;

function TTHttpJWT<P>.LoadHeader(
  const AHeaderSegment: String; out AKeyID: String): Boolean;
var
  LJSon: TJSonValue;
  LAlgorithm: String;
begin
  result := False;
  AKeyID := String.Empty;
  LJSon := TJSonObject.ParseJSonValue(
    TEncoding.UTF8.GetString(TTHttpJWTEncoding.Decode(AHeaderSegment)));
  if Assigned(LJSon) then
    try
      if LJSon is TJSonObject then
      begin
        LAlgorithm := GetStringValue(LJSon, 'alg');
        AKeyID := GetStringValue(LJSon, 'kid');
        result := (not FPayload.Algorithm.IsEmpty) and
          SameText(LAlgorithm, FPayload.Algorithm);
      end;
    finally
      LJSon.Free;
    end;
end;

function TTHttpJWT<P>.LoadFromToken(const AToken: String): Boolean;
var
  LParts: TArray<String>;
  LKeyID: String;
  LSigningInput, LSignature: TBytes;
begin
  result := False;
  LParts := AToken.Split(['.']);
  if (Length(LParts) = 3) and
    TTHttpJWTEncoding.IsValid(LParts[0]) and
    TTHttpJWTEncoding.IsValid(LParts[1]) and
    TTHttpJWTEncoding.IsValid(LParts[2]) then
    if LoadHeader(LParts[0], LKeyID) then
    begin
      LSigningInput := TEncoding.UTF8.GetBytes(
        Format('%s.%s', [LParts[0], LParts[1]]));
      LSignature := TTHttpJWTEncoding.Decode(LParts[2]);
      if FPayload.Verify(LSigningInput, LSignature, LKeyID) then
      begin
        FPayload.FromJSon(
          TEncoding.UTF8.GetString(TTHttpJWTEncoding.Decode(LParts[1])));
        result := True;
      end;
    end;
end;

end.
