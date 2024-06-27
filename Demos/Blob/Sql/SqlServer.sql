CREATE SEQUENCE ImagesID
  AS int
  START WITH 1
  INCREMENT BY 1;

CREATE TABLE Images(
  ID int NOT NULL,
  Name nvarchar(100) NOT NULL,
  Image varbinary(max) NULL,
  VersionID int NOT NULL,
  CONSTRAINT PK_Images PRIMARY KEY CLUSTERED (ID ASC)
);
