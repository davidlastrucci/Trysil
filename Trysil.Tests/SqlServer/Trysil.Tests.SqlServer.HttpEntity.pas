(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.HttpEntity;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.HttpEntity,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerHttpEntityTests }

  [TestFixture]
  TTSqlServerHttpEntityTests = class(TTAbstractHttpEntityTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerHttpEntityTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
