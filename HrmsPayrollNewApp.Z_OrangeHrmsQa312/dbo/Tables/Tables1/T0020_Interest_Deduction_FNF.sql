CREATE TABLE [dbo].[T0020_Interest_Deduction_FNF] (
    [Tran_Id]                 NUMERIC (18)    NOT NULL,
    [Cmp_ID]                  NUMERIC (18)    NULL,
    [Emp_ID]                  NUMERIC (18)    NULL,
    [Loan_ID]                 NUMERIC (18)    NULL,
    [Loan_Apr_ID]             NUMERIC (18)    NULL,
    [Loan_Amount]             NUMERIC (18, 2) NULL,
    [Loan_Interest_Amount]    NUMERIC (18, 2) NULL,
    [Is_First_Deduction_Flag] NUMERIC (18)    NULL,
    [Is_Deduction_Flag]       NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

