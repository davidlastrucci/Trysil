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
  Trysil.Generics.Collections,
  Trysil.Attributes,
  Trysil.Validation,
  Trysil.Validation.Attributes,
  Trysil.Events.Attributes,
  Trysil.Lazy,
  Trysil.JSon.Attributes;

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

{ TSegretoAttribute - an attribute of the host, derived from a Trysil one }

  TSegretoAttribute = class(TJSonIgnoreSerializeAttribute);

{ TTestSecret - entity with a column excluded from dynamic filtering }

  [TTable('Secrets')]
  [TSequence('SecretsID')]
  TTestSecret = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TColumn('Password')]
    [TNotFilterable]
    FPassword: String;

    [TColumn('Token')]
    [TJSonIgnoreSerialize]
    FToken: String;

    [TColumn('Segreto')]
    [TSegreto]
    FSegreto: String;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Password: String read FPassword write FPassword;
    property Token: String read FToken write FToken;
    property Segreto: String read FSegreto write FSegreto;
  end;

{ TTestFilterNames - columns whose JSON names are not their column names }

  [TTable('FilterNames')]
  [TSequence('FilterNamesID')]
  TTestFilterNames = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('DESCR')]
    FDescrizione: String;

    [TColumn('NOTE_INT')]
    [TJSonIgnoreSerialize]
    FNoteInterne: String;

    [TColumn('ClienteID')]
    [TJSonIgnoreSerialize]
    FCodiceCliente: String;

    [TColumn('IDCliente')]
    FClienteID: Integer;

    [TColumn('CUST_REF')]
    FCustomer: TTLazy<TTestCustomer>;
  public
    property ID: TTPrimaryKey read FID;
    property Descrizione: String read FDescrizione write FDescrizione;
    property NoteInterne: String read FNoteInterne write FNoteInterne;
    property CodiceCliente: String
      read FCodiceCliente write FCodiceCliente;
    property ClienteID: Integer read FClienteID write FClienteID;
    property Customer: TTLazy<TTestCustomer> read FCustomer;
  end;

{ TTestTask - entity with soft delete and update tracking }

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

    [TUpdatedAt]
    [TColumn('UpdatedAt')]
    FUpdatedAt: TTNullable<TDateTime>;

    [TUpdatedBy]
    [TColumn('UpdatedBy')]
    FUpdatedBy: String;

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
    property UpdatedAt: TTNullable<TDateTime> read FUpdatedAt;
    property UpdatedBy: String read FUpdatedBy;
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

{ TTestParamCollision - two columns that fold onto one parameter name }

  [TTable('ParamCollision')]
  TTestParamCollision = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Ragione Sociale')]
    FRagioneSociale: String;

    [TColumn('Ragione_Sociale')]
    FRagioneSocialeAlt: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property RagioneSociale: String
      read FRagioneSociale write FRagioneSociale;
    property RagioneSocialeAlt: String
      read FRagioneSocialeAlt write FRagioneSocialeAlt;
    property Version: TTVersion read FVersion;
  end;

{ TTestOwnedOrderReport - JOIN entity that counts its own destructions }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TTestOwnedOrderReport = class
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
    destructor Destroy; override;

    class procedure ResetDestroyedCount;
    class function DestroyedCount: Integer;

    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount;
    property CustomerName: String read FCustomerName;
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

{ TTestFaultValue - a type only the fault deserializer of the tests reads }

  TTestFaultValue = type Integer;

{ TTestFaultyEntity - entity whose column goes through that deserializer }

  TTestFaultyEntity = class
  strict private
    [TColumn('Fault')]
    FFault: TTestFaultValue;
  public
    property Fault: TTestFaultValue read FFault;
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

    function GetOrders: TTList<TTestLazyOrder>;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
    property Orders: TTList<TTestLazyOrder> read GetOrders;
  end;

{ TTestBareDetailOrder - detail that does not map the foreign key }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestBareDetailOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Amount')]
    FAmount: Double;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Amount: Double read FAmount write FAmount;
    property Version: TTVersion read FVersion;
  end;

{ TTestBareDetailCustomer - master of a detail that does not map the key }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestBareDetailCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDetailColumn('ID', 'CustomerID')]
    FOrders: TTLazyList<TTestBareDetailOrder>;

    function GetOrders: TTList<TTestBareDetailOrder>;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
    property Orders: TTList<TTestBareDetailOrder> read GetOrders;
  end;

{ TTestJoinDetailOrder - detail entity that maps a join }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  [TJoin(TJoinKind.Inner, 'Customers', 'CustomerID', 'ID')]
  TTestJoinDetailOrder = class
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

{ TTestJoinDetailCustomer - master of a detail entity that maps a join }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestJoinDetailCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;

    [TDetailColumn('ID', 'CustomerID')]
    FOrders: TTLazyList<TTestJoinDetailOrder>;

    function GetOrders: TTList<TTestJoinDetailOrder>;
  public
    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
    property Orders: TTList<TTestJoinDetailOrder> read GetOrders;
  end;

{ TTestChainedOrder - order whose lazy customer has a lazy list of its own }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestChainedOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FCustomer: TTLazy<TTestLazyCustomer>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Customer: TTLazy<TTestLazyCustomer> read FCustomer;
    property Version: TTVersion read FVersion;
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

{ TTestRequiredSoftLazyOrder - required relation whose master is soft deleted }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestRequiredSoftLazyOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    [TRequired]
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

{ TTestMissingColumn - maps a column the table does not have }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestMissingColumn = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('NoSuchColumn')]
    FMissing: String;
  public
    property ID: TTPrimaryKey read FID;
    property Missing: String read FMissing write FMissing;
  end;

{ TTestRequiredLazyOrder - order whose relation is required }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestRequiredLazyOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
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

{ TTestDoubleFLazyOrder - lazy member named F, F and a capital }

  [TTable('Orders')]
  [TSequence('OrdersID')]
  TTestDoubleFLazyOrder = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('CustomerID')]
    FFCustomer: TTLazy<TTestCustomer>;

    [TColumn('Amount')]
    FAmount: Double;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Customer: TTLazy<TTestCustomer> read FFCustomer;
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

{ TTestAsymmetricCustomer - entity with directional JSon attributes }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestAsymmetricCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    [TJSonIgnoreSerialize]
    FName: String;

    [TColumn('Email')]
    [TJSonIgnoreDeserialize]
    FEmail: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID write FID;
    property Name: String read FName write FName;
    property Email: String read FEmail write FEmail;
    property Version: TTVersion read FVersion;
  end;

{ TTestHiddenKeyCustomer - key and version kept out of the JSon }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestHiddenKeyCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    [TJSonIgnore]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    [TJSonIgnore]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID write FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestWriteOnlyKeyCustomer - the key is written and never returned }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestWriteOnlyKeyCustomer = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    [TJSonIgnoreSerialize]
    FID: TTPrimaryKey;

    [TColumn('Name')]
    FName: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersion: TTVersion;
  public
    property ID: TTPrimaryKey read FID write FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestReentrantCustomer - serialized by an event of its own }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestReentrantCustomer = class
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
    property ID: TTPrimaryKey read FID write FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestNoKeyCustomer - entity without a primary key }

  [TTable('Customers')]
  TTestNoKeyCustomer = class
  strict private
    [TColumn('Name')]
    FName: String;
  public
    property Name: String read FName write FName;
  end;

{ TTestValueCustomer - entity that compares by value, not by identity }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  TTestValueCustomer = class
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
    function Equals(AObject: TObject): Boolean; override;
    function GetHashCode: Integer; override;

    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Version: TTVersion read FVersion;
  end;

{ TTestParameterCustomer - entity with WhereClause and parameters }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TWhereClause('Name <> :ExcludedName')]
  [TWhereClauseParameter('ExcludedName', 'Excluded')]
  TTestParameterCustomer = class
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

{ TTestSequenceCeiling - entity on a table no other fixture touches }

  [TTable('SequenceCeiling')]
  [TSequence('SequenceCeilingID')]
  TTestSequenceCeiling = class
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

    [TColumn('Price')]
    FPrice: Currency;

    [TColumn('Notes')]
    FNotes: String;

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

    [TColumn('OptPrice')]
    FOptPrice: TTNullable<Currency>;

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
    property Price: Currency read FPrice write FPrice;
    property Notes: String read FNotes write FNotes;
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
    property OptPrice: TTNullable<Currency>
      read FOptPrice write FOptPrice;
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

    [TValidator]
    procedure ValidateNameAgainstTheDatabase(
      const AErrors: TTValidationErrors);
  end;

implementation

var
  GDestroyedOwnedOrderReports: Integer;

{ TTestOwnedOrderReport }

destructor TTestOwnedOrderReport.Destroy;
begin
  Inc(GDestroyedOwnedOrderReports);
  inherited Destroy;
end;

class procedure TTestOwnedOrderReport.ResetDestroyedCount;
begin
  GDestroyedOwnedOrderReports := 0;
end;

class function TTestOwnedOrderReport.DestroyedCount: Integer;
begin
  result := GDestroyedOwnedOrderReports;
end;

{ TTestValueCustomer }

function TTestValueCustomer.Equals(AObject: TObject): Boolean;
begin
  result := (AObject is TTestValueCustomer) and
    (TTestValueCustomer(AObject).Name = FName);
end;

function TTestValueCustomer.GetHashCode: Integer;
begin
  result := FName.GetHashCode;
end;

{ TTestLazyCustomer }

function TTestLazyCustomer.GetOrders: TTList<TTestLazyOrder>;
begin
  result := FOrders.List;
end;

{ TTestBareDetailCustomer }

function TTestBareDetailCustomer.GetOrders: TTList<TTestBareDetailOrder>;
begin
  result := FOrders.List;
end;

{ TTestJoinDetailCustomer }

function TTestJoinDetailCustomer.GetOrders: TTList<TTestJoinDetailOrder>;
begin
  result := FOrders.List;
end;

{ TTestCustomValidatedCustomer }

procedure TTestCustomValidatedCustomer.ValidateNameNotAdmin(
  const AErrors: TTValidationErrors);
begin
  if FName = 'admin' then
    AErrors.Add('Name', 'Name cannot be "admin"');
end;

procedure TTestCustomValidatedCustomer.ValidateNameAgainstTheDatabase(
  const AErrors: TTValidationErrors);
begin
  if FName = 'unreachable' then
    raise Exception.Create(
      'Connection lost: server SQL01.internal, database Billing');
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
