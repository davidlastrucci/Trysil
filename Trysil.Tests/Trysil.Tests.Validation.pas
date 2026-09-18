(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Validation;

interface

uses
  System.SysUtils,
  System.Rtti,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Validation,
  Trysil.Validation.Attributes;

type

{ TTValidationAttributesTests }

  [TestFixture]
  TTValidationAttributesTests = class
  strict private
    FErrors: TTValidationErrors;

    procedure Validate(
      const AAttribute: TValidationAttribute; const AValue: TValue);
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AnIntegerLimitAcceptsAnInt64Field;

    [Test]
    procedure AnIntegerLimitAcceptsANullableIntegerField;

    [Test]
    procedure AnIntegerLimitAcceptsADoubleField;

    [Test]
    procedure ADoubleLimitAcceptsAnIntegerField;

    [Test]
    procedure ANullableFieldIsComparedByItsValue;

    [Test]
    procedure AnInt64KeepsItsPrecision;

    [Test]
    procedure ARangeAcceptsAnInt64Field;

    [Test]
    procedure ARangeRejectsAnInt64OutOfBounds;

    [Test]
    procedure ANonNumericFieldIsRefused;
  end;

implementation

{ TTValidationAttributesTests }

procedure TTValidationAttributesTests.Setup;
begin
  FErrors := TTValidationErrors.Create;
end;

procedure TTValidationAttributesTests.TearDown;
begin
  FErrors.Free;
end;

procedure TTValidationAttributesTests.Validate(
  const AAttribute: TValidationAttribute; const AValue: TValue);
begin
  try
    AAttribute.Validate('Column', AValue, FErrors);
  finally
    AAttribute.Free;
  end;
end;

procedure TTValidationAttributesTests.AnIntegerLimitAcceptsAnInt64Field;
begin
  Validate(TMinValueAttribute.Create(0), TValue.From<Int64>(5));

  Assert.IsTrue(
    FErrors.IsEmpty,
    'The type of the comparison used to come from the literal in the ' +
    'attribute, so [TMinValue(0)] on an Int64 field refused every value ' +
    'and no entity carrying it could ever be saved');
end;

procedure
  TTValidationAttributesTests.AnIntegerLimitAcceptsANullableIntegerField;
var
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(5);

  Validate(
    TMinValueAttribute.Create(0), TValue.From<TTNullable<Integer>>(LValue));

  Assert.IsTrue(
    FErrors.IsEmpty,
    'A nullable is compared by the value it holds, as the length and regex ' +
    'validators already did');
end;

procedure TTValidationAttributesTests.AnIntegerLimitAcceptsADoubleField;
begin
  Validate(TMinValueAttribute.Create(0), TValue.From<Double>(1.5));

  Assert.IsTrue(
    FErrors.IsEmpty,
    'Writing [TMinValue(0)] rather than [TMinValue(0.0)] on a price is the ' +
    'natural thing to do, and it used to refuse every value');
end;

procedure TTValidationAttributesTests.ADoubleLimitAcceptsAnIntegerField;
begin
  Validate(TMaxValueAttribute.Create(10.5), TValue.From<Integer>(5));

  Assert.IsTrue(
    FErrors.IsEmpty,
    'The mismatch is symmetrical: a decimal limit on a whole number field ' +
    'used to fail the same way');
end;

procedure TTValidationAttributesTests.ANullableFieldIsComparedByItsValue;
var
  LValue: TTNullable<Integer>;
begin
  LValue := TTNullable<Integer>.Create(-1);

  Validate(
    TMinValueAttribute.Create(0), TValue.From<TTNullable<Integer>>(LValue));

  Assert.IsFalse(
    FErrors.IsEmpty,
    'Reading through the nullable must not make the check permissive: a ' +
    'value below the minimum is still refused');
end;

procedure TTValidationAttributesTests.AnInt64KeepsItsPrecision;
begin
  Validate(
    TGreaterAttribute.Create(0),
    TValue.From<Int64>(9007199254740993));

  Assert.IsTrue(
    FErrors.IsEmpty,
    'Whole numbers are compared as Int64, not through Double: above 2^53 a ' +
    'Double cannot tell two consecutive integers apart, and that is the ' +
    'range money reaches');
end;

procedure TTValidationAttributesTests.ARangeAcceptsAnInt64Field;
begin
  Validate(TRangeAttribute.Create(1, 100), TValue.From<Int64>(50));

  Assert.IsTrue(FErrors.IsEmpty, 'A range reads the value the same way');
end;

procedure TTValidationAttributesTests.ARangeRejectsAnInt64OutOfBounds;
begin
  Validate(TRangeAttribute.Create(1, 100), TValue.From<Int64>(500));

  Assert.IsFalse(
    FErrors.IsEmpty,
    'And it still refuses what falls outside');
end;

procedure TTValidationAttributesTests.ANonNumericFieldIsRefused;
begin
  Validate(TMinValueAttribute.Create(0), TValue.From<String>('five'));

  Assert.IsFalse(
    FErrors.IsEmpty,
    'A numeric limit on a field that carries no number is a mapping ' +
    'mistake, and the error for it has to stay');
end;

initialization
  TDUnitX.RegisterTestFixture(TTValidationAttributesTests);

end.
