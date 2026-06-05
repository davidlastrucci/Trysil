(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Session;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Session,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleSessionTests }

  [TestFixture]
  TTOracleSessionTests = class(TTAbstractSessionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleSessionTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
