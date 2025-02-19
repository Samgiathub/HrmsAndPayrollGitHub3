CREATE TABLE [dbo].[T0115_EmployeeGoal_SupEval_Level] (
    [SupEval_Level_Id]          NUMERIC (18)   NOT NULL,
    [Cmp_Id]                    NUMERIC (18)   NULL,
    [Emp_Id]                    NUMERIC (18)   NULL,
    [Emp_GoalSetting_Review_Id] NUMERIC (18)   NULL,
    [SupEval_Id]                NUMERIC (18)   NULL,
    [SupEval_Comments]          NVARCHAR (300) NULL,
    [YearEnd_FinalRating]       VARCHAR (12)   NULL,
    [YearEnd_NormalRating]      VARCHAR (12)   NULL,
    [S_Emp_Id]                  NUMERIC (18)   NULL,
    [Approval_date]             DATETIME       NULL,
    [Rpt_Level]                 INT            NULL,
    [EGS_Review_Level_Id]       NUMERIC (18)   NULL,
    CONSTRAINT [PK_T0115_EmployeeGoal_SupEval_Level] PRIMARY KEY CLUSTERED ([SupEval_Level_Id] ASC),
    CONSTRAINT [FK_T0115_EmployeeGoal_SupEval_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_EmployeeGoal_SupEval_Level_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0115_EmployeeGoal_SupEval_Level_T0095_EmployeeGoalSetting_Evaluation] FOREIGN KEY ([Emp_GoalSetting_Review_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Evaluation] ([Emp_GoalSetting_Review_Id]),
    CONSTRAINT [FK_T0115_EmployeeGoal_SupEval_Level_T0100_EmployeeGoal_SupEval] FOREIGN KEY ([SupEval_Id]) REFERENCES [dbo].[T0100_EmployeeGoal_SupEval] ([SupEval_Id]),
    CONSTRAINT [FK_T0115_EmployeeGoal_SupEval_Level_T0110_EmployeeGoalSetting_Evaluation_Approval] FOREIGN KEY ([EGS_Review_Level_Id]) REFERENCES [dbo].[T0110_EmployeeGoalSetting_Evaluation_Approval] ([EGS_Review_Level_Id])
);

