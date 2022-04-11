(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.MainForm;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnPopup,
  Vcl.ImgList,
  FireDAC.ConsoleUI.Wait,
  FireDAC.VCLUI.Wait,

  API.Http;

type

{ TAPIMainForm }

  TAPIMainForm = class(TForm)
    ImageList: TImageList;
    PopupMenu: TPopupActionBar;
    StartMenuItem: TMenuItem;
    StopMenuItem: TMenuItem;
    SeparatorMenuItem: TMenuItem;
    TerminateMenuItem: TMenuItem;
    TrayIcon: TTrayIcon;
    procedure PopupMenuPopup(Sender: TObject);
    procedure StartMenuItemClick(Sender: TObject);
    procedure StopMenuItemClick(Sender: TObject);
    procedure TerminateMenuItemClick(Sender: TObject);
  strict private
    FHttp: TAPIHttp;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;
  end;

var
  APIMainForm: TAPIMainForm;

implementation

{$R *.dfm}

{ TAPIMainForm }

constructor TAPIMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHttp := TAPIHttp.Create;
end;

destructor TAPIMainForm.Destroy;
begin
  FHttp.Free;
  inherited Destroy;
end;

procedure TAPIMainForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FHttp.Start;
end;

procedure TAPIMainForm.PopupMenuPopup(Sender: TObject);
begin
  StopMenuItem.Enabled := FHttp.Started;
  StartMenuItem.Enabled := not StopMenuItem.Enabled;
end;

procedure TAPIMainForm.StartMenuItemClick(Sender: TObject);
begin
  FHttp.Start;
end;

procedure TAPIMainForm.StopMenuItemClick(Sender: TObject);
begin
  FHttp.Stop;
end;

procedure TAPIMainForm.TerminateMenuItemClick(Sender: TObject);
begin
  Close;
end;

end.
