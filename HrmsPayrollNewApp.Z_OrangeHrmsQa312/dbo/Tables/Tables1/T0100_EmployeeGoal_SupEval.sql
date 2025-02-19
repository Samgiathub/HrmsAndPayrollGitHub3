CREATE TABLE [dbo].[T0100_EmployeeGoal_SupEval] (
    [SupEval_Id]                NUMERIC (18)  NOT NULL,
    [Cmp_Id]                    NUMERIC (18)  NULL,
    [Emp_Id]                    NUMERIC (18)  NULL,
    [Emp_GoalSetting_Review_Id] NUMERIC (18)  NULL,
    [SupEval_Comments]          VARCHAR (300) NULL,
    [YearEnd_FinalRating]       VARCHAR (12)  NULL,
    [YearEnd_NormalRating]      VARCHAR (12)  NULL,
    [Sup_PromoRecommend]        BIT           DEFAULT ((0)) NULL,
    [Final_PromoRecommend]      BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0100_EmployeeGoal_SupEval] PRIMARY KEY CLUSTERED ([SupEval_Id] ASC),
    CONSTRAINT [FK_T0100_EmployeeGoal_SupEval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_EmployeeGoal_SupEval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_EmployeeGoal_SupEval_T0095_EmployeeGoalSetting_Evaluation] FOREIGN KEY ([Emp_GoalSetting_Review_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Evaluation] ([Emp_GoalSetting_Review_Id])
);

