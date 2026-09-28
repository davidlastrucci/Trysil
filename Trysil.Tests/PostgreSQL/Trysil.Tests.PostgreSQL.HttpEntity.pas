(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLHttpEntityTests }

  [TestFixture]
  TTPostgreSQLHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
