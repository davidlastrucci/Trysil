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
  System.Generics.Collections,
  System.TypInfo,
  System.Rtti,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Factory,
  Trysil.Sync,
  Trysil.Rtti,
  Trysil.Events.Abstract;

type

{ TTEventRegistry }

  TTEventRegistry = class
  strict private
    class var FInstance: TTEventRegistry;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FLock: TTMultiReadExclusiveWriteLock;
    FEvents: TDictionary<PTypeInfo, TTEventClass>;

    function ParentTypeInfo(const ATypeInfo: PTypeInfo): PTypeInfo;
    function SearchEvents(const AEntityTypeInfo: PTypeInfo): TTEventClass;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterEvents(
      const AEntityTypeInfo: PTypeInfo; const AEventClass: TTEventClass);
    function GetEvents(const AEntityTypeInfo: PTypeInfo): TTEventClass;

    class property Instance: TTEventRegistry read FInstance;
  end;

{ TTEventFactory }

  TTEventFactory = class
  strict private
    class var FInstance: TTEventFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FLock: TTMultiReadExclusiveWriteLock;
    FContext: TRttiContext;
    FMethods: TDictionary<PTypeInfo, TRttiMethod>;

    function GetMethod(
      const AEventClassInfo: Pointer; out AMethod: TRttiMethod): Boolean;
    function InternalSearchMethod(
      const ARttiType: TRttiType;
      const AContext: TObject;
      const AEntity: TObject): TRttiMethod;
    function SearchMethod(
      const AEventClassInfo: Pointer;
      const AContext: TObject;
      const AEntity: TObject): TRttiMethod;
    function GetOrSearchMethod<T: class>(
      const AEventClassInfo: Pointer;
      const AContext: TObject;
      const AEntity: T): TRttiMethod;
    function ResolveEventClass(
      const AEventClass: TTEventClass;
      const AEntityTypeInfo: PTypeInfo): TTEventClass;
    function InternalCreateEvent<T: class>(
      const AEventClass: TTEventClass;
      const AOperation: TTEventOperation;
      const AContext: TObject;
      const AEntity: T): TTEvent;
  public
    constructor Create;
    destructor Destroy; override;

    function CreateEvent<T: class>(
      const AEventClass: TTEventClass;
      const AOperation: TTEventOperation;
      const AContext: TObject;
      const AEntity: T): TTEvent;

    class property Instance: TTEventFactory read FInstance;
  end;

implementation

{ TTEventRegistry }

class constructor TTEventRegistry.ClassCreate;
begin
  FInstance := TTEventRegistry.Create;
end;

class destructor TTEventRegistry.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTEventRegistry.Create;
begin
  inherited Create;
  FLock := TTMultiReadExclusiveWriteLock.Create;
  FEvents := TDictionary<PTypeInfo, TTEventClass>.Create;
end;

destructor TTEventRegistry.Destroy;
begin
  FEvents.Free;
  FLock.Free;
  inherited Destroy;
end;

procedure TTEventRegistry.RegisterEvents(
  const AEntityTypeInfo: PTypeInfo; const AEventClass: TTEventClass);
begin
  if not Assigned(AEventClass) then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SEventClassNotAssigned), [
        GetTypeName(AEntityTypeInfo)]);

  FLock.BeginWrite;
  try
    if FEvents.ContainsKey(AEntityTypeInfo) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SEventsAlreadyRegistered), [
          GetTypeName(AEntityTypeInfo)]);

    FEvents.Add(AEntityTypeInfo, AEventClass);
  finally
    FLock.EndWrite;
  end;
end;

function TTEventRegistry.ParentTypeInfo(
  const ATypeInfo: PTypeInfo): PTypeInfo;
var
  LParentInfo: PPTypeInfo;
begin
  result := nil;
  if ATypeInfo.Kind = tkClass then
  begin
    LParentInfo := GetTypeData(ATypeInfo).ParentInfo;
    if Assigned(LParentInfo) then
      result := LParentInfo^;
  end;
end;

function TTEventRegistry.SearchEvents(
  const AEntityTypeInfo: PTypeInfo): TTEventClass;
var
  LTypeInfo: PTypeInfo;
begin
  result := nil;
  LTypeInfo := AEntityTypeInfo;
  while Assigned(LTypeInfo) and not Assigned(result) do
  begin
    if not FEvents.TryGetValue(LTypeInfo, result) then
      result := nil;
    LTypeInfo := ParentTypeInfo(LTypeInfo);
  end;
end;

function TTEventRegistry.GetEvents(
  const AEntityTypeInfo: PTypeInfo): TTEventClass;
begin
  FLock.BeginRead;
  try
    result := SearchEvents(AEntityTypeInfo);
  finally
    FLock.EndRead;
  end;
end;

{ TTEventFactory }

class constructor TTEventFactory.ClassCreate;
begin
  FInstance := TTEventFactory.Create;
end;

class destructor TTEventFactory.ClassDestroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

constructor TTEventFactory.Create;
begin
  inherited Create;
  FLock := TTMultiReadExclusiveWriteLock.Create;
  FContext := TRttiContext.Create;
  FMethods := TDictionary<PTypeInfo, TRttiMethod>.Create;
end;

destructor TTEventFactory.Destroy;
begin
  FMethods.Free;
  FContext.Free;
  FLock.Free;
  inherited Destroy;
end;

function TTEventFactory.GetMethod(
  const AEventClassInfo: Pointer; out AMethod: TRttiMethod): Boolean;
begin
  FLock.BeginRead;
  try
    result := FMethods.TryGetValue(AEventClassInfo, AMethod);
  finally
    FLock.EndRead;
  end;
end;

function TTEventFactory.InternalSearchMethod(
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
      LIsValid := Length(LParameters) = 3;
      if LIsValid then
        LIsValid :=
          TTRtti.InheritsFrom(AContext, LParameters[0].ParamType) and
          TTRtti.InheritsFrom(AEntity, LParameters[1].ParamType) and
          (LParameters[2].ParamType.Handle = TypeInfo(TTEventOperation));

      if LIsValid then
      begin
        result := LRttiMethod;
        Break;
      end;
    end;
end;

function TTEventFactory.SearchMethod(
  const AEventClassInfo: Pointer;
  const AContext: TObject;
  const AEntity: TObject): TRttiMethod;
var
  LRttiType: TRttiType;
begin
  FLock.BeginWrite;
  try
    if not FMethods.TryGetValue(AEventClassInfo, result) then
    begin
      LRttiType := FContext.GetType(TTFactory.Instance.GetType(AEventClassInfo));
      result := InternalSearchMethod(LRttiType, AContext, AEntity);
      if Assigned(result) then
        FMethods.Add(AEventClassInfo, result);
    end;
  finally
    FLock.EndWrite;
  end;
end;

function TTEventFactory.GetOrSearchMethod<T>(
  const AEventClassInfo: Pointer;
  const AContext: TObject;
  const AEntity: T): TRttiMethod;
begin
  if not GetMethod(AEventClassInfo, result) then
    result := SearchMethod(AEventClassInfo, AContext, AEntity);
end;

function TTEventFactory.ResolveEventClass(
  const AEventClass: TTEventClass;
  const AEntityTypeInfo: PTypeInfo): TTEventClass;
var
  LRegistered: TTEventClass;
begin
  result := AEventClass;
  LRegistered := TTEventRegistry.Instance.GetEvents(AEntityTypeInfo);
  if Assigned(LRegistered) then
  begin
    if Assigned(AEventClass) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SEventsAttributeAndRegistration), [
          GetTypeName(AEntityTypeInfo)]);

    result := LRegistered;
  end;
end;

function TTEventFactory.InternalCreateEvent<T>(
  const AEventClass: TTEventClass;
  const AOperation: TTEventOperation;
  const AContext: TObject;
  const AEntity: T): TTEvent;
var
  LEventClassInfo: Pointer;
  LRttiMethod: TRttiMethod;
  LParams: TArray<TValue>;
  LResult: TValue;
begin
  LEventClassInfo := AEventClass.ClassInfo;
  LRttiMethod := GetOrSearchMethod<T>(LEventClassInfo, AContext, AEntity);

  if not Assigned(LRttiMethod) then
    raise ETException.CreateFmt(
      TTLanguage.Instance.Translate(SNotValidEventClass), [
        AEventClass.ClassName]);

  SetLength(LParams, 3);
  LParams[0] := TValue.From<TObject>(AContext);
  LParams[1] := TValue.From<TObject>(AEntity);
  LParams[2] := TValue.From<TTEventOperation>(AOperation);

  LResult := LRttiMethod.Invoke(AEventClass, LParams);
  try
    if not LResult.IsType<TTEvent>(False) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SNotEventType), [AEventClass.ClassName]);
    result := LResult.AsType<TTEvent>(False);
  except
    LResult.AsObject.Free;
    raise;
  end;
end;

function TTEventFactory.CreateEvent<T>(
  const AEventClass: TTEventClass;
  const AOperation: TTEventOperation;
  const AContext: TObject;
  const AEntity: T): TTEvent;
var
  LEventClass: TTEventClass;
begin
  result := nil;
  LEventClass := ResolveEventClass(AEventClass, TypeInfo(T));
  if Assigned(LEventClass) then
    result := InternalCreateEvent<T>(
      LEventClass, AOperation, AContext, AEntity);
end;

end.
