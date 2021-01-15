<p align="center">
  <img width="300" height="115" src="https://github.com/davidlastrucci/Trysil/blob/master/Docs/Trysil.png" title="Trysil - Operation ORM">
</p>

# Trysil
> **Trysil**<br>
> *Copyright © [David Lastrucci](https://www.lastrucci.net/)*<br>
> *All rights reserved*<br>
> <br>
> *Trysil* - Operation ORM (World War II)<br>
> http://codenames.info/operation/orm/

## Design database
### Sequence
<pre>
CREATE SEQUENCE [dbo].[PersonalDataID] 
  AS [int]
  START WITH 1
  INCREMENT BY 1
</pre>

### Table
<pre>
CREATE TABLE [dbo].[PersonalData](
  [ID] [int] NOT NULL,
  [Firstname] [nvarchar](30) NULL,
  [Lastname] [nvarchar](30) NULL,
  [Company] [nvarchar](50) NULL,
  [Email] [nvarchar](255) NULL,
  [VersionID] [int] NOT NULL,
  CONSTRAINT [PK_PersonalData] PRIMARY KEY CLUSTERED([ID] ASC)
)
</pre>

### Constraints
<pre>
ALTER TABLE [dbo].[PersonalData] ADD CONSTRAINT [DF_PersonalData_ID] DEFAULT ((0)) FOR [ID]
ALTER TABLE [dbo].[PersonalData] ADD CONSTRAINT [DF_PersonalData_Firstname] DEFAULT (N'') FOR [Firstname]
ALTER TABLE [dbo].[PersonalData] ADD CONSTRAINT [DF_PersonalData_Lastname] DEFAULT (N'') FOR [Lastname]
ALTER TABLE [dbo].[PersonalData] ADD CONSTRAINT [DF_PersonalData_Company] DEFAULT (N'') FOR [Company]
ALTER TABLE [dbo].[PersonalData] ADD CONSTRAINT [DF_PersonalData_Email] DEFAULT (N'') FOR [Email]
ALTER TABLE [dbo].[PersonalData]ADD CONSTRAINT [DF_PersonalData_VersionID] DEFAULT ((0)) FOR [VersionID]
</pre>

---
<p>
  <a href="https://www.lastrucci.net/">
    <img width="400" height="100" src="https://www.lastrucci.net/images/badge.small.png" title="https://www.lastrucci.net/">
  </a>
</p>
