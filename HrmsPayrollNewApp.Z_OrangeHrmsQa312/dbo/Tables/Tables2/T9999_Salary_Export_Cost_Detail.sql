CREATE TABLE [dbo].[T9999_Salary_Export_Cost_Detail] (
    [Tran_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NOT NULL,
    [Sal_Exp_ID]     NUMERIC (18)    NULL,
    [Sal_Exp_Trn_ID] NUMERIC (18)    NULL,
    [Cost_Center_ID] NUMERIC (18)    NOT NULL,
    [Amount]         NUMERIC (18, 3) NOT NULL,
    CONSTRAINT [PK_T9999_Salary_Export_Cost_Detail] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T9999_Salary_Export_Cost_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T9999_Salary_Export_Cost_Detail_T0040_Cost_Center] FOREIGN KEY ([Cost_Center_ID]) REFERENCES [dbo].[T0040_Cost_Center] ([Tally_Center_ID]),
    CONSTRAINT [FK_T9999_Salary_Export_Cost_Detail_T9999_Salary_Export] FOREIGN KEY ([Sal_Exp_ID]) REFERENCES [dbo].[T9999_Salary_Export] ([Sal_Exp_Id]),
    CONSTRAINT [FK_T9999_Salary_Export_Cost_Detail_T9999_Salary_Export_Detail] FOREIGN KEY ([Sal_Exp_Trn_ID]) REFERENCES [dbo].[T9999_Salary_Export_Detail] ([Sal_Exp_Trn_Id])
);

