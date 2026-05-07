(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLLazyTests }

  [TestFixture]
  TTFirebirdSQLLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLLazyTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
