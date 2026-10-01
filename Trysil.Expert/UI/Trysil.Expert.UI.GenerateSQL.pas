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
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Menus,
  Vcl.Imaging.PngImage,

  Trysil.Expert.Consts,
  Trysil.Expert.Classes,
  Trysil.Expert.Project,
  Trysil.Expert.Config,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Images,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.UI.ReferenceDatabase,
  Trysil.Expert.SQLCreator,
  Trysil.Expert.Schema,
  Trysil.Expert.SchemaReader,
  Trysil.Expert.SQLUpdateCreator;

type

{ TTGenerateSQL }

  TTGenerateSQL = class(TTThemedForm)
    SaveDialog: TSaveDialog;
    DatabaseTypeLabel: TLabel;
    DatabaseTypeCombobox: TComboBox;
    EntitiesLabel: TLabel;
    EntitiesListView: TListView;
    CancelButton: TButton;
    EntitiesPopupMenu: TPopupMenu;
    SelectAllEntitiesMenuItem: TMenuItem;
    UnselectAllEntitiesMenuItem: TMenuItem;
    SaveButton: TButton;
    AlterCheckbox: TCheckBox;
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

    procedure ConfigToControls;
    procedure ControlsToConfig;

    procedure AddSelectedEntities(const AEntities: TList<TTEntity>);
    procedure SelectAllEntities(const ASelect: Boolean);

    function DatabaseType: TTSQLCreatorType;
    procedure SaveCreateScript(const AEntities: TList<TTEntity>);
    procedure ReadSchema(
      const AParameters: TTDatabaseParameters;
      const AEntities: TList<TTEntity>;
      const ASchema: TTSchema);
    function CreateUpdateScript(
      const AParameters: TTDatabaseParameters;
      const AEntities: TList<TTEntity>): String;
    procedure SaveUpdateScript(const AEntities: TList<TTEntity>);
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

constructor TTGenerateSQL.Create(const AProject: TTProject);
begin
  inherited Create(nil);
  FProject := AProject;

  FConfig := TTLocalConfig.Create;
  FEntities := TTEntities.Create;
end;

destructor TTGenerateSQL.Destroy;
begin
  FEntities.Free;
  FConfig.Free;
  inherited Destroy;
end;

procedure TTGenerateSQL.AfterConstruction;
begin
  inherited AfterConstruction;
  EntitiesListView.SmallImages := TTImagesDataModule.Instance.Images;
  ConfigToControls;
  FEntities.LoadFromDirectory(TTUtils.TrysilFolder(FProject.Directory));
end;

procedure TTGenerateSQL.ConfigToControls;
begin
  DatabaseTypeCombobox.ItemIndex := FConfig.DatabaseType;
end;

procedure TTGenerateSQL.ControlsToConfig;
begin
  FConfig.DatabaseType := DatabaseTypeCombobox.ItemIndex;
  FConfig.Save;
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

function TTGenerateSQL.DatabaseType: TTSQLCreatorType;
begin
  result := TTSQLCreatorType(DatabaseTypeCombobox.ItemIndex);
end;

procedure TTGenerateSQL.SaveCreateScript(const AEntities: TList<TTEntity>);
var
  LSQLCreator: TTSQLCreator;
begin
  if SaveDialog.Execute then
  begin
    Screen.Cursor := crHourGlass;
    try
      LSQLCreator := TTSQLCreator.Create(DatabaseType);
      try
        LSQLCreator.CreateEntities(AEntities);
        TFile.WriteAllText(SaveDialog.FileName, LSQLCreator.ToString);
      finally
        LSQLCreator.Free;
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;

  ControlsToConfig;
  ModalResult := mrOk;
end;

procedure TTGenerateSQL.ReadSchema(
  const AParameters: TTDatabaseParameters;
  const AEntities: TList<TTEntity>;
  const ASchema: TTSchema);
var
  LTableNames: TList<String>;
  LReader: TTSchemaReader;
begin
  LTableNames := TList<String>.Create;
  try
    TTSQLUpdateCreator.AddTableNames(AEntities, LTableNames);
    LReader := TTSchemaReader.Create(AParameters);
    try
      LReader.Read(ASchema, LTableNames);
    finally
      LReader.Free;
    end;
  finally
    LTableNames.Free;
  end;
end;

function TTGenerateSQL.CreateUpdateScript(
  const AParameters: TTDatabaseParameters;
  const AEntities: TList<TTEntity>): String;
var
  LSchema: TTSchema;
  LCreator: TTSQLUpdateCreator;
begin
  LSchema := TTSchema.Create;
  try
    ReadSchema(AParameters, AEntities, LSchema);
    LCreator := TTSQLUpdateCreator.Create(DatabaseType, LSchema);
    try
      LCreator.AlignEntities(AEntities);
      result := LCreator.ToString;
    finally
      LCreator.Free;
    end;
  finally
    LSchema.Free;
  end;
end;

procedure TTGenerateSQL.SaveUpdateScript(const AEntities: TList<TTEntity>);
var
  LEntities: TList<TTEntity>;
  LScript: String;
begin
  if not TTSchemaReader.DriverAvailable(DatabaseType) then
    raise ETExpertException.CreateFmt(
      SDriverNotAvailable, [DatabaseTypeCombobox.Text]);

  LEntities := AEntities;
  if TTReferenceDatabaseForm.ShowDialog(
    FConfig,
    DatabaseType,
    function(const AParameters: TTDatabaseParameters): String
    begin
      result := CreateUpdateScript(AParameters, LEntities);
    end,
    LScript) and SaveDialog.Execute then
  begin
    TFile.WriteAllText(SaveDialog.FileName, LScript);
    ControlsToConfig;
    ModalResult := mrOk;
  end;
end;

procedure TTGenerateSQL.SaveButtonClick(Sender: TObject);
var
  LEntities: TList<TTEntity>;
begin
  LEntities := TList<TTEntity>.Create;
  try
    AddSelectedEntities(LEntities);
    if AlterCheckbox.Checked then
      SaveUpdateScript(LEntities)
    else
      SaveCreateScript(LEntities);
  finally
    LEntities.Free;
  end;
end;

function TTGenerateSQL.HelpPage: String;
begin
  result := 'generate-sql/';
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
