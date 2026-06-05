(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Validation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Validation,
  Trysil.Tests.Oracle.Connection;

type

{ TTOracleValidationTests }

  [TestFixture]
  TTOracleValidationTests = class(TTAbstractValidationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTOracleValidationTests.GetConnection: TTConnection;
begin
  result := TTOracleTestConnection.Connection;
end;

end.
