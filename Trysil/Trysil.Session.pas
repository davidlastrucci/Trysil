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

  Trysil.Exceptions,
  Trysil.Generics.Collections,
  Trysil.Context;

type

{ TTSessionState }

  TTSessionState = (Original, Inserted, Updated, Deleted);

{ TTSession<T> }

  TTSession<T: class, constructor> = class
  strict private
    FContext: TTContext;
    FOriginalEntities: TList<T>;

    FApplied: Boolean;
    FClonedEntities: TList<T>;
    FAllEntities: TList<T>;
    FEntities: TTList<T>;
    FEntityStates: TDictionary<T, TTSessionState>;

    procedure CloneEntities;
    function GetEntityState(const AEntity: T): TTSessionState;
    procedure InternalApplyChanges;
  public
    constructor Create(const AContext: TTContext; const AList: TList<T>);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure Insert(const AEntity: T);
    procedure Update(const AEntity: T);
    procedure Delete(const AEntity: T);

    procedure ApplyChanges;

    property Entities: TTList<T> read FEntities;
  end;

resourcestring
  SClonedEntity = 'Can not insert a cloned entity: "%s".';
  SNotValidEntity = 'Not valid entity: "%s".';
  SDeletedEntity = 'Entity "%s" was deleted.';
  SSessionNotTwice = 'Session can not be used twice.';

implementation

{ TTSession<T> }

constructor TTSession<T>.Create(
  const AContext: TTContext; const AList: TList<T>);
begin
  inherited Create;
  FContext := AContext;
  FOriginalEntities := AList;

  FApplied := False;
  FClonedEntities := TList<T>.Create;
  FEntities := TTList<T>.Create;
  FAllEntities := TList<T>.Create;
  FEntityStates := TDictionary<T, TTSessionState>.Create;
end;

destructor TTSession<T>.Destroy;
var
  LClone: T;
begin
  FEntityStates.Free;
  FAllEntities.Free;
  FEntities.Free;
  for LClone in FClonedEntities do
    FContext.FreeClone<T>(LClone);

  FClonedEntities.Free;
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
      LClone := FContext.CloneEntity<T>(LEntity);
      try
        FEntities.Add(LClone);
        FAllEntities.Add(LClone);
        FEntityStates.Add(LClone, TTSessionState.Original);
        FClonedEntities.Add(LClone);
      except
        FContext.FreeClone<T>(LClone);
        raise;
      end;
    end;
end;

function TTSession<T>.GetEntityState(const AEntity: T): TTSessionState;
begin
  if not FEntityStates.TryGetValue(AEntity, result) then
    raise ETException.CreateFmt(SNotValidEntity, [AEntity.ToString()]);
end;

procedure TTSession<T>.Insert(const AEntity: T);
begin
  if FClonedEntities.Contains(AEntity) then
    raise ETException.CreateFmt(SClonedEntity, [AEntity.ToString()]);
  FEntities.Add(AEntity);
  FAllEntities.Add(AEntity);
  FEntityStates.Add(AEntity, TTSessionState.Inserted);
end;

procedure TTSession<T>.Update(const AEntity: T);
var
  LState: TTSessionState;
begin
  LState := GetEntityState(AEntity);
  if LState = TTSessionState.Deleted then
    raise ETException.CreateFmt(SDeletedEntity, [AEntity.ToString()])
  else if LState = TTSessionState.Original then
    FEntityStates.AddOrSetValue(AEntity, TTSessionState.Updated);
end;

procedure TTSession<T>.Delete(const AEntity: T);
var
  LState: TTSessionState;
begin
  LState := GetEntityState(AEntity);
  if LState = TTSessionState.Inserted then
    FEntityStates.AddOrSetValue(AEntity, TTSessionState.Original)
  else
    FEntityStates.AddOrSetValue(AEntity, TTSessionState.Deleted);
  FEntities.Remove(AEntity);
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
        FContext.Insert<T>(LEntity);

      TTSessionState.Updated:
        FContext.Update<T>(LEntity);

      TTSessionState.Deleted:
        FContext.Delete<T>(LEntity);
    end;
  end;
end;

procedure TTSession<T>.ApplyChanges;
var
  LLocalTransaction: Boolean;
begin
  if FApplied then
    raise ETException.Create(SSessionNotTwice);

  LLocalTransaction := not FContext.InTransaction;
  if LLocalTransaction then
    FContext.StartTransaction;
  try
    InternalApplyChanges;
    if LLocalTransaction then
      FContext.CommitTransaction;
  except
    if LLocalTransaction then
      FContext.RollbackTransaction;
    raise;
  end;

  FApplied := True;
end;

end.
