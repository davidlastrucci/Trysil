CREATE SCHEMA [log]
GO

CREATE TABLE [log].[Actions](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [Date] [datetime] NULL,
  [Action] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Actions] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [log].[Actions] ADD CONSTRAINT [DF_Actions_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [log].[Actions] ADD CONSTRAINT [DF_Actions_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [log].[Actions] ADD CONSTRAINT [DF_Actions_Action] DEFAULT (N'') FOR [Action]
ALTER TABLE [log].[Actions] ADD CONSTRAINT [DF_Actions_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [log].[ActionsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [log].[Requests](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [Date] [datetime] NULL,
  [Uri] [nvarchar](255) NULL,
  [Params] [nvarchar](max) NULL,
  [MethodType] [nvarchar](255) NULL,
  [Content] [nvarchar](max) NULL,
  [Headers] [nvarchar](max) NULL,
  [RemoteIP] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Requests] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_Uri] DEFAULT (N'') FOR [Uri]
ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_MethodType] DEFAULT (N'') FOR [MethodType]
ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_RemoteIP] DEFAULT (N'') FOR [RemoteIP]
ALTER TABLE [log].[Requests] ADD CONSTRAINT [DF_Requests_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [log].[RequestsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [log].[Responses](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [Date] [datetime] NULL,
  [Username] [nvarchar](255) NULL,
  [UserAreas] [nvarchar](max) NULL,
  [StatusCode] [smallint] NULL,
  [ContentType] [nvarchar](255) NULL,
  [ContentEncoding] [nvarchar](255) NULL,
  [Content] [nvarchar](max) NULL,
  [BinaryContent] [nvarchar](max) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_Responses] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_Username] DEFAULT (N'') FOR [Username]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_StatusCode] DEFAULT ((0)) FOR [StatusCode]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_ContentType] DEFAULT (N'') FOR [ContentType]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_ContentEncoding] DEFAULT (N'') FOR [ContentEncoding]
ALTER TABLE [log].[Responses] ADD CONSTRAINT [DF_Responses_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [log].[ResponsesID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO