(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Time;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Time,
  Trysil.Tests.MariaDB.Connection;

type

{ TTMariaDBTimeTests }

  [TestFixture]
  TTMariaDBTimeTests = class(TTAbstractTimeTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTMariaDBTimeTests.GetConnection: TTConnection;
begin
  result := TTMariaDBTestConnection.Connection;
end;

procedure TTMariaDBTimeTests.Setup;
begin
  inherited;
end;

procedure TTMariaDBTimeTests.TearDown;
begin
  inherited;
end;

end.
