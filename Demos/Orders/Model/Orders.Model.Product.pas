(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.Product;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Lazy,

  Orders.Model.Brand;

type

{ TProduct }

  [TTable('Products')]
  [TSequence('ProductsID')]
  [TRelation('OrderDetails', 'ProductID', False)]
  TProduct = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('BrandID')]
    [TRequired]
    FBrand: TTLazy<TBrand>;

    [TColumn('Description')]
    [TRequired]
    [TMaxLength(100)]
    FDescription: String;

    [TColumn('Price')]
    [TMinValue(0.01)]
    FPrice: Double;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;

    function GetBrand: TBrand;
    procedure SetBrand(const AValue: TBrand);
  public
    property ID: TTPrimaryKey read FID;
    property Brand: TBrand read GetBrand write SetBrand;
    property Description: String read FDescription write FDescription;
    property Price: Double read FPrice write FPrice;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TProduct }

function TProduct.GetBrand: TBrand;
begin
  result := FBrand.Entity;
end;

procedure TProduct.SetBrand(const AValue: TBrand);
begin
  FBrand.Entity := AValue;
end;

end.
