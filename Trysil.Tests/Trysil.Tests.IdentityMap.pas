(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.IdentityMap;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.IdentityMap;

type

{ TTestEntityA }

  TTestEntityA = class
  strict private
    class var FDestroyCount: Integer;
  strict private
    FValue: Integer;
  public
    constructor Create(const AValue: Integer);
    destructor Destroy; override;

    class procedure ResetDestroyCount;

    class property DestroyCount: Integer read FDestroyCount;
    property Value: Integer read FValue;
  end;

{ TTestEntityB }

  TTestEntityB = class
  strict private
    FLabel: String;
  public
    constructor Create(const ALabel: String);

    property &Label: String read FLabel;
  end;

{ TTIdentityMapTests }

  [TestFixture]
  TTIdentityMapTests = class
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure GetEntityOnEmptyReturnsNil;

    [Test]
    procedure AddAndGetReturnsSameInstance;

    [Test]
    procedure DifferentPrimaryKeysReturnDifferentInstances;

    [Test]
    procedure AddWithDuplicateKeyReplacesAndFreesPrevious;

    [Test]
    procedure AddSameInstanceTwiceDoesNotFree;

    [Test]
    procedure DifferentEntityTypesDoNotCollideOnSameKey;

    [Test]
    procedure RemoveEntityMakesGetReturnNil;

    [Test]
    procedure RemoveEntityFreesOwnedInstance;

    [Test]
    procedure DestroyFreesAllOwnedEntities;
  end;

implementation

{ TTestEntityA }

constructor TTestEntityA.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

destructor TTestEntityA.Destroy;
begin
  Inc(FDestroyCount);
  inherited Destroy;
end;

class procedure TTestEntityA.ResetDestroyCount;
begin
  FDestroyCount := 0;
end;

{ TTestEntityB }

constructor TTestEntityB.Create(const ALabel: String);
begin
  inherited Create;
  FLabel := ALabel;
end;

{ TTIdentityMapTests }

procedure TTIdentityMapTests.Setup;
begin
  TTestEntityA.ResetDestroyCount;
end;

procedure TTIdentityMapTests.GetEntityOnEmptyReturnsNil;
var
  LMap: TTIdentityMap;
begin
  LMap := TTIdentityMap.Create;
  try
    Assert.IsNull(LMap.GetEntity<TTestEntityA>(1));
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.AddAndGetReturnsSameInstance;
var
  LMap: TTIdentityMap;
  LEntity: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LEntity := TTestEntityA.Create(42);
    LMap.AddEntity<TTestEntityA>(1, LEntity);
    Assert.AreSame(LEntity, LMap.GetEntity<TTestEntityA>(1));
    Assert.AreEqual(Integer(42), LMap.GetEntity<TTestEntityA>(1).Value);
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.DifferentPrimaryKeysReturnDifferentInstances;
var
  LMap: TTIdentityMap;
  LFirst: TTestEntityA;
  LSecond: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LFirst := TTestEntityA.Create(10);
    LSecond := TTestEntityA.Create(20);
    LMap.AddEntity<TTestEntityA>(1, LFirst);
    LMap.AddEntity<TTestEntityA>(2, LSecond);
    Assert.AreSame(LFirst, LMap.GetEntity<TTestEntityA>(1));
    Assert.AreSame(LSecond, LMap.GetEntity<TTestEntityA>(2));
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.AddWithDuplicateKeyReplacesAndFreesPrevious;
var
  LMap: TTIdentityMap;
  LFirst: TTestEntityA;
  LSecond: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LFirst := TTestEntityA.Create(10);
    LSecond := TTestEntityA.Create(20);
    LMap.AddEntity<TTestEntityA>(1, LFirst);
    LMap.AddEntity<TTestEntityA>(1, LSecond);
    Assert.AreSame(LSecond, LMap.GetEntity<TTestEntityA>(1),
      'A colliding key must replace the previous instance');
    Assert.AreEqual(Integer(1), TTestEntityA.DestroyCount,
      'The replaced instance must be freed by the identity map');
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.AddSameInstanceTwiceDoesNotFree;
var
  LMap: TTIdentityMap;
  LEntity: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LEntity := TTestEntityA.Create(42);
    LMap.AddEntity<TTestEntityA>(1, LEntity);
    LMap.AddEntity<TTestEntityA>(1, LEntity);
    Assert.AreSame(LEntity, LMap.GetEntity<TTestEntityA>(1));
    Assert.AreEqual(Integer(0), TTestEntityA.DestroyCount,
      'Re-adding the same instance must not free it');
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.DifferentEntityTypesDoNotCollideOnSameKey;
var
  LMap: TTIdentityMap;
  LEntityA: TTestEntityA;
  LEntityB: TTestEntityB;
begin
  LMap := TTIdentityMap.Create;
  try
    LEntityA := TTestEntityA.Create(7);
    LEntityB := TTestEntityB.Create('hello');
    LMap.AddEntity<TTestEntityA>(1, LEntityA);
    LMap.AddEntity<TTestEntityB>(1, LEntityB);
    Assert.AreSame(LEntityA, LMap.GetEntity<TTestEntityA>(1));
    Assert.AreSame(LEntityB, LMap.GetEntity<TTestEntityB>(1));
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.RemoveEntityMakesGetReturnNil;
var
  LMap: TTIdentityMap;
  LEntity: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LEntity := TTestEntityA.Create(42);
    LMap.AddEntity<TTestEntityA>(1, LEntity);
    LMap.RemoveEntity<TTestEntityA>(1);
    Assert.IsNull(LMap.GetEntity<TTestEntityA>(1));
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.RemoveEntityFreesOwnedInstance;
var
  LMap: TTIdentityMap;
  LEntity: TTestEntityA;
begin
  LMap := TTIdentityMap.Create;
  try
    LEntity := TTestEntityA.Create(42);
    LMap.AddEntity<TTestEntityA>(1, LEntity);
    LMap.RemoveEntity<TTestEntityA>(1);
    Assert.AreEqual(Integer(1), TTestEntityA.DestroyCount);
  finally
    LMap.Free;
  end;
end;

procedure TTIdentityMapTests.DestroyFreesAllOwnedEntities;
var
  LMap: TTIdentityMap;
begin
  LMap := TTIdentityMap.Create;
  try
    LMap.AddEntity<TTestEntityA>(1, TTestEntityA.Create(1));
    LMap.AddEntity<TTestEntityA>(2, TTestEntityA.Create(2));
    LMap.AddEntity<TTestEntityA>(3, TTestEntityA.Create(3));
  finally
    LMap.Free;
  end;
  Assert.AreEqual(Integer(3), TTestEntityA.DestroyCount);
end;

initialization
  TDUnitX.RegisterTestFixture(TTIdentityMapTests);

end.
