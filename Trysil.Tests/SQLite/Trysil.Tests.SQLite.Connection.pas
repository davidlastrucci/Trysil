(*

  Trysil
  Copyright (c) David Lastrucci
  All rights reserved

  Trysil - Operation ORM (World War II)
  http://codenames.info/operation/orm/

*)
unit Trysil.Tests.SQLite.Connection;

interface

uses
  System.SysUtils,
  System.IOUtils,

  Trysil.Data,
  Trysil.Data.FireDAC.ConnectionPool,
  Trysil.Data.FireDAC.SQLite;

type

{ TTSQLiteTestConnection }

  TTSQLiteTestConnection = class
  strict private
    class var FDatabaseFile: String;
    class var FConnection: TTSQLiteConnection;
  public
    class procedure Initialize;
    class procedure Finalize;

    class function Connection: TTConnection;
  end;

implementation

const
  DDL_CUSTOMERS =
    'CREATE TABLE IF NOT EXISTS Customers (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' Email NVARCHAR(255),' +
    ' CountryID INT NULL,' +
    ' DeletedAt DATETIME NULL,' +
    ' DeletedBy NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_COUNTRIES =
    'CREATE TABLE IF NOT EXISTS Countries (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_ORDERS =
    'CREATE TABLE IF NOT EXISTS Orders (' +
    ' ID INT NOT NULL,' +
    ' CustomerID INT NOT NULL,' +
    ' Amount DOUBLE NOT NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_TASKS =
    'CREATE TABLE IF NOT EXISTS Tasks (' +
    ' ID INT NOT NULL,' +
    ' Title NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' DeletedAt DATETIME NULL,' +
    ' DeletedBy NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_TRACKED_USERS =
    'CREATE TABLE IF NOT EXISTS TrackedUsers (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' VersionID INT NOT NULL,' +
    ' CreatedAt DATETIME NULL,' +
    ' CreatedBy NVARCHAR(100),' +
    ' UpdatedAt DATETIME NULL,' +
    ' UpdatedBy NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_VALIDATED_ITEMS =
    'CREATE TABLE IF NOT EXISTS ValidatedItems (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' Code NVARCHAR(50),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_FULL_VALIDATION =
    'CREATE TABLE IF NOT EXISTS FullValidation (' +
    ' ID INT NOT NULL,' +
    ' Code NVARCHAR(50),' +
    ' Score INT NOT NULL,' +
    ' Quantity INT NOT NULL,' +
    ' Price DOUBLE NOT NULL,' +
    ' Discount INT NOT NULL,' +
    ' Weight DOUBLE NOT NULL,' +
    ' Phone NVARCHAR(20),' +
    ' Email NVARCHAR(255),' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_SIMPLE_ITEMS =
    'CREATE TABLE IF NOT EXISTS SimpleItems (' +
    ' ID INT NOT NULL,' +
    ' Name NVARCHAR(100),' +
    ' PRIMARY KEY(ID))';

  DDL_ALL_TYPES =
    'CREATE TABLE IF NOT EXISTS AllTypes (' +
    ' ID INT NOT NULL,' +
    ' LargeNumber BIGINT NOT NULL,' +
    ' IsActive BOOLEAN NOT NULL,' +
    ' BirthDate DATETIME NOT NULL,' +
    ' UniqueID GUID NOT NULL,' +
    ' Payload BLOB NOT NULL,' +
    ' OptLargeNumber BIGINT NULL,' +
    ' OptIsActive BOOLEAN NULL,' +
    ' OptBirthDate DATETIME NULL,' +
    ' OptUniqueID GUID NULL,' +
    ' OptPayload BLOB NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

  DDL_NULLABLE_PRIMITIVES =
    'CREATE TABLE IF NOT EXISTS NullablePrimitives (' +
    ' ID INT NOT NULL,' +
    ' Description NVARCHAR(100) NULL,' +
    ' Quantity INT NULL,' +
    ' Price DOUBLE NULL,' +
    ' VersionID INT NOT NULL,' +
    ' PRIMARY KEY(ID))';

{ TTSQLiteTestConnection }

class procedure TTSQLiteTestConnection.Initialize;
begin
  FDatabaseFile := TPath.GetTempFileName();
  if TFile.Exists(FDatabaseFile) then
    TFile.Delete(FDatabaseFile);

  TTFireDACConnectionPool.Instance.Config.Enabled := False;
  TTSQLiteConnection.RegisterConnection('TrysilTests', FDatabaseFile);
  FConnection := TTSQLiteConnection.Create('TrysilTests');

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

class procedure TTSQLiteTestConnection.Finalize;
begin
  FConnection.Free;
  if TFile.Exists(FDatabaseFile) then
    TFile.Delete(FDatabaseFile);
end;

class function TTSQLiteTestConnection.Connection: TTConnection;
begin
  result := FConnection;
end;

end.
