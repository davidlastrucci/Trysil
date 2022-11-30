(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Events.Factory;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Factory,
  Trysil.Rtti,
  Trysil.Events.Abstract;

type

{ TTEventFactory }

  TTEventFactory = class
  strict private
    class var FInstance: TTEventFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FContext: TRttiContext;

    function SearchMethod(
      const ARttiType: TRttiType;
      const AContext: TObject;
      const AEntity: TObject): TRttiMethod;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateEvent<T: class>(
      const AEventClass: TTEventClass;
      const AContext: TObject;
      const AEntity: T): TTEvent;

    class property Instance: TTEventFactory read FInstance;
  end;

implementation

{ TTEventFactory }

class constructor TTEventFactory.ClassCreate;
begin
  FInstance := TTEventFactory.Create;
end;

class destructor TTEventFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTEventFactory.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
end;

destructor TTEventFactory.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

function TTEventFactory.SearchMethod(
  const ARttiType: TRttiType;
  const AContext: TObject;
  const AEntity: TObject): TRttiMethod;
var
  LRttiMethod: TRttiMethod;
  LParameters: TArray<TRttiParameter>;
  LIsValid: Boolean;
begin
  result := nil;
  for LRttiMethod in ARttiType.GetMethods do
    if LRttiMethod.IsConstructor then
    begin
      LParameters := LRttiMethod.GetParameters;
      LIsValid := Length(LParameters) = 2;
      if LIsValid then
        LIsValid :=
          TTRtti.InheritsFrom(AContext, LParameters[0].ParamType) and
          TTRtti.InheritsFrom(AEntity, LParameters[1].ParamType);

      if LIsValid then
      begin
        result := LRttiMethod;
        Break;
      end;
    end;
end;

function TTEventFactory.CreateEvent<T>(
  const AEventClass: TTEventClass;
  const AContext: TObject;
  const AEntity: T): TTEvent;
var
  LRttiType: TRttiType;
  LRttiMethod: TRttiMethod;
  LParams: TArray<TValue>;
  LResult: TValue;
begin
  result := nil;
  if Assigned(AEventClass) then
  begin
    LRttiType := FContext.GetType(
      TTFactory.Instance.GetType(AEventClass.ClassInfo));
    LRttiMethod := SearchMethod(LRttiType, AContext, AEntity);
    if not Assigned(LRttiMethod) then
      raise ETException.CreateFmt(SNotValidEventClass, [AEventClass.ClassName]);

    SetLength(LParams, 2);
    LParams[0] := TValue.From<TObject>(AContext);
    LParams[1] := TValue.From<TObject>(AEntity);

    LResult := LRttiMethod.Invoke(LRttiType.AsInstance.MetaclassType, LParams);
    try
      if not LResult.IsType<TTEvent>(False) then
        raise ETException.CreateFmt(SNotEventType, [AEventClass.ClassName]);
      result := LResult.AsType<TTEvent>(False);
    except
      LResult.AsObject.Free;
      raise;
    end;
  end;
end;

end.
