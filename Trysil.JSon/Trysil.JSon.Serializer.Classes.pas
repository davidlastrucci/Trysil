(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Serializer.Classes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSon,
  System.DateUtils,
  System.TypInfo,
  System.Rtti,
  System.NetEncoding,
  Trysil.Rtti,

  Trysil.JSon.Consts,
  Trysil.JSon.Exceptions;

type

{ TTJSonAbstractSerializer }

  TTJSonAbstractSerializer = class
  public
    function ToJSon(const AValue: TTValue): TJSonValue; virtual; abstract;
  end;

{ TTJSonSerializerClass }

  TTJSonSerializerClass = class of TTJSonAbstractSerializer;

{ TTJSonStringSerializer }

  TTJSonStringSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonIntegerSerializer }

  TTJSonIntegerSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonLargeIntegerSerializer }

  TTJSonLargeIntegerSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonDoubleSerializer }

  TTJSonDoubleSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonBooleanSerializer }

  TTJSonBooleanSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonDateTimeSerializer }

  TTJSonDateTimeSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonGuidSerializer }

  TTJSonGuidSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonBlobSerializer }

  TTJSonBlobSerializer = class(TTJSonAbstractSerializer)
  public
    function ToJSon(const AValue: TTValue): TJSonValue; override;
  end;

{ TTJSonSerializers }

  TTJSonSerializers = class
  strict private
    class var FInstance: TTJSonSerializers;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FSerializers: TDictionary<PTypeInfo, TTJSonSerializerClass>;

    procedure RegisterBaseTypes;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Get(const ATypeInfo: PTypeInfo): TTJSonSerializerClass;
    procedure Register<T>(const AClass: TTJSonSerializerClass);

    class property Instance: TTJSonSerializers read FInstance;
  end;

implementation

{ TTJSonStringSerializer }

function TTJSonStringSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonString.Create(AValue.AsType<String>());
end;

{ TTJSonIntegerSerializer }

function TTJSonIntegerSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  if AValue.Kind = TTypeKind.tkEnumeration then
    result := TJSonNumber.Create(AValue.AsOrdinal)
  else
    result := TJSonNumber.Create(AValue.AsType<Integer>());
end;

{ TTJSonLargeIntegerSerializer }

function TTJSonLargeIntegerSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonNumber.Create(AValue.AsType<Int64>());
end;

{ TTJSonDoubleSerializer }

function TTJSonDoubleSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonNumber.Create(AValue.AsType<Double>());
end;

{ TTJSonBooleanSerializer }

function TTJSonBooleanSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonBool.Create(AValue.AsType<Boolean>());
end;

{ TTJSonDateTimeSerializer }

function TTJSonDateTimeSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonString.Create(
    DateToISO8601(
      TTimeZone.Local.ToUniversalTime(AValue.AsType<TDateTime>()), True));
end;

{ TTJSonGuidSerializer }

function TTJSonGuidSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonString.Create(AValue.AsType<TGuid>().ToString());
end;

{ TTJSonBlobSerializer }

function TTJSonBlobSerializer.ToJSon(const AValue: TTValue): TJSonValue;
begin
  result := TJSonString.Create(
    TNetEncoding.Base64.EncodeBytesToString(AValue.AsType<TBytes>()));
end;

{ TTJSonSerializers }

class constructor TTJSonSerializers.ClassCreate;
begin
  FInstance := TTJSonSerializers.Create;
end;

class destructor TTJSonSerializers.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTJSonSerializers.Create;
begin
  inherited Create;
  FSerializers := TDictionary<PTypeInfo, TTJSonSerializerClass>.Create;
end;

destructor TTJSonSerializers.Destroy;
begin
  FSerializers.Free;
  inherited Destroy;
end;

procedure TTJSonSerializers.AfterConstruction;
begin
  inherited AfterConstruction;
  RegisterBaseTypes;
end;

function TTJSonSerializers.Get(
  const ATypeInfo: PTypeInfo): TTJSonSerializerClass;
begin
  if not FSerializers.TryGetValue(ATypeInfo, result) then
    raise ETJSonException.CreateFmt(
      SSerializerNotFound, [String(ATypeInfo.Name)]);
end;

procedure TTJSonSerializers.Register<T>(const AClass: TTJSonSerializerClass);
begin
  FSerializers.Add(TypeInfo(T), AClass);
end;

procedure TTJSonSerializers.RegisterBaseTypes;
begin
  Self.Register<String>(TTJSonStringSerializer);

  Self.Register<Int16>(TTJSonIntegerSerializer);
  Self.Register<Int32>(TTJSonIntegerSerializer);
  Self.Register<Int64>(TTJSonLargeIntegerSerializer);

  Self.Register<Double>(TTJSonDoubleSerializer);
  Self.Register<Extended>(TTJSonDoubleSerializer);
  Self.Register<Currency>(TTJSonDoubleSerializer);

  Self.Register<Boolean>(TTJSonBooleanSerializer);

  Self.Register<TDateTime>(TTJSonDateTimeSerializer);
  Self.Register<TDate>(TTJSonDateTimeSerializer);
  Self.Register<TTime>(TTJSonDateTimeSerializer);

  Self.Register<TGuid>(TTJSonGuidSerializer);

  Self.Register<TBytes>(TTJSonBlobSerializer);
end;

end.
