(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.MSBuild;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,

  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Process;

type

{ TTMSBuild }

  TTMSBuild = class
  strict private
    FRootDir: String;
    FLog: TTSetupLog;

    function CommandLine(
      const AProject: String;
      const AConfig: String;
      const APlatform: String): String;
  public
    constructor Create(const ARootDir: String; const ALog: TTSetupLog);

    function Build(
      const AProject: String;
      const AConfig: String;
      const APlatform: String): Boolean;
  end;

implementation

{ TTMSBuild }

constructor TTMSBuild.Create(const ARootDir: String; const ALog: TTSetupLog);
begin
  inherited Create;
  FRootDir := ARootDir;
  FLog := ALog;
end;

function TTMSBuild.CommandLine(
  const AProject: String;
  const AConfig: String;
  const APlatform: String): String;
begin
  result := Format(SMSBuildCommand, [
    GetEnvironmentVariable(SComSpecVariable),
    TPath.Combine(FRootDir, SRsvars),
    AProject,
    AConfig,
    APlatform]);
end;

function TTMSBuild.Build(
  const AProject: String;
  const AConfig: String;
  const APlatform: String): Boolean;
var
  LProcess: TTProcess;
begin
  LProcess := TTProcess.Create(
    CommandLine(AProject, AConfig, APlatform), FLog.Add);
  try
    result := (LProcess.Execute = 0);
  finally
    LProcess.Free;
  end;
end;

end.
