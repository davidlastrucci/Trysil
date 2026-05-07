(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Validation;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractValidationTests }

  TTAbstractValidationTests = class(TTAbstractBaseTests)
  public
    [Test]
    procedure ValidateAcceptsValidEntity;

    [Test]
    procedure ValidateRequiredFieldEmptyRaisesValidationException;

    [Test]
    procedure ValidateMaxLengthExceededRaisesValidationException;

    [Test]
    procedure InsertWithInvalidEntityRaisesValidationException;

    [Test]
    procedure ValidationExceptionMessageContainsColumnName;

    { Advanced validation attributes }

    [Test]
    procedure MinLengthAcceptsLongEnoughString;

    [Test]
    procedure MinLengthRejectsShortString;

    [Test]
    procedure RangeAcceptsValueInBounds;

    [Test]
    procedure RangeRejectsBelowMinimum;

    [Test]
    procedure RangeRejectsAboveMaximum;

    [Test]
    procedure MinValueRejectsBelowMinimum;

    [Test]
    procedure MaxValueRejectsAboveMaximum;

    [Test]
    procedure LessRejectsEqualValue;

    [Test]
    procedure GreaterRejectsZero;

    [Test]
    procedure RegexAcceptsMatchingPattern;

    [Test]
    procedure RegexRejectsNonMatchingPattern;

    [Test]
    procedure EmailAcceptsValidAddress;

    [Test]
    procedure EmailRejectsInvalidAddress;

    [Test]
    procedure FullValidationAcceptsAllValidFields;

    { Custom validator }

    [Test]
    procedure CustomValidatorAcceptsValidName;

    [Test]
    procedure CustomValidatorRejectsAdminName;

    [Test]
    procedure CustomValidatorBlocksInsert;
  end;

implementation

{ Helpers }

procedure SetValidDefaults(const AItem: TTestFullValidation);
begin
  AItem.Code := 'ABC';
  AItem.Score := 50;
  AItem.Quantity := 10;
  AItem.Price := 500.0;
  AItem.Discount := 25;
  AItem.Weight := 1.5;
  AItem.Phone := '123-4567';
  AItem.Email := 'test@example.com';
end;

{ TTAbstractValidationTests }

procedure TTAbstractValidationTests.ValidateAcceptsValidEntity;
var
  LItem: TTestValidatedItem;
begin
  LItem := FContext.CreateEntity<TTestValidatedItem>();
  LItem.Name := 'Valid';
  LItem.Code := 'OK';
  FContext.Validate<TTestValidatedItem>(LItem);
  Assert.Pass('Validate must not raise on a valid entity');
end;

procedure TTAbstractValidationTests.ValidateRequiredFieldEmptyRaisesValidationException;
var
  LItem: TTestValidatedItem;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestValidatedItem>();
  LItem.Name := String.Empty;
  LItem.Code := 'OK';

  LRaised := False;
  try
    FContext.Validate<TTestValidatedItem>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Validate must raise ETValidationException when required field is empty');
end;

procedure TTAbstractValidationTests.ValidateMaxLengthExceededRaisesValidationException;
var
  LItem: TTestValidatedItem;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestValidatedItem>();
  LItem.Name := 'Valid';
  LItem.Code := 'ThisCodeIsWayTooLong';

  LRaised := False;
  try
    FContext.Validate<TTestValidatedItem>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Validate must raise ETValidationException when MaxLength is exceeded');
end;

procedure TTAbstractValidationTests.InsertWithInvalidEntityRaisesValidationException;
var
  LItem: TTestValidatedItem;
  LRaised: Boolean;
  LCount: Integer;
begin
  LItem := FContext.CreateEntity<TTestValidatedItem>();
  LItem.Name := String.Empty;
  LItem.Code := 'X';

  LRaised := False;
  try
    FContext.Insert<TTestValidatedItem>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Insert must trigger validation and raise ETValidationException');

  LCount := FContext.SelectCount<TTestValidatedItem>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'No row must be persisted when validation fails');
end;

procedure TTAbstractValidationTests.ValidationExceptionMessageContainsColumnName;
var
  LItem: TTestValidatedItem;
  LMessage: String;
begin
  LItem := FContext.CreateEntity<TTestValidatedItem>();
  LItem.Name := String.Empty;
  LItem.Code := 'OK';

  LMessage := String.Empty;
  try
    FContext.Validate<TTestValidatedItem>(LItem);
  except
    on E: ETValidationException do
      LMessage := E.Message;
  end;

  Assert.IsTrue(LMessage.Contains('Name'),
    Format('Validation message must reference the failing column. Got: "%s"',
      [LMessage]));
end;

{ Advanced validation attributes }

procedure TTAbstractValidationTests.MinLengthAcceptsLongEnoughString;
var
  LItem: TTestFullValidation;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Code := 'ABCDE';
  FContext.Validate<TTestFullValidation>(LItem);
  Assert.Pass;
end;

procedure TTAbstractValidationTests.MinLengthRejectsShortString;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Code := 'AB';

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'MinLength must reject strings shorter than 3');
end;

procedure TTAbstractValidationTests.RangeAcceptsValueInBounds;
var
  LItem: TTestFullValidation;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Score := 50;
  FContext.Validate<TTestFullValidation>(LItem);
  Assert.Pass;
end;

procedure TTAbstractValidationTests.RangeRejectsBelowMinimum;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Score := 0;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Range(1,100) must reject 0');
end;

procedure TTAbstractValidationTests.RangeRejectsAboveMaximum;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Score := 101;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Range(1,100) must reject 101');
end;

procedure TTAbstractValidationTests.MinValueRejectsBelowMinimum;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Quantity := -1;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'MinValue(0) must reject -1');
end;

procedure TTAbstractValidationTests.MaxValueRejectsAboveMaximum;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Price := 1001.0;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'MaxValue(1000) must reject 1001');
end;

procedure TTAbstractValidationTests.LessRejectsEqualValue;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Discount := 50;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Less(50) must reject 50 (strict less than)');
end;

procedure TTAbstractValidationTests.GreaterRejectsZero;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Weight := 0.0;

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Greater(0) must reject 0 (strict greater than)');
end;

procedure TTAbstractValidationTests.RegexAcceptsMatchingPattern;
var
  LItem: TTestFullValidation;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Phone := '123-4567';
  FContext.Validate<TTestFullValidation>(LItem);
  Assert.Pass;
end;

procedure TTAbstractValidationTests.RegexRejectsNonMatchingPattern;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Phone := 'not-a-phone';

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'Regex ^\d{3}-\d{4}$ must reject non-matching string');
end;

procedure TTAbstractValidationTests.EmailAcceptsValidAddress;
var
  LItem: TTestFullValidation;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Email := 'user@domain.com';
  FContext.Validate<TTestFullValidation>(LItem);
  Assert.Pass;
end;

procedure TTAbstractValidationTests.EmailRejectsInvalidAddress;
var
  LItem: TTestFullValidation;
  LRaised: Boolean;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  LItem.Email := 'not-an-email';

  LRaised := False;
  try
    FContext.Validate<TTestFullValidation>(LItem);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'EMail must reject invalid address');
end;

procedure TTAbstractValidationTests.FullValidationAcceptsAllValidFields;
var
  LItem: TTestFullValidation;
begin
  LItem := FContext.CreateEntity<TTestFullValidation>();
  SetValidDefaults(LItem);
  FContext.Validate<TTestFullValidation>(LItem);
  Assert.Pass('All valid fields must pass validation');
end;

{ Custom validator }

procedure TTAbstractValidationTests.CustomValidatorAcceptsValidName;
var
  LCustomer: TTestCustomValidatedCustomer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomValidatedCustomer>();
  LCustomer.Name := 'Alice';
  FContext.Validate<TTestCustomValidatedCustomer>(LCustomer);
  Assert.Pass;
end;

procedure TTAbstractValidationTests.CustomValidatorRejectsAdminName;
var
  LCustomer: TTestCustomValidatedCustomer;
  LRaised: Boolean;
begin
  LCustomer := FContext.CreateEntity<TTestCustomValidatedCustomer>();
  LCustomer.Name := 'admin';

  LRaised := False;
  try
    FContext.Validate<TTestCustomValidatedCustomer>(LCustomer);
  except
    on E: ETValidationException do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised,
    'Custom validator must reject name "admin"');
end;

procedure TTAbstractValidationTests.CustomValidatorBlocksInsert;
var
  LCustomer: TTestCustomValidatedCustomer;
  LRaised: Boolean;
  LCount: Integer;
begin
  LCustomer := FContext.CreateEntity<TTestCustomValidatedCustomer>();
  LCustomer.Name := 'admin';

  LRaised := False;
  try
    FContext.Insert<TTestCustomValidatedCustomer>(LCustomer);
  except
    on E: ETValidationException do
      LRaised := True;
  end;

  Assert.IsTrue(LRaised,
    'Insert must trigger custom validator and raise');
  LCount := FContext.SelectCount<TTestCustomValidatedCustomer>(TTFilter.Empty);
  Assert.AreEqual<Integer>(0, LCount,
    'No row must be persisted when custom validator fails');
end;

end.
