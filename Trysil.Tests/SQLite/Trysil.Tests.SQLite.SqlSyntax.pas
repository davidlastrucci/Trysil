(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.SqlSyntax;

interface

uses
  System.SysUtils,
  System.RegularExpressions,
  DUnitX.TestFramework,

  Trysil.Filter,
  Trysil.Context,
  Trysil.Generics.Collections,
  Trysil.Exceptions,
  Trysil.Mapping,
  Trysil.Data.SqlSyntax,
  Trysil.Data.SqlSyntax.SQLite,
  Trysil.Data.SqlSyntax.PostgreSQL,
  Trysil.Data.SqlSyntax.FirebirdSQL,
  Trysil.Data.SqlSyntax.InterBase,
  Trysil.Data.SqlSyntax.MariaDB,
  Trysil.Data.SqlSyntax.Oracle,
  Trysil.Data.SqlSyntax.SqlServer,

  Trysil.Tests.SQLite.Connection,
  Trysil.Tests.Model;

type

{ TTSQLiteSqlSyntaxTests }

  [TestFixture]
  TTSQLiteSqlSyntaxTests = class
  strict private
    function PagedSelect(const AClasses: TTSyntaxClasses): String;
    procedure CheckTokensAreSeparated(
      const ADialect: String; const AClasses: TTSyntaxClasses);
    function CountSelect(const AClasses: TTSyntaxClasses): String;
  public
    [Test]
    procedure EveryDialectSeparatesThePagingFromTheColumns;

    [Test]
    procedure ANameSQLiteCannotEscapeIsRefused;

    [Test]
    procedure TwoColumnsThatNameOneParameterAreRefused;

    [Test]
    procedure OnlySqlServerCountsWithCountBig;
  end;

implementation

{ TTSQLiteSqlSyntaxTests }

procedure TTSQLiteSqlSyntaxTests.ANameSQLiteCannotEscapeIsRefused;
var
  LName: String;
  LMessage: String;
  LRaised: Boolean;
begin
  LMessage := String.Empty;

  Assert.AreEqual(
    '[Order]',
    TTSQLiteTestConnection.Connection.GetDatabaseObjectName('Order'),
    'Precondition: an ordinary name is quoted with brackets');

  LRaised := False;
  try
    LName := TTSQLiteTestConnection.Connection.GetDatabaseObjectName('a]b');
  except
    on E: ETException do
    begin
      LRaised := True;
      LMessage := E.Message;
    end;
  end;

  Assert.IsTrue(
    LRaised,
    'SQLite has no escape for a "]" inside [ ]: the identifier ends at the ' +
    'first bracket and what follows it is read as SQL. Doubling it, which ' +
    'is what SQL Server documents and what the shared code did, named a ' +
    'different object without saying so');

  Assert.IsTrue(
    LMessage.Contains('SQLite'),
    'and the message names the engine, which is one of its arguments');
  Assert.IsFalse(
    LMessage.Contains('"]"'),
    'The character used to be given as the three-character string "]" '
    + 'instead of the bracket. Looking for a bracket anywhere in the '
    + 'message proved nothing: the name a]b carries one of its own');
end;

procedure TTSQLiteSqlSyntaxTests.TwoColumnsThatNameOneParameterAreRefused;
var
  LContext: TTContext;
  LList: TTList<TTestParamCollision>;
  LRaised: Boolean;
  LMessage: String;
begin
  LRaised := False;
  LMessage := String.Empty;

  LContext := TTContext.Create(TTSQLiteTestConnection.Connection, False);
  try
    LList := LContext.CreateEntityList<TTestParamCollision>();
    try
      try
        LContext.SelectAll<TTestParamCollision>(LList);
      except
        on E: ETException do
        begin
          LRaised := True;
          LMessage := E.Message;
        end;
      end;
    finally
      LList.Free;
    end;
  finally
    LContext.Free;
  end;

  Assert.IsTrue(
    LRaised,
    'ParamCollision maps a column named "Ragione Sociale" and one named '
    + 'Ragione_Sociale, and the space folds onto the underscore: both name '
    + 'the parameter :Ragione_Sociale, both find the same TFDParam, and '
    + 'the second used to write over the first without a word - which is '
    + 'the very failure the entry that stopped folding the other hostile '
    + 'characters says it refused');
  Assert.IsTrue(
    LMessage.Contains('Ragione'),
    'and the message names the columns, so the mapping can be corrected '
    + 'without guessing which two collided');
end;

function TTSQLiteSqlSyntaxTests.PagedSelect(
  const AClasses: TTSyntaxClasses): String;
var
  LSyntax: TTSelectSyntax;
begin
  LSyntax := AClasses.Select.Create(
    TTSQLiteTestConnection.Connection,
    TTMapper.Instance.Load<TTestCustomer>(),
    TTFilter.Create(String.Empty, 20, 10, 'ID'));
  try
    result := LSyntax.SQL;
  finally
    LSyntax.Free;
  end;
end;

procedure TTSQLiteSqlSyntaxTests.CheckTokensAreSeparated(
  const ADialect: String; const AClasses: TTSyntaxClasses);
var
  LSql: String;
begin
  try
    LSql := PagedSelect(AClasses);
  finally
    AClasses.Free;
  end;

  Assert.IsFalse(
    TRegEx.IsMatch(LSql, '\d[A-Za-z_]'),
    Format(
      '%s glues the paging to the next token, which is not valid SQL. ' +
      'Five of the seven dialects have never been executed, so a missing ' +
      'space is found by reading or not at all: %s', [ADialect, LSql]));
  Assert.IsTrue(
    LSql.Contains(Format(' FROM %s', [
      TTSQLiteTestConnection.Connection.GetDatabaseObjectName(
        'Customers')])),
    Format('%s must still select from the table: %s', [ADialect, LSql]));
end;

procedure TTSQLiteSqlSyntaxTests.EveryDialectSeparatesThePagingFromTheColumns;
begin
  CheckTokensAreSeparated('SQLite', TTSQLiteSyntaxClasses.Create);
  CheckTokensAreSeparated('PostgreSQL', TTPostgreSQLSyntaxClasses.Create);
  CheckTokensAreSeparated('FirebirdSQL', TTFirebirdSQLSyntaxClasses.Create);
  CheckTokensAreSeparated('InterBase', TTInterBaseSyntaxClasses.Create);
  CheckTokensAreSeparated('MariaDB', TTMariaDBSyntaxClasses.Create);
  CheckTokensAreSeparated('Oracle', TTOracleSyntaxClasses.Create);
  CheckTokensAreSeparated('SqlServer', TTSqlServerSyntaxClasses.Create);
end;

function TTSQLiteSqlSyntaxTests.CountSelect(
  const AClasses: TTSyntaxClasses): String;
var
  LSyntax: TTSelectCountSyntax;
begin
  try
    LSyntax := AClasses.SelectCount.Create(
      TTSQLiteTestConnection.Connection,
      TTMapper.Instance.Load<TTestCustomer>(),
      TTFilter.Create(String.Empty));
    try
      result := LSyntax.SQL;
    finally
      LSyntax.Free;
    end;
  finally
    AClasses.Free;
  end;
end;

procedure TTSQLiteSqlSyntaxTests.OnlySqlServerCountsWithCountBig;
begin
  Assert.IsTrue(
    CountSelect(TTSqlServerSyntaxClasses.Create).Contains('COUNT_BIG(*)'),
    'COUNT(*) is an int on SQL Server: past 2147483647 rows the engine '
    + 'raised an arithmetic overflow before any Delphi type came into '
    + 'play, and SelectCount returning Int64 could not help');
  Assert.IsTrue(
    CountSelect(TTSQLiteSyntaxClasses.Create).Contains('COUNT(*)'),
    'The other six keep COUNT(*), which is already 64-bit there, or which '
    + 'has no wider form');
  Assert.IsFalse(
    CountSelect(TTOracleSyntaxClasses.Create).Contains('COUNT_BIG'),
    'and COUNT_BIG does not leak into a dialect that has no such function');
end;

end.
