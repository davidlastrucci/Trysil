(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.GenerateSQL;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.ImgList,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.Project,
  Trysil.Expert.Config,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.SQLCreator, Vcl.Menus;

type

{ TTGenerateSQL }

  TTGenerateSQL = class(TForm)
    TrysilImage: TImage;
    ImageList: TImageList;
    SaveDialog: TSaveDialog;
    DatabaseTypeLabel: TLabel;
    DatabaseTypeCombobox: TComboBox;
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

constructor TTGenerateSQL.Create(const AProject: TTProject);
begin
  inherited Create(nil);
  FProject := AProject;
  FEntities := TTEntities.Create;
end;

destructor TTGenerateSQL.Destroy;
begin
  FEntities.Free;
  inherited Destroy;
end;

procedure TTGenerateSQL.AfterConstruction;
begin
  inherited AfterConstruction;
  FEntities.LoadFromDirectory(TTUtils.TrysilFolder(FProject.Directory));
end;

procedure TTGenerateSQL.AddSelectedEntities(const AEntities: TList<TTEntity>);
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

procedure TTGenerateSQL.FormShow(Sender: TObject);
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

procedure TTGenerateSQL.EntitiesListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TTEntityListItem;
end;

procedure TTGenerateSQL.SelectAllEntities(const ASelect: Boolean);
var
  LItem: TListItem;
begin
  for LItem in EntitiesListView.Items do
    LItem.Checked := ASelect;
end;

procedure TTGenerateSQL.SelectAllEntitiesMenuItemClick(Sender: TObject);
begin
  SelectAllEntities(True);
end;

procedure TTGenerateSQL.UnselectallEntitiesMenuItemClick(Sender: TObject);
begin
  SelectAllEntities(False);
end;

procedure TTGenerateSQL.SaveButtonClick(Sender: TObject);
var
  LEntities: TList<TTEntity>;
  LSQLCreator: TTSQLCreator;
begin
  Screen.Cursor := crHourGlass;
  try
    LEntities := TList<TTEntity>.Create;
    try
      AddSelectedEntities(LEntities);
      if SaveDialog.Execute then
      begin
        LSQLCreator := TTSQLCreator.Create(
          TTSQLCreatorType(DatabaseTypeCombobox.ItemIndex));
        try
          LSQLCreator.CreateEntities(LEntities);
          TFile.WriteAllText(SaveDialog.FileName, LSQLCreator.ToString);
        finally
          LSQLCreator.Free;
        end;

        ModalResult := mrOk;
      end;
    finally
      LEntities.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

class procedure TTGenerateSQL.ShowDialog(const AProject: TTProject);
var
  LDialog: TTGenerateSQL;
begin
  LDialog := TTGenerateSQL.Create(AProject);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
