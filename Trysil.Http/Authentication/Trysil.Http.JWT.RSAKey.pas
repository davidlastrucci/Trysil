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
    class function WarmUpInput: TBytes; static;

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

{ TTHttpJWTLibCrypto }

const
  EVP_PKEY_RSA = 6;

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
  TEVP_PKEY_base_id = function(
    AKey: Pointer): Integer; cdecl;

  TEVP_MD_CTX_new = function: Pointer; cdecl;
  TEVP_MD_CTX_free = procedure(ACtx: Pointer); cdecl;
  TEVP_sha256 = function: Pointer; cdecl;

  TEVP_DigestSignInit = function(
    ACtx, APCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  TEVP_DigestVerifyInit = function(
    ACtx, APCtx, AType, AEngine, AKey: Pointer): Integer; cdecl;
  TEVP_DigestUpdate = function(
    ACtx: Pointer; AData: Pointer; ALen: NativeUInt): Integer; cdecl;
  TEVP_DigestSignFinal = function(
    ACtx: Pointer; ASig: Pointer; var ASigLen: NativeUInt): Integer; cdecl;
  TEVP_DigestVerifyFinal = function(
    ACtx: Pointer; ASig: Pointer; ASigLen: NativeUInt): Integer; cdecl;

  TTHttpJWTLibCrypto = class
  strict private
    class var FInstance: TTHttpJWTLibCrypto;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FLock: TTCriticalSection;
    FHandle: TLibHandle;
    FResolved: Boolean;

    FBIO_new_mem_buf: TBIO_new_mem_buf;
    FBIO_free: TBIO_free;
    FPEM_read_bio_PrivateKey: TPEM_read_bio_PrivateKey;
    FPEM_read_bio_PUBKEY: TPEM_read_bio_PUBKEY;
    FEVP_PKEY_free: TEVP_PKEY_free;
    FEVP_PKEY_base_id: TEVP_PKEY_base_id;
    FEVP_MD_CTX_new: TEVP_MD_CTX_new;
    FEVP_MD_CTX_free: TEVP_MD_CTX_free;
    FEVP_sha256: TEVP_sha256;
    FEVP_DigestSignInit: TEVP_DigestSignInit;
    FEVP_DigestVerifyInit: TEVP_DigestVerifyInit;
    FEVP_DigestUpdate: TEVP_DigestUpdate;
    FEVP_DigestSignFinal: TEVP_DigestSignFinal;
    FEVP_DigestVerifyFinal: TEVP_DigestVerifyFinal;

    class function LibraryNames: TArray<String>; static;
    class function OpenLibrary(const AName: String): TLibHandle; static;

    procedure CloseLibrary;
    function TryGetSymbol(const AName: String): Pointer;
    function GetSymbol(const AName: String): Pointer;
    function GetAnySymbol(
      const AName: String;
      const AAlternateName: String): Pointer;
    procedure CheckIsRsaKey(const AKey: Pointer);
    procedure ResolveSymbols;
    procedure LoadLibrary;
    function NewDigestContext: Pointer;
    function ReadPem(const ABio: Pointer; const APrivate: Boolean): Pointer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Initialize;

    function LoadPemKey(
      const APem: String; const APrivate: Boolean): Pointer;
    procedure FreeKey(const AKey: Pointer);

    function Sign(const AKey: Pointer; const AInput: TBytes): TBytes;
    function Verify(
      const AKey: Pointer;
      const AInput: TBytes;
      const ASignature: TBytes): Boolean;

    class property Instance: TTHttpJWTLibCrypto read FInstance;
  end;

class constructor TTHttpJWTLibCrypto.ClassCreate;
begin
  FInstance := TTHttpJWTLibCrypto.Create;
end;

class destructor TTHttpJWTLibCrypto.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTHttpJWTLibCrypto.Create;
begin
  inherited Create;
  FLock := TTCriticalSection.Create;
  FHandle := 0;
  FResolved := False;
end;

destructor TTHttpJWTLibCrypto.Destroy;
begin
  // libcrypto is left loaded on purpose
  FLock.Free;
  inherited Destroy;
end;

class function TTHttpJWTLibCrypto.LibraryNames: TArray<String>;
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

class function TTHttpJWTLibCrypto.OpenLibrary(
  const AName: String): TLibHandle;
{$IFDEF POSIX}
var
  LName: UTF8String;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  result := Winapi.Windows.LoadLibrary(PChar(AName));
{$ENDIF}
{$IFDEF POSIX}
  LName := UTF8String(AName);
  result := dlopen(MarshaledAString(LName), RTLD_LAZY);
{$ENDIF}
end;

procedure TTHttpJWTLibCrypto.CloseLibrary;
begin
  if FHandle <> 0 then
  begin
{$IFDEF MSWINDOWS}
    FreeLibrary(HMODULE(FHandle));
{$ENDIF}
{$IFDEF POSIX}
    dlclose(FHandle);
{$ENDIF}
    FHandle := 0;
  end;
end;

function TTHttpJWTLibCrypto.TryGetSymbol(const AName: String): Pointer;
{$IFDEF POSIX}
var
  LName: UTF8String;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  result := GetProcAddress(HMODULE(FHandle), PChar(AName));
{$ENDIF}
{$IFDEF POSIX}
  LName := UTF8String(AName);
  result := dlsym(FHandle, MarshaledAString(LName));
{$ENDIF}
end;

function TTHttpJWTLibCrypto.GetSymbol(const AName: String): Pointer;
begin
  result := TryGetSymbol(AName);
  if result = nil then
    raise ETHttpJWTException.CreateFmt(
      'OpenSSL: symbol "%s" not found in libcrypto.', [AName]);
end;

function TTHttpJWTLibCrypto.GetAnySymbol(
  const AName: String;
  const AAlternateName: String): Pointer;
begin
  result := TryGetSymbol(AName);
  if result = nil then
    result := TryGetSymbol(AAlternateName);

  if result = nil then
    raise ETHttpJWTException.CreateFmt(
      'OpenSSL: neither "%0:s" nor "%1:s" found in libcrypto.', [
        AName, AAlternateName]);
end;

procedure TTHttpJWTLibCrypto.ResolveSymbols;
begin
  FBIO_new_mem_buf := TBIO_new_mem_buf(GetSymbol('BIO_new_mem_buf'));
  FBIO_free := TBIO_free(GetSymbol('BIO_free'));
  FPEM_read_bio_PrivateKey := TPEM_read_bio_PrivateKey(
    GetSymbol('PEM_read_bio_PrivateKey'));
  FPEM_read_bio_PUBKEY := TPEM_read_bio_PUBKEY(
    GetSymbol('PEM_read_bio_PUBKEY'));
  FEVP_PKEY_free := TEVP_PKEY_free(GetSymbol('EVP_PKEY_free'));
  FEVP_PKEY_base_id := TEVP_PKEY_base_id(
    GetAnySymbol('EVP_PKEY_base_id', 'EVP_PKEY_get_base_id'));
  FEVP_MD_CTX_new := TEVP_MD_CTX_new(GetSymbol('EVP_MD_CTX_new'));
  FEVP_MD_CTX_free := TEVP_MD_CTX_free(GetSymbol('EVP_MD_CTX_free'));
  FEVP_sha256 := TEVP_sha256(GetSymbol('EVP_sha256'));
  FEVP_DigestSignInit := TEVP_DigestSignInit(
    GetSymbol('EVP_DigestSignInit'));
  FEVP_DigestVerifyInit := TEVP_DigestVerifyInit(
    GetSymbol('EVP_DigestVerifyInit'));
  FEVP_DigestUpdate := TEVP_DigestUpdate(GetSymbol('EVP_DigestUpdate'));
  FEVP_DigestSignFinal := TEVP_DigestSignFinal(
    GetSymbol('EVP_DigestSignFinal'));
  FEVP_DigestVerifyFinal := TEVP_DigestVerifyFinal(
    GetSymbol('EVP_DigestVerifyFinal'));
end;

procedure TTHttpJWTLibCrypto.LoadLibrary;
var
  LNames: TArray<String>;
  LIndex: Integer;
begin
  LNames := LibraryNames;
  if Length(LNames) = 0 then
    raise ETHttpJWTException.Create(
      'RS256: OpenSSL libcrypto is not available on this platform.');

  LIndex := Low(LNames);
  while (FHandle = 0) and (LIndex <= High(LNames)) do
  begin
    FHandle := OpenLibrary(LNames[LIndex]);
    Inc(LIndex);
  end;

  if FHandle = 0 then
    raise ETHttpJWTException.CreateFmt(
      'OpenSSL: unable to load libcrypto (tried %s).', [
        String.Join(', ', LNames)]);
end;

procedure TTHttpJWTLibCrypto.Initialize;
begin
  FLock.Acquire;
  try
    if not FResolved then
    begin
      LoadLibrary;
      try
        ResolveSymbols;
        FResolved := True;
      except
        CloseLibrary;
        raise;
      end;
    end;
  finally
    FLock.Release;
  end;
end;

function TTHttpJWTLibCrypto.ReadPem(
  const ABio: Pointer; const APrivate: Boolean): Pointer;
begin
  if APrivate then
    result := FPEM_read_bio_PrivateKey(ABio, nil, nil, nil)
  else
    result := FPEM_read_bio_PUBKEY(ABio, nil, nil, nil);
end;

function TTHttpJWTLibCrypto.LoadPemKey(
  const APem: String; const APrivate: Boolean): Pointer;
var
  LBytes: TBytes;
  LBio: Pointer;
begin
  LBytes := TEncoding.UTF8.GetBytes(APem);
  if Length(LBytes) = 0 then
    raise ETHttpJWTException.Create('RS256: empty key.');

  LBio := FBIO_new_mem_buf(@LBytes[0], Length(LBytes));
  if LBio = nil then
    raise ETHttpJWTException.Create('OpenSSL: BIO_new_mem_buf failed.');
  try
    result := ReadPem(LBio, APrivate);
  finally
    FBIO_free(LBio);
  end;

  if result = nil then
    raise ETHttpJWTException.Create('OpenSSL: cannot load RSA key from PEM.');

  CheckIsRsaKey(result);
end;

procedure TTHttpJWTLibCrypto.CheckIsRsaKey(const AKey: Pointer);
begin
  if FEVP_PKEY_base_id(AKey) <> EVP_PKEY_RSA then
  begin
    FreeKey(AKey);
    raise ETHttpJWTException.Create(
      'RS256: the PEM carries a key that is not RSA. EVP_DigestVerify ' +
      'signs and verifies with whatever algorithm the key names, so an ' +
      'EC key here would have verified ECDSA signatures while the token ' +
      'header said RS256.');
  end;
end;

procedure TTHttpJWTLibCrypto.FreeKey(const AKey: Pointer);
begin
  if Assigned(AKey) and Assigned(FEVP_PKEY_free) then
    FEVP_PKEY_free(AKey);
end;

function TTHttpJWTLibCrypto.NewDigestContext: Pointer;
begin
  result := FEVP_MD_CTX_new();
  if result = nil then
    raise ETHttpJWTException.Create('OpenSSL: EVP_MD_CTX_new failed.');
end;

function TTHttpJWTLibCrypto.Sign(
  const AKey: Pointer; const AInput: TBytes): TBytes;
var
  LCtx: Pointer;
  LLen: NativeUInt;
begin
  LCtx := NewDigestContext;
  try
    if FEVP_DigestSignInit(LCtx, nil, FEVP_sha256(), nil, AKey) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestSignInit failed.');
    if FEVP_DigestUpdate(LCtx, @AInput[0], Length(AInput)) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestUpdate failed.');

    LLen := 0;
    if FEVP_DigestSignFinal(LCtx, nil, LLen) <> 1 then
      raise ETHttpJWTException.Create(
        'OpenSSL: EVP_DigestSignFinal (len) failed.');

    SetLength(result, LLen);
    if FEVP_DigestSignFinal(LCtx, @result[0], LLen) <> 1 then
      raise ETHttpJWTException.Create('OpenSSL: EVP_DigestSignFinal failed.');
    SetLength(result, LLen);
  finally
    FEVP_MD_CTX_free(LCtx);
  end;
end;

function TTHttpJWTLibCrypto.Verify(
  const AKey: Pointer;
  const AInput: TBytes;
  const ASignature: TBytes): Boolean;
var
  LCtx: Pointer;
begin
  if Length(ASignature) = 0 then
    result := False
  else
  begin
    LCtx := NewDigestContext;
    try
      if FEVP_DigestVerifyInit(LCtx, nil, FEVP_sha256(), nil, AKey) <> 1 then
        raise ETHttpJWTException.Create(
          'OpenSSL: EVP_DigestVerifyInit failed.');
      if FEVP_DigestUpdate(LCtx, @AInput[0], Length(AInput)) <> 1 then
        raise ETHttpJWTException.Create('OpenSSL: EVP_DigestUpdate failed.');

      // 1 = Valid; 0 = Not valid; <0 = Error
      result := FEVP_DigestVerifyFinal(
        LCtx, @ASignature[0], Length(ASignature)) = 1;
    finally
      FEVP_MD_CTX_free(LCtx);
    end;
  end;
end;

{ TTHttpJWTRSAAbstractKey }

class function TTHttpJWTRSAAbstractKey.WarmUpInput: TBytes;
begin
  result := TEncoding.UTF8.GetBytes('Trysil');
end;

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
  if Assigned(TTHttpJWTLibCrypto.Instance) then
    TTHttpJWTLibCrypto.Instance.FreeKey(FKey);
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
  TTHttpJWTLibCrypto.Instance.Initialize;
  FKey := TTHttpJWTLibCrypto.Instance.LoadPemKey(FPem, IsPrivateKey);
  FPem := String.Empty;
end;

procedure TTHttpJWTRSAAbstractKey.WarmUp;
var
  LSignature: TBytes;
begin
  SetLength(LSignature, 256);
  TTHttpJWTLibCrypto.Instance.Verify(FKey, WarmUpInput, LSignature);
end;

function TTHttpJWTRSAAbstractKey.Verify(
  const ASigningInput: TBytes; const ASignature: TBytes): Boolean;
begin
  result := TTHttpJWTLibCrypto.Instance.Verify(
    FKey, ASigningInput, ASignature);
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
  TTHttpJWTLibCrypto.Instance.Sign(Key, WarmUpInput);
end;

function TTHttpJWTRSAPrivateKey.Sign(const ASigningInput: TBytes): TBytes;
begin
  result := TTHttpJWTLibCrypto.Instance.Sign(Key, ASigningInput);
end;

end.
