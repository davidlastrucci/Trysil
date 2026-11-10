(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Time;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.Time,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteTimeTests }

  [TestFixture]
  TTSQLiteTimeTests = class(TTAbstractTimeTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSQLiteTimeTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

procedure TTSQLiteTimeTests.Setup;
begin
  inherited;
end;

procedure TTSQLiteTimeTests.TearDown;
begin
  inherited;
end;

end.
