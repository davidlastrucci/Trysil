(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteLazyTests }

  [TestFixture]
  TTSQLiteLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteLazyTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
