CREATE TABLE [dbo].[T0110_RC_Reimbursement_Detail] (
    [RC_Reim_ID]       NUMERIC (18)    NOT NULL,
    [RC_APP_ID]        NUMERIC (18)    NOT NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [RC_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Bill_Date]        DATETIME        NOT NULL,
    [Bill_No]          VARCHAR (255)   NULL,
    [Amount]           NUMERIC (18, 2) NULL,
    [Description]      NVARCHAR (MAX)  NULL,
    [Comments]         NVARCHAR (MAX)  NULL,
    [Apr_Amount]       NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [AD_Exp_Master_ID] NUMERIC (18)    NULL,
    [Exp_FromDate]     DATETIME        NULL,
    [Exp_ToDate]       DATETIME        NULL,
    CONSTRAINT [PK_T0110_RC_Reimbursement_Detail] PRIMARY KEY CLUSTERED ([RC_Reim_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0110_RC_Reimbursement_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_RC_Reimbursement_Detail_T0050_AD_Expense_Limit_Master] FOREIGN KEY ([AD_Exp_Master_ID]) REFERENCES [dbo].[T0050_AD_Expense_Limit_Master] ([AD_Exp_Master_ID]),
    CONSTRAINT [FK_T0110_RC_Reimbursement_Detail_T0050_AD_MASTER] FOREIGN KEY ([RC_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0110_RC_Reimbursement_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_RC_Reimbursement_Detail_T0100_RC_Application] FOREIGN KEY ([RC_APP_ID]) REFERENCES [dbo].[T0100_RC_Application] ([RC_APP_ID])
);

