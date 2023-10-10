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
  Trysil.Expert.UI.Images,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.Validator,
  Trysil.Expert.ModelCreator,
  Trysil.Expert.ControllerCreator,
  Trysil.Expert.APIHttpModifier;

type

{ TTGenerateModel }

  TTGenerateModel = class(TTThemedForm)
    EntitiesPopupMenu: TPopupMenu;
    SelectAllEntitiesMenuItem: TMenuItem;
    UnselectAllEntitiesMenuItem: TMenuItem;
    ModelDirectoryLabel: TLabel;
    ModelDirectoryTextbox: TEdit;
    UnitFilenamesLabel: TLabel;
    UnitFilenamesTextbox: TEdit;
    EntitiesLabel: TLabel;
    EntitiesListView: TListView;
    APIControllersCheckbox: TCheckBox;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure EntitiesListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure SelectAllEntitiesMenuItemClick(Sender: TObject);
    procedure UnselectallEntitiesMenuItemClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FProject: TTProject;
    FConfig: TTLocalConfig;
    FEntities: TTEntities;

    procedure CheckIsAPIRestApplication;
    procedure ConfigToControls;
    procedure ControlsToConfig;
    procedure AddSelectedEntities(const AEntities: TList<TTEntity>);
    function CheckOverwrite(const AEntities: TList<TTEntity>): Boolean;
    procedure SelectAllEntities(const ASelect: Boolean);
    procedure CreateModels(const AEntities: TList<TTEntity>);
    procedure CreateControllers(const AEntities: TList<TTEntity>);
    procedure ModifyAPIHttp(const AEntities: TList<TTEntity>);
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
end;

destructor TTGenerateModel.Destroy;
begin
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
end;

procedure TTGenerateModel.CheckIsAPIRestApplication;
var
  LProjectName: String;
  LHttpModule, LControllerModule: IInterface;
begin
  APIControllersCheckbox.Enabled := False;

  LProjectName := TTIOTA.ActiveProjectName;
  LHttpModule := TTIOTA.SearchModule(
    Format('API\%s.Http', [LProjectName]));
  LControllerModule := TTIOTA.SearchModule(
    Format('API\Controllers\%s.Controller', [LProjectName]));

  APIControllersCheckbox.Enabled :=
    Assigned(LHttpModule) and Assigned(LControllerModule);
end;

procedure TTGenerateModel.ConfigToControls;
begin
  ModelDirectoryTextbox.Text := FConfig.ModelDirectory;
  UnitFilenamesTextbox.Text := FConfig.UnitFilenames;
  APIControllersCheckbox.Checked :=
    APIControllersCheckbox.Enabled and FConfig.Controllers;
end;

procedure TTGenerateModel.ControlsToConfig;
begin
  FConfig.ModelDirectory := ModelDirectoryTextbox.Text;
  FConfig.UnitFilenames := UnitFilenamesTextbox.Text;
  FConfig.Controllers :=
    APIControllersCheckbox.Enabled and APIControllersCheckbox.Checked;
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

function TTGenerateModel.CheckOverwrite(
  const AEntities: TList<TTEntity>): Boolean;
var
  LValidator: TTValidator;
  LProjectName, LModuleName: String;
  LEntity: TTEntity;
  LModuleInfo: IOTAModuleInfo;
begin
  result := True;
  LValidator := TTValidator.Create('These units will be overwritten:');
  try
    LProjectName := TTIOTA.ActiveProjectName;
    if not LProjectName.IsEmpty then
    begin
      for LEntity in AEntities do
      begin
        LModuleName := TPath.Combine(
          ModelDirectoryTextbox.Text,
          TTUtils.UnitName(
            UnitFilenamesTextbox.Text, LProjectName, LEntity.Name));
        LModuleInfo := TTIOTA.SearchModule(LModuleName);
        LValidator.Check(Assigned(LModuleInfo), LModuleName);

        if APIControllersCheckbox.Enabled and
          APIControllersCheckbox.Checked then
        begin
          LModuleName := TPath.Combine(
            TPath.Combine('API', 'Controllers'),
              Format('%s.Controller.%s', [LProjectName, LEntity.Name]));
          LModuleInfo := TTIOTA.SearchModule(LModuleName);
          LValidator.Check(Assigned(LModuleInfo), LModuleName);
        end;
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
    TTUtils.ModelFolder(FProject.Directory, ModelDirectoryTextbox.Text));
  try
    LCreator.CreateModels(FEntities, AEntities);
  finally
    LCreator.Free;
  end;
end;

procedure TTGenerateModel.CreateControllers(const AEntities: TList<TTEntity>);
var
  LDirectory: String;
  LCreator: TTControllerCreator;
begin
  LDirectory :=
    TPath.Combine(
      TPath.Combine(FProject.Directory, 'API'), 'Controllers');

  LCreator := TTControllerCreator.Create(
    FProject.Name, UnitFilenamesTextbox.Text, LDirectory);
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
  LModifier := TTAPIHttpModifier.Create(TTIOTA.ActiveProjectName, AEntities);
  try
    LModifier.Modify;
  finally
    LModifier.Free;
  end;
end;

procedure TTGenerateModel.SaveButtonClick(Sender: TObject);
var
  LEntities: TList<TTEntity>;
begin
  LEntities := TList<TTEntity>.Create;
  try
    AddSelectedEntities(LEntities);
    if CheckOverwrite(LEntities) then
    begin
      Screen.Cursor := crHourglass;
      try
        FEntities.CalculateUsesAndRelations;
        CreateModels(LEntities);
        if APIControllersCheckbox.Enabled and
          APIControllersCheckbox.Checked then
        begin
          CreateControllers(LEntities);
          ModifyAPIHttp(LEntities);
        end;
      finally
        Screen.Cursor := crDefault;
      end;

      ControlsToConfig;
      ModalResult := mrOk;
    end;
  finally
    LEntities.Free;
  end;
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
