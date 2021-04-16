(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Rtti;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Rtti,

  Trysil.Types,
  Trysil.Exceptions;

type

{ TTValue }

  TTValue = TValue;

{ TTValueHelper }

  TTValueHelper = record helper for TValue
  strict private
    function GetIsNullable: Boolean;
  public
    function NullableValueToString: String;

    property IsNullable: Boolean read GetIsNullable;
  end;

{ TTRttiMember }

  TTRttiMember = class abstract
  strict protected
    FTypeInfo: PTypeInfo;
    FIsClass: Boolean;
    FRttiType: TRttiType;

    function InternalCreateObject(
      const AContext: TObject;
      const AMapper: TObject;
      const AColumnName: String): TTValue;
    procedure SetID(const AObject: TTValue; const AID: TTValue);
    function GetIsNullable: Boolean;
  public
    function CreateObject(
      const AInstance: TObject;
      const AContext: TObject;
      const AMapper: TObject;
      const AColumnName: String;
      const AValue: TTValue): TObject;

    function GetValueFromObject(const AInstance: TObject): TTValue;

    function GetValue(const AInstance: TObject): TTValue; virtual; abstract;
    procedure SetValue(
      const AInstance: TObject; const AValue: TTValue); virtual; abstract;

    property IsClass: Boolean read FIsClass;
    property IsNullable: Boolean read GetIsNullable;
  end;

{ TTRttiField }

  TTRttiField = class(TTRttiMember)
  strict private
    FRttiField: TRttiField;
  public
    constructor Create(const ARttiField: TRttiField);

    function GetValue(const AInstance: TObject): TTValue; override;
    procedure SetValue(
      const AInstance: TObject; const AValue: TTValue); override;
  end;

{ TTRttiProperty }

  TTRttiProperty = class(TTRttiMember)
  strict private
    FRttiProperty: TRttiProperty;
  public
    constructor Create(const ARttiProperty: TRttiProperty);

    function GetValue(const AInstance: TObject): TTValue; override;
    procedure SetValue(
      const AInstance: TObject; const AValue: TTValue); override;
  end;

resourcestring
  SPropertyIDNotFound = 'Property ID not found';

implementation

{ TTValueHelper }

function TTValueHelper.GetIsNullable: Boolean;
begin
  result :=
    Self.IsType<TTNullable<String>>() or
    Self.IsType<TTNullable<Integer>>() or
    Self.IsType<TTNullable<Int64>>() or
    Self.IsType<TTNullable<Double>>() or
    Self.IsType<TTNullable<Boolean>>() or
    Self.IsType<TTNullable<TDateTime>>() or
    Self.IsType<TTNullable<TGuid>>();
end;

function TTValueHelper.NullableValueToString: String;
begin
  if Self.IsType<TTNullable<String>>() then
    result := Self.AsType<TTNullable<String>>().GetValueOrDefault()
  else if Self.IsType<TTNullable<Integer>>() then
    result := Self.AsType<TTNullable<Integer>>().GetValueOrDefault().ToString()
  else if Self.IsType<TTNullable<Int64>>() then
    result := Self.AsType<TTNullable<Int64>>().GetValueOrDefault().ToString()
  else if Self.IsType<TTNullable<Double>>() then
    result := Self.AsType<TTNullable<Double>>().GetValueOrDefault().ToString()
  else if Self.IsType<TTNullable<Boolean>>() then
    result := Self.AsType<TTNullable<Boolean>>().GetValueOrDefault().ToString()
  else if Self.IsType<TTNullable<TDateTime>>() then
    result := DateToStr(Self.AsType<TTNullable<TDateTime>>().GetValueOrDefault())
  else if Self.IsType<TTNullable<TGuid>>() then
    result := Self.AsType<TTNullable<TGuid>>().GetValueOrDefault().ToString()
  else
    result := String.Empty;
end;

{ TTRttiMember }

function TTRttiMember.InternalCreateObject(
  const AContext: TObject;
  const AMapper: TObject;
  const AColumnName: String): TTValue;
var
  LMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LIsValid: Boolean;
  LParams: TArray<TValue>;
begin
  for LMethod in FRttiType.GetMethods do
    if LMethod.IsConstructor then
    begin
      LParameters := LMethod.GetParameters;
      LIsValid := Length(LParameters) = 3;
      if LIsValid then
        LIsValid :=
          (LParameters[0].ParamType.Handle = AContext.ClassInfo) and
          (LParameters[1].ParamType.Handle = AMapper.ClassInfo) and
          (LParameters[2].ParamType.Handle = TypeInfo(String));

      if LIsValid then
      begin
        SetLength(LParams, 3);
        LParams[0] := TTValue.From<TObject>(AContext);
        LParams[1] := TTValue.From<TObject>(AMapper);
        LParams[2] := TTValue.From<String>(AColumnName);
        result := LMethod.Invoke(FRttiType.AsInstance.MetaclassType, LParams);
        Break;
      end;
    end;
end;

procedure TTRttiMember.SetID(const AObject: TTValue; const AID: TTValue);
var
  LObject: TObject;
  LContext: TRttiContext;
  LType: TRttiType;
  LProperty: TRttiProperty;
begin
  LObject := AObject.AsObject;
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(LObject.ClassType.ClassInfo);
    LProperty := LType.GetProperty('ID');
    if Assigned(LProperty) then
      LProperty.SetValue(LObject, AID)
  finally
    LContext.Free;
  end;
end;

function TTRttiMember.CreateObject(
  const AInstance: TObject;
  const AContext: TObject;
  const AMapper: TObject;
  const AColumnName: String;
  const AValue: TTValue): TObject;
var
  LValue: TTValue;
begin
  result := nil;
  LValue := GetValue(AInstance);
  if LValue.IsEmpty then
  begin
    LValue := InternalCreateObject(AContext, AMapper, AColumnName);
    SetValue(AInstance, LValue);
    if LValue.IsType<TObject>() then
      result := LValue.AsType<TObject>();
  end;

  SetID(LValue, AValue);
end;

function TTRttiMember.GetValueFromObject(const AInstance: TObject): TTValue;
var
  LPropertyID: TRttiProperty;
begin
  LPropertyID := FRttiType.GetProperty('ID');
  if not Assigned(LPropertyID) then
    raise ETException.Create(SPropertyIDNotFound);
  result := LPropertyID.GetValue(AInstance);
end;

function TTRttiMember.GetIsNullable: Boolean;
begin
  result :=
    (FTypeInfo = TypeInfo(TTNullable<String>)) or
    (FTypeInfo = TypeInfo(TTNullable<Integer>)) or
    (FTypeInfo = TypeInfo(TTNullable<Int64>)) or
    (FTypeInfo = TypeInfo(TTNullable<Double>)) or
    (FTypeInfo = TypeInfo(TTNullable<Boolean>)) or
    (FTypeInfo = TypeInfo(TTNullable<TDateTime>)) or
    (FTypeInfo = TypeInfo(TTNullable<TGuid>));
end;

{ TTRttiField }

constructor TTRttiField.Create(const ARttiField: TRttiField);
begin
  inherited Create;
  FTypeInfo := ARttiField.FieldType.Handle;
  FRttiField := ARttiField;
  FIsClass := (FRttiField.FieldType.TypeKind = TTypeKind.tkClass);
  if FIsClass then
    FRttiType := FRttiField.FieldType;
end;

function TTRttiField.GetValue(const AInstance: TObject): TTValue;
begin
  result := FRttiField.GetValue(AInstance);
end;

procedure TTRttiField.SetValue(const AInstance: TObject; const AValue: TTValue);
begin
  FRttiField.SetValue(AInstance, AValue);
end;

{ TTRttiProperty }

constructor TTRttiProperty.Create(const ARttiProperty: TRttiProperty);
begin
  inherited Create;
  FTypeInfo := ARttiProperty.PropertyType.Handle;
  FRttiProperty := ARttiProperty;
  FIsClass := (FRttiProperty.PropertyType.TypeKind = TTypeKind.tkClass);
  if FIsClass then
    FRttiType := FRttiProperty.PropertyType;
end;

function TTRttiProperty.GetValue(const AInstance: TObject): TTValue;
begin
  result := FRttiProperty.GetValue(AInstance);
end;

procedure TTRttiProperty.SetValue(
  const AInstance: TObject; const AValue: TTValue);
begin
  FRttiProperty.SetValue(AInstance, AValue);
end;

end.
