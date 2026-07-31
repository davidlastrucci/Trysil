(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.Http.JWT.RSAKey;

interface

uses
  System.SysUtils,
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF}
{$IFDEF POSIX}
  Posix.Dlfcn,
{$ENDIF}

  Trysil.Sync,
  Trysil.Http.JWT.Payload;

type

{ TTHttpJWTRSAAbstractKey }

  TTHttpJWTRSAAbstractKey = class abstract
  strict private
    FPem: String;
    FKeyID: String;
    FKey: Pointer;

    procedure LoadKey;
  strict protected
    function IsPrivateKey: Boolean; virtual; abstract;
    procedure WarmUp; virtual;

    property Key: Pointer read FKey;
  public
    constructor Create(const APem: String); overload;
    constructor Create(
      const APem: String; const AKeyID: String); overload;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Verify(
      const ASigningInput: TBytes; const ASignature: TBytes): Boolean;

    property KeyID: String read FKeyID;
  end;

{ TTHttpJWTRSAPublicKey }

  TTHttpJWTRSAPublicKey = class(TTHttpJWTRSAAbstractKey)
  strict protected
    function IsPrivateKey: Boolean; override;
  end;

{ TTHttpJWTRSAPrivateKey }

  TTHttpJWTRSAPrivateKey = class(TTHttpJWTRSAAbstractKey)
  strict protected
    function IsPrivateKey: Boolean; override;
    procedure WarmUp; override;
  public
    function Sign(const ASigningInput: TBytes): TBytes;
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
  GLock: TTCriticalSection = nil;
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
  GLock.Acquire;
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
    GLock.Release;
  end;
end;

{ Helpers }

function LoadPemKey(const APem: String; const APrivate: Boolean): Pointer;
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
      raise ETHttpJWTException.Create(
        'OpenSSL: EVP_DigestSignFinal (len) failed.');

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
        raise ETHttpJWTException.Create(
          'OpenSSL: EVP_DigestVerifyInit failed.');
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

function WarmUpInput: TBytes;
begin
  result := TEncoding.UTF8.GetBytes('Trysil');
end;

{ TTHttpJWTRSAAbstractKey }

constructor TTHttpJWTRSAAbstractKey.Create(const APem: String);
begin
  Create(APem, String.Empty);
end;

constructor TTHttpJWTRSAAbstractKey.Create(
  const APem: String; const AKeyID: String);
begin
  inherited Create;
  FPem := APem;
  FKeyID := AKeyID;
  FKey := nil;
end;

destructor TTHttpJWTRSAAbstractKey.Destroy;
begin
  if Assigned(FKey) and Assigned(EVP_PKEY_free) then
    EVP_PKEY_free(FKey);
  inherited Destroy;
end;

procedure TTHttpJWTRSAAbstractKey.AfterConstruction;
begin
  inherited AfterConstruction;
  LoadKey;
  WarmUp;
end;

procedure TTHttpJWTRSAAbstractKey.LoadKey;
begin
  InitLibCrypto;
  FKey := LoadPemKey(FPem, IsPrivateKey);
  FPem := String.Empty;
end;

procedure TTHttpJWTRSAAbstractKey.WarmUp;
var
  LSignature: TBytes;
begin
  SetLength(LSignature, 256);
  InternalVerify(FKey, WarmUpInput, LSignature);
end;

function TTHttpJWTRSAAbstractKey.Verify(
  const ASigningInput: TBytes; const ASignature: TBytes): Boolean;
begin
  result := InternalVerify(FKey, ASigningInput, ASignature);
end;

{ TTHttpJWTRSAPublicKey }

function TTHttpJWTRSAPublicKey.IsPrivateKey: Boolean;
begin
  result := False;
end;

{ TTHttpJWTRSAPrivateKey }

function TTHttpJWTRSAPrivateKey.IsPrivateKey: Boolean;
begin
  result := True;
end;

procedure TTHttpJWTRSAPrivateKey.WarmUp;
begin
  inherited WarmUp;
  InternalSign(Key, WarmUpInput);
end;

function TTHttpJWTRSAPrivateKey.Sign(const ASigningInput: TBytes): TBytes;
begin
  result := InternalSign(Key, ASigningInput);
end;

initialization
  GLock := TTCriticalSection.Create;

finalization
  // libcrypto is left loaded on purpose
  GLock.Free;

end.
