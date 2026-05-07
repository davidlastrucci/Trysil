(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.JSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.JSon,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerJSonTests }

  [TestFixture]
  TTSqlServerJSonTests = class(TTAbstractJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerJSonTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
