(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLHttpEntityTests }

  [TestFixture]
  TTFirebirdSQLHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
