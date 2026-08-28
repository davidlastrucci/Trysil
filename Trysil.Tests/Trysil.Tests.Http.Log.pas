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
  System.JSON,
  DUnitX.TestFramework,

  Trysil.Http.Log.Types,
  Trysil.Http.Log.Classes;

type

{ TTHttpLogTests }

  [TestFixture]
  TTHttpLogTests = class
  public
    [Test]
    procedure LogActionToJSonContainsFields;

    [Test]
    procedure LogActionPreservesTaskIdAndAction;

    [Test]
    procedure LogParametersUnlimitedContentAcceptsAnyLength;

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
    procedure LogQueueTakeDiscardedResetsTheCounter;

    [Test]
    procedure LogQueueWithNegativeCapacityIsUnbounded;

    [Test]
    procedure LogQueueCarriesErrorEntries;

    [Test]
    procedure LogQueueSanitizesTheDiscardedHost;

    [Test]
    procedure LogParametersUnlimitedItemsByDefault;

    [Test]
    procedure LogParametersRejectsItemsAboveTheCap;
  end;

implementation

{ TTHttpLogTests }

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
  LParameters := TTHttpLogParameters.Create(1, 100);
  Assert.IsTrue(LParameters.CanLogContent(0));
  Assert.IsTrue(
    LParameters.CanLogContent(1024 * 1024),
    'The two argument constructor must leave the content unlimited');

  LParameters := TTHttpLogParameters.Create(1, 100, -1);
  Assert.IsTrue(
    LParameters.CanLogContent(1024 * 1024),
    'A negative cap must mean unlimited');
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

procedure TTHttpLogTests.LogParametersUnlimitedItemsByDefault;
var
  LParameters: TTHttpLogParameters;
begin
  LParameters := TTHttpLogParameters.Create(1, 100, 100);
  Assert.IsTrue(
    LParameters.CanLogItems(100000),
    'Without an explicit item cap the count must stay unlimited');
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

initialization
  TDUnitX.RegisterTestFixture(TTHttpLogTests);

end.
