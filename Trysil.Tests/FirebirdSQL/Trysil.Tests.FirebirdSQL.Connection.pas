(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.FirebirdSQL.Connection;

interface

uses
  System.SysUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.FirebirdSQL,

  Trysil.Tests.Config;

type

{ TTFirebirdSQLTestConnection }

  TTFirebirdSQLTestConnection = class
  strict private
    class var FConnection: TTFirebirdSQLConnection;

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
    ' ID INTEGER NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' Email VARCHAR(255),' +
    ' CountryID INTEGER,' +
    ' DeletedAt TIMESTAMP,' +
    ' DeletedBy VARCHAR(100),' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_COUNTRIES =
    'CREATE TABLE Countries (' +
    ' ID INTEGER NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_ORDERS =
    'CREATE TABLE Orders (' +
    ' ID INTEGER NOT NULL,' +
    ' CustomerID INTEGER NOT NULL,' +
    ' Amount FLOAT NOT NULL,' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE Tasks (' +
    ' ID INTEGER NOT NULL,' +
    ' Title VARCHAR(100),' +
    ' VersionID INTEGER NOT NULL,' +
    ' DeletedAt TIMESTAMP,' +
    ' DeletedBy VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE TrackedUsers (' +
    ' ID INTEGER NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' VersionID INTEGER NOT NULL,' +
    ' CreatedAt TIMESTAMP,' +
    ' CreatedBy VARCHAR(100),' +
    ' UpdatedAt TIMESTAMP,' +
    ' UpdatedBy VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_VALIDATED_ITEMS =
    'CREATE TABLE ValidatedItems (' +
    ' ID INTEGER NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' Code VARCHAR(50),' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_FULL_VALIDATION =
    'CREATE TABLE FullValidation (' +
    ' ID INTEGER NOT NULL,' +
    ' Code VARCHAR(50),' +
    ' Score INTEGER NOT NULL,' +
    ' Quantity INTEGER NOT NULL,' +
    ' Price FLOAT NOT NULL,' +
    ' Discount INTEGER NOT NULL,' +
    ' Weight FLOAT NOT NULL,' +
    ' Phone VARCHAR(20),' +
    ' Email VARCHAR(255),' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_SIMPLE_ITEMS =
    'CREATE TABLE SimpleItems (' +
    ' ID INTEGER NOT NULL,' +
    ' Name VARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_ALL_TYPES =
    'CREATE TABLE AllTypes (' +
    ' ID INTEGER NOT NULL,' +
    ' LargeNumber BIGINT NOT NULL,' +
    ' IsActive BOOLEAN NOT NULL,' +
    ' BirthDate TIMESTAMP NOT NULL,' +
    ' UniqueID CHAR(16) CHARACTER SET OCTETS NOT NULL,' +
    ' Payload BLOB SUB_TYPE 0 NOT NULL,' +
    ' OptLargeNumber BIGINT,' +
    ' OptIsActive BOOLEAN,' +
    ' OptBirthDate TIMESTAMP,' +
    ' OptUniqueID CHAR(16) CHARACTER SET OCTETS,' +
    ' OptPayload BLOB SUB_TYPE 0,' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE NullablePrimitives (' +
    ' ID INTEGER NOT NULL,' +
    ' Description VARCHAR(100),' +
    ' Quantity INTEGER,' +
    ' Price FLOAT,' +
    ' VersionID INTEGER NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTFirebirdSQLTestConnection }

class procedure TTFirebirdSQLTestConnection.SafeExecute(const ASQL: String);
begin
  try
    FConnection.Execute(ASQL);
  except
    on E: Exception do
      ; // Object may not exist
  end;
end;

class procedure TTFirebirdSQLTestConnection.DropTables;
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

class procedure TTFirebirdSQLTestConnection.DropSequences;
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

class procedure TTFirebirdSQLTestConnection.CreateSequences;
begin
  FConnection.Execute('CREATE SEQUENCE CustomersID');
  FConnection.Execute('CREATE SEQUENCE CountriesID');
  FConnection.Execute('CREATE SEQUENCE OrdersID');
  FConnection.Execute('CREATE SEQUENCE TasksID');
  FConnection.Execute('CREATE SEQUENCE TrackedUsersID');
  FConnection.Execute('CREATE SEQUENCE ValidatedItemsID');
  FConnection.Execute('CREATE SEQUENCE FullValidationID');
  FConnection.Execute('CREATE SEQUENCE SimpleItemsID');
  FConnection.Execute('CREATE SEQUENCE AllTypesID');
  FConnection.Execute('CREATE SEQUENCE NullablePrimitivesID');
end;

class procedure TTFirebirdSQLTestConnection.CreateTables;
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

class procedure TTFirebirdSQLTestConnection.Initialize;
begin
  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  TTFirebirdSQLConnection.RegisterConnection(
    'TrysilFirebirdSQLTests',
    TTTestConfig.GetDatabaseParam('FirebirdSQL', 'host'),
    TTTestConfig.GetDatabaseParam('FirebirdSQL', 'username'),
    TTTestConfig.GetDatabaseParam('FirebirdSQL', 'password'),
    TTTestConfig.GetDatabaseParam('FirebirdSQL', 'database'));
  FConnection := TTFirebirdSQLConnection.Create('TrysilFirebirdSQLTests');

  DropTables;
  DropSequences;
  CreateSequences;
  CreateTables;
end;

class procedure TTFirebirdSQLTestConnection.Finalize;
begin
  if Assigned(FConnection) then
  begin
    DropTables;
    DropSequences;
    FConnection.Free;
  end;
end;

class function TTFirebirdSQLTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
