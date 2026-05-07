(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.JSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.JSon,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteJSonTests }

  [TestFixture]
  TTSQLiteJSonTests = class(TTAbstractJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteJSonTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
