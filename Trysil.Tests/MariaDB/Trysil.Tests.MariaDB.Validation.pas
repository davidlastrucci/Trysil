(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Validation;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Validation,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBValidationTests }

  [TestFixture]
  TTMariaDBValidationTests = class(TTAbstractValidationTests)
  strict protected
    function GetConnection: TTConnection; override;
  end;

implementation

function TTMariaDBValidationTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

end.
