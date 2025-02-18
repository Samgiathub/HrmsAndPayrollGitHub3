﻿CREATE TABLE [dbo].[T0040_PROJECT_MASTER] (
    [Prj_ID]    NUMERIC (18)  NOT NULL,
    [Prj_name]  NVARCHAR (50) NOT NULL,
    [Cmp_ID]    NUMERIC (18)  NOT NULL,
    [Prj_Group] VARCHAR (100) NULL,
    [Prj_Price] NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_PROJECT_MASTER] PRIMARY KEY CLUSTERED ([Prj_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_PROJECT_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

