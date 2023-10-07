(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.ControllerCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  ToolsAPI,

  Trysil.Expert.Config,
  Trysil.Expert.SourceWriter,
  Trysil.Expert.Model,
  Trysil.Expert.IOTA.ModuleCreator;

type

{ TTControllerCreator }

  TTControllerCreator = class
  strict private
    FProjectName: String;
    FUnitNames: String;
    FPascalDirectory: String;

    procedure CreateController(const AEntity: TTEntity);

    procedure CreateUnit(
      const AName: String; const ASource: TTSourceWriter);
  public
    constructor Create(
      const AProjectName: String;
      const AUnitNames: String;
      const APascalDirectory: String);

    procedure CreateControllers(const ASelected: TList<TTEntity>);
  end;

implementation

{ TTControllerCreator }

constructor TTControllerCreator.Create(
  const AProjectName: String;
  const AUnitNames: String;
  const APascalDirectory: String);
begin
  inherited Create;
  FProjectName := AProjectName;
  FUnitNames := AUnitNames;
  FPascalDirectory := APascalDirectory;
end;

procedure TTControllerCreator.CreateControllers(
  const ASelected: TList<TTEntity>);
var
  LEntity: TTEntity;
begin
  for LEntity in ASelected do
    CreateController(LEntity);
end;

procedure TTControllerCreator.CreateController(const AEntity: TTEntity);
var
  LSource: TTSourceWriter;
  LUnitName: String;
begin
  LSource := TTSourceWriter.Create;
  try
    LUnitName := Format('API.Controller.%s', [AEntity.Name]);

    LSource.Append('unit %s;', [LUnitName]);
    LSource.AppendLine;
    LSource.Append('{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}');
    LSource.AppendLine;
    LSource.Append('interface');
    LSource.AppendLine;
    LSource.Append('uses');
    LSource.Append('  System.Classes,');
    LSource.Append('  System.SysUtils,');
    LSource.Append('  Trysil.Http.Attributes,');
    LSource.AppendLine;
    LSource.Append('  API.Controller,');
    LSource.Append('  %s;', [TTUtils.UnitName(FUnitNames, FProjectName, AEntity.Name)]);
    LSource.AppendLine;
    LSource.Append('type');
    LSource.AppendLine;
    LSource.Append('{ TAPI%sController }', [AEntity.Name]);
    LSource.AppendLine;
    LSource.Append('  [TUri(''/%s'')]', [AEntity.Name.ToLower]);
    LSource.Append('  TAPI%0:sController = class(TAPIReadWriteController<T%0:s>)', [AEntity.Name]);
    LSource.Append('  end;');
    LSource.AppendLine;
    LSource.Append('implementation');
    LSource.AppendLine;
    LSource.Append('end.');

    CreateUnit(TPath.Combine(FPascalDirectory, LUnitName), LSource);
  finally
    LSource.Free;
  end;
end;

procedure TTControllerCreator.CreateUnit(
  const AName: String; const ASource: TTSourceWriter);
var
  LModuleServices: IOTAModuleServices;
  LProject: IOTAProject;
  LModule: IOTAModule;
begin
  if BorlandIDEServices.SupportsService(IOTAModuleServices) then
  begin
    LModuleServices := (BorlandIDEServices as IOTAModuleServices);
    LProject := LModuleServices.GetActiveProject;
    if Assigned(LProject) then
    begin
      LModule := LModuleServices.CreateModule(
        TTModuleCreator.Create(AName, ASource.ToString));
      if Assigned(LModule) then
      begin
        LProject.AddFile(LModule.FileName, True);
        // LModule.Save(False, True);
      end;
    end;
  end;
end;

end.
