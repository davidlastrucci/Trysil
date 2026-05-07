(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Validation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Validation,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerValidationTests }

  [TestFixture]
  TTSqlServerValidationTests = class(TTAbstractValidationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTSqlServerValidationTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

end.
