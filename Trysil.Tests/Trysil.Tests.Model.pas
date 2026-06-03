(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.SysUtils,
  Data.DB,

  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation,
  Trysil.Validation.Attributes,
  Trysil.Events.Attributes,
  Trysil.Lazy;

type

{ TTestCustomer }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestTask - entity with soft delete support }

  [TTable('Tasks')]
  [TSequence('TasksID')]
  TTestTask = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Title')]
    FTitle: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDeletedAt]
    [TColumn('DeletedAt')]
    FDeletedAt: TTNullable<TDateTime>;

    [TDeletedBy]
    [TColumn('DeletedBy')]
    FDeletedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property Title: String read FTitle write FTitle;
    property Version: TTVersion read FVersion;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property DeletedBy: String read FDeletedBy;
  end;

{ TTestTrackedUser - entity with full change tracking columns }

  [TTable('TrackedUsers')]
  [TSequence('TrackedUsersID')]
  TTestTrackedUser = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TCreatedAt]
    [TColumn('CreatedAt')]
    FCreatedAt: TTNullable<TDateTime>;

    [TCreatedBy]
    [TColumn('CreatedBy')]
    FCreatedBy: String;

    [TUpdatedAt]
    [TColumn('UpdatedAt')]
    FUpdatedAt: TTNullable<TDateTime>;

    [TUpdatedBy]
    [TColumn('UpdatedBy')]
    FUpdatedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
    property CreatedAt: TTNullable<TDateTime> read FCreatedAt;
    property CreatedBy: String read FCreatedBy;
    property UpdatedAt: TTNullable<TDateTime> read FUpdatedAt;
    property UpdatedBy: String read FUpdatedBy;
  end;

{ TTestOrder - order with FK to Customers }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FCustomerID: Integer;

    [TColumn('Amount')]
    FAmount: Double;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property CustomerID: Integer read FCustomerID write FCustomerID;
    property Amount: Double read FAmount write FAmount;
    property Version: TTVersion read FVersion;
  end;

{ TTestOrderReport - JOIN entity (read-only) }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TTestOrderReport = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Double;

    [TColumn('Customers', 'Name')]
    FCustomerName: String;

    [TColumn('Customers', 'Email')]
    FCustomerEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
    property CustomerEmail: String read FCustomerEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestOrderSummary - DTO for RawSelect }

  TTestOrderSummary = class
  strict private
    [TColumn('CustomerName')]
    FCustomerName: String;

    [TColumn('OrderCount')]
    FOrderCount: Integer;

    [TColumn('TotalAmount')]
    FTotalAmount: Double;
  public
    property CustomerName: String read FCustomerName;
    property OrderCount: Integer read FOrderCount;
    property TotalAmount: Double read FTotalAmount;
  end;

{ TTestCountry - country for chain join tests }

  [TTable('Countries')]
  [TSequence('CountriesID')]
  TTestCountry = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestCustomerWithCountry - customer with CountryID for chain join setup }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestCustomerWithCountry = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TColumn('CountryID')]
    FCountryID: Integer;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property CountryID: Integer read FCountryID write FCountryID;
    property Version: TTVersion read FVersion;
  end;

{ TTestLeftJoinOrderReport - LEFT JOIN entity }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Left, 'Customers', 'CustomerID', 'ID')]
  TTestLeftJoinOrderReport = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Double;

    [TColumn('Customers', 'Name')]
    FCustomerName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
    property Version: TTVersion read FVersion;
  end;

{ TTestChainJoinOrder - chain join: Orders -> Customers -> Countries }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  [TJoin(TJoinKind.Inner, 'Countries', 'Countries', 'Customers', 'CountryID', 'ID')]
  TTestChainJoinOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Double;

    [TColumn('Customers', 'Name')]
    FCustomerName: String;

    [TColumn('Countries', 'Name')]
    FCountryName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
    property CountryName: String read FCountryName;
    property Version: TTVersion read FVersion;
  end;

{ TTestLazyOrder - order with TTLazy<TTestCustomer> }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestLazyOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FCustomer: TTLazy<TTestCustomer>;

    [TColumn('Amount')]
    FAmount: Double;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Customer: TTLazy<TTestCustomer> read FCustomer;
    property Amount: Double read FAmount write FAmount;
    property Version: TTVersion read FVersion;
  end;

{ TTestLazyCustomer - customer with TTLazyList<TTestLazyOrder> }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestLazyCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDetailColumn('ID', 'CustomerID')]
    FOrders: TTLazyList<TTestLazyOrder>;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property Orders: TTLazyList<TTestLazyOrder> read FOrders;
  end;

{ TTestSoftCustomer - customer with soft delete, used as lazy N:1 target }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestSoftCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDeletedAt]
    [TColumn('DeletedAt')]
    FDeletedAt: TTNullable<TDateTime>;

    [TDeletedBy]
    [TColumn('DeletedBy')]
    FDeletedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property DeletedBy: String read FDeletedBy;
  end;

{ TTestSoftLazyOrder - order whose TTLazy master supports soft delete }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestSoftLazyOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FCustomer: TTLazy<TTestSoftCustomer>;

    [TColumn('Amount')]
    FAmount: Double;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Customer: TTLazy<TTestSoftCustomer> read FCustomer;
    property Amount: Double read FAmount write FAmount;
    property Version: TTVersion read FVersion;
  end;

{ TTestValidatedItem - entity with validation attributes }

  [TTable('ValidatedItems')]
  [TSequence('ValidatedItemsID')]
  TTestValidatedItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TColumn('Name')]
    FName: String;

    [TMaxLength(10)]
    [TColumn('Code')]
    FCode: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Code: String read FCode write FCode;
    property Version: TTVersion read FVersion;
  end;

{ TTestFullValidation - entity with all validation attributes }

  [TTable('FullValidation')]
  [TSequence('FullValidationID')]
  TTestFullValidation = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TMinLength(3)]
    [TColumn('Code')]
    FCode: String;

    [TRange(1, 100)]
    [TColumn('Score')]
    FScore: Integer;

    [TMinValue(0)]
    [TColumn('Quantity')]
    FQuantity: Integer;

    [TMaxValue(1000.00)]
    [TColumn('Price')]
    FPrice: Double;

    [TLess(50)]
    [TColumn('Discount')]
    FDiscount: Integer;

    [TGreater(0.00)]
    [TColumn('Weight')]
    FWeight: Double;

    [TRegex('^\d{3}-\d{4}$')]
    [TColumn('Phone')]
    FPhone: String;

    [TEMail]
    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Code: String read FCode write FCode;
    property Score: Integer read FScore write FScore;
    property Quantity: Integer read FQuantity write FQuantity;
    property Price: Double read FPrice write FPrice;
    property Discount: Integer read FDiscount write FDiscount;
    property Weight: Double read FWeight write FWeight;
    property Phone: String read FPhone write FPhone;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestEventCustomer - entity with event methods }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestEventCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    FEventLog: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property EventLog: String read FEventLog;

    [TBeforeInsertEvent]
    procedure OnBeforeInsert;

    [TAfterInsertEvent]
    procedure OnAfterInsert;

    [TBeforeUpdateEvent]
    procedure OnBeforeUpdate;

    [TAfterUpdateEvent]
    procedure OnAfterUpdate;

    [TBeforeDeleteEvent]
    procedure OnBeforeDelete;

    [TAfterDeleteEvent]
    procedure OnAfterDelete;
  end;

{ TTestActiveCustomer - entity with WhereClause }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TWhereClause('Email IS NOT NULL')]
  TTestActiveCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestSimpleItem - entity without VersionColumn for KeyOnly tests }

  [TTable('SimpleItems')]
  [TSequence('SimpleItemsID')]
  TTestSimpleItem = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
  end;

{ TTestCustomerWithRelation - customer with non-cascade relation to Orders }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TRelation('Orders', 'CustomerID', False)]
  TTestCustomerWithRelation = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestCustomerWithCascadeRelation - customer with cascade relation to Orders }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TRelation('Orders', 'CustomerID', True)]
  TTestCustomerWithCascadeRelation = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestSoftDeleteCustomerWithRelation - customer with soft delete and non-cascade relation }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TRelation('Orders', 'CustomerID', False)]
  TTestSoftDeleteCustomerWithRelation = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDeletedAt]
    [TColumn('DeletedAt')]
    FDeletedAt: TTNullable<TDateTime>;

    [TDeletedBy]
    [TColumn('DeletedBy')]
    FDeletedBy: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property DeletedBy: String read FDeletedBy;
  end;

{ TTestAllTypes - entity exercising every column/parameter/rtti mapping }

  [TTable('AllTypes')]
  [TSequence('AllTypesID')]
  TTestAllTypes = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('LargeNumber')]
    FLargeNumber: Int64;

    [TColumn('IsActive')]
    FIsActive: Boolean;

    [TColumn('BirthDate')]
    FBirthDate: TDateTime;

    [TColumn('UniqueID')]
    FUniqueID: TGuid;

    [TColumn('Payload')]
    FPayload: TBytes;

    [TColumn('OptLargeNumber')]
    FOptLargeNumber: TTNullable<Int64>;

    [TColumn('OptIsActive')]
    FOptIsActive: TTNullable<Boolean>;

    [TColumn('OptBirthDate')]
    FOptBirthDate: TTNullable<TDateTime>;

    [TColumn('OptUniqueID')]
    FOptUniqueID: TTNullable<TGuid>;

    [TColumn('OptPayload')]
    FOptPayload: TTNullable<TBytes>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property LargeNumber: Int64 read FLargeNumber write FLargeNumber;
    property IsActive: Boolean read FIsActive write FIsActive;
    property BirthDate: TDateTime read FBirthDate write FBirthDate;
    property UniqueID: TGuid read FUniqueID write FUniqueID;
    property Payload: TBytes read FPayload write FPayload;
    property OptLargeNumber: TTNullable<Int64>
      read FOptLargeNumber write FOptLargeNumber;
    property OptIsActive: TTNullable<Boolean>
      read FOptIsActive write FOptIsActive;
    property OptBirthDate: TTNullable<TDateTime>
      read FOptBirthDate write FOptBirthDate;
    property OptUniqueID: TTNullable<TGuid>
      read FOptUniqueID write FOptUniqueID;
    property OptPayload: TTNullable<TBytes>
      read FOptPayload write FOptPayload;
    property Version: TTVersion read FVersion;
  end;

{ TTestNullablePrimitives - entity exercising TTNullable<String/Integer/Double> }

  [TTable('NullablePrimitives')]
  [TSequence('NullablePrimitivesID')]
  TTestNullablePrimitives = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Description')]
    FDescription: TTNullable<String>;

    [TColumn('Quantity')]
    FQuantity: TTNullable<Integer>;

    [TColumn('Price')]
    FPrice: TTNullable<Double>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Description: TTNullable<String>
      read FDescription write FDescription;
    property Quantity: TTNullable<Integer>
      read FQuantity write FQuantity;
    property Price: TTNullable<Double> read FPrice write FPrice;
    property Version: TTVersion read FVersion;
  end;

{ TTestCustomValidatedCustomer - entity with custom validator method }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestCustomValidatedCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Email')]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;

    [TValidator]
    procedure ValidateNameNotAdmin(const AErrors: TTValidationErrors);
  end;

implementation

{ TTestCustomValidatedCustomer }

procedure TTestCustomValidatedCustomer.ValidateNameNotAdmin(
  const AErrors: TTValidationErrors);
begin
  if FName = 'admin' then
    AErrors.Add('Name', 'Name cannot be "admin"');
end;

{ TTestEventCustomer }

procedure TTestEventCustomer.OnBeforeInsert;
begin
  FEventLog := Format('%sBI;', [FEventLog]);
end;

procedure TTestEventCustomer.OnAfterInsert;
begin
  FEventLog := Format('%sAI;', [FEventLog]);
end;

procedure TTestEventCustomer.OnBeforeUpdate;
begin
  FEventLog := Format('%sBU;', [FEventLog]);
end;

procedure TTestEventCustomer.OnAfterUpdate;
begin
  FEventLog := Format('%sAU;', [FEventLog]);
end;

procedure TTestEventCustomer.OnBeforeDelete;
begin
  FEventLog := Format('%sBD;', [FEventLog]);
end;

procedure TTestEventCustomer.OnAfterDelete;
begin
  FEventLog := Format('%sAD;', [FEventLog]);
end;

end.
