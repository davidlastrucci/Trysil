(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleLazyTests }

  [TestFixture]
  TTOracleLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleLazyTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
