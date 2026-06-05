(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.ProductsTodo;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes;

type

{ TProductsTodoBase }

  TProductsTodoBase = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('OrderDate')]
    FOrderDate: TDateTime;

    [TColumn('CustomerID')]
    FCustomerID: Integer;

    [TColumn('ProductID')]
    FProductID: Integer;

    [TColumn('Description')]
    FDescription: String;

    [TColumn('Quantity')]
    FQuantity: Double;

    [TColumn('Price')]
    FPrice: Double;
  public
    property ID: TTPrimaryKey read FID;
    property OrderDate: TDateTime read FOrderDate;
    property CustomerID: Integer read FCustomerID;
    property ProductID: Integer read FProductID;
    property Description: String read FDescription;
    property Quantity: Double read FQuantity;
    property Price: Double read FPrice;
  end;

{ TProductsToBeProduced }

  [TTable('ProductsToBeProduced')]
  TProductsToBeProduced = class(TProductsTodoBase)
  end;

{ TProductsToBeDelivered }

  [TTable('ProductsToBeDelivered')]
  TProductsToBeDelivered = class(TProductsTodoBase)
  end;

{ TProductsToBeCashed }

  [TTable('ProductsToBeCashed')]
  TProductsToBeCashed = class(TProductsTodoBase)
  end;

implementation

end.
