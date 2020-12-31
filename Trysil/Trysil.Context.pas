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

  Trysil.Types,
  Trysil.Filter,
  Trysil.Context.Abstract,
  Trysil.Generics.Collections,
  Trysil.Data,
  Trysil.Metadata,
  Trysil.Provider,
  Trysil.Resolver;

type

{ TTContext }

  TTContext = class(TTAbstractContext)
  strict private
    FConnection: TTDataConnection;
    FProvider: TTProvider;
    FResolver: TTResolver;

    function GetInTransaction: Boolean;
  public
    constructor Create(const AConnection: TTDataConnection); override;
    destructor Destroy; override;

    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;

    function CreateEntity<T: class, constructor>(): T;
    function CloneEntity<T: class, constructor>(const AEntity: T): T;

    function GetMetadata<T: class>(): TTTableMetadata;

    procedure SelectAll<T: class, constructor>(const AResult: TTList<T>);
    procedure Select<T: class, constructor>(
      const AResult: TTList<T>; const AFilter: TTFilter);

    function Get<T: class, constructor>(const AID: TTPrimaryKey): T;

    procedure Refresh<T: class>(const AEntity: T);

    procedure Insert<T: class>(const AEntity: T);
    procedure Update<T: class>(const AEntity: T);
    procedure Delete<T: class>(const AEntity: T);

    property InTransaction: Boolean read GetInTransaction;
  end;

implementation

{ TTContext }

constructor TTContext.Create(const AConnection: TTDataConnection);
begin
  inherited Create(AConnection);
  FConnection := AConnection;
  FProvider := TTProvider.Create(Self);
  FResolver := TTResolver.Create(Self);
end;

destructor TTContext.Destroy;
begin
  FResolver.Free;
  FProvider.Free;
  inherited Destroy;
end;

function TTContext.GetInTransaction: Boolean;
begin
  result := FConnection.InTransaction;
end;

procedure TTContext.StartTransaction;
begin
  FConnection.StartTransaction;
end;

procedure TTContext.CommitTransaction;
begin
  FConnection.CommitTransaction;
end;

procedure TTContext.RollbackTransaction;
begin
  FConnection.RollbackTransaction;
end;

function TTContext.CreateEntity<T>(): T;
begin
  result := FProvider.CreateEntity<T>();
end;

function TTContext.CloneEntity<T>(const AEntity: T): T;
begin
  result := FProvider.CloneEntity<T>(AEntity);
end;

function TTContext.GetMetadata<T>: TTTableMetadata;
begin
  result := FProvider.GetMetadata<T>();
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

procedure TTContext.Insert<T>(const AEntity: T);
begin
  FResolver.Insert<T>(AEntity);
end;

procedure TTContext.Update<T>(const AEntity: T);
begin
  FResolver.Update<T>(AEntity);
end;

procedure TTContext.Delete<T>(const AEntity: T);
begin
  FResolver.Delete<T>(AEntity);
end;

end.
