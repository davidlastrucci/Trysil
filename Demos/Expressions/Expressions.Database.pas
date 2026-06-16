(*

  Trysil
  Copyright © David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Expressions.Database;

interface

uses
  System.SysUtils,
  System.Classes,
  Trysil.Data;

type

{ TDemoDatabase }

  TDemoDatabase = class
  strict private
    const CreateTableSQL =
      'CREATE TABLE IF NOT EXISTS People (' +
      '  ID INTEGER NOT NULL,' +
      '  FirstName VARCHAR(30),' +
      '  LastName VARCHAR(30),' +
      '  City VARCHAR(30),' +
      '  Age INTEGER,' +
      '  Salary NUMERIC(10,2),' +
      '  Department VARCHAR(30),' +
      '  VersionID INTEGER NOT NULL,' +
      '  PRIMARY KEY(ID))';

    class function DepartmentValue(const ADepartment: String): String; static;
    class function InsertStatement(
      const AID: Integer;
      const AFirstName: String;
      const ALastName: String;
      const ACity: String;
      const AAge: Integer;
      const ASalary: Integer;
      const ADepartment: String): String; static;
    class function SeedStatements: TArray<String>; static;
  public
    class procedure Build(const AConnection: TTConnection); static;
  end;

implementation

{ TDemoDatabase }

class function TDemoDatabase.DepartmentValue(
  const ADepartment: String): String;
begin
  if ADepartment.IsEmpty then
    result := 'NULL'
  else
    result := QuotedStr(ADepartment);
end;

class function TDemoDatabase.InsertStatement(
  const AID: Integer;
  const AFirstName: String;
  const ALastName: String;
  const ACity: String;
  const AAge: Integer;
  const ASalary: Integer;
  const ADepartment: String): String;
begin
  result := Format(
    'INSERT INTO People ' +
    '(ID, FirstName, LastName, City, Age, Salary, Department, VersionID) ' +
    'VALUES (%d, %s, %s, %s, %d, %d, %s, 0)', [
    AID,
    QuotedStr(AFirstName),
    QuotedStr(ALastName),
    QuotedStr(ACity),
    AAge,
    ASalary,
    DepartmentValue(ADepartment)]);
end;

class function TDemoDatabase.SeedStatements: TArray<String>;
begin
  result := [
    InsertStatement(1, 'Marco', 'Rossi', 'Roma', 35, 2200, 'Sales'),
    InsertStatement(2, 'Luca', 'Bianchi', 'Milano', 28, 1800, 'IT'),
    InsertStatement(3, 'Anna', 'Verdi', 'Roma', 42, 3100, ''),
    InsertStatement(4, 'Sara', 'Russo', 'Napoli', 15, 1100, 'HR'),
    InsertStatement(5, 'Paolo', 'Romano', 'Milano', 39, 2700, 'IT'),
    InsertStatement(6, 'Elena', 'Ricci', 'Torino', 16, 1200, ''),
    InsertStatement(7, 'Giulia', 'Rizzo', 'Napoli', 45, 3500, 'Sales'),
    InsertStatement(8, 'Davide', 'Conti', 'Roma', 22, 1400, 'IT')];
end;

class procedure TDemoDatabase.Build(const AConnection: TTConnection);
var
  LStatement: String;
begin
  AConnection.Execute(CreateTableSQL);
  for LStatement in SeedStatements do
    AConnection.Execute(LStatement);
end;

end.
