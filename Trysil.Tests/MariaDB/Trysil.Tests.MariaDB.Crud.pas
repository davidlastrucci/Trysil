(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Crud;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Crud,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBCrudTests }

  [TestFixture]
  TTMariaDBCrudTests = class(TTAbstractCrudTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBCrudTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
