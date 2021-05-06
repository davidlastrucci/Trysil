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
  System.Generics.Collections,

  Trysil.Types,
  Trysil.Filter,
  Trysil.Rtti,
  Trysil.Context,
  Trysil.Mapping,
  Trysil.Generics.Collections;

type

{ TTAbstractLazy<T> }

  TTAbstractLazy<T: class, constructor> = class abstract
  strict private
    procedure SetID(const AID: TTPrimaryKey);
  strict protected
    FContext: TTContext;
    FMapper: TTMapper;
    FID: TTPrimaryKey;
    FColumnName: String;

    procedure NotifyChangedID; virtual; abstract;
  public
    constructor Create(
      const AContext: TTContext;
      const AMapper: TTMapper;
      const AColumnName: String); virtual;

    property ID: TTPrimaryKey read FID write SetID;
  end;

{ TTLazy<T> }

  TTLazy<T: class, constructor> = class(TTAbstractLazy<T>)
  strict private
    FEntity: T;

    function GetEntity: T;
    procedure SetEntity(const AEntity: T);
  strict protected
    procedure NotifyChangedID; override;
  public
    constructor Create(
      const AContext: TTContext;
      const AMapper: TTMapper;
      const AColumnName: String); override;

    property Entity: T read GetEntity write SetEntity;
  end;

{ TTLazyList<T> }

  TTLazyList<T: class, constructor> = class(TTAbstractLazy<T>)
  strict private
    FList: TTList<T>;

    function GetList: TTList<T>;
  strict protected
    procedure NotifyChangedID; override;
  public
    constructor Create(
      const AContext: TTContext;
      const AMapper: TTMapper;
      const AColumnName: String); override;
    destructor Destroy; override;

    property List: TTList<T> read GetList;
  end;

implementation

{ TTAbstractLazy<T> }

constructor TTAbstractLazy<T>.Create(
  const AContext: TTContext;
  const AMapper: TTMapper;
  const AColumnName: String);
begin
  inherited Create;
  FContext := AContext;
  FMapper := AMapper;
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
  const AContext: TTContext;
  const AMapper: TTMapper;
  const AColumnName: String);
begin
  inherited Create(AContext, AMapper, AColumnName);
  FEntity := nil;
end;

procedure TTLazy<T>.NotifyChangedID;
begin
  FEntity := nil;
end;

function TTLazy<T>.GetEntity: T;
begin
  if not Assigned(FEntity) then
    FEntity := FContext.Get<T>(FID);
  result := FEntity;
end;

procedure TTLazy<T>.SetEntity(const AEntity: T);
var
  LTableMap: TTTableMap;
  LValue: TTValue;
begin
  if FEntity <> AEntity then
  begin
    FEntity := AEntity;
    LTableMap := FMapper.Load<T>();
    if Assigned(LTableMap.PrimaryKey) then
    begin
      LValue := LTableMap.PrimaryKey.Member.GetValue(FEntity);
      FID := LValue.AsType<TTPrimaryKey>();
    end;
  end;
end;

{ TTLazyList<T> }

constructor TTLazyList<T>.Create(
  const AContext: TTContext;
  const AMapper: TTMapper;
  const AColumnName: String);
begin
  inherited Create(AContext, AMapper, AColumnName);
  FList := nil;
end;

destructor TTLazyList<T>.Destroy;
begin
  if Assigned(FList) then
    FList.Free;
  inherited Destroy;
end;

procedure TTLazyList<T>.NotifyChangedID;
begin
  if Assigned(FList) then
  begin
    FList.Free;
    FList := nil;
  end;
end;

function TTLazyList<T>.GetList: TTList<T>;
var
  LFilter: TTFilter;
begin
  if not Assigned(FList) then
  begin
    FList := TTList<T>.Create;
    try
      LFilter := TTFilter.Create(
        Format('%s = %s', [FColumnName, TTPrimaryKeyHelper.SqlValue(FID)]));
      FContext.Select<T>(FList, LFilter);
    except
      FList.Free;
      FList := nil;
      raise;
    end;
  end;
  result := FList;
end;

end.
