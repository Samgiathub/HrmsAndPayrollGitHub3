CREATE TABLE [dbo].[T0210_LWP_Considered_Same_Salary_Cutoff] (
    [Tran_Id]           NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]            NUMERIC (18) NOT NULL,
    [Emp_Id]            NUMERIC (18) NOT NULL,
    [Sal_Tran_Id]       NUMERIC (18) NOT NULL,
    [Leave_Approval_ID] NUMERIC (18) NOT NULL,
    [Leave_Id]          NUMERIC (18) NOT NULL,
    [Leave_Period]      NUMERIC (18) NOT NULL,
    [For_Date]          DATETIME     NOT NULL,
    CONSTRAINT [PK_T0210_LWP_Considered_Same_Salary_Cutoff] PRIMARY KEY CLUSTERED ([Tran_Id] ASC),
    CONSTRAINT [FK_T0210_LWP_Considered_Same_Salary_Cutoff_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0210_LWP_Considered_Same_Salary_Cutoff_T0120_LEAVE_APPROVAL] FOREIGN KEY ([Leave_Approval_ID]) REFERENCES [dbo].[T0120_LEAVE_APPROVAL] ([Leave_Approval_ID]),
    CONSTRAINT [FK_T0210_LWP_Considered_Same_Salary_Cutoff_T0200_MONTHLY_SALARY] FOREIGN KEY ([Sal_Tran_Id]) REFERENCES [dbo].[T0200_MONTHLY_SALARY] ([Sal_Tran_ID])
);

