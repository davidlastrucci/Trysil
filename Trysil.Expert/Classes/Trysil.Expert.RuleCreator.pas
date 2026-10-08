(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.RuleCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  ToolsAPI,
  Trysil.Expert.IOTA,
  Trysil.Expert.Config,
  Trysil.Expert.SourceWriter,
  Trysil.Expert.Model,
  Trysil.Expert.IOTA.ModuleCreator;

type

{ TTRuleCreator }

  TTRuleCreator = class
  strict private
    FProjectName: String;
    FUnitNames: String;
    FRuleNames: String;
    FPascalDirectory: String;

    function Exists(const AUnitName: String): Boolean;
    procedure AddUses(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure AddType(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure AddImplementation(
      const ASource: TTSourceWriter; const AEntity: TTEntity);
    procedure CreateRule(const AEntity: TTEntity; const AUnitName: String);
    procedure CreateUnit(
      const AName: String; const ASource: TTSourceWriter);
  public
    constructor Create(
      const AProjectName: String;
      const AUnitNames: String;
      const ARuleNames: String;
      const APascalDirectory: String);

    procedure CreateRules(const ASelected: TList<TTEntity>);
  end;

implementation

{ TTRuleCreator }

constructor TTRuleCreator.Create(
  const AProjectName: String;
  const AUnitNames: String;
  const ARuleNames: String;
  const APascalDirectory: String);
begin
  inherited Create;
  FProjectName := AProjectName;
  FUnitNames := AUnitNames;
  FRuleNames := ARuleNames;
  FPascalDirectory := APascalDirectory;
end;

procedure TTRuleCreator.CreateRules(const ASelected: TList<TTEntity>);
var
  LEntity: TTEntity;
  LUnitName: String;
begin
  for LEntity in ASelected do
  begin
    LUnitName := TTUtils.UnitName(FRuleNames, FProjectName, LEntity.Name);
    if not Exists(LUnitName) then
      CreateRule(LEntity, LUnitName);
  end;
end;

function TTRuleCreator.Exists(const AUnitName: String): Boolean;
var
  LFileName: String;
begin
  LFileName := TPath.Combine(FPascalDirectory, AUnitName);
  result :=
    TFile.Exists(Format('%s.pas', [LFileName])) or
    Assigned(TTIOTA.SearchModule(LFileName));
end;

procedure TTRuleCreator.AddUses(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('uses');
  ASource.Append('  System.Classes,');
  ASource.Append('  System.SysUtils,');
  ASource.Append('  Trysil.Exceptions,');
  ASource.Append('  Trysil.Events,');
  ASource.AppendLine;
  ASource.Append('  %s;', [
    TTUtils.UnitName(FUnitNames, FProjectName, AEntity.Name)]);
  ASource.AppendLine;
end;

procedure TTRuleCreator.AddType(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('type');
  ASource.AppendLine;
  ASource.Append('{ T%sRules }', [AEntity.Name]);
  ASource.AppendLine;
  ASource.Append(
    '  T%0:sRules = class(TTEntityEvents<T%0:s>)', [AEntity.Name]);
  ASource.Append('  strict protected');
  ASource.Append('    // procedure BeforeInsert; override;');
  ASource.Append('    // procedure AfterInsert; override;');
  ASource.Append('    // procedure BeforeUpdate; override;');
  ASource.Append('    // procedure AfterUpdate; override;');
  ASource.Append('    // procedure BeforeDelete; override;');
  ASource.Append('    // procedure AfterDelete; override;');
  ASource.Append('  end;');
  ASource.AppendLine;
end;

procedure TTRuleCreator.AddImplementation(
  const ASource: TTSourceWriter; const AEntity: TTEntity);
begin
  ASource.Append('implementation');
  ASource.AppendLine;
  ASource.Append('initialization');
  ASource.Append(
    '  TTEventRegistration.RegisterEvents<T%0:s, T%0:sRules>;', [
      AEntity.Name]);
  ASource.AppendLine;
  ASource.Append('end.');
end;

procedure TTRuleCreator.CreateRule(
  const AEntity: TTEntity; const AUnitName: String);
var
  LSource: TTSourceWriter;
begin
  LSource := TTSourceWriter.Create;
  try
    LSource.Append('unit %s;', [AUnitName]);
    LSource.AppendLine;
    LSource.Append('interface');
    LSource.AppendLine;
    AddUses(LSource, AEntity);
    AddType(LSource, AEntity);
    AddImplementation(LSource, AEntity);
    CreateUnit(TPath.Combine(FPascalDirectory, AUnitName), LSource);
  finally
    LSource.Free;
  end;
end;

procedure TTRuleCreator.CreateUnit(
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
        LProject.AddFile(LModule.FileName, True);
    end;
  end;
end;

end.
