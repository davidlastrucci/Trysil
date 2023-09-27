(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Design;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.AppEvnts,

  Trysil.Expert.Consts,
  Trysil.Expert.Project,
  Trysil.Expert.Config,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Images,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.UI.DesignEntity,
  Trysil.Expert.UI.DesignColumn,
  Trysil.Expert.UI.DesignColumn.DataTypeColumn,
  Trysil.Expert.UI.DesignColumn.EntityTypeColumn,
  Trysil.Expert.UI.DesignColumn.EntityListTypeColumn;

type

{ TTDesignForm }

  TTDesignForm = class(TTThemedForm)
    ApplicationEvents: TApplicationEvents;
    TreeViewPanel: TPanel;
    TreeViewTitlePanel: TPanel;
    TreeViewToolBarPanel: TPanel;
    AddNewEntityButton: TSpeedButton;
    EditEntityButton: TSpeedButton;
    DeleteEntityButton: TSpeedButton;
    TreeView: TTreeView;
    ListViewPanel: TPanel;
    ListViewTitlePanel: TPanel;
    ListViewToolBarPanel: TPanel;
    AddNewColumnButton: TSpeedButton;
    EditColumnButton: TSpeedButton;
    DeleteColumnButton: TSpeedButton;
    ListView: TListView;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure ApplicationEventsIdle(Sender: TObject; var Done: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TreeViewCreateNodeClass(
      Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure ListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure AddNewEntityButtonClick(Sender: TObject);
    procedure EditEntityButtonClick(Sender: TObject);
    procedure DeleteEntityButtonClick(Sender: TObject);
    procedure AddNewColumnButtonClick(Sender: TObject);
    procedure EditColumnButtonClick(Sender: TObject);
    procedure DeleteColumnButtonClick(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    const Margin: Integer = 40;
  strict private
    FDirectory: String;
    FEntities: TTEntities;

    procedure SetImages;

    procedure ShowEntities;
    procedure ShowColumns;
  public
    constructor Create(const ADirectory: String); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class procedure ShowDialog(const AProject: TTProject);
  end;

implementation

{$R *.dfm}

{ TTDesignForm }

constructor TTDesignForm.Create(const ADirectory: String);
begin
  inherited Create(nil);
  FDirectory := ADirectory;
  FEntities := TTEntities.Create;
end;

destructor TTDesignForm.Destroy;
begin
  FEntities.Free;
  inherited Destroy;
end;

procedure TTDesignForm.AfterConstruction;
begin
  inherited AfterConstruction;
  SetImages;
  ListView.SmallImages := TTImagesDataModule.Instance.Images;
  FEntities.LoadFromDirectory(FDirectory);
end;

procedure TTDesignForm.SetImages;
begin
  TreeView.Images := TTImagesDataModule.Instance.Images;
  AddNewEntityButton.Images := TTImagesDataModule.Instance.ButtonsImages;
  EditEntityButton.Images := TTImagesDataModule.Instance.ButtonsImages;
  DeleteEntityButton.Images := TTImagesDataModule.Instance.ButtonsImages;
  AddNewColumnButton.Images := TTImagesDataModule.Instance.ButtonsImages;
  EditColumnButton.Images := TTImagesDataModule.Instance.ButtonsImages;
  DeleteColumnButton.Images := TTImagesDataModule.Instance.ButtonsImages;
end;

procedure TTDesignForm.ApplicationEventsIdle(
  Sender: TObject; var Done: Boolean);
var
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
  LEnabled: Boolean;
begin
  EditEntityButton.Enabled := Assigned(TreeView.Selected);
  DeleteEntityButton.Enabled := EditEntityButton.Enabled;

  AddNewColumnButton.Enabled := EditEntityButton.Enabled;

  LItem := ListView.Selected;
  LEnabled := Assigned(LItem) and
    ((not (LColumnItem.Value is TTColumn)) or
    (not (TTColumn(LColumnItem.Value).DataType in [dtPrimaryKey, dtVersion])));
  EditColumnButton.Enabled := LEnabled;
  DeleteColumnButton.Enabled := LEnabled;

  Done := True;
end;

procedure TTDesignForm.ShowEntities;
var
  LEntity: TTEntity;
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  TreeView.Items.BeginUpdate;
  try
    for LEntity in FEntities.Entities do
    begin
      LNode := TreeView.Items.AddChild(nil, LEntity.Name);
      LEntityNode.Value := LEntity;
    end;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TTDesignForm.ShowColumns;
var
  LColumn: TTAbstractColumn;
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
begin
  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    LNode := TreeView.Selected;
    if Assigned(LNode) then
      for LColumn in LEntityNode.Value.Columns.Columns do
      begin
        LItem := ListView.Items.Add;
        LColumnItem.Value := LColumn;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TTDesignForm.FormShow(Sender: TObject);
begin
  ShowEntities;
end;

procedure TTDesignForm.TreeViewCreateNodeClass(
  Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := TTEntityTreeNode;
end;

procedure TTDesignForm.ListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TTColumnListItem;
end;

procedure TTDesignForm.AddNewEntityButtonClick(Sender: TObject);
var
  FAdded: Boolean;
  LEntity: TTEntity;
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  FAdded := False;
  LEntity := TTEntity.Create(FEntities);
  try
    if TTDesignEntityForm.ShowDialog(FEntities, LEntity) then
    begin
      LNode := TreeView.Items.AddChild(nil, LEntity.Name);
      LEntityNode.Value := LEntity;
      FEntities.AddEntity(LEntity);
      FAdded := True;

      TreeView.Items.AlphaSort(False);
      TreeView.Selected := LNode;
    end;
  finally
    if not FAdded then
      LEntity.Free;
  end;
end;

procedure TTDesignForm.EditEntityButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  if EditEntityButton.Enabled then
  begin
    LNode := TreeView.Selected;
    if Assigned(LNode) then
      if TTDesignEntityForm.ShowDialog(FEntities, LEntityNode.Value) then
      begin
        LNode.Text := LEntityNode.Value.Name;
        TreeView.Items.AlphaSort(False);
        TreeView.Selected := LNode;
      end;
  end;
end;

procedure TTDesignForm.DeleteEntityButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  LNode := TreeView.Selected;
  if Assigned(LNode) then
    if MessageDlg(
      Format(SDeleteEntity, [LNode.Text]),
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      0,
      TMsgDlgBtn.mbNo) = mrYes then
    begin
      FEntities.DeleteEntity(LEntityNode.Value);
      ListView.Items.Clear;
      TreeView.Items.Delete(LNode);
    end;
end;

procedure TTDesignForm.AddNewColumnButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  LNode := TreeView.Selected;
  if Assigned(LNode) then
    if TTDesignColumnForm.ShowDialog(FEntities, LEntityNode.Value) then
      ShowColumns;
end;

procedure TTDesignForm.EditColumnButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
  LEntity: TTEntity;
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
  LColumn: TTAbstractColumn;
  LResult: Boolean;
begin
  if EditColumnButton.Enabled then
  begin
    LNode := TreeView.Selected;
    if Assigned(LNode) then
    begin
      LEntity := LEntityNode.Value;
      LItem := ListView.Selected;
      if Assigned(LItem) then
      begin
        LColumn := LColumnItem.Value;
        if LColumn is TTColumn then
          LResult := TTDesignDataTypeColumnForm.ShowDialog(
            LEntity, TTColumn(LColumn))
        else if LColumn is TTLazyColumn then
          LResult := TTDesignEntityTypeColumnForm.ShowDialog(
            FEntities, LEntity, TTLazyColumn(LColumn))
        else if LColumn is TTLazyListColumn then
          LResult := TTDesignEntityListTypeColumnForm.ShowDialog(
            FEntities, LEntity, TTLazyListColumn(LColumn))
        else
          LResult := False;

        if LResult then
          ShowColumns;
      end;
    end;
  end;
end;

procedure TTDesignForm.DeleteColumnButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
  LEntity: TTEntity;
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
  LColumn: TTAbstractColumn;
begin
  LNode := TreeView.Selected;
  if Assigned(LNode) then
  begin
    LEntity := LEntityNode.Value;
    LItem := ListView.Selected;
    if Assigned(LItem) then
    begin
      LColumn := LColumnItem.Value;
      if MessageDlg(
        Format(SDeleteColumn, [LItem.Caption]),
        TMsgDlgType.mtConfirmation,
        [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
        0,
        TMsgDlgBtn.mbNo) = mrYes then
      begin
        LEntity.Columns.DeleteColumn(LColumn);
        ListView.Items.Delete(LItem.Index);
      end;
    end;
  end;
end;

procedure TTDesignForm.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  ShowColumns;
end;

procedure TTDesignForm.SaveButtonClick(Sender: TObject);
begin
  FEntities.SaveToDirectory(FDirectory);
  ModalResult := mrOk;
end;

class procedure TTDesignForm.ShowDialog(const AProject: TTProject);
var
  LDialog: TTDesignForm;
begin
  LDialog := TTDesignForm.Create(TTUtils.TrysilFolder(AProject.Directory));
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
