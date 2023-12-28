(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Resolver;

interface

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  System.Rtti,

  Trysil.Consts,
  Trysil.Types,
  Trysil.Exceptions,
  Trysil.Rtti,
  Trysil.Mapping,
  Trysil.Metadata,
  Trysil.Data,
  Trysil.Validation,
  Trysil.Events.Attributes,
  Trysil.Events.Abstract,
  Trysil.Events.Factory;

type

{ TTResolverValidator }

  TTResolverValidator = class
  strict private
    FContext: TObject;
    FTableMap: TTTableMap;
    FEntity: TObject;
    FErrors: TTValidationErrors;

    function TryInvoke(
      const AValidatorMap: TTValidatorMap): Boolean; overload;
    procedure TryInvoke(
      const AValidatorMap: TTValidatorMap;
      const AArgs: TArray<TTValue>); overload;

    procedure ValidateColumns;
    procedure ValidateMethods;
  public
    constructor Create(
      const AContext: TObject;
      const ATableMap: TTTableMap;
      const AEntity: TObject;
      const AErrors: TTValidationErrors);

    procedure Execute;
  end;

{ TTResolver }

  TTResolver = class
  strict private
    FConnection: TTConnection;
    FContext: TObject;
    FMetadata: TTMetadata;

    procedure CheckReadWrite(const ATableMap: TTTableMap);

    procedure ExecuteValidators(
      const AEntity: TObject; const ATableMap: TTTableMap);
  strict protected
    function GetValidationErrorMessage(
      const AErrors: TTValidationErrors): String; virtual;
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata);

    procedure Validate<T: class>(const AEntity: T);

    procedure Insert<T: class>(const AEntity: T);
    procedure Update<T: class>(const AEntity: T);
    procedure Delete<T: class>(const AEntity: T);
  end;

implementation

{ TTResolverValidator }

constructor TTResolverValidator.Create(
  const AContext: TObject;
  const ATableMap: TTTableMap;
  const AEntity: TObject;
  const AErrors: TTValidationErrors);
begin
  inherited Create;
  FContext := AContext;
  FTableMap := ATableMap;
  FEntity := AEntity;
  FErrors := AErrors;
end;

procedure TTResolverValidator.Execute;
begin
  ValidateColumns;
  ValidateMethods;
end;

function TTResolverValidator.TryInvoke(
  const AValidatorMap: TTValidatorMap): Boolean;
var
  LLength: Integer;
begin
  LLength := Length(AValidatorMap.Parameters);
  result := (LLength = 0);
  if result then
    TryInvoke(AValidatorMap, [])
  else if LLength = 1 then
  begin
    result := TTRtti.InheritsFrom(
      FErrors, AValidatorMap.Parameters[0].ParamType);
    if result then
      TryInvoke(AValidatorMap, [FErrors]);
  end
  else if LLength = 2 then
  begin
    result :=
      TTRtti.InheritsFrom(FContext, AValidatorMap.Parameters[0].ParamType) and
      TTRtti.InheritsFrom(FErrors, AValidatorMap.Parameters[1].ParamType);
    if result then
      TryInvoke(AValidatorMap, [FContext, FErrors])
  end;
end;

procedure TTResolverValidator.TryInvoke(
  const AValidatorMap: TTValidatorMap; const AArgs: TArray<TTValue>);
begin
  try
    AValidatorMap.Method.Invoke(FEntity, AArgs);
  except
    on E: Exception do
      FErrors.Add(String.Empty, E.Message);
  end;
end;

procedure TTResolverValidator.ValidateColumns;
var
  LColumnMap: TTColumnMap;
begin
  for LColumnMap in FTableMap.Columns do
    LColumnMap.Validate(FEntity, FErrors);
end;

procedure TTResolverValidator.ValidateMethods;
var
  LValidatorMap: TTValidatorMap;
begin
  for LValidatorMap in FTableMap.Validators do
    if not TryInvoke(LValidatorMap) then
      FErrors.Add(String.Empty, Format(SNotValidValidator, [
        LValidatorMap.Method.Name, FEntity.ClassName]));
end;

{ TTResolver }

constructor TTResolver.Create(
  const AConnection: TTConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;
end;

procedure TTResolver.CheckReadWrite(const ATableMap: TTTableMap);
begin
  case FConnection.UpdateMode of
    TTUpdateMode.KeyAndVersionColumn:
      if (not Assigned(ATableMap.PrimaryKey)) or
        (not Assigned(ATableMap.VersionColumn)) then
        raise ETException.Create(SReadOnly);

    TTUpdateMode.KeyOnly:
      if not Assigned(ATableMap.PrimaryKey) then
        raise ETException.Create(SReadOnlyPrimaryKey);
  end;
end;

function TTResolver.GetValidationErrorMessage(
  const AErrors: TTValidationErrors): String;
begin
  result := AErrors.ToString();
end;

procedure TTResolver.ExecuteValidators(
  const AEntity: TObject; const ATableMap: TTTableMap);
var
  LErrors: TTValidationErrors;
  LValidator: TTResolverValidator;
begin
  LErrors := TTValidationErrors.Create;
  try
    LValidator := TTResolverValidator.Create(
      FContext, ATableMap, AEntity, LErrors);
    try
      LValidator.Execute;
    finally
      LValidator.Free;
    end;
    if not LErrors.IsEmpty then
      raise ETValidationException.Create(GetValidationErrorMessage(LErrors));
  finally
    LErrors.Free;
  end;
end;

procedure TTResolver.Validate<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  ExecuteValidators(AEntity, LTableMap);
end;

procedure TTResolver.Insert<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);
  ExecuteValidators(AEntity, LTableMap);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateInsertCommand(LTableMap, LTableMetadata);
  try
    LEvent := TTEventFactory.Instance.CreateEvent<T>(
      LTableMap.Events.InsertEventClass, FContext, AEntity);
    try
      LCommand.Execute(AEntity, LEvent);
    finally
      if Assigned(LEvent) then
        LEvent.Free;
    end;
    if Assigned(LTableMap.VersionColumn) then
      LTableMap.VersionColumn.Member.SetValue(AEntity, 0);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Update<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);
  ExecuteValidators(AEntity, LTableMap);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateUpdateCommand(LTableMap, LTableMetadata);
  try
    LEvent := TTEventFactory.Instance.CreateEvent<T>(
      LTableMap.Events.UpdateEventClass, FContext, AEntity);
    try
      LCommand.Execute(AEntity, LEvent);
    finally
      if Assigned(LEvent) then
        LEvent.Free;
    end;
    if Assigned(LTableMap.VersionColumn) then
    begin
      LTableMap.VersionColumn.Member.SetValue(
        AEntity,
        LTableMap.VersionColumn.Member.GetValue(AEntity).AsType<TTVersion>() + 1);
    end;
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Delete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
begin
  LTableMap := TTMapper.Instance.Load<T>();
  CheckReadWrite(LTableMap);
  FConnection.CheckRelations(LTableMap, AEntity);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateDeleteCommand(LTableMap, LTableMetadata);
  try
    LEvent := TTEventFactory.Instance.CreateEvent<T>(
      LTableMap.Events.DeleteEventClass, FContext, AEntity);
    try
      LCommand.Execute(AEntity, LEvent);
    finally
      if Assigned(LEvent) then
        LEvent.Free;
    end;
  finally
    LCommand.Free;
  end;
end;

end.
