(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Time;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Time,
  Trysil.Tests.FirebirdSQL.Connection;

type

{ TTFirebirdSQLTimeTests }

  [TestFixture]
  TTFirebirdSQLTimeTests = class(TTAbstractTimeTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTFirebirdSQLTimeTests.GetConnection: TTConnection;
begin
  result := TTFirebirdSQLTestConnection.Connection;
end;

procedure TTFirebirdSQLTimeTests.Setup;
begin
  inherited;
end;

procedure TTFirebirdSQLTimeTests.TearDown;
begin
  inherited;
end;

end.
