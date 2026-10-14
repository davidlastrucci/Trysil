(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.OpenAPI.Schema;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,
  System.JSon,
  System.Generics.Collections,
  Trysil.Types,
  Trysil.Classes,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Validation.Attributes,
  Trysil.JSon.Attributes,
  Trysil.JSon.Sqids,

  Trysil.OpenAPI.Types;

type

{ TTOpenApiJSonWriter }

  TTOpenApiJSonWriter = class abstract
  strict protected
    function AddObject(
      const AParent: TJSonObject; const AName: String): TJSonObject;
    function AddArray(
      const AParent: TJSonObject; const AName: String): TJSonArray;
    function AddTyped(
      const AParent: TJSonObject;
      const AName: String;
      const AType: String): TJSonObject;
    procedure AddStrings(
      const AParent: TJSonObject;
      const AName: String;
      const AValues: array of String);
  end;

{ TTOpenApiPrimitive }

  TTOpenApiPrimitive = record
  strict private
    FTypeName: String;
    FFormatKey: String;
    FFormatValue: String;
  public
    constructor Create(
      const ATypeName: String;
      const AFormatKey: String;
      const AFormatValue: String);

    property TypeName: String read FTypeName;
    property FormatKey: String read FFormatKey;
    property FormatValue: String read FFormatValue;
  end;

{ TTOpenApiPrimitives }

  TTOpenApiPrimitives = class
  strict private
    FPrimitives: TDictionary<PTypeInfo, TTOpenApiPrimitive>;

    procedure Add(
      const ATypeInfo: PTypeInfo;
      const ATypeName: String;
      const AFormatKey: String;
      const AFormatValue: String);
    procedure WriteFormat(
      const APrimitive: TTOpenApiPrimitive; const AJSon: TJSonObject);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Write(const ATypeInfo: PTypeInfo; const AJSon: TJSonObject);
    procedure WriteNullable(
      const ATypeInfo: PTypeInfo; const AJSon: TJSonObject);
  end;

{ TTOpenApiFixedSchemas }

  TTOpenApiFixedSchemas = class(TTOpenApiJSonWriter)
  strict private
    procedure WriteWhere(const AProperties: TJSonObject);
    procedure WriteOrderBy(const AProperties: TJSonObject);
    procedure WriteMetadataColumn(const AJSon: TJSonObject);
  public
    procedure WriteError(const AJSon: TJSonObject);
    procedure WriteFilter(const AJSon: TJSonObject);
    procedure WriteMetadata(const AJSon: TJSonObject);
  end;

  TTOpenApiSchemas = class;

{ TTOpenApiEntitySchema }

  TTOpenApiEntitySchema = class(TTOpenApiJSonWriter)
  strict private
    FSchemas: TTOpenApiSchemas;
    FTableMap: TTTableMap;
    FJSon: TJSonObject;
    FProperties: TJSonObject;
    FRequired: TList<String>;

    function CanDescribe(const AColumnMap: TTColumnMap): Boolean;
    function AddProperty(const AName: String): TJSonObject;
    function ClassOf(const AType: TRttiType): TClass;
    function LazyEntityClass(const AType: TRttiType): TClass;
    function IsLazyList(const AType: TRttiType): Boolean;
    function NullableTypeInfo(const AType: TRttiType): PTypeInfo;
    procedure WriteColumn(const AColumnMap: TTColumnMap);
    procedure WriteValue(
      const AColumnMap: TTColumnMap; const AJSon: TJSonObject);
    procedure WriteAccess(
      const AColumnMap: TTColumnMap; const AJSon: TJSonObject);
    procedure WriteAnnotations(
      const AMember: TTRttiMember;
      const AName: String;
      const AJSon: TJSonObject);
    procedure WriteNumber(
      const AJSon: TJSonObject; const AName: String; const AValue: TValue);
    procedure WriteBound(
      const AJSon: TJSonObject;
      const AName: String;
      const AAttribute: TValueAttribute);
    procedure WriteLengths(
      const AMember: TTRttiMember; const AJSon: TJSonObject);
    procedure WriteBounds(
      const AMember: TTRttiMember; const AJSon: TJSonObject);
    procedure WriteRange(
      const AMember: TTRttiMember; const AJSon: TJSonObject);
    procedure WritePattern(
      const AMember: TTRttiMember; const AJSon: TJSonObject);
    procedure WriteLazy(const AColumnMap: TTColumnMap; const AName: String);
    procedure WriteLazyEntity(const AType: TRttiType; const AJSon: TJSonObject);
    procedure WriteDetail(const ADetailColumnMap: TTDetailColumnMap);
    procedure WriteRequired;
  public
    constructor Create(
      const ASchemas: TTOpenApiSchemas;
      const ATableMap: TTTableMap;
      const AJSon: TJSonObject);
    destructor Destroy; override;

    procedure Write;
  end;

{ TTOpenApiSchemas }

  TTOpenApiSchemas = class
  strict private
    const SqidMinLength = 8;
  strict private
    FSchemas: TJSonObject;
    FQualifiedNames: TArray<String>;
    FPrimitives: TTOpenApiPrimitives;
    FFixedSchemas: TTOpenApiFixedSchemas;
    FOwners: TDictionary<String, TClass>;
    FCollisions: TList<String>;

    function IsComponentChar(const AChar: Char): Boolean;
    function IsQualified(const AName: String): Boolean;
    function Sanitize(const AName: String): String;
    procedure TrackOwner(const AName: String; const AClass: TClass);
    function ComponentName(const AClass: TClass): String;
    function GetCollisions: TArray<String>;
    procedure WriteSchema(const AClass: TClass; const AJSon: TJSonObject);
    procedure WriteEntity(const AClass: TClass; const AJSon: TJSonObject);
  public
    constructor Create(
      const ASchemas: TJSonObject; const AQualifiedNames: TArray<String>);
    destructor Destroy; override;

    procedure WriteReference(const AClass: TClass; const AJSon: TJSonObject);
    procedure WriteId(const AJSon: TJSonObject);

    property Primitives: TTOpenApiPrimitives read FPrimitives;
    property Collisions: TArray<String> read GetCollisions;
  end;

implementation

{ TTOpenApiJSonWriter }

function TTOpenApiJSonWriter.AddObject(
  const AParent: TJSonObject; const AName: String): TJSonObject;
begin
  result := TJSonObject.Create;
  AParent.AddPair(AName, result);
end;

function TTOpenApiJSonWriter.AddArray(
  const AParent: TJSonObject; const AName: String): TJSonArray;
begin
  result := TJSonArray.Create;
  AParent.AddPair(AName, result);
end;

function TTOpenApiJSonWriter.AddTyped(
  const AParent: TJSonObject;
  const AName: String;
  const AType: String): TJSonObject;
begin
  result := AddObject(AParent, AName);
  result.AddPair('type', AType);
end;

procedure TTOpenApiJSonWriter.AddStrings(
  const AParent: TJSonObject;
  const AName: String;
  const AValues: array of String);
var
  LArray: TJSonArray;
  LValue: String;
begin
  LArray := AddArray(AParent, AName);
  for LValue in AValues do
    LArray.Add(LValue);
end;

{ TTOpenApiPrimitive }

constructor TTOpenApiPrimitive.Create(
  const ATypeName: String;
  const AFormatKey: String;
  const AFormatValue: String);
begin
  FTypeName := ATypeName;
  FFormatKey := AFormatKey;
  FFormatValue := AFormatValue;
end;

{ TTOpenApiPrimitives }

constructor TTOpenApiPrimitives.Create;
begin
  inherited Create;
  FPrimitives := TDictionary<PTypeInfo, TTOpenApiPrimitive>.Create;
end;

destructor TTOpenApiPrimitives.Destroy;
begin
  FPrimitives.Free;
  inherited Destroy;
end;

procedure TTOpenApiPrimitives.AfterConstruction;
begin
  inherited AfterConstruction;
  Add(TypeInfo(String), 'string', String.Empty, String.Empty);
  Add(TypeInfo(Int16), 'integer', 'format', 'int32');
  Add(TypeInfo(Int32), 'integer', 'format', 'int32');
  Add(TypeInfo(Int64), 'integer', 'format', 'int64');
  Add(TypeInfo(Double), 'number', 'format', 'double');
  Add(TypeInfo(Extended), 'number', 'format', 'double');
  Add(TypeInfo(Currency), 'number', String.Empty, String.Empty);
  Add(TypeInfo(Boolean), 'boolean', String.Empty, String.Empty);
  Add(TypeInfo(TDateTime), 'string', 'format', 'date-time');
  Add(TypeInfo(TDate), 'string', 'format', 'date');
  Add(TypeInfo(TTime), 'string', 'format', 'time');
  Add(TypeInfo(TGuid), 'string', 'format', 'uuid');
  Add(TypeInfo(TBytes), 'string', 'contentEncoding', 'base64');
end;

procedure TTOpenApiPrimitives.Add(
  const ATypeInfo: PTypeInfo;
  const ATypeName: String;
  const AFormatKey: String;
  const AFormatValue: String);
begin
  FPrimitives.AddOrSetValue(
    ATypeInfo, TTOpenApiPrimitive.Create(ATypeName, AFormatKey, AFormatValue));
end;

procedure TTOpenApiPrimitives.WriteFormat(
  const APrimitive: TTOpenApiPrimitive; const AJSon: TJSonObject);
begin
  if not APrimitive.FormatKey.IsEmpty then
    AJSon.AddPair(APrimitive.FormatKey, APrimitive.FormatValue);
end;

procedure TTOpenApiPrimitives.Write(
  const ATypeInfo: PTypeInfo; const AJSon: TJSonObject);
var
  LPrimitive: TTOpenApiPrimitive;
begin
  if FPrimitives.TryGetValue(ATypeInfo, LPrimitive) then
  begin
    AJSon.AddPair('type', LPrimitive.TypeName);
    WriteFormat(LPrimitive, AJSon);
  end;
end;

procedure TTOpenApiPrimitives.WriteNullable(
  const ATypeInfo: PTypeInfo; const AJSon: TJSonObject);
var
  LPrimitive: TTOpenApiPrimitive;
  LTypes: TJSonArray;
begin
  if FPrimitives.TryGetValue(ATypeInfo, LPrimitive) then
  begin
    LTypes := TJSonArray.Create;
    AJSon.AddPair('type', LTypes);
    LTypes.Add(LPrimitive.TypeName);
    LTypes.Add('null');
    WriteFormat(LPrimitive, AJSon);
  end;
end;

{ TTOpenApiFixedSchemas }

procedure TTOpenApiFixedSchemas.WriteError(const AJSon: TJSonObject);
var
  LProperties: TJSonObject;
begin
  AJSon.AddPair('type', 'object');
  LProperties := AddObject(AJSon, 'properties');
  AddTyped(LProperties, 'status', 'integer');
  AddTyped(LProperties, 'message', 'string');
  AddTyped(LProperties, 'taskId', 'string');
  AddStrings(AJSon, 'required', ['status', 'message']);
end;

procedure TTOpenApiFixedSchemas.WriteFilter(const AJSon: TJSonObject);
var
  LProperties: TJSonObject;
begin
  AJSon.AddPair('type', 'object');
  LProperties := AddObject(AJSon, 'properties');
  WriteWhere(LProperties);
  WriteOrderBy(LProperties);
  AddTyped(LProperties, 'start', 'integer');
  AddTyped(LProperties, 'limit', 'integer');
end;

procedure TTOpenApiFixedSchemas.WriteWhere(const AProperties: TJSonObject);
var
  LItems: TJSonObject;
  LProperties: TJSonObject;
begin
  LItems := AddObject(AddTyped(AProperties, 'where', 'array'), 'items');
  LItems.AddPair('type', 'object');
  LProperties := AddObject(LItems, 'properties');
  AddTyped(LProperties, 'columnName', 'string');
  AddStrings(
    AddTyped(LProperties, 'condition', 'string'),
    'enum',
    ['=', '<>', '<', '<=', '>', '>=', 'LIKE', 'NOT LIKE']);
  AddTyped(LProperties, 'value', 'string');
  AddStrings(LItems, 'required', ['columnName', 'condition', 'value']);
end;

procedure TTOpenApiFixedSchemas.WriteOrderBy(const AProperties: TJSonObject);
var
  LItems: TJSonObject;
  LProperties: TJSonObject;
begin
  LItems := AddObject(AddTyped(AProperties, 'orderBy', 'array'), 'items');
  LItems.AddPair('type', 'object');
  LProperties := AddObject(LItems, 'properties');
  AddTyped(LProperties, 'columnName', 'string');
  AddStrings(
    AddTyped(LProperties, 'direction', 'string'), 'enum', ['ASC', 'DESC']);
  AddStrings(LItems, 'required', ['columnName']);
end;

procedure TTOpenApiFixedSchemas.WriteMetadata(const AJSon: TJSonObject);
var
  LProperties: TJSonObject;
begin
  AJSon.AddPair('type', 'object');
  LProperties := AddObject(AJSon, 'properties');
  AddTyped(LProperties, 'entity', 'string');
  AddTyped(LProperties, 'primaryKey', 'string');
  AddTyped(LProperties, 'versionColumn', 'string');
  WriteMetadataColumn(
    AddObject(AddTyped(LProperties, 'properties', 'array'), 'items'));
  AddStrings(AJSon, 'required', ['entity', 'properties']);
end;

procedure TTOpenApiFixedSchemas.WriteMetadataColumn(const AJSon: TJSonObject);
var
  LProperties: TJSonObject;
begin
  AJSon.AddPair('type', 'object');
  LProperties := AddObject(AJSon, 'properties');
  AddTyped(LProperties, 'name', 'string');
  AddTyped(LProperties, 'type', 'string');
  AddTyped(LProperties, 'size', 'integer');
  AddTyped(LProperties, 'precision', 'integer');
  AddTyped(LProperties, 'filterable', 'boolean');
  AddTyped(LProperties, 'readable', 'boolean');
  AddTyped(LProperties, 'writable', 'boolean');
  AddStrings(AJSon, 'required', ['name', 'type']);
end;

{ TTOpenApiEntitySchema }

constructor TTOpenApiEntitySchema.Create(
  const ASchemas: TTOpenApiSchemas;
  const ATableMap: TTTableMap;
  const AJSon: TJSonObject);
begin
  inherited Create;
  FSchemas := ASchemas;
  FTableMap := ATableMap;
  FJSon := AJSon;
  FProperties := nil;
  FRequired := TList<String>.Create;
end;

destructor TTOpenApiEntitySchema.Destroy;
begin
  FRequired.Free;
  inherited Destroy;
end;

procedure TTOpenApiEntitySchema.Write;
var
  LColumnMap: TTColumnMap;
  LDetailColumnMap: TTDetailColumnMap;
begin
  FJSon.AddPair('type', 'object');
  FProperties := AddObject(FJSon, 'properties');
  for LColumnMap in FTableMap.Columns do
    if CanDescribe(LColumnMap) then
      WriteColumn(LColumnMap);
  for LDetailColumnMap in FTableMap.DetailColumns do
    if TTJSonDirection.CanSerialize(LDetailColumnMap.Member) then
      WriteDetail(LDetailColumnMap);
  WriteRequired;
end;

function TTOpenApiEntitySchema.CanDescribe(
  const AColumnMap: TTColumnMap): Boolean;
begin
  result := TTJSonDirection.CanSerialize(AColumnMap.Member) or
    TTJSonDirection.CanDeserializeColumn(FTableMap, AColumnMap);
end;

function TTOpenApiEntitySchema.AddProperty(const AName: String): TJSonObject;
begin
  result := AddObject(FProperties, AName);
end;

function TTOpenApiEntitySchema.ClassOf(const AType: TRttiType): TClass;
begin
  result := nil;
  if Assigned(AType) and AType.IsInstance then
    result := AType.AsInstance.MetaclassType;
end;

function TTOpenApiEntitySchema.LazyEntityClass(
  const AType: TRttiType): TClass;
var
  LProperty: TRttiProperty;
  LMethod: TRttiMethod;
begin
  result := nil;
  LProperty := AType.GetProperty('Entity');
  if Assigned(LProperty) then
    result := ClassOf(LProperty.PropertyType)
  else
  begin
    LMethod := AType.GetMethod('AddEntity');
    if Assigned(LMethod) then
      result := ClassOf(LMethod.ReturnType);
  end;
end;

function TTOpenApiEntitySchema.IsLazyList(const AType: TRttiType): Boolean;
begin
  result := not Assigned(AType.GetProperty('Entity'));
end;

function TTOpenApiEntitySchema.NullableTypeInfo(
  const AType: TRttiType): PTypeInfo;
var
  LMethod: TRttiMethod;
begin
  result := nil;
  LMethod := AType.GetMethod('GetValue');
  if Assigned(LMethod) and Assigned(LMethod.ReturnType) then
    result := LMethod.ReturnType.Handle;
end;

procedure TTOpenApiEntitySchema.WriteColumn(const AColumnMap: TTColumnMap);
var
  LName: String;
  LJSon: TJSonObject;
begin
  LName := TTIdentifier.PublishedName(AColumnMap.Member.Name);
  if AColumnMap.Member.IsClass and
    TTRttiLazy.IsLazyType(AColumnMap.Member.RttiType) then
    WriteLazy(AColumnMap, LName)
  else
  begin
    LJSon := AddProperty(LName);
    WriteValue(AColumnMap, LJSon);
    WriteAccess(AColumnMap, LJSon);
    WriteAnnotations(AColumnMap.Member, LName, LJSon);
  end;
end;

procedure TTOpenApiEntitySchema.WriteValue(
  const AColumnMap: TTColumnMap; const AJSon: TJSonObject);
begin
  if AColumnMap = FTableMap.PrimaryKey then
    FSchemas.WriteId(AJSon)
  else if AColumnMap.Member.IsNullable then
    FSchemas.Primitives.WriteNullable(
      NullableTypeInfo(AColumnMap.Member.RttiType), AJSon)
  else
    FSchemas.Primitives.Write(AColumnMap.Member.RttiType.Handle, AJSon);
end;

procedure TTOpenApiEntitySchema.WriteAccess(
  const AColumnMap: TTColumnMap; const AJSon: TJSonObject);
begin
  if not TTJSonDirection.CanSerialize(AColumnMap.Member) then
    AJSon.AddPair('writeOnly', TJSonBool.Create(True));
  if not TTJSonDirection.CanDeserializeColumn(FTableMap, AColumnMap) then
    AJSon.AddPair('readOnly', TJSonBool.Create(True));
end;

procedure TTOpenApiEntitySchema.WriteAnnotations(
  const AMember: TTRttiMember;
  const AName: String;
  const AJSon: TJSonObject);
var
  LDisplayName: TDisplayNameAttribute;
begin
  LDisplayName := AMember.GetAttribute<TDisplayNameAttribute>();
  if Assigned(LDisplayName) then
    AJSon.AddPair('title', LDisplayName.DisplayName);
  if Assigned(AMember.GetAttribute<TEMailAttribute>()) then
    AJSon.AddPair('format', 'email');
  if Assigned(AMember.GetAttribute<TRequiredAttribute>()) then
    FRequired.Add(AName);
  WriteLengths(AMember, AJSon);
  WriteBounds(AMember, AJSon);
  WritePattern(AMember, AJSon);
end;

procedure TTOpenApiEntitySchema.WriteNumber(
  const AJSon: TJSonObject; const AName: String; const AValue: TValue);
var
  LPair: TJSonPair;
begin
  LPair := AJSon.RemovePair(AName);
  if Assigned(LPair) then
    LPair.Free;
  if AValue.Kind = tkInteger then
    AJSon.AddPair(AName, TJSonNumber.Create(AValue.AsInteger))
  else
    AJSon.AddPair(AName, TJSonNumber.Create(AValue.AsType<Double>()));
end;

procedure TTOpenApiEntitySchema.WriteBound(
  const AJSon: TJSonObject;
  const AName: String;
  const AAttribute: TValueAttribute);
begin
  if Assigned(AAttribute) then
    WriteNumber(AJSon, AName, AAttribute.Value);
end;

procedure TTOpenApiEntitySchema.WriteLengths(
  const AMember: TTRttiMember; const AJSon: TJSonObject);
var
  LMinLength: TMinLengthAttribute;
  LMaxLength: TMaxLengthAttribute;
begin
  LMinLength := AMember.GetAttribute<TMinLengthAttribute>();
  if Assigned(LMinLength) then
    WriteNumber(AJSon, 'minLength', LMinLength.Length);
  LMaxLength := AMember.GetAttribute<TMaxLengthAttribute>();
  if Assigned(LMaxLength) then
    WriteNumber(AJSon, 'maxLength', LMaxLength.Length);
end;

procedure TTOpenApiEntitySchema.WriteBounds(
  const AMember: TTRttiMember; const AJSon: TJSonObject);
begin
  WriteRange(AMember, AJSon);
  WriteBound(
    AJSon, 'minimum', AMember.GetAttribute<TMinValueAttribute>());
  WriteBound(
    AJSon, 'maximum', AMember.GetAttribute<TMaxValueAttribute>());
  WriteBound(
    AJSon, 'exclusiveMinimum', AMember.GetAttribute<TGreaterAttribute>());
  WriteBound(
    AJSon, 'exclusiveMaximum', AMember.GetAttribute<TLessAttribute>());
end;

procedure TTOpenApiEntitySchema.WriteRange(
  const AMember: TTRttiMember; const AJSon: TJSonObject);
var
  LRange: TRangeAttribute;
begin
  LRange := AMember.GetAttribute<TRangeAttribute>();
  if Assigned(LRange) then
  begin
    WriteNumber(AJSon, 'minimum', LRange.MinValue);
    WriteNumber(AJSon, 'maximum', LRange.MaxValue);
  end;
end;

procedure TTOpenApiEntitySchema.WritePattern(
  const AMember: TTRttiMember; const AJSon: TJSonObject);
var
  LRegex: TRegexAttribute;
begin
  LRegex := AMember.GetAttribute<TRegexAttribute>();
  if Assigned(LRegex) then
    AJSon.AddPair('pattern', LRegex.Regex);
end;

procedure TTOpenApiEntitySchema.WriteLazy(
  const AColumnMap: TTColumnMap; const AName: String);
var
  LID: TJSonObject;
  LJSon: TJSonObject;
begin
  LID := AddProperty(Format('%sID', [AName]));
  FSchemas.WriteId(LID);
  WriteAccess(AColumnMap, LID);
  LJSon := AddProperty(AName);
  WriteLazyEntity(AColumnMap.Member.RttiType, LJSon);
  LJSon.AddPair('readOnly', TJSonBool.Create(True));
end;

procedure TTOpenApiEntitySchema.WriteLazyEntity(
  const AType: TRttiType; const AJSon: TJSonObject);
var
  LClass: TClass;
begin
  LClass := LazyEntityClass(AType);
  if Assigned(LClass) and IsLazyList(AType) then
  begin
    AJSon.AddPair('type', 'array');
    FSchemas.WriteReference(LClass, AddObject(AJSon, 'items'));
  end
  else if Assigned(LClass) then
    FSchemas.WriteReference(LClass, AJSon);
end;

procedure TTOpenApiEntitySchema.WriteDetail(
  const ADetailColumnMap: TTDetailColumnMap);
var
  LJSon: TJSonObject;
  LClass: TClass;
begin
  LJSon := AddProperty(
    TTIdentifier.PublishedName(ADetailColumnMap.Member.Name));
  LJSon.AddPair('type', 'array');
  LClass := LazyEntityClass(ADetailColumnMap.Member.RttiType);
  if Assigned(LClass) then
    FSchemas.WriteReference(LClass, AddObject(LJSon, 'items'));
end;

procedure TTOpenApiEntitySchema.WriteRequired;
begin
  if FRequired.Count > 0 then
    AddStrings(FJSon, 'required', FRequired.ToArray);
end;

{ TTOpenApiSchemas }

constructor TTOpenApiSchemas.Create(
  const ASchemas: TJSonObject; const AQualifiedNames: TArray<String>);
begin
  inherited Create;
  FSchemas := ASchemas;
  FQualifiedNames := AQualifiedNames;
  FPrimitives := TTOpenApiPrimitives.Create;
  FFixedSchemas := TTOpenApiFixedSchemas.Create;
  FOwners := TDictionary<String, TClass>.Create;
  FCollisions := TList<String>.Create;
end;

destructor TTOpenApiSchemas.Destroy;
begin
  FCollisions.Free;
  FOwners.Free;
  FFixedSchemas.Free;
  FPrimitives.Free;
  inherited Destroy;
end;

function TTOpenApiSchemas.IsComponentChar(const AChar: Char): Boolean;
begin
  result := CharInSet(
    AChar, ['A' .. 'Z', 'a' .. 'z', '0' .. '9', '.', '-', '_']);
end;

function TTOpenApiSchemas.IsQualified(const AName: String): Boolean;
var
  LName: String;
begin
  result := False;
  for LName in FQualifiedNames do
    result := result or (LName = AName);
end;

function TTOpenApiSchemas.Sanitize(const AName: String): String;
var
  LChars: TArray<Char>;
  LIndex: Integer;
begin
  LChars := AName.ToCharArray;
  for LIndex := Low(LChars) to High(LChars) do
    if not IsComponentChar(LChars[LIndex]) then
      LChars[LIndex] := '_';
  result := String.Create(LChars);
end;

procedure TTOpenApiSchemas.TrackOwner(
  const AName: String; const AClass: TClass);
var
  LOwner: TClass;
begin
  if not FOwners.TryGetValue(AName, LOwner) then
    FOwners.Add(AName, AClass)
  else if (LOwner <> AClass) and not FCollisions.Contains(AName) then
    FCollisions.Add(AName);
end;

function TTOpenApiSchemas.ComponentName(const AClass: TClass): String;
begin
  result := Sanitize(AClass.ClassName);
  TrackOwner(result, AClass);
  if IsQualified(result) then
    result := Sanitize(AClass.QualifiedClassName);
end;

function TTOpenApiSchemas.GetCollisions: TArray<String>;
begin
  result := FCollisions.ToArray;
end;

procedure TTOpenApiSchemas.WriteReference(
  const AClass: TClass; const AJSon: TJSonObject);
var
  LName: String;
  LSchema: TJSonObject;
begin
  LName := ComponentName(AClass);
  if not Assigned(FSchemas.GetValue(LName)) then
  begin
    LSchema := TJSonObject.Create;
    FSchemas.AddPair(LName, LSchema);
    WriteSchema(AClass, LSchema);
  end;
  AJSon.AddPair('$ref', Format('#/components/schemas/%s', [LName]));
end;

procedure TTOpenApiSchemas.WriteSchema(
  const AClass: TClass; const AJSon: TJSonObject);
begin
  if AClass = TTOpenApiFilter then
    FFixedSchemas.WriteFilter(AJSon)
  else if AClass = TTOpenApiMetadata then
    FFixedSchemas.WriteMetadata(AJSon)
  else if AClass = TTOpenApiError then
    FFixedSchemas.WriteError(AJSon)
  else
    WriteEntity(AClass, AJSon);
end;

procedure TTOpenApiSchemas.WriteEntity(
  const AClass: TClass; const AJSon: TJSonObject);
var
  LEntitySchema: TTOpenApiEntitySchema;
begin
  LEntitySchema := TTOpenApiEntitySchema.Create(
    Self, TTMapper.Instance.Load(AClass.ClassInfo), AJSon);
  try
    LEntitySchema.Write;
  finally
    LEntitySchema.Free;
  end;
end;

procedure TTOpenApiSchemas.WriteId(const AJSon: TJSonObject);
begin
  if TTJSonSqids.Instance.UseSqids then
  begin
    AJSon.AddPair('type', 'string');
    AJSon.AddPair('minLength', TJSonNumber.Create(SqidMinLength));
  end
  else
  begin
    AJSon.AddPair('type', 'integer');
    AJSon.AddPair('format', 'int32');
  end;
end;

end.
