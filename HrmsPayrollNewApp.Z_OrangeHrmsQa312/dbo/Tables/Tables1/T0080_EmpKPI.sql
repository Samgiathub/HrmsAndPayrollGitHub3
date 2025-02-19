CREATE TABLE [dbo].[T0080_EmpKPI] (
    [EmpKPI_Id]    NUMERIC (18)  NOT NULL,
    [Cmp_Id]       NUMERIC (18)  NOT NULL,
    [Emp_Id]       NUMERIC (18)  NOT NULL,
    [Status]       INT           NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    [CreatedBy]    NUMERIC (18)  NULL,
    [LastEditDate] DATETIME      NULL,
    [FinancialYr]  INT           NULL,
    [Emp_Comments] VARCHAR (500) NULL,
    [Mgr_Comments] VARCHAR (500) NULL,
    [HR_Comments]  VARCHAR (500) NULL,
    CONSTRAINT [PK_T0080_EmpKPI] PRIMARY KEY CLUSTERED ([EmpKPI_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0080_EmpKPI_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0080_EmpKPI_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

