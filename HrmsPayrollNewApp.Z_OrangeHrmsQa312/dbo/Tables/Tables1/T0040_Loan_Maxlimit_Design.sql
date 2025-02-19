CREATE TABLE [dbo].[T0040_Loan_Maxlimit_Design] (
    [Trans_ID]       NUMERIC (18)    NOT NULL,
    [Loan_ID]        NUMERIC (18)    NULL,
    [Desig_Id]       NUMERIC (18)    NULL,
    [Loan_Max_Limit] NUMERIC (22, 2) NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC) WITH (FILLFACTOR = 80)
);

