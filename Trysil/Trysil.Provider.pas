(*

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
  System.TypInfo,
  Data.DB,

  Trysil.Consts,
  Trysil.Classes,
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

  TTNewEntityCache = class;

{ TTProvider }

  TTProvider = class
  strict private
    FConnection: TTConnection;
    FContext: TObject;
    FMetadata: TTMetadata;
    FIdentityMap: TTIdentityMap;
    FNewEntityCache: TTNewEntityCache;

    FInLoading: Boolean;

    FLazyOwner: TObjectDictionary<Pointer, TObjectList<TObject>>;

    procedure AddLazyOwner(
      const AEntity: TObject; const ALazy: TObject);

    function GetUseIdentityMap: Boolean;
    function GetLazyOwnerCount: Integer;
    function LoadAndCheckTableMap<T: class>(): TTTableMap;
    procedure CheckRawFilter(const AFilter: TTFilter);

    function InternalCreateEntity<T: class>(
      const ATableMap: TTTAbleMap;
      const AReader: TTReader;
      const ARttiEntity: TTRttiEntity<T>): T;

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
    function FindColumnByName(
      const ATablemap: TTTableMap;
      const AColumnName: String): TTColumnMap;
    function GetWhere(
      const ATablemap: TTTableMap;
      const AColumnName: String;
      const AID: TTPrimaryKey): String; overload;
    function GetWhere(
      const ATablemap: TTTableMap; const AID: TTPrimaryKey): String; overload;
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata;
      const AUseIdentityMap: Boolean);
    destructor Destroy; override;

    function CreateDataset(const ASQL: String): TDataset; overload;
    function CreateDataset(
      const ASQL: String; const AFilter: TTFilter): TDataset; overload;

    procedure DisposedEntity(const AEntity: TObject);

    function CreateEntity<T: class>(const AInLoading: Boolean): T;
    function GetID<T: class>(const AEntity: T): TTPrimaryKey;
    procedure SetSequenceID<T: class>(const AEntity: T);
    function CloneEntity<T: class>(const AEntity: T): T;

    function GetMetadata<T: class>(): TTTableMetadata;
    function IdentityMapOwns(const ATableMap: TTTableMap): Boolean;

    function SelectCount<T: class>(const AFilter: TTFilter): Int64;

    procedure Select<T: class>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    function Get<T: class>(
      const AID: TTPrimaryKey; const AIncludeDeleted: Boolean): T;

    function TryRefresh<T: class>(const AEntity: T): Boolean;
    procedure Refresh<T: class>(const AEntity: T);

    procedure RawSelect<T: class>(
      const ASQL: String; const AResult: TTList<T>); overload;
    procedure RawSelect<T: class>(
      const ASQL: String;
      const AFilter: TTFilter;
      const AResult: TTList<T>); overload;

    property UseIdentityMap: Boolean read GetUseIdentityMap;
    property LazyOwnerCount: Integer read GetLazyOwnerCount;
    property NewEntityCache: TTNewEntityCache read FNewEntityCache;
  end;

{ TTNewEntityCache }

  TTNewEntityCache = class(TTTransactionObserver)
  strict private
    FCache: TTHashList<Pointer>;
    FTransactionCache: TTHashList<Pointer>;

    procedure ClearTransaction;
  strict protected
    procedure TransactionStarted; override;
    procedure TransactionCommitted; override;
    procedure TransactionRolledback; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AEntity: TObject);
    function Contains(const AEntity: TObject): Boolean;
    procedure Remove(const AEntity: TObject);
    procedure Disposed(const AEntity: TObject);
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

  FLazyOwner := TObjectDictionary<
    Pointer, TObjectList<TObject>>.Create([doOwnsValues]);
  FNewEntityCache := TTNewEntityCache.Create;
end;

destructor TTProvider.Destroy;
var
  LLazyOwner: TObjectDictionary<Pointer, TObjectList<TObject>>;
  LIdentityMap: TTIdentityMap;
  LNewEntityCache: TTNewEntityCache;
begin
  LLazyOwner := FLazyOwner;
  FLazyOwner := nil;
  LLazyOwner.Free;

  LIdentityMap := FIdentityMap;
  FIdentityMap := nil;
  if Assigned(LIdentityMap) then
    LIdentityMap.Free;

  LNewEntityCache := FNewEntityCache;
  FNewEntityCache := nil;
  LNewEntityCache.Free;
  inherited Destroy;
end;

procedure TTProvider.AddLazyOwner(
  const AEntity: TObject; const ALazy: TObject);
var
  LLazies: TObjectList<TObject>;
begin
  if not FLazyOwner.TryGetValue(Pointer(AEntity), LLazies) then
  begin
    LLazies := TObjectList<TObject>.Create(True);
    try
      FLazyOwner.Add(Pointer(AEntity), LLazies);
    except
      LLazies.Free;
      raise;
    end;
  end;
  LLazies.Add(ALazy);
end;

function TTProvider.IdentityMapOwns(const ATableMap: TTTableMap): Boolean;
begin
  result := Assigned(FIdentityMap) and
    (not ATableMap.HasJoins) and
    Assigned(ATableMap.PrimaryKey);
end;

procedure TTProvider.DisposedEntity(const AEntity: TObject);
var
  LPair: TPair<Pointer, TObjectList<TObject>>;
begin
  if Assigned(FNewEntityCache) then
    FNewEntityCache.Disposed(AEntity);

  if Assigned(FLazyOwner) then
  begin
    LPair := FLazyOwner.ExtractPair(Pointer(AEntity));
    if Assigned(LPair.Value) then
      LPair.Value.Free;
  end;
end;

procedure TTProvider.CheckRawFilter(const AFilter: TTFilter);
begin
  if (not AFilter.Where.IsEmpty) or (not AFilter.Paging.IsEmpty) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SRawFilterOnlyParameters));
end;

function TTProvider.CreateDataset(const ASQL: String): TDataset;
begin
  result := FConnection.CreateDataSet(ASQL, TTFilter.Empty);
end;

function TTProvider.CreateDataset(
  const ASQL: String; const AFilter: TTFilter): TDataset;
begin
  CheckRawFilter(AFilter);
  result := FConnection.CreateDataSet(ASQL, AFilter);
end;

function TTProvider.GetLazyOwnerCount: Integer;
begin
  result := 0;
  if Assigned(FLazyOwner) then
    result := FLazyOwner.Count;
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

function TTProvider.LoadAndCheckTableMap<T>: TTTableMap;
begin
  result := TTMapper.Instance.Load<T>();
  if not Assigned(result.PrimaryKey) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));
  if result.SequenceName.IsEmpty then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedSequence));
end;

function TTProvider.CreateEntity<T>(const AInLoading: Boolean): T;
var
  LTableMap: TTTableMap;
  LRttiEntity: TTRttiEntity<T>;
  LPrimaryKey: TTPrimaryKey;
begin
  FInLoading := AInLoading;
  try
    LTableMap := LoadAndCheckTableMap<T>();
    LRttiEntity := TTRttiEntity<T>.Create;
    try
      result := LRttiEntity.CreateEntity(FContext);
      try
        LPrimaryKey := 0;
        if not FInLoading then
          LPrimaryKey := SetPrimaryKey<T>(LTableMap, result);
        MapEntity(LTableMap, nil, result);
        if not (FInLoading) and Assigned(FIdentityMap) and
          (not LTableMap.HasJoins) then
          FIdentityMap.AddEntity<T>(LPrimaryKey, result);
      except
        DisposedEntity(result);
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
  const ATableMap: TTTAbleMap;
  const AReader: TTReader;
  const ARttiEntity: TTRttiEntity<T>): T;
var
  LPrimaryKey: TTPrimaryKey;
begin
  LPrimaryKey := GetPrimaryKey(ATableMap, AReader);
  result := nil;
  if Assigned(FIdentityMap) and (not ATableMap.HasJoins) then
    result := FIdentityMap.GetEntity<T>(LPrimaryKey);

  if not Assigned(result) then
  begin
    result := ARttiEntity.CreateEntity(FContext);
    try
      if Assigned(FIdentityMap) and (not ATableMap.HasJoins) then
        FIdentityMap.AddEntity<T>(LPrimaryKey, result);
    except
      DisposedEntity(result);
      result.Free;
      raise;
    end;
  end;

  try
    MapEntity(ATableMap, AReader, result);
  except
    if not (Assigned(FIdentityMap) and (not ATableMap.HasJoins)) then
    begin
      DisposedEntity(result);
      result.Free;
    end;
    raise;
  end;
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

      for LDetailColumnMap in LTableMap.DetailColumns do
        LDetailColumnMap.Member.CloneLazyID(result, AEntity);
    except
      DisposedEntity(result);
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
      LColumn := AReader.ColumnByName(LColumnMap.LookupName);
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
      AddLazyOwner(AEntity, LResult)
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
        LColumnMap.LookupName,
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
  for LColumnMap in ATableMap.DetailColumns do
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
    LFilter := TTFilter.Create(GetWhere(LTableMap, AColumnName, AID));
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
          DisposedEntity(LObject);
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
  LColumn := AReader.ColumnByName(ATablemap.PrimaryKey.LookupName);
  LResult := LColumn.Value;
  if not LResult.IsType<TTPrimaryKey>() then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotValidPrimaryKeyType));
  result := LResult.AsType<TTPrimaryKey>();
end;

function TTProvider.FindColumnByName(
  const ATablemap: TTTableMap;
  const AColumnName: String): TTColumnMap;
var
  LColumnMap: TTColumnMap;
begin
  result := nil;
  for LColumnMap in ATablemap.Columns do
    if TTIdentifier.Same(LColumnMap.Name, AColumnName) then
    begin
      result := LColumnMap;
      Break;
    end;
end;

function TTProvider.GetWhere(
  const ATablemap: TTTableMap;
  const AColumnName: String;
  const AID: TTPrimaryKey): String;
var
  LColumnMap: TTColumnMap;
  LReference: String;
begin
  LColumnMap := FindColumnByName(ATablemap, AColumnName);
  if Assigned(LColumnMap) then
    LReference := LColumnMap.SqlReference
  else if ATablemap.HasJoins then
    LReference := Format('%s.%s', [ATablemap.Name, AColumnName])
  else
    LReference := AColumnName;

  result := Format('%s = %s', [
    FConnection.GetDatabaseObjectName(LReference),
    TTPrimaryKeyHelper.SqlValue(AID)]);
end;

function TTProvider.GetWhere(
  const ATablemap: TTTableMap; const AID: TTPrimaryKey): String;
begin
  if not Assigned(ATablemap.PrimaryKey) then
    raise ETException.Create(
      TTLanguage.Instance.Translate(SNotDefinedPrimaryKey));

  result := Format('%s = %s', [
    FConnection.GetDatabaseObjectName(ATablemap.PrimaryKey.SqlReference),
    TTPrimaryKeyHelper.SqlValue(AID)]);
end;

function TTProvider.SelectCount<T>(const AFilter: TTFilter): Int64;
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
  LRttiEntity: TTRttiEntity<T>;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, AFilter);
  try
    LRttiEntity := TTRttiEntity<T>.Create;
    try
      AResult.Clear;
      while not LReader.Eof do
      begin
        AResult.Add(
          InternalCreateEntity<T>(LTableMap, LReader, LRttiEntity));
        LReader.Next;
      end;
    finally
      LRttiEntity.Free;
    end;
  finally
    LReader.Free;
  end;
end;

function TTProvider.Get<T>(
  const AID: TTPrimaryKey; const AIncludeDeleted: Boolean): T;
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LFilter: TTFilter;
  LReader: TTReader;
  LRttiEntity: TTRttiEntity<T>;
begin
  result := default(T);
  LTableMap := TTMapper.Instance.Load<T>();
  LTableMetadata := FMetadata.Load<T>();
  LFilter := TTFilter.Create(GetWhere(LTablemap, AID));
  LFilter.IncludeDeleted := AIncludeDeleted;
  LReader := FConnection.CreateReader(LTableMap, LTableMetadata, LFilter);
  try
    if not LReader.IsEmpty then
    begin
      LRttiEntity := TTRttiEntity<T>.Create;
      try
        result := InternalCreateEntity<T>(LTableMap, LReader, LRttiEntity);
      finally
        LRttiEntity.Free;
      end;
    end;
  finally
    LReader.Free;
  end;
end;

function TTProvider.TryRefresh<T>(const AEntity: T): Boolean;
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
    result := not LReader.IsEmpty;
    if result then
      MapEntity(LTableMap, LReader, AEntity);
  finally
    LReader.Free;
  end;
end;

procedure TTProvider.Refresh<T>(const AEntity: T);
begin
  if not TryRefresh<T>(AEntity) then
    raise ETConcurrentUpdateException.Create(
      TTLanguage.Instance.Translate(SRecordChanged));
end;

procedure TTProvider.RawSelect<T>(
  const ASQL: String; const AResult: TTList<T>);
begin
  RawSelect<T>(ASQL, TTFilter.Empty, AResult);
end;

procedure TTProvider.RawSelect<T>(
  const ASQL: String;
  const AFilter: TTFilter;
  const AResult: TTList<T>);
var
  LTableMap: TTTableMap;
  LDataSet: TDataSet;
  LReader: TTReader;
  LRttiEntity: TTRttiEntity<T>;
  LEntity: T;
begin
  CheckRawFilter(AFilter);
  LTableMap := TTMapper.Instance.Load<T>();
  LDataSet := FConnection.CreateDataSet(ASQL, AFilter);
  LReader := TTRawReader.Create(LTableMap, LDataSet);
  try
    AResult.Clear;
    LRttiEntity := TTRttiEntity<T>.Create;
    try
      while not LReader.Eof do
      begin
        LEntity := LRttiEntity.CreateEntity(FContext);
        try
          MapEntity(LTableMap, LReader, LEntity);
          AResult.Add(LEntity);
        except
          DisposedEntity(LEntity);
          LEntity.Free;
          raise;
        end;
        LReader.Next;
      end;
    finally
      LRttiEntity.Free;
    end;
  finally
    LReader.Free;
  end;
end;

{ TTNewEntityCache }

constructor TTNewEntityCache.Create;
begin
  inherited Create;
  FCache := TTHashList<Pointer>.Create;
  FTransactionCache := nil;
end;

destructor TTNewEntityCache.Destroy;
begin
  if Assigned(FTransactionCache) then
    FTransactionCache.Free;
  FCache.Free;
  inherited Destroy;
end;

procedure TTNewEntityCache.ClearTransaction;
begin
  if Assigned(FTransactionCache) then
    FTransactionCache.Free;
  FTransactionCache := nil;
end;

procedure TTNewEntityCache.TransactionStarted;
begin
  ClearTransaction;
  FTransactionCache := TTHashList<Pointer>.Create;
end;

procedure TTNewEntityCache.TransactionCommitted;
begin
  ClearTransaction;
end;

procedure TTNewEntityCache.TransactionRolledback;
var
  LEntity: Pointer;
begin
  if Assigned(FTransactionCache) then
    for LEntity in FTransactionCache do
      FCache.Add(LEntity);
  ClearTransaction;
end;

procedure TTNewEntityCache.Add(const AEntity: TObject);
begin
  FCache.Add(Pointer(AEntity));
end;

function TTNewEntityCache.Contains(const AEntity: TObject): Boolean;
begin
  result := FCache.Contains(Pointer(AEntity));
end;

procedure TTNewEntityCache.Remove(const AEntity: TObject);
begin
  if Assigned(FTransactionCache) then
    FTransactionCache.Add(Pointer(AEntity));
  FCache.Remove(Pointer(AEntity));
end;

procedure TTNewEntityCache.Disposed(const AEntity: TObject);
begin
  FCache.Remove(Pointer(AEntity));
  if Assigned(FTransactionCache) then
    FTransactionCache.Remove(Pointer(AEntity));
end;

end.
