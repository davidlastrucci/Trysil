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
  public
    constructor Create(const ALength: Integer);
  end;

{ TMaxLengthAttribute }

  TMaxLengthAttribute = class(TLengthAttribute)
  public
    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TMinLengthAttribute }

  TMinLengthAttribute = class(TLengthAttribute)
  public
    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TValidationValueType }

  TValidationValueType = (vvtInteger, vvtDouble);

{ TValueAttibute }

  TValueAttribute = class abstract(TValidationAttribute)
  strict private
    FValueType: TValidationValueType;

    constructor Create(
      const AValueType: TValidationValueType; const AValue: TValue); overload;
  strict protected
    FValue: TValue;

    procedure ValidateInteger(
      const AColumnName: String; const AValue: TValue); virtual; abstract;
    procedure ValidateDouble(
      const AColumnName: String; const AValue: TValue); virtual; abstract;
  public
    constructor Create(const AValue: Integer); overload;
    constructor Create(const AValue: Double); overload;

    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TMinValueAttibute }

  TMinValueAttribute = class(TValueAttribute)
  strict protected
    procedure ValidateInteger(
      const AColumnName: String; const AValue: TValue); override;
    procedure ValidateDouble(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TMaxValueAttibute }

  TMaxValueAttibute = class(TValueAttribute)
  strict protected
    procedure ValidateInteger(
      const AColumnName: String; const AValue: TValue); override;
    procedure ValidateDouble(
      const AColumnName: String; const AValue: TValue); override;
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

{ TMaxLengthAttribute }

procedure TMaxLengthAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  if not AValue.IsType<String> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  if AValue.AsType<String>().Length > FLength then
    raise ETException.CreateFmt(SMaxLengthValidation, [AColumnName, FLength]);
end;

{ TMinLengthAttribute }

procedure TMinLengthAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  if not AValue.IsType<String> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  if AValue.AsType<String>().Length < FLength then
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

{ TMinValueAttribute }

procedure TMinValueAttribute.ValidateInteger(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue: Integer;
begin
  if not AValue.IsType<Integer> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Integer>;
  LMinValue := FValue.AsType<Integer>;
  if (LValue < LMinValue) then
    raise ETException.CreateFmt(SMinValueValidation, [
      AColumnName, LMinValue.ToString()]);
end;

procedure TMinValueAttribute.ValidateDouble(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue: Double;
begin
  if not AValue.IsType<Double> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Double>;
  LMinValue := FValue.AsType<Double>;
  if (LValue < LMinValue) then
    raise ETException.CreateFmt(SMinValueValidation, [
      AColumnName, LMinValue.ToString()]);
end;

{ TMaxValueAttibute }

procedure TMaxValueAttibute.ValidateInteger(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMaxValue: Integer;
begin
  if not AValue.IsType<Integer> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Integer>;
  LMaxValue := FValue.AsType<Integer>;
  if (LValue > LMaxValue) then
    raise ETException.CreateFmt(SMinValueValidation, [
      AColumnName, LMaxValue.ToString()]);
end;

procedure TMaxValueAttibute.ValidateDouble(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMaxValue: Double;
begin
  if not AValue.IsType<Double> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<Double>;
  LMaxValue := FValue.AsType<Double>;
  if (LValue > LMaxValue) then
    raise ETException.CreateFmt(SMinValueValidation, [
      AColumnName, LMaxValue.ToString()]);
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
