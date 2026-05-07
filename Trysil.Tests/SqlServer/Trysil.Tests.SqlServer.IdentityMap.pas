(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.IdentityMap;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.IdentityMap,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerIdentityMapTests }

  [TestFixture]
  TTSqlServerIdentityMapTests = class(TTAbstractIdentityMapTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerIdentityMapTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
