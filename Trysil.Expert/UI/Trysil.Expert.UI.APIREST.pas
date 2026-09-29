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
  Trysil.Expert.APIRest.Parameters,
  Trysil.Expert.APIRestCreator;

type

{ TWizardPageEnabled }

  TWizardPageEnabled = function: Boolean of object;

{ TWizardPageCheck }

  TWizardPageCheck = function: Boolean of object;

{ TTWizardPage }

  TTWizardPage = record
  strict private
    FPage: TPanel;
    FControl: TWinControl;
    FEnabled: TWizardPageEnabled;
    FCheck: TWizardPageCheck;

    function GetVisible: Boolean;
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(
      const APage: TPanel;
      const AControl: TWinControl;
      const AEnabled: TWizardPageEnabled;
      const ACheck: TWizardPageCheck);

    function Enabled: Boolean;
    function Check: Boolean;
    procedure SetFocus;

    property Visible: Boolean read GetVisible write SetVisible;
  end;

{ TTWizard }

  TTWizard = class
  strict private
    FHandle: HWND;
    FPages: TList<TTWizardPage>;
    FIndex: Integer;

    function GetIsFirst: Boolean;
    function GetIsLast: Boolean;
  public
    constructor Create(const AHandle: HWND);
    destructor Destroy; override;

    procedure AddPage(const APage: TTWizardPage);
    procedure Start;

    procedure PreviousPage;
    procedure NextPage;

    property IsFirst: Boolean read GetIsFirst;
    property IsLast: Boolean read GetIsLast;
  end;

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
  strict private
    FWizard: TTWizard;

    procedure EnableDisableButtons;
    procedure EnableServer(
      const ADriver: TComboBox;
      const AHost: TEdit;
      const APort: TEdit);
    procedure ShowErrors(const AValidator: TTValidator);

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
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class procedure ShowDialog;
  end;

implementation

{$R *.dfm}

{ TTWizardPage }

constructor TTWizardPage.Create(
  const APage: TPanel;
  const AControl: TWinControl;
  const AEnabled: TWizardPageEnabled;
  const ACheck: TWizardPageCheck);
begin
  FPage := APage;
  FControl := AControl;
  FEnabled := AEnabled;
  FCheck := ACheck;
end;

function TTWizardPage.Enabled: Boolean;
begin
  if Assigned(FEnabled) then
    result := FEnabled
  else
    result := True;
end;

function TTWizardPage.Check: Boolean;
begin
  if Assigned(FCheck) then
    result := FCheck
  else
    result := True;
end;

procedure TTWizardPage.SetFocus;
begin
  FControl.SetFocus;
end;

function TTWizardPage.GetVisible: Boolean;
begin
  result := FPage.Visible;
end;

procedure TTWizardPage.SetVisible(const AValue: Boolean);
begin
  FPage.Visible := AValue;
  if FPage.Visible then
    FPage.Align := TAlign.alClient;
end;

{ TTWizard }

constructor TTWizard.Create(const AHandle: HWND);
begin
  inherited Create;
  FHandle := AHandle;
  FPages := TList<TTWizardPage>.Create;
end;

destructor TTWizard.Destroy;
begin
  FPages.Free;
  inherited Destroy;
end;

procedure TTWizard.AddPage(const APage: TTWizardPage);
begin
  APage.Visible := False;
  FPages.Add(APage);
end;

procedure TTWizard.Start;
begin
  FIndex := 0;
  FPages[FIndex].Visible := True;
end;

function TTWizard.GetIsFirst: Boolean;
begin
  result := (FIndex = 0);
end;

function TTWizard.GetIsLast: Boolean;
begin
  result := (FIndex = FPages.Count - 1);
end;

procedure TTWizard.PreviousPage;
var
  LIndex: Integer;
begin
  LIndex := FIndex - 1;
  if LIndex >= 0 then
  begin
    LockWindowUpdate(FHandle);
    try
      FPages[FIndex].Visible := False;
      FIndex := LIndex;
      while not FPages[FIndex].Enabled do
        FIndex := FIndex - 1;
      FPages[FIndex].Visible := True;
      FPages[FIndex].SetFocus;
    finally
      LockWindowUpdate(0);
    end;
  end;
end;

procedure TTWizard.NextPage;
var
  LIndex: Integer;
begin
  if FPages[FIndex].Check then
  begin
    LIndex := FIndex + 1;
    if LIndex < FPages.Count then
    begin
      LockWindowUpdate(FHandle);
      try
        FPages[FIndex].Visible := False;
        FIndex := LIndex;
        while not FPages[FIndex].Enabled do
          FIndex := FIndex + 1;
        FPages[FIndex].Visible := True;
        FPages[FIndex].SetFocus;
      finally
        LockWindowUpdate(0);
      end;
    end;
  end;
end;

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
  EnableDisableButtons;
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

function TTAPIRestForm.CheckProject: Boolean;
var
  LValidator: TTValidator;
begin
  LValidator := TTValidator.Create;
  try
    LValidator.Check(
      String(ProjectDirectoryTextbox.Text).IsEmpty,
      'Directory name cannot be empty.');

    LValidator.Check(
      (TDirectory.Exists(ProjectDirectoryTextbox.Text) and
        (Length(TDirectory.GetFiles(ProjectDirectoryTextbox.Text)) > 0)),
      'Directory contain files.');

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
