(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.IdentityMap;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.IdentityMap,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleIdentityMapTests }

  [TestFixture]
  TTOracleIdentityMapTests = class(TTAbstractIdentityMapTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleIdentityMapTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
