(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.APIRest;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Imaging.PngImage,

  Trysil.Expert.Validator,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Wizard,
  Trysil.Expert.APIRest.Parameters,
  Trysil.Expert.APIRestCreator;

type

{ TTAPIRestForm }

  TTAPIRestForm = class(TTThemedForm)
    SaveDialog: TSaveDialog;
    ProjectPagePanel: TPanel;
    ProjectPageGroupBox: TGroupBox;
    ProjectDirectoryLabel: TLabel;
    ProjectDirectoryTextbox: TEdit;
    ProjectNameLabel: TLabel;
    ProjectNameTextBox: TEdit;
    ProjectNameButton: TSpeedButton;
    APIPagePanel: TPanel;
    APIPageGroupbox: TGroupBox;
    APIBaseUriLabel: TLabel;
    APIBaseUriTextbox: TEdit;
    APIPortLabel: TLabel;
    APIPortTextbox: TEdit;
    APIUrlLabel: TLabel;
    APIMultiTenantCheckbox: TCheckBox;
    APIAuthorizationCheckbox: TCheckBox;
    APIRS256Checkbox: TCheckBox;
    APILogCheckbox: TCheckBox;
    APISqidsCheckbox: TCheckBox;
    APISqidsNotSupportedLabel: TLabel;
    DatabasePagePanel: TPanel;
    DatabasePageGroupBox: TGroupBox;
    DatabaseDriverLabel: TLabel;
    DatabaseDriverCombobox: TComboBox;
    DatabaseHostLabel: TLabel;
    DatabaseHostTextbox: TEdit;
    DatabasePortLabel: TLabel;
    DatabasePortTextbox: TEdit;
    DatabaseUsernameLabel: TLabel;
    DatabaseUsernameTextbox: TEdit;
    DatabasePasswordLabel: TLabel;
    DatabasePasswordTextbox: TEdit;
    DatabaseNameLabel: TLabel;
    DatabaseNameTextbox: TEdit;
    LogDatabasePagePanel: TPanel;
    LogDatabasePageGroupBox: TGroupBox;
    LogDriverLabel: TLabel;
    LogDriverCombobox: TComboBox;
    LogHostLabel: TLabel;
    LogHostTextbox: TEdit;
    LogPortLabel: TLabel;
    LogPortTextbox: TEdit;
    LogUsernameLabel: TLabel;
    LogUsernameTextbox: TEdit;
    LogPasswordLabel: TLabel;
    LogPasswordTextbox: TEdit;
    LogDatabaseNameLabel: TLabel;
    LogDatabaseNameTextbox: TEdit;
    ServicePagePanel: TPanel;
    ServicePageGroupBox: TGroupBox;
    ServiceNameLabel: TLabel;
    ServiceNameTextbox: TEdit;
    ServiceDescriptionLabel: TLabel;
    ServiceDescriptionTextbox: TEdit;
    BackButton: TButton;
    NextButton: TButton;
    FinishButton: TButton;
    CancelButton: TButton;
    procedure ProjectNameButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
    procedure CalculateUrlLabel(Sender: TObject);
    procedure APIMultiTenantCheckboxClick(Sender: TObject);
    procedure APIAuthorizationCheckboxClick(Sender: TObject);
    procedure DatabaseDriverComboboxClick(Sender: TObject);
    procedure LogDriverComboboxClick(Sender: TObject);
  strict private
    const MariaDBIndex = 2;
    const OracleIndex = 3;
    const PostgreSQLIndex = 4;
    const SQLiteIndex = 6;
    const SqidsSupported = CompilerVersion >= 36;
  strict private
    FWizard: TTWizard;

    procedure EnableSqids;
    procedure EnableDisableButtons;
    procedure EnableServer(
      const ADriver: TComboBox;
      const AHost: TEdit;
      const APort: TEdit);
    procedure ShowErrors(const AValidator: TTValidator);

    procedure CheckProjectDirectory(const AValidator: TTValidator);
    function CheckProject: Boolean;
    function CheckAPI: Boolean;
    function CheckDatabase(
      const ADriver: TComboBox;
      const AHost: TEdit;
      const AUsername: TEdit;
      const ADatabaseName: TEdit): Boolean;
    function CheckMainDatabase: Boolean;
    function LogDatabaseEnabled: Boolean;
    function CheckLogDatabase: Boolean;
    function CheckService: Boolean;

    function GetFeatures: TTApiRestFeatures;
    function GetDescription: String;
    procedure FillDatabase(const AParameters: TTApiRestParameters);
    procedure FillLogDatabase(const AParameters: TTApiRestParameters);
    procedure FillParameters(const AParameters: TTApiRestParameters);
    procedure CreateProject(const AParameters: TTApiRestParameters);
  strict protected
    function HelpPage: String; override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class procedure ShowDialog;
  end;

implementation

{$R *.dfm}

{ TTAPIRestForm }

constructor TTAPIRestForm.Create;
begin
  inherited Create(nil);
  FWizard := TTWizard.Create(Handle);
end;

destructor TTAPIRestForm.Destroy;
begin
  FWizard.Free;
  inherited Destroy;
end;

procedure TTAPIRestForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FWizard.AddPage(TTWizardPage.Create(
    ProjectPagePanel, ProjectDirectoryTextbox, nil, CheckProject));
  FWizard.AddPage(TTWizardPage.Create(
    APIPagePanel, APIBaseUriTextbox, nil, CheckAPI));
  FWizard.AddPage(TTWizardPage.Create(
    DatabasePagePanel, DatabaseDriverCombobox, nil, CheckMainDatabase));
  FWizard.AddPage(TTWizardPage.Create(
    LogDatabasePagePanel,
    LogDriverCombobox,
    LogDatabaseEnabled,
    CheckLogDatabase));
  FWizard.AddPage(TTWizardPage.Create(
    ServicePagePanel, ServiceNameTextbox, nil, CheckService));

  FWizard.Start;
  EnableSqids;
  EnableDisableButtons;
end;

procedure TTAPIRestForm.EnableSqids;
begin
  APISqidsCheckbox.Enabled := SqidsSupported;
  APISqidsNotSupportedLabel.Visible := not SqidsSupported;
end;

procedure TTAPIRestForm.EnableDisableButtons;
begin
  BackButton.Enabled := not FWizard.IsFirst;
  NextButton.Enabled := not FWizard.IsLast;
  FinishButton.Enabled := FWizard.IsLast;
end;

procedure TTAPIRestForm.CalculateUrlLabel(Sender: TObject);
var
  LFormat: String;
begin
  if String(APIBaseUriTextbox.Text).StartsWith('/') then
    LFormat := 'http://127.0.0.1:%s%s'
  else
    LFormat := 'http://127.0.0.1:%s/%s';

  APIUrlLabel.Caption :=
    Format(LFormat, [APIPortTextbox.Text, APIBaseUriTextbox.Text]);
end;

procedure TTAPIRestForm.APIMultiTenantCheckboxClick(Sender: TObject);
begin
  if APIMultiTenantCheckbox.Checked then
    DatabasePageGroupBox.Caption := 'Tenant (localhost) database  '
  else
    DatabasePageGroupBox.Caption := 'Database  ';
end;

procedure TTAPIRestForm.APIAuthorizationCheckboxClick(Sender: TObject);
begin
  APIRS256Checkbox.Enabled := APIAuthorizationCheckbox.Checked;
  if not APIRS256Checkbox.Enabled then
    APIRS256Checkbox.Checked := False;
end;

procedure TTAPIRestForm.EnableServer(
  const ADriver: TComboBox;
  const AHost: TEdit;
  const APort: TEdit);
begin
  AHost.Enabled := ADriver.ItemIndex <> SQLiteIndex;
  APort.Enabled := ADriver.ItemIndex in [
    MariaDBIndex, OracleIndex, PostgreSQLIndex];
  if not AHost.Enabled then
    AHost.Text := String.Empty;
  if not APort.Enabled then
    APort.Text := '0';
end;

procedure TTAPIRestForm.DatabaseDriverComboboxClick(Sender: TObject);
begin
  EnableServer(
    DatabaseDriverCombobox, DatabaseHostTextbox, DatabasePortTextbox);
end;

procedure TTAPIRestForm.LogDriverComboboxClick(Sender: TObject);
begin
  EnableServer(LogDriverCombobox, LogHostTextbox, LogPortTextbox);
end;

procedure TTAPIRestForm.ShowErrors(const AValidator: TTValidator);
begin
  if not AValidator.IsValid then
    MessageDlg(
      AValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TTAPIRestForm.CheckProjectDirectory(const AValidator: TTValidator);
var
  LDirectory: String;
begin
  LDirectory := ProjectDirectoryTextbox.Text;
  AValidator.Check(
    LDirectory.IsEmpty,
    'Directory name cannot be empty.');

  AValidator.Check(
    (not LDirectory.IsEmpty) and (not TPath.IsPathRooted(LDirectory)),
    'Directory must be an absolute path.');

  AValidator.Check(
    (TDirectory.Exists(LDirectory) and
      (Length(TDirectory.GetFiles(LDirectory)) > 0)),
    'Directory contain files.');
end;

function TTAPIRestForm.CheckProject: Boolean;
var
  LValidator: TTValidator;
begin
  LValidator := TTValidator.Create;
  try
    CheckProjectDirectory(LValidator);

    LValidator.Check(
      String(ProjectNameTextBox.Text).IsEmpty,
      'Project name cannot be empty.');

    result := LValidator.IsValid;
    ShowErrors(LValidator);
  finally
    LValidator.Free;
  end;
end;

function TTAPIRestForm.CheckAPI: Boolean;
var
  LValidator: TTValidator;
  LPort: Integer;
begin
  LValidator := TTValidator.Create;
  try
    LValidator.Check(
      not Integer.TryParse(APIPortTextbox.Text, LPort),
      'Port must be a number.');
    result := LValidator.IsValid;
    ShowErrors(LValidator);
  finally
    LValidator.Free;
  end;
end;

function TTAPIRestForm.CheckDatabase(
  const ADriver: TComboBox;
  const AHost: TEdit;
  const AUsername: TEdit;
  const ADatabaseName: TEdit): Boolean;
var
  LValidator: TTValidator;
  LServer: Boolean;
begin
  LServer := ADriver.ItemIndex <> SQLiteIndex;
  LValidator := TTValidator.Create;
  try
    LValidator.Check(
      LServer and String(AHost.Text).IsEmpty,
      'Host cannot be empty.');
    LValidator.Check(
      LServer and String(AUsername.Text).IsEmpty,
      'Username cannot be empty.');
    LValidator.Check(
      String(ADatabaseName.Text).IsEmpty,
      'Database name cannot be empty.');

    result := LValidator.IsValid;
    ShowErrors(LValidator);
  finally
    LValidator.Free;
  end;
end;

function TTAPIRestForm.CheckMainDatabase: Boolean;
begin
  result := CheckDatabase(
    DatabaseDriverCombobox,
    DatabaseHostTextbox,
    DatabaseUsernameTextbox,
    DatabaseNameTextbox);
end;

function TTAPIRestForm.LogDatabaseEnabled: Boolean;
begin
  result := APILogCheckbox.Checked;
end;

function TTAPIRestForm.CheckLogDatabase: Boolean;
begin
  result := CheckDatabase(
    LogDriverCombobox,
    LogHostTextbox,
    LogUsernameTextbox,
    LogDatabaseNameTextbox);
end;

function TTAPIRestForm.CheckService: Boolean;
var
  LValidator: TTValidator;
begin
  LValidator := TTValidator.Create;
  try
    LValidator.Check(
      String(ServiceNameTextbox.Text).IsEmpty,
      'Service name cannot be empty.');
    LValidator.Check(
      String(ServiceNameTextbox.Text).ToLower().Equals(
        String(ProjectNameTextBox.Text).ToLower()),
      'Service name cannot be the same as project name.');

    result := LValidator.IsValid;
    ShowErrors(LValidator);
  finally
    LValidator.Free;
  end;
end;

procedure TTAPIRestForm.ProjectNameButtonClick(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    ProjectDirectoryTextbox.Text :=
      TPath.GetDirectoryName(SaveDialog.FileName);
    ProjectNameTextBox.Text :=
      TPath.GetFileNameWithoutExtension(SaveDialog.FileName);
  end;
end;

procedure TTAPIRestForm.BackButtonClick(Sender: TObject);
begin
  FWizard.PreviousPage;
  EnableDisableButtons;
end;

procedure TTAPIRestForm.NextButtonClick(Sender: TObject);
begin
  FWizard.NextPage;
  EnableDisableButtons;
end;

function TTAPIRestForm.GetFeatures: TTApiRestFeatures;
begin
  result := [];
  if APIMultiTenantCheckbox.Checked then
    Include(result, TTApiRestFeature.MultiTenant);
  if APIAuthorizationCheckbox.Checked then
    Include(result, TTApiRestFeature.Auth);
  if APIRS256Checkbox.Checked then
    Include(result, TTApiRestFeature.RS256);
  if APILogCheckbox.Checked then
    Include(result, TTApiRestFeature.Log);
  if APISqidsCheckbox.Checked then
    Include(result, TTApiRestFeature.Sqids);
end;

function TTAPIRestForm.GetDescription: String;
begin
  result := String(ServiceDescriptionTextbox.Text).Trim;
  if result.IsEmpty then
    result := Format('%s - API REST', [ProjectNameTextBox.Text]);
end;

procedure TTAPIRestForm.FillDatabase(
  const AParameters: TTApiRestParameters);
begin
  AParameters.Database.DriverIndex := DatabaseDriverCombobox.ItemIndex;
  AParameters.Database.Host := DatabaseHostTextbox.Text;
  AParameters.Database.Port := StrToIntDef(DatabasePortTextbox.Text, 0);
  AParameters.Database.Username := DatabaseUsernameTextbox.Text;
  AParameters.Database.Password := DatabasePasswordTextbox.Text;
  AParameters.Database.DatabaseName := DatabaseNameTextbox.Text;
end;

procedure TTAPIRestForm.FillLogDatabase(
  const AParameters: TTApiRestParameters);
begin
  AParameters.LogDatabase.DriverIndex := LogDriverCombobox.ItemIndex;
  AParameters.LogDatabase.Host := LogHostTextbox.Text;
  AParameters.LogDatabase.Port := StrToIntDef(LogPortTextbox.Text, 0);
  AParameters.LogDatabase.Username := LogUsernameTextbox.Text;
  AParameters.LogDatabase.Password := LogPasswordTextbox.Text;
  AParameters.LogDatabase.DatabaseName := LogDatabaseNameTextbox.Text;
end;

procedure TTAPIRestForm.FillParameters(
  const AParameters: TTApiRestParameters);
begin
  AParameters.Directory := ProjectDirectoryTextbox.Text;
  AParameters.ProjectName := ProjectNameTextBox.Text;
  AParameters.ServiceName := ServiceNameTextbox.Text;
  AParameters.Description := GetDescription;
  AParameters.BaseUri := APIBaseUriTextbox.Text;
  AParameters.Port := Integer.Parse(APIPortTextbox.Text);
  AParameters.Features := GetFeatures;
  FillDatabase(AParameters);
  if AParameters.Has(TTApiRestFeature.Log) then
    FillLogDatabase(AParameters);
end;

procedure TTAPIRestForm.CreateProject(
  const AParameters: TTApiRestParameters);
var
  LCreator: TTAPIRestCreator;
begin
  Screen.Cursor := crHourGlass;
  try
    LCreator := TTAPIRestCreator.Create(AParameters);
    try
      LCreator.CreateProject;
      LCreator.OpenProject;
    finally
      LCreator.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TTAPIRestForm.FinishButtonClick(Sender: TObject);
var
  LParameters: TTApiRestParameters;
begin
  if CheckService then
  begin
    LParameters := TTApiRestParameters.Create;
    try
      FillParameters(LParameters);
      CreateProject(LParameters);
    finally
      LParameters.Free;
    end;

    ModalResult := mrOk;
  end;
end;

function TTAPIRestForm.HelpPage: String;
begin
  result := 'api-rest/';
end;

class procedure TTAPIRestForm.ShowDialog;
var
  LDialog: TTAPIRestForm;
begin
  LDialog := TTAPIRestForm.Create;
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
