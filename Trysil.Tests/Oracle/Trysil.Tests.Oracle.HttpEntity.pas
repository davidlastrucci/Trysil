(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleHttpEntityTests }

  [TestFixture]
  TTOracleHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
