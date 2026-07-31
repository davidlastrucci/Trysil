(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.JWT.RS256;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  DUnitX.TestFramework,

  Trysil.Http.JWT,
  Trysil.Http.JWT.Payload,
  Trysil.Http.JWT.Payload.RS256,
  Trysil.Http.JWT.RSAKey;

type

{ TTestRS256Payload }

  TTestRS256Payload = class(TTHttpJWTRS256Payload)
  strict private
    FUsername: String;
    FSigningKey: TTHttpJWTRSAPrivateKey;
    FVerificationKey: TTHttpJWTRSAAbstractKey;
    FRequestedKeyID: String;

  strict protected
    function GetSigningKey: TTHttpJWTRSAPrivateKey; override;
    function GetVerificationKey(
      const AKeyID: String): TTHttpJWTRSAAbstractKey; override;
  public
    function ToJSon: String; override;
    procedure FromJSon(const AContext: String); override;

    property Username: String read FUsername write FUsername;
    property SigningKey: TTHttpJWTRSAPrivateKey
      read GetSigningKey write FSigningKey;
    property VerificationKey: TTHttpJWTRSAAbstractKey
      read FVerificationKey write FVerificationKey;
    property RequestedKeyID: String read FRequestedKeyID;
  end;

{ TTestSignVerifyThread }

  TTestSignVerifyThread = class(TThread)
  strict private
    FPrivateKey: TTHttpJWTRSAPrivateKey;
    FPublicKey: TTHttpJWTRSAAbstractKey;
    FIterations: Integer;
    FSuccess: Boolean;

  strict protected
    procedure Execute; override;
  public
    constructor Create(
      const APrivateKey: TTHttpJWTRSAPrivateKey;
      const APublicKey: TTHttpJWTRSAAbstractKey;
      const AIterations: Integer);

    property Success: Boolean read FSuccess;
  end;

{ TTHttpJWTRS256Tests }

  [TestFixture]
  TTHttpJWTRS256Tests = class
  public
    [Test]
    procedure TokenRoundTrip;

    [Test]
    procedure WrongPublicKeyReturnsFalse;

    [Test]
    procedure MissingSigningKeyRaises;

    [Test]
    procedure MissingVerificationKeyReturnsFalse;

    [Test]
    procedure KeyIDIsWrittenInHeader;

    [Test]
    procedure SharedKeysAcrossThreads;
  end;

implementation

{ Test keys, generated for this fixture only }

function TestPrivateKeyPem: String;
begin
  result := String.Join(sLineBreak, [
    '-----BEGIN PRIVATE KEY-----',
    'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDprAKK/NOEXHoq',
    '7FSNv6uh7JUCQYlJnwD+2Mguc2wFGrYBqwCRjGIKOd0/cO20JAqY1IkXQC4ocEEv',
    '3eCqAs7NSQgI/w76q54HzV8v205u25ex8aK7NaTFGfAnLVzEneN72sa9UFYJeMD9',
    'v4bsSZZpyYd8XSsw0F1HWbmLCkntb5EI50RFNwix6lsBGBPjDcW7jepPzTm15fbp',
    'FU3WTENdNd35IYxdpd/jAe2ec5x7ozjZxDwUqleAk5h6N/vgqsBY0SHb8S/Z4TeJ',
    'y4nGOv0RPJCWkB7i4/399Bj2m4ikoMrjq0dpYwQewI9PhIz1hdx+XvqgDRrRRmPu',
    'fI+HbGpnAgMBAAECggEAG6CTMmSfC3y1kwKbIqFBRSVIHtqpxTMP9pGh5WAPKvFU',
    'CJFzwUGkS8o4nuoWqKBEQnqKdN3JN03CX0rv55nqYnoagZnKZxfIWOrOsMVQminL',
    'XyYPE+xNPWKKMs+ZssNqJHgi3Do12evVgYrWBHTU3FAP/UO0uhJAnRF+LvK59+Dp',
    'odF0hT33S+kP4Z3R98Pbe6MT0GLFyeu4YBf2rlx5EPFSkhjf+Is5dV9ZiD8AjKJj',
    'A3mteU8AhKNjphCw1zbmZ08nku5NtZ4mNsltQUKsENsdHivk/zUC7hzoKyNjR1S2',
    '6Fz7mm/iHjcYzuYGoUOzOFApUSy5JXwjBVqQtfsyAQKBgQD3ONdnRLAeJSEEldJK',
    'xMbeKSCSch/b+WjRn6fo3O21+oA0qxGVfFkj+bfXGRrmVoc+CBm9Jz/wyLYHWeq3',
    'AToBP+er/VDzD6/0/YFZdawtLcmOoO2SmDSFHBkvy/Hoe9jF+SylEzZpcMs/6SUg',
    '/5JftS4sRMoy5HU+UNP7HptWAQKBgQDx+AC4a/ga+OCJn4ADcfg7Od1x6wnaIw6a',
    '5OEnHXFFZauViLD1oJZLZRur/A2jTvRxslbLR7pC6ozC6rwmXWA07DmqZfTP0H2v',
    'FQP/KdsBQ4lGzXnfMunyMjGpOAZeLIPRzXlMq4ewoWV9/AsW8VTR4GNAdf0AiDA7',
    'Y325+QzQZwKBgQDA+SmKfl9K6IiBX8Eqg7cHquq15UdhGansFsemSO10Yvi4I+Ax',
    '40Jhhoct63bH3Trr/L66m2yZstIDovhHqTlxyEQ6SB1r3Q7oGQlinyuqiFcQciV/',
    'jDdSv8AZQwStCB8JSZrDr9+FJnpAhOhqfZPwCSjlfTynxRSPc+BD4Hw4AQKBgQCI',
    'kR3u+NlOd9tbMY+x4hhlbRJkInEsEg9DMx0003RD489FFaIy8BEDuqw0lI0p9/0V',
    'Ur+T+gbRj8oklRHeYWNUW2NsniDfTeAx+h2IXZpDC1gmgwBfDkBmNxg6VumZK2y2',
    '9E6bDFEISv+abK/hohHqZsf98Nn7++GlE1E5rqwhzwKBgQCuKC9DnhNSBd4tGyfx',
    'eBb0YQ986P3qjDV4th2locdvl045buslzTflhH2/c/W4WDbgBzV+SkWq4auV3vJZ',
    '1PRV1So8e5JfDZaiatadm3xLw0vmr1mbgEzGG1kk6Je1g7FC+JwYubsHmtP0yd9q',
    '6Pyk8lN63y69rEGZrixknnjS3A==',
    '-----END PRIVATE KEY-----']);
end;

function TestPublicKeyPem: String;
begin
  result := String.Join(sLineBreak, [
    '-----BEGIN PUBLIC KEY-----',
    'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6awCivzThFx6KuxUjb+r',
    'oeyVAkGJSZ8A/tjILnNsBRq2AasAkYxiCjndP3DttCQKmNSJF0AuKHBBL93gqgLO',
    'zUkICP8O+queB81fL9tObtuXsfGiuzWkxRnwJy1cxJ3je9rGvVBWCXjA/b+G7EmW',
    'acmHfF0rMNBdR1m5iwpJ7W+RCOdERTcIsepbARgT4w3Fu43qT805teX26RVN1kxD',
    'XTXd+SGMXaXf4wHtnnOce6M42cQ8FKpXgJOYejf74KrAWNEh2/Ev2eE3icuJxjr9',
    'ETyQlpAe4uP9/fQY9puIpKDK46tHaWMEHsCPT4SM9YXcfl76oA0a0UZj7nyPh2xq',
    'ZwIDAQAB',
    '-----END PUBLIC KEY-----']);
end;

function OtherPublicKeyPem: String;
begin
  result := String.Join(sLineBreak, [
    '-----BEGIN PUBLIC KEY-----',
    'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvyzx7q0E3gVy5jwxJKn+',
    'pU7lIN/+83NCKupAb4wzwaSyh+8PBlPP+YViVsJWweSuFi/w4ZN+IPki9HITgvYj',
    'bi5yJ5aTQU0gMOs1wh4QaWzNBaugQGRpyxeTfZDOmpv5zMnSba6qsGGsFq2XYvi0',
    'KCITBgdrLE1GQI+BHbVeVqAW6xOsEGb5ePoPPhTUiZ7/mStqWnoCDCFfcsRR9+En',
    'vfzN8LW9iWIaO3pYyGz8fjYxShn3cgZzYYlHPEZjkkmJ2omsSvey/DaE556nFgk7',
    'KgIMflbrd0BZuTOeezR74BMZRbwPP1Dy4t/4PjauWwIqR/ert3TOcquXBtGqTxhG',
    '0wIDAQAB',
    '-----END PUBLIC KEY-----']);
end;

{ TTestRS256Payload }

function TTestRS256Payload.GetSigningKey: TTHttpJWTRSAPrivateKey;
begin
  result := FSigningKey;
end;

function TTestRS256Payload.GetVerificationKey(
  const AKeyID: String): TTHttpJWTRSAAbstractKey;
begin
  FRequestedKeyID := AKeyID;
  result := FVerificationKey;
end;

function TTestRS256Payload.ToJSon: String;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('username', FUsername);
    result := LJSon.ToJSon;
  finally
    LJSon.Free;
  end;
end;

procedure TTestRS256Payload.FromJSon(const AContext: String);
var
  LJSon: TJSonValue;
begin
  LJSon := TJSonObject.ParseJSonValue(AContext);
  try
    if LJSon is TJSonObject then
      FUsername := TJSonObject(LJSon).GetValue<String>('username', '');
  finally
    LJSon.Free;
  end;
end;

{ TTestSignVerifyThread }

constructor TTestSignVerifyThread.Create(
  const APrivateKey: TTHttpJWTRSAPrivateKey;
  const APublicKey: TTHttpJWTRSAAbstractKey;
  const AIterations: Integer);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FPrivateKey := APrivateKey;
  FPublicKey := APublicKey;
  FIterations := AIterations;
  FSuccess := False;
end;

procedure TTestSignVerifyThread.Execute;
var
  LIndex: Integer;
  LInput: TBytes;
  LSignature: TBytes;
  LSuccess: Boolean;
begin
  LSuccess := True;
  LInput := TEncoding.UTF8.GetBytes('trysil.rs256.concurrency');
  try
    for LIndex := 1 to FIterations do
    begin
      LSignature := FPrivateKey.Sign(LInput);
      if not FPublicKey.Verify(LInput, LSignature) then
        LSuccess := False;
    end;
  except
    LSuccess := False;
  end;
  FSuccess := LSuccess;
end;

{ TTHttpJWTRS256Tests }

procedure TTHttpJWTRS256Tests.TokenRoundTrip;
var
  LPrivateKey: TTHttpJWTRSAPrivateKey;
  LPublicKey: TTHttpJWTRSAPublicKey;
  LPayload: TTestRS256Payload;
  LJWT: TTHttpJWT<TTestRS256Payload>;
  LToken: String;
  LLoadPayload: TTestRS256Payload;
  LLoadJWT: TTHttpJWT<TTestRS256Payload>;
begin
  LPrivateKey := TTHttpJWTRSAPrivateKey.Create(TestPrivateKeyPem);
  try
    LPublicKey := TTHttpJWTRSAPublicKey.Create(TestPublicKeyPem);
    try
      LPayload := TTestRS256Payload.Create;
      try
        LPayload.SigningKey := LPrivateKey;
        LPayload.Username := 'john';
        LJWT := TTHttpJWT<TTestRS256Payload>.Create(LPayload);
        try
          LToken := LJWT.ToToken;
        finally
          LJWT.Free;
        end;
      finally
        LPayload.Free;
      end;

      LLoadPayload := TTestRS256Payload.Create;
      try
        LLoadPayload.VerificationKey := LPublicKey;
        LLoadJWT := TTHttpJWT<TTestRS256Payload>.Create(LLoadPayload);
        try
          Assert.IsTrue(LLoadJWT.LoadFromToken(LToken),
            'An RS256 token must verify with the matching public key');
          Assert.AreEqual('john', LLoadJWT.Payload.Username);
        finally
          LLoadJWT.Free;
        end;
      finally
        LLoadPayload.Free;
      end;
    finally
      LPublicKey.Free;
    end;
  finally
    LPrivateKey.Free;
  end;
end;

procedure TTHttpJWTRS256Tests.WrongPublicKeyReturnsFalse;
var
  LPrivateKey: TTHttpJWTRSAPrivateKey;
  LOtherKey: TTHttpJWTRSAPublicKey;
  LPayload: TTestRS256Payload;
  LJWT: TTHttpJWT<TTestRS256Payload>;
  LToken: String;
  LLoadPayload: TTestRS256Payload;
  LLoadJWT: TTHttpJWT<TTestRS256Payload>;
begin
  LPrivateKey := TTHttpJWTRSAPrivateKey.Create(TestPrivateKeyPem);
  try
    LOtherKey := TTHttpJWTRSAPublicKey.Create(OtherPublicKeyPem);
    try
      LPayload := TTestRS256Payload.Create;
      try
        LPayload.SigningKey := LPrivateKey;
        LPayload.Username := 'john';
        LJWT := TTHttpJWT<TTestRS256Payload>.Create(LPayload);
        try
          LToken := LJWT.ToToken;
        finally
          LJWT.Free;
        end;
      finally
        LPayload.Free;
      end;

      LLoadPayload := TTestRS256Payload.Create;
      try
        LLoadPayload.VerificationKey := LOtherKey;
        LLoadJWT := TTHttpJWT<TTestRS256Payload>.Create(LLoadPayload);
        try
          Assert.IsFalse(LLoadJWT.LoadFromToken(LToken),
            'A token must not verify with a public key from another pair');
        finally
          LLoadJWT.Free;
        end;
      finally
        LLoadPayload.Free;
      end;
    finally
      LOtherKey.Free;
    end;
  finally
    LPrivateKey.Free;
  end;
end;

procedure TTHttpJWTRS256Tests.MissingSigningKeyRaises;
var
  LPayload: TTestRS256Payload;
  LJWT: TTHttpJWT<TTestRS256Payload>;
  LRaised: Boolean;
begin
  LRaised := False;
  LPayload := TTestRS256Payload.Create;
  try
    LJWT := TTHttpJWT<TTestRS256Payload>.Create(LPayload);
    try
      try
        LJWT.ToToken;
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

  Assert.IsTrue(LRaised,
    'Signing without a private key must raise ETHttpJWTException');
end;

procedure TTHttpJWTRS256Tests.MissingVerificationKeyReturnsFalse;
var
  LPrivateKey: TTHttpJWTRSAPrivateKey;
  LPayload: TTestRS256Payload;
  LJWT: TTHttpJWT<TTestRS256Payload>;
  LToken: String;
  LLoadPayload: TTestRS256Payload;
  LLoadJWT: TTHttpJWT<TTestRS256Payload>;
begin
  LPrivateKey := TTHttpJWTRSAPrivateKey.Create(TestPrivateKeyPem);
  try
    LPayload := TTestRS256Payload.Create;
    try
      LPayload.SigningKey := LPrivateKey;
      LJWT := TTHttpJWT<TTestRS256Payload>.Create(LPayload);
      try
        LToken := LJWT.ToToken;
      finally
        LJWT.Free;
      end;
    finally
      LPayload.Free;
    end;
  finally
    LPrivateKey.Free;
  end;

  LLoadPayload := TTestRS256Payload.Create;
  try
    LLoadJWT := TTHttpJWT<TTestRS256Payload>.Create(LLoadPayload);
    try
      Assert.IsFalse(LLoadJWT.LoadFromToken(LToken),
        'An unresolved verification key must fail closed, not raise');
    finally
      LLoadJWT.Free;
    end;
  finally
    LLoadPayload.Free;
  end;
end;

procedure TTHttpJWTRS256Tests.KeyIDIsWrittenInHeader;
var
  LPrivateKey: TTHttpJWTRSAPrivateKey;
  LPublicKey: TTHttpJWTRSAPublicKey;
  LPayload: TTestRS256Payload;
  LJWT: TTHttpJWT<TTestRS256Payload>;
  LToken: String;
  LHeader: TJSonValue;
  LLoadPayload: TTestRS256Payload;
  LLoadJWT: TTHttpJWT<TTestRS256Payload>;
begin
  LPrivateKey := TTHttpJWTRSAPrivateKey.Create(
    TestPrivateKeyPem, 'test-key-1');
  try
    LPublicKey := TTHttpJWTRSAPublicKey.Create(
      TestPublicKeyPem, 'test-key-1');
    try
      LPayload := TTestRS256Payload.Create;
      try
        LPayload.SigningKey := LPrivateKey;
        LJWT := TTHttpJWT<TTestRS256Payload>.Create(LPayload);
        try
          LToken := LJWT.ToToken;
        finally
          LJWT.Free;
        end;
      finally
        LPayload.Free;
      end;

      LHeader := TJSonObject.ParseJSonValue(
        TEncoding.UTF8.GetString(
          TTHttpJWTEncoding.Decode(LToken.Split(['.'])[0])));
      try
        Assert.AreEqual('test-key-1',
          LHeader.GetValue<String>('kid', String.Empty),
          'The signing key ID must be written in the kid header');
      finally
        LHeader.Free;
      end;

      LLoadPayload := TTestRS256Payload.Create;
      try
        LLoadPayload.VerificationKey := LPublicKey;
        LLoadJWT := TTHttpJWT<TTestRS256Payload>.Create(LLoadPayload);
        try
          Assert.IsTrue(LLoadJWT.LoadFromToken(LToken));
          Assert.AreEqual('test-key-1', LLoadJWT.Payload.RequestedKeyID,
            'The kid of the incoming token must be passed to the key lookup');
        finally
          LLoadJWT.Free;
        end;
      finally
        LLoadPayload.Free;
      end;
    finally
      LPublicKey.Free;
    end;
  finally
    LPrivateKey.Free;
  end;
end;

procedure TTHttpJWTRS256Tests.SharedKeysAcrossThreads;
const
  ThreadCount = 8;
  IterationCount = 20;
var
  LPrivateKey: TTHttpJWTRSAPrivateKey;
  LPublicKey: TTHttpJWTRSAPublicKey;
  LThreads: TArray<TTestSignVerifyThread>;
  LIndex: Integer;
  LAllSucceeded: Boolean;
begin
  LAllSucceeded := True;
  LPrivateKey := TTHttpJWTRSAPrivateKey.Create(TestPrivateKeyPem);
  try
    LPublicKey := TTHttpJWTRSAPublicKey.Create(TestPublicKeyPem);
    try
      SetLength(LThreads, ThreadCount);
      for LIndex := 0 to ThreadCount - 1 do
        LThreads[LIndex] := TTestSignVerifyThread.Create(
          LPrivateKey, LPublicKey, IterationCount);
      try
        for LIndex := 0 to ThreadCount - 1 do
          LThreads[LIndex].Start;

        for LIndex := 0 to ThreadCount - 1 do
        begin
          LThreads[LIndex].WaitFor;
          if not LThreads[LIndex].Success then
            LAllSucceeded := False;
        end;
      finally
        for LIndex := 0 to ThreadCount - 1 do
          LThreads[LIndex].Free;
      end;
    finally
      LPublicKey.Free;
    end;
  finally
    LPrivateKey.Free;
  end;

  Assert.IsTrue(LAllSucceeded,
    'One key instance must sign and verify from several threads at once');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpJWTRS256Tests);

end.
