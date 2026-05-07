(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLAllTypesJSonTests }

  [TestFixture]
  TTFirebirdSQLAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTFirebirdSQLAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

procedure TTFirebirdSQLAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTFirebirdSQLAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
