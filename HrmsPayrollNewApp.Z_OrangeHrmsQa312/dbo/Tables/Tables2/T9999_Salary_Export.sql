CREATE TABLE [dbo].[T9999_Salary_Export] (
    [Sal_Exp_Id]   NUMERIC (18)  NOT NULL,
    [Cmp_Id]       NUMERIC (18)  NOT NULL,
    [Vch_No]       NUMERIC (18)  NOT NULL,
    [Vch_Type]     VARCHAR (20)  CONSTRAINT [DF_T9999_Salary_Export_Vch_Type] DEFAULT ('Payment') NOT NULL,
    [Vch_Date]     DATETIME      NOT NULL,
    [Month_Date]   DATETIME      NOT NULL,
    [Vch_Comments] VARCHAR (100) CONSTRAINT [DF_T9999_Salary_Export_Vch_Remarks] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T9999_Salary_Export_1] PRIMARY KEY CLUSTERED ([Sal_Exp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T9999_Salary_Export_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

