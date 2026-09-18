(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.JWT;

interface

uses
  System.SysUtils,
  System.JSON,
  DUnitX.TestFramework,

  Trysil.Http.JWT,
  Trysil.Http.JWT.Payload,
  Trysil.Http.JWT.Payload.HS256;

type

{ TTestJWTPayload }

  TTestJWTPayload = class(TTHttpJWTHS256Payload)
  strict private
    FUsername: String;
    FRole: String;
  strict protected
    function GetSecret: String; override;
  public
    function ToJSon: String; override;
    procedure FromJSon(const AContext: String); override;

    property Username: String read FUsername write FUsername;
    property Role: String read FRole write FRole;
  end;

{ TNoSecretJWTPayload }

  TNoSecretJWTPayload = class(TTestJWTPayload)
  strict protected
    function GetSecret: String; override;
  end;

{ TTHttpJWTTests }

  [TestFixture]
  TTHttpJWTTests = class
  strict private
    const Base64Url =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  strict private
    function NewToken(const AUsername: String): String;
    function TokenWithHeader(const AHeader: String): String;
    function SignedTokenWithHeader(const AHeader: String): String;
    function CanLoad(const AToken: String): Boolean;
  public
    [Test]
    procedure TokenHasThreeParts;

    [Test]
    procedure TokenRoundTrip;

    [Test]
    procedure InvalidTokenReturnsFalse;

    [Test]
    procedure TamperedTokenReturnsFalse;

    [Test]
    procedure ANonCanonicalTokenReturnsFalse;

    [Test]
    procedure ASignatureWithSlackBitsReturnsFalse;

    [Test]
    procedure ASegmentWithAMalformedLengthReturnsFalse;

    [Test]
    procedure AnEmptySegmentReturnsFalse;

    [Test]
    procedure ANonStringHeaderClaimReturnsFalse;

    [Test]
    procedure IsValidRefusesASegmentOfInvalidLength;

    [Test]
    procedure IsValidRefusesAnEmptySegment;

    [Test]
    procedure ALongPayloadRoundTrips;

    [Test]
    procedure TheUrlAlphabetRoundTripsBothWays;

    [Test]
    procedure AnEmptySecretRefusesToSign;

    [Test]
    procedure AnEmptySecretRefusesToVerify;

    [Test]
    procedure AlgorithmNoneWithAnEmptySignatureReturnsFalse;

    [Test]
    procedure ASignedTokenNamingAnotherAlgorithmReturnsFalse;

    [Test]
    procedure ASignedTokenWithNoAlgorithmReturnsFalse;

    [Test]
    procedure ASignedTokenWithANonStringAlgorithmReturnsFalse;

    [Test]
    procedure ASignedTokenWithANonStringKeyIDDegradesToNoKeyID;
  end;

implementation

{ TTestJWTPayload }

function TTestJWTPayload.GetSecret: String;
begin
  result := 'test-secret-key-12345';
end;

function TTestJWTPayload.ToJSon: String;
var
  LObj: TJSonObject;
begin
  LObj := TJSonObject.Create;
  try
    LObj.AddPair('username', FUsername);
    LObj.AddPair('role', FRole);
    result := LObj.ToJSon;
  finally
    LObj.Free;
  end;
end;

procedure TTestJWTPayload.FromJSon(const AContext: String);
var
  LObj: TJSonValue;
begin
  LObj := TJSonObject.ParseJSonValue(AContext);
  try
    if LObj is TJSonObject then
    begin
      FUsername := TJSonObject(LObj).GetValue<String>('username', '');
      FRole := TJSonObject(LObj).GetValue<String>('role', '');
    end;
  finally
    LObj.Free;
  end;
end;

{ TNoSecretJWTPayload }

function TNoSecretJWTPayload.GetSecret: String;
begin
  result := String.Empty;
end;

{ TTHttpJWTTests }

function TTHttpJWTTests.NewToken(const AUsername: String): String;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := AUsername;
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      result := LJWT.ToToken;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

function TTHttpJWTTests.CanLoad(const AToken: String): Boolean;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      result := LJWT.LoadFromToken(AToken);
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TTHttpJWTTests.ASignatureWithSlackBitsReturnsFalse;
var
  LToken: String;
  LLast: Integer;
  LOffset: Integer;
  LVariant: String;
begin
  LToken := NewToken('john');
  LLast := Base64Url.IndexOf(LToken.Chars[LToken.Length - 1]);
  for LOffset := 0 to 3 do
  begin
    LVariant := LToken.Substring(0, LToken.Length - 1) +
      Base64Url.Chars[(LLast and not 3) + LOffset];
    if (LLast and not 3) + LOffset = LLast then
      Assert.IsTrue(CanLoad(LVariant), 'Precondition: the token is valid')
    else
      Assert.IsFalse(
        CanLoad(LVariant),
        'The unused bits of the last character used to give four token ' +
        'strings that verify as the same token');
  end;
end;

procedure TTHttpJWTTests.ASegmentWithAMalformedLengthReturnsFalse;
var
  LParts: TArray<String>;
  LSignature: String;
  LRaised: Boolean;
  LLoaded: Boolean;
begin
  LParts := NewToken('john').Split(['.']);
  LSignature := LParts[2];
  while LSignature.Length mod 4 <> 1 do
    LSignature := LSignature.Substring(0, LSignature.Length - 1);

  LRaised := False;
  LLoaded := True;
  try
    LLoaded := CanLoad(
      Format('%s.%s.%s', [LParts[0], LParts[1], LSignature]));
  except
    LRaised := True;
  end;

  Assert.IsFalse(LRaised,
    'A segment that cannot be padded must not escape as an exception: ' +
    'an anonymous caller would get a 500 instead of a 403');
  Assert.IsFalse(LLoaded, 'A segment of that length is not a valid token');
end;

procedure TTHttpJWTTests.AnEmptySegmentReturnsFalse;
var
  LParts: TArray<String>;
begin
  LParts := NewToken('john').Split(['.']);
  Assert.IsFalse(
    CanLoad(Format('.%s.%s', [LParts[1], LParts[2]])),
    'An empty header is not a valid token');
  Assert.IsFalse(
    CanLoad(Format('%s..%s', [LParts[0], LParts[2]])),
    'An empty payload is not a valid token');
  Assert.IsFalse(
    CanLoad(Format('%s.%s.', [LParts[0], LParts[1]])),
    'An empty signature is not a valid token');
  Assert.IsFalse(CanLoad('..'), 'Three empty segments are not a token');
end;

function TTHttpJWTTests.TokenWithHeader(const AHeader: String): String;
var
  LParts: TArray<String>;
begin
  LParts := NewToken('john').Split(['.']);
  result := Format('%s.%s.%s', [
    TTHttpJWTEncoding.Encode(TEncoding.UTF8.GetBytes(AHeader)),
    LParts[1],
    LParts[2]]);
end;

function TTHttpJWTTests.SignedTokenWithHeader(const AHeader: String): String;
var
  LPayload: TTestJWTPayload;
  LHeaderSeg, LPayloadSeg: String;
  LSigningInput: TBytes;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := 'john';
    LHeaderSeg := TTHttpJWTEncoding.Encode(TEncoding.UTF8.GetBytes(AHeader));
    LPayloadSeg := TTHttpJWTEncoding.Encode(
      TEncoding.UTF8.GetBytes(LPayload.ToJSon()));
    LSigningInput := TEncoding.UTF8.GetBytes(
      Format('%s.%s', [LHeaderSeg, LPayloadSeg]));
    result := Format('%s.%s.%s', [
      LHeaderSeg,
      LPayloadSeg,
      TTHttpJWTEncoding.Encode(LPayload.Sign(LSigningInput))]);
  finally
    LPayload.Free;
  end;
end;

procedure TTHttpJWTTests.ANonStringHeaderClaimReturnsFalse;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    CanLoad(TokenWithHeader('{"alg":{},"typ":"JWT"}'));
    CanLoad(TokenWithHeader('{"alg":"HS256","kid":[],"typ":"JWT"}'));
  except
    LRaised := True;
  end;

  Assert.IsFalse(LRaised,
    'A header claim that is not a string must not escape as an exception: ' +
    'on some RTL versions GetValue<String> raises, and an anonymous ' +
    'caller would get a 500 instead of a 403');
end;

procedure TTHttpJWTTests.AlgorithmNoneWithAnEmptySignatureReturnsFalse;
var
  LParts: TArray<String>;
  LHeaderSeg: String;
begin
  LParts := NewToken('john').Split(['.']);
  LHeaderSeg := TTHttpJWTEncoding.Encode(
    TEncoding.UTF8.GetBytes('{"alg":"none","typ":"JWT"}'));

  Assert.IsFalse(
    CanLoad(Format('%s.%s.', [LHeaderSeg, LParts[1]])),
    'The unsigned token is the oldest attack on JWT. This one is stopped ' +
    'by the empty third segment, before the algorithm is even read');
  Assert.IsFalse(
    CanLoad(SignedTokenWithHeader('{"alg":"none","typ":"JWT"}')),
    'And this one is stopped by the algorithm alone: the signature is ' +
    'made with our own secret, so it verifies');
end;

procedure TTHttpJWTTests.ASignedTokenNamingAnotherAlgorithmReturnsFalse;
begin
  Assert.IsFalse(
    CanLoad(SignedTokenWithHeader('{"alg":"HS512","typ":"JWT"}')),
    'The signature verifies, because it was made with our own secret: ' +
    'only the algorithm check can refuse this token, and it must');
end;

procedure TTHttpJWTTests.ASignedTokenWithNoAlgorithmReturnsFalse;
begin
  Assert.IsFalse(
    CanLoad(SignedTokenWithHeader('{"typ":"JWT"}')),
    'A header that names no algorithm is not a header we accept, however ' +
    'well the token is signed');
end;

procedure TTHttpJWTTests.ASignedTokenWithANonStringAlgorithmReturnsFalse;
begin
  Assert.IsFalse(
    CanLoad(SignedTokenWithHeader('{"alg":{},"typ":"JWT"}')),
    'An algorithm that is an object reads as no algorithm, and the ' +
    'signature being valid must not save it');
end;

procedure TTHttpJWTTests.ASignedTokenWithANonStringKeyIDDegradesToNoKeyID;
begin
  Assert.IsTrue(
    CanLoad(SignedTokenWithHeader('{"alg":"HS256","kid":[],"typ":"JWT"}')),
    'A kid that is not a string reads as no kid, so the payload verifies ' +
    'with its default key: a malformed kid is not a way in, because the ' +
    'signature still has to be made with that key');
end;

procedure TTHttpJWTTests.IsValidRefusesASegmentOfInvalidLength;
var
  LSegment: String;
  LTrimmed: String;
begin
  LSegment := TTHttpJWTEncoding.Encode(TEncoding.UTF8.GetBytes('john'));
  LTrimmed := LSegment;
  while LTrimmed.Length mod 4 <> 1 do
    LTrimmed := LTrimmed.Substring(0, LTrimmed.Length - 1);

  Assert.IsTrue(TTHttpJWTEncoding.IsValid(LSegment),
    'Precondition: what Encode produces must be accepted');
  Assert.IsFalse(TTHttpJWTEncoding.IsValid(LTrimmed),
    'A segment of that length cannot be padded to a base64 quad, and the ' +
    'refusal must come from IsValid, not from the signature check');
end;

procedure TTHttpJWTTests.IsValidRefusesAnEmptySegment;
begin
  Assert.IsFalse(TTHttpJWTEncoding.IsValid(String.Empty),
    'No segment of a token is ever legitimately empty: the header and the ' +
    'payload are JSon objects and the signature is bytes. It used to be ' +
    'accepted, and the empty-segment tests passed on the JSon parse and ' +
    'the signature length instead');
end;

procedure TTHttpJWTTests.ALongPayloadRoundTrips;
var
  LUsername: String;
  LToken: String;
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LUsername := StringOfChar('a', 500);
  LToken := NewToken(LUsername);

  LPayload := TTestJWTPayload.Create;
  try
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      Assert.IsTrue(
        LJWT.LoadFromToken(LToken),
        'Base64 wraps at 76 characters and Encode strips those breaks: no ' +
        'other test has a segment long enough to wrap, so removing the ' +
        'three Replace calls would leave the whole suite green');
      Assert.AreEqual(LUsername, LJWT.Payload.Username);
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TTHttpJWTTests.TheUrlAlphabetRoundTripsBothWays;
var
  LSegment: String;
begin
  LSegment := TTHttpJWTEncoding.Encode(TBytes.Create($FA, $FF, $BF));

  Assert.IsTrue(
    LSegment.Contains('-') and LSegment.Contains('_'),
    'Precondition: these bytes produce both substituted characters');
  Assert.AreEqual(
    LSegment,
    TTHttpJWTEncoding.Encode(TTHttpJWTEncoding.Decode(LSegment)),
    'Encode maps + and / to - and _, Decode maps them back: an error in ' +
    'one direction only is caught by nothing else');
end;

procedure TTHttpJWTTests.TokenHasThreeParts;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
  LToken: String;
  LParts: TArray<String>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := 'john';
    LPayload.Role := 'admin';
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      LToken := LJWT.ToToken;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  LParts := LToken.Split(['.']);
  Assert.AreEqual<Integer>(3, Length(LParts),
    'JWT token must have exactly 3 parts');
end;

procedure TTHttpJWTTests.TokenRoundTrip;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
  LToken: String;
  LLoadPayload: TTestJWTPayload;
  LLoadJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := 'john';
    LPayload.Role := 'admin';
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      LToken := LJWT.ToToken;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  LLoadPayload := TTestJWTPayload.Create;
  try
    LLoadJWT := TTHttpJWT<TTestJWTPayload>.Create(LLoadPayload);
    try
      Assert.IsTrue(LLoadJWT.LoadFromToken(LToken),
        'LoadFromToken must return True for a valid token');
      Assert.AreEqual('john', LLoadJWT.Payload.Username);
      Assert.AreEqual('admin', LLoadJWT.Payload.Role);
    finally
      LLoadJWT.Free;
    end;
  finally
    LLoadPayload.Free;
  end;
end;

procedure TTHttpJWTTests.InvalidTokenReturnsFalse;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      Assert.IsFalse(LJWT.LoadFromToken('not-a-valid-token'),
        'LoadFromToken must return False for garbage input');
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;
end;

procedure TTHttpJWTTests.ANonCanonicalTokenReturnsFalse;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
  LToken: String;
  LLoadPayload: TTestJWTPayload;
  LLoadJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := 'john';
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      LToken := LJWT.ToToken;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  LLoadPayload := TTestJWTPayload.Create;
  try
    LLoadJWT := TTHttpJWT<TTestJWTPayload>.Create(LLoadPayload);
    try
      Assert.IsFalse(
        LLoadJWT.LoadFromToken(Format('%s ', [LToken])),
        'A character outside the base64url alphabet used to be dropped, ' +
        'so many token strings authenticated as the same token');
      Assert.IsFalse(
        LLoadJWT.LoadFromToken(Format('%s=', [LToken])),
        'Padding is not part of the canonical form either');
    finally
      LLoadJWT.Free;
    end;
  finally
    LLoadPayload.Free;
  end;
end;

procedure TTHttpJWTTests.TamperedTokenReturnsFalse;
var
  LPayload: TTestJWTPayload;
  LJWT: TTHttpJWT<TTestJWTPayload>;
  LToken: String;
  LParts: TArray<String>;
  LTampered: String;
  LLoadPayload: TTestJWTPayload;
  LLoadJWT: TTHttpJWT<TTestJWTPayload>;
begin
  LPayload := TTestJWTPayload.Create;
  try
    LPayload.Username := 'john';
    LPayload.Role := 'admin';
    LJWT := TTHttpJWT<TTestJWTPayload>.Create(LPayload);
    try
      LToken := LJWT.ToToken;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  LParts := LToken.Split(['.']);
  LTampered := Format('%s.%s.%s', [LParts[0], 'dGFtcGVyZWQ', LParts[2]]);

  LLoadPayload := TTestJWTPayload.Create;
  try
    LLoadJWT := TTHttpJWT<TTestJWTPayload>.Create(LLoadPayload);
    try
      Assert.IsFalse(LLoadJWT.LoadFromToken(LTampered),
        'LoadFromToken must return False for a tampered token');
    finally
      LLoadJWT.Free;
    end;
  finally
    LLoadPayload.Free;
  end;
end;

procedure TTHttpJWTTests.AnEmptySecretRefusesToSign;
var
  LPayload: TNoSecretJWTPayload;
  LJWT: TTHttpJWT<TNoSecretJWTPayload>;
  LToken: String;
  LRaised: Boolean;
begin
  LRaised := False;
  LToken := String.Empty;
  LPayload := TNoSecretJWTPayload.Create;
  try
    LJWT := TTHttpJWT<TNoSecretJWTPayload>.Create(LPayload);
    try
      try
        LToken := LJWT.ToToken;
      except
        on E: ETHttpJWTException do
          LRaised := True;
      end;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'A configuration key that is missing gives an empty secret, and the ' +
    'token used to be signed with it: anyone who guessed that could mint ' +
    'a token with any claims');
  Assert.IsTrue(LToken.IsEmpty, 'And no token came out of it');
end;

procedure TTHttpJWTTests.AnEmptySecretRefusesToVerify;
var
  LPayload: TNoSecretJWTPayload;
  LJWT: TTHttpJWT<TNoSecretJWTPayload>;
  LLoaded: Boolean;
  LRaised: Boolean;
begin
  LRaised := False;
  LLoaded := False;
  LPayload := TNoSecretJWTPayload.Create;
  try
    LJWT := TTHttpJWT<TNoSecretJWTPayload>.Create(LPayload);
    try
      try
        LLoaded := LJWT.LoadFromToken(NewToken('john'));
      except
        on E: ETHttpJWTException do
          LRaised := True;
      end;
    finally
      LJWT.Free;
    end;
  finally
    LPayload.Free;
  end;

  Assert.IsFalse(
    LRaised,
    'Verifying is the anonymous path: a secret the application could not ' +
    'produce for this kid must fail closed, not raise. An exception there ' +
    'is an ETHttpJWTException, which descends from Exception and not from ' +
    'ETHttpException, so the listener answers 500 to a caller who sent no ' +
    'credential at all');
  Assert.IsFalse(
    LLoaded,
    'And it refuses, rather than accepting whatever a caller signed with ' +
    'the same empty secret');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpJWTTests);

end.
