CREATE TABLE [dbo].[T0050_AD_Expense_Limit_Master] (
    [AD_Exp_Master_ID] NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [AD_ID]            NUMERIC (18)    NOT NULL,
    [AD_Exp_Name]      VARCHAR (255)   NOT NULL,
    [Max_Limit_Type]   VARCHAR (50)    NOT NULL,
    [Fixed_Max_Limit]  NUMERIC (18, 2) NULL,
    [StDate_Year]      DATETIME        NULL,
    [NoOfYear]         INT             NULL,
    [Created_Date]     DATETIME        NOT NULL,
    [Created_By]       NUMERIC (18)    NOT NULL,
    [Modify_Date]      DATETIME        NULL,
    [Modify_By]        NUMERIC (18)    NULL,
    [IT_Row_No]        NUMERIC (18)    DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_AD_Expense_Limit_Master] PRIMARY KEY CLUSTERED ([AD_Exp_Master_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_AD_Expense_Limit_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_AD_Expense_Limit_Master_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID])
);

