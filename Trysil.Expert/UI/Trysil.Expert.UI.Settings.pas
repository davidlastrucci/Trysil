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
  Vcl.ComCtrls,
  Vcl.Imaging.PngImage,

  Trysil.Expert.Config,
  Trysil.Expert.UI.Themed;

type

{ TTSettingsForm }

  TTSettingsForm = class(TTThemedForm)
    SettingsTreeView: TTreeView;
    TrysilPanel: TPanel;
    TrysilDirectoryLabel: TLabel;
    TrysilDirectoryTextbox: TEdit;
    ModelsPanel: TPanel;
    ModelDirectoryLabel: TLabel;
    ModelDirectoryTextbox: TEdit;
    UnitFilenamesLabel: TLabel;
    UnitFilenamesTextbox: TEdit;
    RulesPanel: TPanel;
    RulesDirectoryLabel: TLabel;
    RulesDirectoryTextbox: TEdit;
    RuleFilenamesLabel: TLabel;
    RuleFilenamesTextbox: TEdit;
    ControllersPanel: TPanel;
    ControllersDirectoryLabel: TLabel;
    ControllersDirectoryTextbox: TEdit;
    ControllerFilenamesLabel: TLabel;
    ControllerFilenamesTextbox: TEdit;
    SaveButton: TButton;
    CancelButton: TButton;
    procedure SettingsTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure SaveButtonClick(Sender: TObject);
  strict private
    procedure AddNode(const ACaption: String; const APanel: TPanel);
    procedure CreateNodes;
    procedure ShowPanel(const APanel: TPanel);
    procedure ConfigToControls;
    procedure ControlsToConfig;
  strict protected
    function HelpPage: String; override;
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
  CreateNodes;
  ConfigToControls;
end;

procedure TTSettingsForm.AddNode(
  const ACaption: String; const APanel: TPanel);
begin
  SettingsTreeView.Items.AddObject(nil, ACaption, APanel);
end;

procedure TTSettingsForm.CreateNodes;
begin
  SettingsTreeView.Items.BeginUpdate;
  try
    AddNode('Trysil', TrysilPanel);
    AddNode('Models', ModelsPanel);
    AddNode('Rules', RulesPanel);
    AddNode('Controllers', ControllersPanel);
  finally
    SettingsTreeView.Items.EndUpdate;
  end;
  SettingsTreeView.Selected := SettingsTreeView.Items[0];
  ShowPanel(TrysilPanel);
end;

procedure TTSettingsForm.ShowPanel(const APanel: TPanel);
var
  LNode: TTreeNode;
begin
  for LNode in SettingsTreeView.Items do
    TPanel(LNode.Data).Visible := LNode.Data = APanel;
end;

procedure TTSettingsForm.SettingsTreeViewChange(
  Sender: TObject; Node: TTreeNode);
begin
  if Assigned(Node) then
    ShowPanel(TPanel(Node.Data));
end;

procedure TTSettingsForm.ConfigToControls;
begin
  TrysilDirectoryTextbox.Text := TTConfig.Instance.TrysilDirectory;
  ModelDirectoryTextbox.Text := TTConfig.Instance.ModelDirectory;
  UnitFilenamesTextbox.Text := TTConfig.Instance.UnitFilenames;
  RulesDirectoryTextbox.Text := TTConfig.Instance.RulesDirectory;
  RuleFilenamesTextbox.Text := TTConfig.Instance.RuleFilenames;
  ControllersDirectoryTextbox.Text := TTConfig.Instance.ControllersDirectory;
  ControllerFilenamesTextbox.Text := TTConfig.Instance.ControllerFilenames;
end;

procedure TTSettingsForm.ControlsToConfig;
begin
  TTConfig.Instance.TrysilDirectory := TrysilDirectoryTextbox.Text;
  TTConfig.Instance.ModelDirectory := ModelDirectoryTextbox.Text;
  TTConfig.Instance.UnitFilenames := UnitFilenamesTextbox.Text;
  TTConfig.Instance.RulesDirectory := RulesDirectoryTextbox.Text;
  TTConfig.Instance.RuleFilenames := RuleFilenamesTextbox.Text;
  TTConfig.Instance.ControllersDirectory := ControllersDirectoryTextbox.Text;
  TTConfig.Instance.ControllerFilenames := ControllerFilenamesTextbox.Text;
end;

procedure TTSettingsForm.SaveButtonClick(Sender: TObject);
begin
  ControlsToConfig;
  TTConfig.Instance.Save;
  ModalResult := mrOk;
end;

function TTSettingsForm.HelpPage: String;
begin
  result := 'settings/';
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
