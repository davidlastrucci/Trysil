(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Validation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Validation,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteValidationTests }

  [TestFixture]
  TTSQLiteValidationTests = class(TTAbstractValidationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSQLiteValidationTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

end.
