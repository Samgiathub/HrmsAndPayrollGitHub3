CREATE TABLE [dbo].[T0050_AD_Expense_Limit] (
    [AD_Exp_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [AD_Exp_Master_ID] NUMERIC (18)    NOT NULL,
    [Desig_ID]         NUMERIC (18)    NOT NULL,
    [Amount_Max_Limit] NUMERIC (18, 2) NOT NULL,
    [Created_Date]     DATETIME        NOT NULL,
    [Created_By]       NUMERIC (18)    NOT NULL,
    [Modify_Date]      DATETIME        NULL,
    [Modify_By]        NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0050_AD_Expense_Limit] PRIMARY KEY CLUSTERED ([AD_Exp_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_AD_Expense_Limit_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_AD_Expense_Limit_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_ID]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0050_AD_Expense_Limit_T0050_AD_Expense_Limit_Master] FOREIGN KEY ([AD_Exp_Master_ID]) REFERENCES [dbo].[T0050_AD_Expense_Limit_Master] ([AD_Exp_Master_ID])
);

