CREATE TABLE [dbo].[T0140_ReimClaim_Transacation_Payment_Monthly] (
    [Trans_ID]     NUMERIC (18)    CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Trans_ID] DEFAULT ((0)) NOT NULL,
    [Cmp_ID]       NUMERIC (18)    CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_cmp_ID] DEFAULT ((0)) NOT NULL,
    [Emp_ID]       NUMERIC (18)    CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Emp_ID] DEFAULT ((0)) NOT NULL,
    [Claim_ID]     NUMERIC (18)    CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Claim_Id] DEFAULT ((0)) NOT NULL,
    [Sal_Trans_ID] NUMERIC (18)    CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Sal_Trans_ID] DEFAULT ((0)) NOT NULL,
    [For_Date]     DATETIME        NULL,
    [Opening]      NUMERIC (18, 2) CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Opening] DEFAULT ((0)) NOT NULL,
    [Credit]       NUMERIC (18, 2) CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Credit] DEFAULT ((0)) NOT NULL,
    [Debit]        NUMERIC (18, 2) CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Debit] DEFAULT ((0)) NOT NULL,
    [Balance]      NUMERIC (18, 2) CONSTRAINT [DF_T0140_Reim_Medical_Claim_Transaction_Balance] DEFAULT ((0)) NOT NULL
);

