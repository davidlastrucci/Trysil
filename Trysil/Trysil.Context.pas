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

  Trysil.Types,
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
    procedure ApplyAll<T: class>(
      const AList: TTList<T>; const AApplyAllMethod: TTApplyAllMethod<T>);

    function GetInTransaction: Boolean;
    function GetUseIdentityMap: Boolean;
  strict protected
    FConnection: TTConnection;
    FMetadata: TTMetadata;
    FProvider: TTProvider;
    FResolver: TTResolver;

    function CreateResolver: TTResolver; virtual;
    function InLoading: Boolean; virtual;
  public
    constructor Create(const AConnection: TTConnection); overload; virtual;
    constructor Create(
      const AConnection: TTConnection;
      const AUseIdentityMap: Boolean); overload; virtual;
    destructor Destroy; override;

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

    procedure Refresh<T: class>(const AEntity: T);

    procedure Validate<T: class>(const AEntity: T);

    procedure Insert<T: class>(const AEntity: T);
    procedure InsertAll<T: class>(const AList: TTList<T>);

    procedure Update<T: class>(const AEntity: T);
    procedure UpdateAll<T: class>(const AList: TTList<T>);

    procedure Delete<T: class>(const AEntity: T);
    procedure DeleteAll<T: class>(const AList: TTList<T>);

    property InTransaction: Boolean read GetInTransaction;
    property UseIdentityMap: Boolean read GetUseIdentityMap;
  end;

implementation

{ TTContext }

constructor TTContext.Create(const AConnection: TTConnection);
begin
  Create(AConnection, True);
end;

constructor TTContext.Create(
  const AConnection: TTConnection; const AUseIdentityMap: Boolean);
begin
  inherited Create;
  FConnection := AConnection;

  FMetadata := TTMetadata.Create(FConnection);

  FProvider := TTProvider.Create(
    FConnection, Self, FMetadata, AUseIdentityMap);
  FResolver := CreateResolver;
end;

destructor TTContext.Destroy;
begin
  FResolver.Free;
  FProvider.Free;
  FMetadata.Free;
  inherited Destroy;
end;

function TTContext.CreateResolver: TTResolver;
begin
  result := TTResolver.Create(FConnection, Self, FMetadata);
end;

function TTContext.InLoading: Boolean;
begin
  result := False;
end;

function TTContext.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

function TTContext.GetUseIdentityMap: Boolean;
begin
  result := FProvider.UseIdentityMap;
end;

function TTContext.CreateEntity<T>(): T;
begin
  result := FProvider.CreateEntity<T>(InLoading);
end;

function TTContext.CloneEntity<T>(const AEntity: T): T;
begin
  result := FProvider.CloneEntity<T>(AEntity);
end;

function TTContext.CreateTransaction: TTTransaction;
begin
  result := TTTransaction.Create(FConnection);
end;

function TTContext.CreateSession<T>(const AList: TList<T>): TTSession<T>;
begin
  result := TTSession<T>.Create(FConnection, FProvider, FResolver, AList);
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

procedure TTContext.Refresh<T>(const AEntity: T);
begin
  FProvider.Refresh<T>(AEntity);
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
    LTransaction := TTTransaction.Create(FConnection);
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

procedure TTContext.Insert<T>(const AEntity: T);
begin
  FResolver.Insert<T>(AEntity);
end;

procedure TTContext.InsertAll<T>(const AList: TTList<T>);
begin
  ApplyAll<T>(
    AList, procedure(const AEntity: T)
    begin
      FResolver.Insert<T>(AEntity);
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
      FResolver.Update<T>(AEntity);
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
      FResolver.Delete<T>(AEntity);
    end);
end;

end.
