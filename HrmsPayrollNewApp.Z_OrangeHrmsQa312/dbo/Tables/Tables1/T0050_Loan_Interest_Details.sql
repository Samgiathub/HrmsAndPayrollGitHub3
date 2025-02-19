CREATE TABLE [dbo].[T0050_Loan_Interest_Details] (
    [Trans_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Loan_ID]        NUMERIC (18)    NULL,
    [Standard_Rates] NUMERIC (18, 4) NULL,
    [Effective_Date] DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC)
);

