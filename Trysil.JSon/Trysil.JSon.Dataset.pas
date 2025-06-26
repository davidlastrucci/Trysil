(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Dataset;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.JSon,
  System.NetEncoding,
  System.DateUtils,
  System.Rtti,
  Data.DB,

  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions;

type

{ TTJSonDateTime }

  TTJSonDateTime = record
  strict private
    const JSonFormat: String = '%4d-%.2d-%.2dT%.2d:%.2d:%.2d.%.3dZ';
  strict private
    FYear: Word;
    FMonth: Word;
    FDay: Word;
    FHour: Word;
    FMinute: Word;
    FSecond: Word;
    FMillisecond: Word;

    function FormatDateTime: String;
  public
    constructor Create(const AValue: String); overload;
    constructor Create(const AValue: TDateTime); overload;

    function ToJSonValue: TJSonValue;

    class operator Implicit(const AValue: String): TTJSonDateTime;
    class operator Implicit(const AValue: TTJSonDateTime): String;
    class operator Implicit(const AValue: TDateTime): TTJSonDateTime;
    class operator Implicit(const AValue: TTJSonDateTime): TDateTime;

    property Year: Word read FYear;
    property Month: Word read FMonth;
    property Day: Word read FDay;
    property Hour: Word read FHour;
    property Minute: Word read FMinute;
    property Second: Word read FSecond;
    property Millisecond: Word read FMillisecond;
  end;

{ TTJSonValue }

  TTJSonValue = record
  strict private
    type TTJSonValueType = (
      jvtString, jvtInteger, jvtDouble, jvtBoolean, jvtDateTime);
  strict private
    FType: TTJSonValueType;
    FValue: TValue;

    class procedure CheckValueType(
      const AValueType: TTJSonValueType;
      const AType: TTJSonValueType); static;
  public
    constructor Create(const AValue: String); overload;
    constructor Create(const AValue: Integer); overload;
    constructor Create(const AValue: Double); overload;
    constructor Create(const AValue: Boolean); overload;
    constructor Create(const AValue: TDateTime); overload;
    constructor Create(const AField: TField); overload;

    class operator Implicit(const AValue: String): TTJSonValue;
    class operator Implicit(const AValue: TTJSonValue): String;
    class operator Implicit(const AValue: Integer): TTJSonValue;
    class operator Implicit(const AValue: TTJSonValue): Integer;
    class operator Implicit(const AValue: Double): TTJSonValue;
    class operator Implicit(const AValue: TTJSonValue): Double;
    class operator Implicit(const AValue: Boolean): TTJSonValue;
    class operator Implicit(const AValue: TTJSonValue): Boolean;
    class operator Implicit(const AValue: TDateTime): TTJSonValue;
    class operator Implicit(const AValue: TTJSonValue): TDateTime;
    class operator Implicit(const AField: TField): TTJSonValue;

    function ToJSonValue: TJSonValue;
  end;

{ TTJSonDatasetHelper }

  TTJSonDatasetHelper = class helper for TDataset
  strict private
    procedure DatasetToJSonArray(const AArray: TJSonArray);
    procedure RecordToJSonObject(const AObject: TJSonObject);
    function FieldToJSonValue(const AField: TField): TJSonValue;
    function BlobFieldToJSonValue(const AField: TBlobField): TJSonValue;
  public
    function ToJSon: String;
    procedure ToJSonArray(const AArray: TJSonArray);
    procedure RecordToJSon(const AObject: TJSonObject);
  end;

implementation

{ TTJSonDateTime }

constructor TTJSonDateTime.Create(const AValue: String);
var
  LValue: TJSonValue;
begin
  LValue := TJSonString.Create(AValue);
  try
    Create(LValue.GetValue<TDateTime>());
  finally
    LValue.Free;
  end;
end;

constructor TTJSonDateTime.Create(const AValue: TDateTime);
begin
  DecodeDate(AValue, FYear, FMonth, FDay);
  DecodeTime(AValue, FHour, FMinute, FSecond, FMillisecond);
end;

function TTJSonDateTime.FormatDateTime: String;
var
  LDate: TDateTime;
  LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond: Word;
begin
  LDate := EncodeDateTime(
    FYear, FMonth, FDay, FHour, FMinute, FSecond, FMillisecond);
  LDate := TTimeZone.Local.ToUniversalTime(LDate);
  DecodeDateTime(
    LDate, LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond);
  result := Format(JSonFormat, [
    LYear, LMonth, LDay, LHour, LMinute, LSecond, LMillisecond]);
end;

class operator TTJSonDateTime.Implicit(const AValue: TTJSonDateTime): String;
begin
  result := AValue.FormatDateTime;
end;

class operator TTJSonDateTime.Implicit(const AValue: String): TTJSonDateTime;
begin
  result := TTJSonDateTime.Create(AValue);
end;

class operator TTJSonDateTime.Implicit(const AValue: TTJSonDateTime): TDateTime;
begin
  result := EncodeDateTime(
    AValue.FYear, AValue.FMonth, AValue.FDay,
    AValue.FHour, AValue.FMinute, AValue.FSecond, AValue.FMillisecond);
end;

class operator TTJSonDateTime.Implicit(const AValue: TDateTime): TTJSonDateTime;
begin
  result := TTJSonDateTime.Create(AValue);
end;

function TTJSonDateTime.ToJSonValue: TJSonValue;
begin
  result := TJSonString.Create(FormatDateTime);
end;

{ TTJSonValue }

constructor TTJSonValue.Create(const AValue: String);
begin
  FType := TTJSonValueType.jvtString;
  FValue := AValue;
end;

constructor TTJSonValue.Create(const AValue: Integer);
begin
  FType := TTJSonValueType.jvtInteger;
  FValue := AValue;
end;

constructor TTJSonValue.Create(const AValue: Double);
begin
  FType := TTJSonValueType.jvtDouble;
  FValue := AValue;
end;

constructor TTJSonValue.Create(const AValue: Boolean);
begin
  FType := TTJSonValueType.jvtBoolean;
  FValue := AValue;
end;

constructor TTJSonValue.Create(const AValue: TDateTime);
begin
  FType := TTJSonValueType.jvtDateTime;
  FValue := AValue;
end;

constructor TTJSonValue.Create(const AField: TField);
begin
  case AField.DataType of
    ftString,
    ftWideString,
    ftMemo,
    ftWideMemo:
    begin
      FType := TTJSonValueType.jvtString;
      FValue := AField.AsString;
    end;

    ftSmallint,
    ftInteger,
    ftWord:
    begin
      FType := TTJSonValueType.jvtInteger;
      FValue := AField.AsInteger;
    end;

    ftFloat,
    ftCurrency,
    ftBCD:
    begin
      FType := TTJSonValueType.jvtDouble;
      FValue := AField.AsFloat;
    end;

    ftBoolean:
    begin
      FType := TTJSonValueType.jvtBoolean;
      FValue := AField.AsBoolean;
    end;

    ftDate,
    ftTime,
    ftDateTime,
    ftTimeStamp:
    begin
      FType := TTJSonValueType.jvtDateTime;
      FValue := AField.AsDateTime;
    end;

    else
      raise ETJSonException.Create(SNotValidType);
  end;
end;

class procedure TTJSonValue.CheckValueType(
  const AValueType: TTJSonValueType; const AType: TTJSonValueType);
begin
  if AValueType <> AType then
    raise ETJSonException.Create(SNotValidType);
end;

class operator TTJSonValue.Implicit(const AValue: String): TTJSonValue;
begin
    result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): String;
begin
  CheckValueType(AValue.FType, TTJSonValueType.jvtString);
  result := AValue.FValue.AsType<String>();
end;

class operator TTJSonValue.Implicit(const AValue: Integer): TTJSonValue;
begin
  result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): Integer;
begin
  CheckValueType(AValue.FType, TTJSonValueType.jvtInteger);
  result := AValue.FValue.AsType<Integer>;
end;

class operator TTJSonValue.Implicit(const AValue: Double): TTJSonValue;
begin
  result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): Double;
begin
  CheckValueType(AValue.FType, TTJSonValueType.jvtDouble);
  result := AValue.FValue.AsType<Double>;
end;

class operator TTJSonValue.Implicit(const AValue: Boolean): TTJSonValue;
begin
  result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): Boolean;
begin
  CheckValueType(AValue.FType, TTJSonValueType.jvtBoolean);
  result := AValue.FValue.AsType<Boolean>;
end;

class operator TTJSonValue.Implicit(const AValue: TDateTime): TTJSonValue;
begin
  result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): TDateTime;
begin
  CheckValueType(AValue.FType, TTJSonValueType.jvtDateTime);
  result := AValue.FValue.AsType<TDateTime>;
end;

class operator TTJSonValue.Implicit(const AField: TField): TTJSonValue;
begin
  result := TTJSonValue.Create(AField);
end;

function TTJSonValue.ToJSonValue: TJSonValue;
begin
  case FType of
    TTJSonValueType.jvtString:
      result := TJSonString.Create(
        TNetEncoding.HTML.Encode(FValue.AsType<String>()));

    TTJSonValueType.jvtInteger:
      result := TJSonNumber.Create(FValue.AsType<Integer>());

    TTJSonValueType.jvtDouble:
      result := TJSonNumber.Create(FValue.AsType<Double>());

    TTJSonValueType.jvtBoolean:
      result := TJSonBool.Create(FValue.AsType<Boolean>());

    TTJSonValueType.jvtDateTime:
      result := TTJSonDateTime.Create(
        FValue.AsType<TDateTime>()).ToJSonValue();

  else
    raise ETJSonException.Create(SNotValidType);
  end;
end;

{ TTJSonDatasetHelper }

function TTJSonDatasetHelper.ToJSon: String;
var
  LResult: TJSonArray;
begin
  LResult := TJSonArray.Create;
  try
    ToJSonArray(LResult);
    result := LResult.ToJSon();
  finally
    LResult.Free;
  end;
end;

procedure TTJSonDatasetHelper.ToJSonArray(const AArray: TJSonArray);
var
  LActive: Boolean;
begin
  LActive := Self.Active;
  if not LActive then
    Self.Open;
  try
    DatasetToJSonArray(AArray);
  finally
    if not LActive then
      Self.Close;
  end;
end;

procedure TTJSonDatasetHelper.RecordToJSon(const AObject: TJSonObject);
begin
  RecordToJSonObject(AObject);
end;

procedure TTJSonDatasetHelper.DatasetToJSonArray(const AArray: TJSonArray);
var
  LObject: TJSonObject;
begin
  Self.First;
  while not Self.Eof do
  begin
    LObject := TJSonObject.Create;
    try
      RecordToJsonObject(LObject);
      AArray.AddElement(LObject);
    except
      LObject.Free;
      raise;
    end;
    Self.Next;
  end;
end;

procedure TTJSonDatasetHelper.RecordToJSonObject(const AObject: TJSonObject);
var
  LIndex: Integer;
  LField: TField;
begin
  for LIndex := 0 to Self.Fields.Count - 1 do
  begin
    LField := Self.Fields[LIndex];
    if LField.Visible then
      AObject.AddPair(LField.FieldName, FieldToJSonValue(LField));
  end;
end;

function TTJSonDatasetHelper.FieldToJSonValue(
  const AField: TField): TJSonValue;
var
  LValue: TTJSonValue;
begin
  if AField.IsNull then
    result := TJSonNull.Create
  else if AField.DataType = ftBlob then
    result := BlobFieldToJSonValue(TBlobField(AField))
  else
  begin
    LValue := AField;
    result := LValue.ToJSonValue;
  end;
end;

function TTJSonDatasetHelper.BlobFieldToJSonValue(
  const AField: TBlobField): TJSonValue;
var
  LStream: TMemoryStream;
  LBytes: TBytes;
begin
  LStream := TMemoryStream.Create;
  try
    AField.SaveToStream(LStream);
    LStream.Position := 0;
    SetLength(LBytes, LStream.Size);
    LStream.Read(LBytes, LStream.Size);

    result := TJSonString.Create(
      TNetEncoding.Base64.EncodeBytesToString(LBytes));
  finally
    LStream.Free;
  end;
end;

end.

