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
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,

  Trysil.Expert.UI.Themes,
  Trysil.Expert.UI.Images;

type

{ TTThemedForm }

  TTThemedForm = class(TForm)
    ContentPanel: TPanel;
    ButtonsPanel: TPanel;
    TrysilImage: TImage;
  strict private
    procedure ApplyThemes;
  public
    procedure AfterConstruction; override;
  end;

implementation

{$R *.dfm}

{ TTThemedForm }

procedure TTThemedForm.AfterConstruction;
begin
  inherited AfterConstruction;
  ApplyThemes;
  TrysilImage.Picture.Assign(TTImagesDataModule.Instance.Logo);
end;

procedure TTThemedForm.ApplyThemes;
begin
  TTThemingServices.Instance.ApplyTheme(Self);
  ContentPanel.Color :=
    TTThemingServices.Instance.GetSystemColor(clWindow);
  ButtonsPanel.Color :=
    TTThemingServices.Instance.GetSystemColor(clBtnFace);
end;

end.
