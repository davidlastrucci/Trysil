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
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.IOUtils,
  System.ImageList,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,
  Vcl.Imaging.PngImage,

  Trysil.Expert.Validator,
  Trysil.Expert.UI.Wizard,
  Trysil.Setup.Consts,
  Trysil.Setup.Log,
  Trysil.Setup.Delphi,
  Trysil.Setup.Folder,
  Trysil.Setup.Installation,
  Trysil.Setup.Installer,
  Trysil.Setup.Thread,
  Trysil.Setup.UI.Controls;

type

{ TTSetupForm }

  TTSetupForm = class(TForm)
    SidebarPanel: TPanel;
    TrysilImage: TImage;
    ProductLabel: TLabel;
    ProductInfoLabel: TLabel;
    StepsPanel: TPanel;
    ModeStepPanel: TPanel;
    ModeStepBadgeLabel: TLabel;
    ModeStepLabel: TLabel;
    FolderStepPanel: TPanel;
    FolderStepBadgeLabel: TLabel;
    FolderStepLabel: TLabel;
    VersionsStepPanel: TPanel;
    VersionsStepBadgeLabel: TLabel;
    VersionsStepLabel: TLabel;
    SummaryStepPanel: TPanel;
    SummaryStepBadgeLabel: TLabel;
    SummaryStepLabel: TLabel;
    InstallationStepPanel: TPanel;
    InstallationStepBadgeLabel: TLabel;
    InstallationStepLabel: TLabel;
    MainPanel: TPanel;
    ContentPanel: TPanel;
    ModePagePanel: TPanel;
    ModeTitleLabel: TLabel;
    ModeSubtitleLabel: TLabel;
    InstallCardPanel: TPanel;
    InstallContentPanel: TPanel;
    ModeInstallRadioButton: TRadioButton;
    InstallDescriptionLabel: TLabel;
    UpdateCardPanel: TPanel;
    UpdateContentPanel: TPanel;
    ModeUpdateRadioButton: TRadioButton;
    UpdateDescriptionLabel: TLabel;
    UninstallCardPanel: TPanel;
    UninstallContentPanel: TPanel;
    ModeUninstallRadioButton: TRadioButton;
    UninstallDescriptionLabel: TLabel;
    MasterCardPanel: TPanel;
    MasterContentPanel: TPanel;
    MasterCheckbox: TCheckBox;
    MasterDescriptionLabel: TLabel;
    FolderPagePanel: TPanel;
    FolderTitleLabel: TLabel;
    FolderSubtitleLabel: TLabel;
    FolderLabel: TLabel;
    FolderTextbox: TEdit;
    FolderButton: TButton;
    FolderHintLabel: TLabel;
    FolderInfoPanel: TPanel;
    FolderInfoContentPanel: TPanel;
    FolderInfoIconLabel: TLabel;
    FolderInfoLabel: TLabel;
    VersionsPagePanel: TPanel;
    VersionsTitleLabel: TLabel;
    VersionsLabel: TLabel;
    VersionsBodyPanel: TPanel;
    VersionsPanel: TPanel;
    Version1CardPanel: TPanel;
    Version1ContentPanel: TPanel;
    Version1PaintBox: TPaintBox;
    Version1Checkbox: TCheckBox;
    Version2CardPanel: TPanel;
    Version2ContentPanel: TPanel;
    Version2PaintBox: TPaintBox;
    Version2Checkbox: TCheckBox;
    Version3CardPanel: TPanel;
    Version3ContentPanel: TPanel;
    Version3PaintBox: TPaintBox;
    Version3Checkbox: TCheckBox;
    Version4CardPanel: TPanel;
    Version4ContentPanel: TPanel;
    Version4PaintBox: TPaintBox;
    Version4Checkbox: TCheckBox;
    Version5CardPanel: TPanel;
    Version5ContentPanel: TPanel;
    Version5PaintBox: TPaintBox;
    Version5Checkbox: TCheckBox;
    VersionsLegendPanel: TPanel;
    PackagesChipLabel: TLabel;
    PackagesLegendLabel: TLabel;
    SourcesChipLabel: TLabel;
    SourcesLegendLabel: TLabel;
    ExpertCardPanel: TPanel;
    ExpertContentPanel: TPanel;
    ExpertCheckbox: TCheckBox;
    ExpertDescriptionLabel: TLabel;
    SummaryPagePanel: TPanel;
    SummaryTitleLabel: TLabel;
    SummarySubtitleLabel: TLabel;
    SummaryListView: TListView;
    ProgressPagePanel: TPanel;
    ProgressTitleLabel: TLabel;
    ProgressCurrentLabel: TLabel;
    ProgressLogLabel: TLabel;
    ProgressLogPanel: TPanel;
    ProgressMemo: TMemo;
    CompletedPagePanel: TPanel;
    CompletedTitleLabel: TLabel;
    CompletedInfoLabel: TLabel;
    CompletedDocsLinkLabel: TLinkLabel;
    CompletedLogLinkLabel: TLinkLabel;
    ButtonsLineShape: TShape;
    ButtonsPanel: TPanel;
    LogButton: TButton;
    BackButton: TButton;
    NextButton: TButton;
    CancelButton: TButton;
    FolderDialog: TFileOpenDialog;
    SummaryImageList: TImageList;
    procedure BackButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure LogButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FolderButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ModeRadioButtonClick(Sender: TObject);
    procedure SummaryListViewCustomDrawItem(
      Sender: TCustomListView;
      Item: TListItem;
      State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure SummaryListViewCustomDrawSubItem(
      Sender: TCustomListView;
      Item: TListItem;
      SubItem: Integer;
      State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure SummaryListViewSelectItem(
      Sender: TObject;
      Item: TListItem;
      Selected: Boolean);
    procedure CompletedDocsLinkLabelLinkClick(
      Sender: TObject;
      const Link: String;
      LinkType: TSysLinkType);
    procedure CompletedLogLinkLabelLinkClick(
      Sender: TObject;
      const Link: String;
      LinkType: TSysLinkType);
  strict private
    FWizard: TTWizard;
    FLog: TTSetupLog;
    FInstallation: TTInstallation;
    FVersions: TObjectList<TTDelphiVersion>;
    FOptions: TTInstallOptions;
    FSteps: TObjectList<TTSetupStep>;
    FStepPages: TArray<TPanel>;
    FModeCards: TObjectList<TTSetupCard>;
    FVersionCards: TObjectList<TTVersionCard>;
    FStarted: Boolean;
    FRunning: Boolean;
    FCompleted: Boolean;

    procedure AddSteps;
    procedure AddModeCards;
    procedure AddVersionCards;
    procedure AddPages;
    function ModeTitle: String;
    procedure DescribeInstalledModes;
    procedure DescribeNotInstalledModes;
    procedure InitializeMode;
    procedure EnableDisableMaster;
    function MasterSelected: Boolean;
    function IsIdle: Boolean;
    function CurrentStep: Integer;
    function IsStepVisible(const AIndex: Integer): Boolean;
    function StepState(
      const AIndex: Integer; const ACurrent: Integer): TTSetupStepState;
    procedure RefreshSteps;
    function ActionCaption: String;
    function NextCaption: String;
    function LogCaption: String;
    procedure EnableDisableButtons;
    procedure RefreshView;
    procedure MoveNext;
    function IsInstallMode: Boolean;
    function IsStarted: Boolean;
    function IsCompleted: Boolean;
    function Mode: TTSetupMode;
    function Directory: String;
    procedure ShowError(const AMessage: String);
    procedure ShowErrors(const AValidator: TTValidator);
    function CanInstallInto(const ADirectory: String): Boolean;
    procedure CheckDirectory(const AValidator: TTValidator);
    procedure StartDetection;
    procedure DetectionTerminate(Sender: TObject);
    function CanBuildAny: Boolean;
    function VersionAt(const AIndex: Integer): TTDelphiVersion;
    procedure FillVersions;
    function HasVersions: Boolean;
    function CheckFolder: Boolean;
    function CheckedCount: Integer;
    function CheckVersions: Boolean;
    function ExpertSelected: Boolean;
    procedure AddSummaryRow(const AKey: String; const AValue: String);
    function ReleaseValue: String;
    function ExpertValue: String;
    procedure AddVersionsRows;
    procedure FillInstallSummary;
    procedure FillUpdateSummary;
    procedure FillUninstallSummary;
    procedure FillSummary;
    function ProgressTitle: String;
    procedure CreateOptions;
    procedure StartSetup;
    procedure StartInstallation;
    procedure LogLine(const ALine: String);
    function CompletedTitle(const AThread: TTSetupThread): String;
    function IsClean(const AThread: TTSetupThread): Boolean;
    function CompletedColor(const AThread: TTSetupThread): TColor;
    procedure FillCompleted(const AThread: TTSetupThread);
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
  FSteps := TObjectList<TTSetupStep>.Create;
  FModeCards := TObjectList<TTSetupCard>.Create;
  FVersionCards := TObjectList<TTVersionCard>.Create;
  FStarted := False;
  FRunning := False;
  FCompleted := False;
end;

destructor TTSetupForm.Destroy;
begin
  if Assigned(FOptions) then
    FOptions.Free;
  FVersionCards.Free;
  FModeCards.Free;
  FSteps.Free;
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
  AddSteps;
  AddModeCards;
  AddVersionCards;
  AddPages;
  InitializeMode;
  FWizard.Start;
  RefreshView;
end;

procedure TTSetupForm.AddSteps;
begin
  FSteps.Add(TTSetupStep.Create(
    ModeStepPanel, ModeStepBadgeLabel, ModeStepLabel));
  FSteps.Add(TTSetupStep.Create(
    FolderStepPanel, FolderStepBadgeLabel, FolderStepLabel));
  FSteps.Add(TTSetupStep.Create(
    VersionsStepPanel, VersionsStepBadgeLabel, VersionsStepLabel));
  FSteps.Add(TTSetupStep.Create(
    SummaryStepPanel, SummaryStepBadgeLabel, SummaryStepLabel));
  FSteps.Add(TTSetupStep.Create(
    InstallationStepPanel, InstallationStepBadgeLabel, InstallationStepLabel));
  FStepPages := [
    ModePagePanel,
    FolderPagePanel,
    VersionsPagePanel,
    SummaryPagePanel,
    ProgressPagePanel];
end;

procedure TTSetupForm.AddModeCards;
begin
  FModeCards.Add(TTSetupCard.Create(
    InstallCardPanel,
    InstallContentPanel,
    ModeInstallRadioButton,
    InstallDescriptionLabel));
  FModeCards.Add(TTSetupCard.Create(
    UpdateCardPanel,
    UpdateContentPanel,
    ModeUpdateRadioButton,
    UpdateDescriptionLabel));
  FModeCards.Add(TTSetupCard.Create(
    UninstallCardPanel,
    UninstallContentPanel,
    ModeUninstallRadioButton,
    UninstallDescriptionLabel));
end;

procedure TTSetupForm.AddVersionCards;
begin
  FVersionCards.Add(TTVersionCard.Create(
    Version1CardPanel,
    Version1ContentPanel,
    Version1Checkbox,
    Version1PaintBox));
  FVersionCards.Add(TTVersionCard.Create(
    Version2CardPanel,
    Version2ContentPanel,
    Version2Checkbox,
    Version2PaintBox));
  FVersionCards.Add(TTVersionCard.Create(
    Version3CardPanel,
    Version3ContentPanel,
    Version3Checkbox,
    Version3PaintBox));
  FVersionCards.Add(TTVersionCard.Create(
    Version4CardPanel,
    Version4ContentPanel,
    Version4Checkbox,
    Version4PaintBox));
  FVersionCards.Add(TTVersionCard.Create(
    Version5CardPanel,
    Version5ContentPanel,
    Version5Checkbox,
    Version5PaintBox));
end;

procedure TTSetupForm.AddPages;
begin
  FWizard.AddPage(TTWizardPage.Create(
    ModePagePanel, ModePagePanel, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    FolderPagePanel, FolderTextbox, IsInstallMode, CheckFolder));
  FWizard.AddPage(TTWizardPage.Create(
    VersionsPagePanel, Version1Checkbox, IsInstallMode, CheckVersions));
  FWizard.AddPage(TTWizardPage.Create(
    SummaryPagePanel, SummaryListView, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    ProgressPagePanel, ProgressMemo, IsStarted, nil));
  FWizard.AddPage(TTWizardPage.Create(
    CompletedPagePanel, CompletedPagePanel, IsCompleted, nil));
end;

function TTSetupForm.ModeTitle: String;
begin
  if FInstallation.Installed then
    result := SInstalledInfo
  else
    result := SNotInstalledInfo;
end;

procedure TTSetupForm.DescribeInstalledModes;
begin
  InstallDescriptionLabel.Caption := SAlreadyInstalledDescription;
  UpdateDescriptionLabel.Caption := SUpdateDescription;
  UninstallDescriptionLabel.Caption := SUninstallDescription;
end;

procedure TTSetupForm.DescribeNotInstalledModes;
begin
  InstallDescriptionLabel.Caption := SInstallDescription;
  UpdateDescriptionLabel.Caption := SNotInstalledDescription;
  UninstallDescriptionLabel.Caption := SNotInstalledDescription;
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
  ModeTitleLabel.Caption := ModeTitle;
  if LInstalled then
    DescribeInstalledModes
  else
    DescribeNotInstalledModes;
  EnableDisableMaster;
end;

procedure TTSetupForm.EnableDisableMaster;
begin
  MasterCheckbox.Enabled := not ModeUninstallRadioButton.Checked;
  MasterDescriptionLabel.Enabled := MasterCheckbox.Enabled;
end;

function TTSetupForm.MasterSelected: Boolean;
begin
  result := MasterCheckbox.Enabled and MasterCheckbox.Checked;
end;

function TTSetupForm.IsIdle: Boolean;
begin
  result := (not FStarted) and (not FRunning);
end;

function TTSetupForm.CurrentStep: Integer;
var
  LIndex: Integer;
begin
  result := Length(FStepPages);
  if not FCompleted then
    for LIndex := High(FStepPages) downto 0 do
      if FStepPages[LIndex].Visible then
        result := LIndex;
end;

function TTSetupForm.IsStepVisible(const AIndex: Integer): Boolean;
begin
  result :=
    IsInstallMode or (
      (FStepPages[AIndex] <> FolderPagePanel) and
      (FStepPages[AIndex] <> VersionsPagePanel));
end;

function TTSetupForm.StepState(
  const AIndex: Integer; const ACurrent: Integer): TTSetupStepState;
begin
  if AIndex < ACurrent then
    result := TTSetupStepState.Done
  else if AIndex = ACurrent then
    result := TTSetupStepState.Current
  else
    result := TTSetupStepState.Todo;
end;

procedure TTSetupForm.RefreshSteps;
var
  LCurrent: Integer;
  LIndex: Integer;
begin
  LCurrent := CurrentStep;
  for LIndex := 0 to FSteps.Count - 1 do
    if IsStepVisible(LIndex) then
      FSteps[LIndex].Show(StepState(LIndex, LCurrent))
    else
      FSteps[LIndex].Hide;
end;

function TTSetupForm.ActionCaption: String;
begin
  case Mode of
    TTSetupMode.Update: result := SUpdateCaption;
    TTSetupMode.Uninstall: result := SUninstallCaption;
  else
    result := SInstallCaption;
  end;
end;

function TTSetupForm.NextCaption: String;
begin
  if FWizard.IsLast then
    result := ActionCaption
  else
    result := SNextCaption;
end;

function TTSetupForm.LogCaption: String;
begin
  if CompletedPagePanel.Visible then
    result := SShowLogCaption
  else
    result := SHideLogCaption;
end;

procedure TTSetupForm.EnableDisableButtons;
begin
  BackButton.Visible := not FStarted;
  NextButton.Visible := not FStarted;
  BackButton.Enabled := IsIdle and (not FWizard.IsFirst);
  NextButton.Enabled := IsIdle;
  NextButton.Caption := NextCaption;
  LogButton.Visible := FCompleted;
  LogButton.Caption := LogCaption;
  CancelButton.Enabled := not FRunning;
end;

procedure TTSetupForm.RefreshView;
begin
  EnableDisableButtons;
  RefreshSteps;
end;

procedure TTSetupForm.MoveNext;
begin
  FWizard.NextPage;
  if FWizard.IsLast then
    FillSummary;
  RefreshView;
end;

function TTSetupForm.IsInstallMode: Boolean;
begin
  result := ModeInstallRadioButton.Checked;
end;

function TTSetupForm.IsStarted: Boolean;
begin
  result := FStarted;
end;

function TTSetupForm.IsCompleted: Boolean;
begin
  result := FCompleted;
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

function TTSetupForm.VersionAt(const AIndex: Integer): TTDelphiVersion;
begin
  if AIndex < FVersions.Count then
    result := FVersions[AIndex]
  else
    result := nil;
end;

procedure TTSetupForm.FillVersions;
var
  LIndex: Integer;
begin
  for LIndex := 0 to FVersionCards.Count - 1 do
    FVersionCards[LIndex].Bind(VersionAt(LIndex));
  ExpertCardPanel.Visible := CanBuildAny;
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
  LCard: TTVersionCard;
begin
  result := 0;
  for LCard in FVersionCards do
    if LCard.Checked then
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
  result := ExpertCardPanel.Visible and ExpertCheckbox.Checked;
end;

procedure TTSetupForm.AddSummaryRow(const AKey: String; const AValue: String);
var
  LItem: TListItem;
begin
  LItem := SummaryListView.Items.Add;
  LItem.Caption := AKey;
  LItem.SubItems.Add(AValue);
end;

function TTSetupForm.ReleaseValue: String;
begin
  if MasterSelected then
    result := SMasterValue
  else
    result := SLatestReleaseValue;
end;

function TTSetupForm.ExpertValue: String;
begin
  if ExpertCheckbox.Checked then
    result := SYesValue
  else
    result := SNoValue;
end;

procedure TTSetupForm.AddVersionsRows;
var
  LKey: String;
  LCard: TTVersionCard;
begin
  LKey := SVersionsKey;
  for LCard in FVersionCards do
    if LCard.Checked then
    begin
      AddSummaryRow(LKey, LCard.Version.Description);
      LKey := String.Empty;
    end;
end;

procedure TTSetupForm.FillInstallSummary;
begin
  SummaryTitleLabel.Caption := SInstallTitle;
  SummarySubtitleLabel.Caption := SInstallSubtitle;
  AddSummaryRow(SVersionKey, ReleaseValue);
  AddSummaryRow(SFolderKey, Directory);
  AddVersionsRows;
  if ExpertCardPanel.Visible then
    AddSummaryRow(SExpertKey, ExpertValue);
end;

procedure TTSetupForm.FillUpdateSummary;
begin
  SummaryTitleLabel.Caption := SUpdateTitle;
  SummarySubtitleLabel.Caption := SUpdateSubtitle;
  AddSummaryRow(
    SInstalledKey, Format(SInstalledValue, [FInstallation.Version]));
  AddSummaryRow(SFolderKey, FInstallation.Directory);
  AddSummaryRow(SVersionKey, ReleaseValue);
end;

procedure TTSetupForm.FillUninstallSummary;
begin
  SummaryTitleLabel.Caption := SUninstallTitle;
  SummarySubtitleLabel.Caption := SUninstallSubtitle;
  AddSummaryRow(
    SInstalledKey, Format(SInstalledValue, [FInstallation.Version]));
  AddSummaryRow(SFolderKey, FInstallation.Directory);
end;

procedure TTSetupForm.FillSummary;
begin
  SummaryListView.Items.BeginUpdate;
  try
    SummaryListView.Items.Clear;
    case Mode of
      TTSetupMode.Install: FillInstallSummary;
      TTSetupMode.Update: FillUpdateSummary;
      TTSetupMode.Uninstall: FillUninstallSummary;
    end;
  finally
    SummaryListView.Items.EndUpdate;
  end;
end;

function TTSetupForm.ProgressTitle: String;
begin
  case Mode of
    TTSetupMode.Update: result := SUpdatingTitle;
    TTSetupMode.Uninstall: result := SUninstallingTitle;
  else
    result := SInstallingTitle;
  end;
end;

procedure TTSetupForm.CreateOptions;
var
  LCard: TTVersionCard;
begin
  FOptions := TTInstallOptions.Create(Directory, ExpertSelected);
  for LCard in FVersionCards do
    if LCard.Checked then
      FOptions.Versions.Add(LCard.Version);
end;

procedure TTSetupForm.StartSetup;
var
  LThread: TTSetupThread;
begin
  if Mode = TTSetupMode.Install then
    CreateOptions;
  LThread := TTSetupThread.Create(
    Mode, FLog, FInstallation, FOptions, MasterSelected);
  LThread.FreeOnTerminate := True;
  LThread.OnTerminate := ThreadTerminate;
  LThread.Start;
end;

procedure TTSetupForm.StartInstallation;
begin
  FStarted := True;
  FRunning := True;
  ProgressTitleLabel.Caption := ProgressTitle;
  FWizard.NextPage;
  RefreshView;
  StartSetup;
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
      ProgressCurrentLabel.Caption := LLine;
    end);
end;

function TTSetupForm.CompletedTitle(const AThread: TTSetupThread): String;
begin
  if not AThread.Succeeded then
    result := SFailedTitle
  else if AThread.HasErrors then
    result := SCompletedWithErrorsTitle
  else
    result := SCompletedTitle;
end;

function TTSetupForm.IsClean(const AThread: TTSetupThread): Boolean;
begin
  result := AThread.Succeeded and (not AThread.HasErrors);
end;

function TTSetupForm.CompletedColor(const AThread: TTSetupThread): TColor;
begin
  if IsClean(AThread) then
    result := clWindowText
  else
    result := ErrorColor;
end;

procedure TTSetupForm.FillCompleted(const AThread: TTSetupThread);
begin
  CompletedInfoLabel.Caption := ProgressCurrentLabel.Caption;
  CompletedTitleLabel.Caption := CompletedTitle(AThread);
  CompletedTitleLabel.Font.Color := CompletedColor(AThread);
  CompletedDocsLinkLabel.Visible :=
    IsClean(AThread) and (Mode <> TTSetupMode.Uninstall);
  CompletedLogLinkLabel.Visible := not IsClean(AThread);
end;

procedure TTSetupForm.ThreadTerminate(Sender: TObject);
begin
  FRunning := False;
  FCompleted := True;
  CancelButton.Caption := SCloseCaption;
  FillCompleted(TTSetupThread(Sender));
  FWizard.NextPage;
  RefreshView;
end;

procedure TTSetupForm.BackButtonClick(Sender: TObject);
begin
  FWizard.PreviousPage;
  RefreshView;
end;

procedure TTSetupForm.NextButtonClick(Sender: TObject);
begin
  if FWizard.IsLast then
    StartInstallation
  else
    MoveNext;
end;

procedure TTSetupForm.LogButtonClick(Sender: TObject);
begin
  if CompletedPagePanel.Visible then
    FWizard.PreviousPage
  else
    FWizard.NextPage;
  RefreshView;
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

procedure TTSetupForm.ModeRadioButtonClick(Sender: TObject);
var
  LCard: TTSetupCard;
begin
  for LCard in FModeCards do
    LCard.Select(Sender);
  EnableDisableMaster;
  RefreshSteps;
end;

procedure TTSetupForm.SummaryListViewCustomDrawItem(
  Sender: TCustomListView;
  Item: TListItem;
  State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color := SecondaryTextColor;
end;

procedure TTSetupForm.SummaryListViewCustomDrawSubItem(
  Sender: TCustomListView;
  Item: TListItem;
  SubItem: Integer;
  State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color := clWindowText;
end;

procedure TTSetupForm.SummaryListViewSelectItem(
  Sender: TObject;
  Item: TListItem;
  Selected: Boolean);
begin
  if Selected then
    Item.Selected := False;
end;

procedure TTSetupForm.CompletedDocsLinkLabelLinkClick(
  Sender: TObject;
  const Link: String;
  LinkType: TSysLinkType);
begin
  ShellExecute(Handle, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

procedure TTSetupForm.CompletedLogLinkLabelLinkClick(
  Sender: TObject;
  const Link: String;
  LinkType: TSysLinkType);
begin
  LogButtonClick(Sender);
end;

end.
