(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Crud;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Crud,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLCrudTests }

  [TestFixture]
  TTFirebirdSQLCrudTests = class(TTAbstractCrudTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLCrudTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
