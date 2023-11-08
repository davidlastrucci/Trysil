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
  System.Classes,
  System.SysUtils,
  System.DateUtils,
  System.JSon,
  System.NetEncoding,
  System.Hash;

type

{ TTHttpJWTHeader }

  TTHttpJWTHeader = class
  strict protected
    FAlgorithm: String;
    FTokenType: String;
  public
    procedure AfterConstruction; override;

    function ToJSon: String;

    property Algorithm: String read FAlgorithm;
    property TokenType: String read FTokenType;
  end;

{ TTHttpJWTAbstractPayload }

  TTHttpJWTAbstractPayload = class abstract
  strict protected
    function GetSecret: String; virtual; abstract;
  public
    function ToJSon: String; virtual; abstract;
    procedure FromJSon(const AContext: String); virtual; abstract;

    property Secret: String read GetSecret;
  end;

{ TTHttpJWTEncoding }

  TTHttpJWTEncoding = class
  public
    class function Encode(const AValue: String): String;
    class function Decode(const AValue: String): String;
  end;

{ TTHttpJWT<P> }

  TTHttpJWT<P: TTHttpJWTAbstractPayload> = class
  strict private
    FHeader: TTHttpJWTHeader;
    FPayload: P;

    function GetSignature(
      const AHeader: String; const APayload: String): String;
  public
    constructor Create(const APayload: P);
    destructor Destroy; override;

    function ToToken: String;
    function LoadFromToken(const AToken: String): Boolean;

    property Payload: P read FPayload;
  end;

implementation

{ TTHttpJWTHeader }

procedure TTHttpJWTHeader.AfterConstruction;
begin
  inherited AfterConstruction;
  FAlgorithm := 'HS256';
  FTokenType := 'JWT';
end;

function TTHttpJWTHeader.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('alg', FAlgorithm);
    LJSon.AddPair('typ', FTokenType);

    result := LJSon.ToJSon();
  finally
    LJSon.Free;
  end;
end;

{ TTHttpJWTEncoding }

class function TTHttpJWTEncoding.Encode(const AValue: String): String;
begin
  result := AValue.
    Replace(#13#10, '', [rfReplaceAll]).
    Replace(#13, '', [rfReplaceAll]).
    Replace(#10, '', [rfReplaceAll]).
    Replace('+', '-', [rfReplaceAll]).
    Replace('/', '_', [rfReplaceAll]).
    TrimRight(['=']);
end;

class function TTHttpJWTEncoding.Decode(const AValue: String): String;
begin
  result := AValue + StringOfChar('=', (4 - (AValue.Length mod 4)) mod 4);
  result := result.
    Replace('-', '+', [rfReplaceAll]).
    Replace('_', '/', [rfReplaceAll]);
end;

{ TTHttpJWT<P> }

constructor TTHttpJWT<P>.Create(const APayload: P);
begin
  inherited Create;
  FHeader := TTHttpJWTHeader.Create;
  FPayload := APayload;
end;

destructor TTHttpJWT<P>.Destroy;
begin
  FHeader.Free;
  inherited Destroy;
end;

function TTHttpJWT<P>.GetSignature(
  const AHeader: String; const APayload: String): String;
var
  LBytes: TBytes;
begin
  result := Format('%s.%s', [AHeader, APayload]);

  LBytes := THashSHA2.GetHMACAsBytes(
    result, FPayload.Secret, THashSHA2.TSHA2Version.SHA256);

  LBytes := TNetEncoding.Base64.Encode(LBytes);
  result := TTHttpJWTEncoding.Encode(TEncoding.UTF8.GetString(LBytes));
end;

function TTHttpJWT<P>.ToToken: String;
var
  LHeader, LPayload, LSignature: String;
begin
  LHeader := TTHttpJWTEncoding.Encode(
    TNetEncoding.Base64.Encode(FHeader.ToJSon()));
  LPayload := TTHttpJWTEncoding.Encode(
    TNetEncoding.Base64.Encode(FPayload.ToJSon()));
  LSignature := GetSignature(LHeader, LPayload);

  result := Format('%s.%s.%s', [LHeader, LPayload, LSignature]);
end;

function TTHttpJWT<P>.LoadFromToken(const AToken: String): Boolean;
var
  LParts: TArray<String>;
  LSignature, LHeader, LPayload: String;
begin
  result := True;

  LParts := AToken.Split(['.']);
  if Length(LParts) <> 3 then
    Exit(False);

  LSignature := GetSignature(LParts[0], LParts[1]);
  if not LSignature.Equals(LParts[2]) then
    Exit(False);

  LHeader := TNetEncoding.Base64.Decode(TTHttpJWTEncoding.Decode(LParts[0]));
  if not LHeader.Equals(FHeader.ToJSon()) then
    Exit(False);

  LPayload := TNetEncoding.Base64.Decode(TTHttpJWTEncoding.Decode(LParts[1]));
  FPayload.FromJSon(LPayload);
end;

end.
