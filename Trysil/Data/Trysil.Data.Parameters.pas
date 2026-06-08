(*

  Trysil
  Copyright � David Lastrucci
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
  System.Rtti,
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
  strict private
    FConnectionID: String;
  strict protected
    FParam: TTParam;
    FColumnMap: TTColumnMap;

    procedure LogParameter(const AName: String; const AValue: String);
  public
    constructor Create(
      const AConnectionID: String; const AParam: TTParam); overload;
    constructor Create(
      const AConnectionID: String;
      const AParam: TTParam;
      const AColumnMap: TTColumnMap); overload;

    procedure SetValue(const AEntity: TObject); overload; virtual; abstract;
    procedure SetValue(const AValue: TTValue); overload; virtual; abstract;
  end;

  TTParameterClass = class of TTParameter;

{ TTStringParameter }

  TTStringParameter = class(TTParameter)
  strict private
    procedure SetParameterValue(const AEntity: TObject; const AValue: String);
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTIntegerParameter }

  TTIntegerParameter = class(TTParameter)
  strict private
    procedure SetValueFromObject(const AObject: TObject);
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTLargeIntegerParameter }

  TTLargeIntegerParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTDoubleParameter }

  TTDoubleParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTBooleanParameter }

  TTBooleanParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTDateTimeParameter }

  TTDateTimeParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTGuidParameter }

  TTGuidParameter = class(TTParameter)
  strict private
    procedure WriteGuid(const AGuid: TGuid);
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
  end;

{ TTBlobParameter }

  TTBlobParameter = class(TTParameter)
  public
    procedure SetValue(const AEntity: TObject); overload; override;
    procedure SetValue(const AValue: TTValue); overload; override;
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
      const AConnectionID: String;
      const AFieldType: TFieldType;
      const AParam: TTParam): TTParameter; overload;
    function CreateParameter(
      const AConnectionID: String;
      const AFieldType: TFieldType;
      const AParam: TTParam;
      const AColumnMap: TTColumnMap): TTParameter; overload;

    class property Instance: TTParameterFactory read FInstance;
  end;

{ TTParameterRegister }

  TTParameterRegister = class
  strict private
    class procedure RegisterStringParameterClasses(
      const AInstance: TTParameterFactory);
    class procedure RegisterIntegerParameterClasses(
      const AInstance: TTParameterFactory);
    class procedure RegisterDoubleParameterClasses(
      const AInstance: TTParameterFactory);
    class procedure RegisterDateTimeParameterClasses(
      const AInstance: TTParameterFactory);
    class procedure RegisterOtherParameterClasses(
      const AInstance: TTParameterFactory);
  public
    class procedure RegisterParameterClasses;
  end;

implementation

{ TTParameter }

constructor TTParameter.Create(
  const AConnectionID: String; const AParam: TTParam);
begin
  Create(FConnectionID, AParam, nil);
end;

constructor TTParameter.Create(
  const AConnectionID: String;
  const AParam: TTParam;
  const AColumnMap: TTColumnMap);
begin
  inherited Create;
  FConnectionID := AConnectionID;
  FParam := AParam;
  FColumnMap := AColumnMap;
end;

procedure TTParameter.LogParameter(const AName: String; const AValue: String);
begin
  TTLogger.Instance.LogParameter(FConnectionID, AName, AValue);
end;

{ TTStringParameter }

procedure TTStringParameter.SetParameterValue(
  const AEntity: TObject; const AValue: String);
var
  LValue: String;
begin
  LValue := AValue;
  if FParam.Size > 0 then
    LValue := LValue.Substring(0, FParam.Size);
  FParam.AsString := LValue;
  if Assigned(AEntity) and (not LValue.Equals(AValue)) then
    FColumnMap.Member.SetValue(AEntity, LValue);
end;

procedure TTStringParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<String>;
  LParamValue: String;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<String>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      SetParameterValue(AEntity, LNullable);
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<String>();
    SetParameterValue(AEntity, LParamValue);
  end;

  LogParameter(FColumnMap.Name, LParamValue);
end;

procedure TTStringParameter.SetValue(const AValue: TTValue);
var
  LParamValue: String;
begin
  LParamValue := AValue.AsType<String>();
  SetParameterValue(nil, LParamValue);
  LogParameter(FParam.Name, LParamValue);
end;

{ TTIntegerParameter }

procedure TTIntegerParameter.SetValue(const AEntity: TObject);
var
  LIsClass: Boolean;
  LValue: TTValue;
  LNullable: TTNullable<Integer>;
  LParamValue: Integer;
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
    LParamValue := LNullable.GetValueOrDefault;
  end
  else if LIsClass then
    SetValueFromObject(LValue.AsObject)
  else
  begin
    if LValue.Kind = TTypeKind.tkEnumeration then
      LValue := LValue.AsOrdinal;

    LParamValue := LValue.AsType<Integer>();
    FParam.AsInteger := LParamValue;
  end;

  if not LIsClass then
    LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

procedure TTIntegerParameter.SetValue(const AValue: TTValue);
var
  LParamValue: Integer;
begin
  LParamValue := AValue.AsType<Integer>();
  FParam.AsInteger := LParamValue;
  LogParameter(FParam.Name, LParamValue.ToString);
end;

procedure TTIntegerParameter.SetValueFromObject(const AObject: TObject);
var
  LTableMap: TTTableMap;
  LValue: TTValue;
  LParamValue: Integer;
begin
  if TTRttiLazy.IsLazy(AObject) then
    LValue := FColumnMap.Member.GetValueFromObject(AObject)
  else
  begin
    LTableMap := TTMapper.Instance.Load(AObject.ClassInfo);
    if not Assigned(LTableMap) then
      raise ETException.Create(
        TTLanguage.Instance.Translate(STableMapNotFound));
    if not Assigned(LTableMap.PrimaryKey) then
      raise ETException.Create(
        TTLanguage.Instance.Translate(SPrimaryKeyNotDefined));
    LValue := LTableMap.PrimaryKey.Member.GetValue(AObject);
  end;
  LParamValue := LValue.AsType<Integer>();
  FParam.AsInteger := LParamValue;

  LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

{ TTLargeIntegerParameter }

procedure TTLargeIntegerParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Int64>;
  LParamValue: Int64;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Int64>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsLargeInt := LNullable;
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<Int64>();
    FParam.AsLargeInt := LParamValue;
  end;

  LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

procedure TTLargeIntegerParameter.SetValue(const AValue: TTValue);
var
  LParamValue: Int64;
begin
  LParamValue := AValue.AsType<Int64>();
  FParam.AsLargeInt := LParamValue;
  LogParameter(FParam.Name, LParamValue.ToString);
end;

{ TTDoubleParameter }

procedure TTDoubleParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Double>;
  LParamValue: Double;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Double>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsDouble := LNullable;
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<Double>();
    FParam.AsDouble := LParamValue;
  end;

  LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

procedure TTDoubleParameter.SetValue(const AValue: TTValue);
var
  LParamValue: Double;
begin
  LParamValue := AValue.AsType<Double>();
  FParam.AsDouble := LParamValue;
  LogParameter(FParam.Name, LParamValue.ToString);
end;

{ TTBooleanParameter }

procedure TTBooleanParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<Boolean>;
  LParamValue: Boolean;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<Boolean>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsBoolean := LNullable;
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<Boolean>();
    FParam.AsBoolean := LParamValue;
  end;

  LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

procedure TTBooleanParameter.SetValue(const AValue: TTValue);
var
  LParamValue: Boolean;
begin
  LParamValue := AValue.AsType<Boolean>();
  FParam.AsBoolean := LParamValue;
  LogParameter(FParam.Name, LParamValue.ToString);
end;

{ TTDateTimeParameter }

procedure TTDateTimeParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TDateTime>;
  LParamValue: TDateTime;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TDateTime>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsDateTime := LNullable;
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<TDateTime>();
    FParam.AsDateTime := LParamValue;
  end;

  LogParameter(FColumnMap.Name, DateTimeToStr(LParamValue));
end;

procedure TTDateTimeParameter.SetValue(const AValue: TTValue);
var
  LParamValue: TDateTime;
begin
  LParamValue := AValue.AsType<TDateTime>();
  FParam.AsDateTime := LParamValue;
  LogParameter(FParam.Name, DateTimeToStr(LParamValue));
end;

{ TTGuidParameter }

procedure TTGuidParameter.WriteGuid(const AGuid: TGuid);
var
  LBytes: TBytes;
begin
  if (FParam.DataType <> ftGuid) and (FParam.Size <= SizeOf(TGuid)) then
  begin
    SetLength(LBytes, SizeOf(TGuid));
    Move(AGuid, LBytes[0], SizeOf(TGuid));
    FParam.AsBytes := LBytes;
  end
  else
    FParam.AsGuid := AGuid;
end;

procedure TTGuidParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TGuid>;
  LParamValue: TGuid;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TGuid>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      WriteGuid(LNullable);
    LParamValue := LNullable.GetValueOrDefault;
  end
  else
  begin
    LParamValue := LValue.AsType<TGuid>();
    WriteGuid(LParamValue);
  end;

  LogParameter(FColumnMap.Name, LParamValue.ToString);
end;

procedure TTGuidParameter.SetValue(const AValue: TTValue);
var
  LParamValue: TGuid;
begin
  LParamValue := AValue.AsType<TGuid>();
  WriteGuid(LParamValue);
  LogParameter(FParam.Name, LParamValue.ToString);
end;

{ TTBlobParameter }

procedure TTBlobParameter.SetValue(const AEntity: TObject);
var
  LValue: TTValue;
  LNullable: TTNullable<TBytes>;
begin
  LValue := FColumnMap.Member.GetValue(AEntity);
  if FColumnMap.Member.IsNullable then
  begin
    LNullable := LValue.AsType<TTNullable<TBytes>>();
    if LNullable.IsNull then
      FParam.Clear()
    else
      FParam.AsBytes := LNullable;
  end
  else
    FParam.AsBytes := LValue.AsType<TBytes>();
  // Blob parameters not logged
end;

procedure TTBlobParameter.SetValue(const AValue: TTValue);
begin
  FParam.AsBytes := AValue.AsType<TBytes>();
  // Blob parameters not logged
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
  const AConnectionID: String;
  const AFieldType: TFieldType;
  const AParam: TTParam): TTParameter;
begin
  result := CreateParameter(AConnectionID, AFieldType, AParam, nil);
end;

function TTParameterFactory.CreateParameter(
  const AConnectionID: String;
  const AFieldType: TFieldType;
  const AParam: TTParam;
  const AColumnMap: TTColumnMap): TTParameter;
var
  LClass: TClass;
begin
  if Assigned(AColumnMap) and AColumnMap.IsGuid then
    result := TTGuidParameter.Create(AConnectionID, AParam, AColumnMap)
  else
  begin
    if not FParameterTypes.TryGetValue(AFieldType, LClass) then
      raise ETException.CreateFmt(
        TTLanguage.Instance.Translate(SParameterTypeError), [
          TRttiEnumerationType.GetName<TFieldType>(AFieldType)]);
    result := TTParameterClass(LClass).Create(AConnectionID, AParam, AColumnMap);
  end;
end;

{ TTParameterRegister }

class procedure TTParameterRegister.RegisterStringParameterClasses(
  const AInstance: TTParameterFactory);
begin
  // TTStringParameter
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftString);
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftWideString);
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftFixedChar);
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftFixedWideChar);
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftMemo);
  AInstance.RegisterParameterClass<TTStringParameter>(TFieldType.ftWideMemo);
end;

class procedure TTParameterRegister.RegisterIntegerParameterClasses(
  const AInstance: TTParameterFactory);
begin
  // TTIntegerParameter
  AInstance.RegisterParameterClass<TTIntegerParameter>(TFieldType.ftSmallint);
  AInstance.RegisterParameterClass<TTIntegerParameter>(TFieldType.ftInteger);

  // TTLargeIntegerParameter
  AInstance.RegisterParameterClass<TTLargeIntegerParameter>(TFieldType.ftLargeint);
end;

class procedure TTParameterRegister.RegisterDoubleParameterClasses(
  const AInstance: TTParameterFactory);
begin
  // TTDoubleParameter
  AInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftFMTBcd);
  AInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftBCD);
  AInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftFloat);
  AInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftSingle);
  AInstance.RegisterParameterClass<TTDoubleParameter>(TFieldType.ftCurrency);
end;

class procedure TTParameterRegister.RegisterDateTimeParameterClasses(
  const AInstance: TTParameterFactory);
begin
  // TTDateTimeParameter
  AInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftDate);
  AInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftDateTime);
  AInstance.RegisterParameterClass<TTDateTimeParameter>(TFieldType.ftTimeStamp);
end;

class procedure TTParameterRegister.RegisterOtherParameterClasses(
  const AInstance: TTParameterFactory);
begin
  // TTBooleanParameter
  AInstance.RegisterParameterClass<TTBooleanParameter>(TFieldType.ftBoolean);

  // TTGuidParameter
  AInstance.RegisterParameterClass<TTGuidParameter>(TFieldType.ftGuid);

  // TTBlobParameter
  AInstance.RegisterParameterClass<TTBlobParameter>(TFieldType.ftBlob);
  AInstance.RegisterParameterClass<TTBlobParameter>(TFieldType.ftOraBlob);
end;

class procedure TTParameterRegister.RegisterParameterClasses;
begin
  RegisterStringParameterClasses(TTParameterFactory.Instance);
  RegisterIntegerParameterClasses(TTParameterFactory.Instance);
  RegisterDoubleParameterClasses(TTParameterFactory.Instance);
  RegisterDateTimeParameterClasses(TTParameterFactory.Instance);
  RegisterOtherParameterClasses(TTParameterFactory.Instance);
end;

end.
