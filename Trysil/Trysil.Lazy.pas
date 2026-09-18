(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Lazy;

interface

uses
  System.SysUtils,
  System.Classes,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Filter,
  Trysil.Metadata,
  Trysil.Rtti,
  Trysil.Context,
  Trysil.Mapping,
  Trysil.Generics.Collections;

type

{ TTAbstractLazy<T> }

  TTAbstractLazy<T: class> = class abstract
  strict private
    procedure SetID(const AID: TTPrimaryKey);
  strict protected
    FContext: TTContext;
    FID: TTPrimaryKey;
    FColumnName: String;

    procedure NotifyChangedID; virtual; abstract;
  public
    constructor Create(
      const AContext: TTContext; const AColumnName: String); virtual;

    property ID: TTPrimaryKey read FID write SetID;
  end;

{ TTLazy<T> }

  TTLazy<T: class> = class(TTAbstractLazy<T>)
  strict private
    FEntity: T;

    function EntityID(
      const ATableMap: TTTableMap; const AEntity: T): TTPrimaryKey;
    function AdoptOrClone(
      const ATableMap: TTTableMap; const AEntity: T): T;
    function GetIsLoaded: Boolean;
    function GetEntity: T;
    procedure SetEntity(const AEntity: T);
  strict protected
    procedure NotifyChangedID; override;
  public
    constructor Create(
      const AContext: TTContext; const AColumnName: String); override;
    destructor Destroy; override;

    property IsLoaded: Boolean read GetIsLoaded;
    property Entity: T read GetEntity write SetEntity;
  end;

{ TTLazyList<T> }

{$RTTI EXPLICIT
  METHODS([vcProtected, vcPrivate])}
  TTLazyList<T: class> = class(TTAbstractLazy<T>)
  strict private
    FList: TTObjectList<T>;

    function InternalCreateList: TTObjectList<T>;

    procedure PrepareList;
    function SqlReference: String;
    function GetList: TTList<T>;
  strict protected
    function AddEntity: T;

    procedure NotifyChangedID; override;
  public
    constructor Create(
      const AContext: TTContext; const AColumnName: String); override;
    destructor Destroy; override;

    property List: TTList<T> read GetList;
  end;

implementation

{ TTAbstractLazy<T> }

constructor TTAbstractLazy<T>.Create(
  const AContext: TTContext; const AColumnName: String);
begin
  inherited Create;
  FContext := AContext;
  FColumnName := AColumnName;
end;

procedure TTAbstractLazy<T>.SetID(const AID: TTPrimaryKey);
begin
  if FID <> AID then
  begin
    FID := AID;
    NotifyChangedID;
  end;
end;

{ TTLazy<T> }

constructor TTLazy<T>.Create(
  const AContext: TTContext; const AColumnName: String);
begin
  inherited Create(AContext, AColumnName);
  FEntity := nil;
end;

procedure TTLazy<T>.NotifyChangedID;
var
  LOldEntity: T;
begin
  LOldEntity := FEntity;
  FEntity := nil;
  if Assigned(LOldEntity) then
    FContext.FreeEntity<T>(LOldEntity);
end;

destructor TTLazy<T>.Destroy;
begin
  if Assigned(FEntity) then
    FContext.FreeEntity<T>(FEntity);
  inherited Destroy;
end;

function TTLazy<T>.GetIsLoaded: Boolean;
begin
  result := Assigned(FEntity);
end;

function TTLazy<T>.GetEntity: T;
begin
  if (not Assigned(FEntity)) and (FID <> 0) then
    FEntity := FContext.Get<T>(FID, True);
  result := FEntity;
end;

function TTLazy<T>.EntityID(
  const ATableMap: TTTableMap; const AEntity: T): TTPrimaryKey;
var
  LValue: TTValue;
begin
  result := FID;
  if not Assigned(AEntity) then
    result := 0
  else if Assigned(ATableMap.PrimaryKey) then
  begin
    LValue := ATableMap.PrimaryKey.Member.GetValue(AEntity);
    result := LValue.AsType<TTPrimaryKey>();
  end;
end;

function TTLazy<T>.AdoptOrClone(
  const ATableMap: TTTableMap; const AEntity: T): T;
begin
  result := AEntity;
  if Assigned(AEntity) and (not FContext.IdentityMapOwns(ATableMap)) then
    result := FContext.CloneEntity<T>(AEntity);
end;

procedure TTLazy<T>.SetEntity(const AEntity: T);
var
  LTableMap: TTTableMap;
  LID: TTPrimaryKey;
  LOldEntity: T;
begin
  if (FEntity <> AEntity) or (not Assigned(AEntity)) then
  begin
    LTableMap := TTMapper.Instance.Load<T>();
    LID := EntityID(LTableMap, AEntity);
    LOldEntity := FEntity;
    FEntity := AdoptOrClone(LTableMap, AEntity);
    FID := LID;

    if Assigned(LOldEntity) then
      FContext.FreeEntity<T>(LOldEntity);
  end;
end;

{ TTLazyList<T> }

constructor TTLazyList<T>.Create(
  const AContext: TTContext; const AColumnName: String);
begin
  inherited Create(AContext, AColumnName);
  FList := InternalCreateList;
end;

destructor TTLazyList<T>.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TTLazyList<T>.InternalCreateList: TTObjectList<T>;
var
  LList: TTList<T>;
  LClassName: String;
begin
  LList := FContext.CreateEntityList<T>();
  if LList is TTObjectList<T> then
    result := TTObjectList<T>(LList)
  else
  begin
    LClassName := LList.ClassName;
    LList.Free;
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidEntityList), [LClassName]);
  end;
end;

procedure TTLazyList<T>.PrepareList;
begin
  FList.Clear;
  FList.IsValid := True;
end;

function TTLazyList<T>.AddEntity: T;
begin
  result := FContext.CreateEntity<T>();
  try
    FList.Add(result);
  except
    FContext.FreeEntity<T>(result);
    raise;
  end;

  FList.IsValid := True;
end;

procedure TTLazyList<T>.NotifyChangedID;
begin
  FList.IsValid := False;
end;

function TTLazyList<T>.SqlReference: String;
var
  LTableMap: TTTableMap;
  LColumnMetadata: TTColumnMetadata;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  if LTableMap.HasJoins then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SDetailColumnOnJoinEntity), [
        FColumnName,
        LTableMap.Name]);

  LColumnMetadata := FContext.GetMetadata<T>().Columns.Find(FColumnName);
  if Assigned(LColumnMetadata) then
    result := LColumnMetadata.SqlReference
  else
    result := FContext.GetDatabaseObjectName(FColumnName);
end;

function TTLazyList<T>.GetList: TTList<T>;
var
  LFilter: TTFilter;
begin
  if not FList.IsValid then
  begin
    LFilter := TTFilter.Create(
      Format('%s = %s', [SqlReference, TTPrimaryKeyHelper.SqlValue(FID)]));
    FContext.Select<T>(FList, LFilter);
    FList.IsValid := True;
  end;

  result := FList;
end;

end.
