CREATE TABLE [dbo].[T0120_Installment_Amount_Details] (
    [Tran_Id]            NUMERIC (18)    NOT NULL,
    [Loan_id]            NUMERIC (18)    NOT NULL,
    [Loan_Apr_ID]        NUMERIC (18)    CONSTRAINT [DF_T0120_Installment_Amount_Details_Loan_Apr_ID] DEFAULT ((0)) NOT NULL,
    [cmp_ID]             NUMERIC (18)    NOT NULL,
    [Emp_ID]             NUMERIC (18)    NOT NULL,
    [Effective_date]     DATETIME        NULL,
    [Installment_Amount] NUMERIC (18, 2) CONSTRAINT [DF_T0120_Installment_Amount_Details_Installment_Amount] DEFAULT ((0)) NOT NULL
);

