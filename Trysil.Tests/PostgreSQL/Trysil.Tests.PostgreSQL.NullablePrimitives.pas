(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLNullablePrimitivesTests }

  [TestFixture]
  TTPostgreSQLNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTPostgreSQLNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

procedure TTPostgreSQLNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTPostgreSQLNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
