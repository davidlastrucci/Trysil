(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRestCreator;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,

  Trysil.Expert.Classes,
  Trysil.Expert.Consts,
  Trysil.Expert.IOTA,
  Trysil.Expert.APIRest.Parameters,
  Trysil.Expert.APIRest.Template,
  Trysil.Expert.APIRest.Project,
  Trysil.Expert.APIRest.Configuration;

type

{ TTAPIRestCreator }

  TTAPIRestCreator = class
  strict private
    FParameters: TTApiRestParameters;

    procedure CheckDirectory;
    procedure Generate(const ATemplate: TTApiRestTemplate);
    procedure Configure;
  public
    constructor Create(const AParameters: TTApiRestParameters);

    procedure CreateProject;
    procedure OpenProject;
  end;

implementation

{ TTAPIRestCreator }

constructor TTAPIRestCreator.Create(const AParameters: TTApiRestParameters);
begin
  inherited Create;
  FParameters := AParameters;
end;

procedure TTAPIRestCreator.CheckDirectory;
begin
  if TDirectory.Exists(FParameters.Directory) and
    (not TDirectory.IsEmpty(FParameters.Directory)) then
    raise ETExpertException.CreateFmt(
      STargetNotEmpty, [FParameters.Directory]);
  TDirectory.CreateDirectory(FParameters.Directory);
end;

procedure TTAPIRestCreator.Generate(const ATemplate: TTApiRestTemplate);
var
  LProject: TTApiRestProject;
  LRules: TTApiRestRules;
begin
  LProject := TTApiRestProject.Create(FParameters);
  try
    LProject.ProcessSources;
    LRules := TTApiRestRules.Create(
      FParameters.Directory, FParameters.Features);
    try
      LRules.Apply(ATemplate.Rules);
    finally
      LRules.Free;
    end;
    LProject.SyncProject;
    LProject.Rename;
    LProject.NewProjectGuid;
    LProject.RemoveEmptyFolders;
  finally
    LProject.Free;
  end;
end;

procedure TTAPIRestCreator.Configure;
var
  LConfiguration: TTApiRestConfiguration;
begin
  LConfiguration := TTApiRestConfiguration.Create(FParameters);
  try
    LConfiguration.Apply;
  finally
    LConfiguration.Free;
  end;
end;

procedure TTAPIRestCreator.CreateProject;
var
  LTemplate: TTApiRestTemplate;
begin
  CheckDirectory;
  LTemplate := TTApiRestTemplate.Create;
  try
    LTemplate.Download;
    LTemplate.ExtractTo(FParameters.Directory);
    Generate(LTemplate);
  finally
    LTemplate.Free;
  end;
  Configure;
end;

procedure TTAPIRestCreator.OpenProject;
begin
  TTIOTA.OpenProject(
    TPath.Combine(
      FParameters.Directory,
      Format('%s.dproj', [FParameters.ProjectName])));
end;

end.
