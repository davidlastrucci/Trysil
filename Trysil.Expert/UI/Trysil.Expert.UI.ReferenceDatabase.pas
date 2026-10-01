(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.ReferenceDatabase;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.PngImage,
  FireDAC.UI.Intf,
  FireDAC.Stan.Intf,
  FireDAC.Comp.UI,
  FireDAC.ConsoleUI.Wait,

  Trysil.Expert.Consts,
  Trysil.Expert.Validator,
  Trysil.Expert.Config,
  Trysil.Expert.SQLCreator,
  Trysil.Expert.SchemaReader,
  Trysil.Expert.UI.Themed;

type

{ TTCreateScript }

  TTCreateScript = reference to function(
    const AParameters: TTDatabaseParameters): String;

{ TTReferenceDatabaseForm }

  TTReferenceDatabaseForm = class(TTThemedForm)
    HostLabel: TLabel;
    HostTextbox: TEdit;
    PortLabel: TLabel;
    PortTextbox: TEdit;
    DatabaseLabel: TLabel;
    DatabaseTextbox: TEdit;
    DatabaseButton: TButton;
    UsernameLabel: TLabel;
    UsernameTextbox: TEdit;
    PasswordLabel: TLabel;
    PasswordTextbox: TEdit;
    OpenDialog: TOpenDialog;
    GenerateButton: TButton;
    CancelButton: TButton;
    WaitCursor: TFDGUIxWaitCursor;
    procedure DatabaseButtonClick(Sender: TObject);
    procedure GenerateButtonClick(Sender: TObject);
  strict private
    FConfig: TTLocalConfig;
    FDatabaseType: TTSQLCreatorType;
    FCreateScript: TTCreateScript;
    FScript: String;
    FValidator: TTValidator;

    function IsServer: Boolean;
    procedure EnableControls;
    procedure ConfigToControls;
    procedure ControlsToConfig;
    procedure CheckControls;
    function GetParameters: TTDatabaseParameters;
    procedure CreateScript;
  strict protected
    function HelpPage: String; override;
  public
    constructor Create(
      const AConfig: TTLocalConfig;
      const ADatabaseType: TTSQLCreatorType;
      const ACreateScript: TTCreateScript); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AConfig: TTLocalConfig;
      const ADatabaseType: TTSQLCreatorType;
      const ACreateScript: TTCreateScript;
      out AScript: String): Boolean;
  end;

implementation

{$R *.dfm}

{ TTReferenceDatabaseForm }

constructor TTReferenceDatabaseForm.Create(
  const AConfig: TTLocalConfig;
  const ADatabaseType: TTSQLCreatorType;
  const ACreateScript: TTCreateScript);
begin
  inherited Create(nil);
  FConfig := AConfig;
  FDatabaseType := ADatabaseType;
  FCreateScript := ACreateScript;
  FScript := String.Empty;
  FValidator := TTValidator.Create;
end;

destructor TTReferenceDatabaseForm.Destroy;
begin
  FValidator.Free;
  inherited Destroy;
end;

procedure TTReferenceDatabaseForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ConfigToControls;
  EnableControls;
end;

function TTReferenceDatabaseForm.IsServer: Boolean;
begin
  result := FDatabaseType <> TTSQLCreatorType.ctSQLite;
end;

procedure TTReferenceDatabaseForm.EnableControls;
begin
  HostTextbox.Enabled := IsServer;
  UsernameTextbox.Enabled := IsServer;
  PasswordTextbox.Enabled := IsServer;
  DatabaseButton.Enabled := not IsServer;
  PortTextbox.Enabled := FDatabaseType in [
    TTSQLCreatorType.ctMariaDB,
    TTSQLCreatorType.ctOracle,
    TTSQLCreatorType.ctPostgreSQL];
  if not HostTextbox.Enabled then
    HostTextbox.Text := String.Empty;
  if not PortTextbox.Enabled then
    PortTextbox.Text := '0';
end;

procedure TTReferenceDatabaseForm.ConfigToControls;
begin
  HostTextbox.Text := FConfig.ReferenceHost;
  PortTextbox.Text := FConfig.ReferencePort.ToString;
  DatabaseTextbox.Text := FConfig.ReferenceDatabase;
  UsernameTextbox.Text := FConfig.ReferenceUsername;
end;

procedure TTReferenceDatabaseForm.ControlsToConfig;
begin
  FConfig.ReferenceHost := HostTextbox.Text;
  FConfig.ReferencePort := StrToIntDef(PortTextbox.Text, 0);
  FConfig.ReferenceDatabase := DatabaseTextbox.Text;
  FConfig.ReferenceUsername := UsernameTextbox.Text;
  FConfig.Save;
end;

procedure TTReferenceDatabaseForm.CheckControls;
begin
  FValidator.Clear;
  FValidator.Check(
    IsServer and String(HostTextbox.Text).IsEmpty, SHostEmpty);
  FValidator.Check(String(DatabaseTextbox.Text).IsEmpty, SDatabaseEmpty);
  FValidator.Check(
    IsServer and String(UsernameTextbox.Text).IsEmpty, SUsernameEmpty);
end;

function TTReferenceDatabaseForm.GetParameters: TTDatabaseParameters;
begin
  result.DatabaseType := FDatabaseType;
  result.Host := HostTextbox.Text;
  result.Port := StrToIntDef(PortTextbox.Text, 0);
  result.Database := DatabaseTextbox.Text;
  result.Username := UsernameTextbox.Text;
  result.Password := PasswordTextbox.Text;
end;

procedure TTReferenceDatabaseForm.CreateScript;
begin
  Screen.Cursor := crHourGlass;
  try
    FScript := FCreateScript(GetParameters);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TTReferenceDatabaseForm.DatabaseButtonClick(Sender: TObject);
begin
  OpenDialog.FileName := DatabaseTextbox.Text;
  if OpenDialog.Execute then
    DatabaseTextbox.Text := OpenDialog.FileName;
end;

procedure TTReferenceDatabaseForm.GenerateButtonClick(Sender: TObject);
begin
  CheckControls;
  if not FValidator.IsValid then
    MessageDlg(FValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
  else
  begin
    ControlsToConfig;
    CreateScript;
    ModalResult := mrOk;
  end;
end;

function TTReferenceDatabaseForm.HelpPage: String;
begin
  result := 'generate-sql/#alter-script';
end;

class function TTReferenceDatabaseForm.ShowDialog(
  const AConfig: TTLocalConfig;
  const ADatabaseType: TTSQLCreatorType;
  const ACreateScript: TTCreateScript;
  out AScript: String): Boolean;
var
  LDialog: TTReferenceDatabaseForm;
begin
  LDialog := TTReferenceDatabaseForm.Create(
    AConfig, ADatabaseType, ACreateScript);
  try
    result := LDialog.ShowModal = mrOk;
    AScript := LDialog.FScript;
  finally
    LDialog.Free;
  end;
end;

end.
