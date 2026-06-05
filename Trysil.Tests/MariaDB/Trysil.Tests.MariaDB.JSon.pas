(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.JSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.JSon,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBJSonTests }

  [TestFixture]
  TTMariaDBJSonTests = class(TTAbstractJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBJSonTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
