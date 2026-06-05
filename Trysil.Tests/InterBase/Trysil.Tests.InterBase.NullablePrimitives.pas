(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.InterBase.NullablePrimitives;

interface

uses
  DUnitX.TestFramework,

  Trysil.Data,

  Trysil.Tests.Abstract.NullablePrimitives,
  Trysil.Tests.InterBase.Connection;

type

{ TTInterBaseNullablePrimitivesTests }

  [TestFixture]
  TTInterBaseNullablePrimitivesTests = class(TTAbstractNullablePrimitivesTests)
  strict protected
    function GetConnection: TTConnection; override;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;
  end;

implementation

function TTInterBaseNullablePrimitivesTests.GetConnection: TTConnection;
begin
  result := TTInterBaseTestConnection.Connection;
end;

procedure TTInterBaseNullablePrimitivesTests.Setup;
begin
  inherited;
end;

procedure TTInterBaseNullablePrimitivesTests.TearDown;
begin
  inherited;
end;

end.
