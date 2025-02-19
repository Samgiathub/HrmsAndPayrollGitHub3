CREATE TABLE [dbo].[T0120_AR_Approval] (
    [AR_Apr_ID]          NUMERIC (18)    NOT NULL,
    [AR_APP_ID]          NUMERIC (18)    NULL,
    [Cmp_ID]             NUMERIC (18)    NOT NULL,
    [Emp_ID]             NUMERIC (18)    NOT NULL,
    [Increment_Id]       NUMERIC (18)    NOT NULL,
    [For_Date]           DATETIME        NOT NULL,
    [Eligibility_amount] NUMERIC (18, 2) NULL,
    [Total_Amount]       NUMERIC (18, 2) NULL,
    [Apr_Status]         NUMERIC (1)     NOT NULL,
    [CreatedBy]          NUMERIC (18)    NOT NULL,
    [DateCreated]        DATETIME        NOT NULL,
    [ModifiedBy]         NUMERIC (18)    NULL,
    [DateModified]       DATETIME        NULL,
    CONSTRAINT [PK_T0120_AR_Approval] PRIMARY KEY CLUSTERED ([AR_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_AR_Approval_T0010_COMPANY_MASTER1] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_AR_Approval_T0080_EMP_MASTER1] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_AR_Approval_T0095_INCREMENT] FOREIGN KEY ([Increment_Id]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID]),
    CONSTRAINT [FK_T0120_AR_Approval_T0100_AR_Application] FOREIGN KEY ([AR_APP_ID]) REFERENCES [dbo].[T0100_AR_Application] ([AR_App_ID])
);

