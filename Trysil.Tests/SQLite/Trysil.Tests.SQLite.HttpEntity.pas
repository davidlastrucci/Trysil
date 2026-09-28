(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteHttpEntityTests }

  [TestFixture]
  TTSQLiteHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
