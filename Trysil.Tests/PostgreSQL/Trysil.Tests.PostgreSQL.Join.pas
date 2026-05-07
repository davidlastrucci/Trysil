(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLJoinTests }

  [TestFixture]
  TTPostgreSQLJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLJoinTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
