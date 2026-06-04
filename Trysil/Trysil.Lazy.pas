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

  Trysil.Types,
  Trysil.Filter,
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

    function GetEntity: T;
    procedure SetEntity(const AEntity: T);
  strict protected
    procedure NotifyChangedID; override;
  public
    constructor Create(
      const AContext: TTContext; const AColumnName: String); override;
    destructor Destroy; override;

    property Entity: T read GetEntity write SetEntity;
  end;

{ TTLazyList<T> }

{$RTTI EXPLICIT
  METHODS([vcProtected, vcPrivate])}
  TTLazyList<T: class> = class(TTAbstractLazy<T>)
  strict private
    FList: TTObjectLazyList<T>;

    procedure PrepareList;
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
begin
  if (not FContext.UseIdentityMap) and Assigned(FEntity) then
    FEntity.Free;
  FEntity := nil;
end;

destructor TTLazy<T>.Destroy;
begin
  if (not FContext.UseIdentityMap) and Assigned(FEntity) then
    FEntity.Free;
  inherited Destroy;
end;

function TTLazy<T>.GetEntity: T;
begin
  if not Assigned(FEntity) then
    FEntity := FContext.Get<T>(FID, True);
  result := FEntity;
end;

procedure TTLazy<T>.SetEntity(const AEntity: T);
var
  LTableMap: TTTableMap;
  LValue: TTValue;
begin
  if FEntity <> AEntity then
  begin
    if (not FContext.UseIdentityMap) and Assigned(FEntity) then
      FEntity.Free;

    FEntity := AEntity;
    LTableMap := TTMapper.Instance.Load<T>();
    if Assigned(LTableMap.PrimaryKey) then
    begin
      LValue := LTableMap.PrimaryKey.Member.GetValue(FEntity);
      FID := LValue.AsType<TTPrimaryKey>();
    end;
  end;
end;

{ TTLazyList<T> }

constructor TTLazyList<T>.Create(
  const AContext: TTContext; const AColumnName: String);
begin
  inherited Create(AContext, AColumnName);
  FList := TTObjectLazyList<T>.Create(not FContext.UseIdentityMap);
end;

destructor TTLazyList<T>.Destroy;
begin
  FList.Free;
  inherited Destroy;
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
    result.Free;
    raise;
  end;

  FList.IsValid := True;
end;

procedure TTLazyList<T>.NotifyChangedID;
begin
  FList.IsValid := False;
end;

function TTLazyList<T>.GetList: TTList<T>;
var
  LFilter: TTFilter;
begin
  if not FList.IsValid then
  begin
    LFilter := TTFilter.Create(
      Format('%s = %s', [FColumnName, TTPrimaryKeyHelper.SqlValue(FID)]));
    FContext.Select<T>(FList, LFilter);
    FList.IsValid := True;
  end;

  result := FList;
end;

end.
