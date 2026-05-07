(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.PostgreSQL.Connection;

interface

uses
  System.SysUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.PostgreSQL,

  Trysil.Tests.Config;

type

{ TTPostgreSQLTestConnection }

  TTPostgreSQLTestConnection = class
  strict private
    class var FConnection: TTPostgreSQLConnection;

    class procedure DropTables;
    class procedure DropSequences;
    class procedure CreateSequences;
    class procedure CreateTables;
  public
    class procedure Initialize;
    class procedure Finalize;

    class function Connection: TTConnection;
  end;

implementation

const
  DDL_CUSTOMERS =
    'CREATE TABLE Customers (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' Email VARCHAR(255),' +
    ' CountryID INT NULL,' +
    ' DeletedAt TIMESTAMP NULL,' +
    ' DeletedBy VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_COUNTRIES =
    'CREATE TABLE Countries (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_ORDERS =
    'CREATE TABLE Orders (' +
    ' ID INT NOT NULL,' +
    ' CustomerID INT NOT NULL,' +
    ' Amount DECIMAL NOT NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE Tasks (' +
    ' ID INT NOT NULL,' +
    ' Title VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' DeletedAt TIMESTAMP NULL,' +
    ' DeletedBy VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE TrackedUsers (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' CreatedAt TIMESTAMP NULL,' +
    ' CreatedBy VARCHAR(100),' +
    ' UpdatedAt TIMESTAMP NULL,' +
    ' UpdatedBy VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_VALIDATED_ITEMS =
    'CREATE TABLE ValidatedItems (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' Code VARCHAR(50),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_FULL_VALIDATION =
    'CREATE TABLE FullValidation (' +
    ' ID INT NOT NULL,' +
    ' Code VARCHAR(50),' +
    ' Score INT NOT NULL,' +
    ' Quantity INT NOT NULL,' +
    ' Price DECIMAL NOT NULL,' +
    ' Discount INT NOT NULL,' +
    ' Weight DECIMAL NOT NULL,' +
    ' Phone VARCHAR(20),' +
    ' Email VARCHAR(255),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_SIMPLE_ITEMS =
    'CREATE TABLE SimpleItems (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_ALL_TYPES =
    'CREATE TABLE AllTypes (' +
    ' ID INT NOT NULL,' +
    ' LargeNumber BIGINT NOT NULL,' +
    ' IsActive BOOLEAN NOT NULL,' +
    ' BirthDate TIMESTAMP NOT NULL,' +
    ' UniqueID UUID NOT NULL,' +
    ' Payload BYTEA NOT NULL,' +
    ' OptLargeNumber BIGINT NULL,' +
    ' OptIsActive BOOLEAN NULL,' +
    ' OptBirthDate TIMESTAMP NULL,' +
    ' OptUniqueID UUID NULL,' +
    ' OptPayload BYTEA NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE NullablePrimitives (' +
    ' ID INT NOT NULL,' +
    ' Description VARCHAR(100) NULL,' +
    ' Quantity INT NULL,' +
    ' Price DECIMAL NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTPostgreSQLTestConnection }

class procedure TTPostgreSQLTestConnection.DropTables;
begin
  FConnection.Execute('DROP TABLE IF EXISTS Orders');
  FConnection.Execute('DROP TABLE IF EXISTS Customers');
  FConnection.Execute('DROP TABLE IF EXISTS Countries');
  FConnection.Execute('DROP TABLE IF EXISTS Tasks');
  FConnection.Execute('DROP TABLE IF EXISTS TrackedUsers');
  FConnection.Execute('DROP TABLE IF EXISTS ValidatedItems');
  FConnection.Execute('DROP TABLE IF EXISTS FullValidation');
  FConnection.Execute('DROP TABLE IF EXISTS SimpleItems');
  FConnection.Execute('DROP TABLE IF EXISTS AllTypes');
  FConnection.Execute('DROP TABLE IF EXISTS NullablePrimitives');
end;

class procedure TTPostgreSQLTestConnection.DropSequences;
begin
  FConnection.Execute('DROP SEQUENCE IF EXISTS CustomersID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS CountriesID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS OrdersID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS TasksID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS TrackedUsersID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS ValidatedItemsID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS FullValidationID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS SimpleItemsID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS AllTypesID');
  FConnection.Execute('DROP SEQUENCE IF EXISTS NullablePrimitivesID');
end;

class procedure TTPostgreSQLTestConnection.CreateSequences;
begin
  FConnection.Execute(
    'CREATE SEQUENCE CustomersID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE CountriesID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE OrdersID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE TasksID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE TrackedUsersID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE ValidatedItemsID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE FullValidationID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE SimpleItemsID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE AllTypesID START 1');
  FConnection.Execute(
    'CREATE SEQUENCE NullablePrimitivesID START 1');
end;

class procedure TTPostgreSQLTestConnection.CreateTables;
begin
  FConnection.Execute(DDL_CUSTOMERS);
  FConnection.Execute(DDL_COUNTRIES);
  FConnection.Execute(DDL_ORDERS);
  FConnection.Execute(DDL_TASKS);
  FConnection.Execute(DDL_TRACKED_USERS);
  FConnection.Execute(DDL_VALIDATED_ITEMS);
  FConnection.Execute(DDL_FULL_VALIDATION);
  FConnection.Execute(DDL_SIMPLE_ITEMS);
  FConnection.Execute(DDL_ALL_TYPES);
  FConnection.Execute(DDL_NULLABLE_PRIMITIVES);
end;

class procedure TTPostgreSQLTestConnection.Initialize;
var
  LPort: Integer;
begin
  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  LPort := StrToIntDef(
    TTTestConfig.GetDatabaseParam('PostgreSQL', 'port'), 5432);
  TTPostgreSQLConnection.RegisterConnection(
    'TrysilPostgreSQLTests',
    TTTestConfig.GetDatabaseParam('PostgreSQL', 'host'),
    LPort,
    TTTestConfig.GetDatabaseParam('PostgreSQL', 'username'),
    TTTestConfig.GetDatabaseParam('PostgreSQL', 'password'),
    TTTestConfig.GetDatabaseParam('PostgreSQL', 'database'));
  FConnection := TTPostgreSQLConnection.Create('TrysilPostgreSQLTests');

  DropTables;
  DropSequences;
  CreateSequences;
  CreateTables;
end;

class procedure TTPostgreSQLTestConnection.Finalize;
begin
  if Assigned(FConnection) then
  begin
    DropTables;
    DropSequences;
    FConnection.Free;
  end;
end;

class function TTPostgreSQLTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
