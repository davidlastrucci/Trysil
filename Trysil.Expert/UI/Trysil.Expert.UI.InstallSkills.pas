(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.InstallSkills;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Imaging.pngimage,

  Trysil.Expert.Classes,
  Trysil.Expert.Project,
  Trysil.Expert.SkillsInstaller,
  Trysil.Expert.UI.Themed,
  Trysil.Expert.UI.Classes,
  Trysil.Expert.UI.Images;

type

{ TTSkillToolListItem }

  TTSkillToolListItem = class(TTListItem<TTSkillTool>)
  strict protected
    procedure SetValue(const AValue: TTSkillTool); override;
  end;

{ TTInstallSkillsForm }

  TTInstallSkillsForm = class(TTThemedForm)
    InfoLabel: TLabel;
    ToolsListView: TListView;
    InstallButton: TButton;
    CancelButton: TButton;
    DownloadFromLabel: TLabel;
    RepositoryLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ToolsListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure InstallButtonClick(Sender: TObject);
    procedure HyperLinkOn(Sender: TObject);
    procedure HyperLinkOff(Sender: TObject);
    procedure WebLabelClick(Sender: TObject);
  strict private
    FProject: TTProject;

    procedure AddTools;
    function SelectedTools: TArray<TTSkillTool>;
    function CheckOverwrite(const AInstaller: TTSkillsInstaller): Boolean;
    procedure DoInstall(const ATools: TArray<TTSkillTool>);
  public
    constructor Create(const AProject: TTProject); reintroduce;

    class procedure ShowDialog(const AProject: TTProject);
  end;

resourcestring
  SSelectOneTool = 'Select at least one coding assistant.';
  SFilesWillBeOverwritten = 'These files will be overwritten:';
  SSkillsInstalled = 'The skills have been installed into the project.';

implementation

{$R *.dfm}

{ TTSkillToolListItem }

procedure TTSkillToolListItem.SetValue(const AValue: TTSkillTool);
begin
  inherited SetValue(AValue);
  Caption := AValue.Caption;
  SubItems.Add(AValue.Target);
  ImageIndex := 2;
  Checked := False;
end;

{ TTInstallSkillsForm }

constructor TTInstallSkillsForm.Create(const AProject: TTProject);
begin
  inherited Create(nil);
  FProject := AProject;
  ToolsListView.SmallImages := TTImagesDataModule.Instance.Images;
end;

procedure TTInstallSkillsForm.FormShow(Sender: TObject);
begin
  AddTools;
end;

procedure TTInstallSkillsForm.HyperLinkOn(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := [TFontStyle.fsUnderline];
end;

procedure TTInstallSkillsForm.HyperLinkOff(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := [];
end;

procedure TTInstallSkillsForm.WebLabelClick(Sender: TObject);
begin
  ShellExecute(
    Application.Handle,
    nil,
    'https://github.com/davidlastrucci/trysil-ai-skills',
    nil,
    nil,
    SW_SHOW);
end;

procedure TTInstallSkillsForm.ToolsListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TTSkillToolListItem;
end;

procedure TTInstallSkillsForm.AddTools;
var
  LTool: TTSkillTool;
  LItem: TListItem;
  LToolItem: TTSkillToolListItem absolute LItem;
begin
  ToolsListView.Items.BeginUpdate;
  try
    for LTool in TTSkillTools.All do
    begin
      LItem := ToolsListView.Items.Add;
      LToolItem.Value := LTool;
    end;
  finally
    ToolsListView.Items.EndUpdate;
  end;
end;

function TTInstallSkillsForm.SelectedTools: TArray<TTSkillTool>;
var
  LResult: TList<TTSkillTool>;
  LItem: TListItem;
  LToolItem: TTSkillToolListItem absolute LItem;
begin
  LResult := TList<TTSkillTool>.Create;
  try
    for LItem in ToolsListView.Items do
      if LItem.Checked then
        LResult.Add(LToolItem.Value);
    result := LResult.ToArray;
  finally
    LResult.Free;
  end;
end;

function TTInstallSkillsForm.CheckOverwrite(
  const AInstaller: TTSkillsInstaller): Boolean;
var
  LExisting: TArray<String>;
  LMessage: String;
  LFileName: String;
begin
  LExisting := AInstaller.ExistingTargetFiles;
  result := Length(LExisting) < 1;
  if not result then
  begin
    LMessage := SFilesWillBeOverwritten;
    for LFileName in LExisting do
      LMessage := Format('%s'#10'%s', [LMessage, LFileName]);
    result := MessageDlg(
      Format('%s'#10#10'Continue?', [LMessage]),
      TMsgDlgType.mtConfirmation,
      [mbYes, mbNo],
      0,
      mbNo) = mrYes;
  end;
end;

procedure TTInstallSkillsForm.DoInstall(const ATools: TArray<TTSkillTool>);
var
  LInstaller: TTSkillsInstaller;
  LTool: TTSkillTool;
begin
  LInstaller := TTSkillsInstaller.Create(FProject.Directory);
  try
    for LTool in ATools do
      LInstaller.AddTool(LTool);

    Screen.Cursor := crHourGlass;
    try
      LInstaller.Prepare;
    finally
      Screen.Cursor := crDefault;
    end;

    if CheckOverwrite(LInstaller) then
    begin
      Screen.Cursor := crHourGlass;
      try
        LInstaller.Install;
      finally
        Screen.Cursor := crDefault;
      end;

      MessageDlg(
        SSkillsInstalled, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
      ModalResult := mrOk;
    end;
  finally
    LInstaller.Free;
  end;
end;

procedure TTInstallSkillsForm.InstallButtonClick(Sender: TObject);
var
  LTools: TArray<TTSkillTool>;
begin
  LTools := SelectedTools;
  if Length(LTools) < 1 then
    raise ETExpertException.Create(SSelectOneTool)
  else
    DoInstall(LTools);
end;

class procedure TTInstallSkillsForm.ShowDialog(const AProject: TTProject);
var
  LDialog: TTInstallSkillsForm;
begin
  LDialog := TTInstallSkillsForm.Create(AProject);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
