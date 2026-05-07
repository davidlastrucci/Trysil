(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Session;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Session,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteSessionTests }

  [TestFixture]
  TTSQLiteSessionTests = class(TTAbstractSessionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteSessionTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
