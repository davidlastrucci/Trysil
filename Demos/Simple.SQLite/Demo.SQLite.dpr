program Demo.SQLite;

uses
  Vcl.Forms,
  Trysil.Vcl.ListView in '..\..\Trysil.UI\Trysil.Vcl.ListView.pas',
  Demo.Model in 'Demo.Model.pas',
  Demo.MainForm in 'Demo.MainForm.pas' {MainForm},
  Demo.EditDialog in 'Demo.EditDialog.pas' {EditDialog},
  Demo.ListView in 'Demo.ListView.pas',
  Demo.DatabaseBuilder in 'Demo.DatabaseBuilder.pas' {DatabaseBuilder: TDataModule};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
