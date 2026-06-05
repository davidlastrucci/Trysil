(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.OrderDetail;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Lazy,

  Orders.Model.Product;

type

{ TOrderDetail }

  [TTable('OrderDetails')]
  [TSequence('OrderDetailsID')]
  TOrderDetail = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('OrderID')]
    [TRequired]
    FOrderID: Integer;

    [TColumn('ProductID')]
    [TRequired]
    FProduct: TTLazy<TProduct>;

    [TColumn('Quantity')]
    [TMinValue(0.01)]
    FQuantity: Double;

    [TColumn('Price')]
    [TMinValue(0.01)]
    FPrice: Double;

    [TColumn('Produced')]
    FProduced: TTNullable<TDateTime>;

    [TColumn('Delivered')]
    FDelivered: TTNullable<TDateTime>;

    [TColumn('Cashed')]
    FCashed: TTNullable<TDateTime>;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;

    function GetProduct: TProduct;
    procedure SetProduct(const AValue: TProduct);
    function GetAmount: Double;
  public
    property ID: TTPrimaryKey read FID;
    property OrderID: Integer read FOrderID write FOrderID;
    property Product: TProduct read GetProduct write SetProduct;
    property Quantity: Double read FQuantity write FQuantity;
    property Price: Double read FPrice write FPrice;
    property Amount: Double read GetAmount;
    property Produced: TTNullable<TDateTime> read FProduced write FProduced;
    property Delivered: TTNullable<TDateTime> read FDelivered write FDelivered;
    property Cashed: TTNullable<TDateTime> read FCashed write FCashed;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TOrderDetail }

function TOrderDetail.GetProduct: TProduct;
begin
  result := FProduct.Entity;
end;

procedure TOrderDetail.SetProduct(const AValue: TProduct);
begin
  FProduct.Entity := AValue;
  if Assigned(AValue) then
    FPrice := AValue.Price;
end;

function TOrderDetail.GetAmount: Double;
begin
  result := FQuantity * FPrice;
end;

end.
