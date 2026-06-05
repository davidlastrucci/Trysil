(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.OrderDetail;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Mask,

  Trysil.Context,
  Trysil.Filter,
  Trysil.Session,
  Trysil.Generics.Collections,

  Orders.Model.Product,
  Orders.Model.OrderDetail,
  Orders.Dialog.Base;

type

{ TOrderDetailDialog }

  TOrderDetailDialog = class(TDialogBase)
    ProductLabel: TLabel;
    ProductCombo: TComboBox;
    QuantityEdit: TLabeledEdit;
    PriceEdit: TLabeledEdit;
    procedure ProductComboChange(Sender: TObject);
  strict private
    FOrderDetail: TOrderDetail;
    FSession: TTSession<TOrderDetail>;
    FProducts: TTList<TProduct>;

    procedure FillProductCombo;
    function FindProductIndex(const AProduct: TProduct): Integer;
    procedure FormCloseQuery(Sender: TObject; var ACanClose: Boolean);

    class function ShowDialog(
      const AContext: TTContext;
      const AOrderDetail: TOrderDetail;
      const ASession: TTSession<TOrderDetail>;
      const ACaption: String): Boolean; static;
  strict protected
    procedure LoadFromEntity; override;
    procedure SaveToEntity; override;
    procedure ApplyEntity; override;
  public
    constructor Create(
      const AContext: TTContext;
      const AOrderDetail: TOrderDetail;
      const ASession: TTSession<TOrderDetail>); reintroduce;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function Insert(
      const AContext: TTContext;
      const AOrderDetail: TOrderDetail;
      const ASession: TTSession<TOrderDetail>): Boolean;
    class function Edit(
      const AContext: TTContext;
      const AOrderDetail: TOrderDetail;
      const ASession: TTSession<TOrderDetail>): Boolean;
  end;

implementation

{$R *.dfm}

{ TOrderDetailDialog }

constructor TOrderDetailDialog.Create(
  const AContext: TTContext;
  const AOrderDetail: TOrderDetail;
  const ASession: TTSession<TOrderDetail>);
begin
  inherited Create(AContext);
  FOrderDetail := AOrderDetail;
  FSession := ASession;
  FProducts := Context.CreateEntityList<TProduct>();
end;

destructor TOrderDetailDialog.Destroy;
begin
  FProducts.Free;
  inherited Destroy;
end;

procedure TOrderDetailDialog.AfterConstruction;
begin
  inherited AfterConstruction;
  OnCloseQuery := FormCloseQuery;
  FillProductCombo;
end;

procedure TOrderDetailDialog.FormCloseQuery(
  Sender: TObject; var ACanClose: Boolean);
begin
  if (ModalResult = mrOk) and (ProductCombo.ItemIndex < 0) then
  begin
    MessageDlg('Please select a product.', mtWarning, [mbOK], 0);
    ACanClose := False;
  end;
end;

procedure TOrderDetailDialog.FillProductCombo;
var
  LProduct: TProduct;
begin
  Context.Select<TProduct>(FProducts, TTFilter.Create('', 0, 'Description'));

  ProductCombo.Items.BeginUpdate;
  try
    ProductCombo.Items.Clear;
    for LProduct in FProducts do
      ProductCombo.Items.AddObject(LProduct.Description, LProduct);
  finally
    ProductCombo.Items.EndUpdate;
  end;
end;

function TOrderDetailDialog.FindProductIndex(const AProduct: TProduct): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  if Assigned(AProduct) then
    for LIndex := 0 to ProductCombo.Items.Count - 1 do
      if ProductCombo.Items.Objects[LIndex] = AProduct then
      begin
        result := LIndex;
        Break;
      end;
end;

procedure TOrderDetailDialog.ProductComboChange(Sender: TObject);
var
  LProduct: TProduct;
begin
  if ProductCombo.ItemIndex >= 0 then
  begin
    LProduct := TProduct(ProductCombo.Items.Objects[ProductCombo.ItemIndex]);
    PriceEdit.Text := LProduct.Price.ToString();
  end;
end;

class function TOrderDetailDialog.ShowDialog(
  const AContext: TTContext;
  const AOrderDetail: TOrderDetail;
  const ASession: TTSession<TOrderDetail>;
  const ACaption: String): Boolean;
var
  LDialog: TOrderDetailDialog;
begin
  LDialog := TOrderDetailDialog.Create(AContext, AOrderDetail, ASession);
  try
    LDialog.Caption := ACaption;
    result := LDialog.Execute;
  finally
    LDialog.Free;
  end;
end;

class function TOrderDetailDialog.Insert(
  const AContext: TTContext;
  const AOrderDetail: TOrderDetail;
  const ASession: TTSession<TOrderDetail>): Boolean;
begin
  result := ShowDialog(AContext, AOrderDetail, ASession, 'New detail');
end;

class function TOrderDetailDialog.Edit(
  const AContext: TTContext;
  const AOrderDetail: TOrderDetail;
  const ASession: TTSession<TOrderDetail>): Boolean;
begin
  result := ShowDialog(AContext, AOrderDetail, ASession, 'Edit detail');
end;

procedure TOrderDetailDialog.LoadFromEntity;
begin
  ProductCombo.ItemIndex := FindProductIndex(FOrderDetail.Product);
  QuantityEdit.Text := FOrderDetail.Quantity.ToString();
  PriceEdit.Text := FOrderDetail.Price.ToString();
end;

procedure TOrderDetailDialog.SaveToEntity;
begin
  if ProductCombo.ItemIndex >= 0 then
    FOrderDetail.Product := TProduct(ProductCombo.Items.Objects[ProductCombo.ItemIndex])
  else
    FOrderDetail.Product := nil;
  FOrderDetail.Quantity := StrToFloatDef(QuantityEdit.Text, 0);
  FOrderDetail.Price := StrToFloatDef(PriceEdit.Text, 0);
end;

procedure TOrderDetailDialog.ApplyEntity;
begin
  FSession.Save(FOrderDetail);
end;

end.
