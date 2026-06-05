(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleJoinTests }

  [TestFixture]
  TTOracleJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleJoinTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
