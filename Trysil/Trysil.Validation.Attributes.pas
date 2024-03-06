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
  System.RegularExpressions,

  Trysil.Rtti,
  Trysil.Consts,
  Trysil.Validation;

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
  strict private
    FErrorMessage: String;
  strict protected
    function CheckType<T>(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors): Boolean;
    function NullableValueToString(const AValue: TValue): TValue;
    function GetErrorMessage(const AMessage: String): String;
  public
    constructor Create(const AErrorMessage: String);

    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); virtual; abstract;
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
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); override;
  end;

{ TLengthAttribute }

  TLengthAttribute = class abstract(TValidationAttribute)
  strict protected
    FLength: Integer;

    function IsValid(const AValue: String): Boolean; virtual; abstract;
    procedure AddValidationError(
      const AColumnName: String;
      const AErrors: TTValidationErrors); virtual; abstract;
  public
    constructor Create(const ALength: Integer); overload;
    constructor Create(
      const ALength: Integer; const AErrorMessage: String); overload;

    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); override;
  end;

{ TMaxLengthAttribute }

  TMaxLengthAttribute = class(TLengthAttribute)
  strict protected
    function IsValid(const AValue: String): Boolean; override;
    procedure AddValidationError(
      const AColumnName: String;
      const AErrors: TTValidationErrors); override;
  end;

{ TMinLengthAttribute }

  TMinLengthAttribute = class(TLengthAttribute)
  strict protected
    function IsValid(const AValue: String): Boolean; override;
    procedure AddValidationError(
      const AColumnName: String;
      const AErrors: TTValidationErrors); override;
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

    procedure ValidateInteger(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
    procedure ValidateDouble(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
  strict protected
    function IsValidInteger(
      const AValue1: Integer;
      const AValue2: Integer): Boolean; virtual; abstract;
    function IsValidDouble(
      const AValue1: Double;
      const AValue2: Double): Boolean; virtual; abstract;

    procedure AddValidationError(
      const AColumnName: String;
      const AValue: String;
      const AErrors: TTValidationErrors); virtual; abstract;
  public
    constructor Create(const AValue: Integer); overload;
    constructor Create(
      const AValue: Integer; const AErrorMessage: String); overload;
    constructor Create(const AValue: Double); overload;
    constructor Create(
      const AValue: Double; const AErrorMessage: String); overload;

    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); override;
  end;

{ TMinValueAttibute }

  TMinValueAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure AddValidationError(
      const AColumnName: String;
      const AValue: String;
      const AErrors: TTValidationErrors); override;
  end;

{ TMaxValueAttribute }

  TMaxValueAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure AddValidationError(
      const AColumnName: String;
      const AValue: String;
      const AErrors: TTValidationErrors); override;
  end;

{ TLessAttribute }

  TLessAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure AddValidationError(
      const AColumnName: String;
      const AValue: String;
      const AErrors: TTValidationErrors); override;
  end;

{ TGreaterAttribute }

  TGreaterAttribute = class(TValueAttribute)
  strict protected
    function IsValidInteger(
      const AValue1: Integer; const AValue2: Integer): Boolean; override;
    function IsValidDouble(
      const AValue1: Double; const AValue2: Double): Boolean; override;

    procedure AddValidationError(
      const AColumnName: String;
      const AValue: String;
      const AErrors: TTValidationErrors); override;
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

    procedure ValidateInteger(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
    procedure ValidateDouble(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
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
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); override;
  end;

{ TRegexAttribute }

  TRegexAttribute = class(TValidationAttribute)
  strict private
    FRegex: string;
  public
    constructor Create(const ARegex: String); overload;
    constructor Create(
      const ARegex: String; const AErrorMessage: String); overload;

    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors); override;
  end;

{ TEMailAttribute }

  TEMailAttribute = class(TRegexAttribute)
  strict private
    const EmailRegex: string = '^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$';
  public
    constructor Create; overload;
    constructor Create(const AErrorMessage: String); overload;
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

constructor TValidationAttribute.Create(const AErrorMessage: String);
begin
  inherited Create;
  FErrorMessage := AErrorMessage;
end;

function TValidationAttribute.CheckType<T>(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors): Boolean;
begin
  result := AValue.IsType<T>;
  if not result then
    AErrors.Add(
      AColumnName,
      Format(GetErrorMessage(SNotInvalidTypeValidation), [AColumnName]));
end;

function TValidationAttribute.GetErrorMessage(const AMessage: String): String;
begin
  result := FErrorMessage;
  if result.IsEmpty then
    result := AMessage;
end;

function TValidationAttribute.NullableValueToString(
  const AValue: TValue): TValue;
begin
  if AValue.IsNullable then
    result := TValue.From<String>(AValue.NullableValueToString)
  else
    result := AValue;
end;

{ TRequiredAttribute }

constructor TRequiredAttribute.Create;
begin
  Create(String.Empty);
end;

constructor TRequiredAttribute.Create(const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
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
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
begin
  if IsNullString(AValue) or IsNullObject(AValue) or
    IsNullDateTime(AValue) or IsNullNullable(AValue) then
    AErrors.Add(
      AColumnName,
      Format(GetErrorMessage(SRequiredValidation), [AColumnName]));
end;

{ TLengthAttribute }

constructor TLengthAttribute.Create(const ALength: Integer);
begin
  Create(ALength, String.Empty);
end;

constructor TLengthAttribute.Create(
  const ALength: Integer; const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FLength := ALength;
end;

procedure TLengthAttribute.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue: TValue;
begin
  LValue := NullableValueToString(AValue);
  if CheckType<String>(AColumnName, LValue, AErrors) and
    (not IsValid(LValue.AsType<String>())) then
      AddValidationError(AColumnName, AErrors);
end;

{ TMaxLengthAttribute }

function TMaxLengthAttribute.IsValid(const AValue: String): Boolean;
begin
  result := AValue.Length <= FLength;
end;

procedure TMaxLengthAttribute.AddValidationError(
  const AColumnName: String; const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SMaxLengthValidation), [AColumnName, FLength]));
end;

{ TMinLengthAttribute }

function TMinLengthAttribute.IsValid(const AValue: String): Boolean;
begin
  result := AValue.Length >= FLength;
end;

procedure TMinLengthAttribute.AddValidationError(
  const AColumnName: String; const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SMinLengthValidation), [AColumnName, FLength]));
end;

{ TValueAttribute }

constructor TValueAttribute.Create(
  const AValueType: TValidationValueType;
  const AValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FValueType := AValueType;
  FValue := AValue;
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
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
begin
  case FValueType of
    TValidationValueType.vvtInteger:
      ValidateInteger(AColumnName, AValue, AErrors);

    TValidationValueType.vvtDouble:
      ValidateDouble(AColumnName, AValue, AErrors);
  end;
end;

procedure TValueAttribute.ValidateInteger(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue1, LValue2: Integer;
begin
  if CheckType<Integer>(AColumnName, AValue, AErrors) then
  begin
    LValue1 := AValue.AsType<Integer>;
    LValue2 := FValue.AsType<Integer>;
    if not IsValidInteger(LValue1, LValue2) then
      AddValidationError(AColumnName, LValue2.ToString(), AErrors);
  end;
end;

procedure TValueAttribute.ValidateDouble(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue1, LValue2: Double;
begin
  if CheckType<Double>(AColumnName, AValue, AErrors) then
  begin
    LValue1 := AValue.AsType<Double>;
    LValue2 := FValue.AsType<Double>;
    if not IsValidDouble(LValue1, LValue2) then
      AddValidationError(AColumnName, LValue2.ToString(), AErrors);
  end;
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

procedure TMinValueAttribute.AddValidationError(
  const AColumnName: String;
  const AValue: String;
  const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SMinValueValidation), [AColumnName, AValue]));
end;

{ TMaxValueAttribute }

function TMaxValueAttribute.IsValidInteger(
  const AValue1: Integer; const AValue2: Integer): Boolean;
begin
  result := (AValue1 <= AValue2);
end;

function TMaxValueAttribute.IsValidDouble(
  const AValue1: Double; const AValue2: Double): Boolean;
begin
  result := (AValue1 <= AValue2);
end;

procedure TMaxValueAttribute.AddValidationError(
  const AColumnName: String;
  const AValue: String;
  const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SMaxValueValidation), [AColumnName, AValue]));
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

procedure TLessAttribute.AddValidationError(
  const AColumnName: String;
  const AValue: String;
  const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SLessValidation), [AColumnName, AValue]));
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

procedure TGreaterAttribute.AddValidationError(
  const AColumnName: String;
  const AValue: String;
  const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SGreaterValidation), [AColumnName, AValue]));
end;

{ TRangeAttribute }

constructor TRangeAttribute.Create(
  const AValueType: TValidationValueType;
  const AMinValue: TValue;
  const AMaxValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FValueType := AValueType;
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
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
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
begin
  case FValueType of
    TValidationValueType.vvtInteger:
      ValidateInteger(AColumnName, AValue, AErrors);

    TValidationValueType.vvtDouble:
      ValidateDouble(AColumnName, AValue, AErrors);
  end;
end;

procedure TRangeAttribute.ValidateInteger(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue, LMinValue, LMaxValue: Integer;
begin
  if CheckType<Integer>(AColumnName, AValue, AErrors) then
  begin
    LValue := AValue.AsType<Integer>;
    LMinValue := FMinValue.AsType<Integer>;
    LMaxValue := FMaxValue.AsType<Integer>;
    if (LValue < LMinValue) or (LValue > LMaxValue) then
      AErrors.Add(
        AColumnName,
        Format(GetErrorMessage(SRangeValidation), [
          AColumnName, LMinValue.ToString(), LMaxValue.ToString()]));
  end;
end;

procedure TRangeAttribute.ValidateDouble(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue, LMinValue, LMaxValue: Double;
begin
  if CheckType<Double>(AColumnName, AValue, AErrors) then
  begin
    LValue := AValue.AsType<Double>;
    LMinValue := FMinValue.AsType<Double>;
    LMaxValue := FMaxValue.AsType<Double>;
    if (LValue < LMinValue) or (LValue > LMaxValue) then
      AErrors.Add(
        AColumnName,
        Format(GetErrorMessage(SRangeValidation), [
          AColumnName, LMinValue.ToString(), LMaxValue.ToString()]));
  end;
end;

{ TRegexAttribute }

constructor TRegexAttribute.Create(const ARegex: String);
begin
  Create(ARegex, String.Empty);
end;

constructor TRegexAttribute.Create(
  const ARegex: String; const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FRegex := ARegex;
end;

procedure TRegexAttribute.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue: TValue;
  LString: String;
begin
  LValue := NullableValueToString(AValue);
  if CheckType<String>(AColumnName, LValue, AErrors) then
  begin
    LString := LValue.AsType<String>();
    if (not LString.IsEmpty) and not TRegEx.IsMatch(LString, FRegex) then
      AErrors.Add(
        AColumnName,
        Format(GetErrorMessage(SRegexValidation), [AColumnName, LString]));
  end;
end;

{ TEMailAttribute }

constructor TEMailAttribute.Create;
begin
  Create(SEMailValidation);
end;

constructor TEMailAttribute.Create(const AErrorMessage: String);
begin
  inherited Create(EmailRegex, AErrorMessage);
end;

end.
