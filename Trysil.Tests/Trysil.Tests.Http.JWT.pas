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

  Trysil.Http.JWT;

type

{ TTestJWTPayload }

  TTestJWTPayload = class(TTHttpJWTAbstractPayload)
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

{ TTHttpJWTTests }

  [TestFixture]
  TTHttpJWTTests = class
  public
    [Test]
    procedure TokenHasThreeParts;

    [Test]
    procedure TokenRoundTrip;

    [Test]
    procedure InvalidTokenReturnsFalse;

    [Test]
    procedure TamperedTokenReturnsFalse;
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

{ TTHttpJWTTests }

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

initialization
  TDUnitX.RegisterTestFixture(TTHttpJWTTests);

end.
