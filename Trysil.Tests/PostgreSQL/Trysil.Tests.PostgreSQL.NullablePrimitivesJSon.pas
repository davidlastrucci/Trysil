(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLNullablePrimitivesJSonTests }

  [TestFixture]
  TTPostgreSQLNullablePrimitivesJSonTests = class(
    TTAbstractNullablePrimitivesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTPostgreSQLNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

procedure TTPostgreSQLNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTPostgreSQLNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
