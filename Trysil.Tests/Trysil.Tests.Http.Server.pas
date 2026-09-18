(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Server;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.JSon,
  System.Generics.Collections,
  DUnitX.TestFramework,
  IdCustomHTTPServer,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.JSon.Exceptions,

  Trysil.Http,

  Trysil.Http.Consts,
  Trysil.Http.Types,
  Trysil.Http.Classes,
  Trysil.Http.Controller,
  Trysil.Http.Attributes,
  Trysil.Http.Authentication,
  Trysil.Http.Cors,
  Trysil.Http.Log,
  Trysil.Http.Rtti,
  Trysil.Http.Listener,
  Trysil.Http.Exceptions,

  Trysil.Tests.Http.Harness;

type

{ TTestHttpContext }

  TTestHttpContext = class
  end;

{ TTestProtectedController }

  TTestProtectedController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestAnonymousController }

  TTestAnonymousController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    procedure Get;
  end;

{ TTestAreaController }

  TTestAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TArea('admin')]
    procedure Get;
  end;

{ TTestAnonymousAreaController }

  TTestAnonymousAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    [TArea('admin')]
    procedure Get;
  end;

{ TTestClassAreaController }

  [TArea('admin')]
  TTestClassAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestBaseAreaController }

  [TArea('admin')]
  TTestBaseAreaController = class(TTHttpController<TTestHttpContext>)
  end;

{ TTestInheritedAreaController }

  TTestInheritedAreaController = class(TTestBaseAreaController)
  public
    [TGet]
    procedure Get;
  end;

{ TTestPartialAreaController }

  TTestPartialAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;

    [TPost]
    [TArea('admin')]
    procedure Post;
  end;

{ TTestMixedCaseAreaController }

  TTestMixedCaseAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TArea('Admin')]
    procedure Get;
  end;

{ TTestOverloadAreaController }

  TTestOverloadAreaController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    procedure Get; overload;

    [TGet('/?')]
    [TArea('admin')]
    procedure Get(const AID: Integer); overload;
  end;

{ TTestReportController }

  TTestReportController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet('/?')]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    procedure PublicReport(const AID: Integer);

    [TGet('/2024')]
    procedure YearBook;
  end;

{ TTestYearArchiveController }

  TTestYearArchiveController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet('/2024/?')]
    procedure Year(const AID: Integer);

    [TGet('/2024')]
    procedure YearBook;
  end;

{ TTestAnyArchiveController }

  TTestAnyArchiveController = class(TTHttpController<TTestHttpContext>)
  public
    [TDelete('/?/?')]
    procedure Remove(
      const AYear: Integer;
      const AID: Integer);

    [TDelete('/?')]
    procedure RemoveOne(const AID: Integer);
  end;

{ TTestMisplacedParamController }

  TTestMisplacedParamController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet('/?/detail')]
    procedure Detail(const AID: Integer);
  end;

{ TTestConflictController }

  TTestConflictController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestFileController }

  TTestFileController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    [TAuthorizationType(TTHttpAuthorizationType.None)]
    procedure Get;
  end;

{ TTestIntegrityController }

  TTestIntegrityController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestInvalidController }

  TTestInvalidController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestJSonServerFaultController }

  TTestJSonServerFaultController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestJSonBadBodyController }

  TTestJSonBadBodyController = class(TTHttpController<TTestHttpContext>)
  public
    [TGet]
    procedure Get;
  end;

{ TTestAuthentication }

  TTestAuthentication = class(TTHttpAbstractAuthentication<TTestHttpContext>)
  strict private
    class var FGrantedArea: String;
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;

    class property GrantedArea: String read FGrantedArea write FGrantedArea;
  end;

{ TTestDenyingAuthentication }

  TTestDenyingAuthentication = class(
    TTHttpAbstractAuthentication<TTestHttpContext>)
  strict protected
    class function GetName: String; override;
    function GetHeader: String; override;
  public
    procedure Check(
      const ARequest: TTHttpRequest;
      const AResponse: TTHttpResponse); override;
  end;

{ TTHttpServerStartTests }

  [TestFixture]
  TTHttpServerStartTests = class
  strict private
    FServer: TTHttpServer<TTestHttpContext>;
    FStartError: String;

    function TryStart: Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure StartRefusesAProtectedRouteWithoutAuthentication;

    [Test]
    procedure AllowAnonymousLetsAProtectedRouteStart;

    [Test]
    procedure AnAnonymousRouteDoesNotRequireAuthentication;

    [Test]
    procedure StartRefusesAnAreaWithoutAuthentication;

    [Test]
    procedure AnAreaStartsWhenAuthenticationIsRegistered;

    [Test]
    procedure StartRefusesAnAreaOnAnAnonymousRoute;

    [Test]
    procedure StartRefusesAnAreaDeclaredOnTheClass;

    [Test]
    procedure StartRefusesAnAreaInheritedFromABaseClass;

    [Test]
    procedure StartRefusesAnAreaOnOneMethodOfTwo;

    [Test]
    procedure AnAreaDoesNotSpreadToAnOverload;

    [Test]
    procedure BaseUriRefusesAnAddress;

    [Test]
    procedure BaseUriAcceptsAPathPrefix;
  end;

{ TTHttpListenerTests }

  [TestFixture]
  TTHttpListenerTests = class
  strict private
    FCors: TTHttpCors;
    FLog: TTHttpLog;
    FRttiControllers: TTHttpRttiControllers<TTestHttpContext>;
    FControllers: TObjectList<TTHttpRttiController<TTestHttpContext>>;
    FRttiAuthentication: TTHttpRttiAuthentication<TTestHttpContext>;
    FListener: TTHttpListener<TTestHttpContext>;

    procedure RegisterController(
      const ATypeInfo: PTypeInfo; const AUri: String);
    procedure GrantArea(const AArea: String);
    procedure DenyAuthentication;
    function PreflightHeaders(const AUri: String): String;
    function BodyOf(const AUri: String): String;
    function StatusOf(const AUri: String): Integer; overload;
    function StatusOf(
      const AUri: String;
      const ACommandType: THTTPCommandType): Integer; overload;
    function StatusOf(
      const AUri: String;
      const ACommandType: THTTPCommandType;
      const ASentMethod: String): Integer; overload;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnAreaDeniesWithoutAuthentication;

    [Test]
    procedure AConcurrentUpdateAnswersConflict;

    [Test]
    procedure AValidationFailureAnswersUnprocessableContent;

    [Test]
    procedure ABrokenSchemaIsAServerFaultAndSaysNothingElse;

    [Test]
    procedure AJSonFaultOfTheServerAnswers500AndABadBody400;

    [Test]
    procedure AnAreaTheUserHoldsIsServed;

    [Test]
    procedure AnAreaComparisonIgnoresCase;

    [Test]
    procedure AnAreaTheUserDoesNotHoldIsDenied;

    [Test]
    procedure AnUnsupportedMethodAnswersMethodNotAllowed;

    [Test]
    procedure AnAreaOnTheControllerClassIsCheckedAtRuntime;

    [Test]
    procedure AnAreaDeclaredInMixedCaseIsMatched;

    [Test]
    procedure AFreeParametrizedRouteDoesNotCoverAProtectedSibling;

    [Test]
    procedure AFreeParametrizedRouteStaysFree;

    [Test]
    procedure AnUnknownRouteAnswersUnauthorizedToAnAnonymousCaller;

    [Test]
    procedure AnErrorDoesNotInheritTheContentTypeOfTheHandler;

    [Test]
    procedure AMethodNotAllowedSaysWhichMethodsAre;

    [Test]
    procedure AnOverlappingRouteIsReachedByItsOwnMethod;

    [Test]
    procedure AnOverlappingRouteDoesNotHideItsSibling;

    [Test]
    procedure APlaceholderBeforeAFixedSegmentIsRefused;

    [Test]
    procedure AnAddressThatDoesNotAnswerFallsBackToAPattern;

    [Test]
    procedure AMethodCarriedInAHeaderIsRefused;

    [Test]
    procedure AMethodOverrideIsServedWhenTheServerAllowsIt;

    [Test]
    procedure APercentEncodedPathReachesItsRoute;

    [Test]
    procedure AnEncodedSlashDoesNotSplitAPathSegment;

    [Test]
    procedure APreflightAnswersTheSameForEveryRoute;

    [Test]
    procedure APreflightCarriesMaxAge;

    [Test]
    procedure APreflightListsEveryMethodOnEveryRoute;

    [Test]
    procedure AMalformedBodyIsRefusedInsteadOfReadAsEmpty;

    [Test]
    procedure AnEmptyBodyIsStillAnEmptyObject;

    [Test]
    procedure AQueryStringIsNotABody;

    [Test]
    procedure AByteOrderMarkIsNotPartOfTheBody;

    [Test]
    procedure APreflightIsNotAuthenticated;

    [Test]
    procedure APreflightDoesNotReachTheController;

    [Test]
    procedure AConflictCarriesTheStatusAndTheReason;

    [Test]
    procedure AValidationFailureCarriesTheStatusAndTheReason;
  end;

{ TTHttpCappedStreamTests }

  [TestFixture]
  TTHttpCappedStreamTests = class
  public
    [Test]
    procedure ABodyUnderTheCeilingIsRead;

    [Test]
    procedure ABodyOverTheCeilingIsRefused;

    [Test]
    procedure NoCeilingIsStillABoundedStream;
  end;

{ TTHttpResponseHeaderTests }

  [TestFixture]
  TTHttpResponseHeaderTests = class
  strict private
    FServerHeader: String;

    function ServerOf: String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure ByDefaultTheResponseNamesTrysil;

    [Test]
    procedure TheServerHeaderCanBeReplaced;

    [Test]
    procedure TheServerHeaderCanBeSuppressed;
  end;

implementation

{ TTestProtectedController }

procedure TTestProtectedController.Get;
begin
end;

{ TTestAnonymousController }

procedure TTestAnonymousController.Get;
begin
end;

{ TTestAreaController }

procedure TTestAreaController.Get;
begin
end;

{ TTestAnonymousAreaController }

procedure TTestAnonymousAreaController.Get;
begin
end;

{ TTestAuthentication }

class function TTestAuthentication.GetName: String;
begin
  result := 'Bearer';
end;

function TTestAuthentication.GetHeader: String;
begin
  result := String.Empty;
end;

procedure TTestAuthentication.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  if not FGrantedArea.IsEmpty then
    ARequest.User.Areas.Add(FGrantedArea);
end;

{ TTHttpServerStartTests }

procedure TTHttpServerStartTests.Setup;
begin
  FServer := TTHttpServer<TTestHttpContext>.Create;
  FServer.Port := 0;
end;

procedure TTHttpServerStartTests.TearDown;
begin
  if FServer.Started then
    FServer.Stop;
  FServer.Free;
end;

function TTHttpServerStartTests.TryStart: Boolean;
begin
  result := True;
  FStartError := String.Empty;
  try
    FServer.Start;
  except
    on E: ETHttpServerException do
    begin
      FStartError := E.Message;
      result := False;
    end;
  end;
end;

procedure
  TTHttpServerStartTests.StartRefusesAProtectedRouteWithoutAuthentication;
begin
  FServer.RegisterController<TTestProtectedController>('/protected');

  Assert.IsFalse(
    TryStart,
    'A route that needs authentication with none registered must not start');
  Assert.IsFalse(
    FServer.Started,
    'A refused start must leave nothing listening');
end;

procedure TTHttpServerStartTests.AllowAnonymousLetsAProtectedRouteStart;
begin
  FServer.RegisterController<TTestProtectedController>('/protected');
  FServer.AllowAnonymous := True;

  Assert.IsTrue(
    TryStart,
    'AllowAnonymous is the declared opt-out from the start-up check');
end;

procedure TTHttpServerStartTests.AnAnonymousRouteDoesNotRequireAuthentication;
begin
  FServer.RegisterController<TTestAnonymousController>('/open');

  Assert.IsTrue(
    TryStart,
    'A route marked TTHttpAuthorizationType.None protects nothing');
end;

procedure TTHttpServerStartTests.StartRefusesAnAreaWithoutAuthentication;
begin
  FServer.RegisterController<TTestAreaController>('/admin');
  FServer.AllowAnonymous := True;

  Assert.IsFalse(
    TryStart,
    'Without an authentication class there is no user, so an area ' +
    'restricts nothing and the attribute lies');
  Assert.IsFalse(FServer.Started);
end;

procedure TTHttpServerStartTests.AnAreaStartsWhenAuthenticationIsRegistered;
begin
  FServer.RegisterController<TTestAreaController>('/admin');
  FServer.RegisterAuthentication<TTestAuthentication>();

  Assert.IsTrue(TryStart, 'With an authentication class the area is checked');
end;

procedure TTHttpServerStartTests.StartRefusesAnAreaOnAnAnonymousRoute;
begin
  FServer.RegisterController<TTestAnonymousAreaController>('/admin');
  FServer.RegisterAuthentication<TTestAuthentication>();

  Assert.IsFalse(
    TryStart,
    'Authentication does not run on a route marked None, so its user ' +
    'carries no area and the route answers 403 to everyone forever');
  Assert.IsTrue(
    FStartError.StartsWith('Route /admin'),
    'The refusal must name the offending route');
  Assert.IsFalse(FServer.Started);
end;

{ TTestMixedCaseAreaController }

procedure TTestMixedCaseAreaController.Get;
begin
end;

{ TTestOverloadAreaController }

procedure TTestOverloadAreaController.Get;
begin
end;

procedure TTestOverloadAreaController.Get(const AID: Integer);
begin
end;

{ TTestClassAreaController }

procedure TTestClassAreaController.Get;
begin
end;

{ TTestInheritedAreaController }

procedure TTestInheritedAreaController.Get;
begin
end;

{ TTestPartialAreaController }

procedure TTestPartialAreaController.Get;
begin
end;

procedure TTestPartialAreaController.Post;
begin
end;

{ TTestReportController }

procedure TTestReportController.PublicReport(const AID: Integer);
begin
end;

procedure TTestReportController.YearBook;
begin
end;

{ TTestYearArchiveController }

procedure TTestYearArchiveController.Year(const AID: Integer);
begin
end;

procedure TTestYearArchiveController.YearBook;
begin
end;

{ TTestAnyArchiveController }

procedure TTestAnyArchiveController.Remove(
  const AYear: Integer;
  const AID: Integer);
begin
end;

procedure TTestAnyArchiveController.RemoveOne(const AID: Integer);
begin
end;

{ TTestDenyingAuthentication }

class function TTestDenyingAuthentication.GetName: String;
begin
  result := 'Bearer';
end;

function TTestDenyingAuthentication.GetHeader: String;
begin
  result := String.Empty;
end;

procedure TTestDenyingAuthentication.Check(
  const ARequest: TTHttpRequest;
  const AResponse: TTHttpResponse);
begin
  ResponseUnauthorizedError(ARequest, AResponse);
end;

{ TTestMisplacedParamController }

procedure TTestMisplacedParamController.Detail(const AID: Integer);
begin
end;

{ TTestConflictController }

procedure TTestConflictController.Get;
begin
  raise ETConcurrentUpdateException.Create('Record changed');
end;

{ TTestFileController }

procedure TTestFileController.Get;
begin
  FResponse.ContentType := 'application/pdf';
  FResponse.AddHeader('Content-Disposition', 'attachment; filename=x.pdf');
  raise ETHttpNotFound.Create('No such invoice');
end;

{ TTestIntegrityController }

procedure TTestIntegrityController.Get;
begin
  raise ETDataIntegrityException.Create(
    'Data integrity error: too many records affected.');
end;

{ TTestInvalidController }

procedure TTestInvalidController.Get;
begin
  raise ETValidationException.Create('Name is required');
end;

{ TTestJSonServerFaultController }

procedure TTestJSonServerFaultController.Get;
begin
  raise ETJSonServerException.Create('JSon Serializer not found for TFoo.');
end;

{ TTestJSonBadBodyController }

procedure TTestJSonBadBodyController.Get;
begin
  raise ETJSonException.Create('JSon is not an object.');
end;

procedure TTHttpServerStartTests.StartRefusesAnAreaDeclaredOnTheClass;
begin
  FServer.RegisterController<TTestClassAreaController>('/admin');
  FServer.AllowAnonymous := True;

  Assert.IsFalse(
    TryStart,
    'An area declared on the controller class reaches every one of its ' +
    'methods, and it is collected by different code than the method one');
  Assert.AreEqual(
    TTLanguage.Instance.Translate(SAreasNeedAuthentication),
    FStartError,
    'The refusal must come from the area check, not from the ' +
    'authentication check one line above it');
end;

procedure TTHttpServerStartTests.StartRefusesAnAreaInheritedFromABaseClass;
begin
  FServer.RegisterController<TTestInheritedAreaController>('/admin');
  FServer.AllowAnonymous := True;

  Assert.IsFalse(
    TryStart,
    'An area declared on an ancestor is inherited, so the start-up check ' +
    'must walk the class hierarchy as the router does');
  Assert.AreEqual(
    TTLanguage.Instance.Translate(SAreasNeedAuthentication),
    FStartError);
end;

procedure TTHttpServerStartTests.StartRefusesAnAreaOnOneMethodOfTwo;
begin
  FServer.RegisterController<TTestPartialAreaController>('/items');
  FServer.AllowAnonymous := True;

  Assert.IsFalse(
    TryStart,
    'Two methods share the URI and only one carries the area: the check ' +
    'must look at every method, not at the first of each route');
  Assert.AreEqual(
    TTLanguage.Instance.Translate(SAreasNeedAuthentication),
    FStartError);
end;

procedure TTHttpServerStartTests.AnAreaDoesNotSpreadToAnOverload;
begin
  FServer.RegisterController<TTestOverloadAreaController>('/items');
  FServer.RegisterAuthentication<TTestAuthentication>();

  Assert.IsTrue(
    TryStart,
    Format('An area on one overload must not reach the other, which is ' +
      'anonymous and carries no [TArea] of its own. %s', [FStartError]));
end;

procedure TTHttpServerStartTests.BaseUriRefusesAnAddress;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    FServer.BaseUri := 'http://localhost';
  except
    on E: ETHttpServerException do
      LRaised := True;
  end;

  Assert.IsTrue(
    LRaised,
    'BaseUri is prepended to every route, so an address there registers ' +
    'routes as /http://localhost/api/... and the server answers 404 to ' +
    'everything while looking perfectly started');
end;

procedure TTHttpServerStartTests.BaseUriAcceptsAPathPrefix;
begin
  FServer.BaseUri := 'api';

  Assert.AreEqual(
    '/api',
    FServer.BaseUri,
    'A prefix without the leading slash is still a prefix, and gains one');
end;

{ TTHttpListenerTests }

procedure TTHttpListenerTests.Setup;
begin
  FCors := TTHttpCors.Create;
  FLog := TTHttpLog.Create;
  FRttiControllers := TTHttpRttiControllers<TTestHttpContext>.Create;
  FControllers :=
    TObjectList<TTHttpRttiController<TTestHttpContext>>.Create(True);
  RegisterController(TypeInfo(TTestAreaController), '/admin');
  RegisterController(TypeInfo(TTestConflictController), '/conflict');
  RegisterController(TypeInfo(TTestInvalidController), '/invalid');
  RegisterController(TypeInfo(TTestIntegrityController), '/integrity');
  RegisterController(
    TypeInfo(TTestJSonServerFaultController), '/jsonserverfault');
  RegisterController(TypeInfo(TTestJSonBadBodyController), '/jsonbadbody');
  RegisterController(TypeInfo(TTestClassAreaController), '/classarea');
  RegisterController(TypeInfo(TTestMixedCaseAreaController), '/mixed');
  RegisterController(TypeInfo(TTestReportController), '/report');
  RegisterController(TypeInfo(TTestYearArchiveController), '/archive');
  RegisterController(TypeInfo(TTestAnyArchiveController), '/archive');
  RegisterController(TypeInfo(TTestFileController), '/file');
  FListener := TTHttpListener<TTestHttpContext>.Create(
    FCors, FRttiControllers, FLog);
  FRttiAuthentication := nil;
end;

procedure TTHttpListenerTests.TearDown;
begin
  TTestAuthentication.GrantedArea := String.Empty;
  FListener.Free;
  if Assigned(FRttiAuthentication) then
    FRttiAuthentication.Free;
  FRttiControllers.Free;
  FControllers.Free;
  FLog.Free;
  FCors.Free;
end;

procedure TTHttpListenerTests.GrantArea(const AArea: String);
begin
  TTestAuthentication.GrantedArea := AArea;
  if Assigned(FRttiAuthentication) then
    FRttiAuthentication.Free;
  FRttiAuthentication := TTHttpRttiAuthentication<TTestHttpContext>.Create(
    TypeInfo(TTestAuthentication));
  FRttiAuthentication.CheckValid;
  FListener.SetRttiAuthentication(FRttiAuthentication);
end;

procedure TTHttpListenerTests.DenyAuthentication;
begin
  if Assigned(FRttiAuthentication) then
    FRttiAuthentication.Free;
  FRttiAuthentication := TTHttpRttiAuthentication<TTestHttpContext>.Create(
    TypeInfo(TTestDenyingAuthentication));
  FRttiAuthentication.CheckValid;
  FListener.SetRttiAuthentication(FRttiAuthentication);
end;

procedure TTHttpListenerTests.RegisterController(
  const ATypeInfo: PTypeInfo; const AUri: String);
var
  LRttiController: TTHttpRttiController<TTestHttpContext>;
begin
  LRttiController := TTHttpRttiController<TTestHttpContext>.Create(
    ATypeInfo, AUri);
  FControllers.Add(LRttiController);
  LRttiController.CheckValid;
  FRttiControllers.Add(LRttiController, FCors.RegisterController);
end;

function TTHttpListenerTests.StatusOf(const AUri: String): Integer;
begin
  result := StatusOf(AUri, hcGET);
end;

function TTHttpListenerTests.StatusOf(
  const AUri: String;
  const ACommandType: THTTPCommandType): Integer;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(AUri, ACommandType, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);
    result := LMessage.Response.StatusCode;
  finally
    LMessage.Free;
  end;
end;

function TTHttpListenerTests.StatusOf(
  const AUri: String;
  const ACommandType: THTTPCommandType;
  const ASentMethod: String): Integer;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(
    AUri, ACommandType, String.Empty, ASentMethod);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);
    result := LMessage.Response.StatusCode;
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AnAreaDeniesWithoutAuthentication;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    StatusOf('/admin'),
    'A listener built by hand with no authentication used to serve an ' +
    'area to an anonymous caller: the check was inside the guard');
end;

procedure TTHttpListenerTests.AConcurrentUpdateAnswersConflict;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Conflict,
    StatusOf('/conflict'),
    'A row that moved under the caller is the caller''s problem to ' +
    'resolve, not a server failure');
end;

procedure TTHttpListenerTests.AValidationFailureAnswersUnprocessableContent;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.UnprocessableContent,
    StatusOf('/invalid'),
    'A body the entity refuses used to answer 500, so a client could ' +
    'only retry the same request forever');
end;

procedure TTHttpListenerTests.ABrokenSchemaIsAServerFaultAndSaysNothingElse;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create('/integrity', hcGET, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);

    Assert.AreEqual<Integer>(
      TTHttpStatusCodeTypes.InternalServerError,
      LMessage.Response.StatusCode,
      'A single-row command that touched more than one row means the key ' +
      'is not unique: the caller asked for nothing wrong and there is ' +
      'nothing it can do about it, so it is a 500 and not a 4xx');
    Assert.IsFalse(
      LMessage.Response.Content.Contains('integrity'),
      'And the body of a 500 stays the constant one with the task id: ' +
      'what the database said about the schema is for the log');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AJSonFaultOfTheServerAnswers500AndABadBody400;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(
    '/jsonserverfault', hcGET, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);

    Assert.AreEqual<Integer>(
      TTHttpStatusCodeTypes.InternalServerError,
      LMessage.Response.StatusCode,
      'ETJSonServerException derives from ETJSonException, and the '
      + 'listener mapped the whole of the base to 400: a serializer the '
      + 'host never registered told the client its request was wrong. The '
      + 'branch for the derived class has to come first, or it is never '
      + 'reached');
    Assert.IsFalse(
      LMessage.Response.Content.Contains('TFoo'),
      'and the body of that 500 is the constant one: the name of the type '
      + 'the old 400 exposed is for the log');
  finally
    LMessage.Free;
  end;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.BadRequest,
    StatusOf('/jsonbadbody'),
    'A body the deserializer cannot read is still the caller''s fault');
end;

procedure TTHttpListenerTests.AnAreaTheUserHoldsIsServed;
begin
  GrantArea('admin');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/admin'),
    'A user carrying the area the route requires must reach the method');
end;

procedure TTHttpListenerTests.AnAreaComparisonIgnoresCase;
begin
  GrantArea('ADMIN');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/admin'),
    'Areas are compared in lower case on both sides, so the case a claim ' +
    'happens to carry cannot lock a user out');
end;

procedure TTHttpListenerTests.AnAreaTheUserDoesNotHoldIsDenied;
begin
  GrantArea('reader');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    StatusOf('/admin'),
    'An authenticated user without the area is refused');
end;

procedure TTHttpListenerTests.AnAreaDeclaredInMixedCaseIsMatched;
begin
  GrantArea('admin');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/mixed'),
    'The attribute is lower cased when it is collected and the claim is ' +
    'lower cased when it is added, so neither side decides the case');
end;

procedure TTHttpListenerTests.AnUnsupportedMethodAnswersMethodNotAllowed;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.MethodNotAllowed,
    StatusOf('/conflict', hcHEAD),
    'The router knows five methods, and a request carrying another one ' +
    'must not reach the generic branch: the first read of MethodType has ' +
    'to stay inside the try of HandleRequest');
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.MethodNotAllowed,
    StatusOf('/conflict', hcTRACE));
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.MethodNotAllowed,
    StatusOf('/conflict', hcPATCH));
end;

procedure TTHttpListenerTests.AnAreaOnTheControllerClassIsCheckedAtRuntime;
begin
  GrantArea('reader');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Forbidden,
    StatusOf('/classarea'),
    'An area declared on the controller class is collected by different ' +
    'code than one on the method, and it must reach CheckAreas the same');
end;

procedure
  TTHttpListenerTests.AFreeParametrizedRouteDoesNotCoverAProtectedSibling;
begin
  DenyAuthentication;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    StatusOf('/report/2024'),
    'The free route /report/? matches 2024 segment by segment, but the ' +
    'router resolves /report/2024 to its own protected method: whether a ' +
    'request is authenticated has to be decided on the route that will ' +
    'actually run');
end;

procedure TTHttpListenerTests.AFreeParametrizedRouteStaysFree;
begin
  DenyAuthentication;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/report/7'),
    'Reading the authorization from the resolved method must not close a ' +
    'route that declares itself anonymous');
end;

procedure
  TTHttpListenerTests.AnUnknownRouteAnswersUnauthorizedToAnAnonymousCaller;
begin
  DenyAuthentication;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.Unauthorized,
    StatusOf('/nothing'),
    'Resolving the route first must not turn the uniform 401 into a 404 ' +
    'that tells an anonymous caller which routes exist');
end;

procedure TTHttpListenerTests.AnErrorDoesNotInheritTheContentTypeOfTheHandler;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create('/file', hcGET, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);

    Assert.AreEqual<Integer>(
      TTHttpStatusCodeTypes.NotFound,
      LMessage.Response.StatusCode,
      'Precondition: the handler raises after setting up a file download');
    Assert.AreEqual(
      TTHttpContentTypes.JSon,
      LMessage.Response.ContentType,
      'The body of an error is JSON, and the content type of the download ' +
      'the handler was preparing used to survive it: the client saved a ' +
      'PDF holding an error message');
    Assert.IsTrue(
      LMessage.ResponseInfo.CustomHeaders.Values[
        'Content-Disposition'].IsEmpty,
      'And so did the headers, so the browser was still told to save the ' +
      'response as a file');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AMethodNotAllowedSaysWhichMethodsAre;
var
  LMessage: TTestHttpMessage;
  LAllow: String;
begin
  LMessage := TTestHttpMessage.Create('/conflict', hcPUT, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);
    LAllow := LMessage.ResponseInfo.CustomHeaders.Values['Allow'];

    Assert.AreEqual<Integer>(
      TTHttpStatusCodeTypes.MethodNotAllowed,
      LMessage.Response.StatusCode,
      'Precondition: the route exists but does not answer PUT');
    Assert.IsFalse(
      LAllow.IsEmpty,
      'A 405 has to carry Allow - it is what tells the client which ' +
      'methods to use - and the router had the list in its hand when it ' +
      'decided to refuse');
    Assert.IsTrue(
      LAllow.Contains('GET'),
      'And the list is the one the route actually answers');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AnOverlappingRouteIsReachedByItsOwnMethod;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/archive/2024/7', hcDELETE),
    'Two patterns match /archive/2024/7 and only one of them answers ' +
    'DELETE: stopping at the first match found leaves the route that ' +
    'does answer unreachable, and the caller reads a 405 about a method ' +
    'the application does implement');
end;

procedure TTHttpListenerTests.AnOverlappingRouteDoesNotHideItsSibling;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/archive/2024/7'),
    'And the search that keeps looking for the verb must still resolve ' +
    'the method the other pattern carries');
end;

procedure TTHttpListenerTests.AnAddressThatDoesNotAnswerFallsBackToAPattern;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/archive/2024', hcDELETE),
    'The literal route /archive/2024 answers GET only, and /archive/? ' +
    'answers DELETE: an address that matches a route the method does not ' +
    'reach is not a 405 while another route does reach it');
end;

procedure TTHttpListenerTests.AMethodCarriedInAHeaderIsRefused;
begin
  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.BadRequest,
    StatusOf('/archive/2024', hcDELETE, 'POST'),
    'Indy turns X-HTTP-Method and its two siblings into the command ' +
    'before Trysil sees the request, so a proxy or a firewall that allows ' +
    'POST and blocks DELETE is walked past with one header. The server ' +
    'refuses the swap unless it has been told to accept it');
end;

procedure TTHttpListenerTests.AMethodOverrideIsServedWhenTheServerAllowsIt;
begin
  FListener.AllowMethodOverride := True;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/archive/2024', hcDELETE, 'POST'),
    'A client that can only send POST is a real constraint, so the ' +
    'override stays available - as a decision the application makes, not ' +
    'as a default nobody chose');
end;

procedure TTHttpListenerTests.APlaceholderBeforeAFixedSegmentIsRefused;
var
  LRefused: Boolean;
begin
  LRefused := False;
  try
    RegisterController(
      TypeInfo(TTestMisplacedParamController), '/misplaced');
  except
    on E: ETHttpServerException do
      LRefused := True;
  end;

  Assert.IsTrue(
    LRefused,
    'A placeholder matches any segment, so /misplaced/?/detail overlaps ' +
    'every three-segment address under /misplaced: the router assumes ' +
    'placeholders sit at the end, and a route that breaks the assumption ' +
    'has to be refused where it is written, not answered at random');
end;

procedure TTHttpListenerTests.APercentEncodedPathReachesItsRoute;
begin
  GrantArea('admin');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/adm%69n'),
    'The router matched the raw request line, so a path that is percent ' +
    'encoded - which any client is free to send - did not resolve to the ' +
    'route it names, and came back 404');
end;

procedure TTHttpListenerTests.AnEncodedSlashDoesNotSplitAPathSegment;
begin
  GrantArea('admin');

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.NotFound,
    StatusOf('/classarea%2Fadmin'),
    'Decoding happens on each segment after the split, so %2F stays inside ' +
    'its segment and cannot invent a path boundary that the client did ' +
    'not send');
end;

function TTHttpListenerTests.PreflightHeaders(const AUri: String): String;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(AUri, hcOPTION, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);
    result := LMessage.ResponseInfo.CustomHeaders.Text;
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AMalformedBodyIsRefusedInsteadOfReadAsEmpty;
var
  LMessage: TTestHttpMessage;
  LStatus: Integer;
begin
  LMessage := TTestHttpMessage.Create(
    '/report', hcPOST, '{"where":[{"column":"Name"');
  try
    LStatus := 0;
    try
      LMessage.Request.JSonContent;
    except
      on E: ETHttpException do
        LStatus := E.StatusCode;
    end;

    Assert.AreEqual<Integer>(
      TTHttpStatusCodeTypes.BadRequest,
      LStatus,
      'A body the parser refuses used to become an empty object, and an ' +
      'empty object is a filter with no condition: a request truncated by ' +
      'the network answered 200 with the whole table');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AnEmptyBodyIsStillAnEmptyObject;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create('/report', hcGET, String.Empty);
  try
    Assert.IsTrue(
      LMessage.Request.JSonContent is TJSonObject,
      'A request that carries no body at all has nothing malformed about ' +
      'it, and a handler reading JSonContent on a GET must still find an ' +
      'empty object rather than a 400');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AByteOrderMarkIsNotPartOfTheBody;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(
    '/report', hcPOST, #$FEFF + '{"where":[]}');
  try
    Assert.IsTrue(
      LMessage.Request.JSonContent is TJSonObject,
      'UTF8.GetString does not remove the byte order mark, Trim does not ' +
      'touch it because it is not below a space, and the parser of the RTL ' +
      'skips only space, tab, CR and LF. So a client that writes one - a ' +
      '.NET or PowerShell client writes one by default - was answered 400 ' +
      'on every request it made');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.AQueryStringIsNotABody;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create('/report', hcGET, String.Empty);
  try
    LMessage.SetQueryString('start=0&limit=50');

    Assert.IsTrue(
      LMessage.Request.JSonContent is TJSonObject,
      'On a GET with no body Indy leaves PostStream unassigned and puts the ' +
      'query string in UnparsedParams, which GetContentText falls back to. ' +
      'So "start=0&limit=50" reached the JSON parser, came back nil, and ' +
      'answered 400: one character more in the URL disabled every endpoint ' +
      'whose handler touches JSonContent');
  finally
    LMessage.Free;
  end;
end;

function TTHttpListenerTests.BodyOf(const AUri: String): String;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create(AUri, hcGET, String.Empty);
  try
    FListener.HandleRequest(LMessage.Request, LMessage.Response);
    result := LMessage.Response.Content;
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpListenerTests.APreflightIsNotAuthenticated;
begin
  DenyAuthentication;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/admin', hcOPTION),
    'A browser sends the preflight before it has any credential to send, ' +
    'so answering it 401 would make every cross-origin call impossible');
end;

procedure TTHttpListenerTests.APreflightDoesNotReachTheController;
begin
  DenyAuthentication;

  Assert.AreEqual<Integer>(
    TTHttpStatusCodeTypes.OK,
    StatusOf('/conflict', hcOPTION),
    'The preflight is answered by the CORS branch and must never run the ' +
    'controller: this one raises, so anything but 200 means the ' +
    'unauthenticated request was executed');
end;

procedure TTHttpListenerTests.AConflictCarriesTheStatusAndTheReason;
var
  LBody: String;
begin
  LBody := BodyOf('/conflict');

  Assert.IsTrue(
    LBody.Contains('"status":409'),
    'A client that reads the body must find the same status the response ' +
    'carries, or it has to parse two contracts');
  Assert.IsTrue(
    LBody.Contains('Record changed'),
    'And the reason the ORM gave, which is the only thing that tells the ' +
    'caller what to do next');
end;

procedure TTHttpListenerTests.AValidationFailureCarriesTheStatusAndTheReason;
var
  LBody: String;
begin
  LBody := BodyOf('/invalid');

  Assert.IsTrue(
    LBody.Contains('"status":422'),
    'A validation failure answers a body shaped like every other error');
  Assert.IsTrue(
    LBody.Contains('Name is required'),
    'The message the validator produced is what the user has to read: ' +
    'asserting the status alone would let it be replaced by anything');
end;

procedure TTHttpListenerTests.APreflightAnswersTheSameForEveryRoute;
var
  LKnown: String;
  LUnknown: String;
begin
  LKnown := PreflightHeaders('/admin');
  LUnknown := PreflightHeaders('/nothing');

  Assert.IsTrue(
    LKnown.Contains('Authorization'),
    'Authorization used to appear only for routes that require it, so two ' +
    'preflights told an anonymous caller which routes are free');
  Assert.AreEqual(
    LKnown,
    LUnknown,
    'And a route that does not exist got no CORS headers at all, which ' +
    'made the preflight an oracle for which routes exist. The browser ' +
    'needs none of that: it sends the preflight and then the real request, ' +
    'where authentication decides');
end;

procedure TTHttpListenerTests.APreflightListsEveryMethodOnEveryRoute;
begin
  Assert.IsTrue(
    PreflightHeaders('/admin').Contains('OPTIONS'),
    'The allowed methods are the whole enumeration, on every route. No ' +
    'controller can register OPTIONS - there is no attribute that produces ' +
    'it - so listing the verbs a route actually answers would have made ' +
    'the presence of OPTIONS a clean "this route does not exist" signal, ' +
    'readable without a credential');
  Assert.AreEqual(
    PreflightHeaders('/admin'),
    PreflightHeaders('/report'),
    'And two routes that answer different verbs must still preflight the ' +
    'same way');
end;

procedure TTHttpListenerTests.APreflightCarriesMaxAge;
begin
  Assert.IsTrue(
    PreflightHeaders('/admin').Contains('Access-Control-Max-Age'),
    'Without Max-Age the browser repeats the preflight before every ' +
    'non-simple request, which doubles the round trips of the whole ' +
    'application');
end;

{ TTHttpCappedStreamTests }

procedure TTHttpCappedStreamTests.ABodyUnderTheCeilingIsRead;
var
  LStream: TTHttpCappedStream;
  LBuffer: TBytes;
begin
  SetLength(LBuffer, 1000);
  LStream := TTHttpCappedStream.Create(65536);
  try
    LStream.Write(LBuffer, Length(LBuffer));

    Assert.AreEqual<Int64>(
      1000,
      LStream.Size,
      'A body the server accepts has to reach the handler untouched');
  finally
    LStream.Free;
  end;
end;

procedure TTHttpCappedStreamTests.ABodyOverTheCeilingIsRefused;
var
  LStream: TTHttpCappedStream;
  LBuffer: TBytes;
  LRefused: Boolean;
begin
  SetLength(LBuffer, 20000);
  LRefused := False;
  LStream := TTHttpCappedStream.Create(1024);
  try
    try
      LStream.Write(LBuffer, Length(LBuffer));
    except
      on E: ETHttpContentTooLarge do
        LRefused := True;
    end;
  finally
    LStream.Free;
  end;

  Assert.IsTrue(
    LRefused,
    'A client that declares a small body and then sends a large one, or ' +
    'sends it chunked and declares no length at all, walks past the ' +
    'check on the headers: the stream Indy reads into is the second ' +
    'line, and it stops growing rather than taking the process down');
end;

procedure TTHttpCappedStreamTests.NoCeilingIsStillABoundedStream;
var
  LStream: TTHttpCappedStream;
  LBuffer: TBytes;
  LRefused: Boolean;
begin
  SetLength(LBuffer, 20000);
  LRefused := False;
  LStream := TTHttpCappedStream.Create(High(Int64));
  try
    try
      LStream.Write(LBuffer, Length(LBuffer));
    except
      on E: ETHttpContentTooLarge do
        LRefused := True;
    end;
  finally
    LStream.Free;
  end;

  Assert.IsFalse(
    LRefused,
    'The server hands this stream over only when a ceiling is set, and a ' +
    'ceiling nothing can reach must not refuse anything');
end;

{ TTHttpResponseHeaderTests }

procedure TTHttpResponseHeaderTests.Setup;
begin
  FServerHeader := TTHttpResponse.ServerHeader;
end;

procedure TTHttpResponseHeaderTests.TearDown;
begin
  TTHttpResponse.ServerHeader := FServerHeader;
end;

function TTHttpResponseHeaderTests.ServerOf: String;
var
  LMessage: TTestHttpMessage;
begin
  LMessage := TTestHttpMessage.Create('/', hcGET, String.Empty);
  try
    result := LMessage.ResponseInfo.Server;
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpResponseHeaderTests.ByDefaultTheResponseNamesTrysil;
begin
  Assert.AreEqual(
    TTHttpServerHeader.Default,
    ServerOf,
    'What the header said before it could be changed is what it still ' +
    'says when nobody changes it');
end;

procedure TTHttpResponseHeaderTests.TheServerHeaderCanBeReplaced;
begin
  TTHttpResponse.ServerHeader := 'Acme/1.0';

  Assert.AreEqual('Acme/1.0', ServerOf, 'The host decides what it is called');
end;

procedure TTHttpResponseHeaderTests.TheServerHeaderCanBeSuppressed;
begin
  TTHttpResponse.ServerHeader := String.Empty;

  Assert.AreEqual(
    String.Empty,
    ServerOf,
    'The name of the framework and the address of its repository used to ' +
    'go out on every response of every application, and there was no way ' +
    'to stop it');
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpServerStartTests);
  TDUnitX.RegisterTestFixture(TTHttpListenerTests);
  TDUnitX.RegisterTestFixture(TTHttpCappedStreamTests);
  TDUnitX.RegisterTestFixture(TTHttpResponseHeaderTests);

end.
