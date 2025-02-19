CREATE TABLE [dbo].[T0140_ReimClaim_Transacation] (
    [Reim_Tran_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]              NUMERIC (18)    NOT NULL,
    [RC_ID]               NUMERIC (18)    NOT NULL,
    [Emp_ID]              NUMERIC (18)    NOT NULL,
    [For_Date]            DATETIME        NULL,
    [Reim_Opening]        NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Reim_Credit]         NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Reim_Debit]          NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Reim_Closing]        NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [RC_apr_ID]           NUMERIC (18)    NULL,
    [Sal_tran_ID]         NUMERIC (18)    NULL,
    [S_Sal_Tran_id]       NUMERIC (18)    NULL,
    [Reim_Sett_CR_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0140_ReimClaim_Transacation_Reim_Sett_CR_Amount] DEFAULT ((0)) NOT NULL,
    [sys_Date]            DATETIME        CONSTRAINT [DF_T0140_ReimClaim_Transacation_sys_Date] DEFAULT (getdate()) NOT NULL,
    [For_FNF]             TINYINT         DEFAULT ((0)) NOT NULL,
    [Posting_Amount]      NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0140_ReimClaim_Transacation] PRIMARY KEY CLUSTERED ([Reim_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0140_ReimClaim_Transacation_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0140_ReimClaim_Transacation_T0050_AD_MASTER] FOREIGN KEY ([RC_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0140_ReimClaim_Transacation_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0140_ReimClaim_Transacation_10_310396275__K1_6_7_8]
    ON [dbo].[T0140_ReimClaim_Transacation]([Reim_Tran_ID] ASC)
    INCLUDE([Reim_Opening], [Reim_Credit], [Reim_Debit]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0140_ReimClaim_Transacation_10_310396275__K4_K5_K3_8]
    ON [dbo].[T0140_ReimClaim_Transacation]([Emp_ID] ASC, [For_Date] ASC, [RC_ID] ASC)
    INCLUDE([Reim_Debit]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0140_ReimClaim_Transacation_10_310396275__K4_2_3_5_11]
    ON [dbo].[T0140_ReimClaim_Transacation]([Emp_ID] ASC)
    INCLUDE([Cmp_ID], [RC_ID], [For_Date], [Sal_tran_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [T0140_ReimClaim_Transacation_CmpId_RCID_EmpId_For_Date_IX]
    ON [dbo].[T0140_ReimClaim_Transacation]([Cmp_ID] ASC, [RC_ID] ASC, [Emp_ID] ASC, [For_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_310396275_4_5_3_15]
    ON [dbo].[T0140_ReimClaim_Transacation]([Emp_ID], [For_Date], [RC_ID], [For_FNF]);


GO
CREATE STATISTICS [_dta_stat_310396275_3_4]
    ON [dbo].[T0140_ReimClaim_Transacation]([RC_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_310396275_5_3]
    ON [dbo].[T0140_ReimClaim_Transacation]([For_Date], [RC_ID]);


GO
CREATE STATISTICS [_dta_stat_310396275_5_2_3]
    ON [dbo].[T0140_ReimClaim_Transacation]([For_Date], [Cmp_ID], [RC_ID]);


GO
CREATE STATISTICS [_dta_stat_310396275_1_4_5_3_15]
    ON [dbo].[T0140_ReimClaim_Transacation]([Reim_Tran_ID], [Emp_ID], [For_Date], [RC_ID], [For_FNF]);


GO
CREATE STATISTICS [_dta_stat_310396275_1_15]
    ON [dbo].[T0140_ReimClaim_Transacation]([Reim_Tran_ID], [For_FNF]);

