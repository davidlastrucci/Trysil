(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Data.Parameters;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.TypInfo,
  Data.DB,

  Trysil.Consts,
  Trysil.Data,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Logger,
  Trysil.Mapping,
  Trysil.Rtti;

type

{ TTParameter }

  TTParameter = class abstract
  strict protected
    FParam: TTParam;
    FColumnMap: TTColumnMap;
  public
    constructor Create(
      const AParam: TTParam;
      const AColumnMap: TTColumnMap);

    procedure SetValue(const AEntity: TObject); virtual; abstract;
  end;

  TTParameterClass = class of TTParameter;

{ TTStringParameter }

  TTStringParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTIntegerParameter }

  TTIntegerParameter = class(TTParameter)
  strict private
    procedure SetValueFromObject(const AObject: TObject);
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTLargeIntegerParameter }

  TTLargeIntegerParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDoubleParameter }

  TTDoubleParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTBooleanParameter }

  TTBooleanParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTDateTimeParameter }

  TTDateTimeParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTGuidParameter }

  TTGuidParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTBlobParameter }

  TTBlobParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); override;
  end;

{ TTParameterFactory }

  TTParameterFactory = class
  strict private
    class var FInstance: TTParameterFactory;
    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FParameterTypes: TDictionary<TFieldType, TClass>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterParameterClass<C: TTParameter>(
      const AFieldType: TFieldType);

    function CreateParameter(
      const AFieldType: TFieldType;
      const AParam: TTParam;
      const AColumnMap: TTColumnMap): TTParameter;

    class property Instance: TTParameterFactory read FInstance;
  end;

{ TTParameterRegister }

  TTParameterRegister = class
  public
    class procedure RegisterParameterClasses;
  end;

implementation

{ TTParameter }

constructor TTParameter.Create(
  const AParam: TTParam;
  const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FParam := AParam;
  FColumnMap := AColumnMap;
end;

{ TTStringParameter }

procedure TTStringParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<String>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<String>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsString := LNullable;
  end
  else
    FParam.AsString := LValue.AsType<String>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsString);
end;

{ TTIntegerParameter }

procedure TTIntegerParameter.SetValue(const AEntity: TObject);
var
  LIsClass: Boolean;
  LValue: TTValue;
  LNullable: TTNullable<Integer>;
begin
  LIsClass := FColumnMap.Member.IsClass;
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Integer>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsInteger := LNullable;
  end
  else if LIsClass then
    SetValueFromObject(LValue.AsObject)
  else
    FParam.AsInteger := LValue.AsType<Integer>();

  if not LIsClass then
    TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsInteger.ToString);
end;

procedure TTIntegerParameter.SetValueFromObject(const AObject: TObject);
var
  LTableMap: TTTableMap;
  LValue: TTValue;
begin
  if TTRttiLazy.IsLazy(AObject) then
    LValue := FColumnMap.Member.GetValueFromObject(AObject)
  else
  begin
    LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
    if not Assigned(LTableMap) then
      raise ETException.Create(STableMapNotFound);
    if not Assigned(LTableMap.PrimaryKey) then
      raise ETException.Create(SPrimaryKeyNotDefined);
    LValue := LTableMap.PrimaryKey.Member.GetValue(AObject);
  end;
  FParam.AsInteger := LValue.AsType<Integer>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsInteger.ToString);
end;

{ TTLargeIntegerParameter }

procedure TTLargeIntegerParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Int64>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Int64>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsLargeInt := LNullable;
  end
  else
    FParam.AsLargeInt := LValue.AsType<Int64>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsLargeInt.ToString);
end;

{ TTDoubleParameter }

procedure TTDoubleParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Double>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Double>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsDouble := LNullable;
  end
  else
    FParam.AsDouble := LValue.AsType<Double>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsDouble.ToString);
end;

{ TTBooleanParameter }

procedure TTBooleanParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Boolean>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Boolean>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsBoolean := LNullable;
  end
  else
    FParam.AsBoolean := LValue.AsType<Boolean>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsBoolean.ToString);
end;

{ TTDateTimeParameter }

procedure TTDateTimeParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TDateTime>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TDateTime>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsDateTime := LNullable;
  end
  else
    FParam.AsDateTime := LValue.AsType<TDateTime>();

  TTLogger.Instance.LogParameter(
    FColumnMap.Name, DateTimeToStr(FParam.AsDateTime));
end;

{ TTGuidParameter }

procedure TTGuidParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TGuid>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TGuid>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsGuid := LNullable;
  end
  else
    FParam.AsGuid := LValue.AsType<TGuid>();

  TTLogger.Instance.LogParameter(FColumnMap.Name, FParam.AsGuid.ToString);
end;

{ TTBlobParameter }

procedure TTBlobParameter.SetValue(const AEntity: TObject);
begin
  raise ETException.Create(SBlobParameterValue);
end;

{ TTParameterFactory }

class constructor TTParameterFactory.ClassCreate;
begin
  FInstance := TTParameterFactory.Create;
  TTParameterRegister.RegisterParameterClasses;
end;

class destructor TTParameterFactory.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTParameterFactory.Create;
begin
  inherited Create;
  FParameterTypes := TDictionary<TFieldType, TClass>.Create;
end;

destructor TTParameterFactory.Destroy;
begin
  FParameterTypes.Free;
  inherited Destroy;
end;

procedure TTParameterFactory.RegisterParameterClass<C>(
  const AFieldType: TFieldType);
begin
  FParameterTypes.Add(AFieldType, C);
end;

function TTParameterFactory.CreateParameter(
  const AFieldType: TFieldType;
  const AParam: TTParam;
  const AColumnMap: TTColumnMap): TTParameter;
var
  LClass: TClass;
begin
  if not FParameterTypes.TryGetValue(AFieldType, LClass) then
    raise ETException.CreateFmt(SParameterTypeError, [
      GetEnumName(TypeInfo(TFieldType), Ord(AFieldType))]);
  result := TTParameterClass(LClass).Create(AParam, AColumnMap);
end;

{ TTParameterRegister }

class procedure TTParameterRegister.RegisterParameterClasses;
var
  LInstance: TTParameterFactory;
begin
  LInstance := TTParameterFactory.Instance;

  // TTStringParameter
  LInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftString);
  LInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftWideString);
  LInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftMemo);
  LInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftWideMemo);

  // TTIntegerParameter
  LInstance.RegisterParameterClass<TTIntegerParameter>(TFieldType.ftSmallint);
  LInstance.RegisterParameterClass<TTIntegerParameter>(TFieldType.ftInteger);

  // TTLargeIntegerParameter
  LInstance.RegisterParameterClass<TTLargeIntegerParameter>(TFieldType.ftLargeint);

  // TTDoubleParameter
  LInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftFMTBcd);
  LInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftBCD);
  LInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftFloat);
  LInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftSingle);
  LInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftCurrency);

  // TTBooleanParameter
  LInstance.RegisterParameterClass<TTBooleanParameter>(TFieldType.ftBoolean);

  // TTDateTimeParameter
  LInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftDate);
  LInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftDateTime);
  LInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftTimeStamp);

  // TTGuidParameter
  LInstance.RegisterParameterClass<TTGuidParameter>(TFieldType.ftGuid);

  // TTBlobParameter
  LInstance.RegisterParameterClass<TTBlobParameter>(TFieldType.ftBlob);
end;

end.
