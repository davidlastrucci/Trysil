(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.UpdateMode;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.UpdateMode,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerUpdateModeTests }

  [TestFixture]
  TTSqlServerUpdateModeTests = class(TTAbstractUpdateModeTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerUpdateModeTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
