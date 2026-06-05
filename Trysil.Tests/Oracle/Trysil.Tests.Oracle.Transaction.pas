(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Transaction;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Transaction,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleTransactionTests }

  [TestFixture]
  TTOracleTransactionTests = class(TTAbstractTransactionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleTransactionTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
