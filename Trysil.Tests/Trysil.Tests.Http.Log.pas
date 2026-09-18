(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Http.Log;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.TypInfo,
  System.JSON,
  DUnitX.TestFramework,
  IdCustomHTTPServer,

  Trysil.Http,
  Trysil.Http.Rtti,
  Trysil.Http.Classes,
  Trysil.Http.Exceptions,
  Trysil.Http.Log.Types,
  Trysil.Http.Log.Classes,
  Trysil.Http.Log.Writer,
  Trysil.Http.Log.Threading,

  Trysil.Tests.Http.Harness;

type

{ TTestLogWriterState }

  TTestLogWriterState = class
  strict private
    class var FCreateFails: Boolean;
    class var FWritten: TEvent;
    class var FAttempted: TEvent;

    class constructor Create;
    class destructor Destroy;
  public
    class procedure Reset(const ACreateFails: Boolean);
    class procedure CreateMustFail(const AValue: Boolean);
    class function CreateFails: Boolean;
    class procedure SignalWritten;
    class function WaitWritten(const ATimeout: Cardinal): Boolean;
    class procedure SignalAttempted;
    class function WaitAttempted(const ATimeout: Cardinal): Boolean;
  end;

{ TTestFailingLogWriter }

  TTestFailingLogWriter = class(TTHttpLogAbstractWriter)
  public
    constructor Create;
    procedure WriteAction(const AAction: TTHttpLogAction); override;
    procedure WriteRequest(const ALogRequest: TTHttpLogRequest); override;
    procedure WriteResponse(const ALogResponse: TTHttpLogResponse); override;
  end;

{ TTestLogContext }

  TTestLogContext = class
  end;

{ TTHttpLogRegistrationTests }

  [TestFixture]
  TTHttpLogRegistrationTests = class
  strict private
    FServer: TTHttpServer<TTestLogContext>;

    function TryRegister: Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure RegisterAcceptsAWriterThatCanBeCreated;

    [Test]
    procedure RegisterRefusesAWriterThatCannotBeCreated;
  end;

{ TTHttpLogThreadTests }

  [TestFixture]
  TTHttpLogThreadTests = class
  strict private
    function CreateRttiLogWriter: TTHttpRttiLogWriter;
  public
    [Test]
    procedure ALogThreadSurvivesAWriterThatCannotBeCreated;

    [Test]
    procedure ALogThreadWritesOnceTheWriterCanBeCreated;
  end;

{ TTHttpLogTests }

  [TestFixture]
  TTHttpLogTests = class
  strict private
    const TurkishLCID = $041F;
  strict private
    function NewHeaders(
      const AName: String; const AValue: String): TTHttpHeaders;
    function LoggedValue(
      const AName: String;
      const AValue: String;
      const ARedact: Boolean): String;
    function RedactEverything: TFunc<TTHttpRequest, String, String>;
  public
    [Test]
    procedure LogActionToJSonContainsFields;

    [Test]
    procedure LogActionPreservesTaskIdAndAction;

    [Test]
    procedure LogParametersUnlimitedContentAcceptsAnyLength;

    [Test]
    procedure TheShortConstructorsDoNotReopenContentCapture;

    [Test]
    procedure AnUnsetRecordStillHasAThreadAndAQueue;

    [Test]
    procedure LogParametersRejectsContentAboveTheCap;

    [Test]
    procedure LogDiscardedCarriesHostAndCount;

    [Test]
    procedure LogQueueIsEmptyAfterCreate;

    [Test]
    procedure LogQueueAcceptsUpToCapacity;

    [Test]
    procedure LogQueueDiscardsAboveCapacityAndCountsThem;

    [Test]
    procedure LogQueueNeverDiscardsAnError;

    [Test]
    procedure LogQueueTakeDiscardedResetsTheCounter;

    [Test]
    procedure LogQueueWithNegativeCapacityIsUnbounded;

    [Test]
    procedure LogQueueCarriesErrorEntries;

    [Test]
    procedure LogQueueSanitizesTheDiscardedHost;

    [Test]
    procedure LogParametersUnlimitedItemsNeedsANegativeCap;

    [Test]
    procedure LogParametersRejectsItemsAboveTheCap;

    [Test]
    procedure LogRequestKeepsContentThatIsNotJSon;

    [Test]
    procedure RedactedHeadersAreReplacedByAPlaceholder;

    [Test]
    procedure ARedactedHeaderIsRecognisedWhateverTheLocale;

    [Test]
    procedure UnredactedHeadersKeepTheirValue;

    [Test]
    procedure AParameterNameThatCarriesASecretIsRedacted;

    [Test]
    procedure ASecretInTheQueryStringIsRedacted;

    [Test]
    procedure AnApplicationCanNameItsOwnSecret;

    [Test]
    procedure TheListIsClosedWhileAServerIsRunning;

    [Test]
    procedure RedactionIsAskedForExplicitly;

    [Test]
    procedure TheRequestBodyGoesThroughTheRedactionHook;

    [Test]
    procedure TheResponseBodyGoesThroughTheRedactionHook;

    [Test]
    procedure TheResponseCarriesTheTenantTheHostWroteOnTheUser;

    [Test]
    procedure WithoutAHookTheRequestBodyIsLoggedAsItIs;

    [Test]
    procedure AnUnreadableBodyCostsTheBodyAndNotTheLine;
  end;

implementation

{ TTestLogWriterState }

class constructor TTestLogWriterState.Create;
begin
  FCreateFails := False;
  FWritten := TEvent.Create(nil, True, False, String.Empty);
  FAttempted := TEvent.Create(nil, True, False, String.Empty);
end;

class destructor TTestLogWriterState.Destroy;
begin
  FAttempted.Free;
  FWritten.Free;
end;

class procedure TTestLogWriterState.Reset(const ACreateFails: Boolean);
begin
  FCreateFails := ACreateFails;
  FWritten.ResetEvent;
  FAttempted.ResetEvent;
end;

class procedure TTestLogWriterState.CreateMustFail(const AValue: Boolean);
begin
  FCreateFails := AValue;
end;

class function TTestLogWriterState.CreateFails: Boolean;
begin
  result := FCreateFails;
end;

class procedure TTestLogWriterState.SignalWritten;
begin
  FWritten.SetEvent;
end;

class function TTestLogWriterState.WaitWritten(
  const ATimeout: Cardinal): Boolean;
begin
  result := FWritten.WaitFor(ATimeout) = TWaitResult.wrSignaled;
end;

class procedure TTestLogWriterState.SignalAttempted;
begin
  FAttempted.SetEvent;
end;

class function TTestLogWriterState.WaitAttempted(
  const ATimeout: Cardinal): Boolean;
begin
  result := FAttempted.WaitFor(ATimeout) = TWaitResult.wrSignaled;
end;

{ TTestFailingLogWriter }

constructor TTestFailingLogWriter.Create;
begin
  inherited Create;
  TTestLogWriterState.SignalAttempted;
  if TTestLogWriterState.CreateFails then
    raise Exception.Create('The log writer cannot be created');
end;

procedure TTestFailingLogWriter.WriteAction(const AAction: TTHttpLogAction);
begin
  TTestLogWriterState.SignalWritten;
end;

procedure TTestFailingLogWriter.WriteRequest(
  const ALogRequest: TTHttpLogRequest);
begin
  TTestLogWriterState.SignalWritten;
end;

procedure TTestFailingLogWriter.WriteResponse(
  const ALogResponse: TTHttpLogResponse);
begin
  TTestLogWriterState.SignalWritten;
end;

{ TTHttpLogRegistrationTests }

procedure TTHttpLogRegistrationTests.Setup;
begin
  FServer := TTHttpServer<TTestLogContext>.Create;
  FServer.Port := 0;
end;

procedure TTHttpLogRegistrationTests.TearDown;
begin
  FServer.Free;
end;

function TTHttpLogRegistrationTests.TryRegister: Boolean;
begin
  result := True;
  try
    FServer.RegisterLogWriter<TTestFailingLogWriter>();
  except
    result := False;
  end;
end;

procedure TTHttpLogRegistrationTests.RegisterAcceptsAWriterThatCanBeCreated;
begin
  TTestLogWriterState.Reset(False);

  Assert.IsTrue(
    TryRegister,
    'A log writer whose constructor runs must be accepted');
end;

procedure TTHttpLogRegistrationTests.RegisterRefusesAWriterThatCannotBeCreated;
begin
  TTestLogWriterState.Reset(True);

  Assert.IsFalse(
    TryRegister,
    'A log writer that cannot be created must fail at registration');

  TTestLogWriterState.CreateMustFail(False);
  Assert.IsTrue(
    TryRegister,
    'A refused registration must leave no writer registered');
end;

{ TTHttpLogThreadTests }

function TTHttpLogThreadTests.CreateRttiLogWriter: TTHttpRttiLogWriter;
begin
  result := TTHttpRttiLogWriter.Create(TypeInfo(TTestFailingLogWriter));
  try
    if not result.CheckValid then
      raise Exception.Create('The test log writer must be valid');
  except
    result.Free;
    raise;
  end;
end;

procedure TTHttpLogThreadTests.ALogThreadSurvivesAWriterThatCannotBeCreated;
var
  LRttiLogWriter: TTHttpRttiLogWriter;
  LThread: TTHttpLogThread;
begin
  TTestLogWriterState.Reset(True);
  LRttiLogWriter := CreateRttiLogWriter;
  try
    LThread := TTHttpLogThread.Create(LRttiLogWriter, 10);
    try
      LThread.Add(Default(TTHttpLogError));

      Assert.IsTrue(
        TTestLogWriterState.WaitAttempted(5000),
        'Precondition: the thread must have tried to build the writer. ' +
        'Sleeping instead would pass on a loaded machine without the ' +
        'failure path ever running');
      Assert.IsFalse(
        LThread.Finished,
        'A writer that cannot be created must not kill the log thread');
      Assert.IsFalse(
        Assigned(LThread.FatalException),
        'The failure belongs on the thread, not parked in it');
    finally
      LThread.Free;
    end;
  finally
    LRttiLogWriter.Free;
  end;
end;

procedure TTHttpLogThreadTests.ALogThreadWritesOnceTheWriterCanBeCreated;
var
  LRttiLogWriter: TTHttpRttiLogWriter;
  LThread: TTHttpLogThread;
begin
  TTestLogWriterState.Reset(True);
  LRttiLogWriter := CreateRttiLogWriter;
  try
    LThread := TTHttpLogThread.Create(LRttiLogWriter, 10);
    try
      Assert.IsTrue(
        TTestLogWriterState.WaitAttempted(5000),
        'Precondition: the thread must have tried and failed once');
      TTestLogWriterState.CreateMustFail(False);
      LThread.Add(Default(TTHttpLogError));

      Assert.IsTrue(
        TTestLogWriterState.WaitWritten(5000),
        'The next cycle must retry the writer and drain the queue');
    finally
      LThread.Free;
    end;
  finally
    LRttiLogWriter.Free;
  end;
end;

{ TTHttpLogTests }

function TTHttpLogTests.NewHeaders(
  const AName: String; const AValue: String): TTHttpHeaders;
var
  LStrings: TStringList;
begin
  result := TTHttpHeaders.Create;
  try
    LStrings := TStringList.Create;
    try
      LStrings.Add(Format('%s=%s', [AName, AValue]));
      result.AddStrings(LStrings);
    finally
      LStrings.Free;
    end;
  except
    result.Free;
    raise;
  end;
end;

function TTHttpLogTests.LoggedValue(
  const AName: String;
  const AValue: String;
  const ARedact: Boolean): String;
var
  LHeaders: TTHttpHeaders;
  LLogged: TTHttpLogNameValues;
  LJSon: TJSonArray;
begin
  LHeaders := NewHeaders(AName, AValue);
  try
    LLogged := TTHttpLogNameValues.Create(LHeaders, ARedact);
    LJSon := LLogged.ToJSonArray;
    try
      result := TJSonObject(LJSon.Items[0]).GetValue<String>('Value');
    finally
      LJSon.Free;
    end;
  finally
    LHeaders.Free;
  end;
end;

procedure TTHttpLogTests.RedactedHeadersAreReplacedByAPlaceholder;
begin
  Assert.AreEqual(
    '<redacted>',
    LoggedValue('Authorization', 'Bearer secret-token', True),
    'Authorization must never reach the log in clear');
  Assert.AreEqual(
    '<redacted>', LoggedValue('Cookie', 'session=abc', True));
  Assert.AreEqual(
    '<redacted>', LoggedValue('X-Api-Key', 'k-123', True));
end;

procedure TTHttpLogTests.ARedactedHeaderIsRecognisedWhateverTheLocale;
var
  LSysLocale: TSysLocale;
begin
  LSysLocale := SysLocale;
  try
    SysLocale.DefaultLCID := TurkishLCID;
    Assert.AreEqual(
      '<redacted>',
      LoggedValue('AUTHORIZATION', 'Bearer secret-token', True),
      'A field name is case insensitive by RFC, so a client may send it in ' +
      'upper case. The name was matched with a comparison that follows the ' +
      'language of the machine, and on a Turkish one AUTHORIZATION did not ' +
      'meet Authorization: the header was not recognised as one to hide ' +
      'and the token went into the log in clear. It is the only one of ' +
      'these that fails open');
  finally
    SysLocale := LSysLocale;
  end;
end;

procedure TTHttpLogTests.UnredactedHeadersKeepTheirValue;
begin
  Assert.AreEqual(
    'application/json',
    LoggedValue('Content-Type', 'application/json', True),
    'Only the names on the list are redacted');
  Assert.AreEqual(
    'Firefox/141.0',
    LoggedValue('User-Agent', 'Firefox/141.0', True),
    'Only the names on the list are redacted, and a name is on it because ' +
    'somebody put it there: the list is not a guess about what looks like ' +
    'a secret');
end;

procedure TTHttpLogTests.RedactionIsAskedForExplicitly;
begin
  Assert.AreEqual(
    'Bearer secret-token',
    LoggedValue('Authorization', 'Bearer secret-token', False),
    'With redaction off the value is logged as it arrived');
end;

function TTHttpLogTests.RedactEverything:
  TFunc<TTHttpRequest, String, String>;
begin
  result :=
    function(ARequest: TTHttpRequest; AContent: String): String
    begin
      result := '{"redacted":true}';
    end;
end;

procedure TTHttpLogTests.AParameterNameThatCarriesASecretIsRedacted;
begin
  Assert.AreEqual(
    '<redacted>',
    LoggedValue('access_token', 'eyJhbGciOi', True),
    'The list held header names and was applied to the query parameters ' +
    'too, where a secret is not called Authorization: a printable invoice ' +
    'opened from a link cannot set a header, so the token travels in the ' +
    'url and every log line carried it in clear');
  Assert.AreEqual('<redacted>', LoggedValue('password', 'p', True));
  Assert.AreEqual('<redacted>', LoggedValue('signature', 's', True));
end;

procedure TTHttpLogTests.ASecretInTheQueryStringIsRedacted;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogRequest;
  LJSon: String;
begin
  LMessage := TTestHttpMessage.Create('/invoice', hcGET, '');
  try
    LMessage.SetQueryString('id=7788&access_token=eyJhbGciOi');

    LItem := TTHttpLogRequest.Create(
      LMessage.Request, TTHttpLogParameters.Create(1, 10, -1, -1), nil);
    LJSon := LItem.ToJSon;

    Assert.IsFalse(
      LJSon.Contains('eyJhbGciOi'),
      'The test beside this one goes through LoggedValue, which always ' +
      'builds headers, so the parameter path was covered by nothing: if ' +
      'the True in TTHttpLogNameValues.Create(ARequest.Parameters, True) ' +
      'became False the suite stayed green and every token in a url came ' +
      'back to the log in clear. A printable invoice opened from a link ' +
      'cannot set a header, so that is where the token travels');
    Assert.IsTrue(
      LJSon.Contains('<redacted>'),
      'and what replaces it is the redaction marker, not an empty value');
    Assert.IsTrue(
      LJSon.Contains('7788'),
      'while a parameter that carries no secret is logged as it is');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpLogTests.AnApplicationCanNameItsOwnSecret;
var
  LName: String;
begin
  LName := Format('X-Tenant-Key-%s', [TGuid.NewGuid.ToString.Substring(1, 8)]);

  Assert.AreEqual(
    'k-123',
    LoggedValue(LName, 'k-123', True),
    'Precondition: a name nobody has declared is logged as it is. The ' +
    'name is fresh on every run because the list is a process singleton ' +
    'with no Remove: with a fixed name this test passed once and then ' +
    'failed on its own precondition, and until then it left every later ' +
    'test that logged that name reading <redacted> instead');

  TTHttpLogRedactedNames.Instance.Add(LName);

  Assert.AreEqual(
    '<redacted>',
    LoggedValue(LName, 'k-123', True),
    'A proprietary header had no way in: the list was a const in a strict ' +
    'private section, so an application could not name its own secret');
end;

procedure TTHttpLogTests.TheListIsClosedWhileAServerIsRunning;
var
  LRaised: Boolean;
begin
  LRaised := False;
  TTHttpLogRedactedNames.Instance.BeginServing;
  try
    try
      TTHttpLogRedactedNames.Instance.Add('X-Too-Late');
    except
      on E: ETHttpServerException do
        LRaised := True;
    end;
  finally
    TTHttpLogRedactedNames.Instance.EndServing;
  end;

  Assert.IsTrue(
    LRaised,
    'The list is read on every header and every parameter of every ' +
    'request, so a name added while those readers run is a race: it is ' +
    'refused there, and that refusal is what lets the read path carry no ' +
    'lock at all');
  Assert.AreEqual(
    'v',
    LoggedValue('X-Too-Late', 'v', True),
    'and the name that was refused must not have been added');
end;

procedure TTHttpLogTests.TheRequestBodyGoesThroughTheRedactionHook;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogRequest;
  LJSon: String;
begin
  LMessage := TTestHttpMessage.Create(
    '/login', hcPOST, '{"username":"david","password":"s3cret"}');
  try
    LItem := TTHttpLogRequest.Create(
      LMessage.Request,
      TTHttpLogParameters.Create(1, 10, -1, -1),
      RedactEverything());
    LJSon := LItem.ToJSon;

    Assert.IsFalse(
      LJSon.Contains('s3cret'),
      'The hook decides what reaches the log: the password must not');
    Assert.IsTrue(
      LJSon.Contains('redacted'),
      'What the hook returned must be what is logged');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpLogTests.TheResponseBodyGoesThroughTheRedactionHook;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogResponse;
  LJSon: String;
begin
  LMessage := TTestHttpMessage.Create('/login', hcPOST, '{}');
  try
    LMessage.Response.Content := '{"token":"eyJhbGciOi"}';

    LItem := TTHttpLogResponse.Create(
      LMessage.Request,
      LMessage.Response,
      TTHttpLogParameters.Create(1, 10, -1, -1),
      RedactEverything());
    LJSon := LItem.ToJSon;

    Assert.IsFalse(
      LJSon.Contains('eyJhbGciOi'),
      'A token in a login response must not reach the log either');
    Assert.IsTrue(LJSon.Contains('redacted'));
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpLogTests.TheResponseCarriesTheTenantTheHostWroteOnTheUser;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogResponse;
  LJSon: String;
begin
  LMessage := TTestHttpMessage.Create('/orders', hcGET, '{}');
  try
    LMessage.Request.User.Username := 'david';
    LMessage.Request.User.Tenant := 'acme';

    LItem := TTHttpLogResponse.Create(
      LMessage.Request,
      LMessage.Response,
      TTHttpLogParameters.Create(1, 10, -1, -1),
      nil);
    LJSon := LItem.ToJSon;

    Assert.IsTrue(
      LJSon.Contains('"Tenant":"acme"'),
      'After an incident on an installation with one database per tenant ' +
      'the log said who, what and when, and did not say on which: Host ' +
      'correlates only for whoever separates the tenants by subdomain, and ' +
      'a thread variable cannot do it because the writer runs on the pool');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpLogTests.WithoutAHookTheRequestBodyIsLoggedAsItIs;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogRequest;
begin
  LMessage := TTestHttpMessage.Create('/login', hcPOST, '{"user":"david"}');
  try
    LItem := TTHttpLogRequest.Create(
      LMessage.Request, TTHttpLogParameters.Create(1, 10, -1, -1), nil);

    Assert.IsTrue(
      LItem.ToJSon.Contains('david'),
      'With no hook assigned nothing is redacted, as before');
  finally
    LMessage.Free;
  end;
end;

procedure TTHttpLogTests.LogRequestKeepsContentThatIsNotJSon;
var
  LRequest: TTHttpLogRequest;
begin
  LRequest := Default(TTHttpLogRequest);
  Assert.IsTrue(
    LRequest.ToJSon.Contains('"Content"'),
    'A content that does not parse as JSon must still be logged');
end;

procedure TTHttpLogTests.LogActionToJSonContainsFields;
var
  LAction: TTHttpLogAction;
  LJson: String;
  LObj: TJSonValue;
begin
  LAction := TTHttpLogAction.Create('task-001', 'TestAction');
  LJson := LAction.ToJSon;

  LObj := TJSonObject.ParseJSonValue(LJson);
  try
    Assert.IsTrue(LObj is TJSonObject,
      'LogAction.ToJSon must return a JSON object');
    Assert.AreEqual('task-001',
      TJSonObject(LObj).GetValue<String>('TaskID'));
    Assert.AreEqual('TestAction',
      TJSonObject(LObj).GetValue<String>('Action'));
    Assert.IsTrue(
      TJSonObject(LObj).GetValue('DateTime') <> nil,
      'LogAction JSON must contain DateTime');
  finally
    LObj.Free;
  end;
end;

procedure TTHttpLogTests.LogActionPreservesTaskIdAndAction;
var
  LAction: TTHttpLogAction;
begin
  LAction := TTHttpLogAction.Create('task-002', 'ProcessRequest');
  Assert.AreEqual('task-002', LAction.TaskID);
  Assert.AreEqual('ProcessRequest', LAction.Action);
end;

procedure TTHttpLogTests.LogParametersUnlimitedContentAcceptsAnyLength;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(1, 100, -1);
  Assert.IsTrue(LParameters.CanLogContent(0));
  Assert.IsTrue(
    LParameters.CanLogContent(1024 * 1024),
    'A negative cap is the host asking for no cap at all');
end;

procedure TTHttpLogTests.TheShortConstructorsDoNotReopenContentCapture;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(4, 20000);
  Assert.IsFalse(
    LParameters.CanLogContent(1),
    'Raising only the pool and the queue is the natural way to write this, ' +
    'and it used to hand back unlimited body capture: what the host has ' +
    'not decided has to mean what the server decides when nobody says ' +
    'anything, which is not to capture');

  LParameters := TTHttpLogParameters.Create(4, 20000, 100);
  Assert.IsTrue(
    LParameters.CanLogItems(TTHttpLogParameters.DefaultMaxItemCount),
    'And the same for the item count left unsaid');
  Assert.IsFalse(
    LParameters.CanLogItems(TTHttpLogParameters.DefaultMaxItemCount + 1),
    'which is a ceiling, not the absence of one');
end;

procedure TTHttpLogTests.AnUnsetRecordStillHasAThreadAndAQueue;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := Default(TTHttpLogParameters);
  Assert.AreEqual<Integer>(
    TTHttpLogParameters.DefaultThreadPoolSize,
    LParameters.ThreadPoolSize,
    'A record nobody filled in gave zero threads, so nothing was ever ' +
    'written and no message said why');
  Assert.AreEqual<Integer>(
    TTHttpLogParameters.DefaultQueueCapacity,
    LParameters.QueueCapacity,
    'And a queue of zero, which discards everything on arrival');
end;

procedure TTHttpLogTests.LogParametersRejectsContentAboveTheCap;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(1, 100, 100);
  Assert.IsTrue(LParameters.CanLogContent(99));
  Assert.IsTrue(
    LParameters.CanLogContent(100),
    'A body exactly at the cap must still be logged');
  Assert.IsFalse(
    LParameters.CanLogContent(101),
    'A body above the cap must be omitted');
end;

procedure TTHttpLogTests.LogDiscardedCarriesHostAndCount;
var
  LDiscarded: TTHttpLogDiscarded;
begin
  LDiscarded := TTHttpLogDiscarded.Create('tenant-a', 7);
  Assert.AreEqual('tenant-a', LDiscarded.Host);
  Assert.AreEqual<Integer>(7, LDiscarded.Count);
end;

procedure TTHttpLogTests.LogQueueIsEmptyAfterCreate;
var
  LQueue: TTHttpLogQueue;
begin
  LQueue := TTHttpLogQueue.Create(10);
  try
    Assert.IsTrue(LQueue.IsEmpty);
    Assert.AreEqual<Integer>(0, Length(LQueue.TakeDiscarded));
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueAcceptsUpToCapacity;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
  LValue: TTHttpLogQueueValue;
begin
  LRequest := Default(TTHttpLogRequest);
  LQueue := TTHttpLogQueue.Create(2);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    Assert.IsFalse(LQueue.IsEmpty);
    Assert.AreEqual<Integer>(0, Length(LQueue.TakeDiscarded));

    LValue := LQueue.Dequeue;
    Assert.IsTrue(LValue.QueueType = TTHttpLogQueueType.Request);
    LQueue.Dequeue;
    Assert.IsTrue(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueNeverDiscardsAnError;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
  LError: TTHttpLogError;
  LValue: TTHttpLogQueueValue;
begin
  LRequest := Default(TTHttpLogRequest);
  LError := Default(TTHttpLogError);
  LQueue := TTHttpLogQueue.Create(1);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LError);

    Assert.AreEqual<Integer>(
      0,
      Length(LQueue.TakeDiscarded),
      'An error went through the same capacity check as everything else, ' +
      'so under load - which is when errors happen - the 500s were thrown ' +
      'away along with the traffic that caused them');

    LValue := LQueue.Dequeue;
    Assert.IsTrue(LValue.QueueType = TTHttpLogQueueType.Request);
    LValue := LQueue.Dequeue;
    Assert.IsTrue(
      LValue.QueueType = TTHttpLogQueueType.Error,
      'The error is in the queue behind the request that filled it');
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueDiscardsAboveCapacityAndCountsThem;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
  LResponse: TTHttpLogResponse;
  LDiscarded: TArray<TTHttpLogDiscarded>;
begin
  LRequest := Default(TTHttpLogRequest);
  LResponse := Default(TTHttpLogResponse);
  LQueue := TTHttpLogQueue.Create(2);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LResponse);

    LDiscarded := LQueue.TakeDiscarded;
    Assert.AreEqual<Integer>(
      1,
      Length(LDiscarded),
      'Discards of the same host must share one entry');
    Assert.AreEqual<Integer>(
      2,
      LDiscarded[0].Count,
      'Entries above the capacity must be discarded and counted');

    LQueue.Dequeue;
    LQueue.Dequeue;
    Assert.IsTrue(
      LQueue.IsEmpty,
      'The queue must never hold more than its capacity');
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueTakeDiscardedResetsTheCounter;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
begin
  LRequest := Default(TTHttpLogRequest);
  LQueue := TTHttpLogQueue.Create(1);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    Assert.AreEqual<Integer>(1, Length(LQueue.TakeDiscarded));
    Assert.AreEqual<Integer>(
      0,
      Length(LQueue.TakeDiscarded),
      'Taking the discarded counts must reset them');
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueWithNegativeCapacityIsUnbounded;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
  LIndex: Integer;
begin
  LRequest := Default(TTHttpLogRequest);
  LQueue := TTHttpLogQueue.Create(-1);
  try
    for LIndex := 1 to 100 do
      LQueue.Enqueue(LRequest);
    Assert.AreEqual<Integer>(
      0,
      Length(LQueue.TakeDiscarded),
      'A negative capacity must mean no limit');

    for LIndex := 1 to 100 do
      LQueue.Dequeue;
    Assert.IsTrue(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogParametersUnlimitedItemsNeedsANegativeCap;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(1, 100, 100, -1);
  Assert.IsTrue(
    LParameters.CanLogItems(100000),
    'An item cap left unsaid is the server default, not the absence of a ' +
    'cap: no cap at all is a decision and has to be written as one');
end;

procedure TTHttpLogTests.LogParametersRejectsItemsAboveTheCap;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(1, 100, 100, 64);
  Assert.IsTrue(LParameters.CanLogItems(64));
  Assert.IsFalse(
    LParameters.CanLogItems(65),
    'A body split into many small parameters must not slip past the cap');
end;

procedure TTHttpLogTests.LogQueueCarriesErrorEntries;
var
  LQueue: TTHttpLogQueue;
  LError: TTHttpLogError;
  LValue: TTHttpLogQueueValue;
begin
  LError := Default(TTHttpLogError);
  LQueue := TTHttpLogQueue.Create(2);
  try
    LQueue.Enqueue(LError);
    Assert.IsFalse(LQueue.IsEmpty);

    LValue := LQueue.Dequeue;
    Assert.IsTrue(
      LValue.QueueType = TTHttpLogQueueType.Error,
      'The queue must carry error entries to the writer');
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.LogQueueSanitizesTheDiscardedHost;
var
  LQueue: TTHttpLogQueue;
  LRequest: TTHttpLogRequest;
  LDiscarded: TArray<TTHttpLogDiscarded>;
begin
  LRequest := Default(TTHttpLogRequest);
  LQueue := TTHttpLogQueue.Create(1);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);

    LDiscarded := LQueue.TakeDiscarded;
    Assert.AreEqual<Integer>(1, Length(LDiscarded));
    Assert.AreEqual(
      '<other>',
      LDiscarded[0].Host,
      'A host the client did not send must not become an empty key');
  finally
    LQueue.Free;
  end;
end;

procedure TTHttpLogTests.AnUnreadableBodyCostsTheBodyAndNotTheLine;
var
  LMessage: TTestHttpMessage;
  LItem: TTHttpLogRequest;
  LJSon: String;
begin
  LMessage := TTestHttpMessage.Create('/orders', hcPOST, '{"broken"');
  try
    LItem := TTHttpLogRequest.Create(
      LMessage.Request,
      TTHttpLogParameters.Create(1, 10, -1, -1),
      nil);
    LJSon := LItem.ToJSon;

    Assert.IsTrue(
      LJSon.Contains('/orders'),
      'A body that does not parse must cost the body and nothing else: the ' +
      'uri, the caller and the headers are written in this record only');
    Assert.IsTrue(
      LJSon.Contains('"ContentOmitted":true'),
      'and it must say that the body was dropped. Without this, writing ' +
      'the raw text into the record instead would leave the test green ' +
      'and send a body that never passed the redaction hook to the log');
  finally
    LMessage.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpLogTests);
  TDUnitX.RegisterTestFixture(TTHttpLogRegistrationTests);
  TDUnitX.RegisterTestFixture(TTHttpLogThreadTests);

end.
