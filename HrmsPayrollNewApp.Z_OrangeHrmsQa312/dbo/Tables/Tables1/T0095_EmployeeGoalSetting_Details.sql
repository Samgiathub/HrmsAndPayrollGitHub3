CREATE TABLE [dbo].[T0095_EmployeeGoalSetting_Details] (
    [Emp_GoalSetting_Detail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]                    NUMERIC (18)    NOT NULL,
    [Emp_GoalSetting_Id]        NUMERIC (18)    NOT NULL,
    [Emp_Id]                    NUMERIC (18)    NOT NULL,
    [KRA]                       NVARCHAR (500)  NULL,
    [KPI]                       NVARCHAR (500)  NULL,
    [Target]                    NVARCHAR (500)  NULL,
    [Weight]                    NUMERIC (18, 2) NULL,
    [KPA_Type_ID]               INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0095_EmployeeGoalSetting_Details] PRIMARY KEY CLUSTERED ([Emp_GoalSetting_Detail_Id] ASC),
    CONSTRAINT [FK_T0095_EmployeeGoalSetting_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_EmployeeGoalSetting_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0095_EmployeeGoalSetting_Details_T0090_EmployeeGoalSetting] FOREIGN KEY ([Emp_GoalSetting_Id]) REFERENCES [dbo].[T0090_EmployeeGoalSetting] ([Emp_GoalSetting_Id])
);

