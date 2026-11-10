(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Time;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Time,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerTimeTests }

  [TestFixture]
  TTSqlServerTimeTests = class(TTAbstractTimeTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSqlServerTimeTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

procedure TTSqlServerTimeTests.Setup;
begin
  inherited;
end;

procedure TTSqlServerTimeTests.TearDown;
begin
  inherited;
end;

end.
