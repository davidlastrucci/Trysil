(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit API.Model.Employee;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Lazy,
  Trysil.Validation.Attributes,

  API.Model.Company;

type

{ TAPIEmployee }

  [TTable('Employees')]
  [TSequence('EmployeesID')]
  TAPIEmployee = class
  strict private
    [TPrimaryKey]
    [TColumn('ID')]
    FID: TTPrimaryKey;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Firstname')]
    FFirstname: String;

    [TRequired]
    [TMaxLength(100)]
    [TColumn('Lastname')]
    FLastname: String;

    [TMaxLength(255)]
    [TEmail]
    [TColumn('Email')]
    FEmail: String;

    [TRequired]
    [TDisplayName('Company')]
    [TColumn('CompanyID')]
    FCompany: TTLazy<TAPICompany>;

    [TVersionColumn]
    [TColumn('VersionID')]
    FVersionID: TTVersion;

    function GetCompany: TAPICompany;
    procedure SetCompany(const AValue: TAPICompany);
  public
    function ToString(): String; override;

    property ID: TTPrimaryKey read FID;
    property Firstname: String read FFirstname write FFirstname;
    property Lastname: String read FLastname write FLastname;
    property Email: String read FEmail write FEmail;
    property Company: TAPICompany read GetCompany write SetCompany;
    property VersionID: TTVersion read FVersionID;
  end;

implementation

{ TAPIEmployee }

function TAPIEmployee.GetCompany: TAPICompany;
begin
  result := FCompany.Entity;
end;

procedure TAPIEmployee.SetCompany(const AValue: TAPICompany);
begin
  FCompany.Entity := AValue;
end;

function TAPIEmployee.ToString: String;
begin
  result := Format('%s %s', [FFirstname, FLastname]);
end;

end.

