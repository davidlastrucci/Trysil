(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Orders.Model.Brand;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TBrand }

  [TTable('Brands')]
  [TSequence('BrandsID')]
  [TRelation('Products', 'BrandID', False)]
  TBrand = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('Description')]
    [TRequired]
    [TMaxLength(100)]
    FDescription: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;
  public
    property ID: TTPrimaryKey read FID;
    property Description: String read FDescription write FDescription;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

end.
