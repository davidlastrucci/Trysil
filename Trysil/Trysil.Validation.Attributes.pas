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

  TLengthAttribute = class(TValidationAttribute)
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

{ TRangeAttribute }

  TRangeAttribute = class(TValidationAttribute)
  strict private
    type TRangeValueType = (rvtInteger, rvtDouble, rvtDateTime);
  strict private
    FValueType: TRangeValueType;
    FMinValue: TValue;
    FMaxValue: TValue;

    constructor Create(
      const AValueType: TRangeValueType;
      const AMinValue: TValue;
      const AMaxValue: TValue); overload;

    procedure ValidateInteger(const AColumnName: String; const AValue: TValue);
    procedure ValidateDouble(const AColumnName: String; const AValue: TValue);
    procedure ValidateDateTime(const AColumnName: String; const AValue: TValue);
  public
    constructor Create(
      const AMinValue: Integer; const AMaxValue: Integer); overload;
    constructor Create(
      const AMinValue: Double; const AMaxValue: Double); overload;
    constructor Create(
      const AMinValue: TDateTime; const AMaxValue: TDateTime); overload;

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
  if AValue.IsNull then
    raise ETException.CreateFmt(SRequiredValidation, [AColumnName])
  else if AValue.IsType<String> and AValue.AsType<String>.IsEmpty then
    raise ETException.CreateFmt(SRequiredStringValidation, [AColumnName])
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

{ TRangeAttribute }

constructor TRangeAttribute.Create(
  const AValueType: TRangeValueType;
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
  Create(TRangeValueType.rvtInteger, AMinValue, AMaxValue);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double; const AMaxValue: Double);
begin
  Create(TRangeValueType.rvtDouble, AMinValue, AMaxValue);
end;

constructor TRangeAttribute.Create(
  const AMinValue: TDateTime; const AMaxValue: TDateTime);
begin
  Create(TRangeValueType.rvtDateTime, AMinValue, AMaxValue);
end;

procedure TRangeAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  case FValueType of
    TRangeValueType.rvtInteger:
      ValidateInteger(AColumnName, AValue);

    TRangeValueType.rvtDouble:
      ValidateDouble(AColumnName, AValue);

    TRangeValueType.rvtDateTime:
      ValidateDateTime(AColumnName, AValue);
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

procedure TRangeAttribute.ValidateDateTime(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue, LMaxValue: TDateTime;
begin
  if not AValue.IsType<TDateTime> then
    raise ETException.CreateFmt(SNotInvalidTypeValidation, [AColumnName]);
  LValue := AValue.AsType<TDateTime>;
  LMinValue := FMinValue.AsType<TDateTime>;
  LMaxValue := FMaxValue.AsType<TDateTime>;
  if (LValue < LMinValue) or (LValue > LMaxValue) then
    raise ETException.CreateFmt(SRangeValidation, [
      AColumnName, DateToStr(LMinValue), DateToStr(LMaxValue)]);
end;

end.
