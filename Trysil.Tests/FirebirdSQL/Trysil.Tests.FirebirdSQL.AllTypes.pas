(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLAllTypesTests }

  [TestFixture]
  TTFirebirdSQLAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTFirebirdSQLAllTypesTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

procedure TTFirebirdSQLAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTFirebirdSQLAllTypesTests.TearDown;
begin
  inherited;
end;

end.
