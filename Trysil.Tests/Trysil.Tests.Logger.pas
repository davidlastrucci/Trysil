(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Logger;

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  DUnitX.TestFramework,

  Trysil.Logger;

type

{ TTestLoggerThread }

  TTestLoggerThread = class(TTLoggerThread)
  strict protected
    procedure LogStartTransaction(const AID: TTLoggerItemID); override;
    procedure LogCommit(const AID: TTLoggerItemID); override;
    procedure LogRollback(const AID: TTLoggerItemID); override;
    procedure LogParameter(
      const AID: TTLoggerItemID;
      const AName: String;
      const AValue: String); override;
    procedure LogSyntax(
      const AID: TTLoggerItemID; const ASyntax: String); override;
    procedure LogCommand(
      const AID: TTLoggerItemID; const ASyntax: String); override;
    procedure LogError(
      const AID: TTLoggerItemID; const AMessage: String); override;
  end;

{ TTestUnstartedLoggerThread }

  TTestUnstartedLoggerThread = class(TTestLoggerThread)
  public
    procedure AfterConstruction; override;
  end;

{ TTestIdleLoggerThread }

  TTestIdleLoggerThread = class(TTestLoggerThread)
  public
    procedure AfterConstruction; override;
  end;

{ TTestSelfFreeingLoggerThread }

  TTestSelfFreeingLoggerThread = class(TTestLoggerThread)
  public
    constructor Create; override;
  end;

{ TTLoggerTests }

  [TestFixture]
  TTLoggerTests = class
  strict private
    class procedure WriteThroughAnIdleLogger; static;
  public
    [Test]
    procedure LoggerItemIDStoresConnectionIDAndCurrentThreadID;

    [Test]
    procedure LoggerItemCreateWithoutValuesYieldsEmptyValuesArray;

    [Test]
    procedure LoggerItemCreateWithSingleValueStoresOneEntry;

    [Test]
    procedure LoggerItemCreateWithValuesArrayCopiesAllEntries;

    [Test]
    procedure LoggerItemCreateStoresEventType;

    [Test]
    procedure LoggerQueueIsEmptyAfterCreate;

    [Test]
    procedure LoggerQueueEnqueueMakesQueueNonEmpty;

    [Test]
    procedure LoggerQueueDequeueReturnsFirstEnqueuedItem;

    [Test]
    procedure LoggerQueueDequeueRemovesItemFromQueue;

    [Test]
    procedure ALoggerThreadDispatchesWhatItIsGiven;

    [Test]
    procedure ALoggerThreadThatFailsBeforeStartingDoesNotHang;

    [Test]
    procedure AQueueGivenToAThreadThatNeverRanIsStillWritten;

    [Test]
    procedure ALoggerThreadThatFreesOnTerminateDoesNotHang;

    [Test]
    procedure LoggerInstanceIsAssigned;

    [Test]
    procedure LoggerLogStartTransactionWithoutRegisteredThreadDoesNotRaise;

    [Test]
    procedure LoggerLogCommitWithoutRegisteredThreadDoesNotRaise;

    [Test]
    procedure LoggerLogRollbackWithoutRegisteredThreadDoesNotRaise;

    [Test]
    procedure LoggerLogParameterWithoutRegisteredThreadDoesNotRaise;

    [Test]
    procedure LoggerLogSyntaxWithoutRegisteredThreadDoesNotRaise;

    [Test]
    procedure LoggerLogCommandWithoutRegisteredThreadDoesNotRaise;
  end;

implementation

var
  GLogged: TStringList;

{ TTestLoggerThread }

procedure TTestLoggerThread.LogStartTransaction(const AID: TTLoggerItemID);
begin
  GLogged.Add('start');
end;

procedure TTestLoggerThread.LogCommit(const AID: TTLoggerItemID);
begin
  GLogged.Add('commit');
end;

procedure TTestLoggerThread.LogRollback(const AID: TTLoggerItemID);
begin
  GLogged.Add('rollback');
end;

procedure TTestLoggerThread.LogParameter(
  const AID: TTLoggerItemID;
  const AName: String;
  const AValue: String);
begin
  GLogged.Add(Format('param:%s=%s', [AName, AValue]));
end;

procedure TTestLoggerThread.LogSyntax(
  const AID: TTLoggerItemID; const ASyntax: String);
begin
  GLogged.Add(Format('syntax:%s', [ASyntax]));
end;

procedure TTestLoggerThread.LogCommand(
  const AID: TTLoggerItemID; const ASyntax: String);
begin
  GLogged.Add(Format('command:%s', [ASyntax]));
end;

procedure TTestLoggerThread.LogError(
  const AID: TTLoggerItemID; const AMessage: String);
begin
  GLogged.Add(Format('error:%s', [AMessage]));
end;

{ TTestUnstartedLoggerThread }

procedure TTestUnstartedLoggerThread.AfterConstruction;
begin
  raise Exception.Create('Refused before the thread was started');
end;

{ TTestIdleLoggerThread }

procedure TTestIdleLoggerThread.AfterConstruction;
begin
end;

{ TTestSelfFreeingLoggerThread }

constructor TTestSelfFreeingLoggerThread.Create;
begin
  inherited Create;
  FreeOnTerminate := True;
end;

{ TTLoggerTests }

procedure TTLoggerTests.LoggerItemIDStoresConnectionIDAndCurrentThreadID;
var
  LID: TTLoggerItemID;
begin
  LID := TTLoggerItemID.Create('conn-123');
  Assert.AreEqual('conn-123', LID.ConnectionID);
  Assert.AreEqual<TThreadID>(TThread.Current.ThreadID, LID.ThreadID);
end;

procedure TTLoggerTests.LoggerItemCreateWithoutValuesYieldsEmptyValuesArray;
var
  LItem: TTLoggerItem;
begin
  LItem := TTLoggerItem.Create('conn-A', TTLoggerEvent.StartTransaction);
  Assert.AreEqual<Integer>(0, Length(LItem.Values));
  Assert.AreEqual('conn-A', LItem.ID.ConnectionID);
end;

procedure TTLoggerTests.LoggerItemCreateWithSingleValueStoresOneEntry;
var
  LItem: TTLoggerItem;
begin
  LItem := TTLoggerItem.Create(
    'conn-B', TTLoggerEvent.Syntax, 'SELECT 1');
  Assert.AreEqual<Integer>(1, Length(LItem.Values));
  Assert.AreEqual('SELECT 1', LItem.Values[0]);
end;

procedure TTLoggerTests.LoggerItemCreateWithValuesArrayCopiesAllEntries;
var
  LItem: TTLoggerItem;
  LValues: TArray<String>;
begin
  LValues := TArray<String>.Create('Name', '42');
  LItem := TTLoggerItem.Create(
    'conn-C', TTLoggerEvent.Parameter, LValues);
  Assert.AreEqual<Integer>(2, Length(LItem.Values));
  Assert.AreEqual('Name', LItem.Values[0]);
  Assert.AreEqual('42', LItem.Values[1]);
end;

procedure TTLoggerTests.LoggerItemCreateStoresEventType;
var
  LItem: TTLoggerItem;
begin
  LItem := TTLoggerItem.Create('conn-D', TTLoggerEvent.Rollback);
  Assert.IsTrue(LItem.Event = TTLoggerEvent.Rollback);
end;

procedure TTLoggerTests.LoggerQueueIsEmptyAfterCreate;
var
  LQueue: TTLoggerQueue;
begin
  LQueue := TTLoggerQueue.Create;
  try
    Assert.IsTrue(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

procedure TTLoggerTests.LoggerQueueEnqueueMakesQueueNonEmpty;
var
  LQueue: TTLoggerQueue;
  LItem: TTLoggerItem;
begin
  LQueue := TTLoggerQueue.Create;
  try
    LItem := TTLoggerItem.Create('conn', TTLoggerEvent.Commit);
    LQueue.Enqueue(LItem);
    Assert.IsFalse(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

procedure TTLoggerTests.LoggerQueueDequeueReturnsFirstEnqueuedItem;
var
  LQueue: TTLoggerQueue;
  LFirst: TTLoggerItem;
  LSecond: TTLoggerItem;
  LDequeued: TTLoggerItem;
begin
  LQueue := TTLoggerQueue.Create;
  try
    LFirst := TTLoggerItem.Create(
      'conn', TTLoggerEvent.Syntax, 'first');
    LSecond := TTLoggerItem.Create(
      'conn', TTLoggerEvent.Syntax, 'second');
    LQueue.Enqueue(LFirst);
    LQueue.Enqueue(LSecond);

    LDequeued := LQueue.Dequeue;
    Assert.AreEqual('first', LDequeued.Values[0]);
  finally
    LQueue.Free;
  end;
end;

procedure TTLoggerTests.LoggerQueueDequeueRemovesItemFromQueue;
var
  LQueue: TTLoggerQueue;
  LItem: TTLoggerItem;
begin
  LQueue := TTLoggerQueue.Create;
  try
    LItem := TTLoggerItem.Create('conn', TTLoggerEvent.Commit);
    LQueue.Enqueue(LItem);
    LQueue.Dequeue;
    Assert.IsTrue(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

procedure TTLoggerTests.LoggerInstanceIsAssigned;
begin
  Assert.IsNotNull(TTLogger.Instance);
end;

procedure TTLoggerTests.LoggerLogStartTransactionWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogStartTransaction('test-connection');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.LoggerLogCommitWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogCommit('test-connection');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.LoggerLogRollbackWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogRollback('test-connection');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.LoggerLogParameterWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogParameter('test-connection', 'ParamName', 'ParamValue');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.LoggerLogSyntaxWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogSyntax('test-connection', 'SELECT 1');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.LoggerLogCommandWithoutRegisteredThreadDoesNotRaise;
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    TTLogger.Instance.LogCommand('test-connection', 'UPDATE Foo SET Bar = 1');
  except
    on E: Exception do
      LRaised := True;
  end;
  Assert.IsFalse(LRaised);
end;

procedure TTLoggerTests.ALoggerThreadDispatchesWhatItIsGiven;
var
  LThread: TTestLoggerThread;
begin
  GLogged.Clear;

  LThread := TTestLoggerThread.Create;
  try
    LThread.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.StartTransaction));
    LThread.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.Syntax, 'select 1'));
    LThread.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.Commit));
  finally
    LThread.Free;
  end;

  Assert.AreEqual<Integer>(
    3,
    GLogged.Count,
    'Nothing in this repository descends from TTLoggerThread and nothing '
    + 'calls RegisterLogger, so the whole class - the dispatch table, the '
    + 'queue, the draining on destruction - was carried by the suite '
    + 'without a single test. Freeing the thread terminates it, wakes it '
    + 'and waits, which is what drains the queue: all three items must '
    + 'have been delivered by the time Free returns');
  Assert.AreEqual('start', GLogged[0]);
  Assert.AreEqual('syntax:select 1', GLogged[1]);
  Assert.AreEqual(
    'commit',
    GLogged[2],
    'and in the order they were queued');
end;

class procedure TTLoggerTests.WriteThroughAnIdleLogger;
var
  LLogger: TTestIdleLoggerThread;
begin
  LLogger := TTestIdleLoggerThread.Create;
  try
    LLogger.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.StartTransaction));
    LLogger.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.Syntax, 'select 1'));
    LLogger.AddLog(
      TTLoggerItem.Create('c', TTLoggerEvent.Commit));
  finally
    LLogger.Free;
  end;
end;

procedure TTLoggerTests.AQueueGivenToAThreadThatNeverRanIsStillWritten;
const
  Timeout: Cardinal = 5000;
var
  LDone: TEvent;
  LThread: TThread;
  LResult: TWaitResult;
begin
  GLogged.Clear;

  LDone := TEvent.Create;
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      WriteThroughAnIdleLogger;
      LDone.SetEvent;
    end);
  LThread.Start;

  LResult := LDone.WaitFor(Timeout);
  if LResult = TWaitResult.wrSignaled then
    LDone.Free;

  Assert.AreEqual<TWaitResult>(
    TWaitResult.wrSignaled,
    LResult,
    'The logger of this test is never started, and freeing it waits for '
    + 'its thread: only the resume in SetTerminated lets that wait end. '
    + 'The logger is freed on a thread nobody waits for, so losing the '
    + 'resume fails here instead of hanging the runner; the event is left '
    + 'alive on a timeout, because that thread may still reach it');
  Assert.AreEqual<Integer>(
    3,
    GLogged.Count,
    'This thread is never started, so Execute never runs: ThreadProc '
    + 'skips it once Terminated is set. Draining was the job of Execute '
    + 'alone, and a queue handed to a thread the system had not scheduled '
    + 'yet was lost. The thread that frees the logger drains what is left '
    + 'after WaitFor, and this test does not depend on when the system '
    + 'schedules anything');
  Assert.AreEqual(
    'commit',
    GLogged[2],
    'and in the order the items were queued');
end;

procedure TTLoggerTests.ALoggerThreadThatFreesOnTerminateDoesNotHang;
const
  Timeout: Cardinal = 5000;
var
  LDone: TEvent;
  LThread: TThread;
  LResult: TWaitResult;
begin
  LDone := TEvent.Create;
  LThread := TThread.CreateAnonymousThread(
    procedure
    var
      LLogger: TTestSelfFreeingLoggerThread;
    begin
      LLogger := TTestSelfFreeingLoggerThread.Create;
      LLogger.Free;
      LDone.SetEvent;
    end);
  LThread.Start;

  LResult := LDone.WaitFor(Timeout);
  if LResult = TWaitResult.wrSignaled then
    LDone.Free;

  Assert.AreEqual<TWaitResult>(
    TWaitResult.wrSignaled,
    LResult,
    'BeforeDestruction stops the thread before inherited, and inherited '
    + 'is what clears FreeOnTerminate. With the flag still set, the '
    + 'logger thread freed itself on the way out of ThreadProc, ran '
    + 'BeforeDestruction again and waited on its own handle, while the '
    + 'thread freeing it waited on the same handle: every process exit '
    + 'hung. 1.0.0 stopped the thread in Destroy, after the flag was '
    + 'cleared. The event is left alive on a timeout, because the thread '
    + 'that should set it may still reach it');
end;

procedure TTLoggerTests.ALoggerThreadThatFailsBeforeStartingDoesNotHang;
const
  Timeout: Cardinal = 5000;
var
  LRaised: Boolean;
  LDone: TEvent;
  LThread: TThread;
  LResult: TWaitResult;
begin
  LRaised := False;
  LDone := TEvent.Create;
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        TTestUnstartedLoggerThread.Create;
      except
        on E: Exception do
          LRaised := True;
      end;
      LDone.SetEvent;
    end);
  LThread.Start;

  LResult := LDone.WaitFor(Timeout);
  if LResult = TWaitResult.wrSignaled then
    LDone.Free;

  Assert.AreEqual<TWaitResult>(
    TWaitResult.wrSignaled,
    LResult,
    'An AfterConstruction that raises before inherited leaves the thread '
    + 'suspended, and the RTL still runs BeforeDestruction on the way out. '
    + 'SetTerminated waited on a thread that was never started, so '
    + 'RegisterLogger hung for good, holding the round robin lock. The '
    + 'creation runs on a thread that frees itself and that nobody waits '
    + 'for, so a regression fails here instead of hanging the runner at '
    + 'exit; the event is left alive on a timeout, because that thread '
    + 'may still reach it');
  Assert.IsTrue(
    LRaised,
    'and the exception reaches the caller instead of being lost');
end;

initialization
  GLogged := TStringList.Create;
  TDUnitX.RegisterTestFixture(TTLoggerTests);

finalization
  GLogged.Free;

end.
