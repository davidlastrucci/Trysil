(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.SchemaName;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Types,
  Trysil.Context,
  Trysil.Data,
  Trysil.Filter,
  Trysil.Attributes,
  Trysil.Generics.Collections,

  Trysil.Tests.SqlServer.Connection;

type

{ TTestReportInvoice }

  [TTable('Report.Invoices')]
  [TSequence('InvoicesID')]
  TTestReportInvoice = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Description')]
    FDescription: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Description: String read FDescription write FDescription;
    property VersionID: TTVersion read FVersionID;
  end;

{ TTSqlServerSchemaNameTests }

  [TestFixture]
  TTSqlServerSchemaNameTests = class
  strict private
    FContext: TTContext;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AQualifiedNameReachesTheObjectInItsSchema;

    [Test]
    procedure AQualifiedNameIsWritableAndCountable;
  end;

implementation

{ TTSqlServerSchemaNameTests }

procedure TTSqlServerSchemaNameTests.Setup;
begin
  TTSqlServerTestConnection.Connection.Execute(
    'DELETE FROM Report.Invoices');
  FContext := TTContext.Create(TTSqlServerTestConnection.Connection);
end;

procedure TTSqlServerSchemaNameTests.TearDown;
begin
  FContext.Free;
end;

procedure TTSqlServerSchemaNameTests.AQualifiedNameReachesTheObjectInItsSchema;
var
  LInvoice: TTestReportInvoice;
  LReloaded: TTestReportInvoice;
begin
  LInvoice := FContext.CreateEntity<TTestReportInvoice>();
  try
    LInvoice.Description := 'Qualified';
    FContext.Insert<TTestReportInvoice>(LInvoice);

    LReloaded := FContext.Get<TTestReportInvoice>(LInvoice.ID);
    try
      Assert.AreEqual(
        'Qualified',
        LReloaded.Description,
        'A table outside the default schema is named with the schema in ' +
        'the attribute, and the quoting has to keep the two apart: ' +
        '[Report].[Invoices] and not [Report.Invoices], which is an ' +
        'object with a dot in its name that nobody created');
    finally
      FContext.FreeEntity<TTestReportInvoice>(LReloaded);
    end;
  finally
    FContext.FreeEntity<TTestReportInvoice>(LInvoice);
  end;
end;

procedure TTSqlServerSchemaNameTests.AQualifiedNameIsWritableAndCountable;
var
  LInvoice: TTestReportInvoice;
begin
  LInvoice := FContext.CreateEntity<TTestReportInvoice>();
  try
    LInvoice.Description := 'Before';
    FContext.Insert<TTestReportInvoice>(LInvoice);

    LInvoice.Description := 'After';
    FContext.Update<TTestReportInvoice>(LInvoice);

    Assert.AreEqual<Integer>(
      1,
      FContext.SelectCount<TTestReportInvoice>(TTFilter.Empty),
      'The count, the update and the delete build their own statements, ' +
      'and each one names the table again');

    FContext.Delete<TTestReportInvoice>(LInvoice);

    Assert.AreEqual<Integer>(
      0,
      FContext.SelectCount<TTestReportInvoice>(TTFilter.Empty),
      'And the delete ran');
  finally
    FContext.FreeEntity<TTestReportInvoice>(LInvoice);
  end;
end;

end.
