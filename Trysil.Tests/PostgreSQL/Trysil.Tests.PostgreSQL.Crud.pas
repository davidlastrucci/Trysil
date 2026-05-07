(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Crud;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Crud,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLCrudTests }

  [TestFixture]
  TTPostgreSQLCrudTests = class(TTAbstractCrudTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLCrudTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
