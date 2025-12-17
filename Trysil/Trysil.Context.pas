(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Context;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.TypInfo,
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Provider,
  Trysil.Resolver,
  Trysil.Session,
  Trysil.Transaction;

type

{ TTApplyAllMethod<T> }

  TTApplyAllMethod<T: class> = reference to procedure(const AEntity: T);

{ TTNewEntityCache }

  TTNewEntityCache = class
  strict private
    FProvider: TTProvider;

    FCache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
    FTransactionCache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;

    procedure ClearTransaction;
    procedure InternalAdd(
      const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
      const ATypeInfo: PTypeInfo;
      const AID: TTPrimaryKey);
    function InternalContains(
      const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
      const ATypeInfo: PTypeInfo;
      const AID: TTPrimaryKey): Boolean;
    procedure InternalRemove(
      const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
      const ATypeInfo: PTypeInfo;
      const AID: TTPrimaryKey);
  public
    constructor Create(const AProvider: TTProvider);
    destructor Destroy; override;

    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;

    procedure Add<T: class>(const AEntity: T);
    function Contains<T: class>(const AEntity: T): Boolean;
    procedure Remove<T: class>(const AEntity: T);
  end;

{ TTContext }

  TTContext = class(TTTransactionObserver)
  strict private
    FNewEntityCache: TTNewEntityCache;

    procedure ApplyAll<T: class>(
      const AList: TTList<T>; const AApplyAllMethod: TTApplyAllMethod<T>);

    function GetInTransaction: Boolean;
    function GetSupportTransaction: Boolean;
    function GetUseIdentityMap: Boolean;
  strict protected
    FReadConnection: TTConnection;
    FWriteConnection: TTConnection;
    FMetadata: TTMetadata;
    FProvider: TTProvider;
    FResolver: TTResolver;

    procedure TransactionStarted; override;
    procedure TransactionCommitted; override;
    procedure TransactionRolledback; override;

    function CreateResolver: TTResolver; virtual;
    function InLoading: Boolean; virtual;
  public
    constructor Create(const AConnection: TTConnection); overload; virtual;
    constructor Create(
      const AConnection: TTConnection;
      const AUseIdentityMap: Boolean); overload; virtual;
    constructor Create(
      const AReadConnection: TTConnection;
      const AWriteConnection: TTConnection); overload; virtual;
    constructor Create(
      const AReadConnection: TTConnection;
      const AWriteConnection: TTConnection;
      const AUseIdentityMap: Boolean); overload; virtual;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function CreateDataset(const ASQL: String): TDataset;

    function CreateEntity<T: class>(): T; overload;
    function CloneEntity<T: class>(const AEntity: T): T;

    function CreateTransaction(): TTTransaction;
    function CreateSession<T: class>(const AList: TList<T>): TTSession<T>;

    function GetMetadata<T: class>(): TTTableMetadata;

    function SelectCount<T: class>(const AFilter: TTFilter): Integer;
    procedure SelectAll<T: class>(const AResult: TTList<T>);
    procedure Select<T: class>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    function Get<T: class>(const AID: TTPrimaryKey): T;
    function TryGet<T: class>(const AID: TTPrimaryKey; out AEntity: T): Boolean;

    procedure Refresh<T: class>(const AEntity: T);
    function OldEntity<T: class>(const AEntity: T): T;

    procedure Validate<T: class>(const AEntity: T);

    procedure Save<T: class>(const AEntity: T);
    procedure SaveAll<T: class>(const AList: TTList<T>);

    procedure Insert<T: class>(const AEntity: T);
    procedure InsertAll<T: class>(const AList: TTList<T>);

    procedure Update<T: class>(const AEntity: T);
    procedure UpdateAll<T: class>(const AList: TTList<T>);

    procedure Delete<T: class>(const AEntity: T);
    procedure DeleteAll<T: class>(const AList: TTList<T>);

    property InTransaction: Boolean read GetInTransaction;
    property SupportTransaction: Boolean read GetSupportTransaction;
    property UseIdentityMap: Boolean read GetUseIdentityMap;
  end;

implementation

{ TTNewEntityCache }

constructor TTNewEntityCache.Create(const AProvider: TTProvider);
begin
  inherited Create;
  FProvider := AProvider;

  FCache := TObjectDictionary<
    PTypeInfo, THashSet<TTPrimaryKey>>.Create([doOwnsValues]);
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
  begin
    FTransactionCache.Free;
    FTransactionCache := nil;
  end;
end;

procedure TTNewEntityCache.StartTransaction;
begin
  if not Assigned(FTransactionCache) then
    FTransactionCache := TObjectDictionary<
      PTypeInfo, THashSet<TTPrimaryKey>>.Create([doOwnsValues]);
end;

procedure TTNewEntityCache.CommitTransaction;
begin
  ClearTransaction;
end;

procedure TTNewEntityCache.RollbackTransaction;
var
  LPair: TPair<PTypeInfo, THashSet<TTPrimaryKey>>;
  LID: TTPrimaryKey;
begin
  if Assigned(FTransactionCache) then
    for LPair in FTransactionCache do
      for LID in LPair.Value do
        InternalAdd(FCache, LPair.Key, LID);
  ClearTransaction;
end;

procedure TTNewEntityCache.InternalAdd(
  const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
  const ATypeInfo: PTypeInfo;
  const AID: TTPrimaryKey);
var
  LHashSet: THashSet<TTPrimaryKey>;
begin
  if not ACache.TryGetValue(ATypeInfo, LHashSet) then
  begin
    LHashSet := THashSet<TTPrimaryKey>.Create;
    try
      ACache.Add(ATypeInfo, LHashSet);
    except
      LHashSet.Free;
      raise;
    end;
  end;

  if not LHashSet.Contains(AID) then
    LHashSet.Add(AID);
end;

function TTNewEntityCache.InternalContains(
  const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
  const ATypeInfo: PTypeInfo;
  const AID: TTPrimaryKey): Boolean;
var
  LHashSet: THashSet<TTPrimaryKey>;
begin
  result := ACache.TryGetValue(ATypeInfo, LHashSet);
  if result then
    result := LHashSet.Contains(AID);
end;

procedure TTNewEntityCache.InternalRemove(
  const ACache: TObjectDictionary<PTypeInfo, THashSet<TTPrimaryKey>>;
  const ATypeInfo: PTypeInfo;
  const AID: TTPrimaryKey);
var
  LHashSet: THashSet<TTPrimaryKey>;
begin
  if ACache.TryGetValue(ATypeInfo, LHashSet) then
    LHashSet.Remove(AID);
end;

procedure TTNewEntityCache.Add<T>(const AEntity: T);
begin
  InternalAdd(FCache, TypeInfo(T), FProvider.GetID<T>(AEntity));
end;

function TTNewEntityCache.Contains<T>(const AEntity: T): Boolean;
var
  LTypeInfo: PTypeInfo;
  LID: TTPrimaryKey;
begin
  LTypeInfo := TypeInfo(T);
  LID := FProvider.GetID<T>(AEntity);
  result := InternalContains(FCache, LTypeInfo, LID);
  if (not result) and Assigned(FTransactionCache) then
    result := InternalContains(FTransactionCache, LTypeInfo, LID);
end;

procedure TTNewEntityCache.Remove<T>(const AEntity: T);
var
  LTypeInfo: PTypeInfo;
  LID: TTPrimaryKey;
begin
  LTypeInfo := TypeInfo(T);
  LID := FProvider.GetID<T>(AEntity);
  if Assigned(FTransactionCache) then
    InternalAdd(FTransactionCache, LTypeInfo, LID);
  InternalRemove(FCache, LTypeInfo, LID);
end;

{ TTContext }

constructor TTContext.Create(const AConnection: TTConnection);
begin
  Create(AConnection, AConnection, True);
end;

constructor TTContext.Create(
  const AConnection: TTConnection; const AUseIdentityMap: Boolean);
begin
  Create(AConnection, AConnection, AUseIdentityMap);
end;

constructor TTContext.Create(
  const AReadConnection: TTConnection;
  const AWriteConnection: TTConnection);
begin
  Create(AReadConnection, AWriteConnection, True);
end;

constructor TTContext.Create(
  const AReadConnection: TTConnection;
  const AWriteConnection: TTConnection;
  const AUseIdentityMap: Boolean);
begin
  inherited Create;
  FReadConnection := AReadConnection;
  FWriteConnection := AWriteConnection;

  FMetadata := TTMetadata.Create(FReadConnection);

  FProvider := TTProvider.Create(
    FReadConnection, Self, FMetadata, AUseIdentityMap);
  FResolver := CreateResolver;

  FNewEntityCache := TTNewEntityCache.Create(FProvider);
end;

destructor TTContext.Destroy;
begin
  FNewEntityCache.Free;
  FResolver.Free;
  FProvider.Free;
  FMetadata.Free;
  inherited Destroy;
end;

procedure TTContext.AfterConstruction;
begin
  inherited AfterConstruction;
  FWriteConnection.TransactionObserver := Self;
end;

procedure TTContext.TransactionStarted;
begin
  FNewEntityCache.StartTransaction;
end;

procedure TTContext.TransactionCommitted;
begin
  FNewEntityCache.CommitTransaction;
end;

procedure TTContext.TransactionRolledback;
begin
  FNewEntityCache.RollbackTransaction;
end;

function TTContext.CreateDataset(const ASQL: String): TDataset;
begin
  result := FProvider.CreateDataset(ASQL);
end;

function TTContext.CreateResolver: TTResolver;
begin
  result := TTResolver.Create(FWriteConnection, Self, FMetadata);
end;

function TTContext.InLoading: Boolean;
begin
  result := False;
end;

function TTContext.GetInTransaction: Boolean;
begin
  result := FWriteConnection.InTransaction;
end;

function TTContext.GetSupportTransaction: Boolean;
begin
  result := FWriteConnection.SupportTransaction;
end;

function TTContext.GetUseIdentityMap: Boolean;
begin
  result := FProvider.UseIdentityMap;
end;

function TTContext.CreateEntity<T>(): T;
begin
  result := FProvider.CreateEntity<T>(InLoading);
  FNewEntityCache.Add<T>(result);
end;

function TTContext.CloneEntity<T>(const AEntity: T): T;
begin
  result := FProvider.CloneEntity<T>(AEntity);
end;

function TTContext.CreateTransaction: TTTransaction;
begin
  if not FWriteConnection.SupportTransaction then
    raise ETException.Create(
      TTLanguage.Instance.Translate(STransactionNotSupported));
  result := TTTransaction.Create(FWriteConnection);
end;

function TTContext.CreateSession<T>(const AList: TList<T>): TTSession<T>;
begin
  result := TTSession<T>.Create(FWriteConnection, FProvider, FResolver, AList);
end;

function TTContext.GetMetadata<T>(): TTTableMetadata;
begin
  result := FProvider.GetMetadata<T>();
end;

function TTContext.SelectCount<T>(const AFilter: TTFilter): Integer;
begin
  result := FProvider.SelectCount<T>(AFilter);
end;

procedure TTContext.SelectAll<T>(const AResult: TTList<T>);
begin
  FProvider.Select<T>(AResult, TTFilter.Empty());
end;

procedure TTContext.Select<T>(
  const AResult: TTList<T>; const AFilter: TTFilter);
begin
  FProvider.Select<T>(AResult, AFilter);
end;

function TTContext.Get<T>(const AID: TTPrimaryKey): T;
begin
  result := FProvider.Get<T>(AID);
end;

function TTContext.TryGet<T>(const AID: TTPrimaryKey; out AEntity: T): Boolean;
begin
  AEntity := Get<T>(AID);
  result := Assigned(AEntity);
end;

procedure TTContext.Refresh<T>(const AEntity: T);
begin
  FProvider.Refresh<T>(AEntity);
end;

function TTContext.OldEntity<T>(const AEntity: T): T;
begin
  result := CloneEntity<T>(AEntity);
  try
    Refresh<T>(result);
  except
    result.Free;
    raise;
  end;
end;

procedure TTContext.Validate<T>(const AEntity: T);
begin
  FResolver.Validate<T>(AEntity);
end;

procedure TTContext.ApplyAll<T>(
  const AList: TTList<T>; const AApplyAllMethod: TTApplyAllMethod<T>);
var
  LTransaction: TTTransaction;
  LEntity: T;
begin
  if Assigned(AApplyAllMethod) then
  begin
    LTransaction := TTTransaction.Create(FWriteConnection);
    try
      try
        for LEntity in AList do
          AApplyAllMethod(LEntity);
      except
        LTransaction.Rollback;
        raise;
      end;
    finally
      LTransaction.Free;
    end;
  end;
end;

procedure TTContext.Save<T>(const AEntity: T);
begin
  if FNewEntityCache.Contains<T>(AEntity) then
    Insert<T>(AEntity)
  else
    Update<T>(AEntity);
end;

procedure TTContext.SaveAll<T>(const AList: TTList<T>);
begin
  ApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Save<T>(AEntity);
    end);
end;

procedure TTContext.Insert<T>(const AEntity: T);
begin
  FResolver.Insert<T>(AEntity);
  FNewEntityCache.Remove<T>(AEntity);
end;

procedure TTContext.InsertAll<T>(const AList: TTList<T>);
begin
  ApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Insert<T>(AEntity);
    end);
end;

procedure TTContext.Update<T>(const AEntity: T);
begin
  FResolver.Update<T>(AEntity);
end;

procedure TTContext.UpdateAll<T>(const AList: TTList<T>);
begin
  ApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Update<T>(AEntity);
    end);
end;

procedure TTContext.Delete<T>(const AEntity: T);
begin
  FResolver.Delete<T>(AEntity);
end;

procedure TTContext.DeleteAll<T>(const AList: TTList<T>);
begin
  ApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Delete<T>(AEntity);
    end);
end;

end.
