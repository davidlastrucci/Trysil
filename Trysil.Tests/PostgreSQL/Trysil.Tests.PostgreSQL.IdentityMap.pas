(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.IdentityMap;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.IdentityMap,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLIdentityMapTests }

  [TestFixture]
  TTPostgreSQLIdentityMapTests = class(TTAbstractIdentityMapTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLIdentityMapTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
