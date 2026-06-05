(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.AllTypes;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.AllTypes,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseAllTypesTests }

  [TestFixture]
  TTInterBaseAllTypesTests = class(TTAbstractAllTypesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTInterBaseAllTypesTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

procedure TTInterBaseAllTypesTests.Setup;
begin
  inherited;
end;

procedure TTInterBaseAllTypesTests.TearDown;
begin
  inherited;
end;

end.
