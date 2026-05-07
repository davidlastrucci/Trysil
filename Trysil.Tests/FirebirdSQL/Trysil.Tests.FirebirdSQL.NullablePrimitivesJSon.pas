(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLNullablePrimitivesJSonTests }

  [TestFixture]
  TTFirebirdSQLNullablePrimitivesJSonTests = class(
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

function TTFirebirdSQLNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

procedure TTFirebirdSQLNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTFirebirdSQLNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
