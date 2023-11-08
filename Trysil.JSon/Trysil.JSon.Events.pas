(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  Http://codenames.info/operation/orm/

*)
unit Trysil.JSon.Events;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,

  Trysil.JSon.Exceptions;

type

{ TTJSonEvent }

  TTJSonEvent = class abstract
  public
    procedure DoAfterSerialized(const AJSon: TJSonObject); virtual;
    procedure DoAfterDeserialized(const AJSon: TJSonValue); virtual;
  end;

{ TTJSonEvent<T> }

  TTJSonEvent<T: class> = class(TTJSonEvent)
  strict private
    FEntity: T;
  strict protected
    property Entity: T read FEntity;
  public
    constructor Create(const AEntity: T);
  end;

{ TTJSonEventData }

  TTJSonEventData = record
  strict private
    FRttyType: TRttiType;
    FRttiMethod: TRttiMethod;
  public
    constructor Create(
      const ARttyType: TRttiType; const ARttiMethod: TRttiMethod);

    property RttyType: TRttiType read FRttyType;
    property RttiMethod: TRttiMethod read FRttiMethod;
  end;

{ TTJSonEventFactory }

  TTJSonEventFactory = class
  strict private
    class var FInstance: TTJSonEventFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FContext: TRttiContext;
    FEvents: TDictionary<PTypeInfo, TTJSonEventData>;

    function SearchMethod(
      const AEvent: TRttiType; const AEntity: PTypeInfo): TRttiMethod;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateEvent(const AEntity: TObject): TTJSonEvent;

    procedure RegisterEvent<T: class; E: TTJSonEvent<T>>();

    class property Instance: TTJSonEventFactory read FInstance;
  end;

resourcestring
  SNotValidEventClass = 'Not valid constructor in TTJSonEvent class.';
  SNotEventType = 'Not valid TTJSonEvent type.';

implementation

{ TTJSonEvent }

procedure TTJSonEvent.DoAfterSerialized(const AJSon: TJSonObject);
begin
  // Do nothing
end;

procedure TTJSonEvent.DoAfterDeserialized(const AJSon: TJSonValue);
begin
  // Do nothing
end;

{ TTJSonEvent<T> }

constructor TTJSonEvent<T>.Create(const AEntity: T);
begin
  inherited Create;
  FEntity := AEntity;
end;

{ TTJSonEventData }

constructor TTJSonEventData.Create(
  const ARttyType: TRttiType; const ARttiMethod: TRttiMethod);
begin
  FRttyType := ARttyType;
  FRttiMethod := ARttiMethod;
end;

{ TTJSonEventFactory }

class constructor TTJSonEventFactory.ClassCreate;
begin
  FInstance := TTJSonEventFactory.Create;
end;

class destructor TTJSonEventFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTJSonEventFactory.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
  FEvents := TDictionary<PTypeInfo, TTJSonEventData>.Create;
end;

destructor TTJSonEventFactory.Destroy;
begin
  FEvents.Free;
  FContext.Free;
  inherited Destroy;
end;

function TTJSonEventFactory.SearchMethod(
  const AEvent: TRttiType; const AEntity: PTypeInfo): TRttiMethod;
var
  LRttiMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LIsValid: Boolean;
begin
  result := nil;
  for LRttiMethod in AEvent.GetMethods do
    if LRttiMethod.IsConstructor then
    begin
      LParameters := LRttiMethod.GetParameters;
      LIsValid := Length(LParameters) = 1;
      if LIsValid then
        LIsValid := (LParameters[0].ParamType.Handle = AEntity);

      if LIsValid then
      begin
        result := LRttiMethod;
        Break;
      end;
    end;
end;

function TTJSonEventFactory.CreateEvent(const AEntity: TObject): TTJSonEvent;
var
  LEventData: TTJSonEventData;
  LParams: TArray<TValue>;
  LResult: TValue;
begin
  result := nil;
  if FEvents.TryGetValue(AEntity.ClassInfo, LEventData) then
  begin
    SetLength(LParams, 1);
    LParams[0] := TValue.From<TObject>(AEntity);
    LResult := LEventData.RttiMethod.Invoke(
      LEventData.RttyType.AsInstance.MetaclassType, LParams);
    try
      if not LResult.IsType<TTJSonEvent>(False) then
        raise ETJSonException.Create(SNotEventType);
      result := LResult.AsType<TTJSonEvent>(False);
    except
      LResult.AsObject.Free;
      raise;
    end;
  end;
end;

procedure TTJSonEventFactory.RegisterEvent<T, E>();
var
  LEvent: TRttiType;
  LEntity: PTypeInfo;
  LRttiMethod: TRttiMethod;
begin
  LEvent := FContext.GetType(TypeInfo(E));
  LEntity := TypeInfo(T);
  LRttiMethod := SearchMethod(LEvent, LEntity);
  if not Assigned(LRttiMethod) then
    raise ETJSonException.Create(SNotValidEventClass);
  FEvents.Add(LEntity, TTJSonEventData.Create(LEvent, LRttiMethod));
end;

end.
