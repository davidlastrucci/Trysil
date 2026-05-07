(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.SQLite.Connection;

type

{ TTSQLiteNullablePrimitivesTests }

  [TestFixture]
  TTSQLiteNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSQLiteNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTSQLiteTestConnection.Connection;
end;

procedure TTSQLiteNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTSQLiteNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
