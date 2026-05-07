(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.UpdateMode;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.UpdateMode,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteUpdateModeTests }

  [TestFixture]
  TTSQLiteUpdateModeTests = class(TTAbstractUpdateModeTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

{ TTSQLiteUpdateModeTests }

function TTSQLiteUpdateModeTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
