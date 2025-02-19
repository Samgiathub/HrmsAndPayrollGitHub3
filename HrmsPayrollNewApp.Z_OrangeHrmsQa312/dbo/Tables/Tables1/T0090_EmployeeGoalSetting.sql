CREATE TABLE [dbo].[T0090_EmployeeGoalSetting] (
    [Emp_GoalSetting_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]             NUMERIC (18)   NOT NULL,
    [Emp_Id]             NUMERIC (18)   NOT NULL,
    [EGS_Status]         NUMERIC (18)   NOT NULL,
    [FinYear]            INT            NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [CreatedBy]          NUMERIC (18)   NOT NULL,
    [ModifiedDate]       DATETIME       NULL,
    [ModifiedBy]         NUMERIC (18)   NULL,
    [Emp_Comment]        NVARCHAR (500) NULL,
    [Manager_Comment]    NVARCHAR (500) NULL,
    CONSTRAINT [PK_T0090_EmployeeGoalSetting] PRIMARY KEY CLUSTERED ([Emp_GoalSetting_Id] ASC),
    CONSTRAINT [FK_T0090_EmployeeGoalSetting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_EmployeeGoalSetting_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

