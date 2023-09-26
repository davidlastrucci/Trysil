(*

  Trysil
  Copyright © David Lastrucci
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
  Vcl.NumberBox,

  Trysil.Expert.Consts,
  Trysil.Expert.Validator,
  Trysil.Expert.Model,
  Trysil.Expert.UI.Themes,
  Trysil.Expert.UI.Images;

type

{ TTDesignDataTypeColumnForm }

  TTDesignDataTypeColumnForm = class(TForm)
    TrysilImage: TImage;
    NameLabel: TLabel;
    NameTextbox: TEdit;
    ColumnNameLabel: TLabel;
    ColumnNameTextbox: TEdit;
    DataTypeLabel: TLabel;
    DataTypeComboBox: TComboBox;
    DataSizeLabel: TLabel;
    DataSizeTextbox: TNumberBox;
    RequiredCheckbox: TCheckBox;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure SaveButtonClick(Sender: TObject);
    procedure DataTypeComboBoxChange(Sender: TObject);
  strict private
    FEntity: TTEntity;
    FColumn: TTColumn;
    FValidator: TTValidator;

    procedure SetSizeEnabled;
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
end;

destructor TTDesignDataTypeColumnForm.Destroy;
begin
  FValidator.Free;
  inherited Destroy;
end;

procedure TTDesignDataTypeColumnForm.AfterConstruction;
begin
  inherited AfterConstruction;
  TTThemingServices.Instance.ApplyTheme(Self);
  TrysilImage.Picture.Assign(TTImagesDataModule.Instance.Logo);
  ColumnToControls;
end;

procedure TTDesignDataTypeColumnForm.SetSizeEnabled;
begin
  DataSizeTextbox.Enabled := (DataTypeComboBox.ItemIndex = 0);
  if not DataSizeTextbox.Enabled then
    DataSizeTextbox.ValueInt := 0;
end;

procedure TTDesignDataTypeColumnForm.DataTypeComboBoxChange(Sender: TObject);
begin
  SetSizeEnabled;
end;

procedure TTDesignDataTypeColumnForm.ColumnToControls;
begin
  NameTextbox.Text := FColumn.Name;
  ColumnNameTextbox.Text := FColumn.ColumnName;
  DataTypeComboBox.ItemIndex := (Ord(FColumn.DataType) - 1);
  SetSizeEnabled;
  DataSizeTextbox.ValueInt := FColumn.Size;
end;

procedure TTDesignDataTypeColumnForm.CheckColumn;
begin
  FValidator.Check(String(NameTextbox.Text).IsEmpty, SColumnNameEmpty);
  FValidator.Check(
    String(ColumnNameTextbox.Text).IsEmpty, SColumnColumnNameEmpty);
  FValidator.Check(DataTypeComboBox.ItemIndex < 0, SInvalidDataType);
  FValidator.Check(
    (DataTypeComboBox.ItemIndex = 0) and (DataSizeTextbox.ValueInt <= 0),
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
  FColumn.Size := DataSizeTextbox.ValueInt;
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
