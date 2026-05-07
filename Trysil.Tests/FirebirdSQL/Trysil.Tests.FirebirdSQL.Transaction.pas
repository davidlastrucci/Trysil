(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Transaction;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Transaction,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLTransactionTests }

  [TestFixture]
  TTFirebirdSQLTransactionTests = class(TTAbstractTransactionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTFirebirdSQLTransactionTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

end.
