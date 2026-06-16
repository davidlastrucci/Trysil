program API;

uses
  Vcl.Forms,
  API.Context in 'API\API.Context.pas',
  API.Config in 'API\API.Config.pas',
  API.Http in 'API\API.Http.pas',
  API.Model.Company in 'API\Model\API.Model.Company.pas',
  API.Model.Employee in 'API\Model\API.Model.Employee.pas',
  API.Controller in 'API\Controllers\API.Controller.pas',
  API.MainForm in 'API.MainForm.pas' {APIMainForm},
  API.Authentication.Controller in 'API\Authentication\API.Authentication.Controller.pas',
  API.Authentication.JWT in 'API\Authentication\API.Authentication.JWT.pas',
  API.Authentication in 'API\Authentication\API.Authentication.pas',
  API.Log.Writer in 'API\Log\API.Log.Writer.pas',
  API.Log.Model in 'API\Log\API.Log.Model.pas';

{$R *.res}

begin
{$IFDEF DEBUG}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.CreateForm(TAPIMainForm, APIMainForm);
  Application.Run;
end.
