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

  Trysil.Http.JWT.Payload;

type

{ TTHttpJWTRS256Payload }

  TTHttpJWTRS256Payload = class abstract(TTHttpJWTAbstractPayload)
  strict protected
    function GetPrivateKey: String; virtual;
    function GetPublicKey: String; virtual; abstract;
  public
    function Algorithm: String; override;
    function Sign(const ASigningInput: TBytes): TBytes; override;
    function Verify(
      const ASigningInput: TBytes; const ASignature: TBytes): Boolean; override;

    property PrivateKey: String read GetPrivateKey;
    property PublicKey: String read GetPublicKey;
  end;

implementation

const
{$IFDEF MSWINDOWS}
  {$IFDEF WIN64}
  SLibCrypto = 'libcrypto-4-x64.dll';
  {$ELSE}
  SLibCrypto = 'libcrypto-4.dll';
  {$ENDIF}
{$ENDIF}
{$IFDEF LINUX}
  SLibCrypto = 'libcrypto.so.4';
{$ENDIF}

{ OpenSSL libcrypto }

function BIO_new_mem_buf(
  ABuf: Pointer; ALen: Integer): Pointer; cdecl; external SLibCrypto;
function BIO_free(
  ABio: Pointer): Integer; cdecl; external SLibCrypto;

function PEM_read_bio_PrivateKey(
  ABio, AKey, ACallback, AUserData: Pointer): Pointer; cdecl;
  external SLibCrypto;
function PEM_read_bio_PUBKEY(
  ABio, AKey, ACallback, AUserData: Pointer): Pointer; cdecl;
  external SLibCrypto;
procedure EVP_PKEY_free(
  AKey: Pointer); cdecl; external SLibCrypto;

function EVP_MD_CTX_new: Pointer; cdecl; external SLibCrypto;
procedure EVP_MD_CTX_free(ACtx: Pointer); cdecl; external SLibCrypto;
function EVP_sha256: Pointer; cdecl; external SLibCrypto;

function EVP_DigestSignInit(
  ACtx, APKeyCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  external SLibCrypto;
function EVP_DigestVerifyInit(
  ACtx, APKeyCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  external SLibCrypto;
function EVP_DigestUpdate(
  ACtx, AData: Pointer; ACount: NativeUInt): Integer; cdecl;
  external SLibCrypto;
function EVP_DigestSignFinal(
  ACtx, ASignature: Pointer; var ASignatureLen: NativeUInt): Integer; cdecl;
  external SLibCrypto;
function EVP_DigestVerifyFinal(
  ACtx, ASignature: Pointer; ASignatureLen: NativeUInt): Integer; cdecl;
  external SLibCrypto;

{ Helpers }

function LoadKey(const APem: String; const APrivate: Boolean): Pointer;
var
  LBytes: TBytes;
  LBio: Pointer;
begin
  LBytes := TEncoding.UTF8.GetBytes(APem);
  if Length(LBytes) = 0 then
    raise ETHttpJWTException.Create('RS256: empty key.');

  LBio := BIO_new_mem_buf(@LBytes[0], Length(LBytes));
  if LBio = nil then
    raise ETHttpJWTException.Create('OpenSSL: BIO_new_mem_buf failed.');
  try
    if APrivate then
      result := PEM_read_bio_PrivateKey(LBio, nil, nil, nil)
    else
      result := PEM_read_bio_PUBKEY(LBio, nil, nil, nil);
  finally
    BIO_free(LBio);
  end;

  if result = nil then
    raise ETHttpJWTException.Create('OpenSSL: cannot load RSA key from PEM.');
end;

function InternalSign(const AKey: Pointer; const AInput: TBytes): TBytes;
var
  LCtx: Pointer;
  LLen: NativeUInt;
begin
  LCtx := EVP_MD_CTX_new;
  if LCtx = nil then
    raise ETHttpJWTException.Create('OpenSSL: EVP_MD_CTX_new failed.');
  try
    if EVP_DigestSignInit(LCtx, nil, EVP_sha256, nil, AKey) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestSignInit failed.');
    if EVP_DigestUpdate(LCtx, @AInput[0], Length(AInput)) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestUpdate failed.');

    LLen := 0;
    if EVP_DigestSignFinal(LCtx, nil, LLen) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestSignFinal (len) failed.');

    SetLength(result, LLen);
    if EVP_DigestSignFinal(LCtx, @result[0], LLen) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestSignFinal failed.');
    SetLength(result, LLen);
  finally
    EVP_MD_CTX_free(LCtx);
  end;
end;

function InternalVerify(
  const AKey: Pointer; const AInput, ASignature: TBytes): Boolean;
var
  LCtx: Pointer;
begin
  if Length(ASignature) = 0 then
    result := False
  else
  begin
    LCtx := EVP_MD_CTX_new;
    if LCtx = nil then
      raise ETHttpJWTException.Create('OpenSSL: EVP_MD_CTX_new failed.');
    try
      if EVP_DigestVerifyInit(LCtx, nil, EVP_sha256, nil, AKey) <> 1 then
        raise ETHttpJWTException.Create('OpenSSL: EVP_DigestVerifyInit failed.');
      if EVP_DigestUpdate(LCtx, @AInput[0], Length(AInput)) <> 1 then
        raise ETHttpJWTException.Create('OpenSSL: EVP_DigestUpdate failed.');

      // 1 = Valid; 0 = Not valid; <0 = Error
      result := EVP_DigestVerifyFinal(
        LCtx, @ASignature[0], Length(ASignature)) = 1;
    finally
      EVP_MD_CTX_free(LCtx);
    end;
  end;
end;

{ TTHttpJWTRS256Payload }

function TTHttpJWTRS256Payload.GetPrivateKey: String;
begin
  result := String.Empty;
end;

function TTHttpJWTRS256Payload.Algorithm: String;
begin
  result := 'RS256';
end;

function TTHttpJWTRS256Payload.Sign(const ASigningInput: TBytes): TBytes;
var
  LKey: Pointer;
begin
  if GetPrivateKey.IsEmpty then
    raise ETHttpJWTException.Create('RS256: private key required to sign.');

  LKey := LoadKey(GetPrivateKey, True);
  try
    result := InternalSign(LKey, ASigningInput);
  finally
    EVP_PKEY_free(LKey);
  end;
end;

function TTHttpJWTRS256Payload.Verify(
  const ASigningInput: TBytes; const ASignature: TBytes): Boolean;
var
  LKey: Pointer;
begin
  LKey := LoadKey(GetPublicKey, False);
  try
    result := InternalVerify(LKey, ASigningInput, ASignature);
  finally
    EVP_PKEY_free(LKey);
  end;
end;

end.
