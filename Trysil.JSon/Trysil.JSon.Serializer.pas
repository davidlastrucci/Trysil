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
  System.TypInfo,
  System.Rtti,
  Data.DB,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Metadata,

  Trysil.JSon.Types,
  Trysil.JSon.Rtti,
  Trysil.JSon.Events,
  Trysil.JSon.Serializer.Classes;

type

{ TTJSonSerializer }

  TTJSonSerializer = class(TTJSon)
  strict private
    FRttiContext: TRttiContext;
    FConfig: TTJSonSerializerConfig;
    FLevel: Integer;

    procedure AddLazyID(
      const AObject: TObject; const AName: String; const AJSon: TJSonObject);
    function GetJSonValue(const AValue: TTValue): TJSonValue;
    function GetJSonNullableValue(const AValue: TTValue): TJSonValue;
    function GetJSonObjectOrArrayValue(const AValue: TTValue): TJSonValue;
    function GetJSonObjectValue(const AObject: TObject): TJSonObject;
    procedure GetJSonListValue(
      const AList: TTJSonList; const AResult: TJSonArray);

    procedure ColumnsToJSonObject(
      const AObject: TObject; const AResult: TJSonObject);
    procedure DetailColumnsToJSonObject(
      const AObject: TObject; const AResult: TJSonObject);

    procedure InternalEntityToJSon(
      const AObject: TObject; const AResult: TJSonObject);

    procedure ColumnMetadataToJSon(
      const AJSon: TJSonObject;
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
end;

destructor TTJSonSerializer.Destroy;
begin
  FRttiContext.Free;
  inherited Destroy;
end;

procedure TTJSonSerializer.AddLazyID(
  const AObject: TObject; const AName: String; const AJSon: TJSonObject);
var
  LLazy: TTRttiLazy;
begin
  LLazy := TTRttiLazy.Create(AObject);
  try
    AJSon.AddPair(Format('%sID', [AName]), TJSonNumber.Create(LLazy.ID));
  finally
    LLazy.Free;
  end;
end;

function TTJSonSerializer.GetJSonValue(const AValue: TTValue): TJSonValue;
var
  LSerializer: TTJSonAbstractSerializer;
begin
  if AValue.IsEmpty then
    result := TJSonNull.Create
  else
  begin
    LSerializer := TTJSonSerializers.Instance.Get(AValue.TypeInfo).Create;
    try
      result := LSerializer.ToJSon(AValue);
    finally
      LSerializer.Free;
    end;
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
  LObject := GetLazyObject(AValue.AsObject);
  result := nil;
  if Assigned(LObject) then
  begin
    try
      LList := TTJSonList.Create(FRttiContext, LObject);
      try
        if LList.IsList then
        begin
          result := TJSonArray.Create;
          try
            GetJSonListValue(LList, TJSonArray(result));
          except
            result.Free;
            raise;
          end;
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
  if (FConfig.MaxLevels < 0) or (FLevel <= FConfig.MaxLevels) then
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
begin
  LCount := AList.Count;
  for LIndex := 0 to LCount - 1 do
  begin
    LItem := AList.Items[LIndex];
    if LItem.IsObject then
      AResult.Add(GetJSonObjectValue(LItem.AsObject));
  end;
end;

procedure TTJSonSerializer.ColumnsToJSonObject(
  const AObject: TObject; const AResult: TJSonObject);
var
  LTableMap: TTTableMap;
  LColumnMap: TTColumnMap;
  LName: String;
  LObject: TObject;
  LValue: TJSonValue;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  for LColumnMap in LTableMap.Columns do
  begin
    LName := GetName(LColumnMap.Member.Name);

    if LColumnMap.Member.IsNullable then
      LValue := GetJSonNullableValue(LColumnMap.Member.GetValue(AObject))
    else if LColumnMap.Member.IsClass then
    begin
      LObject := LColumnMap.Member.GetValue(AObject).AsObject;
      if TTRttiLazy.IsLazy(LObject) then
        AddLazyID(LObject, LName, AResult);
      LValue := GetJSonObjectOrArrayValue(LObject);
    end
    else
      LValue := GetJSonValue(LColumnMap.Member.GetValue(AObject));

    if Assigned(LValue) then
      AResult.AddPair(LName, LValue);
  end;
end;

procedure TTJSonSerializer.DetailColumnsToJSonObject(
  const AObject: TObject; const AResult: TJSonObject);
var
  LLevel: Integer;
  LTableMap: TTTableMap;
  LDetailColumnMap: TTDetailColumnMap;
  LName: String;
  LValue: TTValue;
begin
  LLevel := FLevel;
  try
    LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
    for LDetailColumnMap in LTableMap.DetailColums do
    begin
      FLevel := 0;
      LName := GetName(LDetailColumnMap.Member.Name);
      LValue := LDetailColumnMap.Member.GetValue(AObject);
      if LValue.IsObject then
        AResult.AddPair(LName, GetJSonObjectOrArrayValue(LValue.AsObject));
    end;
  finally
    FLevel := LLevel;
  end;
end;

procedure TTJSonSerializer.InternalEntityToJSon(
  const AObject: TObject; const AResult: TJSonObject);
var
  LEvent: TTJSonEvent;
begin
  Inc(FLevel);
  try
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
    Dec(FLevel);
  end;
end;

procedure TTJSonSerializer.EntityToJSon(
  const AObject: TObject;
  const AResult: TJSonObject;
  const AConfig: TTJSonSerializerConfig);
begin
  FConfig := TTJSonSerializerConfig.Create(AConfig);
  FLevel := 0;
  InternalEntityToJSon(AObject, AResult);
end;

procedure TTJSonSerializer.ColumnMetadataToJSon(
  const AJSon: TJSonObject;
  const AColumnMetadata: TTColumnMetadata;
  const AColumnMap: TTColumnMap);
begin
  if TTRttiLazy.IsLazyType(AColumnMap.Member.RttiType) then
    AJSon.AddPair('name', Format('%sID', [GetName(AColumnMap.Member.Name)]))
  else
    AJSon.AddPair('name', GetName(AColumnMap.Member.Name));
  AJSon.AddPair('type', TRttiEnumerationType.GetName<TFieldType>(
    AColumnMetadata.DataType).Substring(2).ToLower());
  if AColumnMetadata.DataSize <> 0 then
    AJSon.AddPair('size', TJSonNumber.Create(
      AColumnMetadata.DataSize));
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
  AJSon.AddPair('tableName', ATableMap.Name);
  AJSon.AddPair('primaryKey', GetName(ATableMap.PrimaryKey.Member.Name));
  AJSon.AddPair('versionColumn', GetName(ATableMap.VersionColumn.Member.Name));
  LColumns := TJSonArray.Create;
  try
    for LColumnMap in ATableMap.Columns do
    begin
      LColumnMetadata := ATableMetadata.Columns.Find(LColumnMap.Name);
      if Assigned(LColumnMetadata) then
      begin
        LColumn := TJSonObject.Create;
        try
          ColumnMetadataToJSon(LColumn, LColumnMetadata, LColumnMap);

          LColumns.Add(LColumn);
        except
          LColumn.Free;
          raise;
        end;
      end;
    end;
    AJSon.AddPair('columns', LColumns);
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
