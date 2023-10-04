(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.DesignEntity;

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
  Trysil.Expert.UI.Prompter;

type

{ TTDesignEntityForm }

  TTDesignEntityForm = class(TTThemedForm)
    NameLabel: TLabel;
    NameTextbox: TEdit;
    TableNameLabel: TLabel;
    TableNameTextbox: TEdit;
    SequenceNameLabel: TLabel;
    SequenceNameTextbox: TEdit;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure NameTextboxChange(Sender: TObject);
    procedure TableNameTextboxChange(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    FEntities: TTEntities;
    FEntity: TTEntity;
    FValidator: TTValidator;
    FNamePrompter: TTPrompter;
    FTableNamePrompter: TTPrompter;

    procedure EntityToControls;
    procedure CheckEntity;
    procedure CheckNames;
    procedure ControlsToEntity;
  public
    constructor Create(
      const AEntities: TTEntities; const AEntity: TTEntity); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function ShowDialog(
      const AEntities: TTEntities; const AEntity: TTEntity): Boolean;
  end;

implementation

{$R *.dfm}

{ TTDesignEntityForm }

constructor TTDesignEntityForm.Create(
  const AEntities: TTEntities; const AEntity: TTEntity);
begin
  inherited Create(nil);
  FEntities := AEntities;
  FEntity := AEntity;

  FValidator := TTValidator.Create;
  FNamePrompter := TTPrompter.Create(NameTextbox, TableNameTextbox);
  FTableNamePrompter := TTPrompter.Create(
    TableNameTextbox, SequenceNameTextbox, '%sID');
end;

destructor TTDesignEntityForm.Destroy;
begin
  FTableNamePrompter.Free;
  FNamePrompter.Free;
  FValidator.Free;
  inherited Destroy;
end;

procedure TTDesignEntityForm.AfterConstruction;
begin
  inherited AfterConstruction;
  EntityToControls;
end;

procedure TTDesignEntityForm.NameTextboxChange(Sender: TObject);
begin
  FNamePrompter.DoChanged;
end;

procedure TTDesignEntityForm.TableNameTextboxChange(Sender: TObject);
begin
  FTableNamePrompter.DoChanged;
end;

procedure TTDesignEntityForm.EntityToControls;
begin
  NameTextbox.Text := FEntity.Name;
  TableNameTextbox.Text := FEntity.TableName;
  SequenceNameTextbox.Text := FEntity.SequenceName;

  FNamePrompter.Start;
  FTableNamePrompter.Start;
end;

procedure TTDesignEntityForm.CheckEntity;
begin
  FValidator.Check(String(NameTextbox.Text).IsEmpty, SEntityNameEmpty);
  FValidator.Check(String(TableNameTextbox.Text).IsEmpty, STableNameEmpty);
  FValidator.Check(
    String(SequenceNameTextbox.Text).IsEmpty, SSequenceNameEmpty);
end;

procedure TTDesignEntityForm.CheckNames;
var
  LEntity: TTEntity;
begin
  FValidator.Check(
    String.Compare(TableNameTextbox.Text, SequenceNameTextbox.Text, True) = 0,
    STableSameSequenceName);

  for LEntity in FEntities.Entities do
    if LEntity <> FEntity then
    begin
      FValidator.Check(
        String.Compare(NameTextbox.Text, LEntity.Name, True) = 0,
        SDuplicateEntityName);
      FValidator.Check(String.Compare(
        TableNameTextbox.Text, LEntity.TableName, True) = 0,
        Format(SDuplicateTableName, [LEntity.Name]));
      FValidator.Check(
        String.Compare(
          SequenceNameTextbox.Text, LEntity.SequenceName, True) = 0,
        Format(SDuplicateSequenceName, [LEntity.Name]));

      FValidator.Check(
        String.Compare(TableNameTextbox.Text, LEntity.SequenceName, True) = 0,
        Format(SSequenceSameTable, [LEntity.Name]));
      FValidator.Check(
        String.Compare(SequenceNameTextbox.Text, LEntity.TableName, True) = 0,
        Format(STableSameSequence, [LEntity.Name]));
    end;
end;

procedure TTDesignEntityForm.ControlsToEntity;
begin
  FEntity.Name := NameTextbox.Text;
  FEntity.TableName := TableNameTextbox.Text;
  FEntity.SequenceName := SequenceNameTextbox.Text;
end;

procedure TTDesignEntityForm.SaveButtonClick(Sender: TObject);
begin
  FValidator.Clear;
  CheckEntity;
  CheckNames;
  if not FValidator.IsValid then
    MessageDlg(FValidator.Messages, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0)
  else
  begin
    ControlsToEntity;
    ModalResult := mrOk;
  end;
end;

class function TTDesignEntityForm.ShowDialog(
  const AEntities: TTEntities; const AEntity: TTEntity): Boolean;
var
  LDialog: TTDesignEntityForm;
begin
  LDialog := TTDesignEntityForm.Create(AEntities, AEntity);
  try
    result := LDialog.ShowModal = mrOk;
  finally
    LDialog.Free;
  end;
end;

end.
