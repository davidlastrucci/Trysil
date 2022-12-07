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

{ TDisplayNameAttribute }

  TDisplayNameAttribute = class(TCustomAttribute)
  strict private
    FDisplayName: String;
  public
    constructor Create(const ADisplayName: String);

    property DisplayName: String read FDisplayName;
  end;

{ TValidationAttribute }

  TValidationAttribute = class abstract(TCustomAttribute)
  strict protected
    FErrorMessage: String;

    procedure CheckType<T>(const AColumnName: String; const AValue: TValue);
    function GetErrorMessage(const AMessage: String): String;
  public
    procedure Validate(
      const AColumnName: String; const AValue: TValue); virtual; abstract;
  end;

{ TRequiredAttribute }

  TRequiredAttribute = class(TValidationAttribute)
  strict private
    function IsNullString(const AValue: TValue): Boolean;
    function IsNullDateTime(const AValue: TValue): Boolean;
    function IsNullObject(const AValue: TValue): Boolean;
    function IsNullNullable(const AValue: TValue): Boolean;
  public
    constructor Create; overload;
    constructor Create(const AErrorMessage: String); overload;

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
    constructor Create(const ALength: Integer); overload;
    constructor Create(
      const ALength: Integer; const AErrorMessage: String); overload;

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
      const AValueType: TValidationValueType;
      const AValue: TValue;
      const AErrorMessage: String); overload;

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
    constructor Create(
      const AValue: Integer; const AErrorMessage: String); overload;
    constructor Create(const AValue: Double); overload;
    constructor Create(
      const AValue: Double; const AErrorMessage: String); overload;

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

{ TLessAttribute }

  TLessAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure RaiseException(
      const AColumnName: String; const AValue: String); override;
  end;

{ TGreaterAttribute }

  TGreaterAttribute = class(TValueAttribute)
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
      const AMaxValue: TValue;
      const AErrorMessage: String); overload;

    procedure ValidateInteger(const AColumnName: String; const AValue: TValue);
    procedure ValidateDouble(const AColumnName: String; const AValue: TValue);
  public
    constructor Create(
      const AMinValue: Integer; const AMaxValue: Integer); overload;
    constructor Create(
      const AMinValue: Integer;
      const AMaxValue: Integer;
      const AErrorMessage: String); overload;
    constructor Create(
      const AMinValue: Double; const AMaxValue: Double); overload;
    constructor Create(
      const AMinValue: Double;
      const AMaxValue: Double;
      const AErrorMessage: String); overload;

    procedure Validate(
      const AColumnName: String; const AValue: TValue); override;
  end;

{ TValidatorAttribute }

  TValidatorAttribute = class(TCustomAttribute);

implementation

{ TDisplayNameAttribute }

constructor TDisplayNameAttribute.Create(const ADisplayName: String);
begin
  inherited Create;
  FDisplayName := ADisplayName;
end;

{ TValidationAttribute }

procedure TValidationAttribute.CheckType<T>(
  const AColumnName: String; const AValue: TValue);
begin
  if not AValue.IsType<T> then
    raise ETValidationException.CreateFmt(
      GetErrorMessage(SNotInvalidTypeValidation), [AColumnName]);
end;

function TValidationAttribute.GetErrorMessage(const AMessage: String): String;
begin
  result := FErrorMessage;
  if result.IsEmpty then
    result := AMessage;
end;

{ TRequiredAttribute }

constructor TRequiredAttribute.Create;
begin
  inherited Create;
end;

constructor TRequiredAttribute.Create(const AErrorMessage: String);
begin
  Create;
  FErrorMessage := AErrorMessage;
end;

function TRequiredAttribute.IsNullString(const AValue: TValue): Boolean;
begin
  result := AValue.IsType<String>() and AValue.AsType<String>().IsEmpty;
end;

function TRequiredAttribute.IsNullDateTime(const AValue: TValue): Boolean;
begin
  result := AValue.IsType<TDateTime>() and (AValue.AsType<TDateTime> = 0);
end;

function TRequiredAttribute.IsNullObject(const AValue: TValue): Boolean;
var
  LObject: TObject;
  LRttiLazy: TTRttiLazy;
begin
  result := False;
  if AValue.IsType<TObject>() then
  begin
    LObject := AValue.AsType<TObject>();
    if TTRttiLazy.IsLazy(LObject) then
    begin
      LRttiLazy := TTRttiLazy.Create(LObject);
      try
        result := not Assigned(LRttiLazy.ObjectValue);
      finally
        LRttiLazy.Free;
      end;
    end;
  end;
end;

function TRequiredAttribute.IsNullNullable(const AValue: TValue): Boolean;
begin
  result := AValue.IsNull;
end;

procedure TRequiredAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  if IsNullString(AValue) or IsNullObject(AValue) or
    IsNullDateTime(AValue) or IsNullNullable(AValue) then
    raise ETValidationException.CreateFmt(
      GetErrorMessage(SRequiredValidation), [AColumnName]);
end;

{ TLengthAttribute }

constructor TLengthAttribute.Create(const ALength: Integer);
begin
  inherited Create;
  FLength := ALength;
end;

constructor TLengthAttribute.Create(
  const ALength: Integer; const AErrorMessage: String);
begin
  Create(ALength);
  FErrorMessage := AErrorMessage;
end;

procedure TLengthAttribute.Validate(
  const AColumnName: String; const AValue: TValue);
begin
  CheckType<String>(AColumnName, AValue);
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
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SMaxLengthValidation), [AColumnName, FLength]);
end;

{ TMinLengthAttribute }

function TMinLengthAttribute.IsValid(const AValue: String): Boolean;
begin
  result := AValue.Length >= FLength;
end;

procedure TMinLengthAttribute.RaiseException(const AColumnName: String);
begin
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SMinLengthValidation), [AColumnName, FLength]);
end;

{ TValueAttribute }

constructor TValueAttribute.Create(
  const AValueType: TValidationValueType;
  const AValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create;
  FValueType := AValueType;
  FValue := AValue;
  FErrorMessage := AErrorMessage;
end;

constructor TValueAttribute.Create(const AValue: Integer);
begin
  Create(TValidationValueType.vvtInteger, AValue, String.Empty);
end;

constructor TValueAttribute.Create(
  const AValue: Integer; const AErrorMessage: String);
begin
  Create(TValidationValueType.vvtInteger, AValue, AErrorMessage);
end;

constructor TValueAttribute.Create(const AValue: Double);
begin
  Create(TValidationValueType.vvtDouble, AValue, String.Empty);
end;

constructor TValueAttribute.Create(
  const AValue: Double; const AErrorMessage: String);
begin
  Create(TValidationValueType.vvtDouble, AValue, AErrorMessage);
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
  CheckType<Integer>(AColumnName, AValue);
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
  CheckType<Double>(AColumnName, AValue);
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
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SMinValueValidation), [AColumnName, AValue]);
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
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SMaxValueValidation), [AColumnName, AValue]);
end;

{ TLessAttribute }

function TLessAttribute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 < AValue2);
end;

function TLessAttribute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 < AValue2);
end;

procedure TLessAttribute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SLessValidation), [AColumnName, AValue]);
end;

{ TGreaterAttribute }

function TGreaterAttribute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 > AValue2);
end;

function TGreaterAttribute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 > AValue2);
end;

procedure TGreaterAttribute.RaiseException(
  const AColumnName: String; const AValue: String);
begin
  raise ETValidationException.CreateFmt(
    GetErrorMessage(SGreaterValidation), [AColumnName, AValue]);
end;

{ TRangeAttribute }

constructor TRangeAttribute.Create(
  const AValueType: TValidationValueType;
  const AMinValue: TValue;
  const AMaxValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create;
  FValueType := AValueType;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
  FErrorMessage := AErrorMessage;
end;

constructor TRangeAttribute.Create(
  const AMinValue: Integer; const AMaxValue: Integer);
begin
  Create(TValidationValueType.vvtInteger, AMinValue, AMaxValue, String.Empty);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Integer;
  const AMaxValue: Integer;
  const AErrorMessage: String);
begin
  Create(TValidationValueType.vvtInteger, AMinValue, AMaxValue, AErrorMessage);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double; const AMaxValue: Double);
begin
  Create(TValidationValueType.vvtDouble, AMinValue, AMaxValue, String.Empty);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double;
  const AMaxValue: Double;
  const AErrorMessage: String);
begin
  Create(TValidationValueType.vvtDouble, AMinValue, AMaxValue, AErrorMessage);
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
  CheckType<Integer>(AColumnName, AValue);
  LValue := AValue.AsType<Integer>;
  LMinValue := FMinValue.AsType<Integer>;
  LMaxValue := FMaxValue.AsType<Integer>;
  if (LValue < LMinValue) or (LValue > LMaxValue) then
    raise ETValidationException.CreateFmt(GetErrorMessage(SRangeValidation), [
      AColumnName, LMinValue.ToString(), LMaxValue.ToString()]);
end;

procedure TRangeAttribute.ValidateDouble(
  const AColumnName: String; const AValue: TValue);
var
  LValue, LMinValue, LMaxValue: Double;
begin
  CheckType<Double>(AColumnName, AValue);
  LValue := AValue.AsType<Double>;
  LMinValue := FMinValue.AsType<Double>;
  LMaxValue := FMaxValue.AsType<Double>;
  if (LValue < LMinValue) or (LValue > LMaxValue) then
    raise ETValidationException.CreateFmt(GetErrorMessage(SRangeValidation), [
      AColumnName, LMinValue.ToString(), LMaxValue.ToString()]);
end;

end.
