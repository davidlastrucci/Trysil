(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Events;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Events,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLEventsTests }

  [TestFixture]
  TTPostgreSQLEventsTests = class(TTAbstractEventsTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLEventsTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
