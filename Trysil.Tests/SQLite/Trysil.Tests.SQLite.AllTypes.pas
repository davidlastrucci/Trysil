(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteAllTypesTests }

  [TestFixture]
  TTSQLiteAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSQLiteAllTypesTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

procedure TTSQLiteAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTSQLiteAllTypesTests.TearDown;
begin
  inherited;
end;

end.
