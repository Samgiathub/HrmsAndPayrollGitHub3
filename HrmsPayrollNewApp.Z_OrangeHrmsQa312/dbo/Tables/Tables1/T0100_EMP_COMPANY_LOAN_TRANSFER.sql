CREATE TABLE [dbo].[T0100_EMP_COMPANY_LOAN_TRANSFER] (
    [Row_Id]          NUMERIC (18)    NOT NULL,
    [Tran_Id]         NUMERIC (18)    NOT NULL,
    [Cmp_Id]          NUMERIC (18)    NOT NULL,
    [Emp_Id]          NUMERIC (18)    NOT NULL,
    [Loan_Id]         NUMERIC (18)    NOT NULL,
    [Old_Balance]     NUMERIC (18, 3) NOT NULL,
    [New_Cmp_Id]      NUMERIC (18)    NOT NULL,
    [New_Emp_Id]      NUMERIC (18)    NOT NULL,
    [New_Loan_Id]     NUMERIC (18)    NOT NULL,
    [New_Balance]     NUMERIC (18)    NOT NULL,
    [Loan_Row_Id]     NUMERIC (18)    NOT NULL,
    [New_Loan_Apr_Id] NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0100_EMP_COMPANY_LOAN_TRANSFER] PRIMARY KEY CLUSTERED ([Row_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_EMP_COMPANY_LOAN_TRANSFER_T0095_EMP_COMPANY_TRANSFER] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0095_EMP_COMPANY_TRANSFER] ([Tran_Id])
);

