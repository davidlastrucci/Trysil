(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.GenerateModel;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Menus,
  ToolsAPI,

  Trysil.Expert.IOTA,
  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.Project,
  Trysil.Expert.Config,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Wizard,
  Trysil.Expert.UI.Images,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.Validator,
  Trysil.Expert.ModelCreator,
  Trysil.Expert.EventCreator,
  Trysil.Expert.ControllerCreator,
  Trysil.Expert.APIHttpModifier, Vcl.Imaging.pngimage;

type

{ TTGenerateModel }

  TTGenerateModel = class(TTThemedForm)
    EntitiesPopupMenu: TPopupMenu;
    SelectAllEntitiesMenuItem: TMenuItem;
    UnselectAllEntitiesMenuItem: TMenuItem;
    EntitiesPagePanel: TPanel;
    EntitiesPageGroupbox: TGroupBox;
    EntitiesListView: TListView;
    ModelsPagePanel: TPanel;
    ModelsPageGroupbox: TGroupBox;
    ModelsCheckbox: TCheckBox;
    ModelDirectoryLabel: TLabel;
    ModelDirectoryTextbox: TEdit;
    UnitFilenamesLabel: TLabel;
    UnitFilenamesTextbox: TEdit;
    FilterPropertiesCheckbox: TCheckBox;
    EventsPagePanel: TPanel;
    EventsPageGroupbox: TGroupBox;
    EventsCheckbox: TCheckBox;
    EventsDirectoryLabel: TLabel;
    EventsDirectoryTextbox: TEdit;
    EventFilenamesLabel: TLabel;
    EventFilenamesTextbox: TEdit;
    ControllersPagePanel: TPanel;
    ControllersPageGroupbox: TGroupBox;
    APIControllersCheckbox: TCheckBox;
    ControllersDirectoryLabel: TLabel;
    ControllersDirectoryTextbox: TEdit;
    ControllerFilenamesLabel: TLabel;
    ControllerFilenamesTextbox: TEdit;
    BackButton: TButton;
    NextButton: TButton;
    FinishButton: TButton;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure EntitiesListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure SelectAllEntitiesMenuItemClick(Sender: TObject);
    procedure UnselectallEntitiesMenuItemClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure FinishButtonClick(Sender: TObject);
  strict private
    FProject: TTProject;
    FConfig: TTLocalConfig;
    FEntities: TTEntities;
    FWizard: TTWizard;

    procedure CheckIsAPIRestApplication;
    function IsAPIRestApplication: Boolean;
    function CheckEntities: Boolean;
    procedure AddPages;
    procedure EnableDisableButtons;
    function IsControllersChecked: Boolean;
    procedure ConfigToControls;
    procedure ControlsToConfig;
    procedure AddSelectedEntities(const AEntities: TList<TTEntity>);
    procedure CheckGeneration;
    procedure CheckModule(
      const AValidator: TTValidator;
      const AProjectName: String;
      const ADirectory: String;
      const AUnitNames: String;
      const AEntity: TTEntity);
    function CheckOverwrite(const AEntities: TList<TTEntity>): Boolean;
    procedure SelectAllEntities(const ASelect: Boolean);
    procedure CreateModels(const AEntities: TList<TTEntity>);
    procedure CreateEvents(const AEntities: TList<TTEntity>);
    procedure CreateControllers(const AEntities: TList<TTEntity>);
    procedure ModifyAPIHttp(const AEntities: TList<TTEntity>);
    procedure Generate(const AEntities: TList<TTEntity>);
  strict protected
    function HelpPage: String; override;
  public
    constructor Create(const AProject: TTProject); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class procedure ShowDialog(const AProject: TTProject);
  end;

implementation

{$R *.dfm}

constructor TTGenerateModel.Create(const AProject: TTProject);
begin
  inherited Create(nil);
  FProject := AProject;

  FConfig := TTLocalConfig.Create;
  FEntities := TTEntities.Create;
  FWizard := TTWizard.Create(Handle);
end;

destructor TTGenerateModel.Destroy;
begin
  FWizard.Free;
  FEntities.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TTGenerateModel.AfterConstruction;
begin
  inherited AfterConstruction;
  EntitiesListView.SmallImages := TTImagesDataModule.Instance.Images;
  CheckIsAPIRestApplication;
  ConfigToControls;
  FEntities.LoadFromDirectory(TTUtils.TrysilFolder(FProject.Directory));
  AddPages;
  FWizard.Start;
  EnableDisableButtons;
end;

procedure TTGenerateModel.AddPages;
begin
  FWizard.AddPage(TTWizardPage.Create(
    EntitiesPagePanel, EntitiesListView, nil, CheckEntities));
  FWizard.AddPage(TTWizardPage.Create(
    ModelsPagePanel, ModelsCheckbox, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    EventsPagePanel, EventsCheckbox, nil, nil));
  FWizard.AddPage(TTWizardPage.Create(
    ControllersPagePanel, APIControllersCheckbox, IsAPIRestApplication, nil));
end;

procedure TTGenerateModel.EnableDisableButtons;
begin
  BackButton.Enabled := not FWizard.IsFirst;
  NextButton.Enabled := not FWizard.IsLast;
  FinishButton.Enabled := FWizard.IsLast;
end;

function TTGenerateModel.IsAPIRestApplication: Boolean;
begin
  result := APIControllersCheckbox.Enabled;
end;

function TTGenerateModel.CheckEntities: Boolean;
var
  LItem: TListItem;
begin
  result := False;
  for LItem in EntitiesListView.Items do
    if LItem.Checked then
      result := True;

  if not result then
    MessageDlg(SSelectOneEntity, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
end;

procedure TTGenerateModel.CheckIsAPIRestApplication;
var
  LProjectName: String;
  LHttpModule, LControllerModule: IInterface;
begin
  APIControllersCheckbox.Enabled := False;

  LProjectName := TTIOTA.ActiveProjectName;
  LHttpModule := TTIOTA.SearchModule(Format('%s.Http', [LProjectName]));
  LControllerModule := TTIOTA.SearchModule(
    'Core\Controllers\TApiRest.Controller');

  APIControllersCheckbox.Enabled :=
    Assigned(LHttpModule) and Assigned(LControllerModule);
end;

function TTGenerateModel.IsControllersChecked: Boolean;
begin
  result := APIControllersCheckbox.Enabled and APIControllersCheckbox.Checked;
end;

procedure TTGenerateModel.ConfigToControls;
begin
  ModelsCheckbox.Checked := FConfig.Models;
  ModelDirectoryTextbox.Text := FConfig.ModelDirectory;
  UnitFilenamesTextbox.Text := FConfig.UnitFilenames;
  EventsCheckbox.Checked := FConfig.Events;
  EventsDirectoryTextbox.Text := FConfig.EventsDirectory;
  EventFilenamesTextbox.Text := FConfig.EventFilenames;
  APIControllersCheckbox.Checked :=
    APIControllersCheckbox.Enabled and FConfig.Controllers;
  ControllersDirectoryTextbox.Text := FConfig.ControllersDirectory;
  ControllerFilenamesTextbox.Text := FConfig.ControllerFilenames;
  FilterPropertiesCheckbox.Checked := FConfig.FilterProperties;
end;

procedure TTGenerateModel.ControlsToConfig;
begin
  FConfig.Models := ModelsCheckbox.Checked;
  FConfig.ModelDirectory := ModelDirectoryTextbox.Text;
  FConfig.UnitFilenames := UnitFilenamesTextbox.Text;
  FConfig.Events := EventsCheckbox.Checked;
  FConfig.EventsDirectory := EventsDirectoryTextbox.Text;
  FConfig.EventFilenames := EventFilenamesTextbox.Text;
  FConfig.Controllers := IsControllersChecked;
  FConfig.ControllersDirectory := ControllersDirectoryTextbox.Text;
  FConfig.ControllerFilenames := ControllerFilenamesTextbox.Text;
  FConfig.FilterProperties := FilterPropertiesCheckbox.Checked;
  FConfig.Save;
end;

procedure TTGenerateModel.AddSelectedEntities(const AEntities: TList<TTEntity>);
var
  LItem: TListItem;
  LEntityItem: TTEntityListItem absolute LItem;
begin
  AEntities.Clear;
  for LItem in EntitiesListView.Items do
    if LItem.Checked then
      AEntities.Add(LEntityItem.Value);

  if AEntities.Count < 1 then
    raise ETExpertException.Create(SSelectOneEntity);
end;

procedure TTGenerateModel.CheckGeneration;
begin
  if not (ModelsCheckbox.Checked or
    EventsCheckbox.Checked or
    IsControllersChecked) then
    raise ETExpertException.Create(SSelectOneGeneration);
end;

procedure TTGenerateModel.CheckModule(
  const AValidator: TTValidator;
  const AProjectName: String;
  const ADirectory: String;
  const AUnitNames: String;
  const AEntity: TTEntity);
var
  LModuleName: String;
begin
  LModuleName := TPath.Combine(
    ADirectory, TTUtils.UnitName(AUnitNames, AProjectName, AEntity.Name));
  AValidator.Check(
    Assigned(TTIOTA.SearchModule(LModuleName)), LModuleName);
end;

function TTGenerateModel.CheckOverwrite(
  const AEntities: TList<TTEntity>): Boolean;
var
  LValidator: TTValidator;
  LProjectName: String;
  LEntity: TTEntity;
begin
  result := True;
  LValidator := TTValidator.Create('These units will be overwritten:');
  try
    LProjectName := TTIOTA.ActiveProjectName;
    if not LProjectName.IsEmpty then
    begin
      for LEntity in AEntities do
      begin
        if ModelsCheckbox.Checked then
          CheckModule(
            LValidator,
            LProjectName,
            ModelDirectoryTextbox.Text,
            UnitFilenamesTextbox.Text,
            LEntity);

        if IsControllersChecked then
          CheckModule(
            LValidator,
            LProjectName,
            ControllersDirectoryTextbox.Text,
            ControllerFilenamesTextbox.Text,
            LEntity);
      end;

      result := LValidator.IsValid;
      if not result then
        result := MessageDlg(
          LValidator.Messages + #10#10 + 'Continue?',
          TMsgDlgType.mtConfirmation,
          [mbYes, mbNo],
          0,
          mbNo) = mrYes;
    end;
  finally
    LValidator.Free;
  end;
end;

procedure TTGenerateModel.FormShow(Sender: TObject);
var
  LEntity: TTEntity;
  LItem: TListItem;
  LEntityItem: TTEntityListItem absolute LItem;
begin
  EntitiesListView.Items.BeginUpdate;
  try
    for LEntity in FEntities.Entities do
    begin
      LItem := EntitiesListView.Items.Add;
      LEntityItem.Value := LEntity;
      LItem.Checked := True;
    end;
  finally
    EntitiesListView.Items.EndUpdate;
  end;
end;

procedure TTGenerateModel.EntitiesListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TTEntityListItem;
end;

procedure TTGenerateModel.SelectAllEntities(const ASelect: Boolean);
var
  LItem: TListItem;
begin
  for LItem in EntitiesListView.Items do
    LItem.Checked := ASelect;
end;

procedure TTGenerateModel.SelectAllEntitiesMenuItemClick(Sender: TObject);
begin
  SelectAllEntities(True);
end;

procedure TTGenerateModel.UnselectallEntitiesMenuItemClick(Sender: TObject);
begin
  SelectAllEntities(False);
end;

procedure TTGenerateModel.CreateModels(const AEntities: TList<TTEntity>);
var
  LCreator: TTModelCreator;
begin
  LCreator := TTModelCreator.Create(
    FProject.Name,
    UnitFilenamesTextbox.Text,
    TTUtils.ProjectFolder(FProject.Directory, ModelDirectoryTextbox.Text),
    FilterPropertiesCheckbox.Checked);
  try
    LCreator.CreateModels(FEntities, AEntities);
  finally
    LCreator.Free;
  end;
end;

procedure TTGenerateModel.CreateEvents(const AEntities: TList<TTEntity>);
var
  LCreator: TTEventCreator;
begin
  LCreator := TTEventCreator.Create(
    FProject.Name,
    UnitFilenamesTextbox.Text,
    EventFilenamesTextbox.Text,
    TTUtils.ProjectFolder(FProject.Directory, EventsDirectoryTextbox.Text));
  try
    LCreator.CreateEvents(AEntities);
  finally
    LCreator.Free;
  end;
end;

procedure TTGenerateModel.CreateControllers(const AEntities: TList<TTEntity>);
var
  LCreator: TTControllerCreator;
begin
  LCreator := TTControllerCreator.Create(
    FProject.Name,
    UnitFilenamesTextbox.Text,
    ControllerFilenamesTextbox.Text,
    TTUtils.ProjectFolder(
      FProject.Directory, ControllersDirectoryTextbox.Text));
  try
    LCreator.CreateControllers(AEntities);
  finally
    LCreator.Free;
  end;
end;

procedure TTGenerateModel.ModifyAPIHttp(const AEntities: TList<TTEntity>);
var
  LModifier: TTAPIHttpModifier;
begin
  LModifier := TTAPIHttpModifier.Create(
    TTIOTA.ActiveProjectName, ControllerFilenamesTextbox.Text, AEntities);
  try
    LModifier.Modify;
  finally
    LModifier.Free;
  end;
end;

procedure TTGenerateModel.Generate(const AEntities: TList<TTEntity>);
begin
  Screen.Cursor := crHourglass;
  try
    FEntities.CalculateUsesAndRelations;
    if ModelsCheckbox.Checked then
      CreateModels(AEntities);
    if EventsCheckbox.Checked then
      CreateEvents(AEntities);
    if IsControllersChecked then
    begin
      CreateControllers(AEntities);
      ModifyAPIHttp(AEntities);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TTGenerateModel.BackButtonClick(Sender: TObject);
begin
  FWizard.PreviousPage;
  EnableDisableButtons;
end;

procedure TTGenerateModel.NextButtonClick(Sender: TObject);
begin
  FWizard.NextPage;
  EnableDisableButtons;
end;

procedure TTGenerateModel.FinishButtonClick(Sender: TObject);
var
  LEntities: TList<TTEntity>;
begin
  LEntities := TList<TTEntity>.Create;
  try
    CheckGeneration;
    AddSelectedEntities(LEntities);
    if CheckOverwrite(LEntities) then
    begin
      Generate(LEntities);
      ControlsToConfig;
      ModalResult := mrOk;
    end;
  finally
    LEntities.Free;
  end;
end;

function TTGenerateModel.HelpPage: String;
begin
  result := 'generate-model/';
end;

class procedure TTGenerateModel.ShowDialog(const AProject: TTProject);
var
  LDialog: TTGenerateModel;
begin
  LDialog := TTGenerateModel.Create(AProject);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
