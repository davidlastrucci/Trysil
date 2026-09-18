(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.SqlSyntax;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,

  Trysil.Exceptions,

  Trysil.Tests.Oracle.Connection;

type

{ TTOracleSqlSyntaxTests }

  [TestFixture]
  TTOracleSqlSyntaxTests = class
  public
    [Test]
    procedure ANameOracleCannotEscapeIsRefused;
  end;

implementation

{ TTOracleSqlSyntaxTests }

procedure TTOracleSqlSyntaxTests.ANameOracleCannotEscapeIsRefused;
var
  LName: String;
  LMessage: String;
  LRaised: Boolean;
begin
  LMessage := String.Empty;
  Assert.AreEqual(
    '"ORDER"',
    TTOracleTestConnection.Connection.GetDatabaseObjectName('Order'),
    'Precondition: an ordinary name is quoted and folded to upper case');

  LRaised := False;
  try
    LName := TTOracleTestConnection.Connection.GetDatabaseObjectName('a"b');
  except
    on E: ETException do
    begin
      LRaised := True;
      LMessage := E.Message;
    end;
  end;

  Assert.IsTrue(
    LRaised,
    'Oracle says that neither a quoted nor an unquoted identifier can ' +
    'carry a double quote, so there is nothing to escape it with: the ' +
    'doubling that PostgreSQL, Firebird and InterBase document would name ' +
    'a different object here, and be read as SQL after the first quote');

  Assert.IsTrue(
    LMessage.Contains('"') and LMessage.Contains('Oracle'),
    'The message carries the character and the engine, which are its two ' +
    'arguments. The assertion names only those, and not the English around ' +
    'them, because the message goes through the translation table: pinned ' +
    'to a phrase it turns red the moment a language is registered, for a ' +
    'reason that is not the defect - and the two language units exist');
  Assert.IsFalse(
    LMessage.Contains('double quote'),
    'and the character is given as itself. It used to be given as those ' +
    'two English words, which carry an article of their own, so the ' +
    'sentence read "carries a a double quote"');
end;

end.
