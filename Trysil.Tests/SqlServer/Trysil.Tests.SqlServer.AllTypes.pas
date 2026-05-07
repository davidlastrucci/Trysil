(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.SqlServer.Connection;

type

{ TTSqlServerAllTypesTests }

  [TestFixture]
  TTSqlServerAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTSqlServerAllTypesTests.GetConnection: TTConnection;
begin
  result := TTSqlServerTestConnection.Connection;
end;

procedure TTSqlServerAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTSqlServerAllTypesTests.TearDown;
begin
  inherited;
end;

end.
