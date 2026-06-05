CREATE SEQUENCE [dbo].[CustomersID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[Customers](
  [ID] [int] NOT NULL,
  [CompanyName] [nvarchar](100) NULL,
  [Address] [nvarchar](100) NULL,
  [City] [nvarchar](100) NULL,
  [Region] [nvarchar](100) NULL,
  [PostalCode] [nvarchar](20) NULL,
  [Country] [nvarchar](100) NULL,
  [Email] [nvarchar](255) NULL,
  [CreatedAt] [datetime] NULL,
  [CreatedBy] [nvarchar](100) NULL,
  [UpdatedAt] [datetime] NULL,
  [UpdatedBy] [nvarchar](100) NULL,
  [DeletedAt] [datetime] NULL,
  [DeletedBy] [nvarchar](100) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_CompanyName] DEFAULT (N'') FOR [CompanyName]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_Address] DEFAULT (N'') FOR [Address]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_City] DEFAULT (N'') FOR [City]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_Region] DEFAULT (N'') FOR [Region]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_PostalCode] DEFAULT (N'') FOR [PostalCode]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_Country] DEFAULT (N'') FOR [Country]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_Email] DEFAULT (N'') FOR [Email]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_CreatedBy] DEFAULT (N'') FOR [CreatedBy]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_UpdatedBy] DEFAULT (N'') FOR [UpdatedBy]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_DeletedBy] DEFAULT (N'') FOR [DeletedBy]
ALTER TABLE [dbo].[Customers] ADD CONSTRAINT [DF_Customers_VersionID] DEFAULT ((0)) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[BrandsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[Brands](
  [ID] [int] NOT NULL,
  [Description] [nvarchar](100) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Brands] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Brands] ADD CONSTRAINT [DF_Brands_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[Brands] ADD CONSTRAINT [DF_Brands_Description] DEFAULT (N'') FOR [Description]
ALTER TABLE [dbo].[Brands] ADD CONSTRAINT [DF_Brands_VersionID] DEFAULT ((0)) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[ProductsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[Products](
  [ID] [int] NOT NULL,
  [BrandID] [int] NULL,
  [Description] [nvarchar](100) NULL,
  [Price] [float] NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_BrandID] DEFAULT ((0)) FOR [BrandID]
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_Description] DEFAULT (N'') FOR [Description]
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_Price] DEFAULT ((0)) FOR [Price]
ALTER TABLE [dbo].[Products] ADD CONSTRAINT [DF_Products_VersionID] DEFAULT ((0)) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[OrdersID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[Orders](
  [ID] [int] NOT NULL,
  [OrderDate] [date] NULL,
  [CustomerID] [int] NULL,
  [Cashed] [bit] NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_CustomerID] DEFAULT ((0)) FOR [CustomerID]
ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_Cashed] DEFAULT ((0)) FOR [Cashed]
ALTER TABLE [dbo].[Orders] ADD CONSTRAINT [DF_Orders_VersionID] DEFAULT ((0)) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[OrderDetailsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[OrderDetails](
  [ID] [int] NOT NULL,
  [OrderID] [int] NULL,
  [ProductID] [int] NULL,
  [Quantity] [float] NULL,
  [Price] [float] NULL,
  [Produced] [datetime] NULL,
  [Delivered] [datetime] NULL,
  [Cashed] [datetime] NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED ([ID] ASC) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_OrderID] DEFAULT ((0)) FOR [OrderID]
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_ProductID] DEFAULT ((0)) FOR [ProductID]
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_Quantity] DEFAULT ((0)) FOR [Quantity]
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_Price] DEFAULT ((0)) FOR [Price]
ALTER TABLE [dbo].[OrderDetails] ADD CONSTRAINT [DF_OrderDetails_VersionID] DEFAULT ((0)) FOR [VersionID]
GO

CREATE VIEW [dbo].[ProductsToBeProduced] AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE CS.Produced IS NULL
GO

CREATE VIEW [dbo].[ProductsToBeDelivered] AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE NOT CS.Produced IS NULL AND CS.Delivered IS NULL
GO

CREATE VIEW [dbo].[ProductsToBeCashed] AS
  SELECT CS.ID, C.OrderDate, C.CustomerID, CS.ProductID, P.Description, CS.Quantity, CS.Price
  FROM Orders C
  INNER JOIN OrderDetails CS ON CS.OrderID = C.ID
  LEFT JOIN Products P ON P.ID = CS.ProductID
  WHERE NOT CS.Produced IS NULL AND NOT CS.Delivered IS NULL AND (C.Cashed = 0 AND CS.Cashed IS NULL)
GO

CREATE NONCLUSTERED INDEX [IDX_Customers_City] ON [dbo].[Customers]([City] ASC) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_Customers_DeletedAt] ON [dbo].[Customers]([DeletedAt] ASC) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_Products_BrandID] ON [dbo].[Products]([BrandID] ASC) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_Orders_CustomerID] ON [dbo].[Orders]([CustomerID] ASC) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_OrderDetails_OrderID] ON [dbo].[OrderDetails]([OrderID] ASC) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IDX_OrderDetails_ProductID] ON [dbo].[OrderDetails]([ProductID] ASC) ON [PRIMARY]
GO