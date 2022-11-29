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
  Trysil.Events.Abstract,
  Trysil.Events.Factory;

type

{ TTResolver }

  TTResolver = class
  strict private
    FConnection: TTConnection;
    FContext: TObject;
    FMetadata: TTMetadata;

    procedure CheckReadWrite(const ATableMap: TTTableMap);
    procedure ExecuteValidators(
      const AEntity: TObject; const ATableMap: TTTableMap);
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata);

    procedure Insert<T: class>(const AEntity: T);
    procedure Update<T: class>(const AEntity: T);
    procedure Delete<T: class>(const AEntity: T);
  end;

implementation

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

procedure TTResolver.ExecuteValidators(
  const AEntity: TObject; const ATableMap: TTTableMap);
var
  LColumnMap: TTColumnMap;
  LValidatorMap: TTValidatorMap;
  LLength: Integer;
  LIsValid: Boolean;
begin
  for LColumnMap in ATableMap.Columns do
    LColumnMap.Validate(AEntity);

  for LValidatorMap in ATableMap.Validators do
  begin
    LLength := Length(LValidatorMap.Parameters);
    if LLength = 0 then
      LValidatorMap.Method.Invoke(AEntity, [])
    else
    begin
      LIsValid := (LLength = 1);
      if LIsValid then
        LIsValid := (
          LValidatorMap.Parameters[0].ParamType.Handle = FContext.ClassInfo);
      if not LIsValid then
        raise ETException.CreateFmt(SNotValidValidator, [
          LValidatorMap.Method.Name, AEntity.ClassName]);
      LValidatorMap.Method.Invoke(AEntity, [FContext])
    end;
  end;
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
