(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.ContextApi;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ContextApi,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteContextApiTests }

  [TestFixture]
  TTSQLiteContextApiTests = class(TTAbstractContextApiTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

{ TTSQLiteContextApiTests }

function TTSQLiteContextApiTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
