(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.ContextApi;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.ContextApi,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerContextApiTests }

  [TestFixture]
  TTSqlServerContextApiTests = class(TTAbstractContextApiTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerContextApiTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
