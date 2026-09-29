(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.APIRest.Project;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.RegularExpressions,

  Trysil.Expert.APIRest.Parameters,
  Trysil.Expert.APIRest.Features;

type

{ TTApiRestProject }

  TTApiRestProject = class
  strict private
    const SourceProject = 'TApiRestTemplate';
    const SourceService = 'ApiRestTemplateService';
    const SourceDescription = 'TApiRestTemplate - API REST';
  strict private
    FParameters: TTApiRestParameters;

    function Files(const AExtensions: array of String): TArray<String>;
    function ProjectFile(const AExtension: String): String;
    function DprUnits: TArray<String>;
    function IsUnitReference(const ALine: String): Boolean;
    procedure WriteReferences(const ALines: TStrings; const AIndent: String);
    procedure ReplaceReferences(
      const ASource: TArray<String>; const ALines: TStrings);
    function RenameLine(const ALine: String): String;
    procedure RenameText(const AFileName: String);
    procedure RenameFile(const AFileName: String);
  public
    constructor Create(const AParameters: TTApiRestParameters);

    procedure ProcessSources;
    procedure SyncProject;
    procedure Rename;
    procedure NewProjectGuid;
    procedure RemoveEmptyFolders;
  end;

implementation

{ TTApiRestProject }

constructor TTApiRestProject.Create(const AParameters: TTApiRestParameters);
begin
  inherited Create;
  FParameters := AParameters;
end;

function TTApiRestProject.Files(
  const AExtensions: array of String): TArray<String>;
var
  LFileName: String;
  LExtension: String;
begin
  result := [];
  for LFileName in TDirectory.GetFiles(
    FParameters.Directory, '*', TSearchOption.soAllDirectories) do
    for LExtension in AExtensions do
      if SameText(TPath.GetExtension(LFileName), LExtension) then
        result := result + [LFileName];
end;

function TTApiRestProject.ProjectFile(const AExtension: String): String;
begin
  result := TPath.Combine(
    FParameters.Directory, Format('%s%s', [SourceProject, AExtension]));
end;

procedure TTApiRestProject.ProcessSources;
var
  LSource: TTApiRestSource;
  LFileName: String;
begin
  LSource := TTApiRestSource.Create(FParameters.Features);
  try
    for LFileName in Files(['.pas', '.dpr', '.dfm', '.sql']) do
      if not LSource.Process(LFileName) then
        TFile.Delete(LFileName);
  finally
    LSource.Free;
  end;
end;

function TTApiRestProject.DprUnits: TArray<String>;
var
  LMatch: TMatch;
begin
  result := [];
  for LMatch in TRegEx.Matches(
    TFile.ReadAllText(ProjectFile('.dpr')), '\bin\s+''([^'']+)''') do
    result := result + [LMatch.Groups[1].Value];
end;

function TTApiRestProject.IsUnitReference(const ALine: String): Boolean;
begin
  result := TRegEx.IsMatch(
    ALine, '^\s*<DCCReference Include="[^"]+\.pas"/>\s*$');
end;

procedure TTApiRestProject.WriteReferences(
  const ALines: TStrings; const AIndent: String);
var
  LUnit: String;
begin
  for LUnit in DprUnits do
    ALines.Add(Format('%s<DCCReference Include="%s"/>', [AIndent, LUnit]));
end;

procedure TTApiRestProject.ReplaceReferences(
  const ASource: TArray<String>; const ALines: TStrings);
var
  LLine: String;
  LWritten: Boolean;
begin
  LWritten := False;
  for LLine in ASource do
    if not IsUnitReference(LLine) then
      ALines.Add(LLine)
    else if not LWritten then
    begin
      WriteReferences(ALines, LLine.Substring(0, LLine.IndexOf('<')));
      LWritten := True;
    end;
end;

procedure TTApiRestProject.SyncProject;
var
  LFile: TTApiRestTextFile;
  LSource: TArray<String>;
begin
  LFile := TTApiRestTextFile.Create(ProjectFile('.dproj'));
  try
    LSource := LFile.Lines.ToStringArray;
    LFile.Lines.Clear;
    ReplaceReferences(LSource, LFile.Lines);
    LFile.Save;
  finally
    LFile.Free;
  end;
end;

function TTApiRestProject.RenameLine(const ALine: String): String;
begin
  result := ALine
    .Replace(SourceDescription, FParameters.Description, [rfReplaceAll])
    .Replace(SourceService, FParameters.ServiceName, [rfReplaceAll])
    .Replace(SourceProject, FParameters.ProjectName, [rfReplaceAll]);
end;

procedure TTApiRestProject.RenameText(const AFileName: String);
var
  LFile: TTApiRestTextFile;
  LIndex: Integer;
begin
  LFile := TTApiRestTextFile.Create(AFileName);
  try
    for LIndex := 0 to LFile.Lines.Count - 1 do
      LFile.Lines[LIndex] := RenameLine(LFile.Lines[LIndex]);
    LFile.Save;
  finally
    LFile.Free;
  end;
end;

procedure TTApiRestProject.RenameFile(const AFileName: String);
var
  LName: String;
begin
  LName := TPath.GetFileName(AFileName);
  if LName.Contains(SourceProject) then
    TFile.Move(
      AFileName,
      TPath.Combine(
        TPath.GetDirectoryName(AFileName),
        LName.Replace(
          SourceProject, FParameters.ProjectName, [rfReplaceAll])));
end;

procedure TTApiRestProject.Rename;
var
  LFileName: String;
begin
  for LFileName in Files(
    ['.pas', '.dpr', '.dproj', '.dfm', '.json', '.sql']) do
    RenameText(LFileName);

  for LFileName in TDirectory.GetFiles(
    FParameters.Directory, '*', TSearchOption.soAllDirectories) do
    RenameFile(LFileName);
end;

procedure TTApiRestProject.NewProjectGuid;
var
  LFile: TTApiRestTextFile;
  LIndex: Integer;
begin
  LFile := TTApiRestTextFile.Create(TPath.Combine(
    FParameters.Directory, Format('%s.dproj', [FParameters.ProjectName])));
  try
    for LIndex := 0 to LFile.Lines.Count - 1 do
      LFile.Lines[LIndex] := TRegEx.Replace(
        LFile.Lines[LIndex],
        '<ProjectGuid>[^<]*</ProjectGuid>',
        Format('<ProjectGuid>%s</ProjectGuid>', [TGUID.NewGuid.ToString]));
    LFile.Save;
  finally
    LFile.Free;
  end;
end;

procedure TTApiRestProject.RemoveEmptyFolders;
var
  LFolders: TArray<String>;
  LIndex: Integer;
begin
  LFolders := TDirectory.GetDirectories(
    FParameters.Directory, '*', TSearchOption.soAllDirectories);
  for LIndex := High(LFolders) downto Low(LFolders) do
    if TDirectory.IsEmpty(LFolders[LIndex]) then
      TDirectory.Delete(LFolders[LIndex]);
end;

end.
