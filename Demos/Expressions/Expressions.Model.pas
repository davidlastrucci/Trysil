(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Expressions.Model;

{$WARN UNKNOWN_CUSTOM_ATTRIBUTE ERROR}

interface

uses
  System.Classes,
  System.SysUtils,
  Trysil.Types,
  Trysil.Attributes,
  Trysil.Filter.Expression;

type

{ TPerson }

  [TTable('People')]
  [TSequence('PeopleID')]
  TPerson = class
  strict private
    [TColumn('ID')]
    [TPrimaryKey]
    FID: TTPrimaryKey;

    [TColumn('FirstName')]
    FFirstName: String;

    [TColumn('LastName')]
    FLastName: String;

    [TColumn('City')]
    FCity: String;

    [TColumn('Age')]
    FAge: Integer;

    [TColumn('Salary')]
    FSalary: Double;

    [TColumn('Department')]
    FDepartment: String;

    [TColumn('VersionID')]
    [TVersionColumn]
    FVersionID: TTVersion;

    function GetDepartmentText: String;
  public
    function ToString(): String; override;

    property ID: TTPrimaryKey read FID;
    property FirstName: String read FFirstName write FFirstName;
    property LastName: String read FLastName write FLastName;
    property City: String read FCity write FCity;
    property Age: Integer read FAge write FAge;
    property Salary: Double read FSalary write FSalary;
    property Department: String read FDepartment write FDepartment;
    property DepartmentText: String read GetDepartmentText;
    property VersionID: TTVersion read FVersionID;
  end;

{ TPersonProperties }

  TPersonProperties = record
  public
    ID: TTProperty;
    FirstName: TTProperty;
    LastName: TTProperty;
    City: TTProperty;
    Age: TTProperty;
    Salary: TTProperty;
    Department: TTProperty;

    class function Create: TPersonProperties; static;
  end;

implementation

{ TPerson }

function TPerson.GetDepartmentText: String;
begin
  if FDepartment.IsEmpty then
    result := '(none)'
  else
    result := FDepartment;
end;

function TPerson.ToString: String;
begin
  result := Format('%-7s %-9s  %-7s  age %2d  %7.0f  %s', [
    FFirstName, FLastName, FCity, FAge, FSalary, DepartmentText]);
end;

{ TPersonProperties }

class function TPersonProperties.Create: TPersonProperties;
begin
  result.ID := TTProperty.Create('ID');
  result.FirstName := TTProperty.Create('FirstName');
  result.LastName := TTProperty.Create('LastName');
  result.City := TTProperty.Create('City');
  result.Age := TTProperty.Create('Age');
  result.Salary := TTProperty.Create('Salary');
  result.Department := TTProperty.Create('Department');
end;

end.
