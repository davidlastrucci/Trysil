(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.Order;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes,
  Trysil.Generics.Collections,
  Trysil.Lazy,

  Orders.Model.Customer,
  Orders.Model.OrderDetail;

type

{ TOrder }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TRelation('OrderDetails', 'OrderID', True)]
  TOrder = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('OrderDate')]
    [TRequired]
    FOrderDate: TDateTime;

    [TColumn('CustomerID')]
    [TRequired]
    FCustomer: TTLazy<TCustomer>;

    [TDetailColumn('ID', 'OrderID')]
    FDetail: TTLazyList<TOrderDetail>;

    [TColumn('Cashed')]
    FCashed: Boolean;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;

    function GetCustomer: TCustomer;
    procedure SetCustomer(const AValue: TCustomer);
    function GetDetail: TTList<TOrderDetail>;
  public
    procedure AfterConstruction; override;

    property ID: TTPrimaryKey read FID;
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    property Customer: TCustomer read GetCustomer write SetCustomer;
    property Detail: TTList<TOrderDetail> read GetDetail;
    property Cashed: Boolean read FCashed write FCashed;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TOrder }

procedure TOrder.AfterConstruction;
begin
  inherited AfterConstruction;
  FOrderDate := Date;
end;

function TOrder.GetCustomer: TCustomer;
begin
  result := FCustomer.Entity;
end;

procedure TOrder.SetCustomer(const AValue: TCustomer);
begin
  FCustomer.Entity := AValue;
end;

function TOrder.GetDetail: TTList<TOrderDetail>;
begin
  result := FDetail.List;
end;

end.
