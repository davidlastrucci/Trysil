(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.IdentityMap;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.IdentityMap,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLIdentityMapTests }

  [TestFixture]
  TTFirebirdSQLIdentityMapTests = class(TTAbstractIdentityMapTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLIdentityMapTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
