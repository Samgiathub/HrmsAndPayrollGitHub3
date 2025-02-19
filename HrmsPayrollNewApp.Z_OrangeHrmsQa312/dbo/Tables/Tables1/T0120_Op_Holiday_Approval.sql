CREATE TABLE [dbo].[T0120_Op_Holiday_Approval] (
    [Op_Holiday_Apr_ID]       NUMERIC (18)   NOT NULL,
    [Op_Holiday_App_ID]       NUMERIC (18)   NOT NULL,
    [Emp_ID]                  NUMERIC (18)   NOT NULL,
    [Cmp_ID]                  NUMERIC (18)   NOT NULL,
    [HDay_ID]                 NUMERIC (18)   NOT NULL,
    [S_Emp_ID]                NUMERIC (18)   NULL,
    [Op_Holiday_Apr_Date]     DATETIME       NOT NULL,
    [Op_Holiday_Apr_Status]   CHAR (10)      NOT NULL,
    [Op_Holiday_Apr_Comments] VARCHAR (4000) NULL,
    [Created_By]              NUMERIC (18)   NOT NULL,
    [Date_Created]            DATETIME       NOT NULL,
    [Modify_By]               NUMERIC (18)   NULL,
    [Date_Modified]           DATETIME       NULL,
    CONSTRAINT [PK_T0120_Op_Holiday_Approval] PRIMARY KEY CLUSTERED ([Op_Holiday_Apr_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_Op_Holiday_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_Op_Holiday_Approval_T0040_HOLIDAY_MASTER] FOREIGN KEY ([HDay_ID]) REFERENCES [dbo].[T0040_HOLIDAY_MASTER] ([Hday_ID]),
    CONSTRAINT [FK_T0120_Op_Holiday_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_Op_Holiday_Approval_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_Op_Holiday_Approval_T0100_OP_Holiday_Application] FOREIGN KEY ([Op_Holiday_App_ID]) REFERENCES [dbo].[T0100_OP_Holiday_Application] ([Op_Holiday_App_ID])
);

