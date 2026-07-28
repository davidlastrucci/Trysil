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
  System.SyncObjs,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
{$IFDEF POSIX}
  Posix.Dlfcn,
{$ENDIF}

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

{ OpenSSL libcrypto, resolved at first use }

type
  TLibHandle = NativeUInt;

  TBIO_new_mem_buf = function(
    ABuf: Pointer; ALen: Integer): Pointer; cdecl;
  TBIO_free = function(
    ABio: Pointer): Integer; cdecl;

  TPEM_read_bio_PrivateKey = function(
    ABio, AKey, ACallback, AUserData: Pointer): Pointer; cdecl;
  TPEM_read_bio_PUBKEY = function(
    ABio, AKey, ACallback, AUserData: Pointer): Pointer; cdecl;
  TEVP_PKEY_free = procedure(
    AKey: Pointer); cdecl;

  TEVP_MD_CTX_new = function: Pointer; cdecl;
  TEVP_MD_CTX_free = procedure(ACtx: Pointer); cdecl;
  TEVP_sha256 = function: Pointer; cdecl;

  TEVP_DigestSignInit = function(
    ACtx, APKeyCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  TEVP_DigestVerifyInit = function(
    ACtx, APKeyCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  TEVP_DigestUpdate = function(
    ACtx, AData: Pointer; ACount: NativeUInt): Integer; cdecl;
  TEVP_DigestSignFinal = function(
    ACtx, ASignature: Pointer; var ASignatureLen: NativeUInt): Integer; cdecl;
  TEVP_DigestVerifyFinal = function(
    ACtx, ASignature: Pointer; ASignatureLen: NativeUInt): Integer; cdecl;

var
  GLock: TCriticalSection = nil;
  GLibCrypto: TLibHandle = 0;
  GResolved: Boolean = False;

  BIO_new_mem_buf: TBIO_new_mem_buf = nil;
  BIO_free: TBIO_free = nil;
  PEM_read_bio_PrivateKey: TPEM_read_bio_PrivateKey = nil;
  PEM_read_bio_PUBKEY: TPEM_read_bio_PUBKEY = nil;
  EVP_PKEY_free: TEVP_PKEY_free = nil;
  EVP_MD_CTX_new: TEVP_MD_CTX_new = nil;
  EVP_MD_CTX_free: TEVP_MD_CTX_free = nil;
  EVP_sha256: TEVP_sha256 = nil;
  EVP_DigestSignInit: TEVP_DigestSignInit = nil;
  EVP_DigestVerifyInit: TEVP_DigestVerifyInit = nil;
  EVP_DigestUpdate: TEVP_DigestUpdate = nil;
  EVP_DigestSignFinal: TEVP_DigestSignFinal = nil;
  EVP_DigestVerifyFinal: TEVP_DigestVerifyFinal = nil;

{ Dynamic loading }

function LibCryptoNames: TArray<String>;
begin
{$IF Defined(MSWINDOWS) and Defined(WIN64)}
  result := [
    'libcrypto-4-x64.dll', 'libcrypto-3-x64.dll', 'libcrypto-1_1-x64.dll'];
{$ELSEIF Defined(MSWINDOWS)}
  result := ['libcrypto-4.dll', 'libcrypto-3.dll', 'libcrypto-1_1.dll'];
{$ELSEIF Defined(LINUX)}
  result := ['libcrypto.so.3', 'libcrypto.so.4', 'libcrypto.so.1.1'];
{$ELSEIF Defined(MACOS) and not Defined(IOS)}
  result := [
    'libcrypto.3.dylib', 'libcrypto.4.dylib', 'libcrypto.1.1.dylib',
    '/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib',
    '/usr/local/opt/openssl@3/lib/libcrypto.3.dylib'];
{$ELSEIF Defined(ANDROID)}
  result := ['libcrypto.so'];
{$ELSE}
  result := [];
{$ENDIF}
end;

function OpenLibCrypto(const AName: String): TLibHandle;
{$IFDEF POSIX}
var
  LName: UTF8String;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  result := LoadLibrary(PChar(AName));
{$ENDIF}
{$IFDEF POSIX}
  LName := UTF8String(AName);
  result := dlopen(MarshaledAString(LName), RTLD_LAZY);
{$ENDIF}
end;

procedure CloseLibCrypto;
begin
  if GLibCrypto <> 0 then
  begin
{$IFDEF MSWINDOWS}
    FreeLibrary(HMODULE(GLibCrypto));
{$ENDIF}
{$IFDEF POSIX}
    dlclose(GLibCrypto);
{$ENDIF}
    GLibCrypto := 0;
  end;
end;

function GetSymbol(const AName: String): Pointer;
{$IFDEF POSIX}
var
  LName: UTF8String;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  result := GetProcAddress(HMODULE(GLibCrypto), PChar(AName));
{$ENDIF}
{$IFDEF POSIX}
  LName := UTF8String(AName);
  result := dlsym(GLibCrypto, MarshaledAString(LName));
{$ENDIF}
  if result = nil then
    raise ETHttpJWTException.CreateFmt(
      'OpenSSL: symbol "%s" not found in libcrypto.', [AName]);
end;

procedure ResolveSymbols;
begin
  BIO_new_mem_buf := TBIO_new_mem_buf(GetSymbol('BIO_new_mem_buf'));
  BIO_free := TBIO_free(GetSymbol('BIO_free'));
  PEM_read_bio_PrivateKey := TPEM_read_bio_PrivateKey(
    GetSymbol('PEM_read_bio_PrivateKey'));
  PEM_read_bio_PUBKEY := TPEM_read_bio_PUBKEY(
    GetSymbol('PEM_read_bio_PUBKEY'));
  EVP_PKEY_free := TEVP_PKEY_free(GetSymbol('EVP_PKEY_free'));
  EVP_MD_CTX_new := TEVP_MD_CTX_new(GetSymbol('EVP_MD_CTX_new'));
  EVP_MD_CTX_free := TEVP_MD_CTX_free(GetSymbol('EVP_MD_CTX_free'));
  EVP_sha256 := TEVP_sha256(GetSymbol('EVP_sha256'));
  EVP_DigestSignInit := TEVP_DigestSignInit(
    GetSymbol('EVP_DigestSignInit'));
  EVP_DigestVerifyInit := TEVP_DigestVerifyInit(
    GetSymbol('EVP_DigestVerifyInit'));
  EVP_DigestUpdate := TEVP_DigestUpdate(GetSymbol('EVP_DigestUpdate'));
  EVP_DigestSignFinal := TEVP_DigestSignFinal(
    GetSymbol('EVP_DigestSignFinal'));
  EVP_DigestVerifyFinal := TEVP_DigestVerifyFinal(
    GetSymbol('EVP_DigestVerifyFinal'));
end;

procedure InitLibCrypto;
var
  LNames: TArray<String>;
  LIndex: Integer;
begin
  GLock.Enter;
  try
    if not GResolved then
    begin
      LNames := LibCryptoNames;
      if Length(LNames) = 0 then
        raise ETHttpJWTException.Create(
          'RS256: OpenSSL libcrypto is not available on this platform.');

      LIndex := Low(LNames);
      while (GLibCrypto = 0) and (LIndex <= High(LNames)) do
      begin
        GLibCrypto := OpenLibCrypto(LNames[LIndex]);
        Inc(LIndex);
      end;

      if GLibCrypto = 0 then
        raise ETHttpJWTException.CreateFmt(
          'OpenSSL: unable to load libcrypto (tried %s).', [
            String.Join(', ', LNames)]);

      try
        ResolveSymbols;
        GResolved := True;
      except
        CloseLibCrypto;
        raise;
      end;
    end;
  finally
    GLock.Leave;
  end;
end;

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
  LCtx := EVP_MD_CTX_new();
  if LCtx = nil then
    raise ETHttpJWTException.Create('OpenSSL: EVP_MD_CTX_new failed.');
  try
    if EVP_DigestSignInit(LCtx, nil, EVP_sha256(), nil, AKey) <> 1 then
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
    LCtx := EVP_MD_CTX_new();
    if LCtx = nil then
      raise ETHttpJWTException.Create('OpenSSL: EVP_MD_CTX_new failed.');
    try
      if EVP_DigestVerifyInit(LCtx, nil, EVP_sha256(), nil, AKey) <> 1 then
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

  InitLibCrypto;
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
  InitLibCrypto;
  LKey := LoadKey(GetPublicKey, False);
  try
    result := InternalVerify(LKey, ASigningInput, ASignature);
  finally
    EVP_PKEY_free(LKey);
  end;
end;

initialization
  GLock := TCriticalSection.Create;

finalization
  // libcrypto is left loaded on purpose
  GLock.Free;

end.
