(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SqlServer.Connection;

interface

uses
  System.SysUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SqlServer,

  Trysil.Tests.Config;

type

{ TTSqlServerTestConnection }

  TTSqlServerTestConnection = class
  strict private
    class var FConnection: TTSqlServerConnection;

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
    ' Name NVARCHAR(100),' +
    ' Email NVARCHAR(255),' +
    ' CountryID INT NULL,' +
    ' DeletedAt DATETIME NULL,' +
    ' DeletedBy NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_COUNTRIES =
    'CREATE TABLE Countries (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_ORDERS =
    'CREATE TABLE Orders (' +
    ' ID INT NOT NULL,' +
    ' CustomerID INT NOT NULL,' +
    ' Amount FLOAT NOT NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE Tasks (' +
    ' ID INT NOT NULL,' +
    ' Title NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' DeletedAt DATETIME NULL,' +
    ' DeletedBy NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE TrackedUsers (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' CreatedAt DATETIME NULL,' +
    ' CreatedBy NVARCHAR(100),' +
    ' UpdatedAt DATETIME NULL,' +
    ' UpdatedBy NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_VALIDATED_ITEMS =
    'CREATE TABLE ValidatedItems (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' Code NVARCHAR(50),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_FULL_VALIDATION =
    'CREATE TABLE FullValidation (' +
    ' ID INT NOT NULL,' +
    ' Code NVARCHAR(50),' +
    ' Score INT NOT NULL,' +
    ' Quantity INT NOT NULL,' +
    ' Price FLOAT NOT NULL,' +
    ' Discount INT NOT NULL,' +
    ' Weight FLOAT NOT NULL,' +
    ' Phone NVARCHAR(20),' +
    ' Email NVARCHAR(255),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_SIMPLE_ITEMS =
    'CREATE TABLE SimpleItems (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_ALL_TYPES =
    'CREATE TABLE AllTypes (' +
    ' ID INT NOT NULL,' +
    ' LargeNumber BIGINT NOT NULL,' +
    ' IsActive BIT NOT NULL,' +
    ' BirthDate DATETIME NOT NULL,' +
    ' UniqueID UNIQUEIDENTIFIER NOT NULL,' +
    ' Payload VARBINARY(MAX) NOT NULL,' +
    ' OptLargeNumber BIGINT NULL,' +
    ' OptIsActive BIT NULL,' +
    ' OptBirthDate DATETIME NULL,' +
    ' OptUniqueID UNIQUEIDENTIFIER NULL,' +
    ' OptPayload VARBINARY(MAX) NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE NullablePrimitives (' +
    ' ID INT NOT NULL,' +
    ' Description NVARCHAR(100) NULL,' +
    ' Quantity INT NULL,' +
    ' Price FLOAT NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTSqlServerTestConnection }

class procedure TTSqlServerTestConnection.DropTables;
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

class procedure TTSqlServerTestConnection.DropSequences;
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

class procedure TTSqlServerTestConnection.CreateSequences;
begin
  FConnection.Execute(
    'CREATE SEQUENCE CustomersID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE CountriesID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE OrdersID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE TasksID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE TrackedUsersID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE ValidatedItemsID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE FullValidationID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE SimpleItemsID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE AllTypesID AS int START WITH 1 INCREMENT BY 1');
  FConnection.Execute(
    'CREATE SEQUENCE NullablePrimitivesID AS int START WITH 1 INCREMENT BY 1');
end;

class procedure TTSqlServerTestConnection.CreateTables;
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

class procedure TTSqlServerTestConnection.Initialize;
begin
  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  TTSqlServerConnection.RegisterConnection(
    'TrysilSqlServerTests',
    TTTestConfig.GetDatabaseParam('SqlServer', 'host'),
    TTTestConfig.GetDatabaseParam('SqlServer', 'username'),
    TTTestConfig.GetDatabaseParam('SqlServer', 'password'),
    TTTestConfig.GetDatabaseParam('SqlServer', 'database'));
  FConnection := TTSqlServerConnection.Create('TrysilSqlServerTests');

  DropSequences;
  CreateSequences;
  DropTables;
  CreateTables;
end;

class procedure TTSqlServerTestConnection.Finalize;
begin
  DropTables;
  DropSequences;
  FConnection.Free;
end;

class function TTSqlServerTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
