(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.Customer;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TCustomer }

  [TTable('Customers')]
  [TSequence('CustomersID')]
  [TRelation('Orders', 'CustomerID', False)]
  TCustomer = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('CompanyName')]
    [TRequired]
    [TMaxLength(100)]
    FCompanyName: String;

    [TColumn('Address')]
    [TMaxLength(100)]
    FAddress: String;

    [TColumn('City')]
    [TMaxLength(100)]
    FCity: String;

    [TColumn('Region')]
    [TMaxLength(100)]
    FRegion: String;

    [TColumn('PostalCode')]
    [TMaxLength(20)]
    FPostalCode: String;

    [TColumn('Country')]
    [TMaxLength(100)]
    FCountry: String;

    [TColumn('Email')]
    [TMaxLength(255)]
    [TEMail]
    FEmail: String;

    [TColumn('CreatedAt')]
    [TCreatedAt]
    FCreatedAt: TTNullable<TDateTime>;

    [TColumn('CreatedBy')]
    [TCreatedBy]
    [TMaxLength(100)]
    FCreatedBy: String;

    [TColumn('UpdatedAt')]
    [TUpdatedAt]
    FUpdatedAt: TTNullable<TDateTime>;

    [TColumn('UpdatedBy')]
    [TUpdatedBy]
    [TMaxLength(100)]
    FUpdatedBy: String;

    [TColumn('DeletedAt')]
    [TDeletedAt]
    FDeletedAt: TTNullable<TDateTime>;

    [TColumn('DeletedBy')]
    [TDeletedBy]
    [TMaxLength(100)]
    FDeletedBy: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property CompanyName: String read FCompanyName write FCompanyName;
    property Address: String read FAddress write FAddress;
    property City: String read FCity write FCity;
    property Region: String read FRegion write FRegion;
    property PostalCode: String read FPostalCode write FPostalCode;
    property Country: String read FCountry write FCountry;
    property Email: String read FEmail write FEmail;
    property CreatedAt: TTNullable<TDateTime> read FCreatedAt;
    property CreatedBy: String read FCreatedBy;
    property UpdatedAt: TTNullable<TDateTime> read FUpdatedAt;
    property UpdatedBy: String read FUpdatedBy;
    property DeletedAt: TTNullable<TDateTime> read FDeletedAt;
    property DeletedBy: String read FDeletedBy;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

end.
