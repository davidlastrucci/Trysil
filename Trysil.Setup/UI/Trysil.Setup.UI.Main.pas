(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Setup.UI.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.IOUtils,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.CheckLst,
  Vcl.Imaging.PngImage,

  Trysil.Expert.Validator,
  Trysil.Expert.UI.Wizard,
  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Delphi,
  Trysil.Setup.Folder,
  Trysil.Setup.Installation,
  Trysil.Setup.Installer,
  Trysil.Setup.Thread;

type

{ TTSetupForm }

  TTSetupForm = class(TForm)
    ContentPanel: TPanel;
    TrysilImage: TImage;
    ModePagePanel: TPanel;
    ModeTitleLabel: TLabel;
    ModeInstallRadioButton: TRadioButton;
    ModeUpdateRadioButton: TRadioButton;
    ModeUninstallRadioButton: TRadioButton;
    ModeInfoLabel: TLabel;
    FolderPagePanel: TPanel;
    FolderTitleLabel: TLabel;
    FolderLabel: TLabel;
    FolderTextbox: TEdit;
    FolderButton: TButton;
    VersionsPagePanel: TPanel;
    VersionsTitleLabel: TLabel;
    VersionsLabel: TLabel;
    VersionsListBox: TCheckListBox;
    ExpertCheckbox: TCheckBox;
    SummaryPagePanel: TPanel;
    SummaryTitleLabel: TLabel;
    SummaryMemo: TMemo;
    ProgressPagePanel: TPanel;
    ProgressTitleLabel: TLabel;
    ProgressMemo: TMemo;
    ButtonsPanel: TPanel;
    BackButton: TButton;
    NextButton: TButton;
    FinishButton: TButton;
    CancelButton: TButton;
    FolderDialog: TFileOpenDialog;
    procedure BackButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FolderButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure VersionsListBoxDrawItem(
      Control: TWinControl;
      Index: Integer;
      Rect: TRect;
      State: TOwnerDrawState);
  strict private
    FWizard: TTWizard;
    FLog: TTSetupLog;
    FInstallation: TTInstallation;
    FVersions: TObjectList<TTDelphiVersion>;
    FOptions: TTInstallOptions;
    FStarted: Boolean;
    FRunning: Boolean;

    procedure AddPages;
    function ModeInfo: String;
    procedure InitializeMode;
    function IsIdle: Boolean;
    procedure EnableDisableButtons;
    procedure MoveNext;
    function IsInstallMode: Boolean;
    function IsStarted: Boolean;
    function Mode: TTSetupMode;
    function Directory: String;
    procedure ShowError(const AMessage: String);
    procedure ShowErrors(const AValidator: TTValidator);
    function CanInstallInto(const ADirectory: String): Boolean;
    procedure CheckDirectory(const AValidator: TTValidator);
    procedure StartDetection;
    procedure DetectionTerminate(Sender: TObject);
    function CanBuildAny: Boolean;
    procedure FillVersions;
    function HasVersions: Boolean;
    function CheckFolder: Boolean;
    function CheckedCount: Integer;
    function CheckVersions: Boolean;
    function ExpertSelected: Boolean;
    procedure FillInstallSummary;
    procedure FillSummary;
    procedure CreateOptions;
    procedure StartSetup;
    procedure LogLine(const ALine: String);
    procedure ThreadTerminate(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

var
  SetupForm: TTSetupForm;

implementation

{$R *.dfm}

{ TTSetupForm }

constructor TTSetupForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWizard := TTWizard.Create(Handle);
  FLog := TTSetupLog.Create;
  FInstallation := TTInstallation.Create;
  FVersions := TObjectList<TTDelphiVersion>.Create;
  FOptions := nil;
  FStarted := False;
  FRunning := False;
end;

destructor TTSetupForm.Destroy;
begin
  if Assigned(FOptions) then
    FOptions.Free;
  FVersions.Free;
  FInstallation.Free;
  FLog.Free;
  FWizard.Free;
  inherited Destroy;
end;

procedure TTSetupForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FLog.OnLine := LogLine;
  FInstallation.Load;
  FolderTextbox.Text := TPath.Combine(
    GetEnvironmentVariable(SLocalAppDataVariable), SDefaultFolder);
  AddPages;
  InitializeMode;
  FWizard.Start;
  EnableDisableButtons;
end;

procedure TTSetupForm.AddPages;
begin
  FWizard.AddPage(TTWizardPage.Create(
    ModePagePanel, ModePagePanel, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    FolderPagePanel, FolderTextbox, IsInstallMode, CheckFolder));
  FWizard.AddPage(TTWizardPage.Create(
    VersionsPagePanel, VersionsListBox, IsInstallMode, CheckVersions));
  FWizard.AddPage(TTWizardPage.Create(
    SummaryPagePanel, SummaryMemo, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    ProgressPagePanel, ProgressMemo, IsStarted, nil));
end;

function TTSetupForm.ModeInfo: String;
begin
  if FInstallation.Installed then
    result := Format(SInstalledInfo, [
      FInstallation.Version, FInstallation.Directory])
  else
    result := SNotInstalledInfo;
end;

procedure TTSetupForm.InitializeMode;
var
  LInstalled: Boolean;
  LUninstall: Boolean;
begin
  LInstalled := FInstallation.Installed;
  LUninstall := FindCmdLineSwitch(SUninstallSwitch);
  ModeInstallRadioButton.Enabled := not LInstalled;
  ModeUpdateRadioButton.Enabled := LInstalled;
  ModeUninstallRadioButton.Enabled := LInstalled;
  ModeInstallRadioButton.Checked := not LInstalled;
  ModeUpdateRadioButton.Checked := LInstalled and (not LUninstall);
  ModeUninstallRadioButton.Checked := LInstalled and LUninstall;
  ModeInfoLabel.Caption := ModeInfo;
end;

function TTSetupForm.IsIdle: Boolean;
begin
  result := (not FStarted) and (not FRunning);
end;

procedure TTSetupForm.EnableDisableButtons;
begin
  BackButton.Enabled := IsIdle and (not FWizard.IsFirst);
  NextButton.Enabled := IsIdle and (not FWizard.IsLast);
  FinishButton.Enabled := IsIdle and FWizard.IsLast;
  CancelButton.Enabled := not FRunning;
end;

procedure TTSetupForm.MoveNext;
begin
  FWizard.NextPage;
  if FWizard.IsLast then
    FillSummary;
  EnableDisableButtons;
end;

function TTSetupForm.IsInstallMode: Boolean;
begin
  result := ModeInstallRadioButton.Checked;
end;

function TTSetupForm.IsStarted: Boolean;
begin
  result := FStarted;
end;

function TTSetupForm.Mode: TTSetupMode;
begin
  if ModeUpdateRadioButton.Checked then
    result := TTSetupMode.Update
  else if ModeUninstallRadioButton.Checked then
    result := TTSetupMode.Uninstall
  else
    result := TTSetupMode.Install;
end;

function TTSetupForm.Directory: String;
begin
  result := String(FolderTextbox.Text).Trim;
end;

procedure TTSetupForm.ShowError(const AMessage: String);
begin
  MessageDlg(AMessage, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TTSetupForm.ShowErrors(const AValidator: TTValidator);
begin
  if not AValidator.IsValid then
    ShowError(AValidator.Messages);
end;

function TTSetupForm.CanInstallInto(const ADirectory: String): Boolean;
var
  LFolder: TTInstallFolder;
begin
  LFolder := TTInstallFolder.Create(ADirectory);
  try
    result := LFolder.CanInstall;
  finally
    LFolder.Free;
  end;
end;

procedure TTSetupForm.CheckDirectory(const AValidator: TTValidator);
var
  LDirectory: String;
  LRooted: Boolean;
begin
  LDirectory := Directory;
  LRooted := (not LDirectory.IsEmpty) and TPath.IsPathRooted(LDirectory);
  AValidator.Check(LDirectory.IsEmpty, SFolderEmpty);
  AValidator.Check(
    (not LDirectory.IsEmpty) and (not LRooted), SFolderNotAbsolute);
  AValidator.Check(
    LRooted and (not CanInstallInto(LDirectory)), SFolderNotEmpty);
end;

procedure TTSetupForm.StartDetection;
var
  LThread: TTDetectThread;
begin
  FRunning := True;
  Screen.Cursor := crHourGlass;
  EnableDisableButtons;
  LThread := TTDetectThread.Create(FLog, FVersions);
  LThread.FreeOnTerminate := True;
  LThread.OnTerminate := DetectionTerminate;
  LThread.Start;
end;

procedure TTSetupForm.DetectionTerminate(Sender: TObject);
begin
  FRunning := False;
  Screen.Cursor := crDefault;
  FillVersions;
  if FVersions.Count > 0 then
    MoveNext
  else
    ShowError(SNoDelphiVersion);
  EnableDisableButtons;
end;

function TTSetupForm.CanBuildAny: Boolean;
var
  LVersion: TTDelphiVersion;
begin
  result := False;
  for LVersion in FVersions do
    result := result or LVersion.CanBuild;
end;

procedure TTSetupForm.FillVersions;
var
  LVersion: TTDelphiVersion;
  LIndex: Integer;
begin
  VersionsListBox.Items.Clear;
  for LVersion in FVersions do
  begin
    LIndex := VersionsListBox.Items.AddObject(LVersion.Description, LVersion);
    VersionsListBox.Checked[LIndex] := True;
  end;
  ExpertCheckbox.Visible := CanBuildAny;
end;

function TTSetupForm.HasVersions: Boolean;
begin
  result := (FVersions.Count > 0);
  if not result then
    StartDetection;
end;

function TTSetupForm.CheckFolder: Boolean;
var
  LValidator: TTValidator;
begin
  LValidator := TTValidator.Create;
  try
    CheckDirectory(LValidator);
    result := LValidator.IsValid;
    ShowErrors(LValidator);
  finally
    LValidator.Free;
  end;
  result := result and HasVersions;
end;

function TTSetupForm.CheckedCount: Integer;
var
  LIndex: Integer;
begin
  result := 0;
  for LIndex := 0 to VersionsListBox.Count - 1 do
    if VersionsListBox.Checked[LIndex] then
      Inc(result);
end;

function TTSetupForm.CheckVersions: Boolean;
begin
  result := (CheckedCount > 0);
  if not result then
    ShowError(SSelectVersion);
end;

function TTSetupForm.ExpertSelected: Boolean;
begin
  result := ExpertCheckbox.Visible and ExpertCheckbox.Checked;
end;

procedure TTSetupForm.FillInstallSummary;
var
  LIndex: Integer;
begin
  SummaryMemo.Lines.Add(SInstallSummary);
  SummaryMemo.Lines.Add(Directory);
  SummaryMemo.Lines.Add(String.Empty);
  for LIndex := 0 to VersionsListBox.Count - 1 do
    if VersionsListBox.Checked[LIndex] then
      SummaryMemo.Lines.Add(
        Format(SSummaryItem, [VersionsListBox.Items[LIndex]]));
  if ExpertSelected then
  begin
    SummaryMemo.Lines.Add(String.Empty);
    SummaryMemo.Lines.Add(SExpertSummary);
  end;
end;

procedure TTSetupForm.FillSummary;
begin
  SummaryMemo.Lines.Clear;
  case Mode of
    TTSetupMode.Install:
      FillInstallSummary;
    TTSetupMode.Update:
      SummaryMemo.Lines.Add(Format(SUpdateSummary, [
        FInstallation.Version, FInstallation.Directory]));
    TTSetupMode.Uninstall:
      SummaryMemo.Lines.Add(Format(SUninstallSummary, [
        FInstallation.Version, FInstallation.Directory]));
  end;
end;

procedure TTSetupForm.CreateOptions;
var
  LIndex: Integer;
begin
  FOptions := TTInstallOptions.Create(Directory, ExpertSelected);
  for LIndex := 0 to VersionsListBox.Count - 1 do
    if VersionsListBox.Checked[LIndex] then
      FOptions.Versions.Add(
        TTDelphiVersion(VersionsListBox.Items.Objects[LIndex]));
end;

procedure TTSetupForm.StartSetup;
var
  LThread: TTSetupThread;
begin
  if Mode = TTSetupMode.Install then
    CreateOptions;
  LThread := TTSetupThread.Create(Mode, FLog, FInstallation, FOptions);
  LThread.FreeOnTerminate := True;
  LThread.OnTerminate := ThreadTerminate;
  LThread.Start;
end;

procedure TTSetupForm.LogLine(const ALine: String);
var
  LLine: String;
begin
  LLine := ALine;
  TThread.Queue(nil,
    procedure
    begin
      ProgressMemo.Lines.Add(LLine);
    end);
end;

procedure TTSetupForm.ThreadTerminate(Sender: TObject);
begin
  FRunning := False;
  CancelButton.Caption := SCloseCaption;
  EnableDisableButtons;
  if TTSetupThread(Sender).Succeeded then
    MessageDlg(
      SSetupCompleted, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0)
  else
    ShowError(SSetupFailed);
end;

procedure TTSetupForm.BackButtonClick(Sender: TObject);
begin
  FWizard.PreviousPage;
  EnableDisableButtons;
end;

procedure TTSetupForm.NextButtonClick(Sender: TObject);
begin
  MoveNext;
end;

procedure TTSetupForm.FinishButtonClick(Sender: TObject);
begin
  FStarted := True;
  FRunning := True;
  FWizard.NextPage;
  EnableDisableButtons;
  StartSetup;
end;

procedure TTSetupForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TTSetupForm.FolderButtonClick(Sender: TObject);
begin
  FolderDialog.DefaultFolder := Directory;
  if FolderDialog.Execute then
    FolderTextbox.Text := FolderDialog.FileName;
end;

procedure TTSetupForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not FRunning;
end;

procedure TTSetupForm.VersionsListBoxDrawItem(
  Control: TWinControl;
  Index: Integer;
  Rect: TRect;
  State: TOwnerDrawState);
var
  LText: String;
  LRect: TRect;
begin
  VersionsListBox.Canvas.FillRect(Rect);
  LText := VersionsListBox.Items[Index];
  LRect := Rect;
  Inc(LRect.Left, 2);
  VersionsListBox.Canvas.TextRect(
    LRect, LText, [tfLeft, tfVerticalCenter, tfSingleLine]);
end;

end.
