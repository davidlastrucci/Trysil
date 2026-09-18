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
  Data.FmtBcd,
  Trysil.Consts,

  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions;

type

{ TTJSonValue }

  TTJSonValue = record
  strict private
    type TTJSonValueType = (
      jvtString, jvtInteger, jvtLargeInt, jvtDouble, jvtExactNumber,
      jvtBoolean, jvtDateTime, jvtDate, jvtTime);
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
    function FieldNames: TArray<String>;
    procedure DatasetToJSonArray(const AArray: TJSonArray);
    procedure RecordToJSonObject(
      const AObject: TJSonObject; const ANames: TArray<String>);
    function FieldToJSonValue(const AField: TField): TJSonValue;
    function BlobFieldToJSonValue(const AField: TBlobField): TJSonValue;
  public
    function ToJSon: String;
    procedure ToJSonArray(const AArray: TJSonArray);
    procedure RecordToJSon(const AObject: TJSonObject);
  end;

implementation

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
    ftFixedChar,
    ftFixedWideChar,
    ftMemo,
    ftWideMemo,
    ftOraClob:
    begin
      FType := TTJSonValueType.jvtString;
      FValue := AField.AsString;
    end;

    ftGuid:
    begin
      FType := TTJSonValueType.jvtString;
      FValue := AField.AsString;
    end;

    ftBytes,
    ftVarBytes:
    begin
      FType := TTJSonValueType.jvtString;
      FValue := TNetEncoding.Base64.EncodeBytesToString(
        AField.AsBytes);
    end;

    ftShortint,
    ftByte,
    ftSmallint,
    ftInteger,
    ftWord:
    begin
      FType := TTJSonValueType.jvtInteger;
      FValue := AField.AsInteger;
    end;

    ftLargeint,
    ftLongWord,
    ftAutoInc:
    begin
      FType := TTJSonValueType.jvtLargeInt;
      FValue := AField.AsLargeInt;
    end;

    ftFloat,
    ftSingle,
    ftExtended:
    begin
      FType := TTJSonValueType.jvtDouble;
      FValue := AField.AsFloat;
    end;

    ftCurrency:
    begin
      FType := TTJSonValueType.jvtExactNumber;
      FValue := CurrToStr(AField.AsCurrency, TFormatSettings.Invariant);
    end;

    ftBCD,
    ftFMTBcd:
    begin
      FType := TTJSonValueType.jvtExactNumber;
      FValue := BcdToStr(AField.AsBCD, TFormatSettings.Invariant);
    end;

    ftBoolean:
    begin
      FType := TTJSonValueType.jvtBoolean;
      FValue := AField.AsBoolean;
    end;

    ftDate:
    begin
      FType := TTJSonValueType.jvtDate;
      FValue := AField.AsDateTime;
    end;

    ftTime:
    begin
      FType := TTJSonValueType.jvtTime;
      FValue := AField.AsDateTime;
    end;

    ftDateTime,
    ftTimeStamp:
    begin
      FType := TTJSonValueType.jvtDateTime;
      FValue := AField.AsDateTime;
    end;

    else
      raise ETJSonServerException.Create(
        TTLanguage.Instance.Translate(SNotValidType));
  end;
end;

class procedure TTJSonValue.CheckValueType(
  const AValueType: TTJSonValueType; const AType: TTJSonValueType);
begin
  if AValueType <> AType then
    raise ETJSonServerException.Create(
      TTLanguage.Instance.Translate(SNotValidType));
end;

class operator TTJSonValue.Implicit(const AValue: String): TTJSonValue;
begin
    result := TTJSonValue.Create(AValue);
end;

class operator TTJSonValue.Implicit(const AValue: TTJSonValue): String;
begin
  if AValue.FType <> TTJSonValueType.jvtExactNumber then
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
  if AValue.FType = TTJSonValueType.jvtExactNumber then
    result := StrToFloat(
      AValue.FValue.AsType<String>(), TFormatSettings.Invariant)
  else
  begin
    CheckValueType(AValue.FType, TTJSonValueType.jvtDouble);
    result := AValue.FValue.AsType<Double>;
  end;
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
  if not (AValue.FType in [
    TTJSonValueType.jvtDateTime,
    TTJSonValueType.jvtDate,
    TTJSonValueType.jvtTime]) then
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
      result := TJSonString.Create(FValue.AsType<String>());

    TTJSonValueType.jvtInteger:
      result := TJSonNumber.Create(FValue.AsType<Integer>());

    TTJSonValueType.jvtLargeInt:
      result := TJSonNumber.Create(FValue.AsType<Int64>());

    TTJSonValueType.jvtDouble:
      result := TJSonNumber.Create(FValue.AsType<Double>());

    TTJSonValueType.jvtExactNumber:
      result := TJSonNumber.Create(FValue.AsType<String>());

    TTJSonValueType.jvtBoolean:
      result := TJSonBool.Create(FValue.AsType<Boolean>());

    TTJSonValueType.jvtDateTime:
      result := TJSonString.Create(
        DateToISO8601(
          TTimeZone.Local.ToUniversalTime(FValue.AsType<TDateTime>()), True));

    TTJSonValueType.jvtDate:
      result := TJSonString.Create(
        FormatDateTime(
          'yyyy-mm-dd',
          FValue.AsType<TDateTime>(),
          TFormatSettings.Invariant));

    TTJSonValueType.jvtTime:
      result := TJSonString.Create(
        FormatDateTime(
          'hh:nn:ss',
          FValue.AsType<TDateTime>(),
          TFormatSettings.Invariant));
  else
    raise ETJSonServerException.Create(
      TTLanguage.Instance.Translate(SNotValidType));
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
  RecordToJSonObject(AObject, FieldNames);
end;

function TTJSonDatasetHelper.FieldNames: TArray<String>;
var
  LIndex: Integer;
begin
  SetLength(result, Self.Fields.Count);
  for LIndex := 0 to Self.Fields.Count - 1 do
    result[LIndex] := Self.Fields[LIndex].FieldName.ToLowerInvariant;
end;

procedure TTJSonDatasetHelper.DatasetToJSonArray(const AArray: TJSonArray);
var
  LObject: TJSonObject;
  LNames: TArray<String>;
begin
  LNames := FieldNames;
  Self.First;
  while not Self.Eof do
  begin
    LObject := TJSonObject.Create;
    try
      RecordToJsonObject(LObject, LNames);
      AArray.AddElement(LObject);
    except
      LObject.Free;
      raise;
    end;
    Self.Next;
  end;
end;

procedure TTJSonDatasetHelper.RecordToJSonObject(
  const AObject: TJSonObject; const ANames: TArray<String>);
var
  LIndex: Integer;
  LField: TField;
  LValue: TJSonValue;
begin
  for LIndex := 0 to Self.Fields.Count - 1 do
  begin
    LField := Self.Fields[LIndex];
    if LField.Visible then
    begin
      LValue := FieldToJSonValue(LField);
      try
        AObject.AddPair(ANames[LIndex], LValue);
      except
        LValue.Free;
        raise;
      end;
    end;
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

