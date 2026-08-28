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
    procedure LogQueueIsEmptyAfterCreate;

    [Test]
    procedure LogQueueAcceptsUpToCapacity;

    [Test]
    procedure LogQueueDiscardsAboveCapacityAndCountsThem;

    [Test]
    procedure LogQueueTakeDiscardedResetsTheCounter;

    [Test]
    procedure LogQueueWithNegativeCapacityIsUnbounded;
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

procedure TTHttpLogTests.LogQueueIsEmptyAfterCreate;
var
  LQueue: TTHttpLogQueue;
begin
  LQueue := TTHttpLogQueue.Create(10);
  try
    Assert.IsTrue(LQueue.IsEmpty);
    Assert.AreEqual<Integer>(0, LQueue.TakeDiscarded);
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
    Assert.AreEqual<Integer>(0, LQueue.TakeDiscarded);

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
begin
  LRequest := Default(TTHttpLogRequest);
  LResponse := Default(TTHttpLogResponse);
  LQueue := TTHttpLogQueue.Create(2);
  try
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LRequest);
    LQueue.Enqueue(LResponse);
    Assert.AreEqual<Integer>(
      2,
      LQueue.TakeDiscarded,
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
    Assert.AreEqual<Integer>(1, LQueue.TakeDiscarded);
    Assert.AreEqual<Integer>(
      0,
      LQueue.TakeDiscarded,
      'Taking the discarded count must reset it');
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
      LQueue.TakeDiscarded,
      'A negative capacity must mean no limit');

    for LIndex := 1 to 100 do
      LQueue.Dequeue;
    Assert.IsTrue(LQueue.IsEmpty);
  finally
    LQueue.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTHttpLogTests);

end.
