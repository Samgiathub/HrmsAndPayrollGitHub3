CREATE TABLE [dbo].[T0100_Asset_Application] (
    [Asset_Application_ID] NUMERIC (18) NOT NULL,
    [Cmp_ID]               NUMERIC (18) NOT NULL,
    [Emp_ID]               NUMERIC (18) NOT NULL,
    [Branch_ID]            NUMERIC (18) NOT NULL,
    [Application_date]     DATETIME     NOT NULL,
    [Application_code]     VARCHAR (50) NOT NULL,
    [Asset_ID]             VARCHAR (50) NOT NULL,
    [Remarks]              VARCHAR (50) NOT NULL,
    [LoginId]              NUMERIC (18) NOT NULL,
    [System_date]          DATETIME     NOT NULL,
    [Application_status]   CHAR (1)     NULL,
    [Application_Type]     NUMERIC (1)  NULL,
    [AssetM_Id]            VARCHAR (20) NULL,
    [Dept_Id]              NUMERIC (18) NULL,
    CONSTRAINT [PK_T0100_Asset_Application] PRIMARY KEY CLUSTERED ([Asset_Application_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_Asset_Application_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

