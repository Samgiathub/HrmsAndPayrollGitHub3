CREATE TABLE [dbo].[T9999_Salary_Export_Detail] (
    [Sal_Exp_Id]     NUMERIC (18)    NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Sal_Exp_Trn_Id] NUMERIC (18)    NOT NULL,
    [Emp_Id]         NUMERIC (18)    NULL,
    [Tally_Led_Name] VARCHAR (100)   NOT NULL,
    [Dr_Amount]      NUMERIC (18, 2) CONSTRAINT [DF_T9999_Salary_Export_Detail_Dr_Amount] DEFAULT ((0)) NOT NULL,
    [Cr_Amount]      NUMERIC (18, 2) CONSTRAINT [DF_T9999_Salary_Export_Detail_Cr_Amount] DEFAULT ((0)) NOT NULL,
    [Comment]        VARCHAR (100)   CONSTRAINT [DF_T9999_Salary_Export_Detail_Remarks] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T9999_Salary_Export_Detail] PRIMARY KEY CLUSTERED ([Sal_Exp_Trn_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T9999_Salary_Export_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T9999_Salary_Export_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T9999_Salary_Export_Detail_T9999_Salary_Export] FOREIGN KEY ([Sal_Exp_Id]) REFERENCES [dbo].[T9999_Salary_Export] ([Sal_Exp_Id])
);

