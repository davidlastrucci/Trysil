CREATE TABLE IF NOT EXISTS Customers (
  ID INTEGER NOT NULL,
  CompanyName VARCHAR(100) DEFAULT '',
  Address VARCHAR(100) DEFAULT '',
  City VARCHAR(100) DEFAULT '',
  Region VARCHAR(100) DEFAULT '',
  PostalCode VARCHAR(20) DEFAULT '',
  Country VARCHAR(100) DEFAULT '',
  Email VARCHAR(255) DEFAULT '',
  CreatedAt DATETIME,
  CreatedBy VARCHAR(100) DEFAULT '',
  UpdatedAt DATETIME,
  UpdatedBy VARCHAR(100) DEFAULT '',
  DeletedAt DATETIME,
  DeletedBy VARCHAR(100) DEFAULT '',
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(ID)
);

CREATE TABLE IF NOT EXISTS Brands (
  ID INTEGER NOT NULL,
  Description VARCHAR(100) DEFAULT '',
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(ID)
);

CREATE TABLE IF NOT EXISTS Products (
  ID INTEGER NOT NULL,
  BrandID INTEGER DEFAULT 0,
  Description VARCHAR(100) DEFAULT '',
  Price FLOAT DEFAULT 0,
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(ID)
);

CREATE TABLE IF NOT EXISTS Orders (
  ID INTEGER NOT NULL,
  OrderDate DATE,
  CustomerID INTEGER DEFAULT 0,
  Cashed INTEGER DEFAULT 0,
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(ID)
);

CREATE TABLE IF NOT EXISTS OrderDetails (
  ID INTEGER NOT NULL,
  OrderID INTEGER DEFAULT 0,
  ProductID INTEGER DEFAULT 0,
  Quantity FLOAT DEFAULT 0,
  Price FLOAT DEFAULT 0,
  Produced DATETIME,
  Delivered DATETIME,
  Cashed DATETIME,
  VersionID INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(ID)
);

CREATE VIEW IF NOT EXISTS ProductsToBeProduced AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE CS.Produced IS NULL;

CREATE VIEW IF NOT EXISTS ProductsToBeDelivered AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE CS.Produced IS NOT NULL AND CS.Delivered IS NULL;

CREATE VIEW IF NOT EXISTS ProductsToBeCashed AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE CS.Produced IS NOT NULL AND CS.Delivered IS NOT NULL AND (C.Cashed = 0 AND CS.Cashed IS NULL);

CREATE INDEX IF NOT EXISTS IDX_Customers_City ON Customers(City);
CREATE INDEX IF NOT EXISTS IDX_Customers_DeletedAt ON Customers(DeletedAt);
CREATE INDEX IF NOT EXISTS IDX_Products_BrandID ON Products(BrandID);
CREATE INDEX IF NOT EXISTS IDX_Orders_CustomerID ON Orders(CustomerID);
CREATE INDEX IF NOT EXISTS IDX_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE INDEX IF NOT EXISTS IDX_OrderDetails_ProductID ON OrderDetails(ProductID);
