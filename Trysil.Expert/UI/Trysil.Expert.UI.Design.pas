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
  Trysil.Expert.UI.DesignColumn.EntityListTypeColumn, System.Actions,
  Vcl.ActnList, System.ImageList, Vcl.ImgList;

type

{ TTDesignForm }

  TTDesignForm = class(TTThemedForm)
    ImageList: TImageList;
    ActionList: TActionList;
    AddNewEntityAction: TAction;
    EditEntityAction: TAction;
    DeleteEntityAction: TAction;
    AddNewPropertyAction: TAction;
    EditPropertyAction: TAction;
    DeletePropertyAction: TAction;
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
    AddNewPropertyButton: TSpeedButton;
    EditPropertyButton: TSpeedButton;
    DeletePropertyButton: TSpeedButton;
    ListView: TListView;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure TreeViewCreateNodeClass(
      Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure ListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure AddNewEntity(Sender: TObject);
    procedure EditEntity(Sender: TObject);
    procedure DeleteEntity(Sender: TObject);
    procedure AddNewProperty(Sender: TObject);
    procedure EditProperty(Sender: TObject);
    procedure DeleteProperty(Sender: TObject);
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
  FEntities.LoadFromDirectory(FDirectory);
end;

procedure TTDesignForm.SetImages;
begin
  TreeView.Images := TTImagesDataModule.Instance.Images;
  ListView.SmallImages := TTImagesDataModule.Instance.Images;
end;

procedure TTDesignForm.ActionListUpdate(
  Action: TBasicAction; var Handled: Boolean);
var
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
  LEnabled: Boolean;
begin
  EditEntityAction.Enabled := Assigned(TreeView.Selected);
  DeleteEntityAction.Enabled := EditEntityAction.Enabled;

  AddNewPropertyAction.Enabled := EditEntityAction.Enabled;

  LItem := ListView.Selected;
  LEnabled := Assigned(LItem) and
    ((not (LColumnItem.Value is TTColumn)) or
    (not (TTColumn(LColumnItem.Value).DataType in [dtPrimaryKey, dtVersion])));
  EditPropertyAction.Enabled := LEnabled;
  DeletePropertyAction.Enabled := LEnabled;

  Handled := True;
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

procedure TTDesignForm.AddNewEntity(Sender: TObject);
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

procedure TTDesignForm.EditEntity(Sender: TObject);
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

procedure TTDesignForm.DeleteEntity(Sender: TObject);
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

procedure TTDesignForm.AddNewProperty(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
begin
  LNode := TreeView.Selected;
  if Assigned(LNode) then
    if TTDesignColumnForm.ShowDialog(FEntities, LEntityNode.Value) then
      ShowColumns;
end;

procedure TTDesignForm.EditProperty(Sender: TObject);
var
  LNode: TTreeNode;
  LEntityNode: TTEntityTreeNode absolute LNode;
  LEntity: TTEntity;
  LItem: TListItem;
  LColumnItem: TTColumnListItem absolute LItem;
  LColumn: TTAbstractColumn;
  LResult: Boolean;
begin
  if EditPropertyAction.Enabled then
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

procedure TTDesignForm.DeleteProperty(Sender: TObject);
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
