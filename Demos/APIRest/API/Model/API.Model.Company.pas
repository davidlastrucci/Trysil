(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Model.Company;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Validation.Attributes;

type

{ TAPICompany }

  [TTable('Companies')]
  [TSequence('CompaniesID')]
  [TRelation('Employees', 'CompanyID', False)]
  TAPICompany = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Name')]
    FName: String;

    [TMaxLength(100)]
    [TColumn('Address')]
    FAddress: String;

    [TMaxLength(100)]
    [TColumn('City')]
    FCity: String;

    [TMaxLength(100)]
    [TColumn('Country')]
    FCountry: String;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;
  public
    function ToString(): String; override;

    property ID: TTPrimaryKey read FID;
    property Name: String read FName write FName;
    property Address: String read FAddress write FAddress;
    property City: String read FCity write FCity;
    property Country: String read FCountry write FCountry;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TAPICompany }

function TAPICompany.ToString: String;
begin
  result := FName;
end;

end.


