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

  Trysil.Expert.Validator,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.APIRestCreator;

type

{ TWizardPageCheck }

  TWizardPageCheck = function: Boolean of object;

{ TTWizardPage }

  TTWizardPage = record
  strict private
    FPage: TPanel;
    FControl: TWinControl;
    FCheck: TWizardPageCheck;

    function GetVisible: Boolean;
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(
      const APage: TPanel;
      const AControl: TWinControl;
      const ACheck: TWizardPageCheck);

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
    APIAuthorizationCheckbox: TCheckBox;
    APILogCheckbox: TCheckBox;
    ServicePagePanel: TPanel;
    ServicePageGroupBox: TGroupBox;
    ServiceNameLabel: TLabel;
    ServiceNameTextbox: TEdit;
    ServiceDisplayNameLabel: TLabel;
    ServiceDisplayNameTextbox: TEdit;
    ServiceDescriptionLabel: TLabel;
    ServiceDescriptionTextbox: TEdit;
    DatabasePagePanel: TPanel;
    DatabasePageGroupBox: TGroupBox;
    DBConnectionNameLabel: TLabel;
    DBHostLabel: TLabel;
    DBConnectionNameTextbox: TEdit;
    DBHostTextbox: TEdit;
    DBUsernameLabel: TLabel;
    DBUsernameTextbox: TEdit;
    DBPasswordLabel: TLabel;
    DBPasswordTextbox: TEdit;
    DBDatabaseNameLabel: TLabel;
    DBDatabaseNameTextbox: TEdit;
    BackButton: TButton;
    NextButton: TButton;
    FinishButton: TButton;
    CancelButton: TButton;
    procedure ProjectNameButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
    procedure CalculateUrlLabel(Sender: TObject);
  strict private
    FWizard: TTWizard;

    procedure EnableDisableButtons;

    function CheckProject: Boolean;
    function CheckAPI: Boolean;
    function CheckService: Boolean;
    function CheckDatabase: Boolean;
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
  const ACheck: TWizardPageCheck);
begin
  FPage := APage;
  FControl := AControl;
  FCheck := ACheck;
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
    ProjectPagePanel, ProjectDirectoryTextbox, CheckProject));
  FWizard.AddPage(TTWizardPage.Create(
    APIPagePanel, APIBaseUriTextbox, CheckAPI));
  FWizard.AddPage(TTWizardPage.Create(
    ServicePagePanel, ServiceNameTextbox, CheckService));
  FWizard.AddPage(TTWizardPage.Create(
    DatabasePagePanel, DBConnectionNameTextbox, CheckDatabase));

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
    if not result then
      MessageDlg(
        LValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
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
    if not result then
      MessageDlg(
        LValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  finally
    LValidator.Free;
  end;
end;

function TTAPIRestForm.CheckDatabase: Boolean;
var
  LValidator: TTValidator;
begin
  LValidator := TTValidator.Create;
  try
    LValidator.Check(
      String(DBConnectionNameTextbox.Text).IsEmpty,
      'Connection name cannot be empty.');
    LValidator.Check(
      String(DBHostTextbox.Text).IsEmpty,
      'Host cannot be empty.');
    LValidator.Check(
      String(DBUsernameTextbox.Text).IsEmpty,
      'Username cannot be empty.');
    LValidator.Check(
      String(DBDatabaseNameTextbox.Text).IsEmpty,
      'Database name cannot be empty.');

    result := LValidator.IsValid;
    if not result then
      MessageDlg(
        LValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
  finally
    LValidator.Free;
  end;
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
      String(ServiceNameTextbox.Text).Equals(ProjectNameTextBox.Text),
      'Service name cannot be the same as project name.');
    LValidator.Check(
      String(ServiceDisplayNameTextbox.Text).IsEmpty,
      'Display name cannot be empty.');

    result := LValidator.IsValid;
    if not result then
      MessageDlg(
        LValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
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

procedure TTAPIRestForm.FinishButtonClick(Sender: TObject);
var
  LParameters: TTApiRestParameters;
  LCreator: TTAPIRestCreator;
begin
  if CheckDatabase then
  begin
    LParameters := TTApiRestParameters.Create;
    try
      LParameters.Project.Directory := ProjectDirectoryTextbox.Text;
      LParameters.Project.ProjectName := ProjectNameTextBox.Text;

      LParameters.API.BaseUri := APIBaseUriTextbox.Text;
      LParameters.API.Port := Integer.Parse(APIPortTextbox.Text);
      LParameters.API.Authorization := APIAuthorizationCheckbox.Checked;
      LParameters.API.Log := APILogCheckbox.Checked;

      LParameters.Service.Name := ServiceNameTextbox.Text;
      LParameters.Service.DisplayName := ServiceDisplayNameTextbox.Text;
      LParameters.Service.Description := ServiceDescriptionTextbox.Text;

      LParameters.Database.ConnectionName := DBConnectionNameTextbox.Text;
      LParameters.Database.Host :=
        String(DBHostTextbox.Text).Replace('\', '\\');
      LParameters.Database.Username := DBUsernameTextbox.Text;
      LParameters.Database.Password := DBPasswordTextbox.Text;
      LParameters.Database.DatabaseName := DBDatabaseNameTextbox.Text;

      Screen.Cursor := crHourGlass;
      try
        LCreator := TTAPIRestCreator.Create(LParameters);
        try
          LCreator.CreateProject;
          LCreator.OpenProject;
        finally
          LCreator.Free;
        end;
      finally
        Screen.Cursor := crDefault;
      end;
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
