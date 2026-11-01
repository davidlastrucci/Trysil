(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Folder;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,

  Trysil.Setup.Consts;

type

{ TTInstallFolder }

  TTInstallFolder = class
  strict private
    FDirectory: String;

    function IsEmpty: Boolean;
    procedure DeleteDirectories;
    procedure DeleteFiles;
  public
    constructor Create(const ADirectory: String);

    function CanInstall: Boolean;
    procedure Clean;
    procedure Remove;
    function LogFileName: String;
    function SetupFileName: String;

    property Directory: String read FDirectory;
  end;

implementation

{ TTInstallFolder }

constructor TTInstallFolder.Create(const ADirectory: String);
begin
  inherited Create;
  FDirectory := ExcludeTrailingPathDelimiter(ADirectory);
end;

function TTInstallFolder.IsEmpty: Boolean;
begin
  result := TDirectory.IsEmpty(FDirectory);
end;

function TTInstallFolder.LogFileName: String;
begin
  result := TPath.Combine(FDirectory, SLogFileName);
end;

function TTInstallFolder.SetupFileName: String;
begin
  result := TPath.Combine(FDirectory, SSetupFileName);
end;

function TTInstallFolder.CanInstall: Boolean;
begin
  result :=
    (not TDirectory.Exists(FDirectory)) or
    IsEmpty or
    TFile.Exists(LogFileName);
end;

procedure TTInstallFolder.DeleteDirectories;
var
  LDirectory: String;
begin
  for LDirectory in TDirectory.GetDirectories(FDirectory) do
    TDirectory.Delete(LDirectory, True);
end;

procedure TTInstallFolder.DeleteFiles;
var
  LFileName: String;
begin
  for LFileName in TDirectory.GetFiles(FDirectory) do
    if not SameText(LFileName, ParamStr(0)) then
      TFile.Delete(LFileName);
end;

procedure TTInstallFolder.Clean;
begin
  if not CanInstall then
    raise ETSetupException.CreateFmt(SFolderNotOwned, [FDirectory]);
  if TDirectory.Exists(FDirectory) then
  begin
    DeleteDirectories;
    DeleteFiles;
  end;
  TDirectory.CreateDirectory(FDirectory);
end;

procedure TTInstallFolder.Remove;
begin
  if TDirectory.Exists(FDirectory) then
  begin
    DeleteDirectories;
    DeleteFiles;
    if IsEmpty then
      TDirectory.Delete(FDirectory);
  end;
end;

end.
