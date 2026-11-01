(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
program Trysil.Setup;

uses
  Vcl.Forms,
  Trysil.Expert.Consts in '..\Trysil.Expert\Classes\Trysil.Expert.Consts.pas',
  Trysil.Expert.Validator in '..\Trysil.Expert\Classes\Trysil.Expert.Validator.pas',
  Trysil.Expert.UI.Wizard in '..\Trysil.Expert\UI\Trysil.Expert.UI.Wizard.pas',
  Trysil.Setup.Consts in 'Classes\Trysil.Setup.Consts.pas',
  Trysil.Setup.Log in 'Classes\Trysil.Setup.Log.pas',
  Trysil.Setup.Process in 'Classes\Trysil.Setup.Process.pas',
  Trysil.Setup.MSBuild in 'Classes\Trysil.Setup.MSBuild.pas',
  Trysil.Setup.Probe in 'Classes\Trysil.Setup.Probe.pas',
  Trysil.Setup.Delphi in 'Classes\Trysil.Setup.Delphi.pas',
  Trysil.Setup.Detector in 'Classes\Trysil.Setup.Detector.pas',
  Trysil.Setup.Release in 'Classes\Trysil.Setup.Release.pas',
  Trysil.Setup.Folder in 'Classes\Trysil.Setup.Folder.pas',
  Trysil.Setup.IDESettings in 'Classes\Trysil.Setup.IDESettings.pas',
  Trysil.Setup.Installation in 'Classes\Trysil.Setup.Installation.pas',
  Trysil.Setup.Builder in 'Classes\Trysil.Setup.Builder.pas',
  Trysil.Setup.Installer in 'Classes\Trysil.Setup.Installer.pas',
  Trysil.Setup.Thread in 'Classes\Trysil.Setup.Thread.pas',
  Trysil.Setup.Startup in 'Classes\Trysil.Setup.Startup.pas',
  Trysil.Setup.UI.Main in 'UI\Trysil.Setup.UI.Main.pas' {SetupForm};

{$R *.res}
{$R 'Trysil.Setup.Probe.res' 'Trysil.Setup.Probe.rc'}

var
  LStartup: TTStartup;

begin
  ReportMemoryLeaksOnShutdown := True;
  LStartup := TTStartup.Create;
  try
    if LStartup.CanRun then
    begin
      Application.Initialize;
      Application.MainFormOnTaskbar := True;
      Application.Title := 'Trysil Setup';
      Application.CreateForm(TTSetupForm, SetupForm);
      Application.Run;
    end;
  finally
    LStartup.Free;
  end;
end.
