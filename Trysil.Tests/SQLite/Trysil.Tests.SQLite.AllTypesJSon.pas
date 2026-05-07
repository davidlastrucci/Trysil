(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.AllTypesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypesJSon,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteAllTypesJSonTests }

  [TestFixture]
  TTSQLiteAllTypesJSonTests = class(TTAbstractAllTypesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSQLiteAllTypesJSonTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

procedure TTSQLiteAllTypesJSonTests.Setup;
begin
  inherited;
end;

procedure TTSQLiteAllTypesJSonTests.TearDown;
begin
  inherited;
end;

end.
