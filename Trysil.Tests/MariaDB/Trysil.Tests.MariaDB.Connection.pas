(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.MariaDB.Connection;

interface

uses
  System.SysUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.MariaDB,

  Trysil.Tests.Config;

type

{ TTMariaDBTestConnection }

  TTMariaDBTestConnection = class
  strict private
    class var FConnection: TTMariaDBConnection;

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
    ' DeletedAt DATETIME NULL,' +
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
    ' Amount DECIMAL(18,4) NOT NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE Tasks (' +
    ' ID INT NOT NULL,' +
    ' Title VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' DeletedAt DATETIME NULL,' +
    ' DeletedBy VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE TrackedUsers (' +
    ' ID INT NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' CreatedAt DATETIME NULL,' +
    ' CreatedBy VARCHAR(100),' +
    ' UpdatedAt DATETIME NULL,' +
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
    ' Price DECIMAL(18,4) NOT NULL,' +
    ' Discount INT NOT NULL,' +
    ' Weight DECIMAL(18,4) NOT NULL,' +
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
    ' BirthDate DATETIME NOT NULL,' +
    ' UniqueID CHAR(38) NOT NULL,' +
    ' Payload BLOB NOT NULL,' +
    ' OptLargeNumber BIGINT NULL,' +
    ' OptIsActive BOOLEAN NULL,' +
    ' OptBirthDate DATETIME NULL,' +
    ' OptUniqueID CHAR(38) NULL,' +
    ' OptPayload BLOB NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE NullablePrimitives (' +
    ' ID INT NOT NULL,' +
    ' Description VARCHAR(100) NULL,' +
    ' Quantity INT NULL,' +
    ' Price DECIMAL(18,4) NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTMariaDBTestConnection }

class procedure TTMariaDBTestConnection.DropTables;
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

class procedure TTMariaDBTestConnection.DropSequences;
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

class procedure TTMariaDBTestConnection.CreateSequences;
begin
  FConnection.Execute('CREATE SEQUENCE CustomersID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE CountriesID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE OrdersID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE TasksID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE TrackedUsersID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE ValidatedItemsID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE FullValidationID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE SimpleItemsID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE AllTypesID START WITH 1');
  FConnection.Execute('CREATE SEQUENCE NullablePrimitivesID START WITH 1');
end;

class procedure TTMariaDBTestConnection.CreateTables;
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

class procedure TTMariaDBTestConnection.Initialize;
var
  LPort: Integer;
begin
  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  LPort := StrToIntDef(
    TTTestConfig.GetDatabaseParam('MariaDB', 'port'), 3306);
  TTMariaDBConnection.RegisterConnection(
    'TrysilMariaDBTests',
    TTTestConfig.GetDatabaseParam('MariaDB', 'host'),
    LPort,
    TTTestConfig.GetDatabaseParam('MariaDB', 'username'),
    TTTestConfig.GetDatabaseParam('MariaDB', 'password'),
    TTTestConfig.GetDatabaseParam('MariaDB', 'database'));
  FConnection := TTMariaDBConnection.Create('TrysilMariaDBTests');

  DropTables;
  DropSequences;
  CreateSequences;
  CreateTables;
end;

class procedure TTMariaDBTestConnection.Finalize;
begin
  if Assigned(FConnection) then
  begin
    DropTables;
    DropSequences;
    FConnection.Free;
  end;
end;

class function TTMariaDBTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
