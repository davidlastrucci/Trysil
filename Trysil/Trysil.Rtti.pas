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

  Trysil.Consts,
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
    procedure SetID(const AObject: TObject; const AID: TTValue);
    function GetIsNullable: Boolean;
  public
    function NeedCreateObject(
      const AValue: TTValue; const AIsLazy: Boolean): Boolean;
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

{ TTRttiLazy }

  TTRttiLazy = class
  strict private
    class function CheckTypeName(const AType: TRttiType): Boolean;
  public
    class function IsLazy(const AObject: TObject): Boolean;
    class function IsLazyType(const AType: TRttiType): Boolean;
  end;

{ TTRttiGenericList }

  TTRttiGenericList = class
  strict private
    FObject: TObject;
    FContext: TRttiContext;

    FType: TRttiType;
    FGenericType: TRttiType;
    FGenericConstructor: TRttiMethod;
    FClear: TRttiMethod;
    FAdd: TRttiMethod;

    procedure RaiseNotAList;

    procedure SearchGenericType;
    procedure SearchGenericConstructor;
    procedure SearchClearMethod;
    procedure SearchAddMethod;
    function GetGenericTypeInfo: PTypeInfo;
  public
    constructor Create(const AObject: TObject);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function CreateObject: TObject;
    procedure Clear;
    procedure Add(const AObject: TObject);

    property GenericTypeInfo: PTypeInfo read GetGenericTypeInfo;
  end;

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

procedure TTRttiMember.SetID(const AObject: TObject; const AID: TTValue);
var
  LContext: TRttiContext;
  LType: TRttiType;
  LProperty: TRttiProperty;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AObject.ClassType.ClassInfo);
    LProperty := LType.GetProperty('ID');
    if Assigned(LProperty) then
      LProperty.SetValue(AObject, AID)
  finally
    LContext.Free;
  end;
end;

function TTRttiMember.NeedCreateObject(
  const AValue: TTValue; const AIsLazy: Boolean): Boolean;
begin
  result := AValue.IsEmpty;
  if result then
    result := AIsLazy;
end;

function TTRttiMember.CreateObject(
  const AInstance: TObject;
  const AContext: TObject;
  const AMapper: TObject;
  const AColumnName: String;
  const AValue: TTValue): TObject;
var
  LIsLazy: Boolean;
  LValue: TTValue;
begin
  result := nil;
  LIsLazy := TTRttiLazy.IsLazyType(FRttiType);
  LValue := GetValue(AInstance);
  if NeedCreateObject(LValue, LIsLazy) then
  begin
    LValue := InternalCreateObject(AContext, AMapper, AColumnName);
    SetValue(AInstance, LValue);
    if LValue.IsType<TObject>() then
    begin
      result := LValue.AsType<TObject>();
      SetID(result, AValue);
    end;
  end;

  if (not LIsLazy) and (not Assigned(result)) and LValue.IsType<TObject>() then
    result := LValue.AsType<TObject>();
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

{ TTRttiLazy }

class function TTRttiLazy.IsLazy(const AObject: TObject): Boolean;
var
  LContext: TRttiContext;
  LType: TRttiType;
begin
  result := False;
  if not Assigned(AObject) then
    Exit;
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(AObject.ClassInfo);
    result := IsLazyType(LType);
  finally
    LContext.Free;
  end;
end;

class function TTRttiLazy.IsLazyType(const AType: TRttiType): Boolean;
var
  LType: TRttiType;
begin
  LType := AType;
  while not CheckTypeName(LType) do
  begin
    LType := LType.BaseType;
    if not Assigned(LType) then
      Break;
  end;

  result := CheckTypeName(LType);
end;

class function TTRttiLazy.CheckTypeName(const AType: TRttiType): Boolean;
begin
  result := Assigned(AType) and (
    (AType.Name.StartsWith('TTAbstractLazy<')) or
    (AType.Name.StartsWith('TTLazy<')) or
    (AType.Name.StartsWith('TTLazyList<')));
end;

{ TTRttiGenericList }

constructor TTRttiGenericList.Create(const AObject: TObject);
begin
  inherited Create;
  FObject := AObject;
  FContext := TRttiContext.Create;

  FGenericType := nil;
  FGenericConstructor := nil;
  FClear := nil;
  FAdd := nil;
end;

destructor TTRttiGenericList.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

procedure TTRttiGenericList.AfterConstruction;
begin
  inherited AfterConstruction;
  FType := FContext.GetType(FObject.ClassInfo);
  SearchGenericType;
  SearchGenericConstructor;
  SearchClearMethod;
  SearchAddMethod;
end;

procedure TTRttiGenericList.RaiseNotAList;
begin
  raise ETException.CreateFmt(STypeIsNotAList, [FObject.ClassName]);
end;

procedure TTRttiGenericList.SearchGenericType;
var
  LType: TRttiType;
  LNames: TArray<String>;
begin
  LType := FType;
  while not LType.Name.Contains('<') do
  begin
    LType := LType.BaseType;
    if not Assigned(LType) then
      Break;
  end;

  if not Assigned(LType) then
    RaiseNotALIst;

  LNames := LType.Name.Split(['<', '>']);
  if Length(LNames) <> 3 then
    RaiseNotAList;

  FGenericType := FContext.FindType(LNames[1]);
  if not Assigned(FGenericType) then
    RaiseNotAList;
end;

procedure TTRttiGenericList.SearchGenericConstructor;
var
  LMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
begin
  for LMethod in FGenericType.GetMethods do
    if LMethod.IsConstructor then
    begin
      LParameters := LMethod.GetParameters;
      if Length(LParameters) = 0 then
      begin
        FGenericConstructor := LMethod;
        Break;
      end;
    end;

  if not Assigned(FGenericConstructor) then
    RaiseNotAList;
end;

procedure TTRttiGenericList.SearchClearMethod;
begin
  FClear := FType.GetMethod('Clear');
  if not Assigned(FClear) then
    RaiseNotAList;
end;

procedure TTRttiGenericList.SearchAddMethod;
begin
  FAdd := FType.GetMethod('Add');
  if not Assigned(FAdd) then
    RaiseNotAList;
end;

function TTRttiGenericList.GetGenericTypeInfo: PTypeInfo;
begin
  result := FGenericType.Handle;
end;

function TTRttiGenericList.CreateObject: TObject;
var
  LValue: TTValue;
begin
  result := nil;
  LValue := FGenericConstructor.Invoke(
    FGenericType.AsInstance.MetaclassType, []);
  if LValue.IsObject then
    result := LValue.AsObject;
end;

procedure TTRttiGenericList.Clear;
begin
  FClear.Invoke(FObject, []);
end;

procedure TTRttiGenericList.Add(const AObject: TObject);
begin
  FAdd.Invoke(FObject, [AObject]);
end;

end.
