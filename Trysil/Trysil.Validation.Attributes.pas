(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Validation.Attributes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,

  Trysil.Rtti,
  Trysil.Exceptions,
  Trysil.Consts;

type

{ TValidationAttribute }

  TValidationAttribute = class abstract(TCustomAttribute)
  public
    procedure Validate(
      const AColumnName: String; const AValue: TValue); virtual; abstract;
  end;

{ TRequiredAttribute }

  TRequiredAttribute = class(TValidationAttribute)
  public
    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TLengthAttribute }

  TLengthAttribute = class abstract(TValidationAttribute)
  strict protected
    FLength: Integer;

    function IsValid(const AValue: String): Boolean; virtual; abstract;
    procedure RaiseException(const AColumnName: String); virtual; abstract;
  public
    constructor Create(const ALength: Integer);

    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TMaxLengthAttribute }

  TMaxLengthAttribute = class(TLengthAttribute)
  strict protected
    function IsValid(const AValue: String): Boolean; override;
    procedure RaiseException(const AColumnName: String); override;
  end;

{ TMinLengthAttribute }

  TMinLengthAttribute = class(TLengthAttribute)
  strict protected
    function IsValid(const AValue: String): Boolean; override;
    procedure RaiseException(const AColumnName: String); override;
  end;

{ TValidationValueType }

  TValidationValueType = (vvtInteger, vvtDouble);

{ TValueAttibute }

  TValueAttribute = class abstract(TValidationAttribute)
  strict private
    FValueType: TValidationValueType;
    FValue: TValue;

    constructor Create(
      const AValueType: TValidationValueType; const AValue: TValue); overload;

    procedure ValidateInteger(const AColumnName: String; const AValue: TValue);
    procedure ValidateDouble(const AColumnName: String; const AValue: TValue);
  strict protected
    function IsValidInteger(
      const AValue1: Integer;
      const AValue2: Integer): Boolean; virtual; abstract;
    function IsValidDouble(
      const AValue1: Double;
      const AValue2: Double): Boolean; virtual; abstract;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); virtual; abstract;
  public
    constructor Create(const AValue: Integer); overload;
    constructor Create(const AValue: Double); overload;

    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TMinValueAttibute }

  TMinValueAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); override;
  end;

{ TMaxValueAttibute }

  TMaxValueAttibute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); override;
  end;

{ TLessAttibute }

  TLessAttibute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); override;
  end;

{ TGreaterAttibute }

  TGreaterAttibute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); override;
  end;

{ TRangeAttribute }

  TRangeAttribute = class(TValidationAttribute)
  strict private
    FValueType: TValidationValueType;
    FMinValue: TValue;
    FMaxValue: TValue;

    constructor Create(
      const AValueType: TValidationValueType;
      const AMinValue: TValue;
      const AMaxValue: TValue); overload;

    procedure ValidateInteger(const AColumnName: String; const AValue: TValue);
    procedure ValidateDouble(const AColumnName: String; const AValue: TValue);
  public
    constructor Create(
      const AMinValue: Integer; const AMaxValue: Integer); overload;
    constructor Create(
      const AMinValue: Double; const AMaxValue: Double); overload;

    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TValidatorAttribute }

  TValidatorAttribute = class(TCustomAttribute);

implementation

{ TRequiredAttribute }

procedure TRequiredAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  if AValue.IsType<String> and AValue.AsType<String>.IsEmpty then
    raise ETException.CreateFmt(SRequiredStringValidation, [AColumnName])
  else if AValue.IsType<TDateTime> and (AValue.AsType<TDateTime> = 0) then
    raise ETException.CreateFmt(SRequiredValidation, [AColumnName])
  else if AValue.IsNull then
    raise ETException.CreateFmt(SRequiredValidation, [AColumnName]);
end;

{ TLengthAttribute }

constructor TLengthAttribute.Create(const ALength: Integer);
begin
  inherited Create;
  FLength := ALength;
end;

procedure TLengthAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  if not AValue.IsType<String> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  if not IsValid(AValue.AsType<String>()) then
    RaiseException(AColumnName);
end;

{ TMaxLengthAttribute }

function TMaxLengthAttribute.IsValid(const AValue: String): Boolean;
begin
  result := AValue.Length <= FLength;
end;

procedure TMaxLengthAttribute.RaiseException(const AColumnName: String);
begin
  raise ETException.CreateFmt(SMaxLengthValidation, [AColumnName, FLength]);
end;

{ TMinLengthAttribute }

function TMinLengthAttribute.IsValid(const AValue: String): Boolean;
begin
  result := AValue.Length >= FLength;
end;

procedure TMinLengthAttribute.RaiseException(const AColumnName: String);
begin
  raise ETException.CreateFmt(SMinLengthValidation, [AColumnName, FLength]);
end;

{ TValueAttribute }

constructor TValueAttribute.Create(
  const AValueType: TValidationValueType; const AValue: TValue);
begin
  inherited Create;
  FValueType := AValueType;
  FValue := AValue;
end;

constructor TValueAttribute.Create(const AValue: Integer);
begin
  Create(TValidationValueType.vvtInteger, AValue);
end;

constructor TValueAttribute.Create(const AValue: Double);
begin
  Create(TValidationValueType.vvtDouble, AValue);
end;

procedure TValueAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  case FValueType of
    TValidationValueType.vvtInteger:
      ValidateInteger(AColumnName, AValue);

    TValidationValueType.vvtDouble:
      ValidateDouble(AColumnName, AValue);
  end;
end;

procedure TValueAttribute.ValidateInteger(
  const AColumnName: String; const AValue: TValue);
var
  LValue1, LValue2: Integer;
begin
  if not AValue.IsType<Integer> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue1 := AValue.AsType<Integer>;
  LValue2 := FValue.AsType<Integer>;
  if not IsValidInteger(LValue1, LValue2) then
    RaiseException(AColumnName, LValue2.ToString());
end;

procedure TValueAttribute.ValidateDouble(
  const AColumnName: String; const AValue: TValue);
var
  LValue1, LValue2: Double;
begin
  if not AValue.IsType<Double> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue1 := AValue.AsType<Double>;
  LValue2 := FValue.AsType<Double>;
  if not IsValidDouble(LValue1, LValue2) then
    RaiseException(AColumnName, LValue2.ToString());
end;

{ TMinValueAttribute }

function TMinValueAttribute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 >= AValue2);
end;

function TMinValueAttribute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 >= AValue2);
end;

procedure TMinValueAttribute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETException.CreateFmt(SMinValueValidation, [AColumnName, AValue]);
end;

{ TMaxValueAttibute }

function TMaxValueAttibute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 <= AValue2);
end;

function TMaxValueAttibute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 <= AValue2);
end;

procedure TMaxValueAttibute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETException.CreateFmt(SMaxValueValidation, [AColumnName, AValue]);
end;

{ TLessAttibute }

function TLessAttibute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 < AValue2);
end;

function TLessAttibute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 < AValue2);
end;

procedure TLessAttibute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETException.CreateFmt(SLessValidation, [AColumnName, AValue]);
end;

{ TGreaterAttibute }

function TGreaterAttibute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 > AValue2);
end;

function TGreaterAttibute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 > AValue2);
end;

procedure TGreaterAttibute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETException.CreateFmt(SGreaterValidation, [AColumnName, AValue]);
end;

{ TRangeAttribute }

constructor TRangeAttribute.Create(
  const AValueType: TValidationValueType;
  const AMinValue: TValue;
  const AMaxValue: TValue);
begin
  inherited Create;
  FValueType := AValueType;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
end;

constructor TRangeAttribute.Create(
  const AMinValue: Integer; const AMaxValue: Integer);
begin
  Create(TValidationValueType.vvtInteger, AMinValue, AMaxValue);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double; const AMaxValue: Double);
begin
  Create(TValidationValueType.vvtDouble, AMinValue, AMaxValue);
end;

procedure TRangeAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  case FValueType of
    TValidationValueType.vvtInteger:
      ValidateInteger(AColumnName, AValue);

    TValidationValueType.vvtDouble:
      ValidateDouble(AColumnName, AValue);
  end;
end;

procedure TRangeAttribute.ValidateInteger(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue, LMaxValue: Integer;
begin
  if not AValue.IsType<Integer> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Integer>;
  LMinValue := FMinValue.AsType<Integer>;
  LMaxValue := FMaxValue.AsType<Integer>;
  if (LValue < LMinValue) or (LValue > LMaxValue) then
    raise ETException.CreateFmt(SRangeValidation, [
      AColumnName, LMinValue.ToString(), LMaxValue.ToString()]);
end;

procedure TRangeAttribute.ValidateDouble(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue, LMaxValue: Double;
begin
  if not AValue.IsType<Double> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Double>;
  LMinValue := FMinValue.AsType<Double>;
  LMaxValue := FMaxValue.AsType<Double>;
  if (LValue < LMinValue) or (LValue > LMaxValue) then
    raise ETException.CreateFmt(SRangeValidation, [
      AColumnName, LMinValue.ToString(), LMaxValue.ToString()]);
end;

end.
