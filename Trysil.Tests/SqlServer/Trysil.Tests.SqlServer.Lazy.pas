(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerLazyTests }

  [TestFixture]
  TTSqlServerLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerLazyTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
