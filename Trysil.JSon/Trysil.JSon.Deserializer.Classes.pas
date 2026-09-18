(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Deserializer.Classes;

interface

uses
  System.SysUtils,
  System.SysConst,
  System.Classes,
  System.Generics.Collections,
  System.JSon,
  System.DateUtils,
  System.TypInfo,
  System.NetEncoding,
  Trysil.Consts,
  Trysil.Rtti,

  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions;

type

{ TTJSonAbstractDeserializer }

  TTJSonAbstractDeserializer = class
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; virtual; abstract;
  end;

{ TTJSonDeserializerClass }

  TTJSonDeserializerClass = class of TTJSonAbstractDeserializer;

{ TTJSonStringDeserializer }

  TTJSonStringDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonIntegerDeserializer }

  TTJSonIntegerDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonSmallIntDeserializer }

  TTJSonSmallIntDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonLargeIntegerDeserializer }

  TTJSonLargeIntegerDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonDoubleDeserializer }

  TTJSonDoubleDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonCurrencyDeserializer }

  TTJSonCurrencyDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonBooleanDeserializer }

  TTJSonBooleanDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonDateTimeDeserializer }

  TTJSonDateTimeDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonDateDeserializer }

  TTJSonDateDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonTimeDeserializer }

  TTJSonTimeDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonGuidDeserializer }

  TTJSonGuidDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonBlobDeserializer }

  TTJSonBlobDeserializer = class(TTJSonAbstractDeserializer)
  public
    function FromJSon(const AJSon: TJSonValue): TTValue; override;
  end;

{ TTJSonDeserializers }

  TTJSonDeserializers = class
  strict private
    class var FInstance: TTJSonDeserializers;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FInstances: TObjectDictionary<PTypeInfo, TTJSonAbstractDeserializer>;

    procedure RegisterBaseTypes;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function GetInstance(
      const ATypeInfo: PTypeInfo): TTJSonAbstractDeserializer;
    procedure Register<T>(const AClass: TTJSonDeserializerClass);

    class property Instance: TTJSonDeserializers read FInstance;
  end;

implementation

{ TTJSonStringDeserializer }

function TTJSonStringDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<String>(AJSon.GetValue<String>());
end;

{ TTJSonIntegerDeserializer }

function TTJSonIntegerDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<Integer>(AJSon.GetValue<Integer>());
end;

{ TTJSonSmallIntDeserializer }

function TTJSonSmallIntDeserializer.FromJSon(
  const AJSon: TJSonValue): TTValue;
var
  LValue: Integer;
begin
  LValue := AJSon.GetValue<Integer>();
  if (LValue < Low(Int16)) or (LValue > High(Int16)) then
    raise ERangeError.CreateRes(@SRangeError);
  result := TTValue.From<Int16>(LValue);
end;

{ TTJSonLargeIntegerDeserializer }

function TTJSonLargeIntegerDeserializer.FromJSon(
  const AJSon: TJSonValue): TTValue;
var
  LValue: Int64;
begin
  if not TryStrToInt64(AJSon.Value, LValue) then
    LValue := AJSon.GetValue<Int64>();
  result := TTValue.From<Int64>(LValue);
end;

{ TTJSonDoubleDeserializer }

function TTJSonDoubleDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<Double>(AJSon.GetValue<Double>());
end;

{ TTJSonCurrencyDeserializer }

function TTJSonCurrencyDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
var
  LValue: Currency;
begin
  if not TryStrToCurr(AJSon.Value, LValue, TFormatSettings.Invariant) then
    LValue := AJSon.GetValue<Double>();
  result := TTValue.From<Currency>(LValue);
end;

{ TTJSonBooleanDeserializer }

function TTJSonBooleanDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<Boolean>(AJSon.GetValue<Boolean>());
end;

{ TTJSonDateTimeDeserializer }

function TTJSonDateTimeDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<TDateTime>(
    TTimeZone.Local.ToLocalTime(ISO8601ToDate(AJSon.AsType<String>(), True)));
end;

{ TTJSonDateDeserializer }

function TTJSonDateDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
var
  LValue: String;
  LDate: TDateTime;
begin
  LValue := AJSon.AsType<String>();
  if not TryStrToDate(LValue, LDate, TFormatSettings.Invariant) then
    LDate := ISO8601ToDate(LValue, True);
  result := TTValue.From<TDate>(DateOf(LDate));
end;

{ TTJSonTimeDeserializer }

function TTJSonTimeDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
var
  LValue: String;
  LTime: TDateTime;
begin
  LValue := AJSon.AsType<String>();
  if not TryStrToTime(LValue, LTime, TFormatSettings.Invariant) then
    LTime := ISO8601ToDate(LValue, True);
  result := TTValue.From<TTime>(TimeOf(LTime));
end;

{ TTJSonGuidDeserializer }

function TTJSonGuidDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<TGuid>(TGuid.Create(AJSon.AsType<String>()));
end;

{ TTJSonBlobDeserializer }

function TTJSonBlobDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<TBytes>(
    TNetEncoding.Base64.DecodeStringToBytes(AJSon.AsType<String>()));
end;

{ TTJSonDeserializers }

class constructor TTJSonDeserializers.ClassCreate;
begin
  FInstance := TTJSonDeserializers.Create;
end;

class destructor TTJSonDeserializers.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTJSonDeserializers.Create;
begin
  inherited Create;
  FInstances := TObjectDictionary<
    PTypeInfo, TTJSonAbstractDeserializer>.Create([doOwnsValues]);
end;

destructor TTJSonDeserializers.Destroy;
begin
  FInstances.Free;
  inherited Destroy;
end;

procedure TTJSonDeserializers.AfterConstruction;
begin
  inherited AfterConstruction;
  RegisterBaseTypes;
end;

procedure TTJSonDeserializers.Register<T>(
  const AClass: TTJSonDeserializerClass);
var
  LInstance: TTJSonAbstractDeserializer;
begin
  LInstance := AClass.Create;
  try
    FInstances.Add(TypeInfo(T), LInstance);
  except
    LInstance.Free;
    raise;
  end;
end;

function TTJSonDeserializers.GetInstance(
  const ATypeInfo: PTypeInfo): TTJSonAbstractDeserializer;
begin
  if not FInstances.TryGetValue(ATypeInfo, result) then
    raise ETJSonServerException.CreateFmt(
      TTLanguage.Instance.Translate(SDeserializerNotFound), [
        String(ATypeInfo.Name)]);
end;

procedure TTJSonDeserializers.RegisterBaseTypes;
begin
  Self.Register<String>(TTJSonStringDeserializer);

  Self.Register<Int16>(TTJSonSmallIntDeserializer);
  Self.Register<Int32>(TTJSonIntegerDeserializer);
  Self.Register<Int64>(TTJSonLargeIntegerDeserializer);

  Self.Register<Double>(TTJSonDoubleDeserializer);
  Self.Register<Extended>(TTJSonDoubleDeserializer);
  Self.Register<Currency>(TTJSonCurrencyDeserializer);

  Self.Register<Boolean>(TTJSonBooleanDeserializer);

  Self.Register<TDateTime>(TTJSonDateTimeDeserializer);
  Self.Register<TDate>(TTJSonDateDeserializer);
  Self.Register<TTime>(TTJSonTimeDeserializer);

  Self.Register<TGuid>(TTJSonGuidDeserializer);

  Self.Register<TBytes>(TTJSonBlobDeserializer);
end;

end.
