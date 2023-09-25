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
  System.Generics.Collections,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.ImgList,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.Project,
  Trysil.Expert.Config,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.PascalCreator, Vcl.Menus;

type

{ TTGenerateModel }

  TTGenerateModel = class(TForm)
    TrysilImage: TImage;
    ImageList: TImageList;
    ModelDirectoryLabel: TLabel;
    ModelDirectoryTextbox: TEdit;
    UnitFilenamesLabel: TLabel;
    UnitFilenamesTextbox: TEdit;
    EntitiesLabel: TLabel;
    EntitiesListView: TListView;
    SaveButton: TButton;
    CancelButton: TButton;
    EntitiesPopupMenu: TPopupMenu;
    SelectAllEntitiesMenuItem: TMenuItem;
    UnselectAllEntitiesMenuItem: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure EntitiesListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure SelectAllEntitiesMenuItemClick(Sender: TObject);
    procedure UnselectallEntitiesMenuItemClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FProject: TTProject;
    FEntities: TTEntities;

    procedure ConfigToControls;
    procedure AddSelectedEntities(const AEntities: TList<TTEntity>);
    procedure SelectAllEntities(const ASelect: Boolean);
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
  FEntities := TTEntities.Create;
end;

destructor TTGenerateModel.Destroy;
begin
  FEntities.Free;
  inherited Destroy;
end;

procedure TTGenerateModel.AfterConstruction;
begin
  inherited AfterConstruction;
  ConfigToControls;
  FEntities.LoadFromDirectory(TTUtils.TrysilFolder(FProject.Directory));
end;

procedure TTGenerateModel.ConfigToControls;
begin
  ModelDirectoryTextbox.Text := TTConfig.Instance.ModelDirectory;
  UnitFilenamesTextbox.Text := TTConfig.Instance.UnitFilenames;
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

procedure TTGenerateModel.SaveButtonClick(Sender: TObject);
var
  LEntities: TList<TTEntity>;
  LPascalCreator: TTPascalCreator;
begin
  Screen.Cursor := crHourglass;
  try
    FEntities.CalculateUsesAndRelations;
    LEntities := TList<TTEntity>.Create;
    try
      AddSelectedEntities(LEntities);
      LPascalCreator := TTPascalCreator.Create(
        FProject.Name,
        UnitFilenamesTextbox.Text,
        TTUtils.ModelFolder(FProject.Directory, ModelDirectoryTextbox.Text));
      try
        LPascalCreator.CreateEntities(FEntities, LEntities);
      finally
        LPascalCreator.Free;
      end;
    finally
      LEntities.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  ModalResult := mrOk;
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
