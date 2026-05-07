(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLNullablePrimitivesTests }

  [TestFixture]
  TTFirebirdSQLNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTFirebirdSQLNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

procedure TTFirebirdSQLNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTFirebirdSQLNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
