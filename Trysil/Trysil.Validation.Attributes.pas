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
  System.TypInfo,
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
    function NumericValue(const AValue: TValue): TValue;
    function TryAsInt64(const AValue: TValue; out AResult: Int64): Boolean;
    function TryAsDouble(const AValue: TValue; out AResult: Double): Boolean;

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
    function IsMissingRelation(const AValue: TValue): Boolean;
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

{ TValueAttibute }

  TValueAttribute = class abstract(TValidationAttribute)
  strict private
    FValue: TValue;

    constructor Create(
      const AValue: TValue;
      const AErrorMessage: String); overload;

    function ValidateInteger(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors): Boolean;
    function ValidateDouble(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors): Boolean;
  strict protected
    function IsValidInteger(
      const AValue1: Int64;
      const AValue2: Int64): Boolean; virtual; abstract;
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
      const AValue1: Int64; const AValue2: Int64): Boolean; override;
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
      const AValue1: Int64; const AValue2: Int64): Boolean; override;
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
      const AValue1: Int64; const AValue2: Int64): Boolean; override;
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
      const AValue1: Int64; const AValue2: Int64): Boolean; override;
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
    FMinValue: TValue;
    FMaxValue: TValue;

    constructor Create(
      const AMinValue: TValue;
      const AMaxValue: TValue;
      const AErrorMessage: String); overload;

    function ValidateInteger(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors): Boolean;
    function ValidateDouble(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors): Boolean;
    procedure AddRangeError(
      const AColumnName: String;
      const AMinValue: String;
      const AMaxValue: String;
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
    const EmailRegex: string = '^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,})+$';
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

function TValidationAttribute.NumericValue(const AValue: TValue): TValue;
begin
  if AValue.IsNullable then
    result := AValue.NullableValue
  else
    result := AValue;
end;

function TValidationAttribute.TryAsInt64(
  const AValue: TValue; out AResult: Int64): Boolean;
begin
  result := AValue.Kind in [tkInteger, tkInt64];
  if result then
    AResult := AValue.AsInt64
  else
    AResult := 0;
end;

function TValidationAttribute.TryAsDouble(
  const AValue: TValue; out AResult: Double): Boolean;
begin
  result := AValue.Kind in [tkInteger, tkInt64, tkFloat];
  if result then
    AResult := AValue.AsExtended
  else
    AResult := 0;
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
    result := TTLanguage.Instance.Translate(AMessage);
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
        result := LRttiLazy.ID = 0;
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

function TRequiredAttribute.IsMissingRelation(
  const AValue: TValue): Boolean;
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
        result := (LRttiLazy.ID <> 0) and
          (not Assigned(LRttiLazy.ObjectValue));
      finally
        LRttiLazy.Free;
      end;
    end;
  end;
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
      Format(GetErrorMessage(SRequiredValidation), [AColumnName]))
  else if IsMissingRelation(AValue) then
    AErrors.Add(
      AColumnName,
      Format(
        GetErrorMessage(SRequiredRelationValidation), [AColumnName]));
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
  const AValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FValue := AValue;
end;

constructor TValueAttribute.Create(const AValue: Integer);
begin
  Create(TValue.From<Integer>(AValue), String.Empty);
end;

constructor TValueAttribute.Create(
  const AValue: Integer; const AErrorMessage: String);
begin
  Create(TValue.From<Integer>(AValue), AErrorMessage);
end;

constructor TValueAttribute.Create(const AValue: Double);
begin
  Create(TValue.From<Double>(AValue), String.Empty);
end;

constructor TValueAttribute.Create(
  const AValue: Double; const AErrorMessage: String);
begin
  Create(TValue.From<Double>(AValue), AErrorMessage);
end;

procedure TValueAttribute.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue: TValue;
begin
  LValue := NumericValue(AValue);
  if (not ValidateInteger(AColumnName, LValue, AErrors)) and
    (not ValidateDouble(AColumnName, LValue, AErrors)) then
    AErrors.Add(
      AColumnName,
      Format(GetErrorMessage(SNotInvalidTypeValidation), [AColumnName]));
end;

function TValueAttribute.ValidateInteger(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors): Boolean;
var
  LValue1, LValue2: Int64;
begin
  result := TryAsInt64(AValue, LValue1) and TryAsInt64(FValue, LValue2);
  if result and (not IsValidInteger(LValue1, LValue2)) then
    AddValidationError(AColumnName, LValue2.ToString(), AErrors);
end;

function TValueAttribute.ValidateDouble(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors): Boolean;
var
  LValue1, LValue2: Double;
begin
  result := TryAsDouble(AValue, LValue1) and TryAsDouble(FValue, LValue2);
  if result and (not IsValidDouble(LValue1, LValue2)) then
    AddValidationError(AColumnName, LValue2.ToString(), AErrors);
end;

{ TMinValueAttribute }

function TMinValueAttribute.IsValidInteger(
  const AValue1: Int64; const AValue2: Int64): Boolean;
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
  const AValue1: Int64; const AValue2: Int64): Boolean;
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
  const AValue1: Int64; const AValue2: Int64): Boolean;
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
  const AValue1: Int64; const AValue2: Int64): Boolean;
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
  const AMinValue: TValue;
  const AMaxValue: TValue;
  const AErrorMessage: String);
begin
  inherited Create(AErrorMessage);
  FMinValue := AMinValue;
  FMaxValue := AMaxValue;
end;

constructor TRangeAttribute.Create(
  const AMinValue: Integer; const AMaxValue: Integer);
begin
  Create(
    TValue.From<Integer>(AMinValue),
    TValue.From<Integer>(AMaxValue),
    String.Empty);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Integer;
  const AMaxValue: Integer;
  const AErrorMessage: String);
begin
  Create(
    TValue.From<Integer>(AMinValue),
    TValue.From<Integer>(AMaxValue),
    AErrorMessage);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double; const AMaxValue: Double);
begin
  Create(
    TValue.From<Double>(AMinValue),
    TValue.From<Double>(AMaxValue),
    String.Empty);
end;

constructor TRangeAttribute.Create(
  const AMinValue: Double;
  const AMaxValue: Double;
  const AErrorMessage: String);
begin
  Create(
    TValue.From<Double>(AMinValue),
    TValue.From<Double>(AMaxValue),
    AErrorMessage);
end;

procedure TRangeAttribute.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValue: TValue;
begin
  LValue := NumericValue(AValue);
  if (not ValidateInteger(AColumnName, LValue, AErrors)) and
    (not ValidateDouble(AColumnName, LValue, AErrors)) then
    AErrors.Add(
      AColumnName,
      Format(GetErrorMessage(SNotInvalidTypeValidation), [AColumnName]));
end;

procedure TRangeAttribute.AddRangeError(
  const AColumnName: String;
  const AMinValue: String;
  const AMaxValue: String;
  const AErrors: TTValidationErrors);
begin
  AErrors.Add(
    AColumnName,
    Format(GetErrorMessage(SRangeValidation), [
      AColumnName, AMinValue, AMaxValue]));
end;

function TRangeAttribute.ValidateInteger(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors): Boolean;
var
  LValue, LMinValue, LMaxValue: Int64;
begin
  result := TryAsInt64(AValue, LValue) and TryAsInt64(FMinValue, LMinValue) and
    TryAsInt64(FMaxValue, LMaxValue);
  if result and ((LValue < LMinValue) or (LValue > LMaxValue)) then
    AddRangeError(
      AColumnName, LMinValue.ToString(), LMaxValue.ToString(), AErrors);
end;

function TRangeAttribute.ValidateDouble(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors): Boolean;
var
  LValue, LMinValue, LMaxValue: Double;
begin
  result := TryAsDouble(AValue, LValue) and
    TryAsDouble(FMinValue, LMinValue) and TryAsDouble(FMaxValue, LMaxValue);
  if result and ((LValue < LMinValue) or (LValue > LMaxValue)) then
    AddRangeError(
      AColumnName, LMinValue.ToString(), LMaxValue.ToString(), AErrors);
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
