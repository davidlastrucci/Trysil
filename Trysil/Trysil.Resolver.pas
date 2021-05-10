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
    FMapper: TTMapper;
    FUpdateMode: TTUpdateMode;

    procedure CheckReadWrite(const ATableMap: TTTableMap);
  public
    constructor Create(
      const AConnection: TTConnection;
      const AContext: TObject;
      const AMetadata: TTMetadata;
      const AMapper: TTMapper);

    procedure Insert<T: class>(const AEntity: T);
    procedure Update<T: class>(const AEntity: T);
    procedure Delete<T: class>(const AEntity: T);
  end;

implementation

{ TTResolver }

constructor TTResolver.Create(
  const AConnection: TTConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata;
  const AMapper: TTMapper);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;
  FMapper := AMapper;
  FUpdateMode := TTUpdateMode.KeyAndVersionColumn;
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

procedure TTResolver.Insert<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTAbstractCommand;
  LEvent: TTEvent;
begin
  LTableMap := FMapper.Load<T>();
  CheckReadWrite(LTableMap);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateInsertCommand(
    FMapper, LTableMap, LTableMetadata);
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
  LTableMap := FMapper.Load<T>();
  CheckReadWrite(LTableMap);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateUpdateCommand(
    FMapper, LTableMap, LTableMetadata);
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
  LTableMap := FMapper.Load<T>();
  CheckReadWrite(LTableMap);
  FConnection.CheckRelations(LTableMap, AEntity);
  LTableMetadata := FMetadata.Load<T>();
  LCommand := FConnection.CreateDeleteCommand(
    FMapper, LTableMap, LTableMetadata);
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
