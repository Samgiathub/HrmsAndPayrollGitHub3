CREATE TABLE [dbo].[T0240_LTA_Medical_Transaction] (
    [LM_Tran_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [Type_ID]           INT             NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [For_Date]          DATETIME        NULL,
    [Balance_Opening]   NUMERIC (18, 2) NULL,
    [Balance_Crediated] NUMERIC (18, 2) NULL,
    [Balance_Used]      NUMERIC (18, 2) NULL,
    [Balance_Closing]   NUMERIC (18, 2) NULL,
    [Sal_Tran_ID]       NUMERIC (18)    NULL,
    [LM_Apr_ID]         NUMERIC (18)    NULL,
    [P_Status]          NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0240_LTA_Medical_Transaction] PRIMARY KEY CLUSTERED ([LM_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0240_LTA_Medical_Transaction_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0240_LTA_Medical_Transaction_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

