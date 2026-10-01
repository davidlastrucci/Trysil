(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.Themed;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,

  Trysil.Expert.Consts,
  Trysil.Expert.UI.Themes,
  Trysil.Expert.UI.Images, Vcl.Imaging.pngimage;

type

{ TTThemedForm }

  TTThemedForm = class(TForm)
    ContentPanel: TPanel;
    ButtonsPanel: TPanel;
    TrysilImage: TImage;
  strict private
    FHelpButton: TButton;

    procedure ApplyThemes;
    procedure CreateHelpButton;
    procedure HelpButtonClick(Sender: TObject);
    procedure ShowHelp;
  strict protected
    function HelpPage: String; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    procedure AfterConstruction; override;
  end;

implementation

{$R *.dfm}

{ TTThemedForm }

procedure TTThemedForm.AfterConstruction;
begin
  inherited AfterConstruction;
  CreateHelpButton;
  ApplyThemes;
end;

function TTThemedForm.HelpPage: String;
begin
  result := String.Empty;
end;

procedure TTThemedForm.CreateHelpButton;
begin
  if not HelpPage.IsEmpty then
  begin
    KeyPreview := True;
    FHelpButton := TButton.Create(Self);
    FHelpButton.Parent := ButtonsPanel;
    FHelpButton.Left := 0;
    FHelpButton.Width := 75;
    FHelpButton.Align := TAlign.alLeft;
    FHelpButton.Caption := '&Help';
    FHelpButton.OnClick := HelpButtonClick;
  end;
end;

procedure TTThemedForm.HelpButtonClick(Sender: TObject);
begin
  ShowHelp;
end;

procedure TTThemedForm.ShowHelp;
begin
  ShellExecute(
    Handle,
    'open',
    PChar(Format('%s%s', [SHelpUrl, HelpPage])),
    nil,
    nil,
    SW_SHOWNORMAL);
end;

procedure TTThemedForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F1) and (Shift = []) and Assigned(FHelpButton) then
  begin
    Key := 0;
    ShowHelp;
  end
  else
    inherited KeyDown(Key, Shift);
end;

procedure TTThemedForm.ApplyThemes;
begin
  TTThemingServices.Instance.ApplyTheme(Self);
  ContentPanel.Color :=
    TTThemingServices.Instance.GetSystemColor(clBtnFace);
  ButtonsPanel.Color :=
    TTThemingServices.Instance.GetSystemColor(clWindow);
end;

end.
