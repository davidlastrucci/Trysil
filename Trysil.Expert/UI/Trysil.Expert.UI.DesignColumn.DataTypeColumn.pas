(*

  Trysil
  Copyright � David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.DesignColumn.DataTypeColumn;

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

  Trysil.Expert.Consts,
  Trysil.Expert.Validator,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Prompter, Vcl.Imaging.pngimage;

type

{ TTDesignDataTypeColumnForm }

  TTDesignDataTypeColumnForm = class(TTThemedForm)
    NameLabel: TLabel;
    NameTextbox: TEdit;
    ColumnNameLabel: TLabel;
    ColumnNameTextbox: TEdit;
    DataTypeLabel: TLabel;
    DataTypeComboBox: TComboBox;
    DataSizeLabel: TLabel;
    DataSizeTextbox: TEdit;
    RequiredCheckbox: TCheckBox;
    AllowEmptyCheckbox: TCheckBox;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure NameTextboxChange(Sender: TObject);
    procedure DataTypeComboBoxChange(Sender: TObject);
    procedure RequiredCheckboxClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FEntity: TTEntity;
    FColumn: TTColumn;
    FValidator: TTValidator;
    FNamePrompter: TTPrompter;

    procedure SetSizeEnabled;
    procedure SetAllowEmptyEnabled;
    procedure ColumnToControls;
    procedure CheckColumn;
    procedure CheckNames;
    procedure ControlsToColumn;
  public
    constructor Create(
      const AEntity: TTEntity; const AColumn: TTColumn); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AEntity: TTEntity; const AColumn: TTColumn): Boolean;
  end;

implementation

{$R *.dfm}

{ TTDesignDataTypeColumnForm }

constructor TTDesignDataTypeColumnForm.Create(
  const AEntity: TTEntity; const AColumn: TTColumn);
begin
  inherited Create(nil);
  FEntity := AEntity;
  FColumn := AColumn;

  FValidator := TTValidator.Create;
  FNamePrompter := TTPrompter.Create(NameTextbox, ColumnNameTextbox);
end;

destructor TTDesignDataTypeColumnForm.Destroy;
begin
  FNamePrompter.Free;
  FValidator.Free;
  inherited Destroy;
end;

procedure TTDesignDataTypeColumnForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ColumnToControls;
end;

procedure TTDesignDataTypeColumnForm.NameTextboxChange(Sender: TObject);
begin
  FNamePrompter.DoChanged;
end;

procedure TTDesignDataTypeColumnForm.SetSizeEnabled;
begin
  DataSizeTextbox.Enabled := (DataTypeComboBox.ItemIndex = 0);
  if not DataSizeTextbox.Enabled then
    DataSizeTextbox.Text := '0';
end;

procedure TTDesignDataTypeColumnForm.SetAllowEmptyEnabled;
begin
  AllowEmptyCheckbox.Enabled :=
    (DataTypeComboBox.ItemIndex = 0) and (not RequiredCheckbox.Checked);
  if not AllowEmptyCheckbox.Enabled then
    AllowEmptyCheckbox.Checked := False;
end;

procedure TTDesignDataTypeColumnForm.DataTypeComboBoxChange(Sender: TObject);
begin
  SetSizeEnabled;
  SetAllowEmptyEnabled;
end;

procedure TTDesignDataTypeColumnForm.RequiredCheckboxClick(Sender: TObject);
begin
  SetAllowEmptyEnabled;
end;

procedure TTDesignDataTypeColumnForm.ColumnToControls;
begin
  NameTextbox.Text := FColumn.Name;
  ColumnNameTextbox.Text := FColumn.ColumnName;
  DataTypeComboBox.ItemIndex := (Ord(FColumn.DataType) - 1);
  if DataTypeComboBox.ItemIndex < 0 then
    DataTypeComboBox.ItemIndex := 0;
  SetSizeEnabled;
  DataSizeTextbox.Text := FColumn.Size.ToString();
  RequiredCheckbox.Checked := FColumn.Required;
  AllowEmptyCheckbox.Checked := FColumn.AllowEmpty;
  SetAllowEmptyEnabled;

  FNamePrompter.Start;
end;

procedure TTDesignDataTypeColumnForm.CheckColumn;
begin
  FValidator.Check(String(NameTextbox.Text).IsEmpty, SColumnNameEmpty);
  FValidator.Check(
    String(ColumnNameTextbox.Text).IsEmpty, SColumnColumnNameEmpty);
  FValidator.Check(DataTypeComboBox.ItemIndex < 0, SInvalidDataType);
  FValidator.Check(
    (DataTypeComboBox.ItemIndex = 0) and
      (Integer.Parse(DataSizeTextbox.Text) <= 0),
    SStringSizeError);
end;

procedure TTDesignDataTypeColumnForm.CheckNames;
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

procedure TTDesignDataTypeColumnForm.ControlsToColumn;
begin
  FColumn.Name := NameTextbox.Text;
  FColumn.ColumnName := ColumnNameTextbox.Text;
  FColumn.DataType := TTDataType(DataTypeComboBox.ItemIndex + 1);
  FColumn.Size := Integer.Parse(DataSizeTextbox.Text);
  FColumn.Required := RequiredCheckbox.Checked;
  FColumn.AllowEmpty := AllowEmptyCheckbox.Enabled and AllowEmptyCheckbox.Checked;
end;

procedure TTDesignDataTypeColumnForm.SaveButtonClick(Sender: TObject);
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

class function TTDesignDataTypeColumnForm.ShowDialog(
  const AEntity: TTEntity; const AColumn: TTColumn): Boolean;
var
  LDialog: TTDesignDataTypeColumnForm;
begin
  LDialog := TTDesignDataTypeColumnForm.Create(AEntity, AColumn);
  try
    result := LDialog.ShowModal = mrOk;
  finally
    LDialog.Free;
  end;
end;

end.
