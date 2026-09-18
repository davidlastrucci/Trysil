(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Serializer;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.Rtti,
  System.TypInfo,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Metadata,

  Trysil.JSon.Attributes,
  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions,
  Trysil.JSon.Types,
  Trysil.JSon.Rtti,
  Trysil.JSon.Events,
  Trysil.JSon.Sqids,
  Trysil.JSon.Serializer.Classes;

type

{ TTJSonSerializer }

  TTJSonSerializer = class(TTJSon)
  strict private
    const MaxReentrance = 16;
  strict private
    FRttiContext: TRttiContext;
    FConfig: TTJSonSerializerConfig;
    FLevel: Integer;
    FReentrance: Integer;
    FVisiting: TList<String>;

    function EntityKey(const AObject: TObject): String;
    function IsVisiting(const AObject: TObject): Boolean;

    procedure AddLazyID(
      const AObject: TObject; const AName: String; const AJSon: TJSonObject);
    function CanSerializeLevel: Boolean;
    function GetJSonValue(const AValue: TTValue): TJSonValue;
    function GetJSonNullableValue(const AValue: TTValue): TJSonValue;
    function GetJSonObjectOrArrayValue(const AValue: TTValue): TJSonValue;
    function GetJSonObjectValue(const AObject: TObject): TJSonObject;
    procedure GetJSonListValue(
      const AList: TTJSonList; const AResult: TJSonArray);

    function ColumnToJSonValue(
      const ATableMap: TTTableMap;
      const AColumnMap: TTColumnMap;
      const AName: String;
      const AObject: TObject;
      const AResult: TJSonObject): TJSonValue;
    function CanSerializeMember(const AMember: TTRttiMember): Boolean;
    function CanSerializeColumn(const AColumnMap: TTColumnMap): Boolean;
    function CanDescribeColumn(
      const ATableMap: TTTableMap;
      const AColumnMap: TTColumnMap): Boolean;

    procedure ColumnsToJSonObject(
      const AObject: TObject; const AResult: TJSonObject);
    procedure DetailColumnsToJSonObject(
      const AObject: TObject; const AResult: TJSonObject);

    procedure InternalEntityToJSon(
      const AObject: TObject; const AResult: TJSonObject);

    procedure ColumnMetadataToJSon(
      const AJSon: TJSonObject;
      const ATableMap: TTTableMap;
      const AColumnMetadata: TTColumnMetadata;
      const AColumnMap: TTColumnMap);
    procedure TableMetadataToJSon(
      const AJSon: TJSonObject;
      const ATableMetadata: TTTableMetadata;
      const ATableMap: TTTableMap);
  public
    constructor Create;
    destructor Destroy; override;

    procedure EntityToJSon(
      const AObject: TObject;
      const AResult: TJSonObject;
      const AConfig: TTJSonSerializerConfig);

    function MetadataToJSon(
      const ATableMetadata: TTTableMetadata;
      const ATableMap: TTTableMap): String;
  end;

implementation

{ TTJSonSerializer }

constructor TTJSonSerializer.Create;
begin
  inherited Create;
  FRttiContext := TRttiContext.Create;
  FVisiting := TList<String>.Create;
end;

destructor TTJSonSerializer.Destroy;
begin
  FVisiting.Free;
  FRttiContext.Free;
  inherited Destroy;
end;

function TTJSonSerializer.EntityKey(const AObject: TObject): String;
var
  LTableMap: TTTableMap;
begin
  result := String.Empty;
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  if Assigned(LTableMap.PrimaryKey) then
    result := Format('%s#%d', [
      AObject.ClassName,
      LTableMap.PrimaryKey.Member.GetValue(AObject).AsType<TTPrimaryKey>()]);
end;

function TTJSonSerializer.IsVisiting(const AObject: TObject): Boolean;
var
  LKey: String;
begin
  LKey := EntityKey(AObject);
  result := (not LKey.IsEmpty) and (FVisiting.IndexOf(LKey) >= 0);
end;

procedure TTJSonSerializer.AddLazyID(
  const AObject: TObject; const AName: String; const AJSon: TJSonObject);
var
  LLazy: TTRttiLazy;
begin
  LLazy := TTRttiLazy.Create(AObject);
  try
    AJSon.AddPair(
      Format('%sID', [AName]), TTJSonSqids.Instance.Encode(LLazy.ID));
  finally
    LLazy.Free;
  end;
end;

function TTJSonSerializer.CanSerializeLevel: Boolean;
begin
  result := (FConfig.MaxLevels < 0) or (FLevel <= FConfig.MaxLevels);
end;

function TTJSonSerializer.GetJSonValue(const AValue: TTValue): TJSonValue;
var
  LSerializer: TTJSonAbstractSerializer;
begin
  if AValue.IsEmpty then
    result := TJSonNull.Create
  else
  begin
    LSerializer := TTJSonSerializers.Instance.GetInstance(AValue.TypeInfo);
    result := LSerializer.ToJSon(AValue);
  end;
end;

function TTJSonSerializer.GetJSonNullableValue(
  const AValue: TTValue): TJSonValue;
var
  LNullable: TTJSonNullable;
begin
  LNullable := TTJSonNullable.Create(FRttiContext, AValue);
  try
    result := GetJSonValue(LNullable.Value);
  finally
    LNullable.Free;
  end;
end;

function TTJSonSerializer.GetJSonObjectOrArrayValue(
  const AValue: TTValue): TJSonValue;
var
  LObject: TObject;
  LList: TTJSonList;
begin
  result := nil;
  LObject := nil;
  if CanSerializeLevel then
    LObject := GetLazyObject(AValue.AsObject);

  if Assigned(LObject) then
  begin
    try
      LList := TTJSonList.Create(FRttiContext, LObject);
      try
        if LList.IsList then
        begin
          result := TJSonArray.Create;
          GetJSonListValue(LList, TJSonArray(result));
        end
        else
          result := GetJSonObjectValue(LObject);
      finally
        LList.Free;
      end;
    except
      if Assigned(result) then
        result.Free;
      raise;
    end;
  end;
end;

function TTJSonSerializer.GetJSonObjectValue(
  const AObject: TObject): TJSonObject;
begin
  if CanSerializeLevel and (not IsVisiting(AObject)) then
  begin
    result := TJSonObject.Create;
    try
      InternalEntityToJSon(AObject, result);
    except
      result.Free;
      raise;
    end;
  end
  else
    result := nil;
end;

procedure TTJSonSerializer.GetJSonListValue(
  const AList: TTJSonList; const AResult: TJSonArray);
var
  LCount, LIndex: Integer;
  LItem: TTValue;
  LJSon: TJSonObject;
begin
  LCount := AList.Count;
  for LIndex := 0 to LCount - 1 do
  begin
    LItem := AList.Items[LIndex];
    if LItem.IsObject then
    begin
      LJSon := GetJSonObjectValue(LItem.AsObject);
      if Assigned(LJSon) then
        AResult.Add(LJSon);
    end;
  end;
end;

function TTJSonSerializer.ColumnToJSonValue(
  const ATableMap: TTTableMap;
  const AColumnMap: TTColumnMap;
  const AName: String;
  const AObject: TObject;
  const AResult: TJSonObject): TJSonValue;
var
  LObject: TObject;
begin
  if AColumnMap.Member.IsNullable then
    result := GetJSonNullableValue(AColumnMap.Member.GetValue(AObject))
  else if AColumnMap.Member.IsClass then
  begin
    LObject := AColumnMap.Member.GetValue(AObject).AsObject;
    if TTRttiLazy.IsLazy(LObject) then
      AddLazyID(LObject, AName, AResult);
    result := GetJSonObjectOrArrayValue(LObject);
  end
  else if TTJSonSqids.Instance.UseSqids and
    (AColumnMap = ATableMap.PrimaryKey) then
    result := TTJSonSqids.Instance.Encode(
      AColumnMap.Member.GetValue(AObject).AsType<Integer>)
  else
    result := GetJSonValue(AColumnMap.Member.GetValue(AObject));
end;

function TTJSonSerializer.CanSerializeMember(
  const AMember: TTRttiMember): Boolean;
begin
  result := TTJSonDirection.CanSerialize(AMember);
end;

function TTJSonSerializer.CanSerializeColumn(
  const AColumnMap: TTColumnMap): Boolean;
begin
  result := CanSerializeMember(AColumnMap.Member);
end;

function TTJSonSerializer.CanDescribeColumn(
  const ATableMap: TTTableMap;
  const AColumnMap: TTColumnMap): Boolean;
begin
  result := CanSerializeColumn(AColumnMap) or
    TTJSonDirection.CanDeserializeColumn(ATableMap, AColumnMap);
end;

procedure TTJSonSerializer.ColumnsToJSonObject(
  const AObject: TObject; const AResult: TJSonObject);
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LName: String;
  LValue: TJSonValue;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LColumnMap in LTableMap.Columns do
  begin
    if CanSerializeColumn(LColumnMap) then
    begin
      LName := GetName(LColumnMap.Member.Name);
      LValue := ColumnToJSonValue(
        LTableMap, LColumnMap, LName, AObject, AResult);
      if Assigned(LValue) then
        try
          AResult.AddPair(LName, LValue);
        except
          LValue.Free;
          raise;
        end;
    end;
  end;
end;

procedure TTJSonSerializer.DetailColumnsToJSonObject(
  const AObject: TObject; const AResult: TJSonObject);
var
  LTableMap: TTTableMap;
  LDetailColumnMap: TTDetailColumnMap;
  LName: String;
  LValue: TTValue;
  LJSonValue: TJSonValue;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LDetailColumnMap in LTableMap.DetailColumns do
  begin
    if CanSerializeMember(LDetailColumnMap.Member) then
    begin
      LName := GetName(LDetailColumnMap.Member.Name);
      LValue := LDetailColumnMap.Member.GetValue(AObject);
      if LValue.IsObject then
      begin
        LJSonValue := GetJSonObjectOrArrayValue(LValue.AsObject);
        if Assigned(LJSonValue) then
          try
            AResult.AddPair(LName, LJSonValue);
          except
            LJSonValue.Free;
            raise;
          end;
      end;
    end;
  end;
end;

procedure TTJSonSerializer.InternalEntityToJSon(
  const AObject: TObject; const AResult: TJSonObject);
var
  LEvent: TTJSonEvent;
  LKey: String;
  LVisitingCount: Integer;
begin
  LKey := EntityKey(AObject);
  LVisitingCount := FVisiting.Count;
  Inc(FLevel);
  try
    if not LKey.IsEmpty then
      FVisiting.Add(LKey);

    ColumnsToJSonObject(AObject, AResult);

    LEvent := TTJSonEventFactory.Instance.CreateEvent(AObject);
    if Assigned(LEvent) then
      try
        LEvent.DoAfterSerialized(AResult);
      finally
        LEvent.Free;
      end;

    if FConfig.Details then
      DetailColumnsToJSonObject(AObject, AResult);
  finally
    while FVisiting.Count > LVisitingCount do
      FVisiting.Delete(FVisiting.Count - 1);
    Dec(FLevel);
  end;
end;

procedure TTJSonSerializer.EntityToJSon(
  const AObject: TObject;
  const AResult: TJSonObject;
  const AConfig: TTJSonSerializerConfig);
var
  LConfig: TTJSonSerializerConfig;
  LLevel: Integer;
  LVisiting: TArray<String>;
begin
  if FReentrance >= MaxReentrance then
    raise ETJSonServerException.CreateFmt(
      TTLanguage.Instance.Translate(SSerializerReentered), [FReentrance]);

  LConfig := FConfig;
  LLevel := FLevel;
  LVisiting := FVisiting.ToArray;
  Inc(FReentrance);
  try
    FConfig := TTJSonSerializerConfig.Create(AConfig);
    FLevel := 0;
    FVisiting.Clear;
    InternalEntityToJSon(AObject, AResult);
  finally
    Dec(FReentrance);
    FConfig := LConfig;
    FLevel := LLevel;
    FVisiting.Clear;
    FVisiting.AddRange(LVisiting);
  end;
end;

procedure TTJSonSerializer.ColumnMetadataToJSon(
  const AJSon: TJSonObject;
  const ATableMap: TTTableMap;
  const AColumnMetadata: TTColumnMetadata;
  const AColumnMap: TTColumnMap);
begin
  AJSon.AddPair('name', AColumnMetadata.JSonName);
  AJSon.AddPair('type', TRttiEnumerationType.GetName<TFieldType>(
    AColumnMetadata.DataType).Substring(2).ToLowerInvariant);
  if AColumnMetadata.DataSize <> 0 then
    AJSon.AddPair('size', TJSonNumber.Create(
      AColumnMetadata.DataSize));
  if AColumnMetadata.Precision <> 0 then
    AJSon.AddPair('precision', TJSonNumber.Create(
      AColumnMetadata.Precision));
  if (not AColumnMap.IsFilterable) or (not CanSerializeColumn(AColumnMap)) then
    AJSon.AddPair('filterable', TJSonBool.Create(False));
  if not CanSerializeColumn(AColumnMap) then
    AJSon.AddPair('readable', TJSonBool.Create(False));
  if not TTJSonDirection.CanDeserializeColumn(ATableMap, AColumnMap) then
    AJSon.AddPair('writable', TJSonBool.Create(False));
end;

procedure TTJSonSerializer.TableMetadataToJSon(
  const AJSon: TJSonObject;
  const ATableMetadata: TTTableMetadata;
  const ATableMap: TTTableMap);
var
  LColumns: TJSonArray;
  LColumnMap: TTColumnMap;
  LColumnMetadata: TTColumnMetadata;
  LColumn: TJSonObject;
begin
  AJSon.AddPair(
    'entity', GetEntityName(String(ATableMap.EntityTypeInfo^.Name)));
  if CanDescribeColumn(ATableMap, ATableMap.PrimaryKey) then
    AJSon.AddPair('primaryKey', GetName(ATableMap.PrimaryKey.Member.Name));
  if Assigned(ATableMap.VersionColumn) and
    CanDescribeColumn(ATableMap, ATableMap.VersionColumn) then
    AJSon.AddPair(
      'versionColumn', GetName(ATableMap.VersionColumn.Member.Name));
  LColumns := TJSonArray.Create;
  try
    for LColumnMap in ATableMap.Columns do
    begin
      LColumnMetadata := ATableMetadata.Columns.Find(
        LColumnMap.LookupName);
      if Assigned(LColumnMetadata) and
        CanDescribeColumn(ATableMap, LColumnMap) then
      begin
        LColumn := TJSonObject.Create;
        try
          ColumnMetadataToJSon(
            LColumn, ATableMap, LColumnMetadata, LColumnMap);

          LColumns.Add(LColumn);
        except
          LColumn.Free;
          raise;
        end;
      end;
    end;
    AJSon.AddPair('properties', LColumns);
  except
    LColumns.Free;
    raise;
  end;
end;

function TTJSonSerializer.MetadataToJSon(
  const ATableMetadata: TTTableMetadata;
  const ATableMap: TTTableMap): String;
var
  LResult: TJSonObject;
begin
  LResult := TJSonObject.Create;
  try
    TableMetadataToJSon(LResult, ATableMetadata, ATableMap);
    result := LResult.ToJSon;
  finally
    LResult.Free;
  end;
end;

end.
