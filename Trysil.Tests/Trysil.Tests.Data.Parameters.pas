(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Data.Parameters;

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.TypInfo,
  System.Rtti,
  System.Generics.Defaults,
  Data.DB,
  DUnitX.TestFramework,

  Trysil.Rtti,
  Trysil.Classes,
  Trysil.Exceptions,
  Trysil.Data,
  Trysil.Data.Columns,
  Trysil.Data.Parameters;

type

{ TTDatabaseObjectNameTests }

  [TestFixture]
  TTDatabaseObjectNameTests = class
  strict private
    const TurkishLCID = $041F;
  public
    [Test]
    procedure AQuotedNameResolvesWhatAnUnquotedOneResolved;

    [Test]
    procedure ANameKeepsItsCaseWhereTheEngineDoesNotFold;

    [Test]
    procedure TheClosingQuoteInsideANameIsDoubled;

    [Test]
    procedure AQualifiedNameIsQuotedPartByPart;

    [Test]
    procedure AnEmptyNameStaysEmpty;

    [Test]
    procedure TheFoldingDoesNotFollowTheLocaleOfTheMachine;

    [Test]
    procedure TwoNamesAreTheSameWhateverTheLocaleOfTheMachine;

    [Test]
    procedure TheComparerHashesWhatItCompares;
  end;

{ TTFieldTypeRegistryTests }

  [TestFixture]
  TTFieldTypeRegistryTests = class
  strict private
    function TypeIsRegistered(const AFieldType: TFieldType): Boolean;
  public
    [Test]
    procedure TheTypesThatWereMissingAreRegistered;

    [Test]
    procedure AnOffsetTypeIsStillRefused;

    [Test]
    procedure ADescendantOfARegisteredFieldResolves;
  end;

{ TTDataParametersTests }

  [TestFixture]
  TTDataParametersTests = class
  public
    [Test]
    procedure StringFieldTypeConvertsAnyValue;

    [Test]
    procedure IntegerFieldTypeConvertsDecimalText;

    [Test]
    procedure IntegerFieldTypeRejectsNonNumericText;

    [Test]
    procedure LargeIntegerFieldTypeConvertsBeyondInt32;

    [Test]
    procedure FloatFieldTypeUsesInvariantDecimalSeparator;

    [Test]
    procedure CurrencyFieldTypeProducesCurrencyValue;

    [Test]
    procedure FloatFieldTypeProducesDoubleValue;

    [Test]
    procedure BooleanFieldTypeAcceptsTextAndDigits;

    [Test]
    procedure BooleanFieldTypeRejectsOtherText;

    [Test]
    procedure DateTimeFieldTypeConvertsIso8601UtcToLocal;

    [Test]
    procedure DateTimeFieldTypeReadsTextWithoutZoneAsLocal;

    [Test]
    procedure DateTimeFieldTypeRejectsLocalizedText;

    [Test]
    procedure GuidFieldTypeConvertsBracedForm;

    [Test]
    procedure GuidFieldTypeRejectsNonGuidText;

    [Test]
    procedure BlobFieldTypeHasNoStringConversion;

    [Test]
    procedure UnregisteredFieldTypeReturnsFalse;

    [Test]
    procedure FailedConversionLeavesResultEmpty;
  end;

implementation

{ TTDataParametersTests }

procedure TTDataParametersTests.StringFieldTypeConvertsAnyValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftString, 'O''Brien', LValue));
  Assert.AreEqual('O''Brien', LValue.AsType<String>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftWideMemo, String.Empty, LValue));
  Assert.AreEqual(String.Empty, LValue.AsType<String>());
end;

procedure TTDataParametersTests.IntegerFieldTypeConvertsDecimalText;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '42', LValue));
  Assert.AreEqual<Integer>(42, LValue.AsType<Integer>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftSmallint, '-7', LValue));
  Assert.AreEqual<Integer>(-7, LValue.AsType<Integer>());
end;

procedure TTDataParametersTests.IntegerFieldTypeRejectsNonNumericText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '42abc', LValue));

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '4.2', LValue));
end;

procedure TTDataParametersTests.LargeIntegerFieldTypeConvertsBeyondInt32;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftLargeint, '3000000000', LValue));
  Assert.AreEqual<Int64>(3000000000, LValue.AsType<Int64>());

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, '3000000000', LValue));
end;

procedure TTDataParametersTests.FloatFieldTypeUsesInvariantDecimalSeparator;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, '1234.56', LValue));
  Assert.AreEqual(1234.56, LValue.AsType<Double>(), 0.0001);

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, 'abc', LValue));
end;

procedure TTDataParametersTests.CurrencyFieldTypeProducesCurrencyValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftCurrency, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Currency),
    'ftCurrency must produce a Currency value, not a Double');
  Assert.AreEqual(19.99, Double(LValue.AsType<Currency>()), 0.0001);
end;

procedure TTDataParametersTests.FloatFieldTypeProducesDoubleValue;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftFloat, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Double),
    'ftFloat must produce a Double value');

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBCD, '19.99', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(Double),
    'ftBCD must produce a Double value');
end;

procedure TTDataParametersTests.BooleanFieldTypeAcceptsTextAndDigits;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'TRUE', LValue));
  Assert.IsTrue(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '1', LValue));
  Assert.IsTrue(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'False', LValue));
  Assert.IsFalse(LValue.AsType<Boolean>());

  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '0', LValue));
  Assert.IsFalse(LValue.AsType<Boolean>());
end;

procedure TTDataParametersTests.BooleanFieldTypeRejectsOtherText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, 'yes', LValue));

  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBoolean, '2', LValue));
end;

procedure TTDataParametersTests.DateTimeFieldTypeConvertsIso8601UtcToLocal;
var
  LValue: TTValue;
  LExpected: TDateTime;
begin
  LExpected := EncodeDateTime(2026, 8, 28, 10, 30, 0, 0);
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDateTime, '2026-08-28T10:30:00.000Z', LValue));
  Assert.AreEqual(
    Double(LExpected),
    Double(TTimeZone.Local.ToUniversalTime(LValue.AsType<TDateTime>())),
    1 / SecsPerDay);
end;

procedure TTDataParametersTests.DateTimeFieldTypeReadsTextWithoutZoneAsLocal;
var
  LValue: TTValue;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDate, '2026-03-05', LValue));
  Assert.AreEqual(
    Double(EncodeDate(2026, 3, 5)),
    Double(LValue.AsType<TDateTime>()),
    1 / SecsPerDay,
    'The RTL overload with a Boolean takes a text without a time zone as '
    + 'UTC, and the value was then moved to local time: on a server at '
    + 'UTC+1 a filter on 2026-03-05 asked for one in the morning, and on a '
    + 'DATE column it found nothing. 1.0.0 put the text into the statement '
    + 'and the database read the date as written. On a machine at UTC this '
    + 'assertion cannot tell the two apart');
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDateTime, '2026-03-05T10:30:00', LValue));
  Assert.AreEqual(
    Double(EncodeDateTime(2026, 3, 5, 10, 30, 0, 0)),
    Double(LValue.AsType<TDateTime>()),
    1 / SecsPerDay,
    'and a timestamp without a zone is the local time it says');
end;

procedure TTDataParametersTests.DateTimeFieldTypeRejectsLocalizedText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftDateTime, '28/08/2026 10:30', LValue));
end;

procedure TTDataParametersTests.GuidFieldTypeConvertsBracedForm;
var
  LValue: TTValue;
  LGuid: TGuid;
begin
  Assert.IsTrue(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftGuid, '{2C3F5A81-9D4E-4B27-8A6C-1E0F7B3D5A99}', LValue));
  Assert.IsTrue(
    LValue.TypeInfo = TypeInfo(TGuid),
    'ftGuid must produce a TGuid value');

  LGuid := LValue.AsType<TGuid>();
  Assert.AreEqual('{2C3F5A81-9D4E-4B27-8A6C-1E0F7B3D5A99}', LGuid.ToString);
end;

procedure TTDataParametersTests.GuidFieldTypeRejectsNonGuidText;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftGuid, 'not-a-guid', LValue));
end;

procedure TTDataParametersTests.BlobFieldTypeHasNoStringConversion;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBlob, 'anything', LValue));
end;

procedure TTDataParametersTests.UnregisteredFieldTypeReturnsFalse;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftBytes, 'anything', LValue));
end;

procedure TTDataParametersTests.FailedConversionLeavesResultEmpty;
var
  LValue: TTValue;
begin
  Assert.IsFalse(TTParameterFactory.Instance.TryValueFromString(
    TFieldType.ftInteger, 'abc', LValue));
  Assert.IsTrue(LValue.IsEmpty, 'A failed conversion must clear the result');
end;

{ TTDatabaseObjectNameTests }

procedure
  TTDatabaseObjectNameTests.AQuotedNameResolvesWhatAnUnquotedOneResolved;
begin
  Assert.AreEqual(
    '"customers"',
    TTDatabaseObjectName.Quoted('Customers', '"', '"', TTNameCase.Lower),
    'PostgreSQL folds an unquoted name to lower case, so a table created ' +
    'as Customers is customers: quoting it without folding first would ' +
    'ask for an object that does not exist, and every application on the ' +
    'engine would stop working');
  Assert.AreEqual(
    '"CUSTOMERS"',
    TTDatabaseObjectName.Quoted('Customers', '"', '"', TTNameCase.Upper),
    'And Oracle, Firebird and InterBase fold the other way');
end;

procedure TTDatabaseObjectNameTests.ANameKeepsItsCaseWhereTheEngineDoesNotFold;
begin
  Assert.AreEqual(
    '[Customers]',
    TTDatabaseObjectName.Quoted('Customers', '[', ']', TTNameCase.AsIs),
    'SQL Server stores the name as written and compares it by collation');
  Assert.AreEqual(
    '`Customers`',
    TTDatabaseObjectName.Quoted('Customers', '`', '`', TTNameCase.AsIs),
    'MariaDB takes backticks, and folding would break it on Linux, where ' +
    'table names are case sensitive by default');
end;

procedure TTDatabaseObjectNameTests.TheClosingQuoteInsideANameIsDoubled;
begin
  Assert.AreEqual(
    '"a""b"',
    TTDatabaseObjectName.Quoted('a"b', '"', '"', TTNameCase.AsIs),
    'A closing quote inside the name would end the identifier early, and ' +
    'what follows it would be read as SQL');
  Assert.AreEqual(
    '[a]]b]',
    TTDatabaseObjectName.Quoted('a]b', '[', ']', TTNameCase.AsIs),
    'And the same for the bracket form');
end;

procedure TTDatabaseObjectNameTests.AQualifiedNameIsQuotedPartByPart;
begin
  Assert.AreEqual(
    '[dbo].[MyFunction]',
    TTDatabaseObjectName.Quoted(
      'dbo.MyFunction', '[', ']', TTNameCase.AsIs),
    'A schema qualified name is what people write on SQL Server, and ' +
    'quoting it whole would ask for an object literally called ' +
    'dbo.MyFunction in the default schema');
  Assert.AreEqual(
    '"public"."customers"',
    TTDatabaseObjectName.Quoted(
      'public.Customers', '"', '"', TTNameCase.Lower),
    'And each part is folded on its own, as the engine folds them');
end;

procedure TTDatabaseObjectNameTests.AnEmptyNameStaysEmpty;
begin
  Assert.AreEqual(
    String.Empty,
    TTDatabaseObjectName.Quoted(String.Empty, '"', '"', TTNameCase.Upper),
    'An empty name is a name nobody asked for: quoting it would put an ' +
    'empty identifier in the statement instead of leaving it out');
end;

procedure
  TTDatabaseObjectNameTests.TheFoldingDoesNotFollowTheLocaleOfTheMachine;
var
  LSysLocale: TSysLocale;
begin
  LSysLocale := SysLocale;
  try
    SysLocale.DefaultLCID := TurkishLCID;
    Assert.AreNotEqual(
      'id',
      String('ID').ToLower,
      'Under a Turkish locale the linguistic lower case of I is not i but ' +
      'the dotless one, which is the whole reason this test exists: if ' +
      'this assertion fails the premise is gone, not the fix');
    Assert.AreEqual(
      '"id"',
      TTDatabaseObjectName.Quoted('ID', '"', '"', TTNameCase.Lower),
      'PostgreSQL folds to lower case, and the name that has to reach it ' +
      'is the one the engine resolved, not the one the language of the ' +
      'machine would produce');
    Assert.AreEqual(
      '"CODICEID"',
      TTDatabaseObjectName.Quoted('CodiceID', '"', '"', TTNameCase.Upper),
      'And the same the other way for Oracle, Firebird and InterBase');
  finally
    SysLocale := LSysLocale;
  end;
end;

procedure
  TTDatabaseObjectNameTests.TwoNamesAreTheSameWhateverTheLocaleOfTheMachine;
var
  LSysLocale: TSysLocale;
begin
  LSysLocale := SysLocale;
  try
    SysLocale.DefaultLCID := TurkishLCID;
    Assert.IsTrue(
      TTIdentifier.Same('ID', 'id'),
      'The metadata of PostgreSQL come back in lower case and the entity ' +
      'maps them in upper: a comparison that follows the language of the ' +
      'machine stops matching them, and the column is not found');
    Assert.IsFalse(
      TTIdentifier.Same('ID', 'IDX'),
      'And two different names stay different');
  finally
    SysLocale := LSysLocale;
  end;
end;

procedure TTDatabaseObjectNameTests.TheComparerHashesWhatItCompares;
var
  LSysLocale: TSysLocale;
  LComparer: IEqualityComparer<String>;
begin
  LComparer := TTIdentifier.Comparer;
  LSysLocale := SysLocale;
  try
    SysLocale.DefaultLCID := TurkishLCID;

    Assert.IsTrue(
      LComparer.Equals('ID', 'id'),
      'The dictionaries keyed on this comparer hold identifiers - a column ' +
      'name, a header name - so two spellings of one name are one key');
    Assert.AreEqual<Integer>(
      LComparer.GetHashCode('ID'),
      LComparer.GetHashCode('id'),
      'and the hash has to agree with the comparison, or the two spellings ' +
      'never meet in one bucket and Equals is never asked. This is the ' +
      'contract a dictionary needs, and it is what the comparer is here to ' +
      'guarantee: it folds with ToUpperInvariant on both sides, so no ' +
      'machine setting can move it. The Turkish locale is set on purpose: ' +
      'ToUpper without an argument reads SysLocale.DefaultLCID and folds ' +
      'id to the dotted capital I, so a hash that slipped back to it goes ' +
      'red here, where without the locale the two folds agree. Note what ' +
      'this test does NOT prove: ' +
      'TIStringComparer.Ordinal, which it replaced, passes these two ' +
      'assertions as well. Its Ansi primitives do not show the Turkish I ' +
      'for an ASCII identifier on Windows - measured, not assumed. The ' +
      'substitution is right because the dependency should not be there at ' +
      'all, not because this case breaks without it');
    Assert.IsFalse(
      LComparer.Equals('ID', 'IDX'),
      'and two different names stay two keys');
  finally
    SysLocale := LSysLocale;
  end;
end;

{ TTFieldTypeRegistryTests }

function TTFieldTypeRegistryTests.TypeIsRegistered(
  const AFieldType: TFieldType): Boolean;
var
  LParameter: TTParameter;
begin
  result := True;
  LParameter := nil;
  try
    LParameter := TTParameterFactory.Instance.CreateParameter(
      'test', AFieldType, nil);
  except
    on E: ETException do
      result := False;
  end;
  if Assigned(LParameter) then
    LParameter.Free;
end;

procedure TTFieldTypeRegistryTests.TheTypesThatWereMissingAreRegistered;
begin
  Assert.IsTrue(
    TypeIsRegistered(TFieldType.ftTime),
    'A TIME column is refused on five engines out of seven when the ' +
    'registry does not know the type, and the refusal arrives at the ' +
    'first access rather than at start-up');
  Assert.IsTrue(
    TypeIsRegistered(TFieldType.ftWord),
    'And so are the unsigned integers MariaDB hands out');
  Assert.IsTrue(
    TypeIsRegistered(TFieldType.ftLongWord),
    'An unsigned 32 bit reaches 4294967295, which does not fit an Int32: ' +
    'it is registered on the large integer, because binding it as an ' +
    'Integer would overflow in silence, which is worse than the error');
  Assert.IsTrue(
    TypeIsRegistered(TFieldType.ftVarBytes),
    'And VARBINARY and RAW are binary like a blob');
end;

procedure TTFieldTypeRegistryTests.AnOffsetTypeIsStillRefused;
begin
  Assert.IsFalse(
    TypeIsRegistered(TFieldType.ftTimeStampOffset),
    'Left out on purpose: it carries an offset from UTC that none of the ' +
    'supported member types can hold, so registering it would drop the ' +
    'zone in silence. The clear refusal is the better answer until there ' +
    'is a type that keeps the value whole');
end;

procedure TTFieldTypeRegistryTests.ADescendantOfARegisteredFieldResolves;
begin
  Assert.IsTrue(
    Assigned(TTColumnFactory.Instance.FindColumnClass(TGraphicField)),
    'The read side looked the field up by its exact class, so a class ' +
    'that descends from a registered one - TGraphicField from TBlobField ' +
    '- was refused all the same, and so would be any field class a ' +
    'driver introduces');
end;

initialization
  TDUnitX.RegisterTestFixture(TTFieldTypeRegistryTests);
  TDUnitX.RegisterTestFixture(TTDatabaseObjectNameTests);
  TDUnitX.RegisterTestFixture(TTDataParametersTests);

end.
