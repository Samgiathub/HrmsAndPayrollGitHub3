CREATE TABLE [dbo].[T0110_RC_Dependant_Detail] (
    [RC_Dependent_ID]  NUMERIC (18)    NOT NULL,
    [RC_APP_ID]        NUMERIC (18)    NOT NULL,
    [RC_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Name]             VARCHAR (255)   NULL,
    [Relation]         VARCHAR (255)   NULL,
    [Age]              NUMERIC (18)    NULL,
    [BillNo]           VARCHAR (255)   NULL,
    [BillDate]         DATETIME        NULL,
    [PrescribeBy]      VARCHAR (255)   NULL,
    [Amount]           NUMERIC (18, 2) NULL,
    [Apr_Amount]       NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [AD_Exp_Master_ID] NUMERIC (18)    NULL,
    [Exp_FromDate]     DATETIME        NULL,
    [Exp_ToDate]       DATETIME        NULL,
    CONSTRAINT [PK_T0110_RC_Dependant_Detail] PRIMARY KEY CLUSTERED ([RC_Dependent_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0110_RC_Dependant_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_RC_Dependant_Detail_T0050_AD_Expense_Limit_Master] FOREIGN KEY ([AD_Exp_Master_ID]) REFERENCES [dbo].[T0050_AD_Expense_Limit_Master] ([AD_Exp_Master_ID]),
    CONSTRAINT [FK_T0110_RC_Dependant_Detail_T0050_AD_MASTER] FOREIGN KEY ([RC_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0110_RC_Dependant_Detail_T0100_RC_Application] FOREIGN KEY ([RC_APP_ID]) REFERENCES [dbo].[T0100_RC_Application] ([RC_APP_ID])
);

