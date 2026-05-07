(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteJoinTests }

  [TestFixture]
  TTSQLiteJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteJoinTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
