CREATE TABLE [dbo].[T0210_Monthly_Reim_Detail] (
    [AD_Reim_Tran_ID]  NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [Emp_ID]           NUMERIC (18)    NOT NULL,
    [RC_ID]            NUMERIC (18)    NULL,
    [RC_apr_ID]        NUMERIC (18)    NULL,
    [Temp_Sal_tran_ID] NUMERIC (18)    NULL,
    [Sal_tran_ID]      NUMERIC (18)    NULL,
    [for_Date]         DATETIME        NOT NULL,
    [Amount]           NUMERIC (18, 2) NULL,
    [Taxable]          NUMERIC (18, 2) NOT NULL,
    [Tax_Free_amount]  NUMERIC (18)    NOT NULL,
    CONSTRAINT [PK_T0210_Monthly_Reim_Detail] PRIMARY KEY CLUSTERED ([AD_Reim_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0210_Monthly_Reim_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0210_Monthly_Reim_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0210_Monthly_Reim_Detail_T0120_RC_Approval] FOREIGN KEY ([RC_apr_ID]) REFERENCES [dbo].[T0120_RC_Approval] ([RC_APR_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_Monthly_Reim_Detail_SP_IT_TAX_PREPARATION1]
    ON [dbo].[T0210_Monthly_Reim_Detail]([Sal_tran_ID] ASC, [for_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0210_Monthly_Reim_Detail_SP_IT_TAX_PREPARATION2]
    ON [dbo].[T0210_Monthly_Reim_Detail]([Emp_ID] ASC, [for_Date] ASC);


GO
CREATE STATISTICS [_dta_stat_576981382_4_1]
    ON [dbo].[T0210_Monthly_Reim_Detail]([RC_ID], [AD_Reim_Tran_ID]);


GO
CREATE STATISTICS [_dta_stat_576981382_2_3]
    ON [dbo].[T0210_Monthly_Reim_Detail]([Cmp_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_576981382_1_8_3]
    ON [dbo].[T0210_Monthly_Reim_Detail]([AD_Reim_Tran_ID], [for_Date], [Emp_ID]);

