(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.View.Brand;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
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
  Trysil.Context,
  Trysil.Generics.Collections,

  Orders.FrameManager,
  Orders.Model.Brand,
  Orders.Dialog.Brand,
  Orders.View.Base, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type

{ TBrandListItem }

  TBrandListItem = class(TListItem)
  strict private
    FBrand: TBrand;

    procedure SetBrand(const AValue: TBrand);
  public
    property Brand: TBrand read FBrand write SetBrand;
  end;

{ TBrandView }

  TBrandView = class(TViewBase)
  strict private
    FList: TTList<TBrand>;

    function GetSelectedBrand: TBrand;
  strict protected
    function GetListItemClass: TListItemClass; override;

    procedure LoadList; override;
    procedure NewItem; override;
    procedure EditItem; override;
    procedure DeleteItem; override;
  public
    constructor Create(
      const AContext: TTContext; const AParent: TWinControl); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TBrandListItem }

procedure TBrandListItem.SetBrand(const AValue: TBrand);
begin
  FBrand := AValue;
  if Assigned(FBrand) then
  begin
    Caption := FBrand.ID.ToString;
    SubItems.Clear;
    SubItems.Add(FBrand.Description);
  end;
end;

{ TBrandView }

constructor TBrandView.Create(
  const AContext: TTContext; const AParent: TWinControl);
begin
  inherited Create(AContext, AParent);
  FList := Context.CreateEntityList<TBrand>();
end;

destructor TBrandView.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TBrandView.GetListItemClass: TListItemClass;
begin
  result := TBrandListItem;
end;

function TBrandView.GetSelectedBrand: TBrand;
begin
  if Assigned(ListView.Selected) then
    result := TBrandListItem(ListView.Selected).Brand
  else
    result := nil;
end;

procedure TBrandView.LoadList;
var
  LBrand: TBrand;
  LItem: TListItem;
  LBrandListItem: TBrandListItem absolute LItem;
begin
  Context.SelectAll<TBrand>(FList);

  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for LBrand in FList do
    begin
      LItem := ListView.Items.Add;
      LBrandListItem.Brand := LBrand;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TBrandView.NewItem;
var
  LBrand: TBrand;
begin
  LBrand := Context.CreateEntity<TBrand>();
  try
    if TBrandDialog.Insert(Context, LBrand) then
      LoadList;
  finally
    Context.FreeEntity<TBrand>(LBrand);
  end;
end;

procedure TBrandView.EditItem;
var
  LBrand: TBrand;
begin
  LBrand := GetSelectedBrand;
  if Assigned(LBrand) then
  begin
    Context.Refresh<TBrand>(LBrand);
    if TBrandDialog.Edit(Context, LBrand) then
      LoadList;
  end;
end;

procedure TBrandView.DeleteItem;
var
  LBrand: TBrand;
  LMsg: String;
begin
  LBrand := GetSelectedBrand;
  if Assigned(LBrand) then
  begin
    LMsg := Format('Delete brand "%s"?', [LBrand.Description]);
    if MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Context.Delete<TBrand>(LBrand);
      LoadList;
    end;
  end;
end;

initialization
  TFrameContainer.Instance.RegisterFrame<TBrandView>('Brands');

end.
