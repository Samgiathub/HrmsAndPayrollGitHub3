CREATE TABLE [dbo].[T0100_Monthly_Loan_Skip_Approval] (
    [Tran_ID]            NUMERIC (18)    NOT NULL,
    [Request_Apr_ID]     NUMERIC (18)    NULL,
    [Request_ID]         NUMERIC (18)    NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [Emp_ID]             NUMERIC (18)    NULL,
    [Loan_Apr_ID]        NUMERIC (18)    NULL,
    [Loan_ID]            NUMERIC (18)    NULL,
    [Old_Install_Amount] NUMERIC (18, 2) NULL,
    [New_Install_Amount] NUMERIC (18, 2) NULL,
    [S_Emp_ID]           NUMERIC (18)    NULL,
    [Rpt_Level]          NUMERIC (2)     NULL,
    [Final_Approval]     TINYINT         NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

