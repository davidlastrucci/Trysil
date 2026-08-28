(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Data.Parameters;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.TypInfo,
  System.Rtti,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Rtti,
  Trysil.Data.Parameters;

type

{ TTDataParametersTests }

  [TestFixture]
  TTDataParametersTests = class
  public
    [Test]
    procedure StringFieldTypeConvertsAnyValue;

    [Test]
    procedure IntegerFieldTypeConvertsDecimalText;

    [Test]
    procedure IntegerFieldTypeRejectsNonNumericText;

    [Test]
    procedure LargeIntegerFieldTypeConvertsBeyondInt32;

    [Test]
    procedure FloatFieldTypeUsesInvariantDecimalSeparator;

    [Test]
    procedure CurrencyFieldTypeProducesCurrencyValue;

    [Test]
    procedure FloatFieldTypeProducesDoubleValue;

    [Test]
    procedure BooleanFieldTypeAcceptsTextAndDigits;

    [Test]
    procedure BooleanFieldTypeRejectsOtherText;

    [Test]
    procedure DateTimeFieldTypeConvertsIso8601UtcToLocal;

    [Test]
    procedure DateTimeFieldTypeRejectsLocalizedText;

    [Test]
    procedure GuidFieldTypeConvertsBracedForm;

    [Test]
    procedure GuidFieldTypeRejectsNonGuidText;

    [Test]
    procedure BlobFieldTypeHasNoStringConversion;

    [Test]
    procedure UnregisteredFieldTypeReturnsFalse;

    [Test]
    procedure FailedConversionLeavesResultEmpty;
  end;

implementation

{ TTDataParametersTests }

procedure TTDataParametersTests.StringFieldTypeConvertsAnyValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftString, 'O''Brien', LValue));
  Assert.AreEqual('O''Brien', LValue.AsType<String>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftWideMemo, String.Empty, LValue));
  Assert.AreEqual(String.Empty, LValue.AsType<String>());
end;

procedure TTDataParametersTests.IntegerFieldTypeConvertsDecimalText;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '42', LValue));
  Assert.AreEqual<Integer>(42, LValue.AsType<Integer>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftSmallint, '-7', LValue));
  Assert.AreEqual<Integer>(-7, LValue.AsType<Integer>());
end;

procedure TTDataParametersTests.IntegerFieldTypeRejectsNonNumericText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '42abc', LValue));

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '4.2', LValue));
end;

procedure TTDataParametersTests.LargeIntegerFieldTypeConvertsBeyondInt32;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftLargeint, '3000000000', LValue));
  Assert.AreEqual<Int64>(3000000000, LValue.AsType<Int64>());

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '3000000000', LValue));
end;

procedure TTDataParametersTests.FloatFieldTypeUsesInvariantDecimalSeparator;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, '1234.56', LValue));
  Assert.AreEqual(1234.56, LValue.AsType<Double>(), 0.0001);

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, 'abc', LValue));
end;

procedure TTDataParametersTests.CurrencyFieldTypeProducesCurrencyValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftCurrency, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Currency),
    'ftCurrency must produce a Currency value, not a Double');
  Assert.AreEqual(19.99, Double(LValue.AsType<Currency>()), 0.0001);
end;

procedure TTDataParametersTests.FloatFieldTypeProducesDoubleValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Double),
    'ftFloat must produce a Double value');

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBCD, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Double),
    'ftBCD must produce a Double value');
end;

procedure TTDataParametersTests.BooleanFieldTypeAcceptsTextAndDigits;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'TRUE', LValue));
  Assert.IsTrue(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '1', LValue));
  Assert.IsTrue(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'False', LValue));
  Assert.IsFalse(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '0', LValue));
  Assert.IsFalse(LValue.AsType<Boolean>());
end;

procedure TTDataParametersTests.BooleanFieldTypeRejectsOtherText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'yes', LValue));

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '2', LValue));
end;

procedure TTDataParametersTests.DateTimeFieldTypeConvertsIso8601UtcToLocal;
var
  LValue: TTValue;
  LExpected: TDateTime;
begin
  LExpected := EncodeDateTime(2026, 8, 28, 10, 30, 0, 0);
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDateTime, '2026-08-28T10:30:00.000Z', LValue));
  Assert.AreEqual(
    Double(LExpected),
    Double(TTimeZone.Local.ToUniversalTime(LValue.AsType<TDateTime>())),
    1 / SecsPerDay);
end;

procedure TTDataParametersTests.DateTimeFieldTypeRejectsLocalizedText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDateTime, '28/08/2026 10:30', LValue));
end;

procedure TTDataParametersTests.GuidFieldTypeConvertsBracedForm;
var
  LValue: TTValue;
  LGuid: TGuid;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftGuid, '{2C3F5A81-9D4E-4B27-8A6C-1E0F7B3D5A99}', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(TGuid),
    'ftGuid must produce a TGuid value');

  LGuid := LValue.AsType<TGuid>();
  Assert.AreEqual('{2C3F5A81-9D4E-4B27-8A6C-1E0F7B3D5A99}', LGuid.ToString);
end;

procedure TTDataParametersTests.GuidFieldTypeRejectsNonGuidText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftGuid, 'not-a-guid', LValue));
end;

procedure TTDataParametersTests.BlobFieldTypeHasNoStringConversion;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBlob, 'anything', LValue));
end;

procedure TTDataParametersTests.UnregisteredFieldTypeReturnsFalse;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBytes, 'anything', LValue));
end;

procedure TTDataParametersTests.FailedConversionLeavesResultEmpty;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, 'abc', LValue));
  Assert.IsTrue(LValue.IsEmpty, 'A failed conversion must clear the result');
end;

initialization
  TDUnitX.RegisterTestFixture(TTDataParametersTests);

end.
