CREATE TABLE [dbo].[T0120_Interest_Yearly_Details] (
    [Tran_Id]             NUMERIC (18)    NOT NULL,
    [Loan_id]             NUMERIC (18)    NOT NULL,
    [Loan_Apr_Id]         NUMERIC (18)    CONSTRAINT [DF_T0120_Interest_Yearly_Details_Loan_Apr_Id] DEFAULT ((0)) NOT NULL,
    [cmp_ID]              NUMERIC (18)    NOT NULL,
    [Emp_ID]              NUMERIC (18)    NOT NULL,
    [Effective_date]      DATETIME        NULL,
    [Interest_Per_Yearly] NUMERIC (18, 2) CONSTRAINT [DF_T0120_Interest_Yearly_Details_Interest_Per_Yearly] DEFAULT ((0)) NOT NULL
);

