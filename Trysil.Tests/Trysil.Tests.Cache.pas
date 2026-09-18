(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Cache;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Threading,
  DUnitX.TestFramework,

  Trysil.Exceptions,
  Trysil.Cache;

type

{ TTestCacheItem }

  TTestCacheItem = class
  strict private
    class var FLive: Integer;
  strict private
    FKey: String;
    FStamp: String;
  public
    constructor Create(const AKey: String);
    destructor Destroy; override;

    class procedure ResetLive;

    class property Live: Integer read FLive;

    property Key: String read FKey;
    property Stamp: String read FStamp write FStamp;
  end;

{ TTestCache }

  TTestCache = class(TTCache<String, TTestCacheItem>)
  strict private
    FCreated: Integer;
  strict protected
    function CreateObject(const AKey: String): TTestCacheItem; override;
  public
    function Get(const AKey: String): TTestCacheItem; overload;
    function Get(
      const AKey: String;
      const AAfterCreate: TTAfterCreateObjectMethod<TTestCacheItem>):
      TTestCacheItem; overload;

    property Created: Integer read FCreated;
  end;

{ TTCacheTests }

  [TestFixture]
  TTCacheTests = class
  strict private
    const Racers: Integer = 8;
  strict private
    FCache: TTestCache;
    FSlot: Integer;

    function RaiseInTheHook(const AKey: String): Boolean;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AKeyIsBuiltOnceAndHandedBackAfterwards;

    [Test]
    procedure DifferentKeysAreDifferentObjects;

    [Test]
    procedure TheHookRunsBeforeTheObjectIsHandedBack;

    [Test]
    procedure AHookThatRaisesCachesNothingAndFreesTheObject;

    [Test]
    procedure ARaceOnOneKeyHasOneWinnerAndNoLeak;
  end;

implementation

{ TTestCacheItem }

constructor TTestCacheItem.Create(const AKey: String);
begin
  inherited Create;
  FKey := AKey;
  TInterlocked.Increment(FLive);
end;

destructor TTestCacheItem.Destroy;
begin
  TInterlocked.Decrement(FLive);
  inherited Destroy;
end;

class procedure TTestCacheItem.ResetLive;
begin
  FLive := 0;
end;

{ TTestCache }

function TTestCache.CreateObject(const AKey: String): TTestCacheItem;
begin
  TInterlocked.Increment(FCreated);
  TThread.Yield;
  result := TTestCacheItem.Create(AKey);
end;

function TTestCache.Get(const AKey: String): TTestCacheItem;
begin
  result := GetValueOrCreate(AKey);
end;

function TTestCache.Get(
  const AKey: String;
  const AAfterCreate: TTAfterCreateObjectMethod<TTestCacheItem>):
  TTestCacheItem;
begin
  result := GetValueOrCreate(AKey, AAfterCreate);
end;

{ TTCacheTests }

procedure TTCacheTests.Setup;
begin
  TTestCacheItem.ResetLive;
  FSlot := 0;
  FCache := TTestCache.Create;
end;

procedure TTCacheTests.TearDown;
begin
  FCache.Free;
end;

procedure TTCacheTests.AKeyIsBuiltOnceAndHandedBackAfterwards;
var
  LFirst: TTestCacheItem;
begin
  LFirst := FCache.Get('alpha');

  Assert.IsTrue(
    LFirst = FCache.Get('alpha'),
    'The second caller must get the object the first one built, or the ' +
    'cache is only a factory with a lock');
  Assert.AreEqual<Integer>(
    1, FCache.Created, 'And the object must be built once');
end;

procedure TTCacheTests.DifferentKeysAreDifferentObjects;
begin
  Assert.IsFalse(
    FCache.Get('alpha') = FCache.Get('beta'),
    'Two keys are two entries');
  Assert.AreEqual<Integer>(2, FCache.Created);
end;

procedure TTCacheTests.TheHookRunsBeforeTheObjectIsHandedBack;
var
  LItem: TTestCacheItem;
begin
  LItem := FCache.Get(
    'alpha',
    procedure(const AObject: TTestCacheItem)
    begin
      AObject.Stamp := 'stamped';
    end);

  Assert.AreEqual(
    'stamped',
    LItem.Stamp,
    'The hook is where the caller finishes building the object, so it has ' +
    'to run before anybody can see it');
  Assert.AreEqual(
    'stamped',
    FCache.Get('alpha').Stamp,
    'And what it did is what the next caller finds in the cache');
end;

function TTCacheTests.RaiseInTheHook(const AKey: String): Boolean;
begin
  result := False;
  try
    FCache.Get(
      AKey,
      procedure(const AObject: TTestCacheItem)
      begin
        raise ETException.Create('The hook refuses this object');
      end);
  except
    on E: ETException do
      result := True;
  end;
end;

procedure TTCacheTests.AHookThatRaisesCachesNothingAndFreesTheObject;
begin
  Assert.IsTrue(
    RaiseInTheHook('alpha'), 'Precondition: the hook must raise');
  Assert.AreEqual<Integer>(
    0,
    TTestCacheItem.Live,
    'An object the hook refused is freed on the way out, not leaked');

  Assert.AreEqual(
    'alpha',
    FCache.Get('alpha').Key,
    'And nothing was cached under that key, so the next caller builds it ' +
    'again instead of finding a half-built object');
  Assert.AreEqual<Integer>(2, FCache.Created);
end;

procedure TTCacheTests.ARaceOnOneKeyHasOneWinnerAndNoLeak;
var
  LTasks: TArray<ITask>;
  LResults: TArray<TTestCacheItem>;
  LIndex: Integer;
begin
  SetLength(LTasks, Racers);
  SetLength(LResults, Racers);
  for LIndex := 0 to Racers - 1 do
  begin
    LTasks[LIndex] := TTask.Run(
      procedure
      var
        LSlot: Integer;
      begin
        LSlot := TInterlocked.Increment(FSlot) - 1;
        LResults[LSlot] := FCache.Get('contended');
      end);
  end;
  TTask.WaitForAll(LTasks);

  for LIndex := 1 to Racers - 1 do
    Assert.IsTrue(
      LResults[0] = LResults[LIndex],
      'Every caller of one key must end up with the same object, however ' +
      'many of them built one while the lock was open');

  Assert.AreEqual<Integer>(
    1,
    TTestCacheItem.Live,
    'The losers of the race are freed, so exactly one object survives: ' +
    'anything else is a leak once per contended key');
end;

initialization
  TDUnitX.RegisterTestFixture(TTCacheTests);

end.
