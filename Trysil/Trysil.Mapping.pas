(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Mapping;

interface

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.Rtti,

  Trysil.Consts,
  Trysil.Exceptions,
  Trysil.Classes,
  Trysil.Events.Abstract,
  Trysil.Attributes,
  Trysil.Validation,
  Trysil.Validation.Attributes,
  Trysil.Events.Attributes,
  Trysil.Cache,
  Trysil.Generics.Collections,
  Trysil.Factory,
  Trysil.Rtti;

type

{ TTValidationMap }

  TTValidationMap = class
  strict private
    FValidation: TValidationAttribute;
  public
    constructor Create(const AValidation: TValidationAttribute);

    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
  end;

{ TTValidationsMap }

  TTValidationsMap = class
  strict private
    FValidations: TTObjectList<TTValidationMap>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AValidation: TTValidationMap);
    procedure Validate(
      const AColumnName: String;
      const AValue: TValue;
      const AErrors: TTValidationErrors);
  end;

{ TTColumnMap }

  TTColumnMap = class
  strict private
    FMember: TTRttiMember;
    FName: String;
    FDisplayName: String;
    FValidations: TTValidationsMap;

    function GetValidationColumnName: String;
    procedure SearchValidations(const ARttiMember: TRttiMember);
  public
    constructor Create(const AName: String); overload;
    constructor Create(
      const AName: String; const AField: TRttiField); overload;
    constructor Create(
      const AName: String; const AProperty: TRttiProperty); overload;

    destructor Destroy; override;

    procedure Validate(
      const AEntity: TObject;
      const AErrors: TTValidationErrors);

    property Member: TTRttiMember read FMember;
    property Name: String read FName;
  end;

{ TTColumnsMap }

  TTColumnsMap = class
  strict private
    FColumns: TTObjectList<TTColumnMap>;

    function GetEmpty: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AColumn: TTColumnMap);

    function GetEnumerator(): TTListEnumerator<TTColumnMap>;

    property Empty: Boolean read GetEmpty;
  end;

{ TTDetailColumnMap }

  TTDetailColumnMap = class
  strict private
    FMember: TTRttiMember;
    FName: String;
    FDetailName: String;
  public
    constructor Create(
      const AName: String; const ADetailName: String); overload;
    constructor Create(
      const AName: String;
      const ADetailName: String;
      const AField: TRttiField); overload;
    constructor Create(
      const AName: String;
      const ADetailName: String;
      const AProperty: TRttiProperty); overload;

    destructor Destroy; override;

    property Member: TTRttiMember read FMember;
    property Name: String read FName;
    property DetailName: String read FDetailName;
  end;

{ TTDetailColumnsMap }

  TTDetailColumnsMap = class
  strict private
    FColumns: TTObjectList<TTDetailColumnMap>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AColumn: TTDetailColumnMap);

    function GetEnumerator(): TTListEnumerator<TTDetailColumnMap>;
  end;

{ TTRelationMap }

  TTRelationMap = class
  strict private
    FTableName: String;
    FColumnName: String;
    FIsCascade: Boolean;
  public
    constructor Create(
      const ATableName: String;
      const AColumnName: String;
      const AIsCascade: Boolean);

    property TableName: String read FTableName;
    property ColumnName: String read FColumnName;
    property IsCascade: Boolean read FIsCascade;
  end;

{ TTRelationsMap }

  TTRelationsMap = class
  strict private
    FRelations: TTObjectList<TTRelationMap>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const ARelation: TTRelationMap);

    function GetEnumerator(): TTListEnumerator<TTRelationMap>;
  end;

{ TTValidatorMap }

  TTValidatorMap = class
  strict private
    FMethod: TRttiMethod;
    FParameters: TArray<TRttiParameter>;
  public
    constructor Create(const AMedhod: TRttiMethod);

    property Method: TRttiMethod read FMethod;
    property Parameters: TArray<TRttiParameter> read FParameters;
  end;

{ TTValidatorsMap }

  TTValidatorsMap = class
  strict private
    FValidators: TTObjectList<TTValidatorMap>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AValidator: TTValidatorMap);

    function GetEnumerator(): TTListEnumerator<TTValidatorMap>;
  end;

{ TTEventsMap }

  TTEventsMap = class
  strict private
    FInsertEventClass: TTEventClass;
    FUpdateEventClass: TTEventClass;
    FDeleteEventClass: TTEventClass;

    procedure SetInsertTypeInfo(const AAttribute: TEventAttribute);
    procedure SetUpdateTypeInfo(const AAttribute: TEventAttribute);
    procedure SetDeleteTypeInfo(const AAttribute: TEventAttribute);
  private // internal
    procedure SetEvent(const AAttribute: TEventAttribute);
  public
    constructor Create;

    property InsertEventClass: TTEventClass read FInsertEventClass;
    property UpdateEventClass: TTEventClass read FUpdateEventClass;
    property DeleteEventClass: TTEventClass read FDeleteEventClass;
  end;

{ TTTableMap }

  TTTableMap = class
  strict private
    FContext: TRttiContext;
    FTypeInfo: PTypeInfo;

    FName: String;
    FSequenceName: String;
    FPrimaryKey: TTColumnMap;
    FVersionColumn: TTColumnMap;
    FColumns: TTColumnsMap;
    FDetailColumns: TTDetailColumnsMap;
    FRelations: TTRelationsMap;
    FValidators: TTValidatorsMap;
    FEvents: TTEventsMap;

    procedure SetTableName(const AName: String);
    procedure SetSequenceName(const AName: String);

    procedure InitializeTable(const AType: TRttiType);
    procedure InitializeColumns(const AType: TRttiType);
    procedure InitializeValidators(const AType: TRttiType);
    function CreateColumnMap(
      const AName: String; const AObject: TRttiObject): TTColumnMap;
    function CreateDetailColumnMap(
      const AName: String;
      const ADetailName: String;
      const AObject: TRttiObject): TTDetailColumnMap;
    procedure SearchColumnAttribute(const AObject: TRttiObject);
    procedure InitializePrimaryKey(
      const AObject: TRttiObject; const AColumnMap: TTColumnMap);
    procedure InitializeVersionColumn(
      const AObject: TRttiObject; const AColumnMap: TTColumnMap);
  public
    constructor Create(
      const AContext: TRttiContext; const ATypeInfo: PTypeInfo);
    destructor Destroy; override;

    procedure AfterConstruction; override;

    property Name: String read FName;
    property SequenceName: String read FSequenceName;
    property PrimaryKey: TTColumnMap read FPrimaryKey;
    property VersionColumn: TTColumnMap read FVersionColumn;
    property Columns: TTColumnsMap read FColumns;
    property DetailColums: TTDetailColumnsMap read FDetailColumns;
    property Relations: TTRelationsMap read FRelations;
    property Validators: TTValidatorsMap read FValidators;
    property Events: TTEventsMap read FEvents;
  end;

{ TTMapper }

  TTMapper = class(TTCache<PTypeInfo, TTTableMap>)
  strict private
    class var FInstance: TTMapper;

    class constructor ClassCreate;
    class destructor ClassDestroy;
  strict private
    FContext: TRttiContext;
  strict protected
    function CreateObject(const ATypeInfo: PTypeInfo): TTTableMap; override;
  public
    constructor Create;
    destructor Destroy; override;

    function Load<T: class>(): TTTableMap; overload;
    function Load(const ATypeInfo: PTypeInfo): TTTableMap; overload;

    class property Instance: TTMapper read FInstance;
  end;

implementation

{ TTValidationMap }

constructor TTValidationMap.Create(const AValidation: TValidationAttribute);
begin
  inherited Create;
  FValidation := AValidation;
end;

procedure TTValidationMap.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
begin
  FValidation.Validate(AColumnName, AValue, AErrors);
end;

{ TTValidationsMap }

constructor TTValidationsMap.Create;
begin
  inherited Create;
  FValidations := TTObjectList<TTValidationMap>.Create(True);
end;

destructor TTValidationsMap.Destroy;
begin
  FValidations.Free;
  inherited Destroy;
end;

procedure TTValidationsMap.Add(const AValidation: TTValidationMap);
begin
  FValidations.Add(AValidation);
end;

procedure TTValidationsMap.Validate(
  const AColumnName: String;
  const AValue: TValue;
  const AErrors: TTValidationErrors);
var
  LValidation: TTValidationMap;
begin
  for LValidation in FValidations do
    LValidation.Validate(AColumnName, AValue, AErrors);
end;

{ TTColumnMap }

constructor TTColumnMap.Create(const AName: String);
begin
  inherited Create;
  FMember := nil;
  FName := AName;
  FDisplayName := String.Empty;
  FValidations := TTValidationsMap.Create;
end;

constructor TTColumnMap.Create(const AName: String; const AField: TRttiField);
begin
  Create(AName);
  FMember := TTRttiField.Create(AField);
  SearchValidations(AField);
end;

constructor TTColumnMap.Create(
  const AName: String; const AProperty: TRttiProperty);
begin
  Create(AName);
  FMember := TTRttiProperty.Create(AProperty);
  SearchValidations(AProperty);
end;

destructor TTColumnMap.Destroy;
begin
  FValidations.Free;
  FMember.Free;
  inherited Destroy;
end;

procedure TTColumnMap.SearchValidations(const ARttiMember: TRttiMember);
var
  LAttribute: TCustomAttribute;
begin
  for LAttribute in ARttiMember.GetAttributes do
    if LAttribute is TDisplayNameAttribute then
      FDisplayName := TDisplayNameAttribute(LAttribute).DisplayName
    else if LAttribute is TValidationAttribute then
      FValidations.Add(
        TTValidationMap.Create(TValidationAttribute(LAttribute)));
end;

function TTColumnMap.GetValidationColumnName: String;
begin
  result := FDisplayName;
  if result.IsEmpty then
    result := FName;
end;

procedure TTColumnMap.Validate(
  const AEntity: TObject; const AErrors: TTValidationErrors);
begin
  FValidations.Validate(
    GetValidationColumnName, FMember.GetValue(AEntity), AErrors);
end;

{ TTColumnsMap }

constructor TTColumnsMap.Create;
begin
  inherited Create;
  FColumns := TTObjectList<TTColumnMap>.Create(True);
end;

destructor TTColumnsMap.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

procedure TTColumnsMap.Add(const AColumn: TTColumnMap);
begin
  FColumns.Add(AColumn);
end;

function TTColumnsMap.GetEmpty: Boolean;
begin
  result := (FColumns.Count = 0);
end;

function TTColumnsMap.GetEnumerator: TTListEnumerator<TTColumnMap>;
begin
  result := TTListEnumerator<TTColumnMap>.Create(FColumns);
end;

{ TTDetailColumnMap }

constructor TTDetailColumnMap.Create(
  const AName: String; const ADetailName: String);
begin
  inherited Create;
  FMember := nil;
  FName := AName;
  FDetailName := ADetailName;
end;

constructor TTDetailColumnMap.Create(
  const AName: String;
  const ADetailName: String;
  const AField: TRttiField);
begin
  Create(AName, ADetailName);
  FMember := TTRttiField.Create(AField);
end;

constructor TTDetailColumnMap.Create(
  const AName: String;
  const ADetailName: String;
  const AProperty: TRttiProperty);
begin
  Create(AName, ADetailName);
  FMember := TTRttiProperty.Create(AProperty);
end;

destructor TTDetailColumnMap.Destroy;
begin
  FMember.Free;
  inherited;
end;

{ TTDetailColumnsMap }

constructor TTDetailColumnsMap.Create;
begin
  inherited Create;
  FColumns := TTObjectList<TTDetailColumnMap>.Create(True);
end;

destructor TTDetailColumnsMap.Destroy;
begin
  FColumns.Free;
  inherited Destroy;
end;

procedure TTDetailColumnsMap.Add(const AColumn: TTDetailColumnMap);
begin
  FColumns.Add(AColumn);
end;

function TTDetailColumnsMap.GetEnumerator: TTListEnumerator<TTDetailColumnMap>;
begin
  result := TTListEnumerator<TTDetailColumnMap>.Create(FColumns);
end;

{ TTRelationMap }

constructor TTRelationMap.Create(
  const ATableName: String;
  const AColumnName: String;
  const AIsCascade: Boolean);
begin
  inherited Create;
  FTableName := ATableName;
  FColumnName := AColumnName;
  FIsCascade := AIsCascade;
end;

{ TTRelationsMap }

constructor TTRelationsMap.Create;
begin
  inherited Create;
  FRelations := TTObjectList<TTRelationMap>.Create(True);
end;

destructor TTRelationsMap.Destroy;
begin
  FRelations.Free;
  inherited Destroy;
end;

procedure TTRelationsMap.Add(const ARelation: TTRelationMap);
begin
  FRelations.Add(ARelation)
end;

function TTRelationsMap.GetEnumerator: TTListEnumerator<TTRelationMap>;
begin
  result := TTListEnumerator<TTRelationMap>.Create(FRelations);
end;

{ TTValidatorMap }

constructor TTValidatorMap.Create(const AMedhod: TRttiMethod);
begin
  inherited Create;
  FMethod := AMedhod;
  FParameters := FMethod.GetParameters;
end;

{ TTValidatorsMap }

constructor TTValidatorsMap.Create;
begin
  inherited Create;
  FValidators := TTObjectList<TTValidatorMap>.Create(True);
end;

destructor TTValidatorsMap.Destroy;
begin
  FValidators.Free;
  inherited Destroy;
end;

procedure TTValidatorsMap.Add(const AValidator: TTValidatorMap);
begin
  FValidators.Add(AValidator);
end;

function TTValidatorsMap.GetEnumerator: TTListEnumerator<TTValidatorMap>;
begin
  result := TTListEnumerator<TTValidatorMap>.Create(FValidators);
end;

{ TTEventsMap }

constructor TTEventsMap.Create;
begin
  inherited Create;
  FInsertEventClass := nil;
  FUpdateEventClass := nil;
  FDeleteEventClass := nil;
end;

procedure TTEventsMap.SetInsertTypeInfo(const AAttribute: TEventAttribute);
begin
  if Assigned(FInsertEventClass) then
    raise ETException.Create(SInsertEventAttribute);
  FInsertEventClass := AAttribute.EventClass;
end;

procedure TTEventsMap.SetUpdateTypeInfo(const AAttribute: TEventAttribute);
begin
  if Assigned(FUpdateEventClass) then
    raise ETException.Create(SUpdateEventAttribute);
  FUpdateEventClass := AAttribute.EventClass;
end;

procedure TTEventsMap.SetDeleteTypeInfo(const AAttribute: TEventAttribute);
begin
  if Assigned(FDeleteEventClass) then
    raise ETException.Create(SDeleteEventAttribute);
  FDeleteEventClass := AAttribute.EventClass;
end;

procedure TTEventsMap.SetEvent(const AAttribute: TEventAttribute);
begin
  if AAttribute is TInsertEventAttribute then
    SetInsertTypeInfo(AAttribute)
  else if AAttribute is TUpdateEventAttribute then
    SetUpdateTypeInfo(AAttribute)
  else if AAttribute is TDeleteEventAttribute then
    SetDeleteTypeInfo(AAttribute);
end;

{ TTTableMap }

constructor TTTableMap.Create(
  const AContext: TRttiContext; const ATypeInfo: PTypeInfo);
begin
  inherited Create;
  FContext := AContext;
  FTypeInfo := ATypeInfo;

  FName := String.Empty;
  FSequenceName := String.Empty;
  FPrimaryKey := nil;
  FVersionColumn := nil;
  FColumns := TTColumnsMap.Create;
  FDetailColumns := TTDetailColumnsMap.Create;
  FRelations := TTRelationsMap.Create;
  FValidators := TTValidatorsMap.Create;
  FEvents := TTEventsMap.Create;
end;

destructor TTTableMap.Destroy;
begin
  FEvents.Free;
  FValidators.Free;
  FRelations.Free;
  FDetailColumns.Free;
  FColumns.Free;
  inherited Destroy;
end;

procedure TTTableMap.AfterConstruction;
var
  LType: TRttiType;
begin
  inherited AfterConstruction;
  LType := FContext.GetType(FTypeInfo);
  InitializeTable(LType);
  InitializeColumns(LType);
  InitializeValidators(LType);
end;

procedure TTTableMap.SetTableName(const AName: String);
begin
  if not FName.IsEmpty then
    raise ETException.Create(SDuplicateTableAttribute);
  FName := AName;
end;

procedure TTTableMap.SetSequenceName(const AName: String);
begin
  if not FSequenceName.IsEmpty then
    raise ETException.Create(SDuplicateSequenceAttribute);
  FSequenceName := AName;
end;

procedure TTTableMap.InitializeTable(const AType: TRttiType);
var
  LAttribute: TCustomAttribute;
begin
  for LAttribute in AType.GetInheritedAttributes do
    if LAttribute is TTableAttribute then
      SetTableName(TTableAttribute(LAttribute).Name)
    else if LAttribute is TSequenceAttribute then
      SetSequenceName(TSequenceAttribute(LAttribute).Name)
    else if LAttribute is TRelationAttribute then
      FRelations.Add(
        TTRelationMap.Create(
          TRelationAttribute(LAttribute).TableName,
          TRelationAttribute(LAttribute).ColumnName,
          TRelationAttribute(LAttribute).IsCascade))
    else if LAttribute is TEventAttribute then
      FEvents.SetEvent(TEventAttribute(LAttribute));
end;

procedure TTTableMap.InitializeColumns(const AType: TRttiType);
var
  LObject: TRttiObject;
begin
  for LObject in AType.GetFields do
    SearchColumnAttribute(LObject);
  for LObject in AType.GetProperties do
    SearchColumnAttribute(LObject);
end;

procedure TTTableMap.InitializeValidators(const AType: TRttiType);
var
  LMethod: TRttiMethod;
  LAttribute: TValidatorAttribute;
begin
  for LMethod in AType.GetMethods do
  begin
    LAttribute := LMethod.GetAttribute<TValidatorAttribute>;
    if Assigned(LAttribute) then
      FValidators.Add(TTValidatorMap.Create(LMethod));
  end;
end;

function TTTableMap.CreateColumnMap(
  const AName: String; const AObject: TRttiObject): TTColumnMap;
begin
  if AObject is TRttiField then
    result := TTColumnMap.Create(AName, TRttiField(AObject))
  else if AObject is TRttiProperty then
    result := TTColumnMap.Create(AName, TRttiProperty(AObject))
  else
    raise ETException.Create(SInvalidRttiObjectType);
end;

function TTTableMap.CreateDetailColumnMap(
  const AName: String;
  const ADetailName: String;
  const AObject: TRttiObject): TTDetailColumnMap;
begin
  if AObject is TRttiField then
    result := TTDetailColumnMap.Create(
      AName, ADetailName, TRttiField(AObject))
  else if AObject is TRttiProperty then
    result := TTDetailColumnMap.Create(
      AName, ADetailName, TRttiProperty(AObject))
  else
    raise ETException.Create(SInvalidRttiObjectType);
end;

procedure TTTableMap.SearchColumnAttribute(const AObject: TRttiObject);
var
  LAttribute: TCustomAttribute;
  LColumnMap: TTColumnMap;
begin
  for LAttribute in AObject.GetAttributes do
    if LAttribute is TColumnAttribute then
    begin
      LColumnMap := CreateColumnMap(
        TColumnAttribute(LAttribute).Name, AObject);
      try
        InitializePrimaryKey(AObject, LColumnMap);
        InitializeVersionColumn(AObject, LColumnMap);
        FColumns.Add(LColumnMap);
      except
        LColumnMap.Free;
        raise;
      end;
      Break;
    end
    else if LAttribute is TDetailColumnAttribute then
    begin
      FDetailColumns.Add(
        CreateDetailColumnMap(
          TDetailColumnAttribute(LAttribute).Name,
          TDetailColumnAttribute(LAttribute).DetailName,
          AObject));
      Break;
    end;
end;

procedure TTTableMap.InitializePrimaryKey(
  const AObject: TRttiObject; const AColumnMap: TTColumnMap);
var
  LAttribute: TCustomAttribute;
begin
  for LAttribute in AObject.GetAttributes do
    if LAttribute is TPrimaryKeyAttribute then
    begin
      if Assigned(FPrimaryKey) then
        raise ETException.Create(SDuplicatePrimaryKeyAttribute);
      FPrimaryKey := AColumnMap;
      Break;
    end;
end;

procedure TTTableMap.InitializeVersionColumn(
  const AObject: TRttiObject; const AColumnMap: TTColumnMap);
var
  LAttribute: TCustomAttribute;
begin
  for LAttribute in AObject.GetAttributes do
    if LAttribute is TVersionColumnAttribute then
    begin
      if Assigned(FVersionColumn) then
        raise ETException.Create(SDuplicateVersionColumnAttribute);
      FVersionColumn := AColumnMap;
      Break;
    end;
end;

{ TTMapper }

class constructor TTMapper.ClassCreate;
begin
  FInstance := TTMapper.Create;
end;

class destructor TTMapper.ClassDestroy;
begin
  FInstance.Free;
end;

constructor TTMapper.Create;
begin
  inherited Create;
  FContext := TRttiContext.Create;
end;

destructor TTMapper.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

function TTMapper.CreateObject(const ATypeInfo: PTypeInfo): TTTableMap;
begin
  result := TTTableMap.Create(FContext, ATypeInfo);
end;

function TTMapper.Load<T>: TTTableMap;
begin
  result := Load(TTFactory.Instance.GetType<T>());
end;

function TTMapper.Load(const ATypeInfo: PTypeInfo): TTTableMap;
begin
  result := GetValueOrCreate(ATypeInfo);
end;

end.
