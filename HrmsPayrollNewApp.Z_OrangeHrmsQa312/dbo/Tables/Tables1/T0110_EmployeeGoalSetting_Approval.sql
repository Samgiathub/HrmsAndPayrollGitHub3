CREATE TABLE [dbo].[T0110_EmployeeGoalSetting_Approval] (
    [EGS_Level_Id]       NUMERIC (18)  NOT NULL,
    [Cmp_Id]             NUMERIC (18)  NOT NULL,
    [Emp_Id]             NUMERIC (18)  NULL,
    [S_Emp_Id]           NUMERIC (18)  NULL,
    [Emp_GoalSetting_Id] NUMERIC (18)  NULL,
    [Approval_date]      DATETIME      NULL,
    [Approval_Comments]  VARCHAR (300) NULL,
    [Login_id]           NUMERIC (18)  NULL,
    [Rpt_Level]          INT           NULL,
    [Approval_Status]    INT           NULL,
    CONSTRAINT [PK_T0110_EmployeeGoalSetting_Approval] PRIMARY KEY CLUSTERED ([EGS_Level_Id] ASC),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Approval_T0090_EmployeeGoalSetting] FOREIGN KEY ([Emp_GoalSetting_Id]) REFERENCES [dbo].[T0090_EmployeeGoalSetting] ([Emp_GoalSetting_Id])
);

