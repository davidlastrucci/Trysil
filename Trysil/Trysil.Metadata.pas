(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Metadata;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Hash,
  System.Generics.Defaults,
  Data.DB,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Classes,
  Trysil.Cache,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Factory,
  Trysil.Generics.Collections;

type

{ TTColumnType }

  TTColumnType = record
  strict private
    FDataType: TFieldType;
    FDataSize: Integer;
    FPrecision: Integer;
  public
    constructor Create(
      const ADataType: TFieldType;
      const ADataSize: Integer;
      const APrecision: Integer);

    property DataType: TFieldType read FDataType;
    property DataSize: Integer read FDataSize;
    property Precision: Integer read FPrecision;
  end;

{ TTColumnMetadata }

  TTColumnMetadata = class
  strict private
    FColumnName: String;
    FSqlReference: String;
    FColumnType: TTColumnType;
    FIsGuid: Boolean;
    FIsCurrency: Boolean;
    FIsFilterable: Boolean;
    FJSonName: String;
    FAttributes: TArray<String>;

    function GetDataType: TFieldType;
    function GetDataSize: Integer;
    function GetPrecision: Integer;
  public
    constructor Create(
      const AColumnName: String;
      const ASqlReference: String;
      const AColumnType: TTColumnType;
      const AColumnMap: TTColumnMap);

    function HasAttribute(const AAttribute: TClass): Boolean;

    property ColumnName: String read FColumnName;
    property SqlReference: String read FSqlReference;
    property DataType: TFieldType read GetDataType;
    property DataSize: Integer read GetDataSize;
    property Precision: Integer read GetPrecision;
    property IsGuid: Boolean read FIsGuid;
    property IsCurrency: Boolean read FIsCurrency;
    property IsFilterable: Boolean read FIsFilterable;
    property JSonName: String read FJSonName;
  end;

{ TTColumnsMetadata }

  TTColumnsMetadata = class
  strict private
    FColumns: TTObjectList<TTColumnMetadata>;

    function GetEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(
      const AColumnName: String;
      const ASqlReference: String;
      const AColumnType: TTColumnType;
      const AColumnMap: TTColumnMap);

    function Find(const AColumnName: String): TTColumnMetadata;

    function GetEnumerator: TTListEnumerator<TTColumnMetadata>;

    property Empty: Boolean read GetEmpty;
  end;

{ TTTableMetadata }

  TTTableMetadata = class
  strict private
    FTableName: String;
    FPrimaryKey: String;
    FColumns: TTColumnsMetadata;

    class procedure CheckTableMap(const ATableMap: TTTableMap); static;
  public
    constructor Create(const ATableMap: TTTableMap);
    destructor Destroy; override;

    property TableName: String read FTableName;
    property PrimaryKey: String read FPrimaryKey;
    property Columns: TTColumnsMetadata read FColumns;
  end;

{ TTMetadataProvider }

  TTMetadataProvider = class abstract
  strict protected
    function GetConnectionName: String; virtual; abstract;
  public
    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); virtual; abstract;

    property ConnectionName: String read GetConnectionName;
  end;

{ TTMetadataKey }

  TTMetadataKey = record
  strict private
    FConnectionName: String;
    FTypeInfo: PTypeInfo;
  public
    constructor Create(
      const AConnectionName: String; const ATypeInfo: PTypeInfo);

    property ConnectionName: String read FConnectionName;
    property TypeInfo: PTypeInfo read FTypeInfo;
  end;

{ TTMetadataKeyComparer }

  TTMetadataKeyComparer = class(TEqualityComparer<TTMetadataKey>)
  public
    function Equals(
      const ALeft: TTMetadataKey;
      const ARight: TTMetadataKey): Boolean; override;
    function GetHashCode(const AValue: TTMetadataKey): Integer; override;
  end;

{ TTMetadataCache }

  TTMetadataCache = class(TTCache<TTMetadataKey, TTTableMetadata>)
  strict private
    class var FInstance: TTMetadataCache;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateObject(
      const AKey: TTMetadataKey): TTTableMetadata; override;
  public
    function Load(
      const AConnectionName: String;
      const ATypeInfo: PTypeInfo;
      const AAfterCreate: TTAfterCreateObjectMethod<
        TTTableMetaData>): TTTableMetaData;

    class property Instance: TTMetadataCache read FInstance;
  end;

{ TTMetadata }

  TTMetadata = class
  strict private
    FMetadataProvider: TTMetadataProvider;
  public
    constructor Create(const AMetadataProvider: TTMetadataProvider);

    function Load<T: class>(): TTTableMetaData; overload;
    function Load(const ATypeInfo: PTypeInfo): TTTableMetaData; overload;
  end;

implementation

{ TTColumnType }

constructor TTColumnType.Create(
  const ADataType: TFieldType;
  const ADataSize: Integer;
  const APrecision: Integer);
begin
  FDataType := ADataType;
  FDataSize := ADataSize;
  FPrecision := APrecision;
end;

{ TTColumnMetadata }

constructor TTColumnMetadata.Create(
  const AColumnName: String;
  const ASqlReference: String;
  const AColumnType: TTColumnType;
  const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FColumnName := AColumnName;
  FSqlReference := ASqlReference;
  FColumnType := AColumnType;
  FIsGuid := Assigned(AColumnMap) and AColumnMap.IsGuid;
  FIsCurrency := Assigned(AColumnMap) and AColumnMap.IsCurrency;
  FIsFilterable := Assigned(AColumnMap) and AColumnMap.IsFilterable;
  if Assigned(AColumnMap) and Assigned(AColumnMap.Member) then
  begin
    FAttributes := AColumnMap.Member.AttributeNames;
    FJSonName := TTIdentifier.PublishedName(AColumnMap.Member.Name);
    if TTRttiLazy.IsLazyType(AColumnMap.Member.RttiType) then
      FJSonName := Format('%sID', [FJSonName]);
  end;
end;

function TTColumnMetadata.HasAttribute(const AAttribute: TClass): Boolean;
var
  LName: String;
begin
  result := False;
  for LName in FAttributes do
    if LName = AAttribute.QualifiedClassName then
    begin
      result := True;
      Break;
    end;
end;

function TTColumnMetadata.GetDataType: TFieldType;
begin
  result := FColumnType.DataType;
end;

function TTColumnMetadata.GetDataSize: Integer;
begin
  result := FColumnType.DataSize;
end;

function TTColumnMetadata.GetPrecision: Integer;
begin
  result := FColumnType.Precision;
end;

{ TTColumnsMetadata }

constructor TTColumnsMetadata.Create;
begin
  inherited Create;
  FColumns := TTObjectList<TTColumnMetadata>.Create(True);
end;

destructor TTColumnsMetadata.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

procedure TTColumnsMetadata.Add(
  const AColumnName: String;
  const ASqlReference: String;
  const AColumnType: TTColumnType;
  const AColumnMap: TTColumnMap);
var
  LColumnMetadata: TTColumnMetadata;
begin
  LColumnMetadata := TTColumnMetadata.Create(
    AColumnName, ASqlReference, AColumnType, AColumnMap);
  try
    FColumns.Add(LColumnMetadata);
  except
    LColumnMetadata.Free;
    raise;
  end;
end;

function TTColumnsMetadata.Find(const AColumnName: String): TTColumnMetadata;
var
  LColumnMetadata: TTColumnMetadata;
begin
  result := nil;
  for LColumnMetadata in FColumns do
    if TTIdentifier.Same(LColumnMetadata.ColumnName, AColumnName) then
    begin
      result := LColumnMetadata;
      Break;
    end;
end;

function TTColumnsMetadata.GetEmpty: Boolean;
begin
  result := (FColumns.Count = 0);
end;

function TTColumnsMetadata.GetEnumerator: TTListEnumerator<TTColumnMetadata>;
begin
  result := TTListEnumerator<TTColumnMetadata>.Create(FColumns);
end;

{ TTTableMetadata }

class procedure TTTableMetadata.CheckTableMap(const ATableMap: TTTableMap);
var
  LEntityName: String;
begin
  LEntityName := String(ATableMap.EntityTypeInfo^.Name);
  if ATableMap.Name.IsEmpty then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidTableName), [
        LEntityName]);

  if ATableMap.Columns.Empty then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNoMappedColumns), [
        LEntityName]);

  if not Assigned(ATableMap.PrimaryKey) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));
end;

constructor TTTableMetadata.Create(const ATableMap: TTTableMap);
begin
  inherited Create;
  CheckTableMap(ATableMap);
  FTableName := ATableMap.Name;
  FPrimaryKey := ATableMap.PrimaryKey.Name;
  FColumns := TTColumnsMetadata.Create;
end;

destructor TTTableMetadata.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

{ TTMetadataKey }

constructor TTMetadataKey.Create(
  const AConnectionName: String; const ATypeInfo: PTypeInfo);
begin
  FConnectionName := AConnectionName;
  FTypeInfo := ATypeInfo;
end;

{ TTMetadataKeyComparer }

function TTMetadataKeyComparer.Equals(
  const ALeft: TTMetadataKey; const ARight: TTMetadataKey): Boolean;
begin
  result := (ALeft.TypeInfo = ARight.TypeInfo) and
    TTIdentifier.Same(ALeft.ConnectionName, ARight.ConnectionName);
end;

function TTMetadataKeyComparer.GetHashCode(
  const AValue: TTMetadataKey): Integer;
begin
  result := THashBobJenkins.GetHashValue(
    AValue.ConnectionName.ToUpperInvariant) xor
    Integer(NativeInt(AValue.TypeInfo));
end;

{ TTMetadataCache }

class constructor TTMetadataCache.ClassCreate;
begin
  FInstance := TTMetadataCache.Create(TTMetadataKeyComparer.Create);
end;

class destructor TTMetadataCache.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

function TTMetadataCache.CreateObject(
  const AKey: TTMetadataKey): TTTableMetadata;
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load(AKey.TypeInfo);
  result := TTTableMetadata.Create(LTableMap);
end;

function TTMetadataCache.Load(
  const AConnectionName: String;
  const ATypeInfo: PTypeInfo;
  const AAfterCreate: TTAfterCreateObjectMethod<
    TTTableMetaData>): TTTableMetaData;
begin
  result := GetValueOrCreate(
    TTMetadataKey.Create(AConnectionName, ATypeInfo), AAfterCreate);
end;

{ TTMetadata }

constructor TTMetadata.Create(const AMetadataProvider: TTMetadataProvider);
begin
  inherited Create;
  FMetadataProvider := AMetadataProvider;
end;

function TTMetadata.Load<T>: TTTableMetaData;
begin
  result := Load(TTFactory.Instance.GetType<T>());
end;

function TTMetadata.Load(const ATypeInfo: PTypeInfo): TTTableMetaData;
begin
  result := TTMetadataCache.Instance.Load(
    FMetadataProvider.ConnectionName,
    ATypeInfo,
    procedure(const AMetaData: TTTableMetaData)
    var
      LTableMap: TTTableMap;
    begin
      LTableMap := TTMapper.Instance.Load(ATypeInfo);
      FMetadataProvider.GetMetadata(LTableMap, AMetaData);
    end);
end;

end.
