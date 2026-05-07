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
  DUnitX.TestFramework,

  Trysil.Logger;

type

{ TTLoggerTests }

  [TestFixture]
  TTLoggerTests = class
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

initialization
  TDUnitX.RegisterTestFixture(TTLoggerTests);

end.
