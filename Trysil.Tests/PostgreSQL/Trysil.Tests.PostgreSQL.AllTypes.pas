(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLAllTypesTests }

  [TestFixture]
  TTPostgreSQLAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTPostgreSQLAllTypesTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

procedure TTPostgreSQLAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTPostgreSQLAllTypesTests.TearDown;
begin
  inherited;
end;

end.
