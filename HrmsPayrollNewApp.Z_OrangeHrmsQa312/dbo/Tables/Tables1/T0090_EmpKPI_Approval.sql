CREATE TABLE [dbo].[T0090_EmpKPI_Approval] (
    [Tran_Id]           NUMERIC (18)  NOT NULL,
    [EmpKPI_Id]         NUMERIC (18)  NULL,
    [Cmp_Id]            NUMERIC (18)  NULL,
    [Emp_Id]            NUMERIC (18)  NULL,
    [S_Emp_Id]          NUMERIC (18)  NULL,
    [Approval_date]     DATETIME      NULL,
    [Approval_Comments] VARCHAR (500) NULL,
    [Login_id]          NUMERIC (18)  NULL,
    [Rpt_Level]         INT           NULL,
    [Approval_Status]   INT           NULL,
    CONSTRAINT [PK_T0090_EmpKPI_Approval] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_EmpKPI_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_EmpKPI_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0090_EmpKPI_Approval_T0080_EmpKPI] FOREIGN KEY ([EmpKPI_Id]) REFERENCES [dbo].[T0080_EmpKPI] ([EmpKPI_Id])
);

