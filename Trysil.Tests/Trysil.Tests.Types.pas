(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Types;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions;

type

{ TTNullableTests }

  [TestFixture]
  TTNullableTests = class
  strict private
    class procedure Consume(const AValue: Integer); static;
  public
    [Test]
    procedure UninitializedIsNull;

    [Test]
    procedure CreateWithValueIsNotNull;

    [Test]
    procedure ValueReturnsAssignedValue;

    [Test]
    procedure AccessingNullValueRaisesETException;

    [Test]
    procedure GetValueOrDefaultOnNullReturnsTypeDefault;

    [Test]
    procedure GetValueOrDefaultOnValueReturnsValue;

    [Test]
    procedure GetValueOrDefaultWithArgOnNullReturnsArg;

    [Test]
    procedure GetValueOrDefaultWithArgOnValueReturnsValue;

    [Test]
    procedure TwoNullsAreEqual;

    [Test]
    procedure NullAndValueAreNotEqual;

    [Test]
    procedure SameValuesAreEqual;

    [Test]
    procedure DifferentValuesAreNotEqual;

    [Test]
    procedure ImplicitFromValueIsNotNull;

    [Test]
    procedure ImplicitToValueOnNullRaises;

    [Test]
    procedure ImplicitFromNilPointerIsNull;

    [Test]
    procedure CopyConstructorFromNullStaysNull;

    [Test]
    procedure CopyConstructorFromValueCopiesValue;
  end;

implementation

{ TTNullableTests }

class procedure TTNullableTests.Consume(const AValue: Integer);
begin
  // no-op: used to force evaluation of an expression whose result is ignored
end;

procedure TTNullableTests.UninitializedIsNull;
var
  LNullable: TTNullable<Integer>;
begin
  Assert.IsTrue(LNullable.IsNull);
end;

procedure TTNullableTests.CreateWithValueIsNotNull;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := TTNullable<Integer>.Create(42);
  Assert.IsFalse(LNullable.IsNull);
end;

procedure TTNullableTests.ValueReturnsAssignedValue;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := TTNullable<Integer>.Create(42);
  Assert.AreEqual(Integer(42), LNullable.Value);
end;

procedure TTNullableTests.AccessingNullValueRaisesETException;
var
  LNullable: TTNullable<Integer>;
  LRaised: Boolean;
begin
  LRaised := False;
  try
    Consume(LNullable.Value);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Expected ETException on null Value access');
end;

procedure TTNullableTests.GetValueOrDefaultOnNullReturnsTypeDefault;
var
  LNullable: TTNullable<Integer>;
begin
  Assert.AreEqual(Integer(0), LNullable.GetValueOrDefault);
end;

procedure TTNullableTests.GetValueOrDefaultOnValueReturnsValue;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := TTNullable<Integer>.Create(7);
  Assert.AreEqual(Integer(7), LNullable.GetValueOrDefault);
end;

procedure TTNullableTests.GetValueOrDefaultWithArgOnNullReturnsArg;
var
  LNullable: TTNullable<Integer>;
begin
  Assert.AreEqual(Integer(99), LNullable.GetValueOrDefault(99));
end;

procedure TTNullableTests.GetValueOrDefaultWithArgOnValueReturnsValue;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := TTNullable<Integer>.Create(7);
  Assert.AreEqual(Integer(7), LNullable.GetValueOrDefault(99));
end;

procedure TTNullableTests.TwoNullsAreEqual;
var
  LLeft: TTNullable<Integer>;
  LRight: TTNullable<Integer>;
begin
  Assert.IsTrue(LLeft = LRight);
end;

procedure TTNullableTests.NullAndValueAreNotEqual;
var
  LLeft: TTNullable<Integer>;
  LRight: TTNullable<Integer>;
begin
  LRight := TTNullable<Integer>.Create(1);
  Assert.IsTrue(LLeft <> LRight);
end;

procedure TTNullableTests.SameValuesAreEqual;
var
  LLeft: TTNullable<Integer>;
  LRight: TTNullable<Integer>;
begin
  LLeft := TTNullable<Integer>.Create(5);
  LRight := TTNullable<Integer>.Create(5);
  Assert.IsTrue(LLeft = LRight);
end;

procedure TTNullableTests.DifferentValuesAreNotEqual;
var
  LLeft: TTNullable<Integer>;
  LRight: TTNullable<Integer>;
begin
  LLeft := TTNullable<Integer>.Create(5);
  LRight := TTNullable<Integer>.Create(6);
  Assert.IsTrue(LLeft <> LRight);
end;

procedure TTNullableTests.ImplicitFromValueIsNotNull;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := 123;
  Assert.IsFalse(LNullable.IsNull);
  Assert.AreEqual(Integer(123), LNullable.Value);
end;

procedure TTNullableTests.ImplicitToValueOnNullRaises;
var
  LNullable: TTNullable<Integer>;
  LRaised: Boolean;
begin
  LRaised := False;
  try
    Consume(LNullable);
  except
    on E: ETException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Expected ETException on implicit conversion from null');
end;

procedure TTNullableTests.ImplicitFromNilPointerIsNull;
var
  LNullable: TTNullable<Integer>;
begin
  LNullable := TTNullable<Integer>.Create(10);
  LNullable := nil;
  Assert.IsTrue(LNullable.IsNull);
end;

procedure TTNullableTests.CopyConstructorFromNullStaysNull;
var
  LSource: TTNullable<Integer>;
  LCopy: TTNullable<Integer>;
begin
  LCopy := TTNullable<Integer>.Create(LSource);
  Assert.IsTrue(LCopy.IsNull);
end;

procedure TTNullableTests.CopyConstructorFromValueCopiesValue;
var
  LSource: TTNullable<Integer>;
  LCopy: TTNullable<Integer>;
begin
  LSource := TTNullable<Integer>.Create(42);
  LCopy := TTNullable<Integer>.Create(LSource);
  Assert.IsFalse(LCopy.IsNull);
  Assert.AreEqual(Integer(42), LCopy.Value);
end;

initialization
  TDUnitX.RegisterTestFixture(TTNullableTests);

end.
