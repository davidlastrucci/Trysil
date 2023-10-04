(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.DesignColumn.EntityTypeColumn;

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
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Prompter;

type

{ TTDesignEntityTypeColumnForm }

  TTDesignEntityTypeColumnForm = class(TTThemedForm)
    NameLabel: TLabel;
    NameTextbox: TEdit;
    ColumnNameLabel: TLabel;
    ColumnNameTextbox: TEdit;
    EntityTypeLabel: TLabel;
    EntityTypeCombobox: TComboBox;
    EntityTypeListbox: TListBox;
    RequiredCheckbox: TCheckBox;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure NameTextboxChange(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FEntities: TTEntities;
    FEntity: TTEntity;
    FColumn: TTLazyColumn;
    FValidator: TTValidator;
    FNamePrompter: TTPrompter;

    procedure ShowEntities;
    procedure ColumnToControls;
    procedure CheckColumn;
    procedure CheckNames;
    procedure ControlsToColumn;
  public
    constructor Create(
      const AEntities: TTEntities;
      const AEntity: TTEntity;
      const AColumn: TTLazyColumn); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AEntities: TTEntities;
      const AEntity: TTEntity;
      const AColumn: TTLazyColumn): Boolean;
  end;

implementation

{$R *.dfm}

{ TTDesignEntityTypeColumnForm }

constructor TTDesignEntityTypeColumnForm.Create(
  const AEntities: TTEntities;
  const AEntity: TTEntity;
  const AColumn: TTLazyColumn);
begin
  inherited Create(nil);
  FEntities := AEntities;
  FEntity := AEntity;
  FColumn := AColumn;

  FValidator := TTValidator.Create;
  FNamePrompter := TTPrompter.Create(NameTextbox, ColumnNameTextbox, '%sID');
end;

destructor TTDesignEntityTypeColumnForm.Destroy;
begin
  FNamePrompter.Free;
  FValidator.Free;
  inherited Destroy;
end;

procedure TTDesignEntityTypeColumnForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ShowEntities;
  ColumnToControls;
end;

procedure TTDesignEntityTypeColumnForm.NameTextboxChange(Sender: TObject);
begin
  FNamePrompter.DoChanged;
end;

procedure TTDesignEntityTypeColumnForm.ShowEntities;
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
    EntityTypeListbox.Items.Add(Format('{%s}', [LEntity.ID]));
  end;
end;

procedure TTDesignEntityTypeColumnForm.ColumnToControls;
begin
  NameTextbox.Text := FColumn.Name;
  ColumnNameTextbox.Text := FColumn.ColumnName;
  EntityTypeCombobox.ItemIndex :=
    EntityTypeListbox.Items.IndexOf(FColumn.DataType);
  RequiredCheckbox.Checked := FColumn.Required;

  FNamePrompter.Start;
end;

procedure TTDesignEntityTypeColumnForm.CheckColumn;
begin
  FValidator.Check(String(NameTextbox.Text).IsEmpty, SColumnNameEmpty);
  FValidator.Check(
    String(ColumnNameTextbox.Text).IsEmpty, SColumnColumnNameEmpty);
  FValidator.Check(EntityTypeCombobox.ItemIndex < 0, SInvalidEntityType);
end;

procedure TTDesignEntityTypeColumnForm.CheckNames;
var
  LColumn: TTAbstractColumn;
begin
  for LColumn in FEntity.Columns.Columns do
      if LColumn <> FColumn then
      begin
        FValidator.Check(
          String.Compare(LColumn.Name, NameTextbox.Text, True) = 0,
          SDuplicateColumnName);

        FValidator.Check(
          String.Compare(LColumn.ColumnName, ColumnNameTextbox.Text, True) = 0,
          Format(SDuplicateColumnColumnName, [LColumn.ColumnName]));
      end;
end;

procedure TTDesignEntityTypeColumnForm.ControlsToColumn;
begin
  FColumn.Name := NameTextbox.Text;
  FColumn.ColumnName := ColumnNameTextbox.Text;
  FColumn.DataType := EntityTypeListbox.Items[EntityTypeCombobox.ItemIndex];
  FColumn.Required := RequiredCheckbox.Checked;
end;

procedure TTDesignEntityTypeColumnForm.SaveButtonClick(Sender: TObject);
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

class function TTDesignEntityTypeColumnForm.ShowDialog(
  const AEntities: TTEntities;
  const AEntity: TTEntity;
  const AColumn: TTLazyColumn): Boolean;
var
  LDialog: TTDesignEntityTypeColumnForm;
begin
  LDialog := TTDesignEntityTypeColumnForm.Create(AEntities, AEntity, AColumn);
  try
    result := LDialog.ShowModal = mrOk;
  finally
    LDialog.Free;
  end;
end;

end.
