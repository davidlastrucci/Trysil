(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Startup;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  Winapi.TlHelp32,
  System.SysUtils,
  System.Classes,
  System.UITypes,
  System.IOUtils,
  Vcl.Dialogs,

  Trysil.Setup.Consts,
  Trysil.Setup.Installation;

type

{ TTStartup }

  TTStartup = class
  strict private
    FInstallation: TTInstallation;

    function IsIDERunning: Boolean;
    function MustCloseIDE: Boolean;
    function IsInstalledCopy: Boolean;
    function Arguments: String;
    procedure Relaunch;
    procedure CleanTemporaryCopies;
  public
    constructor Create;
    destructor Destroy; override;

    function CanRun: Boolean;
  end;

implementation

{ TTStartup }

constructor TTStartup.Create;
begin
  inherited Create;
  FInstallation := TTInstallation.Create;
end;

destructor TTStartup.Destroy;
begin
  FInstallation.Free;
  inherited Destroy;
end;

function TTStartup.IsIDERunning: Boolean;
var
  LSnapshot: THandle;
  LEntry: TProcessEntry32;
begin
  result := False;
  LSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  try
    LEntry := Default(TProcessEntry32);
    LEntry.dwSize := SizeOf(LEntry);
    if Process32First(LSnapshot, LEntry) then
      repeat
        result := result or SameText(String(LEntry.szExeFile), SIDEProcess);
      until not Process32Next(LSnapshot, LEntry);
  finally
    CloseHandle(LSnapshot);
  end;
end;

function TTStartup.MustCloseIDE: Boolean;
begin
{$IFDEF DEBUG}
  result := False;
{$ELSE}
  result := IsIDERunning;
{$ENDIF}
end;

function TTStartup.IsInstalledCopy: Boolean;
begin
  FInstallation.Load;
  result :=
    FInstallation.Installed and
    SameText(
      TPath.GetDirectoryName(ParamStr(0)),
      ExcludeTrailingPathDelimiter(FInstallation.Directory));
end;

function TTStartup.Arguments: String;
begin
  if FindCmdLineSwitch(SUninstallSwitch) then
    result := Format('/%s', [SUninstallSwitch])
  else
    result := String.Empty;
end;

procedure TTStartup.Relaunch;
var
  LFileName: String;
begin
  LFileName := TPath.Combine(
    TPath.GetTempPath,
    Format(STemporarySetupFileName, [TGUID.NewGuid.ToString]));
  TFile.Copy(ParamStr(0), LFileName, True);
  ShellExecute(
    0, 'open', PChar(LFileName), PChar(Arguments), nil, SW_SHOWNORMAL);
end;

procedure TTStartup.CleanTemporaryCopies;
var
  LFileName: String;
begin
  for LFileName in TDirectory.GetFiles(
    TPath.GetTempPath, Format(STemporarySetupFileName, ['*'])) do
    if not SameText(LFileName, ParamStr(0)) then
      DeleteFile(LFileName);
end;

function TTStartup.CanRun: Boolean;
begin
  result := False;
  CleanTemporaryCopies;
  if MustCloseIDE then
    MessageDlg(SCloseIDE, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0)
  else if IsInstalledCopy then
    Relaunch
  else
    result := True;
end;

end.
