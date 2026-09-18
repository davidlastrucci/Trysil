(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.LoadBalancing;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Threading,
  DUnitX.TestFramework,

  Trysil.LoadBalancing;

type

{ TTestNode }

  TTestNode = class
  strict private
    FName: String;
    FServed: Integer;
  public
    constructor Create(const AName: String);

    procedure Serve;

    property Name: String read FName;
    property Served: Integer read FServed;
  end;

{ TTestNodePool }

  TTestNodePool = class(TTRoundRobin<TTestNode>)
  end;

{ TTRoundRobinTests }

  [TestFixture]
  TTRoundRobinTests = class
  strict private
    const Threads: Integer = 4;
    const CallsPerThread: Integer = 250;
  strict private
    FPool: TTestNodePool;
    FCreated: Integer;

    procedure Fill(const ACount: Integer);
    function NameOfNext: String;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnEmptyPoolHandsBackNothing;

    [Test]
    procedure APoolSizeBelowOneStillMakesOne;

    [Test]
    procedure TheFirstCallHandsBackTheFirstItem;

    [Test]
    procedure ThePoolCyclesInOrder;

    [Test]
    procedure APoolOfOneAlwaysHandsBackTheSameItem;

    [Test]
    procedure FillingTwiceAddsToThePool;

    [Test]
    procedure ConcurrentCallersShareThePoolEvenly;
  end;

implementation

{ TTestNode }

constructor TTestNode.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
  FServed := 0;
end;

procedure TTestNode.Serve;
begin
  TInterlocked.Increment(FServed);
end;

{ TTRoundRobinTests }

procedure TTRoundRobinTests.Setup;
begin
  FPool := TTestNodePool.Create;
  FCreated := 0;
end;

procedure TTRoundRobinTests.TearDown;
begin
  FPool.Free;
end;

procedure TTRoundRobinTests.Fill(const ACount: Integer);
begin
  FPool.CreateItems(
    function: TTestNode
    begin
      Inc(FCreated);
      result := TTestNode.Create(Format('node%d', [FCreated]));
    end,
    ACount);
end;

function TTRoundRobinTests.NameOfNext: String;
var
  LNode: TTestNode;
begin
  LNode := FPool.Next;
  if Assigned(LNode) then
    result := LNode.Name
  else
    result := String.Empty;
end;

procedure TTRoundRobinTests.AnEmptyPoolHandsBackNothing;
begin
  Assert.IsNull(
    FPool.Next,
    'A pool nobody filled has nothing to hand back, and must say so with ' +
    'nil rather than with an index out of range');
end;

procedure TTRoundRobinTests.APoolSizeBelowOneStillMakesOne;
begin
  Fill(0);

  Assert.AreEqual<Integer>(
    1,
    FCreated,
    'A pool size of zero is a configuration mistake, and the pool clamps ' +
    'it to one rather than becoming a pool that answers nil for ever');
end;

procedure TTRoundRobinTests.TheFirstCallHandsBackTheFirstItem;
begin
  Fill(3);

  Assert.AreEqual(
    'node1',
    NameOfNext,
    'The index starts before the first item, so the first caller gets the ' +
    'first node and not the second');
end;

procedure TTRoundRobinTests.ThePoolCyclesInOrder;
begin
  Fill(3);

  Assert.AreEqual('node1', NameOfNext);
  Assert.AreEqual('node2', NameOfNext);
  Assert.AreEqual('node3', NameOfNext);
  Assert.AreEqual(
    'node1',
    NameOfNext,
    'After the last item the pool starts again from the first');
  Assert.AreEqual('node2', NameOfNext);
end;

procedure TTRoundRobinTests.APoolOfOneAlwaysHandsBackTheSameItem;
var
  LFirst: TTestNode;
begin
  Fill(1);
  LFirst := FPool.Next;

  Assert.IsTrue(
    LFirst = FPool.Next,
    'A pool of one is not a special case to guard against: it hands back ' +
    'the same node every time');
end;

procedure TTRoundRobinTests.FillingTwiceAddsToThePool;
begin
  Fill(2);
  Fill(2);

  Assert.AreEqual('node1', NameOfNext);
  Assert.AreEqual('node2', NameOfNext);
  Assert.AreEqual(
    'node3',
    NameOfNext,
    'CreateItems adds to the pool, it does not replace it: calling it ' +
    'twice is how a host grows the pool, and how it doubles it by mistake');
end;

procedure TTRoundRobinTests.ConcurrentCallersShareThePoolEvenly;
var
  LTasks: TArray<ITask>;
  LIndex: Integer;
  LNode: TTestNode;
  LExpected: Integer;
begin
  Fill(Threads);

  SetLength(LTasks, Threads);
  for LIndex := 0 to Threads - 1 do
    LTasks[LIndex] := TTask.Run(
      procedure
      var
        LCall: Integer;
      begin
        for LCall := 1 to CallsPerThread do
          FPool.Next.Serve;
      end);
  TTask.WaitForAll(LTasks);

  LExpected := (Threads * CallsPerThread) div Threads;
  for LIndex := 1 to Threads do
  begin
    LNode := FPool.Next;
    Assert.AreEqual<Integer>(
      LExpected,
      LNode.Served,
      Format(
        'The rotation is under a lock, so it is a strict rotation: %s must ' +
        'have served exactly its share. A count that drifts means two ' +
        'threads read the same index', [LNode.Name]));
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTRoundRobinTests);

end.
