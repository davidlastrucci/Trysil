(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.DesignColumn.EntityListTypeColumn;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Defaults,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,

  Trysil.Expert.Consts,
  Trysil.Expert.Validator,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed, Vcl.Imaging.pngimage;

type

{ TTDesignEntityListTypeColumnForm }

  TTDesignEntityListTypeColumnForm = class(TTThemedForm)
    NameLabel: TLabel;
    NameTextbox: TEdit;
    ColumnNameLabel: TLabel;
    EntityTypeLabel: TLabel;
    EntityTypeCombobox: TComboBox;
    EntityTypeListbox: TListBox;
    ColumnNameCombobox: TComboBox;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure EntityTypeComboboxChange(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FEntities: TTEntities;
    FEntity: TTEntity;
    FColumn: TTLazyListColumn;
    FValidator: TTValidator;

    procedure ShowEntities;
    function IsForeignKeyColumn(const AColumn: TTAbstractColumn): Boolean;
    procedure ShowColumns;
    function SelectedColumnName: String;
    function IndexOfColumnName(const AColumnName: String): Integer;
    procedure ColumnToControls;
    procedure CheckColumn;
    procedure CheckNames;
    procedure ControlsToColumn;
  strict protected
    function HelpPage: String; override;
  public
    constructor Create(
      const AEntities: TTEntities;
      const AEntity: TTEntity;
      const AColumn: TTLazyListColumn); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AEntities: TTEntities;
      const AEntity: TTEntity;
      const AColumn: TTLazyListColumn): Boolean;
  end;

implementation

{$R *.dfm}

{ TTDesignEntityListTypeColumnForm }

constructor TTDesignEntityListTypeColumnForm.Create(
  const AEntities: TTEntities;
  const AEntity: TTEntity;
  const AColumn: TTLazyListColumn);
begin
  inherited Create(nil);
  FEntities := AEntities;
  FEntity := AEntity;
  FColumn := AColumn;
  FValidator := TTValidator.Create;
end;

destructor TTDesignEntityListTypeColumnForm.Destroy;
begin
  FValidator.Free;
  inherited Destroy;
end;

procedure TTDesignEntityListTypeColumnForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ShowEntities;
  ColumnToControls;
end;

procedure TTDesignEntityListTypeColumnForm.ShowEntities;
var
	LComparison: TComparison<TTEntity>;
  LEntity: TTEntity;
begin
	LComparison := function (const ALeft, ARight: TTEntity): Integer
  begin
    result := String.Compare(ALeft.Name, ARight.Name, True);
  end;
  FEntities.Entities.Sort(TComparer<TTEntity>.Construct(LComparison));

  for LEntity in FEntities.Entities do
  begin
    EntityTypeCombobox.Items.Add(LEntity.Name);
    EntityTypeListbox.Items.Add(Format('{%s}[]', [LEntity.ID]));
  end;
end;

function TTDesignEntityListTypeColumnForm.IsForeignKeyColumn(
  const AColumn: TTAbstractColumn): Boolean;
begin
  result := (AColumn is TTColumn) and
    (TTColumn(AColumn).DataType = TTDataType.dtInteger);
end;

procedure TTDesignEntityListTypeColumnForm.ShowColumns;
var
  LColumn: TTAbstractColumn;
begin
  ColumnNameCombobox.Items.BeginUpdate;
  try
    ColumnNameCombobox.Items.Clear;
    if EntityTypeCombobox.ItemIndex > -1 then
      for LColumn in FEntities.Entities[
        EntityTypeCombobox.ItemIndex].Columns.Columns do
        if IsForeignKeyColumn(LColumn) then
          ColumnNameCombobox.Items.AddObject(LColumn.Name, LColumn);
  finally
    ColumnNameCombobox.Items.EndUpdate;
  end;
end;

function TTDesignEntityListTypeColumnForm.SelectedColumnName: String;
begin
  result := TTAbstractColumn(
    ColumnNameCombobox.Items.Objects[ColumnNameCombobox.ItemIndex]).ColumnName;
end;

function TTDesignEntityListTypeColumnForm.IndexOfColumnName(
  const AColumnName: String): Integer;
var
  LIndex: Integer;
  LColumn: TTAbstractColumn;
begin
  result := -1;
  for LIndex := 0 to ColumnNameCombobox.Items.Count - 1 do
  begin
    LColumn := TTAbstractColumn(ColumnNameCombobox.Items.Objects[LIndex]);
    if String.Compare(LColumn.ColumnName, AColumnName, True) = 0 then
      result := LIndex;
  end;
end;

procedure TTDesignEntityListTypeColumnForm.EntityTypeComboboxChange(
  Sender: TObject);
begin
  ShowColumns;
end;

procedure TTDesignEntityListTypeColumnForm.ColumnToControls;
begin
  NameTextbox.Text := FColumn.Name;
  EntityTypeCombobox.ItemIndex :=
    EntityTypeListbox.Items.IndexOf(FColumn.DataType);
  ShowColumns;
  ColumnNameCombobox.ItemIndex := IndexOfColumnName(FColumn.ColumnName);
end;

procedure TTDesignEntityListTypeColumnForm.CheckColumn;
begin
  FValidator.Check(String(NameTextbox.Text).IsEmpty, SColumnNameEmpty);
  FValidator.Check(EntityTypeCombobox.ItemIndex < 0, SInvalidEntityType);
  FValidator.Check(ColumnNameCombobox.ItemIndex < 0, SInvalidColumnName);
end;

procedure TTDesignEntityListTypeColumnForm.CheckNames;
var
  LColumn: TTAbstractColumn;
begin
  // TODO
  for LColumn in FEntity.Columns.Columns do
      if LColumn <> FColumn then
      begin
        FValidator.Check(
          String.Compare(LColumn.Name, NameTextbox.Text, True) = 0,
          SDuplicateColumnName);

        if ColumnNameCombobox.ItemIndex >= 0 then
          FValidator.Check(
            String.Compare(LColumn.ColumnName, SelectedColumnName, True) = 0,
            Format(SDuplicateColumnColumnName, [LColumn.ColumnName]));
      end;
end;

procedure TTDesignEntityListTypeColumnForm.ControlsToColumn;
begin
  FColumn.Name := NameTextbox.Text;
  FColumn.DataType := EntityTypeListbox.Items[EntityTypeCombobox.ItemIndex];
  FColumn.ColumnName := SelectedColumnName;
  FColumn.Required := False;
end;

procedure TTDesignEntityListTypeColumnForm.SaveButtonClick(Sender: TObject);
begin
  FValidator.Clear;
  CheckColumn;
  CheckNames;
  if not FValidator.IsValid then
    MessageDlg(FValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
  else
  begin
    ControlsToColumn;
    ModalResult := mrOk;
  end;
end;

function TTDesignEntityListTypeColumnForm.HelpPage: String;
begin
  result := 'design/#entity-list-column';
end;

class function TTDesignEntityListTypeColumnForm.ShowDialog(
  const AEntities: TTEntities;
  const AEntity: TTEntity;
  const AColumn: TTLazyListColumn): Boolean;
var
  LDialog: TTDesignEntityListTypeColumnForm;
begin
  LDialog := TTDesignEntityListTypeColumnForm.Create(
    AEntities, AEntity, AColumn);
  try
    result := LDialog.ShowModal = mrOk;
  finally
    LDialog.Free;
  end;end;

end.
