(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Session;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Session,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerSessionTests }

  [TestFixture]
  TTSqlServerSessionTests = class(TTAbstractSessionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerSessionTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
