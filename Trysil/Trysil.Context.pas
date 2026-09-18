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
  Data.DB,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Provider,
  Trysil.Resolver,
  Trysil.Session,
  Trysil.Transaction;

type

{ TTApplyAllMethod<T> }

  TTApplyAllMethod<T: class> = reference to procedure(const AEntity: T);

{ TTContext }

  TTContext = class
  strict private
    procedure InternalApplyAll<T: class>(
      const AList: TTList<T>; const AApplyAllMethod: TTApplyAllMethod<T>);

    function GetInTransaction: Boolean;
    function GetSupportTransaction: Boolean;
    function GetUseIdentityMap: Boolean;
    function GetLazyOwnerCount: Integer;

    function GetOnGetCurrentUser: TFunc<String>;
    procedure SetOnGetCurrentUser(const AValue: TFunc<String>);

    procedure DisposedEntity(const AEntity: TObject);
  strict protected
    FReadConnection: TTConnection;
    FWriteConnection: TTConnection;
    FMetadata: TTMetadata;
    FProvider: TTProvider;
    FResolver: TTResolver;

    function CreateResolver: TTResolver; virtual;
    function InLoading: Boolean; virtual;
    procedure CheckSave; virtual;
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
    procedure BeforeDestruction; override;

    function CreateDataset(const ASQL: String): TDataset; overload;
    function CreateDataset(
      const ASQL: String; const AFilter: TTFilter): TDataset; overload;

    function CreateEntity<T: class>(): T; overload;
    function CreateEntityList<T: class>(): TTList<T>;
    function CloneEntity<T: class>(const AEntity: T): T;
    procedure FreeEntity<T: class>(const AEntity: T);

    function CreateTransaction(): TTTransaction; overload;
      deprecated 'Use CreateTransaction(TTTransactionMode.CommitOnDestroy)';
    function CreateTransaction(
      const ATransactionMode: TTTransactionMode): TTTransaction; overload;
    procedure RunInTransaction(const AProc: TProc);

    function CreateSession<T: class>(const AList: TList<T>): TTSession<T>;

    function CreateFilterBuilder<T: class>(): TTFilterBuilder<T>;

    function GetMetadata<T: class>(): TTTableMetadata;
    function IdentityMapOwns(const ATableMap: TTTableMap): Boolean;
    procedure FreeClone<T: class>(const AEntity: T);
    function GetDatabaseObjectName(const AName: String): String;

    function SelectCount<T: class>(const AFilter: TTFilter): Int64;
    procedure SelectAll<T: class>(const AResult: TTList<T>);
    procedure Select<T: class>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    procedure RawSelect<T: class>(
      const ASQL: String; const AResult: TTList<T>); overload;
    procedure RawSelect<T: class>(
      const ASQL: String;
      const AFilter: TTFilter;
      const AResult: TTList<T>); overload;

    function Get<T: class>(const AID: TTPrimaryKey): T; overload;
    function Get<T: class>(
      const AID: TTPrimaryKey; const AIncludeDeleted: Boolean): T; overload;
    function TryGet<T: class>(
      const AID: TTPrimaryKey; out AEntity: T): Boolean; overload;
    function TryGet<T: class>(
      const AID: TTPrimaryKey;
      const AIncludeDeleted: Boolean;
      out AEntity: T): Boolean; overload;

    function TryRefresh<T: class>(const AEntity: T): Boolean;
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

    procedure Undelete<T: class>(const AEntity: T);
    procedure UndeleteAll<T: class>(const AList: TTList<T>);

    procedure ApplyAll<T: class>(
      const AInsertList: TTList<T>;
      const AUpdateList: TTList<T>;
      const ADeleteList: TTList<T>);

    property InTransaction: Boolean read GetInTransaction;
    property SupportTransaction: Boolean read GetSupportTransaction;
    property UseIdentityMap: Boolean read GetUseIdentityMap;
    property LazyOwnerCount: Integer read GetLazyOwnerCount;

    property OnGetCurrentUser: TFunc<String>
      read GetOnGetCurrentUser write SetOnGetCurrentUser;
  end;

implementation

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
end;

destructor TTContext.Destroy;
begin
  FProvider.Free;
  FResolver.Free;
  FMetadata.Free;
  inherited Destroy;
end;

procedure TTContext.AfterConstruction;
begin
  inherited AfterConstruction;
  FWriteConnection.AddTransactionObserver(FProvider.NewEntityCache);
end;

procedure TTContext.BeforeDestruction;
begin
  if Assigned(FWriteConnection) then
    FWriteConnection.RemoveTransactionObserver(FProvider.NewEntityCache);
  inherited BeforeDestruction;
end;

function TTContext.CreateDataset(const ASQL: String): TDataset;
begin
  result := FProvider.CreateDataset(ASQL);
end;

function TTContext.CreateDataset(
  const ASQL: String; const AFilter: TTFilter): TDataset;
begin
  result := FProvider.CreateDataset(ASQL, AFilter);
end;

function TTContext.CreateResolver: TTResolver;
begin
  result := TTResolver.Create(FWriteConnection, Self, FMetadata);
end;

function TTContext.InLoading: Boolean;
begin
  result := False;
end;

procedure TTContext.CheckSave;
begin
  // A context that creates the entities it writes can answer the question
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

function TTContext.GetLazyOwnerCount: Integer;
begin
  result := FProvider.LazyOwnerCount;
end;

function TTContext.GetOnGetCurrentUser: TFunc<String>;
begin
  result := FResolver.OnGetCurrentUser;
end;

procedure TTContext.SetOnGetCurrentUser(const AValue: TFunc<String>);
begin
  FResolver.OnGetCurrentUser := AValue;
end;

function TTContext.CreateEntity<T>(): T;
begin
  result := FProvider.CreateEntity<T>(InLoading);
  if not InLoading then
    FProvider.NewEntityCache.Add(result);
end;

function TTContext.IdentityMapOwns(const ATableMap: TTTableMap): Boolean;
begin
  result := FProvider.IdentityMapOwns(ATableMap);
end;

function TTContext.CreateEntityList<T>: TTList<T>;
var
  LResult: TTObjectList<T>;
begin
  LResult := TTObjectList<T>.Create(
    not IdentityMapOwns(TTMapper.Instance.Load<T>()));
  LResult.OnDisposeItem := DisposedEntity;
  result := LResult;
end;

procedure TTContext.DisposedEntity(const AEntity: TObject);
begin
  FResolver.DisposedEntity(AEntity);
  FProvider.DisposedEntity(AEntity);
end;

procedure TTContext.FreeClone<T>(const AEntity: T);
begin
  if Assigned(AEntity) then
  begin
    DisposedEntity(AEntity);
    AEntity.Free;
  end;
end;

function TTContext.CloneEntity<T>(const AEntity: T): T;
begin
  result := FProvider.CloneEntity<T>(AEntity);
end;

procedure TTContext.FreeEntity<T>(const AEntity: T);
begin
  if not IdentityMapOwns(TTMapper.Instance.Load<T>()) then
  begin
    DisposedEntity(AEntity);
    AEntity.Free;
  end;
end;

function TTContext.CreateTransaction: TTTransaction;
begin
  result := CreateTransaction(TTTransactionMode.CommitOnDestroy);
end;

function TTContext.CreateTransaction(
  const ATransactionMode: TTTransactionMode): TTTransaction;
begin
  if not FWriteConnection.SupportTransaction then
    raise ETException.Create(
      TTLanguage.Instance.Translate(STransactionNotSupported));
  result := TTTransaction.Create(
    FWriteConnection, ATransactionMode);
end;

procedure TTContext.RunInTransaction(const AProc: TProc);
begin
  if not FWriteConnection.SupportTransaction then
    raise ETException.Create(
      TTLanguage.Instance.Translate(STransactionNotSupported));

  TTTransaction.Run(FWriteConnection, AProc);
end;

function TTContext.CreateSession<T>(const AList: TList<T>): TTSession<T>;
begin
  result := TTSession<T>.Create(FWriteConnection, FProvider, FResolver, AList);
end;

function TTContext.CreateFilterBuilder<T>: TTFilterBuilder<T>;
begin
  result := TTFilterBuilder<T>.Create(FMetadata);
end;

function TTContext.GetMetadata<T>(): TTTableMetadata;
begin
  result := FProvider.GetMetadata<T>();
end;

function TTContext.GetDatabaseObjectName(const AName: String): String;
begin
  result := FReadConnection.GetDatabaseObjectName(AName);
end;

function TTContext.SelectCount<T>(const AFilter: TTFilter): Int64;
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

procedure TTContext.RawSelect<T>(
  const ASQL: String; const AResult: TTList<T>);
begin
  FProvider.RawSelect<T>(ASQL, AResult);
end;

procedure TTContext.RawSelect<T>(
  const ASQL: String;
  const AFilter: TTFilter;
  const AResult: TTList<T>);
begin
  FProvider.RawSelect<T>(ASQL, AFilter, AResult);
end;

function TTContext.Get<T>(const AID: TTPrimaryKey): T;
begin
  result := Get<T>(AID, False);
end;

function TTContext.Get<T>(
  const AID: TTPrimaryKey; const AIncludeDeleted: Boolean): T;
begin
  result := FProvider.Get<T>(AID, AIncludeDeleted);
end;

function TTContext.TryGet<T>(const AID: TTPrimaryKey; out AEntity: T): Boolean;
begin
  result := TryGet<T>(AID, False, AEntity);
end;

function TTContext.TryGet<T>(
  const AID: TTPrimaryKey;
  const AIncludeDeleted: Boolean;
  out AEntity: T): Boolean;
begin
  AEntity := Get<T>(AID, AIncludeDeleted);
  result := Assigned(AEntity);
end;

function TTContext.TryRefresh<T>(const AEntity: T): Boolean;
begin
  result := FProvider.TryRefresh<T>(AEntity);
end;

procedure TTContext.Refresh<T>(const AEntity: T);
begin
  FProvider.Refresh<T>(AEntity);
end;

function TTContext.OldEntity<T>(const AEntity: T): T;
begin
  result := CloneEntity<T>(AEntity);
  try
    if not TryRefresh<T>(result) then
    begin
      DisposedEntity(result);
      FreeAndNil(result);
    end;
  except
    if Assigned(result) then
    begin
      DisposedEntity(result);
      result.Free;
      result := default(T);
    end;
    raise;
  end;
end;

procedure TTContext.Validate<T>(const AEntity: T);
begin
  FResolver.Validate<T>(AEntity);
end;

procedure TTContext.InternalApplyAll<T>(
  const AList: TTList<T>; const AApplyAllMethod: TTApplyAllMethod<T>);
begin
  if Assigned(AApplyAllMethod) then
    RunInTransaction(
      procedure()
      var
        LEntity: T;
      begin
        for LEntity in AList do
          AApplyAllMethod(LEntity);
      end);
end;

procedure TTContext.Save<T>(const AEntity: T);
begin
  CheckSave;
  if FProvider.NewEntityCache.Contains(AEntity) then
    Insert<T>(AEntity)
  else
    Update<T>(AEntity);
end;

procedure TTContext.SaveAll<T>(const AList: TTList<T>);
begin
  InternalApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Save<T>(AEntity);
    end);
end;

procedure TTContext.Insert<T>(const AEntity: T);
begin
  FResolver.Insert<T>(AEntity);
  FProvider.NewEntityCache.Remove(AEntity);
end;

procedure TTContext.InsertAll<T>(const AList: TTList<T>);
begin
  InternalApplyAll<T>(
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
  InternalApplyAll<T>(
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
  InternalApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Delete<T>(AEntity);
    end);
end;

procedure TTContext.Undelete<T>(const AEntity: T);
begin
  FResolver.Undelete<T>(AEntity);
end;

procedure TTContext.UndeleteAll<T>(const AList: TTList<T>);
begin
  InternalApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      Undelete<T>(AEntity);
    end);
end;

procedure TTContext.ApplyAll<T>(
  const AInsertList: TTList<T>;
  const AUpdateList: TTList<T>;
  const ADeleteList: TTList<T>);
begin
  RunInTransaction(
    procedure()
    begin
      InsertAll<T>(AInsertList);
      UpdateAll<T>(AUpdateList);
      DeleteAll<T>(ADeleteList);
    end);
end;

end.
