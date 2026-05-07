(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Transaction;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Transaction,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerTransactionTests }

  [TestFixture]
  TTSqlServerTransactionTests = class(TTAbstractTransactionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerTransactionTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
