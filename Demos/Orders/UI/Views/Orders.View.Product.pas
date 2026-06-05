(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.View.Product;

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
  Orders.Model.Product,
  Orders.Dialog.Product,
  Orders.View.Base;

type

{ TProductListItem }

  TProductListItem = class(TListItem)
  strict private
    FProduct: TProduct;

    procedure SetProduct(const AValue: TProduct);
  public
    property Product: TProduct read FProduct write SetProduct;
  end;

{ TProductView }

  TProductView = class(TViewBase)
  strict private
    FList: TTList<TProduct>;

    function GetSelectedProduct: TProduct;
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

{ TProductListItem }

procedure TProductListItem.SetProduct(const AValue: TProduct);
begin
  FProduct := AValue;
  if Assigned(FProduct) then
  begin
    Caption := FProduct.ID.ToString;
    SubItems.Clear;
    SubItems.Add(FProduct.Description);
    SubItems.Add(FormatFloat('#,##0.00', FProduct.Price));
  end;
end;

{ TProductView }

constructor TProductView.Create(
  const AContext: TTContext; const AParent: TWinControl);
begin
  inherited Create(AContext, AParent);
  FList := Context.CreateEntityList<TProduct>();
end;

destructor TProductView.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TProductView.GetListItemClass: TListItemClass;
begin
  result := TProductListItem;
end;

function TProductView.GetSelectedProduct: TProduct;
begin
  if Assigned(ListView.Selected) then
    result := TProductListItem(ListView.Selected).Product
  else
    result := nil;
end;

procedure TProductView.LoadList;
var
  LProduct: TProduct;
  LItem: TListItem;
  LProductListItem: TProductListItem absolute LItem;
begin
  Context.SelectAll<TProduct>(FList);

  ListView.Items.BeginUpdate;
  try
    ListView.Items.Clear;
    for LProduct in FList do
    begin
      LItem := ListView.Items.Add;
      LProductListItem.Product := LProduct;
    end;
  finally
    ListView.Items.EndUpdate;
  end;
end;

procedure TProductView.NewItem;
var
  LProduct: TProduct;
begin
  LProduct := Context.CreateEntity<TProduct>();
  try
    if TProductDialog.Insert(Context, LProduct) then
      LoadList;
  finally
    Context.FreeEntity<TProduct>(LProduct);
  end;
end;

procedure TProductView.EditItem;
var
  LProduct: TProduct;
begin
  LProduct := GetSelectedProduct;
  if Assigned(LProduct) then
  begin
    Context.Refresh<TProduct>(LProduct);
    if TProductDialog.Edit(Context, LProduct) then
      LoadList;
  end;
end;

procedure TProductView.DeleteItem;
var
  LProduct: TProduct;
  LMsg: String;
begin
  LProduct := GetSelectedProduct;
  if Assigned(LProduct) then
  begin
    LMsg := Format('Delete product "%s"?', [LProduct.Description]);
    if MessageDlg(LMsg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      Context.Delete<TProduct>(LProduct);
      LoadList;
    end;
  end;
end;

initialization
  TFrameContainer.Instance.RegisterFrame<TProductView>('Products');

end.
