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
    FDeserializers: TDictionary<PTypeInfo, TTJSonDeserializerClass>;

    procedure RegisterBaseTypes;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    function Get(const ATypeInfo: PTypeInfo): TTJSonDeserializerClass;
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

{ TTJSonLargeIntegerDeserializer }

function TTJSonLargeIntegerDeserializer.FromJSon(
  const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<Int64>(AJSon.GetValue<Int64>());
end;

{ TTJSonDoubleDeserializer }

function TTJSonDoubleDeserializer.FromJSon(const AJSon: TJSonValue): TTValue;
begin
  result := TTValue.From<Double>(AJSon.GetValue<Double>());
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
end;

constructor TTJSonDeserializers.Create;
begin
  inherited Create;
  FDeserializers := TDictionary<PTypeInfo, TTJSonDeserializerClass>.Create;
end;

destructor TTJSonDeserializers.Destroy;
begin
  FDeserializers.Free;
  inherited Destroy;
end;

procedure TTJSonDeserializers.AfterConstruction;
begin
  inherited AfterConstruction;
  RegisterBaseTypes;
end;

function TTJSonDeserializers.Get(
  const ATypeInfo: PTypeInfo): TTJSonDeserializerClass;
begin
  if not FDeserializers.TryGetValue(ATypeInfo, result) then
    raise ETJSonException.CreateFmt(
      SDeserializerNotFound, [String(ATypeInfo.Name)]);
end;

procedure TTJSonDeserializers.Register<T>(
  const AClass: TTJSonDeserializerClass);
begin
  FDeserializers.Add(TypeInfo(T), AClass);
end;

procedure TTJSonDeserializers.RegisterBaseTypes;
begin
  Self.Register<String>(TTJSonStringDeserializer);

  Self.Register<Int16>(TTJSonIntegerDeserializer);
  Self.Register<Int32>(TTJSonIntegerDeserializer);
  Self.Register<Int64>(TTJSonLargeIntegerDeserializer);

  Self.Register<Double>(TTJSonDoubleDeserializer);
  Self.Register<Extended>(TTJSonDoubleDeserializer);
  Self.Register<Currency>(TTJSonDoubleDeserializer);

  Self.Register<Boolean>(TTJSonBooleanDeserializer);

  Self.Register<TDateTime>(TTJSonDateTimeDeserializer);
  Self.Register<TDate>(TTJSonDateTimeDeserializer);
  Self.Register<TTime>(TTJSonDateTimeDeserializer);

  Self.Register<TGuid>(TTJSonGuidDeserializer);

  Self.Register<TBytes>(TTJSonBlobDeserializer);
end;

end.
