CREATE TABLE [dbo].[T0115_EmployeeGoalSetting_Details_Level] (
    [Tran_Id]                   NUMERIC (18)    NOT NULL,
    [Cmp_Id]                    NUMERIC (18)    NULL,
    [Emp_Id]                    NUMERIC (18)    NULL,
    [Emp_GoalSetting_Detail_Id] NUMERIC (18)    NULL,
    [KRA]                       NVARCHAR (500)  NULL,
    [KPI]                       NVARCHAR (500)  NULL,
    [Target]                    NVARCHAR (500)  NULL,
    [Weight]                    NUMERIC (18, 2) NULL,
    [Rpt_Level]                 TINYINT         NULL,
    [EGS_Level_Id]              NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0115_EmployeeGoalSetting_Details_Level] PRIMARY KEY CLUSTERED ([Tran_Id] ASC),
    CONSTRAINT [FK_T0115_EmployeeGoalSetting_Details_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_EmployeeGoalSetting_Details_Level_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0115_EmployeeGoalSetting_Details_Level_T0095_EmployeeGoalSetting_Details] FOREIGN KEY ([Emp_GoalSetting_Detail_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Details] ([Emp_GoalSetting_Detail_Id]),
    CONSTRAINT [FK_T0115_EmployeeGoalSetting_Details_Level_T0110_EmployeeGoalSetting_Approval] FOREIGN KEY ([EGS_Level_Id]) REFERENCES [dbo].[T0110_EmployeeGoalSetting_Approval] ([EGS_Level_Id])
);

