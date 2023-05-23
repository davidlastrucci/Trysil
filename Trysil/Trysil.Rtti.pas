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
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Factory;

type

{ TTValue }

  TTValue = TValue;

{ TTValueHelper }

  TTValueHelper = record helper for TValue
  strict private
    function GetIsNull: Boolean;
    function GetIsNullable: Boolean;
  public
    function NullableValueToString: String;

    property IsNull: Boolean read GetIsNull;
    property IsNullable: Boolean read GetIsNullable;
  end;

{$IF CompilerVersion < 35} // Delphi 11 Alexandria

{ TTRttiObjectHelper }

  TTRttiObjectHelper = class helper for TRttiObject
  public
    function GetAttribute<T: TCustomAttribute>(): T;
  end;

{$ENDIF}

{ TTRttiTypeHelper }

  TTRttiTypeHelper = class helper for TRttiType
  strict private
    function SearchAttribute<T: TCustomAttribute>(const AType: TRttiType): T;
    procedure SearchAttributes(
      const AType: TRttiType; const AList: TList<TCustomAttribute>);
  public
    function GetInheritedAttribute<T: TCustomAttribute>(): T;
    function GetInheritedAttributes: TArray<TCustomAttribute>;
  end;

{ TTRtti }

  TTRtti = class
  strict private
    class var FHasPackages: Boolean;

    class constructor ClassCreate;

    class function GetHasPackages: Boolean;
    class function IsSameType(
      const AClass: TClass; const AType: TRttiType): Boolean;
  public
    class function InheritsFrom(
      const AObject: TObject; const AType: TRttiType): Boolean;
  end;

{ TTRttiMember }

  TTRttiMember = class abstract
  strict protected
    FName: String;
    FTypeInfo: PTypeInfo;
    FIsClass: Boolean;
    FRttiType: TRttiType;

    function InternalCreateObject(
      const AContext: TObject;
      const AColumnName: String): TTValue;
    procedure SetID(const AObject: TObject; const AID: TTValue);

    function GetIsNullable: Boolean;
  public
    constructor Create(const AName: String);

    function NeedCreateObject(
      const AValue: TTValue; const AIsLazy: Boolean): Boolean;
    function CreateObject(
      const AInstance: TObject;
      const AContext: TObject;
      const AColumnName: String;
      const AValue: TTValue): TObject;

    function GetValueFromObject(const AInstance: TObject): TTValue;

    function GetValue(const AInstance: TObject): TTValue; virtual; abstract;
    procedure SetValue(
      const AInstance: TObject; const AValue: TTValue); virtual; abstract;

    property Name: String read FName;
    property RttiType: TRttiType read FRttiType;
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
  strict protected
    FObject: TObject;
    FContext: TRttiContext;

    FType: TRttiType;
    FID: TRttiField;
    FProperty: TRttiProperty;

    procedure SearchType;
    procedure SearchProperty;
    procedure SearchID;

    function GetObjectValue: TObject;
    function GetID: TTPrimaryKey;
    procedure SetID(const AValue: TTPrimaryKey);
  strict private
    class function CheckTypeName(const AType: TRttiType): Boolean;
  public
    constructor Create(const AObject: TObject);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property ObjectValue: TObject read GetObjectValue;
    property ID: TTPrimaryKey read GetID write SetID;

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

{ TTRttiEntity<T> }

  TTRttiEntity<T: class> = class
  strict private
    FContext: TRttiContext;
    FType: TRttiType;

    function SearchConstructor: TRttiMethod; overload;
    function InternalCreateEntity(): T; overload;

    function SearchConstructor(const AContext: TObject): TRttiMethod; overload;
    function InternalCreateEntity(const AContext: TObject): T; overload;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateEntity(const AContext: TObject): T;
  end;

implementation

{ TTValueHelper }

function TTValueHelper.GetIsNullable: Boolean;
begin
  result := String(Self.TypeInfo.Name).StartsWith('TTNullable<');
end;

function TTValueHelper.GetIsNull: Boolean;
begin
  result := False;
  if Self.IsNullable then
  begin
    if Self.IsType<TTNullable<String>>() then
      result := Self.AsType<TTNullable<String>>().IsNull
    else if Self.IsType<TTNullable<Integer>>() then
      result := Self.AsType<TTNullable<Integer>>().IsNull
    else if Self.IsType<TTNullable<Int64>>() then
      result := Self.AsType<TTNullable<Int64>>().IsNull
    else if Self.IsType<TTNullable<Double>>() then
      result := Self.AsType<TTNullable<Double>>().IsNull
    else if Self.IsType<TTNullable<Boolean>>() then
      result := Self.AsType<TTNullable<Boolean>>().IsNull
    else if Self.IsType<TTNullable<TDateTime>>() then
      result := Self.AsType<TTNullable<TDateTime>>().IsNull
    else if Self.IsType<TTNullable<TGuid>>() then
      result := Self.AsType<TTNullable<TGuid>>().IsNull
    else
      raise ETException.Create(SInvalidNullableType);
  end;
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
    raise ETException.Create(SInvalidNullableType);
end;

{$IF CompilerVersion < 35} // Delphi 11 Alexandria

{ TTRttiObjectHelper }

function TTRttiObjectHelper.GetAttribute<T>(): T;
var
  LAttribute: TCustomAttribute;
begin
  result := nil;
  for LAttribute in Self.GetAttributes do
    if LAttribute is T then
    begin
      result := T(LAttribute);
      Break;
    end;
end;

{$ENDIF}

{ TTRttiTypeHelper }

function TTRttiTypeHelper.SearchAttribute<T>(const AType: TRttiType): T;
var
  LParent: TRttiType;
begin
  result := AType.GetAttribute<T>();
  if not Assigned(result) then
  begin
    LParent := AType.BaseType;
    if Assigned(LParent) then
      result := SearchAttribute<T>(LParent);
  end;
end;

function TTRttiTypeHelper.GetInheritedAttribute<T>(): T;
begin
  result := SearchAttribute<T>(Self);
end;

procedure TTRttiTypeHelper.SearchAttributes(
  const AType: TRttiType; const AList: TList<TCustomAttribute>);
var
  LParent: TRttiType;
  LAttribute: TCustomAttribute;
begin
  LParent := AType.BaseType;
  if Assigned(LParent) then
    SearchAttributes(LParent, AList);

  for LAttribute in AType.GetAttributes do
    AList.Add(LAttribute);
end;

function TTRttiTypeHelper.GetInheritedAttributes: TArray<TCustomAttribute>;
var
  LResult: TList<TCustomAttribute>;
begin
  LResult := TList<TCustomAttribute>.Create;
  try
    SearchAttributes(Self, LResult);
    result := LResult.ToArray;
  finally
    LResult.Free;
  end;
end;

{ TTRtti }

class constructor TTRtti.ClassCreate;
begin
  FHasPackages := GetHasPackages;
end;

class function TTRtti.GetHasPackages: Boolean;
var
  LContext: TRttiContext;
  LPackages: TArray<TRttiPackage>;
begin
  LContext := TRttiContext.Create;
  try
    LPackages := LContext.GetPackages;
    result := Length(LPackages) > 1;
  finally
    LContext.Free;
  end;
end;

class function TTRtti.IsSameType(
  const AClass: TClass; const AType: TRttiType): Boolean;
begin
  // RTTI, Package & Generics
  if FHasPackages then
    result := String.Compare(
      AClass.QualifiedClassName, AType.QualifiedName, True) = 0
  else
    result := AClass.ClassInfo = AType.Handle;
end;

class function TTRtti.InheritsFrom(
  const AObject: TObject; const AType: TRttiType): Boolean;
var
  LClass: TClass;
begin
  LClass := AObject.ClassType;
  result := IsSameType(LClass, AType);
  while not result do
  begin
    LClass := LClass.ClassParent;
    if not Assigned(LClass) then
      Break;
    result := IsSameType(LClass, AType);
  end;
end;

{ TTRttiMember }

constructor TTRttiMember.Create(const AName: String);
begin
  inherited Create;
  FName := AName;
end;

function TTRttiMember.InternalCreateObject(
  const AContext: TObject;
  const AColumnName: String): TTValue;
var
  LMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LIsValid: Boolean;
  LParams: TArray<TTValue>;
begin
  for LMethod in FRttiType.GetMethods do
    if LMethod.IsConstructor then
    begin
      LParameters := LMethod.GetParameters;
      LIsValid := Length(LParameters) = 2;
      if LIsValid then
        LIsValid :=
          TTRtti.InheritsFrom(AContext, LParameters[0].ParamType) and
          (LParameters[1].ParamType.Handle = TypeInfo(String));

      if LIsValid then
      begin
        SetLength(LParams, 2);
        LParams[0] := TTValue.From<TObject>(AContext);
        LParams[1] := TTValue.From<String>(AColumnName);
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
    LValue := InternalCreateObject(AContext, AColumnName);
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
  result := String(FTypeInfo.Name).StartsWith('TTNullable<');
end;

{ TTRttiField }

constructor TTRttiField.Create(const ARttiField: TRttiField);
begin
  inherited Create(ARttiField.Name);
  FTypeInfo := ARttiField.FieldType.Handle;
  FRttiField := ARttiField;
  FRttiType := FRttiField.FieldType;
  FIsClass := (FRttiType.TypeKind = TTypeKind.tkClass);
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
  inherited Create(ARttiProperty.Name);
  FTypeInfo := ARttiProperty.PropertyType.Handle;
  FRttiProperty := ARttiProperty;
  FRttiType := FRttiProperty.PropertyType;
  FIsClass := (FRttiType.TypeKind = TTypeKind.tkClass);
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

constructor TTRttiLazy.Create(const AObject: TObject);
begin
  inherited Create;
  FObject := AObject;
  FContext := TRttiContext.Create;

  FType := nil;
  FProperty := nil;
  FID := nil;
end;

destructor TTRttiLazy.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

procedure TTRttiLazy.AfterConstruction;
begin
  inherited AfterConstruction;
  if Assigned(FObject) then
  begin
    SearchType;
    if Assigned(FType) then
    begin
      SearchProperty;
      SearchID;
    end;
  end;
end;

procedure TTRttiLazy.SearchType;
var
  LType: TRttiType;
begin
  LType := FContext.GetType(FObject.ClassInfo);
  while not CheckTypeName(LType) do
  begin
    LType := LType.BaseType;
    if not Assigned(LType) then
      Break;
  end;

  if Assigned(LType) then
    FType := LType;
end;

procedure TTRttiLazy.SearchProperty;
begin
  if FType.Name.StartsWith('TTLazy<') then
    FProperty := FType.GetProperty('Entity')
  else if FType.Name.StartsWith('TTLazyList<') then
    FProperty := FType.GetProperty('List');
end;

procedure TTRttiLazy.SearchID;
begin
  FID := FType.GetField('FID');
end;

function TTRttiLazy.GetObjectValue: TObject;
var
  LValue: TTValue;
begin
  result := nil;
  if Assigned(FObject) and Assigned(FProperty) then
  begin
    LValue := FProperty.GetValue(FObject);
    if LValue.IsObject then
      result := LValue.AsObject;
  end;
end;

function TTRttiLazy.GetID: TTPrimaryKey;
var
  LValue: TTValue;
begin
  result := 0;
  if Assigned(FObject) and Assigned(FID) then
  begin
    LValue := FID.GetValue(FObject);
    if LValue.IsType<TTPrimaryKey>() then
      result := LValue.AsType<TTPrimaryKey>();
  end;
end;

procedure TTRttiLazy.SetID(const AValue: TTPrimaryKey);
begin
  if Assigned(FObject) and Assigned(FID) then
    FID.SetValue(FObject, AValue);
end;

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

{ TTRttiEntity<T> }

constructor TTRttiEntity<T>.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
  FType := FContext.GetType(TTFactory.Instance.GetType<T>());
end;

destructor TTRttiEntity<T>.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

function TTRttiEntity<T>.SearchConstructor: TRttiMethod;
var
  LMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
begin
  for LMethod in FType.GetMethods do
    if LMethod.IsConstructor then
    begin
      LParameters := LMethod.GetParameters;
      if Length(LParameters) = 0 then
      begin
        result := LMethod;
        Break;
      end;
    end;

  if not Assigned(result) then
    raise ETException.CreateFmt(STypeHasNotValidConstructor, [FType.Name]);
end;

function TTRttiEntity<T>.InternalCreateEntity: T;
var
  LConstructor: TRttiMethod;
  LValue: TTValue;
begin
  result := nil;
  LConstructor := SearchConstructor;
  LValue := LConstructor.Invoke(FType.AsInstance.MetaclassType, []);
  if LValue.IsType<T>() then
    result := LValue.AsType<T>();
end;

function TTRttiEntity<T>.SearchConstructor(
  const AContext: TObject): TRttiMethod;
var
  LMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
begin
  result := nil;
  for LMethod in FType.GetMethods do
    if LMethod.IsConstructor then
    begin
      LParameters := LMethod.GetParameters;
      if (Length(LParameters) = 1) and
        TTRtti.InheritsFrom(AContext, LParameters[0].ParamType) then
      begin
        result := LMethod;
        Break;
      end;
    end;
end;

function TTRttiEntity<T>.InternalCreateEntity(const AContext: TObject): T;
var
  LConstructor: TRttiMethod;
  LValue: TTValue;
begin
  result := nil;
  LConstructor := SearchConstructor(AContext);
  if Assigned(LConstructor) then
  begin
    LValue := LConstructor.Invoke(FType.AsInstance.MetaclassType, [AContext]);
    if LValue.IsType<T>() then
      result := LValue.AsType<T>();
  end;
end;

function TTRttiEntity<T>.CreateEntity(const AContext: TObject): T;
begin
  result := InternalCreateEntity(AContext);
  if not Assigned(result) then
    result := InternalCreateEntity;
end;

end.
