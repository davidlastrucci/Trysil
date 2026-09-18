(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.JSon.Values;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.TypInfo,
  Data.DB,
  Data.FmtBcd,
  DUnitX.TestFramework,

  FireDAC.Comp.Client,

  Trysil.Consts,
  Trysil.Rtti,
  Trysil.JSon.Consts,
  Trysil.JSon.Types,
  Trysil.JSon.Dataset,
  Trysil.JSon.Sqids,
  Trysil.JSon.Serializer.Classes,
  Trysil.JSon.Exceptions,
  Trysil.JSon.Deserializer.Classes,
  Trysil.JSon.Deserializer,

  Trysil.Tests.Model;

type

{ TTJSonValuesTests }

  [TestFixture]
  TTJSonValuesTests = class
  strict private
    FJSon: TJSonObject;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure AMissingStringIsNotAnError;

    [Test]
    procedure AStringThatIsAnObjectIsInvalid;

    [Test]
    procedure ANullStringIsMissing;

    [Test]
    procedure AMissingIntegerIsNotAnError;

    [Test]
    procedure AnIntegerThatIsAnObjectIsInvalid;

    [Test]
    procedure AnIntegerThatIsNotANumberIsInvalid;

    [Test]
    procedure AMissingArrayIsNotAnError;

    [Test]
    procedure AnArrayThatIsAnObjectIsInvalid;

    [Test]
    procedure AnArrayIsRead;

    [Test]
    procedure AMissingSerializerIsTheServersFault;
  end;

{ TTJSonDatasetNumberTests }

  [TestFixture]
  TTJSonDatasetNumberTests = class
  strict private
    function ExactColumnToJSon(const AValue: String): String;
    function CurrencyColumnToJSon(const AValue: Currency): String;
  public
    [Test]
    procedure ADecimalPastTheDoublePrecisionKeepsEveryDigit;

    [Test]
    procedure AnExactDecimalIsStillAJSonNumber;

    [Test]
    procedure AnExactNumberIgnoresTheSeparatorOfTheMachine;

    [Test]
    procedure AnExactNumberStillConvertsToDoubleAndString;

    [Test]
    procedure ACurrencyColumnIsWrittenThroughItsOwnBranch;
  end;

{ TTJSonDatasetDateTests }

  [TestFixture]
  TTJSonDatasetDateTests = class
  strict private
    function CreateColumn(
      const ADataType: TFieldType;
      const AValue: TDateTime): TFDMemTable;
    function ColumnToJSon(
      const ADataType: TFieldType;
      const AValue: TDateTime): String;
    function ColumnToDateTime(
      const ADataType: TFieldType;
      const AValue: TDateTime): TDateTime;
  public
    [Test]
    procedure ADateAndATimeLeaveTheDatasetWithoutATimeZone;

    [Test]
    procedure ADateAndATimeStillConvertToTDateTime;
  end;

{ TTestFaultDeserializer }

  TTestFaultDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonDeserializerFaultTests }

  [TestFixture]
  TTJSonDeserializerFaultTests = class
  strict private
    class function Describe(const AException: Exception): String; static;
    function Deserialize(
      const AJSon: TJSonObject; const AEntity: TObject): String;
    function FaultOf(const AValue: String): String;
  public
    [Test]
    procedure OnlyAConversionIsTheCallersFault;
  end;

{ TTJSonSqidsTests }

  [TestFixture]
  TTJSonSqidsTests = class
  strict private
    function AlphabetRefusal(const AValue: String): String;
  public
    [Test]
    procedure TheAlphabetIsCheckedForShapeAndThenClosed;
  end;

{ TTJSonSmallIntTests }

  [TestFixture]
  TTJSonSmallIntTests = class
  strict private
    function FromJSon(const AValue: Integer): Int16;
  public
    [Test]
    procedure AValueOutsideTheRangeIsRefused;
  end;

{ TTJSonLargeIntegerTests }

  [TestFixture]
  TTJSonLargeIntegerTests = class
  strict private
    function FromJSon(const AJSon: TJSonValue): Int64;
  public
    [Test]
    procedure ANumberIsRead;

    [Test]
    procedure AQuotedNumberIsRead;

    [Test]
    procedure AValueAboveTheDoubleRangeKeepsEveryDigit;
  end;

implementation

{ TTJSonValuesTests }

procedure TTJSonValuesTests.Setup;
begin
  FJSon := TJSonObject.Create;
  FJSon.AddPair('name', 'Trysil');
  FJSon.AddPair('start', TJSonNumber.Create(10));
  FJSon.AddPair('object', TJSonObject.Create);
  FJSon.AddPair('array', TJSonArray.Create);
  FJSon.AddPair('nothing', TJSonNull.Create);
end;

procedure TTJSonValuesTests.TearDown;
begin
  FJSon.Free;
end;

procedure TTJSonValuesTests.AMissingStringIsNotAnError;
var
  LValue: String;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Missing,
    TTJSonValues.GetString(FJSon, 'absent', LValue),
    'A field nobody sent is not a mistake: the caller falls back to its ' +
    'own default');
end;

procedure TTJSonValuesTests.AStringThatIsAnObjectIsInvalid;
var
  LValue: String;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Invalid,
    TTJSonValues.GetString(FJSon, 'object', LValue),
    'The RTL overload with a default raised on Delphi 11 and returned the ' +
    'default on Delphi 13, so the same body was a 500 on one version and a ' +
    'silent no-op on the other');
end;

procedure TTJSonValuesTests.ANullStringIsMissing;
var
  LValue: String;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Missing,
    TTJSonValues.GetString(FJSon, 'nothing', LValue),
    'An explicit null says the same thing as an absent field');
end;

procedure TTJSonValuesTests.AMissingIntegerIsNotAnError;
var
  LValue: Integer;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Missing,
    TTJSonValues.GetInteger(FJSon, 'absent', LValue));
end;

procedure TTJSonValuesTests.AnIntegerThatIsAnObjectIsInvalid;
var
  LValue: Integer;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Invalid,
    TTJSonValues.GetInteger(FJSon, 'object', LValue));
end;

procedure TTJSonValuesTests.AnIntegerThatIsNotANumberIsInvalid;
var
  LValue: Integer;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Invalid,
    TTJSonValues.GetInteger(FJSon, 'name', LValue),
    'A word where a number goes is refused, not read as zero');
end;

procedure TTJSonValuesTests.AMissingArrayIsNotAnError;
var
  LValue: TJSonArray;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Missing,
    TTJSonValues.GetArray(FJSon, 'absent', LValue));
  Assert.IsFalse(Assigned(LValue));
end;

procedure TTJSonValuesTests.AnArrayThatIsAnObjectIsInvalid;
var
  LValue: TJSonArray;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Invalid,
    TTJSonValues.GetArray(FJSon, 'object', LValue),
    'This is the dangerous one: a "where" that is not an array used to ' +
    'become no filter at all, and the endpoint answered with the whole ' +
    'table');
end;

procedure TTJSonValuesTests.AnArrayIsRead;
var
  LValue: TJSonArray;
begin
  Assert.AreEqual<TTJSonValueState>(
    TTJSonValueState.Valid, TTJSonValues.GetArray(FJSon, 'array', LValue));
  Assert.IsTrue(Assigned(LValue));
end;

procedure TTJSonValuesTests.AMissingSerializerIsTheServersFault;
var
  LServerFault: Boolean;
  LStillAJSonFailure: Boolean;
begin
  LServerFault := False;
  LStillAJSonFailure := False;

  try
    TTJSonSerializers.Instance.GetInstance(TypeInfo(TStringList));
  except
    on E: ETJSonServerException do
      LServerFault := True;
  end;

  try
    TTJSonSerializers.Instance.GetInstance(TypeInfo(TStringList));
  except
    on E: ETJSonException do
      LStillAJSonFailure := True;
  end;

  Assert.IsTrue(
    LServerFault,
    'A serializer the host never registered for a member of its own model '
    + 'is a deployment fault, and the listener used to answer the client '
    + '400 for it: the caller was told its request was wrong for something '
    + 'it had no part in. It raises ETJSonServerException now, which the '
    + 'listener answers 500');
  Assert.IsTrue(
    LStillAJSonFailure,
    'and it still derives from ETJSonException, so an application that '
    + 'catches the base keeps catching it: the split adds a branch, it '
    + 'does not move anything out of reach');
end;

{ TTJSonSmallIntTests }

function TTJSonSmallIntTests.FromJSon(const AValue: Integer): Int16;
var
  LDeserializer: TTJSonAbstractDeserializer;
  LJSon: TJSonNumber;
begin
  LDeserializer := TTJSonDeserializers.Instance.GetInstance(TypeInfo(Int16));
  LJSon := TJSonNumber.Create(AValue);
  try
    result := LDeserializer.FromJSon(LJSon).AsType<Int16>();
  finally
    LJSon.Free;
  end;
end;

procedure TTJSonSmallIntTests.AValueOutsideTheRangeIsRefused;
var
  LRefused: Boolean;
begin
  LRefused := False;
  try
    FromJSon(70000);
  except
    on E: ERangeError do
      LRefused := True;
  end;

  Assert.IsTrue(
    LRefused,
    'Int16 was registered on the deserializer of Integer, and TValue.Cast '
    + 'copies an integer into a narrower one without a range check: 70000 '
    + 'was stored as 4464 and the request answered 200. ERangeError is one '
    + 'of the classes the deserializer turns into a 400 naming the field');
  Assert.AreEqual<Int16>(
    High(Int16),
    FromJSon(High(Int16)),
    'and the bounds are still read');
  Assert.AreEqual<Int16>(Low(Int16), FromJSon(Low(Int16)));
end;

{ TTJSonLargeIntegerTests }

function TTJSonLargeIntegerTests.FromJSon(const AJSon: TJSonValue): Int64;
var
  LDeserializer: TTJSonAbstractDeserializer;
begin
  LDeserializer := TTJSonDeserializers.Instance.GetInstance(TypeInfo(Int64));
  try
    result := LDeserializer.FromJSon(AJSon).AsType<Int64>();
  finally
    AJSon.Free;
  end;
end;

procedure TTJSonLargeIntegerTests.ANumberIsRead;
begin
  Assert.AreEqual<Int64>(42, FromJSon(TJSonNumber.Create(42)));
end;

procedure TTJSonLargeIntegerTests.AQuotedNumberIsRead;
begin
  Assert.AreEqual<Int64>(
    42,
    FromJSon(TJSonString.Create('42')),
    'JavaScript cannot hold a whole number above 2^53, so a client that ' +
    'has one has to send it quoted. Currency already accepted that form ' +
    'and Int64 did not');
end;

procedure TTJSonLargeIntegerTests.AValueAboveTheDoubleRangeKeepsEveryDigit;
begin
  Assert.AreEqual<Int64>(
    9007199254740993,
    FromJSon(TJSonString.Create('9007199254740993')),
    'And the digit that a Double cannot represent survives the trip');
end;

function TTJSonDatasetNumberTests.ExactColumnToJSon(
  const AValue: String): String;
var
  LTable: TFDMemTable;
  LFieldDef: TFieldDef;
begin
  LTable := TFDMemTable.Create(nil);
  try
    LFieldDef := LTable.FieldDefs.AddFieldDef;
    LFieldDef.Name := 'Total';
    LFieldDef.DataType := TFieldType.ftFMTBcd;
    LFieldDef.Precision := 38;
    LFieldDef.Size := 4;
    LTable.CreateDataSet;
    LTable.Append;
    LTable.FieldByName('Total').AsBCD :=
      StrToBcd(AValue, TFormatSettings.Invariant);
    LTable.Post;

    result := LTable.ToJSon;
  finally
    LTable.Free;
  end;
end;

function TTJSonDatasetNumberTests.CurrencyColumnToJSon(
  const AValue: Currency): String;
var
  LTable: TFDMemTable;
  LFieldDef: TFieldDef;
begin
  LTable := TFDMemTable.Create(nil);
  try
    LFieldDef := LTable.FieldDefs.AddFieldDef;
    LFieldDef.Name := 'Amount';
    LFieldDef.DataType := TFieldType.ftCurrency;
    LTable.CreateDataSet;
    LTable.Append;
    LTable.FieldByName('Amount').AsCurrency := AValue;
    LTable.Post;

    result := LTable.ToJSon;
  finally
    LTable.Free;
  end;
end;

procedure
  TTJSonDatasetNumberTests.ADecimalPastTheDoublePrecisionKeepsEveryDigit;
const
  Value = '12345678901234567890';
begin
  Assert.IsTrue(
    ExactColumnToJSon(Value).Contains(Value),
    'A decimal column - which is what a SUM(CAST(x AS DECIMAL)) comes back '
    + 'as - shared the branch of ftFloat and went out through AsFloat, so '
    + 'past the precision of a Double the total that reached the client '
    + 'was rounded and nothing said so. The value is inside the range of '
    + 'a Double and past its exactness, which ends at 2^53');
end;

procedure TTJSonDatasetNumberTests.AnExactDecimalIsStillAJSonNumber;
const
  Value = '12345678901234567890';
begin
  Assert.IsFalse(
    ExactColumnToJSon(Value).Contains(Format('"%s"', [Value])),
    'The exact literal is written through TJSonNumber, which keeps the '
    + 'digits it is given and emits them unquoted, so the payload keeps '
    + 'the type it had: correcting the digits is not a change of contract');
end;

procedure
  TTJSonDatasetNumberTests.AnExactNumberIgnoresTheSeparatorOfTheMachine;
var
  LSettings: TFormatSettings;
  LDecimal: String;
  LCurrency: String;
begin
  LSettings := FormatSettings;
  try
    FormatSettings.DecimalSeparator := ',';
    FormatSettings.ThousandSeparator := '.';
    LDecimal := ExactColumnToJSon('1234567890123.25');
    LCurrency := CurrencyColumnToJSon(1234.5);
  finally
    FormatSettings := LSettings;
  end;

  Assert.IsTrue(
    LDecimal.Contains('1234567890123.25'),
    'A JSON number has a point, whatever the machine writes: the exact '
    + 'decimal is formatted with TFormatSettings.Invariant, and with the '
    + 'separator of the machine the literal would not even be a number');
  Assert.IsTrue(
    LCurrency.Contains('1234.5'),
    'and so is a Currency column, which has a branch of its own');
end;

procedure TTJSonDatasetNumberTests.AnExactNumberStillConvertsToDoubleAndString;
var
  LTable: TFDMemTable;
  LFieldDef: TFieldDef;
  LValue: TTJSonValue;
  LDouble: Double;
  LString: String;
begin
  LTable := TFDMemTable.Create(nil);
  try
    LFieldDef := LTable.FieldDefs.AddFieldDef;
    LFieldDef.Name := 'Total';
    LFieldDef.DataType := TFieldType.ftFMTBcd;
    LFieldDef.Precision := 18;
    LFieldDef.Size := 4;
    LTable.CreateDataSet;
    LTable.Append;
    LTable.FieldByName('Total').AsBCD :=
      StrToBcd('1234.5', TFormatSettings.Invariant);
    LTable.Post;

    LValue := TTJSonValue.Create(LTable.FieldByName('Total'));
    LDouble := LValue;
    LString := LValue;
  finally
    LTable.Free;
  end;

  Assert.AreEqual<Double>(
    1234.5,
    LDouble,
    'TTJSonValue is public, and in 1.0.0 a decimal column converted to '
    + 'Double. The exact literal kept for DatasetToJSon is a type of its '
    + 'own, and the conversion checked for Double alone, so a host that '
    + 'read a total through the record got an exception it never had');
  Assert.AreEqual(
    '1234.5',
    LString,
    'and the conversion to String hands back the exact literal');
end;

procedure TTJSonDatasetNumberTests.ACurrencyColumnIsWrittenThroughItsOwnBranch;
const
  Value = '123456789012.3456';
var
  LJSon: String;
begin
  LJSon := CurrencyColumnToJSon(StrToCurr(Value, TFormatSettings.Invariant));

  Assert.IsTrue(
    LJSon.Contains(Value),
    'ftCurrency has a branch of its own and goes out through CurrToStr. In '
    + 'the branch of ftFloat it would go out through a Double, which JSON '
    + 'writes with fifteen significant digits: 123456789012.346. The test '
    + 'on the separator stays green on both paths, because 1234.5 reads the '
    + 'same on each');
end;

{ TTJSonDatasetDateTests }

function TTJSonDatasetDateTests.CreateColumn(
  const ADataType: TFieldType;
  const AValue: TDateTime): TFDMemTable;
var
  LFieldDef: TFieldDef;
begin
  result := TFDMemTable.Create(nil);
  try
    LFieldDef := result.FieldDefs.AddFieldDef;
    LFieldDef.Name := 'When';
    LFieldDef.DataType := ADataType;
    result.CreateDataSet;
    result.Append;
    result.FieldByName('When').AsDateTime := AValue;
    result.Post;
  except
    result.Free;
    raise;
  end;
end;

function TTJSonDatasetDateTests.ColumnToJSon(
  const ADataType: TFieldType;
  const AValue: TDateTime): String;
var
  LTable: TFDMemTable;
begin
  LTable := CreateColumn(ADataType, AValue);
  try
    result := LTable.ToJSon;
  finally
    LTable.Free;
  end;
end;

function TTJSonDatasetDateTests.ColumnToDateTime(
  const ADataType: TFieldType;
  const AValue: TDateTime): TDateTime;
var
  LTable: TFDMemTable;
  LValue: TTJSonValue;
begin
  LTable := CreateColumn(ADataType, AValue);
  try
    LValue := TTJSonValue.Create(LTable.FieldByName('When'));
    result := LValue;
  finally
    LTable.Free;
  end;
end;

procedure
  TTJSonDatasetDateTests.ADateAndATimeLeaveTheDatasetWithoutATimeZone;
var
  LSettings: TFormatSettings;
  LDate: String;
  LTime: String;
begin
  LSettings := FormatSettings;
  try
    FormatSettings.TimeSeparator := '.';
    LDate := ColumnToJSon(TFieldType.ftDate, EncodeDate(2026, 3, 5));
    LTime := ColumnToJSon(TFieldType.ftTime, EncodeTime(10, 30, 0, 0));
  finally
    FormatSettings := LSettings;
  end;

  Assert.IsTrue(
    LDate.Contains('"2026-03-05"'),
    'A DATE read through CreateDataset shared the branch of DATETIME and '
    + 'was converted to UTC: on a server east of Greenwich it went out as '
    + 'the evening of the day before, and on the hour a clock skips it '
    + 'raised and failed the whole report with a 500. The entity path '
    + 'writes the date alone, and so does the dataset path now');
  Assert.IsTrue(
    LTime.Contains('"10:30:00"'),
    'and a TIME is the time alone, not a day of 1899 moved by the time '
    + 'zone, written with the invariant separator like the entity path');
end;

procedure TTJSonDatasetDateTests.ADateAndATimeStillConvertToTDateTime;
begin
  Assert.AreEqual<TDateTime>(
    EncodeDate(2026, 3, 5),
    ColumnToDateTime(TFieldType.ftDate, EncodeDate(2026, 3, 5)),
    'TTJSonValue is public, and in 1.0.0 a DATE column converted to '
    + 'TDateTime. The date and the time got value types of their own for '
    + 'DatasetToJSon, and a conversion that checked for the timestamp alone '
    + 'would raise on them: the correction that stopped the day before '
    + 'must not cost a host that reads the record');
  Assert.AreEqual<TDateTime>(
    EncodeTime(10, 30, 0, 0),
    ColumnToDateTime(TFieldType.ftTime, EncodeTime(10, 30, 0, 0)),
    'and a TIME converts the same way');
end;

{ TTestFaultDeserializer }

function TTestFaultDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  if AJSon.Value = 'server' then
    raise ETJSonServerException.Create('A fault of the server')
  else
    raise EConvertError.Create('A value the host could not read');
end;

{ TTJSonDeserializerFaultTests }

class function TTJSonDeserializerFaultTests.Describe(
  const AException: Exception): String;
begin
  result := Format('%s: %s', [AException.ClassName, AException.Message]);
  if Assigned(AException.InnerException) then
    result := Format(
      '%s <- %s', [result, AException.InnerException.ClassName]);
end;

function TTJSonDeserializerFaultTests.Deserialize(
  const AJSon: TJSonObject; const AEntity: TObject): String;
var
  LDeserializer: TTJSonDeserializer;
begin
  result := String.Empty;
  LDeserializer := TTJSonDeserializer.Create;
  try
    try
      LDeserializer.EntityFromJSon(AJSon, AEntity);
    except
      on E: Exception do
        result := Describe(E);
    end;
  finally
    LDeserializer.Free;
  end;
end;

function TTJSonDeserializerFaultTests.FaultOf(const AValue: String): String;
var
  LJSon: TJSonObject;
  LEntity: TTestFaultyEntity;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('fault', AValue);
    LEntity := TTestFaultyEntity.Create;
    try
      result := Deserialize(LJSon, LEntity);
    finally
      LEntity.Free;
    end;
  finally
    LJSon.Free;
  end;
end;

procedure TTJSonDeserializerFaultTests.OnlyAConversionIsTheCallersFault;
var
  LClientFault: String;
begin
  LClientFault := FaultOf('client');

  Assert.AreEqual(
    'ETJSonServerException: A fault of the server',
    FaultOf('server'),
    'The deserializer turns eight exception classes into ETJSonException, '
    + 'which the listener answers 400, and lets every other one through. '
    + 'No test raised anything outside the eight inside FromJSon, so '
    + 'turning every exception into a 400 left the suite green. A fault of '
    + 'the server raised by a deserializer keeps its class and its message, '
    + 'and stays a 500');
  Assert.IsTrue(
    LClientFault.StartsWith('ETJSonException: '),
    'An EConvertError raised by a deserializer of the host is one of the '
    + 'eight: the value could not be read, and the caller hears it as a 400');
  Assert.IsTrue(
    LClientFault.Contains('"fault"'),
    'and the message names the member by its JSON name');
  Assert.IsTrue(
    LClientFault.EndsWith(' <- EConvertError'),
    'and it keeps the exception behind it. The eight classes come from the '
    + 'value in the deserializers of the framework, but a deserializer of '
    + 'the host can raise one out of a defect, and the 400 used to carry '
    + 'nothing of it: the listener writes the inner exception into the log '
    + 'line of the 400. The fault of the server above carries none');
end;

function TTJSonSqidsTests.AlphabetRefusal(const AValue: String): String;
begin
  result := String.Empty;
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  try
    TTJSonSqids.Instance.Alphabet := AValue;
  except
    on E: ETJSonException do
      result := E.Message;
  end;
{$ENDIF}
end;

procedure TTJSonSqidsTests.TheAlphabetIsCheckedForShapeAndThenClosed;
{$IF CompilerVersion >= 36} // Delphi 12 Athens
var
  LInUse: String;
  LWasUsingSqids: Boolean;
  LJSon: TJSonValue;
{$ENDIF}
begin
{$IF CompilerVersion >= 36} // Delphi 12 Athens
  LInUse := TTLanguage.Instance.Translate(SSqidsAlphabetInUse);

  Assert.IsFalse(
    AlphabetRefusal('abcd').IsEmpty,
    'The alphabet has three ways of being refused and none of them had a '
    + 'test, on a property this release declares as configurable API. '
    + 'Four characters is below the floor of five');
  Assert.AreNotEqual(
    LInUse,
    AlphabetRefusal('abcd'),
    'and it is refused for its shape. Another fixture may have encoded an '
    + 'id first, which closes the alphabet: then every value is refused, '
    + 'and a test that only asked whether it was refused stayed green with '
    + 'the shape check gone');
  Assert.IsFalse(
    AlphabetRefusal('abcda').IsEmpty,
    'A repeated character is refused too: an alphabet that repeats maps '
    + 'two different ids onto one string');
  Assert.AreNotEqual(
    LInUse,
    AlphabetRefusal('abcda'),
    'and again for its shape');
  Assert.AreEqual(
    Format(TTLanguage.Instance.Translate(SSqidsAlphabetNotLowerCase), ['E']),
    AlphabetRefusal('abcdE'),
    'A capital letter is refused: every id is lower-cased on its way out '
    + 'and on its way in, and with a capital in the alphabet the fold turns '
    + 'an id into another string of the same alphabet, which decodes to '
    + 'another number. The default alphabet of the RTL has capitals');
  Assert.AreEqual(
    Format(
      TTLanguage.Instance.Translate(SSqidsAlphabetNotLowerCase), [#$00E8]),
    AlphabetRefusal('abcd'#$00E8),
    'and so is a character outside ASCII, which TSqidsEncoding refuses '
    + 'too, but at the first encode of a request instead of at startup');

  LWasUsingSqids := TTJSonSqids.Instance.UseSqids;
  try
    TTJSonSqids.Instance.UseSqids := True;
    LJSon := TTJSonSqids.Instance.Encode(1);
    LJSon.Free;
  finally
    TTJSonSqids.Instance.UseSqids := LWasUsingSqids;
  end;

  Assert.AreEqual(
    LInUse,
    AlphabetRefusal('abcdefghij'),
    'Once an id has been encoded the alphabet is closed: changing it '
    + 'then would invalidate every id already handed out, so it raises '
    + 'instead. This assertion is why the encode above is here, and it is '
    + 'also the reason this test leaves the encoding built for the rest '
    + 'of the process - harmless, because nothing else configures it, and '
    + 'because Encode and Decode read UseSqids before they read it');
{$ELSE}
  Assert.Pass(
    'TTJSonSqids.Alphabet is declared under {$IF CompilerVersion >= 36}, '
    + 'like the rest of the class: TSqidsEncoding is an RTL 12 type');
{$ENDIF}
end;

initialization
  TTJSonDeserializers.Instance.Register<TTestFaultValue>(
    TTestFaultDeserializer);
  TDUnitX.RegisterTestFixture(TTJSonValuesTests);
  TDUnitX.RegisterTestFixture(TTJSonSqidsTests);
  TDUnitX.RegisterTestFixture(TTJSonDatasetNumberTests);
  TDUnitX.RegisterTestFixture(TTJSonDatasetDateTests);
  TDUnitX.RegisterTestFixture(TTJSonDeserializerFaultTests);
  TDUnitX.RegisterTestFixture(TTJSonSmallIntTests);
  TDUnitX.RegisterTestFixture(TTJSonLargeIntegerTests);

end.
