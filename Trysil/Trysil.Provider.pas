﻿(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Provider;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.IdentityMap,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Data.Columns,
  Trysil.Rtti;

type

{ TTProvider }

  TTProvider = class
  strict private
    FConnection: TTConnection;
    FContext: TObject;
    FMetadata: TTMetadata;
    FIdentityMap: TTIdentityMap;

    FInLoading: Boolean;

    FLazyOwner: TObjectList<TObject>;

    function GetUseIdentityMap: Boolean;

    function InternalCreateEntity<T: class>(
      const ATableMap: TTTAbleMap; const AReader: TTReader): T;

    function SetPrimaryKey<T: class>(
      const ATablemap: TTTableMap; const AEntity: T): TTPrimaryKey;
    function GetValue(
      const AReader: TTReader; const AColumnName: String): TTValue;

    procedure MapColumns(
      const ATableMap: TTTAbleMap;
      const AReader: TTReader;
      const AEntity: TObject);
    procedure MapLazyColumn(
      const AReader: TTReader;
      const AColumnName: String;
      const ADetailColumnName: String;
      const ARttiMember: TTRttiMember;
      const AEntity: TObject;
      const AIsDetail: Boolean);
    procedure MapLazyColumns(
      const ATableMap: TTTAbleMap;
      const AReader: TTReader;
      const AEntity: TObject);
    procedure MapLazyListColumns(
      const ATableMap: TTTAbleMap;
      const AReader: TTReader;
      const AEntity: TObject);

    procedure MapEntity(
      const ATableMap: TTTAbleMap;
      const AReader: TTReader;
      const AEntity: TObject);

    procedure SelectAndMapList(
      const AObject: TObject;
      const AColumnName: String;
      const AID: TTPrimaryKey);
    procedure GetAndMapObject(const AObject: TObject; const AID: TTPrimaryKey);

    function GetPrimaryKey(
      const ATablemap: TTTableMap; const AReader: TTReader): TTPrimaryKey;
    function GetWhere(
      const AColumnName: String; const AID: TTPrimaryKey): String; overload;
    function GetWhere(
      const ATablemap: TTTableMap; const AID: TTPrimaryKey): String; overload;
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata;
      const AUseIdentityMap: Boolean);
    destructor Destroy; override;

    function CreateDataset(const ASQL: String): TDataset;

    function CreateEntity<T: class>(const AInLoading: Boolean): T;
    function GetID<T: class>(const AEntity: T): TTPrimaryKey;
    procedure SetSequenceID<T: class>(const AEntity: T);
    function CloneEntity<T: class>(const AEntity: T): T;

    function GetMetadata<T: class>(): TTTableMetadata;

    function SelectCount<T: class>(const AFilter: TTFilter): Integer;

    procedure Select<T: class>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    function Get<T: class>(const AID: TTPrimaryKey): T;

    procedure Refresh<T: class>(const AEntity: T);

    property UseIdentityMap: Boolean read GetUseIdentityMap;
  end;

implementation

{ TTProvider }

constructor TTProvider.Create(
  const AConnection: TTConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata;
  const AUseIdentityMap: Boolean);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;

  FIdentityMap := nil;
  if AUseIdentityMap then
    FIdentityMap := TTIdentityMap.Create;

  FInLoading := False;

  FLazyOwner := TObjectList<TObject>.Create(True);
end;

destructor TTProvider.Destroy;
begin
  if Assigned(FIdentityMap) then
    FIdentityMap.Free;
  FLazyOwner.Free;
  inherited Destroy;
end;

function TTProvider.CreateDataset(const ASQL: String): TDataset;
begin
  result := FConnection.CreateDataSet(ASQL, TTFilter.Empty);
end;

function TTProvider.GetUseIdentityMap: Boolean;
begin
  result := Assigned(FIdentityMap);
end;

function TTProvider.SetPrimaryKey<T>(
  const ATablemap: TTTableMap; const AEntity: T): TTPrimaryKey;
begin
  result := FConnection.GetSequenceID(ATableMap);
  ATableMap.PrimaryKey.Member.SetValue(AEntity, result);
end;

function TTProvider.GetID<T>(const AEntity: T): TTPrimaryKey;
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  result :=
    LTableMap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>();
end;

procedure TTProvider.SetSequenceID<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  SetPrimaryKey<T>(LTablemap, AEntity);
end;

function TTProvider.CreateEntity<T>(const AInLoading: Boolean): T;
var
  LTableMap: TTTableMap;
  LRttiEntity: TTRttiEntity<T>;
  LPrimaryKey: TTPrimaryKey;
begin
  FInLoading := AInLoading;
  try
    LTableMap := TTMapper.Instance.Load<T>();
    if not Assigned(LTablemap.PrimaryKey) then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));
    if LTableMap.SequenceName.IsEmpty then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SNotDefinedSequence));

    LRttiEntity := TTRttiEntity<T>.Create;
    try
      result := LRttiEntity.CreateEntity(FContext);
      try
        LPrimaryKey := 0;
        if not FInLoading then
          LPrimaryKey := SetPrimaryKey<T>(LTableMap, result);
        MapEntity(LTableMap, nil, result);
        if not (FInLoading) and Assigned(FIdentityMap) then
          FIdentityMap.AddEntity<T>(LPrimaryKey, result);
      except
        result.Free;
        raise;
      end;
    finally
      LRttiEntity.Free;
    end;
  finally
    FInLoading := False;
  end;
end;

function TTProvider.InternalCreateEntity<T>(
  const ATableMap: TTTAbleMap; const AReader: TTReader): T;
var
  LPrimaryKey: TTPrimaryKey;
  LRttiEntity: TTRttiEntity<T>;
begin
  LPrimaryKey := GetPrimaryKey(ATableMap, AReader);
  result := nil;
  if Assigned(FIdentityMap) then
    result := FIdentityMap.GetEntity<T>(LPrimaryKey);

  if not Assigned(result) then
  begin
    LRttiEntity := TTRttiEntity<T>.Create;
    try
      result := LRttiEntity.CreateEntity(FContext);
      if Assigned(FIdentityMap) then
        FIdentityMap.AddEntity<T>(LPrimaryKey, result);
    finally
      LRttiEntity.Free;
    end;
  end;

  MapEntity(ATableMap, AReader, result);
end;

function TTProvider.CloneEntity<T>(const AEntity: T): T;
var
  LTableMap: TTTableMap;
  LRttiEntity: TTRttiEntity<T>;
  LColumnMap: TTColumnMap;
  LDetailColumnMap: TTDetailColumnMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LRttiEntity := TTRttiEntity<T>.Create;
  try
    result := LRttiEntity.CreateEntity(FContext);
    try
      MapEntity(LTableMap, nil, result);
      for LColumnMap in LTableMap.Columns do
        if LColumnMap.Member.IsClass then
          LColumnMap.Member.CloneLazyID(result, AEntity)
        else
          LColumnMap.Member.SetValue(
            result, LColumnMap.Member.GetValue(AEntity));

      for LDetailColumnMap in LTableMap.DetailColums do
        LDetailColumnMap.Member.CloneLazyID(result, AEntity);
    except
      result.Free;
      raise;
    end;
  finally
    LRttiEntity.Free;
  end;
end;

function TTProvider.GetValue(
  const AReader: TTReader; const AColumnName: String): TTValue;
var
  LColumn: TTColumn;
begin
    if Assigned(AReader) then
    begin
      LColumn := AReader.ColumnByName(AColumnName);
      result := LColumn.Value;
    end
    else
      result := 0;
end;

procedure TTProvider.MapColumns(
  const ATableMap: TTTAbleMap;
  const AReader: TTReader;
  const AEntity: TObject);
var
  LColumnMap: TTColumnMap;
  LColumn: TTColumn;
begin
  for LColumnMap in ATableMap.Columns do
  begin
    if not LColumnMap.Member.IsClass then
    begin
      LColumn := AReader.ColumnByName(LColumnMap.Name);
      LColumn.SetValue(AEntity);
    end;
  end;
end;

procedure TTProvider.MapLazyColumn(
  const AReader: TTReader;
  const AColumnName: String;
  const ADetailColumnName: String;
  const ARttiMember: TTRttiMember;
  const AEntity: TObject;
  const AIsDetail: Boolean);
var
  LValue: TTValue;
  LResult: TObject;
begin
  LValue := GetValue(AReader, AColumnName);
  LResult := ARttiMember.CreateObject(
    AEntity, FContext, ADetailColumnName, LValue);

  if Assigned(LResult) then
  begin
    if TTRttiLazy.IsLazy(LResult) then
      FLazyOwner.Add(LResult)
    else if AIsDetail then
      SelectAndMapList(
        LResult, ADetailColumnName, LValue.AsType<TTPrimaryKey>())
    else
      GetAndMapObject(LResult, LValue.AsType<TTPrimaryKey>());
  end;
end;

procedure TTProvider.MapLazyColumns(
  const ATableMap: TTTAbleMap;
  const AReader: TTReader;
  const AEntity: TObject);
var
  LColumnMap: TTColumnMap;
begin
  for LColumnMap in ATableMap.Columns do
    if LColumnMap.Member.IsClass then
      MapLazyColumn(
        AReader,
        LColumnMap.Name,
        LColumnMap.Name,
        LColumnMap.Member,
        AEntity,
        False);
end;

procedure TTProvider.MapLazyListColumns(
  const ATableMap: TTTAbleMap;
  const AReader: TTReader;
  const AEntity: TObject);
var
  LColumnMap: TTDetailColumnMap;
begin
  for LColumnMap in ATableMap.DetailColums do
    if LColumnMap.Member.IsClass then
      MapLazyColumn(
        AReader,
        LColumnMap.Name,
        LColumnMap.DetailName,
        LColumnMap.Member,
        AEntity,
        True);
end;

procedure TTProvider.MapEntity(
  const ATableMap: TTTAbleMap;
  const AReader: TTReader;
  const AEntity: TObject);
begin
  if Assigned(AReader) then
    MapColumns(ATableMap, AReader, AEntity);
  MapLazyColumns(ATableMap, AReader, AEntity);
  MapLazyListColumns(ATableMap, AReader, AEntity);
end;

procedure TTProvider.SelectAndMapList(
  const AObject: TObject;
  const AColumnName: String;
  const AID: TTPrimaryKey);
var
  LGenericList: TTRttiGenericList;
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTReader;
  LObject: TObject;
begin
  LGenericList := TTRttiGenericList.Create(AObject);
  try
    LTableMap := TTMapper.Instance.Load(LGenericList.GenericTypeInfo);
    LTableMetadata := FMetadata.Load(LGenericList.GenericTypeInfo);
    LFilter := TTFilter.Create(GetWhere(AColumnName, AID));
    LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
    try
      LGenericList.Clear;
      while not LReader.Eof do
      begin
        LObject := LGenericList.CreateObject;
        try
          MapEntity(LTableMap, LReader, LObject);
          LGenericList.Add(LObject);
        except
          LObject.Free;
          raise;
        end;
        LReader.Next;
      end;
    finally
        LReader.Free;
    end;
  finally
    LGenericList.Free;
  end;
end;

procedure TTProvider.GetAndMapObject(
  const AObject: TObject; const AID: TTPrimaryKey);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTReader;
begin
  LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
  LTableMetadata := FMetadata.Load(AObject.ClassInfo);
  LFilter := TTFilter.Create(GetWhere(LTablemap, AID));
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
    if not LReader.IsEmpty then
      MapEntity(LTableMap, LReader, AObject);
  finally
    LReader.Free;
  end;
end;

function TTProvider.GetMetadata<T>: TTTableMetadata;
begin
  result := FMetadata.Load<T>();
end;

function TTProvider.GetPrimaryKey(
  const ATablemap: TTTableMap; const AReader: TTReader): TTPrimaryKey;
var
  LColumn: TTColumn;
  LResult: TTValue;
begin
  if not Assigned(ATablemap.PrimaryKey) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));
  LColumn := AReader.ColumnByName(ATablemap.PrimaryKey.Name);
  LResult := LColumn.Value;
  if not LResult.IsType<TTPrimaryKey>() then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotValidPrimaryKeyType));
  result := LResult.AsType<TTPrimaryKey>();
end;

function TTProvider.GetWhere(
  const AColumnName: String; const AID: TTPrimaryKey): String;
begin
  result := Format('%s = %s', [AColumnName, TTPrimaryKeyHelper.SqlValue(AID)]);
end;

function TTProvider.GetWhere(
  const ATablemap: TTTableMap; const AID: TTPrimaryKey): String;
begin
  if not Assigned(ATablemap.PrimaryKey) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));
  result := GetWhere(ATablemap.PrimaryKey.Name, AID);
end;

function TTProvider.SelectCount<T>(const AFilter: TTFilter): Integer;
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  result := FConnection.SelectCount(LTableMap, AFilter);
end;

procedure TTProvider.Select<T>(
  const AResult: TTList<T>; const AFilter: TTFilter);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LReader: TTReader;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, AFilter);
  try
    AResult.Clear;
    while not LReader.Eof do
    begin
      AResult.Add(InternalCreateEntity<T>(LTableMap, LReader));
      LReader.Next;
    end;
  finally
    LReader.Free;
  end;
end;

function TTProvider.Get<T>(const AID: TTPrimaryKey): T;
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTReader;
begin
  result := default(T);
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LFilter := TTFilter.Create(GetWhere(LTablemap, AID));
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
    if not LReader.IsEmpty then
      result := InternalCreateEntity<T>(LTableMap, LReader);
  finally
    LReader.Free;
  end;
end;

procedure TTProvider.Refresh<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTReader;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LFilter := TTFilter.Create(GetWhere(
    LTablemap,
    LTablemap.PrimaryKey.Member.GetValue(AEntity).AsType<TTPrimaryKey>()));
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
    if not LReader.IsEmpty then
      MapEntity(LTableMap, LReader, AEntity);
  finally
    LReader.Free;
  end;
end;

end.
