(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Events;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Events,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteEventsTests }

  [TestFixture]
  TTSQLiteEventsTests = class(TTAbstractEventsTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteEventsTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
