(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Session;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Provider,
  Trysil.Resolver;

type

{ TTClonedEntities<T> }

  TTClonedEntities<T: class> = class
  strict private
    FProvider: TTProvider;
    FEntities: TObjectDictionary<T, T>;
  private // internal
    function CloneEntity(const AEntity: T): T;
    procedure FreeClone(const AClone: T);
    function GetOriginalEntity(const AClone: T): T;
  public
    constructor Create(const AProvider: TTProvider);
    destructor Destroy; override;
  end;

{ TTSessionState }

  TTSessionState = (Original, Inserted, Updated, Deleted);

{ TTSession<T> }

  TTSession<T: class> = class
  strict private
    FConnection: TTConnection;
    FProvider: TTProvider;
    FResolver: TTResolver;
    FOriginalEntities: TList<T>;

    FApplied: Boolean;
    FCloned: TTClonedEntities<T>;
    FClonedEntities: TList<T>;
    FAllEntities: TList<T>;
    FEntities: TTList<T>;
    FEntityStates: TDictionary<T, TTSessionState>;

    procedure CloneEntities;
    function GetEntityState(const AClone: T): TTSessionState;
    procedure InternalApplyChanges;
  public
    constructor Create(
      const AConnection: TTConnection;
      const AProvider: TTProvider;
      const AResolver: TTResolver;
      const AList: TList<T>);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function GetOriginalEntity(const AClone: T): T;

    procedure Insert(const AEntity: T);
    procedure Update(const AClone: T);
    procedure Delete(const AClone: T);

    procedure ApplyChanges;

    property Entities: TTList<T> read FEntities;
  end;

implementation

{ TTClonedEntities<T> }

constructor TTClonedEntities<T>.Create(const AProvider: TTProvider);
begin
  inherited Create;
  FProvider := AProvider;
  FEntities := TObjectDictionary<T, T>.Create([doOwnsKeys]);
end;

destructor TTClonedEntities<T>.Destroy;
begin
  FEntities.Free;
  inherited Destroy;
end;

function TTClonedEntities<T>.CloneEntity(const AEntity: T): T;
begin
  result := FProvider.CloneEntity<T>(AEntity);
  try
    FEntities.Add(result, AEntity);
  except
    result.Free;
    raise;
  end;
end;

procedure TTClonedEntities<T>.FreeClone(const AClone: T);
begin
  if FEntities.ContainsKey(AClone) then
    FEntities.Remove(AClone);
end;

function TTClonedEntities<T>.GetOriginalEntity(const AClone: T): T;
begin
  if not FEntities.TryGetValue(AClone, result) then
    result := nil;
end;

{ TTSession<T> }

constructor TTSession<T>.Create(
  const AConnection: TTConnection;
  const AProvider: TTProvider;
  const AResolver: TTResolver;
  const AList: TList<T>);
begin
  inherited Create;
  FConnection := AConnection;
  FProvider := AProvider;
  FResolver := AResolver;
  FOriginalEntities := AList;

  FApplied := False;
  FCloned := TTClonedEntities<T>.Create(FProvider);
  FClonedEntities := TList<T>.Create;
  FEntities := TTList<T>.Create;
  FAllEntities := TList<T>.Create;
  FEntityStates := TDictionary<T, TTSessionState>.Create;
end;

destructor TTSession<T>.Destroy;
begin
  FEntityStates.Free;
  FAllEntities.Free;
  FEntities.Free;
  FClonedEntities.Free;
  FCloned.Free;
  inherited Destroy;
end;

procedure TTSession<T>.AfterConstruction;
begin
  inherited AfterConstruction;
  CloneEntities;
end;

procedure TTSession<T>.CloneEntities;
var
  LEntity, LClone: T;
begin
  if Assigned(FOriginalEntities) then
    for LEntity in FOriginalEntities do
    begin
      LClone := FCloned.CloneEntity(LEntity);
      try
        FEntities.Add(LClone);
        FAllEntities.Add(LClone);
        FEntityStates.Add(LClone, TTSessionState.Original);
        FClonedEntities.Add(LClone);
      except
        FCloned.FreeClone(LClone);
        raise;
      end;
    end;
end;

function TTSession<T>.GetEntityState(const AClone: T): TTSessionState;
begin
  if not FEntityStates.TryGetValue(AClone, result) then
    raise ETException.CreateFmt(SNotValidEntity, [AClone.ToString()]);
end;

function TTSession<T>.GetOriginalEntity(const AClone: T): T;
begin
  result := FCloned.GetOriginalEntity(AClone);
end;

procedure TTSession<T>.Insert(const AEntity: T);
begin
  if FClonedEntities.Contains(AEntity) then
    raise ETException.CreateFmt(SClonedEntity, [AEntity.ToString()]);
  FEntities.Add(AEntity);
  FAllEntities.Add(AEntity);
  FEntityStates.Add(AEntity, TTSessionState.Inserted);
end;

procedure TTSession<T>.Update(const AClone: T);
var
  LState: TTSessionState;
begin
  LState := GetEntityState(AClone);
  if LState = TTSessionState.Deleted then
    raise ETException.CreateFmt(SDeletedEntity, [AClone.ToString()])
  else if LState = TTSessionState.Original then
    FEntityStates.AddOrSetValue(AClone, TTSessionState.Updated);
end;

procedure TTSession<T>.Delete(const AClone: T);
var
  LState: TTSessionState;
begin
  LState := GetEntityState(AClone);
  if LState = TTSessionState.Inserted then
    FEntityStates.AddOrSetValue(AClone, TTSessionState.Original)
  else
    FEntityStates.AddOrSetValue(AClone, TTSessionState.Deleted);
  FEntities.Remove(AClone);
end;

procedure TTSession<T>.InternalApplyChanges;
var
  LEntity: T;
  LState: TTSessionState;
begin
  for LEntity in FAllEntities do
  begin
    LState := GetEntityState(LEntity);
    case LState of
      TTSessionState.Inserted:
        FResolver.Insert<T>(LEntity);

      TTSessionState.Updated:
        FResolver.Update<T>(LEntity);

      TTSessionState.Deleted:
        FResolver.Delete<T>(LEntity);
    end;
  end;
end;

procedure TTSession<T>.ApplyChanges;
var
  LLocalTransaction: Boolean;
begin
  if FApplied then
    raise ETException.Create(SSessionNotTwice);

  LLocalTransaction := not FConnection.InTransaction;
  if LLocalTransaction then
    FConnection.StartTransaction;
  try
    InternalApplyChanges;
    if LLocalTransaction then
      FConnection.CommitTransaction;
  except
    if LLocalTransaction then
      FConnection.RollbackTransaction;
    raise;
  end;

  FApplied := True;
end;

end.
