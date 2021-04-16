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

  Trysil.Types,
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
    FConnection: TTDataConnection;
    FContext: TObject;
    FMetadata: TTMetadata;
    FMapper: TTMapper;
  public
    constructor Create(
      const AConnection: TTDataConnection;
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
  const AConnection: TTDataConnection;
  const AContext: TObject;
  const AMetadata: TTMetadata;
  const AMapper: TTMapper);
begin
  inherited Create;
  FConnection := AConnection;
  FContext := AContext;
  FMetadata := AMetadata;
  FMapper := AMapper;
end;

procedure TTResolver.Insert<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTDataInsertCommand;
  LEvent: TTEvent;
begin
  LTableMap := FMapper.Load<T>();
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
    LTableMap.VersionColumn.Member.SetValue(AEntity, 0);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Update<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTDataUpdateCommand;
  LEvent: TTEvent;
begin
  LTableMap := FMapper.Load<T>();
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
    LTableMap.VersionColumn.Member.SetValue(
      AEntity,
      LTableMap.VersionColumn.Member.GetValue(AEntity).AsType<TTVersion>() + 1);
  finally
    LCommand.Free;
  end;
end;

procedure TTResolver.Delete<T>(const AEntity: T);
var
  LTableMap: TTTableMap;
  LTableMetadata: TTTableMetadata;
  LCommand: TTDataDeleteCommand;
  LEvent: TTEvent;
begin
  LTableMap := FMapper.Load<T>();
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
