(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.SkillsInstaller;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Zip,
  System.Net.HttpClient,
  System.Generics.Collections,

  Trysil.Expert.Classes;

type

{ TTSkillTool }

  TTSkillTool = record
  strict private
    FFolder: String;
    FCaption: String;
    FDescription: String;
    FTarget: String;
  public
    constructor Create(
      const AFolder: String;
      const ACaption: String;
      const ADescription: String;
      const ATarget: String);

    property Folder: String read FFolder;
    property Caption: String read FCaption;
    property Description: String read FDescription;
    property Target: String read FTarget;
  end;

{ TTSkillTools }

  TTSkillTools = class
  public
    class function All: TArray<TTSkillTool>;
  end;

{ TTSkillsInstaller }

  TTSkillsInstaller = class
  strict private
    const RepositoryUrl =
      'https://github.com/davidlastrucci/trysil-ai-skills/archive/refs/heads/master.zip';
    const ArchiveRoot = 'trysil-ai-skills-master';
  strict private
    FProjectDirectory: String;
    FArchiveFileName: String;
    FExtractedDirectory: String;
    FTools: TList<TTSkillTool>;

    class function RelativeName(
      const ABaseDirectory: String; const AFileName: String): String;
    function DownloadArchive: String;
    function ExtractArchive(const AArchiveFileName: String): String;
    function ToolSourceDirectory(const ATool: TTSkillTool): String;
    procedure CopyTool(const ATool: TTSkillTool);
    procedure Cleanup;
  public
    constructor Create(const AProjectDirectory: String);
    destructor Destroy; override;

    procedure AddTool(const ATool: TTSkillTool);
    procedure Prepare;
    function ExistingTargetFiles: TArray<String>;
    procedure Install;
  end;

resourcestring
  SDownloadFailed = 'Could not download the skills (HTTP %d).';

implementation

{ TTSkillTool }

constructor TTSkillTool.Create(
  const AFolder: String;
  const ACaption: String;
  const ADescription: String;
  const ATarget: String);
begin
  FFolder := AFolder;
  FCaption := ACaption;
  FDescription := ADescription;
  FTarget := ATarget;
end;

{ TTSkillTools }

class function TTSkillTools.All: TArray<TTSkillTool>;
begin
  result := [
    TTSkillTool.Create(
      'claude-code',
      'Claude Code',
      'Anthropic Claude Code (CLI and IDE)',
      '.claude\skills\'),
    TTSkillTool.Create(
      'cursor',
      'Cursor',
      'Cursor IDE',
      '.cursor\rules\'),
    TTSkillTool.Create(
      'copilot',
      'GitHub Copilot',
      'GitHub Copilot (VS Code and Visual Studio)',
      '.github\copilot-instructions.md'),
    TTSkillTool.Create(
      'windsurf',
      'Windsurf',
      'Windsurf (Codeium)',
      '.windsurf\rules\'),
    TTSkillTool.Create(
      'generic',
      'Other / generic',
      'Any other assistant (llms.txt and llm\)',
      'llm\')];
end;

{ TTSkillsInstaller }

constructor TTSkillsInstaller.Create(const AProjectDirectory: String);
begin
  inherited Create;
  FProjectDirectory := AProjectDirectory;
  FTools := TList<TTSkillTool>.Create;
end;

destructor TTSkillsInstaller.Destroy;
begin
  Cleanup;
  FTools.Free;
  inherited Destroy;
end;

class function TTSkillsInstaller.RelativeName(
  const ABaseDirectory: String; const AFileName: String): String;
begin
  result := AFileName.Substring(
    ABaseDirectory.Length).TrimLeft([TPath.DirectorySeparatorChar]);
end;

function TTSkillsInstaller.DownloadArchive: String;
var
  LClient: THTTPClient;
  LStream: TFileStream;
  LResponse: IHTTPResponse;
begin
  result := TPath.GetTempFileName;
  LClient := THTTPClient.Create;
  try
    LStream := TFileStream.Create(result, fmCreate);
    try
      LResponse := LClient.Get(RepositoryUrl, LStream);
      if LResponse.StatusCode <> 200 then
        raise ETExpertException.Create(
          Format(SDownloadFailed, [LResponse.StatusCode]));
    finally
      LStream.Free;
    end;
  finally
    LClient.Free;
  end;
end;

function TTSkillsInstaller.ExtractArchive(
  const AArchiveFileName: String): String;
begin
  result := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(result);
  TZipFile.ExtractZipFile(AArchiveFileName, result);
end;

function TTSkillsInstaller.ToolSourceDirectory(
  const ATool: TTSkillTool): String;
begin
  result := TPath.Combine(
    TPath.Combine(FExtractedDirectory, ArchiveRoot), ATool.Folder);
end;

procedure TTSkillsInstaller.CopyTool(const ATool: TTSkillTool);
var
  LSourceDirectory: String;
  LFiles: TArray<String>;
  LFileName: String;
  LTargetFileName: String;
begin
  LSourceDirectory := ToolSourceDirectory(ATool);
  LFiles := TDirectory.GetFiles(
    LSourceDirectory, '*', TSearchOption.soAllDirectories);
  for LFileName in LFiles do
  begin
    LTargetFileName := TPath.Combine(
      FProjectDirectory, RelativeName(LSourceDirectory, LFileName));
    TDirectory.CreateDirectory(TPath.GetDirectoryName(LTargetFileName));
    TFile.Copy(LFileName, LTargetFileName, True);
  end;
end;

procedure TTSkillsInstaller.Cleanup;
begin
  if (not FExtractedDirectory.IsEmpty) and
    TDirectory.Exists(FExtractedDirectory) then
    TDirectory.Delete(FExtractedDirectory, True);
  if (not FArchiveFileName.IsEmpty) and TFile.Exists(FArchiveFileName) then
    TFile.Delete(FArchiveFileName);
end;

procedure TTSkillsInstaller.AddTool(const ATool: TTSkillTool);
begin
  FTools.Add(ATool);
end;

procedure TTSkillsInstaller.Prepare;
begin
  FArchiveFileName := DownloadArchive;
  FExtractedDirectory := ExtractArchive(FArchiveFileName);
end;

function TTSkillsInstaller.ExistingTargetFiles: TArray<String>;
var
  LResult: TList<String>;
  LTool: TTSkillTool;
  LSourceDirectory: String;
  LFiles: TArray<String>;
  LFileName: String;
  LRelativeName: String;
begin
  LResult := TList<String>.Create;
  try
    for LTool in FTools do
    begin
      LSourceDirectory := ToolSourceDirectory(LTool);
      LFiles := TDirectory.GetFiles(
        LSourceDirectory, '*', TSearchOption.soAllDirectories);
      for LFileName in LFiles do
      begin
        LRelativeName := RelativeName(LSourceDirectory, LFileName);
        if TFile.Exists(TPath.Combine(FProjectDirectory, LRelativeName)) then
          LResult.Add(LRelativeName);
      end;
    end;
    result := LResult.ToArray;
  finally
    LResult.Free;
  end;
end;

procedure TTSkillsInstaller.Install;
var
  LTool: TTSkillTool;
begin
  for LTool in FTools do
    CopyTool(LTool);
end;

end.
