CREATE TABLE [dbo].[T0050_EXPENSE_TYPE_MAX_LIMIT] (
    [Tran_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Expense_Type_ID] NUMERIC (18)    NOT NULL,
    [Grd_ID]          NUMERIC (18)    NOT NULL,
    [Amount]          NUMERIC (18, 2) CONSTRAINT [DF_T0050_EXPENSE_TYPE_MAX_LIMIT_Amount] DEFAULT ((0)) NOT NULL,
    [Flag_Grd_Desig]  TINYINT         NULL,
    [City_Cat_ID]     NUMERIC (18)    NULL,
    [City_Cat_Amount] NUMERIC (18)    NULL,
    [Desig_ID]        NUMERIC (18)    NULL,
    [Effective_Date]  DATETIME        NULL,
    [City_Cat_Flag]   TINYINT         NULL,
    CONSTRAINT [PK_T0050_EXPENSE_TYPE_MAX_LIMIT] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_EXPENSE_TYPE_MAX_LIMIT_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_EXPENSE_TYPE_MAX_LIMIT_T0040_Expense_Type_Master] FOREIGN KEY ([Expense_Type_ID]) REFERENCES [dbo].[T0040_Expense_Type_Master] ([Expense_Type_ID])
);

