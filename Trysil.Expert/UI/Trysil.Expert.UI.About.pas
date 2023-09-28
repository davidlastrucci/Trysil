(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Expert.UI.About;

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
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  Trysil.Expert.UI.Themed;

type

{ TTAboutForm }

  TTAboutForm = class(TTThemedForm)
    TitleLabel: TLabel;
    DescriptionLabel: TLabel;
    CopyrightLabel: TLabel;
    Bevel01: TBevel;
    Trysil00Label: TLabel;
    Trysil01Label: TLabel;
    Trysil02Label: TLabel;
    Trysil03Label: TLabel;
    Trysil04Label: TLabel;
    Bevel02: TBevel;
    SupportedDatabaseLabel: TLabel;
    FirebirdLabel: TLabel;
    MSSQLLabel: TLabel;
    PostgreSQLLabel: TLabel;
    SQLiteLabel: TLabel;
    Bevel03: TBevel;
    WebLabelLabel: TLabel;
    WebLabel: TLabel;
    EmailLabelLabel: TLabel;
    EmailLabel: TLabel;
    GitHubLabelLabel: TLabel;
    GitHubLabel: TLabel;
    CloseButton: TButton;
    procedure HyperLinkOn(Sender: TObject);
    procedure HyperLinkOff(Sender: TObject);
    procedure WebLabelClick(Sender: TObject);
    procedure EmailLabelClick(Sender: TObject);
    procedure GitHubLabelClick(Sender: TObject);
    procedure Trysil04LabelClick(Sender: TObject);
  strict private
  public
    class procedure ShowDialog;
  end;

implementation

{$R *.dfm}

procedure TTAboutForm.HyperLinkOn(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := [TFontStyle.fsUnderline];
end;

procedure TTAboutForm.HyperLinkOff(Sender: TObject);
begin
  if Sender is TLabel then
    TLabel(Sender).Font.Style := [];
end;

procedure TTAboutForm.Trysil04LabelClick(Sender: TObject);
begin
  ShellExecute(
    Application.Handle,
    nil,
    'https://codenames.info/operation/orm',
    nil,
    nil,
    SW_SHOW);
end;

procedure TTAboutForm.WebLabelClick(Sender: TObject);
begin
  ShellExecute(
    Application.Handle,
    nil,
    'https://www.lastrucci.net',
    nil,
    nil,
    SW_SHOW);
end;

procedure TTAboutForm.EmailLabelClick(Sender: TObject);
begin
  ShellExecute(
    Application.Handle,
    nil,
    'mailto:david.lastrucci@gmail.com',
    nil,
    nil,
    SW_SHOW);
end;

procedure TTAboutForm.GitHubLabelClick(Sender: TObject);
begin
  ShellExecute(
    Application.Handle,
    nil,
    'https://github.com/davidlastrucci/Trysil',
    nil,
    nil,
    SW_SHOW);
end;

class procedure TTAboutForm.ShowDialog;
var
  LDialog: TTAboutForm;
begin
  LDialog := TTAboutForm.Create(nil);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

end.
