(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Authentication;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.NetEncoding,
  IdCustomHTTPServer,
  DUnitX.TestFramework,

  Trysil.Http.Consts,
  Trysil.Http.Classes,
  Trysil.Http.Exceptions,
  Trysil.Http.Authentication,
  Trysil.Http.Authentication.Basic,
  Trysil.Http.Authentication.Bearer,
  Trysil.Http.JWT,

  Trysil.Tests.Http.JWT,
  Trysil.Tests.Http.Harness;

type

{ TTestAuthContext }

  TTestAuthContext = class
  end;

{ TTestBasicAuthentication }

  TTestBasicAuthentication = class(TTHttpAuthenticationBasic<TTestAuthContext>)
  strict private
    FCalled: Boolean;
  strict protected
    function IsValid(const AUser: TTHttpUser): Boolean; override;
  public
    property Called: Boolean read FCalled;
  end;

{ TTestBearerAuthentication }

  TTestBearerAuthentication = class(
    TTHttpAuthenticationBearer<TTestAuthContext, TTestJWTPayload>)
  strict private
    FCalled: Boolean;
  strict protected
    function CreatePayload: TTestJWTPayload; override;
    function IsValid(const APayload: TTestJWTPayload): Boolean; override;
  public
    property Called: Boolean read FCalled;
  end;

{ TTHttpAuthenticationTests }

  [TestFixture]
  TTHttpAuthenticationTests = class
  strict private
    const Realm: String = 'Trysil';
    const Username: String = 'david';
    const Password: String = 'secret';
  strict private
    FContext: TTestAuthContext;
    FBasic: TTestBasicAuthentication;
    FBearer: TTestBearerAuthentication;
    FMessage: TTestHttpMessage;

    function BasicCredentials(
      const AUsername: String; const APassword: String): String;
    function NewToken(const AUsername: String): String;

    function CheckBasic: Integer;
    function CheckBearer: Integer;
    function ChallengeHeader: String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure BasicWithoutTheHeaderAnswersUnauthorized;

    [Test]
    procedure BasicWithAnotherSchemeAnswersUnauthorized;

    [Test]
    procedure BasicChallengesWithTheRealm;

    [Test]
    procedure BasicDoesNotAskTheApplicationWhenUnauthorized;

    [Test]
    procedure BasicWithoutASeparatorAnswersForbidden;

    [Test]
    procedure BasicOutsideTheBase64AlphabetIsForbidden;

    [Test]
    procedure BasicWithCredentialsThatAreNotTextIsRefused;

    [Test]
    procedure BasicWithWrongCredentialsAnswersForbidden;

    [Test]
    procedure BasicWithValidCredentialsPassesTheUserOn;

    [Test]
    procedure BasicReadsAPasswordThatHoldsASeparator;

    [Test]
    procedure BearerWithoutTheHeaderAnswersUnauthorized;

    [Test]
    procedure BearerWithAnotherSchemeAnswersUnauthorized;

    [Test]
    procedure BearerWithATokenThatDoesNotLoadAnswersForbidden;

    [Test]
    procedure BearerDoesNotAskTheApplicationForABadToken;

    [Test]
    procedure BearerWithAValidTokenPassesThePayloadOn;

    [Test]
    procedure TheSchemeNameIsMatchedWithoutCase;
  end;

implementation

{ TTestBasicAuthentication }

function TTestBasicAuthentication.IsValid(const AUser: TTHttpUser): Boolean;
begin
  FCalled := True;
  result := AUser.Username.Equals('david') and
    AUser.Password.Equals('secret');
end;

{ TTestBearerAuthentication }

function TTestBearerAuthentication.CreatePayload: TTestJWTPayload;
begin
  result := TTestJWTPayload.Create;
end;

function TTestBearerAuthentication.IsValid(
  const APayload: TTestJWTPayload): Boolean;
begin
  FCalled := True;
  result := APayload.Username.Equals('david');
end;

{ TTHttpAuthenticationTests }

procedure TTHttpAuthenticationTests.Setup;
begin
  FContext := TTestAuthContext.Create;
  FBasic := TTestBasicAuthentication.Create(FContext);
  FBasic.Realm := Realm;
  FBearer := TTestBearerAuthentication.Create(FContext);
  FMessage := TTestHttpMessage.Create(
    '/customers', THTTPCommandType.hcGET, String.Empty);
end;

procedure TTHttpAuthenticationTests.TearDown;
begin
  FMessage.Free;
  FBearer.Free;
  FBasic.Free;
  FContext.Free;
end;

function TTHttpAuthenticationTests.BasicCredentials(
  const AUsername: String; const APassword: String): String;
begin
  result := TNetEncoding.Base64.Encode(
    Format('%s:%s', [AUsername, APassword]));
end;

function TTHttpAuthenticationTests.NewToken(
  const AUsername: String): String;
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

function TTHttpAuthenticationTests.CheckBasic: Integer;
begin
  result := 0;
  try
    FBasic.Check(FMessage.Request, FMessage.Response);
  except
    on E: ETHttpException do
      result := E.StatusCode;
  end;
end;

function TTHttpAuthenticationTests.CheckBearer: Integer;
begin
  result := 0;
  try
    FBearer.Check(FMessage.Request, FMessage.Response);
  except
    on E: ETHttpException do
      result := E.StatusCode;
  end;
end;

function TTHttpAuthenticationTests.ChallengeHeader: String;
begin
  result := FMessage.ResponseInfo.CustomHeaders.Values['WWW-Authenticate'];
end;

procedure TTHttpAuthenticationTests.BasicWithoutTheHeaderAnswersUnauthorized;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    CheckBasic,
    'A request with no Authorization header must be answered 401');
end;

procedure TTHttpAuthenticationTests.BasicWithAnotherSchemeAnswersUnauthorized;
begin
  FMessage.SetRequestHeader('Authorization', 'Bearer a.b.c');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    CheckBasic,
    'A credential of another scheme is a missing credential, not a wrong one');
end;

procedure TTHttpAuthenticationTests.BasicChallengesWithTheRealm;
begin
  CheckBasic;

  Assert.AreEqual(
    Format('Basic realm="%s"', [Realm]),
    ChallengeHeader,
    'A 401 must carry the challenge that says how to authenticate');
end;

procedure
  TTHttpAuthenticationTests.BasicDoesNotAskTheApplicationWhenUnauthorized;
begin
  CheckBasic;

  Assert.IsFalse(
    FBasic.Called,
    'A request with no credential must not reach the application');
end;

procedure TTHttpAuthenticationTests.BasicWithoutASeparatorAnswersForbidden;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('Basic %s', [TNetEncoding.Base64.Encode('davidsecret')]));

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    CheckBasic,
    'A credential with no colon is a credential that cannot be right');
end;

procedure TTHttpAuthenticationTests.BasicOutsideTheBase64AlphabetIsForbidden;
begin
  FMessage.SetRequestHeader('Authorization', 'Basic ~~~not~base64~~~');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    CheckBasic,
    'A malformed credential is the client fault, and must never be a 500');
end;

procedure TTHttpAuthenticationTests.BasicWithCredentialsThatAreNotTextIsRefused;
begin
  FMessage.SetRequestHeader('Authorization', 'Basic //8=');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    CheckBasic,
    'Well formed base64 whose bytes are not UTF-8 is still the client fault');
end;

procedure TTHttpAuthenticationTests.BasicWithWrongCredentialsAnswersForbidden;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('Basic %s', [BasicCredentials(Username, 'wrong')]));

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    CheckBasic,
    'A credential that is understood and wrong is 403, not 401');
end;

procedure TTHttpAuthenticationTests.BasicWithValidCredentialsPassesTheUserOn;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('Basic %s', [BasicCredentials(Username, Password)]));

  Assert.AreEqual<Integer>(0, CheckBasic, 'A valid credential must pass');
  Assert.IsTrue(FBasic.Called, 'The application decides, and must be asked');
  Assert.AreEqual(
    Username,
    FMessage.Request.User.Username,
    'The user the application validated is the one on the request');
end;

procedure TTHttpAuthenticationTests.BasicReadsAPasswordThatHoldsASeparator;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('Basic %s', [BasicCredentials(Username, 'a:b')]));

  CheckBasic;

  Assert.AreEqual(
    'a:b',
    FMessage.Request.User.Password,
    'Only the first colon separates: a password may contain more');
end;

procedure TTHttpAuthenticationTests.BearerWithoutTheHeaderAnswersUnauthorized;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    CheckBearer,
    'A request with no Authorization header must be answered 401');
end;

procedure TTHttpAuthenticationTests.BearerWithAnotherSchemeAnswersUnauthorized;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('Basic %s', [BasicCredentials(Username, Password)]));

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    CheckBearer,
    'A credential of another scheme is a missing credential, not a wrong one');
end;

procedure
  TTHttpAuthenticationTests.BearerWithATokenThatDoesNotLoadAnswersForbidden;
begin
  FMessage.SetRequestHeader('Authorization', 'Bearer not.a.token');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    CheckBearer,
    'A token that does not verify is 403: the credential was understood');
end;

procedure TTHttpAuthenticationTests.BearerDoesNotAskTheApplicationForABadToken;
begin
  FMessage.SetRequestHeader('Authorization', 'Bearer not.a.token');

  CheckBearer;

  Assert.IsFalse(
    FBearer.Called,
    'A token that does not verify must not reach the application');
end;

procedure TTHttpAuthenticationTests.BearerWithAValidTokenPassesThePayloadOn;
begin
  FMessage.SetRequestHeader(
    'Authorization', Format('Bearer %s', [NewToken(Username)]));

  Assert.AreEqual<Integer>(0, CheckBearer, 'A valid token must pass');
  Assert.IsTrue(FBearer.Called, 'The application decides, and must be asked');
end;

procedure TTHttpAuthenticationTests.TheSchemeNameIsMatchedWithoutCase;
begin
  FMessage.SetRequestHeader(
    'Authorization',
    Format('basic %s', [BasicCredentials(Username, Password)]));

  Assert.AreEqual<Integer>(
    0,
    CheckBasic,
    'RFC 7235 says the scheme name is case-insensitive');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpAuthenticationTests);

end.
