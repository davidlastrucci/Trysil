(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Transaction;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Transaction,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteTransactionTests }

  [TestFixture]
  TTSQLiteTransactionTests = class(TTAbstractTransactionTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteTransactionTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
