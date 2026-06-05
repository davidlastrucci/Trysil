(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Events;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Events,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleEventsTests }

  [TestFixture]
  TTOracleEventsTests = class(TTAbstractEventsTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleEventsTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
