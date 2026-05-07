(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Session;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Session,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLSessionTests }

  [TestFixture]
  TTFirebirdSQLSessionTests = class(TTAbstractSessionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLSessionTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
