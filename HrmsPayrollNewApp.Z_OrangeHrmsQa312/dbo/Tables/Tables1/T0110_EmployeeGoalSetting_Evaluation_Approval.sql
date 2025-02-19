CREATE TABLE [dbo].[T0110_EmployeeGoalSetting_Evaluation_Approval] (
    [EGS_Review_Level_Id]       NUMERIC (18)    NOT NULL,
    [Cmp_Id]                    NUMERIC (18)    NOT NULL,
    [Emp_Id]                    NUMERIC (18)    NOT NULL,
    [S_Emp_Id]                  NUMERIC (18)    NULL,
    [Emp_GoalSetting_Review_Id] NUMERIC (18)    NULL,
    [Approval_date]             DATETIME        NULL,
    [Approval_Comments]         NVARCHAR (300)  NULL,
    [AdditionalAchievement]     NVARCHAR (1000) NULL,
    [Login_Id]                  NUMERIC (18)    NULL,
    [Rpt_Level]                 INT             NULL,
    [Approval_Status]           INT             NULL,
    CONSTRAINT [PK_T0110_EmployeeGoalSetting_Evaluation_Approval] PRIMARY KEY CLUSTERED ([EGS_Review_Level_Id] ASC),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Evaluation_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Evaluation_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_EmployeeGoalSetting_Evaluation_Approval_T0095_EmployeeGoalSetting_Evaluation] FOREIGN KEY ([Emp_GoalSetting_Review_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Evaluation] ([Emp_GoalSetting_Review_Id])
);

