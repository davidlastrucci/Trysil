(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.NullablePrimitivesJSon;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitivesJSon,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteNullablePrimitivesJSonTests }

  [TestFixture]
  TTSQLiteNullablePrimitivesJSonTests = class(
    TTAbstractNullablePrimitivesJSonTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSQLiteNullablePrimitivesJSonTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

procedure TTSQLiteNullablePrimitivesJSonTests.Setup;
begin
  inherited;
end;

procedure TTSQLiteNullablePrimitivesJSonTests.TearDown;
begin
  inherited;
end;

end.
