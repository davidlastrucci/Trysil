(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
program Blob;

uses
  Vcl.Forms,
  Blob.PictureHelper in 'Blob.PictureHelper.pas',
  Blob.Model in 'Blob.Model.pas',
  Blob.MainForm in 'Blob.MainForm.pas' {MainForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
