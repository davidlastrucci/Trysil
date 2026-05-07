(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Events;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Events,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerEventsTests }

  [TestFixture]
  TTSqlServerEventsTests = class(TTAbstractEventsTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerEventsTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
