(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Thread;

{$SCOPEDENUMS ON}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Progress,
  Trysil.Setup.Delphi,
  Trysil.Setup.Detector,
  Trysil.Setup.Folder,
  Trysil.Setup.Release,
  Trysil.Setup.Installation,
  Trysil.Setup.Installer;

type

{ TTSetupMode }

  TTSetupMode = (Install, Update, Uninstall);

{ TTSetupThread }

  TTSetupThread = class(TThread)
  strict private
    FMode: TTSetupMode;
    FLog: TTSetupLog;
    FProgress: TTSetupProgress;
    FInstallation: TTInstallation;
    FOptions: TTInstallOptions;
    FMaster: Boolean;
    FSucceeded: Boolean;
    FHasErrors: Boolean;

    procedure Run(const AInstaller: TTInstaller);
    function LogDirectory: String;
    procedure SaveLog;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const AMode: TTSetupMode;
      const ALog: TTSetupLog;
      const AProgress: TTSetupProgress;
      const AInstallation: TTInstallation;
      const AOptions: TTInstallOptions;
      const AMaster: Boolean);

    property Succeeded: Boolean read FSucceeded;
    property HasErrors: Boolean read FHasErrors;
  end;

{ TTDetectThread }

  TTDetectThread = class(TThread)
  strict private
    FLog: TTSetupLog;
    FVersions: TObjectList<TTDelphiVersion>;
  protected
    procedure Execute; override;
  public
    constructor Create(
      const ALog: TTSetupLog;
      const AVersions: TObjectList<TTDelphiVersion>);
  end;

{ TTReleaseThread }

  TTReleaseThread = class(TThread)
  strict private
    FVersion: String;

    function FetchVersion(const ALog: TTSetupLog): String;
  protected
    procedure Execute; override;
  public
    constructor Create;

    property Version: String read FVersion;
  end;

implementation

{ TTSetupThread }

constructor TTSetupThread.Create(
  const AMode: TTSetupMode;
  const ALog: TTSetupLog;
  const AProgress: TTSetupProgress;
  const AInstallation: TTInstallation;
  const AOptions: TTInstallOptions;
  const AMaster: Boolean);
begin
  inherited Create(True);
  FMode := AMode;
  FLog := ALog;
  FProgress := AProgress;
  FInstallation := AInstallation;
  FOptions := AOptions;
  FMaster := AMaster;
  FSucceeded := False;
  FHasErrors := False;
end;

procedure TTSetupThread.Run(const AInstaller: TTInstaller);
begin
  case FMode of
    TTSetupMode.Install: AInstaller.Install(FOptions);
    TTSetupMode.Update: AInstaller.Update;
    TTSetupMode.Uninstall: AInstaller.Uninstall;
  end;
end;

function TTSetupThread.LogDirectory: String;
begin
  if Assigned(FOptions) then
    result := FOptions.Directory
  else
    result := FInstallation.Directory;
end;

procedure TTSetupThread.SaveLog;
var
  LFolder: TTInstallFolder;
begin
  if (FMode <> TTSetupMode.Uninstall) and
    TDirectory.Exists(LogDirectory) then
  begin
    LFolder := TTInstallFolder.Create(LogDirectory);
    try
      FLog.SaveToFile(LFolder.LogFileName);
    finally
      LFolder.Free;
    end;
  end;
end;

procedure TTSetupThread.Execute;
var
  LInstaller: TTInstaller;
begin
  LInstaller := TTInstaller.Create(
    FLog, FProgress, FInstallation, FMaster);
  try
    try
      Run(LInstaller);
      FSucceeded := True;
      FHasErrors := LInstaller.HasErrors;
    except
      on E: Exception do
        FLog.AddFormat(SError, [E.Message]);
    end;
    SaveLog;
  finally
    LInstaller.Free;
  end;
end;

{ TTDetectThread }

constructor TTDetectThread.Create(
  const ALog: TTSetupLog;
  const AVersions: TObjectList<TTDelphiVersion>);
begin
  inherited Create(True);
  FLog := ALog;
  FVersions := AVersions;
end;

procedure TTDetectThread.Execute;
var
  LDetector: TTDelphiDetector;
begin
  LDetector := TTDelphiDetector.Create(FLog);
  try
    try
      LDetector.DetectAll(FVersions);
    except
      on E: Exception do
        FLog.AddFormat(SError, [E.Message]);
    end;
  finally
    LDetector.Free;
  end;
end;

{ TTReleaseThread }

constructor TTReleaseThread.Create;
begin
  inherited Create(True);
  FVersion := String.Empty;
end;

function TTReleaseThread.FetchVersion(const ALog: TTSetupLog): String;
var
  LDownloader: TTReleaseDownloader;
begin
  LDownloader := TTReleaseDownloader.Create(ALog, False);
  try
    LDownloader.Fetch;
    result := LDownloader.Version;
  finally
    LDownloader.Free;
  end;
end;

procedure TTReleaseThread.Execute;
var
  LLog: TTSetupLog;
begin
  LLog := TTSetupLog.Create;
  try
    try
      FVersion := FetchVersion(LLog);
    except
      on Exception do
        FVersion := String.Empty;
    end;
  finally
    LLog.Free;
  end;
end;

end.
