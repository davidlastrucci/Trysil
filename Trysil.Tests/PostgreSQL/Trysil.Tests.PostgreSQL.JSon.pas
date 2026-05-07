(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.JSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.JSon,
  Trysil.Tests.PostgreSQL.Connection;

type

{ TTPostgreSQLJSonTests }

  [TestFixture]
  TTPostgreSQLJSonTests = class(TTAbstractJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTPostgreSQLJSonTests.GetConnection: TTConnection;
begin
  result := TTPostgreSQLTestConnection.Connection;
end;

end.
