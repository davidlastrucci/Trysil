(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.Installation;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Win.Registry,

  Trysil.Setup.Consts;

type

{ TTInstallation }

  TTInstallation = class
  strict private
    FInstalled: Boolean;
    FDirectory: String;
    FVersion: String;
    FCommit: String;
    FVersions: TArray<String>;
    FExpert: Boolean;

    procedure ReadChoices(const ARegistry: TRegistry);
    procedure WriteUninstall(const ARegistry: TRegistry);
    procedure WriteChoices(const ARegistry: TRegistry);
    procedure WriteKey;
  public
    constructor Create;

    procedure Load;
    procedure Save(
      const ADirectory: String;
      const AVersion: String;
      const ACommit: String;
      const AVersions: TArray<String>;
      const AExpert: Boolean);
    procedure Delete;

    property Installed: Boolean read FInstalled;
    property Directory: String read FDirectory;
    property Version: String read FVersion;
    property Commit: String read FCommit;
    property Versions: TArray<String> read FVersions;
    property Expert: Boolean read FExpert;
  end;

implementation

{ TTInstallation }

constructor TTInstallation.Create;
begin
  inherited Create;
  FInstalled := False;
  FDirectory := String.Empty;
  FVersion := String.Empty;
  FCommit := String.Empty;
  FVersions := [];
  FExpert := False;
end;

procedure TTInstallation.ReadChoices(const ARegistry: TRegistry);
begin
  FDirectory := ARegistry.ReadString(SInstallLocationValue);
  FVersion := ARegistry.ReadString(SDisplayVersionValue);
  FCommit := ARegistry.ReadString(SCommitValue);
  FVersions := ARegistry.ReadString(SVersionsValue).Split(
    [SSearchPathSeparator], TStringSplitOptions.ExcludeEmpty);
  FExpert :=
    ARegistry.ValueExists(SExpertValue) and
    ARegistry.ReadBool(SExpertValue);
end;

procedure TTInstallation.Load;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    FInstalled := LRegistry.OpenKeyReadOnly(SUninstallKey);
    if FInstalled then
      ReadChoices(LRegistry);
  finally
    LRegistry.Free;
  end;
end;

procedure TTInstallation.WriteUninstall(const ARegistry: TRegistry);
var
  LSetupFileName: String;
begin
  LSetupFileName := TPath.Combine(FDirectory, SSetupFileName);
  ARegistry.WriteString(SDisplayNameValue, SDisplayName);
  ARegistry.WriteString(SDisplayVersionValue, FVersion);
  ARegistry.WriteString(SPublisherValue, SPublisher);
  ARegistry.WriteString(SUrlInfoAboutValue, SProjectUrl);
  ARegistry.WriteString(SInstallLocationValue, FDirectory);
  ARegistry.WriteString(SDisplayIconValue, LSetupFileName);
  ARegistry.WriteString(SUninstallStringValue,
    Format(SUninstallCommand, [LSetupFileName, SUninstallSwitch]));
  ARegistry.WriteInteger(SNoModifyValue, 1);
  ARegistry.WriteInteger(SNoRepairValue, 1);
end;

procedure TTInstallation.WriteChoices(const ARegistry: TRegistry);
begin
  ARegistry.WriteString(
    SVersionsValue, String.Join(SSearchPathSeparator, FVersions));
  ARegistry.WriteBool(SExpertValue, FExpert);
  ARegistry.WriteString(SCommitValue, FCommit);
end;

procedure TTInstallation.WriteKey;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    if LRegistry.OpenKey(SUninstallKey, True) then
    begin
      WriteUninstall(LRegistry);
      WriteChoices(LRegistry);
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TTInstallation.Save(
  const ADirectory: String;
  const AVersion: String;
  const ACommit: String;
  const AVersions: TArray<String>;
  const AExpert: Boolean);
begin
  FDirectory := ExcludeTrailingPathDelimiter(ADirectory);
  FVersion := AVersion;
  FCommit := ACommit;
  FVersions := AVersions;
  FExpert := AExpert;
  WriteKey;
  FInstalled := True;
end;

procedure TTInstallation.Delete;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    LRegistry.DeleteKey(SUninstallKey);
    FInstalled := False;
  finally
    LRegistry.Free;
  end;
end;

end.
