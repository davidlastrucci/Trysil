(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Lazy;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Lazy,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBLazyTests }

  [TestFixture]
  TTMariaDBLazyTests = class(TTAbstractLazyTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBLazyTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
