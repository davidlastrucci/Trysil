CREATE TABLE [dbo].[LogActions](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [LogDate] [datetime] NULL,
  [Action] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_LogActions] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [dbo].[LogActions] ADD CONSTRAINT [DF_LogActions_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [dbo].[LogActions] ADD CONSTRAINT [DF_LogActions_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [dbo].[LogActions] ADD CONSTRAINT [DF_LogActions_Action] DEFAULT (N'') FOR [Action]
ALTER TABLE [dbo].[LogActions] ADD CONSTRAINT [DF_LogActions_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[LogActionsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[LogRequests](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [LogDate] [datetime] NULL,
  [Uri] [nvarchar](255) NULL,
  [Params] [nvarchar](max) NULL,
  [MethodType] [nvarchar](255) NULL,
  [Content] [nvarchar](max) NULL,
  [Headers] [nvarchar](max) NULL,
  [RemoteIP] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_LogRequests] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_Uri] DEFAULT (N'') FOR [Uri]
ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_MethodType] DEFAULT (N'') FOR [MethodType]
ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_RemoteIP] DEFAULT (N'') FOR [RemoteIP]
ALTER TABLE [dbo].[LogRequests] ADD CONSTRAINT [DF_LogRequests_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[LogRequestsID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO

CREATE TABLE [dbo].[LogResponses](
  [ID] [int] NOT NULL,
  [TaskID] [nvarchar](50) NULL,
  [LogDate] [datetime] NULL,
  [Username] [nvarchar](255) NULL,
  [UserAreas] [nvarchar](max) NULL,
  [StatusCode] [smallint] NULL,
  [ContentType] [nvarchar](255) NULL,
  [ContentEncoding] [nvarchar](255) NULL,
  [Content] [nvarchar](max) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_LogResponses] PRIMARY KEY CLUSTERED ([ID] ASC)
)
GO

ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_ID] DEFAULT (0) FOR [ID]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_TaskID] DEFAULT (N'') FOR [TaskID]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_Username] DEFAULT (N'') FOR [Username]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_StatusCode] DEFAULT ((0)) FOR [StatusCode]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_ContentType] DEFAULT (N'') FOR [ContentType]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_ContentEncoding] DEFAULT (N'') FOR [ContentEncoding]
ALTER TABLE [dbo].[LogResponses] ADD CONSTRAINT [DF_LogResponses_VersionID] DEFAULT (0) FOR [VersionID]
GO

CREATE SEQUENCE [dbo].[LogResponsesID]
 AS [int]
 START WITH 1
 INCREMENT BY 1
GO