CREATE TABLE [dbo].[T0140_Asset_Transaction] (
    [Asset_Tran_Id]     NUMERIC (18)    NOT NULL,
    [Cmp_Id]            NUMERIC (18)    NOT NULL,
    [Asset_Approval_Id] NUMERIC (18)    NULL,
    [Emp_Id]            NUMERIC (18)    NULL,
    [AssetM_Id]         NUMERIC (18)    NULL,
    [Asset_Opening]     NUMERIC (18, 2) NOT NULL,
    [Issue_Amount]      NUMERIC (18, 2) NOT NULL,
    [Receive_Amount]    NUMERIC (18, 2) NOT NULL,
    [Asset_Closing]     NUMERIC (18, 2) NOT NULL,
    [For_Date]          DATETIME        NULL,
    [Sal_Tran_Id]       NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0140_Asset_Transaction] PRIMARY KEY CLUSTERED ([Asset_Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0140_Asset_Transaction_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0140_Asset_Transaction_T0040_Asset_Details] FOREIGN KEY ([AssetM_Id]) REFERENCES [dbo].[T0040_Asset_Details] ([AssetM_ID]),
    CONSTRAINT [FK_T0140_Asset_Transaction_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0140_Asset_Transaction_T0120_Asset_Approval] FOREIGN KEY ([Asset_Approval_Id]) REFERENCES [dbo].[T0120_Asset_Approval] ([Asset_Approval_ID])
);

