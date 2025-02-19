CREATE TABLE [dbo].[T0120_Asset_Approval] (
    [Asset_Approval_ID]        NUMERIC (18)   NOT NULL,
    [Asset_Application_ID]     NUMERIC (18)   NULL,
    [Cmp_ID]                   NUMERIC (18)   NOT NULL,
    [Emp_ID]                   NUMERIC (18)   NULL,
    [Branch_ID]                NUMERIC (18)   NULL,
    [Receiver_ID]              NUMERIC (18)   NULL,
    [Comments]                 VARCHAR (1000) NULL,
    [Status]                   VARCHAR (50)   NOT NULL,
    [LoginId]                  NUMERIC (18)   NOT NULL,
    [System_date]              DATETIME       NOT NULL,
    [Asset_Approval_Date]      DATETIME       NULL,
    [Allocation_Date]          DATETIME       NULL,
    [Applied_by]               NUMERIC (18)   NULL,
    [Dept_Id]                  NUMERIC (18)   NULL,
    [Application_Type]         NUMERIC (18)   NULL,
    [Transfer_Emp_Id]          NUMERIC (18)   NULL,
    [Transfer_Branch_Id]       NUMERIC (18)   NULL,
    [Transfer_Dept_Id]         NUMERIC (18)   NULL,
    [Branch_For_Dept]          INT            NULL,
    [Transfer_Branch_For_Dept] INT            NULL,
    CONSTRAINT [PK_T0120_Asset_Approval] PRIMARY KEY CLUSTERED ([Asset_Approval_ID] ASC) WITH (FILLFACTOR = 80)
);

