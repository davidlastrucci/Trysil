(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLLazyTests }

  [TestFixture]
  TTPostgreSQLLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLLazyTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
