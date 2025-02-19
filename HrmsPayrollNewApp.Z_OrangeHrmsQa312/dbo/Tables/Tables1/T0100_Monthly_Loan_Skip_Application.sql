CREATE TABLE [dbo].[T0100_Monthly_Loan_Skip_Application] (
    [Tran_ID]            NUMERIC (18)    NOT NULL,
    [Request_ID]         NUMERIC (18)    NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [Emp_ID]             NUMERIC (18)    NULL,
    [Loan_Apr_ID]        NUMERIC (18)    NULL,
    [Loan_ID]            NUMERIC (18)    NULL,
    [Old_Install_Amount] NUMERIC (18, 2) NULL,
    [New_Install_Amount] NUMERIC (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

