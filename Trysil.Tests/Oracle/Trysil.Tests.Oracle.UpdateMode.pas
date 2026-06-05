(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.UpdateMode;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.UpdateMode,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleUpdateModeTests }

  [TestFixture]
  TTOracleUpdateModeTests = class(TTAbstractUpdateModeTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleUpdateModeTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
