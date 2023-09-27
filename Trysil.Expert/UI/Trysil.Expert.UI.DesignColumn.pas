(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.DesignColumn;

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

  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Images,
  Trysil.Expert.UI.DesignColumn.DataTypeColumn,
  Trysil.Expert.UI.DesignColumn.EntityTypeColumn,
  Trysil.Expert.UI.DesignColumn.EntityListTypeColumn;

type

{ TTDesignColumnForm }

  TTDesignColumnForm = class(TTThemedForm)
    ColumnTypeLabel: TLabel;
    OkeyButton: TButton;
    CancelButton: TButton;
    TreeView: TTreeView;
    procedure OkeyButtonClick(Sender: TObject);
  strict private
    FEntities: TTEntities;
    FEntity: TTEntity;

    function CreateDataColumn: Boolean;
    function CreateEntityColumn: Boolean;
    function CreateEntityListColumn: Boolean;
  public
    constructor Create(
      const AEntities: TTEntities; const AEntity: TTEntity); reintroduce;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AEntities: TTEntities; const AEntity: TTEntity): Boolean;
  end;

implementation

{$R *.dfm}

{ TTDesignColumnForm }

constructor TTDesignColumnForm.Create(
  const AEntities: TTEntities; const AEntity: TTEntity);
begin
  inherited Create(nil);
  FEntities := AEntities;
  FEntity := AEntity;;
end;

procedure TTDesignColumnForm.AfterConstruction;
begin
  inherited AfterConstruction;
  TreeView.Images := TTImagesDataModule.Instance.Images;
  TreeView.Selected := TreeView.Items[0];
end;

procedure TTDesignColumnForm.OkeyButtonClick(Sender: TObject);
var
  LNode: TTreeNode;
  LResult: Boolean;
begin
  LNode := TreeView.Selected;
  if Assigned(LNode) then
  begin
    case LNode.StateIndex of
      0: // Data column
        LResult := CreateDataColumn;

      1: // Entity column
        LResult := CreateEntityColumn;

      2: // Entity list column
        LResult := CreateEntityListColumn;

      else
        LResult := False;
    end;

    if LResult then
      ModalResult := mrOk;
  end;
end;

function TTDesignColumnForm.CreateDataColumn: Boolean;
var
  LColumn: TTColumn;
begin
  result := False;
  LColumn := TTColumn.Create(FEntities, FEntity);
  try
    if TTDesignDataTypeColumnForm.ShowDialog(FEntity, LColumn) then
    begin
      FEntity.Columns.AddColumn(LColumn);
      result := True;
    end;
  finally
    if not result then
      LColumn.Free;
  end;
end;

function TTDesignColumnForm.CreateEntityColumn: Boolean;
var
  LColumn: TTLazyColumn;
begin
  result := False;
  LColumn := TTLazyColumn.Create(FEntities, FEntity);
  try
    if TTDesignEntityTypeColumnForm.ShowDialog(
      FEntities, FEntity, LColumn) then
    begin
      FEntity.Columns.AddColumn(LColumn);
      result := True;
    end;
  finally
    if not result then
      LColumn.Free;
  end;
end;

function TTDesignColumnForm.CreateEntityListColumn: Boolean;
var
  LColumn: TTLazyListColumn;
begin
  result := False;
  LColumn := TTLazyListColumn.Create(FEntities, FEntity);
  try
    if TTDesignEntityListTypeColumnForm.ShowDialog(
      FEntities, FEntity, LColumn) then
    begin
      FEntity.Columns.AddColumn(LColumn);
      result := True;
    end;
  finally
    if not result then
      LColumn.Free;
  end;
end;

class function TTDesignColumnForm.ShowDialog(
  const AEntities: TTEntities; const AEntity: TTEntity): Boolean;
var
  LDialog: TTDesignColumnForm;
begin
  LDialog := TTDesignColumnForm.Create(AEntities, AEntity);
  try
    result := LDialog.ShowModal = mrOk;
  finally
    LDialog.Free;
  end;
end;

end.
