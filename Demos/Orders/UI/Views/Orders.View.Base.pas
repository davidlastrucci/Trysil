(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.View.Base;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Actions,
  System.ImageList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ActnList,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ImgList,
  Vcl.ImageCollection,
  Vcl.VirtualImageList,

  Orders.ManagedFrame,
  Orders.FrameManager;

type

{ TViewBase }

  TViewBase = class(TManagedFrame)
    TopPanel: TPanel;
    TitleLabel: TLabel;
    NewButton: TSpeedButton;
    EditButton: TSpeedButton;
    DeleteButton: TSpeedButton;
    RefreshButton: TSpeedButton;
    ListView: TListView;
    ActionList: TActionList;
    NewAction: TAction;
    EditAction: TAction;
    DeleteAction: TAction;
    RefreshAction: TAction;
    IconCollection: TImageCollection;
    ImageList: TVirtualImageList;
    ListViewImageList: TImageList;
    procedure ListViewCreateItemClass(
      Sender: TCustomListView; var ItemClass: TListItemClass);
    procedure NewActionExecute(Sender: TObject);
    procedure EditActionExecute(Sender: TObject);
    procedure DeleteActionExecute(Sender: TObject);
    procedure RefreshActionExecute(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
  strict protected
    function GetListItemClass: TListItemClass; virtual; abstract;

    procedure LoadList; virtual; abstract;
    procedure NewItem; virtual; abstract;
    procedure EditItem; virtual; abstract;
    procedure DeleteItem; virtual; abstract;
  public
    procedure AfterConstruction; override;
  end;

implementation

{$R *.dfm}

{ TViewBase }

procedure TViewBase.AfterConstruction;
begin
  inherited AfterConstruction;
  if not (csDesigning in ComponentState) then
  begin
    ListView.OnCreateItemClass := ListViewCreateItemClass;
    LoadList;
  end;
end;

procedure TViewBase.ListViewCreateItemClass(
  Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := GetListItemClass();
end;

procedure TViewBase.NewActionExecute(Sender: TObject);
begin
  NewItem;
end;

procedure TViewBase.EditActionExecute(Sender: TObject);
begin
  EditItem;
end;

procedure TViewBase.DeleteActionExecute(Sender: TObject);
begin
  DeleteItem;
end;

procedure TViewBase.RefreshActionExecute(Sender: TObject);
begin
  LoadList;
end;

procedure TViewBase.ListViewDblClick(Sender: TObject);
begin
  EditItem;
end;

end.
