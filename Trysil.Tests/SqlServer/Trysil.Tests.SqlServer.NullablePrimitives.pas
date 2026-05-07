(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerNullablePrimitivesTests }

  [TestFixture]
  TTSqlServerNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSqlServerNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

procedure TTSqlServerNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTSqlServerNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
