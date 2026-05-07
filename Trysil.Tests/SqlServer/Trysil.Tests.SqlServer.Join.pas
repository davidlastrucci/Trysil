(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Join;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Join,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerJoinTests }

  [TestFixture]
  TTSqlServerJoinTests = class(TTAbstractJoinTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerJoinTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
