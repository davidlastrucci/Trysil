(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.Oracle.Connection;

interface

uses
  System.SysUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.Oracle,

  Trysil.Tests.Config;

type

{ TTOracleTestConnection }

  TTOracleTestConnection = class
  strict private
    class var FConnection: TTOracleConnection;

    class procedure SafeExecute(const ASQL: String);
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
    ' ID NUMBER(9) NOT NULL,' +
    ' Name VARCHAR2(100),' +
    ' Email VARCHAR2(255),' +
    ' CountryID NUMBER(9) NULL,' +
    ' DeletedAt TIMESTAMP NULL,' +
    ' DeletedBy VARCHAR2(100),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_COUNTRIES =
    'CREATE TABLE Countries (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Name VARCHAR2(100),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_ORDERS =
    'CREATE TABLE Orders (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' CustomerID NUMBER(9) NOT NULL,' +
    ' Amount NUMBER(18,4) NOT NULL,' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE Tasks (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Title VARCHAR2(100),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' DeletedAt TIMESTAMP NULL,' +
    ' DeletedBy VARCHAR2(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE TrackedUsers (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Name VARCHAR2(100),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' CreatedAt TIMESTAMP NULL,' +
    ' CreatedBy VARCHAR2(100),' +
    ' UpdatedAt TIMESTAMP NULL,' +
    ' UpdatedBy VARCHAR2(100),' +
    ' PRIMARY KEY(ID))';

  DDL_VALIDATED_ITEMS =
    'CREATE TABLE ValidatedItems (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Name VARCHAR2(100),' +
    ' Code VARCHAR2(50),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_FULL_VALIDATION =
    'CREATE TABLE FullValidation (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Code VARCHAR2(50),' +
    ' Score NUMBER(9) NOT NULL,' +
    ' Quantity NUMBER(9) NOT NULL,' +
    ' Price NUMBER(18,4) NOT NULL,' +
    ' Discount NUMBER(9) NOT NULL,' +
    ' Weight NUMBER(18,4) NOT NULL,' +
    ' Phone VARCHAR2(20),' +
    ' Email VARCHAR2(255),' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_SIMPLE_ITEMS =
    'CREATE TABLE SimpleItems (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Name VARCHAR2(100),' +
    ' PRIMARY KEY(ID))';

  DDL_ALL_TYPES =
    'CREATE TABLE AllTypes (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' LargeNumber NUMBER(19) NOT NULL,' +
    ' IsActive BOOLEAN NOT NULL,' +
    ' BirthDate TIMESTAMP NOT NULL,' +
    ' UniqueID RAW(16) NOT NULL,' +
    ' Payload BLOB NOT NULL,' +
    ' OptLargeNumber NUMBER(19) NULL,' +
    ' OptIsActive BOOLEAN NULL,' +
    ' OptBirthDate TIMESTAMP NULL,' +
    ' OptUniqueID RAW(16) NULL,' +
    ' OptPayload BLOB NULL,' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE NullablePrimitives (' +
    ' ID NUMBER(9) NOT NULL,' +
    ' Description VARCHAR2(100) NULL,' +
    ' Quantity NUMBER(9) NULL,' +
    ' Price NUMBER(18,4) NULL,' +
    ' VersionID NUMBER(9) NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTOracleTestConnection }

class procedure TTOracleTestConnection.SafeExecute(const ASQL: String);
begin
  try
    FConnection.Execute(ASQL);
  except
    on E: Exception do
      ; // Object may not exist
  end;
end;

class procedure TTOracleTestConnection.DropTables;
begin
  SafeExecute('DROP TABLE Orders');
  SafeExecute('DROP TABLE Customers');
  SafeExecute('DROP TABLE Countries');
  SafeExecute('DROP TABLE Tasks');
  SafeExecute('DROP TABLE TrackedUsers');
  SafeExecute('DROP TABLE ValidatedItems');
  SafeExecute('DROP TABLE FullValidation');
  SafeExecute('DROP TABLE SimpleItems');
  SafeExecute('DROP TABLE AllTypes');
  SafeExecute('DROP TABLE NullablePrimitives');
end;

class procedure TTOracleTestConnection.DropSequences;
begin
  SafeExecute('DROP SEQUENCE CustomersID');
  SafeExecute('DROP SEQUENCE CountriesID');
  SafeExecute('DROP SEQUENCE OrdersID');
  SafeExecute('DROP SEQUENCE TasksID');
  SafeExecute('DROP SEQUENCE TrackedUsersID');
  SafeExecute('DROP SEQUENCE ValidatedItemsID');
  SafeExecute('DROP SEQUENCE FullValidationID');
  SafeExecute('DROP SEQUENCE SimpleItemsID');
  SafeExecute('DROP SEQUENCE AllTypesID');
  SafeExecute('DROP SEQUENCE NullablePrimitivesID');
end;

class procedure TTOracleTestConnection.CreateSequences;
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

class procedure TTOracleTestConnection.CreateTables;
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

class procedure TTOracleTestConnection.Initialize;
var
  LPort: Integer;
begin
  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  LPort := StrToIntDef(
    TTTestConfig.GetDatabaseParam('Oracle', 'port'), 1521);
  TTOracleConnection.RegisterConnection(
    'TrysilOracleTests',
    TTTestConfig.GetDatabaseParam('Oracle', 'host'),
    LPort,
    TTTestConfig.GetDatabaseParam('Oracle', 'username'),
    TTTestConfig.GetDatabaseParam('Oracle', 'password'),
    TTTestConfig.GetDatabaseParam('Oracle', 'database'));
  FConnection := TTOracleConnection.Create('TrysilOracleTests');

  DropTables;
  DropSequences;
  CreateSequences;
  CreateTables;
end;

class procedure TTOracleTestConnection.Finalize;
begin
  if Assigned(FConnection) then
  begin
    DropTables;
    DropSequences;
    FConnection.Free;
  end;
end;

class function TTOracleTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
