(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLAllTypesJSonTests }

  [TestFixture]
  TTPostgreSQLAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTPostgreSQLAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

procedure TTPostgreSQLAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTPostgreSQLAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
