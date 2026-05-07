(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Base;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Context,
  Trysil.Data;

type

{ TTAbstractBaseTests }

  TTAbstractBaseTests = class
  strict protected
    FContext: TTContext;

    function GetConnection: TTConnection; virtual; abstract;
    procedure ClearTables; virtual;
  public
    property Connection: TTConnection read GetConnection;

    [Setup]
    procedure Setup; virtual;

    [TearDown]
    procedure TearDown; virtual;
  end;

implementation

{ TTAbstractBaseTests }

procedure TTAbstractBaseTests.ClearTables;
begin
  Connection.Execute('DELETE FROM Orders;');
  Connection.Execute('DELETE FROM Customers;');
  Connection.Execute('DELETE FROM Tasks;');
  Connection.Execute('DELETE FROM TrackedUsers;');
  Connection.Execute('DELETE FROM ValidatedItems;');
  Connection.Execute('DELETE FROM FullValidation;');
  Connection.Execute('DELETE FROM Countries;');
  Connection.Execute('DELETE FROM SimpleItems;');
end;

procedure TTAbstractBaseTests.Setup;
begin
  ClearTables;
  FContext := TTContext.Create(Connection);
end;

procedure TTAbstractBaseTests.TearDown;
begin
  FContext.Free;
end;

end.
