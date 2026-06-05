(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Dialog.Product;

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
  Trysil.Generics.Collections,

  Orders.Model.Brand,
  Orders.Model.Product,
  Orders.Dialog.Base;

type

{ TProductDialog }

  TProductDialog = class(TDialogBase)
    DescriptionEdit: TLabeledEdit;
    BrandLabel: TLabel;
    BrandCombo: TComboBox;
    PriceEdit: TLabeledEdit;
  strict private
    FProduct: TProduct;
    FBrands: TTList<TBrand>;

    procedure FillBrandCombo;
    function FindBrandIndex(const ABrand: TBrand): Integer;

    class function ShowDialog(
      const AContext: TTContext;
      const AProduct: TProduct;
      const ACaption: String): Boolean; static;
  strict protected
    procedure LoadFromEntity; override;
    procedure SaveToEntity; override;
    procedure ApplyEntity; override;
  public
    constructor Create(const AContext: TTContext); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    class function Insert(
      const AContext: TTContext; const AProduct: TProduct): Boolean;
    class function Edit(
      const AContext: TTContext; const AProduct: TProduct): Boolean;
  end;

implementation

{$R *.dfm}

{ TProductDialog }

constructor TProductDialog.Create(const AContext: TTContext);
begin
  inherited Create(AContext);
  FBrands := Context.CreateEntityList<TBrand>();
end;

destructor TProductDialog.Destroy;
begin
  FBrands.Free;
  inherited Destroy;
end;

procedure TProductDialog.AfterConstruction;
begin
  inherited AfterConstruction;
  FillBrandCombo;
end;

procedure TProductDialog.FillBrandCombo;
var
  LBrand: TBrand;
begin
  Context.Select<TBrand>(FBrands, TTFilter.Create('', 0, 'Description'));

  BrandCombo.Items.BeginUpdate;
  try
    BrandCombo.Items.Clear;
    for LBrand in FBrands do
      BrandCombo.Items.AddObject(LBrand.Description, LBrand);
  finally
    BrandCombo.Items.EndUpdate;
  end;
end;

function TProductDialog.FindBrandIndex(const ABrand: TBrand): Integer;
var
  LIndex: Integer;
begin
  result := -1;
  if Assigned(ABrand) then
    for LIndex := 0 to BrandCombo.Items.Count - 1 do
      if BrandCombo.Items.Objects[LIndex] = ABrand then
      begin
        result := LIndex;
        Break;
      end;
end;

class function TProductDialog.ShowDialog(
  const AContext: TTContext;
  const AProduct: TProduct;
  const ACaption: String): Boolean;
var
  LDialog: TProductDialog;
begin
  LDialog := TProductDialog.Create(AContext);
  try
    LDialog.Caption := ACaption;
    LDialog.FProduct := AProduct;
    result := LDialog.Execute;
  finally
    LDialog.Free;
  end;
end;

class function TProductDialog.Insert(
  const AContext: TTContext; const AProduct: TProduct): Boolean;
begin
  result := ShowDialog(AContext, AProduct, 'New product');
end;

class function TProductDialog.Edit(
  const AContext: TTContext; const AProduct: TProduct): Boolean;
begin
  result := ShowDialog(AContext, AProduct, 'Edit product');
end;

procedure TProductDialog.SaveToEntity;
begin
  if BrandCombo.ItemIndex >= 0 then
    FProduct.Brand := TBrand(BrandCombo.Items.Objects[BrandCombo.ItemIndex])
  else
    FProduct.Brand := nil;
  FProduct.Description := DescriptionEdit.Text;
  FProduct.Price := StrToFloatDef(PriceEdit.Text, 0);
end;

procedure TProductDialog.LoadFromEntity;
begin
  BrandCombo.ItemIndex := FindBrandIndex(FProduct.Brand);

  DescriptionEdit.Text := FProduct.Description;
  PriceEdit.Text := FProduct.Price.ToString();
end;

procedure TProductDialog.ApplyEntity;
begin
  Context.Save<TProduct>(FProduct);
end;

end.
