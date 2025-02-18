﻿CREATE TABLE [dbo].[T0090_EMP_ASSET_DETAIL] (
    [Emp_Asset_ID]  NUMERIC (18)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NOT NULL,
    [Emp_ID]        NUMERIC (18)  NOT NULL,
    [Asset_ID]      NUMERIC (18)  NOT NULL,
    [Model_No]      VARCHAR (20)  NOT NULL,
    [Issue_Date]    DATETIME      NOT NULL,
    [Return_Date]   DATETIME      NULL,
    [Asset_Comment] VARCHAR (150) NULL,
    CONSTRAINT [PK_T0090_EMP_ASSET_DETAIL] PRIMARY KEY CLUSTERED ([Emp_Asset_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_EMP_ASSET_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_EMP_ASSET_DETAIL_T0040_ASSET_MASTER] FOREIGN KEY ([Asset_ID]) REFERENCES [dbo].[T0040_ASSET_MASTER] ([Asset_ID]),
    CONSTRAINT [FK_T0090_EMP_ASSET_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

