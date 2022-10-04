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
  Data.DB,

  Trysil.Exceptions,
  Trysil.Classes,
  Trysil.Cache,
  Trysil.Mapping,
  Trysil.Factory,
  Trysil.Generics.Collections;

type

{ TTColumnMetadata }

  TTColumnMetadata = class
  strict private
    FColumnName: String;
    FDataType: TFieldType;
    FDataSize: Integer;
  public
    constructor Create(
      const AColumnName: String;
      const ADataType: TFieldType;
      const ADataSize: Integer);

    property ColumnName: String read FColumnName;
    property DataType: TFieldType read FDataType;
    property DataSize: Integer read FDataSize;
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
      const ADataType: TFieldType;
      const ADataSize: Integer);

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
  public
    constructor Create(const ATableMap: TTTableMap);
    destructor Destroy; override;

    property TableName: String read FTableName;
    property PrimaryKey: String read FPrimaryKey;
    property Columns: TTColumnsMetadata read FColumns;
  end;

{ TTMetadataProvider }

  TTMetadataProvider = class abstract
  public
    procedure GetMetadata(
      const ATableMap: TTTableMap;
      const ATableMetadata: TTTableMetadata); virtual; abstract;
  end;

{ TTMetadataCache }

  TTMetadataCache = class(TTCache<PTypeInfo, TTTableMetadata>)
  strict private
    class var FInstance: TTMetadataCache;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict protected
    function CreateObject(
      const ATypeInfo: PTypeInfo): TTTableMetadata; override;
  public
    function Load(
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

{ TTColumnMetadata }

constructor TTColumnMetadata.Create(
  const AColumnName: String;
  const ADataType: TFieldType;
  const ADataSize: Integer);
begin
  inherited Create;
  FColumnName := AColumnName;
  FDataType := ADataType;
  FDataSize := ADataSize;
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
  const ADataType: TFieldType;
  const ADataSize: Integer);
var
  LColumnMetadata: TTColumnMetadata;
begin
  LColumnMetadata := TTColumnMetadata.Create(AColumnName, ADataType, ADataSize);
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
    if String.Compare(LColumnMetadata.ColumnName, AColumnName, True) = 0 then
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

constructor TTTableMetadata.Create(const ATableMap: TTTableMap);
begin
  inherited Create;
  FTableName := ATableMap.Name;
  FPrimaryKey := ATableMap.PrimaryKey.Name;
  FColumns := TTColumnsMetadata.Create;
end;

destructor TTTableMetadata.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

{ TTMetadataCache }

class constructor TTMetadataCache.ClassCreate;
begin
  FInstance := TTMetadataCache.Create;
end;

class destructor TTMetadataCache.ClassDestroy;
begin
  FInstance.Free;
end;

function TTMetadataCache.CreateObject(
  const ATypeInfo: PTypeInfo): TTTableMetadata;
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load(ATypeInfo);
  result := TTTableMetadata.Create(LTableMap);
end;

function TTMetadataCache.Load(
  const ATypeInfo: PTypeInfo;
  const AAfterCreate: TTAfterCreateObjectMethod<
    TTTableMetaData>): TTTableMetaData;
begin
  result := GetValueOrCreate(ATypeInfo, AAfterCreate);
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
