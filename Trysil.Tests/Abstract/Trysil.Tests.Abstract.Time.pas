(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Abstract.Time;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Context,

  Trysil.Tests.Abstract.Base,
  Trysil.Tests.Model;

type

{ TTAbstractTimeTests }

  TTAbstractTimeTests = class(TTAbstractBaseTests)
  strict protected
    procedure DeleteTables; override;

    function InsertShift(const AStartsAt: TDateTime): TTPrimaryKey;
    function ReadStartsAt(const AID: TTPrimaryKey): TDateTime;
  public
    [Setup]
    procedure Setup; override;

    [TearDown]
    procedure TearDown; override;

    [Test]
    procedure ATimeColumnKeepsItsTime;
  end;

implementation

{ TTAbstractTimeTests }

procedure TTAbstractTimeTests.DeleteTables;
begin
  inherited;
  Connection.Execute('DELETE FROM Shifts');
end;

procedure TTAbstractTimeTests.Setup;
begin
  inherited;
end;

procedure TTAbstractTimeTests.TearDown;
begin
  inherited;
end;

function TTAbstractTimeTests.InsertShift(
  const AStartsAt: TDateTime): TTPrimaryKey;
var
  LShift: TTestShift;
begin
  LShift := FContext.CreateEntity<TTestShift>();
  try
    LShift.StartsAt := AStartsAt;
    FContext.Insert<TTestShift>(LShift);
    result := LShift.ID;
  finally
    FContext.FreeEntity<TTestShift>(LShift);
  end;
end;

function TTAbstractTimeTests.ReadStartsAt(
  const AID: TTPrimaryKey): TDateTime;
var
  LContext: TTContext;
  LShift: TTestShift;
begin
  LContext := TTContext.Create(Connection, False);
  try
    LShift := LContext.Get<TTestShift>(AID);
    try
      result := LShift.StartsAt;
    finally
      LContext.FreeEntity<TTestShift>(LShift);
    end;
  finally
    LContext.Free;
  end;
end;

procedure TTAbstractTimeTests.ATimeColumnKeepsItsTime;
var
  LID: TTPrimaryKey;
begin
  LID := InsertShift(EncodeTime(8, 5, 0, 0));

  Assert.AreEqual<TDateTime>(
    EncodeTime(8, 5, 0, 0),
    ReadStartsAt(LID),
    'A time column must be written as a time: written as a date and ' +
    'time it comes back as midnight');
end;

end.
