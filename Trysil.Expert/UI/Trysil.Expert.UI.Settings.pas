(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Settings;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  Trysil.Expert.Config,
  Trysil.Expert.UI.Themed;

type

{ TTSettingsForm }

  TTSettingsForm = class(TTThemedForm)
    TrysilGroupbox: TGroupBox;
    TrysilDirectoryLabel: TLabel;
    TrysilDirectoryTextbox: TEdit;
    EntitiesGroupbox: TGroupBox;
    ModelDirectoryLabel: TLabel;
    ModelDirectoryTextbox: TEdit;
    UnitFilenamesLabel: TLabel;
    UnitFilenamesTextbox: TEdit;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure SaveButtonClick(Sender: TObject);
  strict private
    procedure ConfigToControls;
    procedure ControlsToConfig;
  public
    procedure AfterConstruction; override;

    class procedure ShowDialog;
  end;

implementation

{$R *.dfm}

{ TTSettingsForm }

procedure TTSettingsForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ConfigToControls;
end;

procedure TTSettingsForm.ConfigToControls;
begin
  TrysilDirectoryTextbox.Text := TTConfig.Instance.TrysilDirectory;
  ModelDirectoryTextbox.Text := TTConfig.Instance.ModelDirectory;
  UnitFilenamesTextbox.Text := TTConfig.Instance.UnitFilenames;
end;

procedure TTSettingsForm.ControlsToConfig;
begin
  TTConfig.Instance.TrysilDirectory := TrysilDirectoryTextbox.Text;
  TTConfig.Instance.ModelDirectory := ModelDirectoryTextbox.Text;
  TTConfig.Instance.UnitFilenames := UnitFilenamesTextbox.Text;
end;

procedure TTSettingsForm.SaveButtonClick(Sender: TObject);
begin
  ControlsToConfig;
  TTConfig.Instance.Save;
  ModalResult := mrOk;
end;

class procedure TTSettingsForm.ShowDialog;
var
  LDialog: TTSettingsForm;
begin
  LDialog := TTSettingsForm.Create(nil);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
