(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.ContextApi;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ContextApi,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleContextApiTests }

  [TestFixture]
  TTOracleContextApiTests = class(TTAbstractContextApiTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleContextApiTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
