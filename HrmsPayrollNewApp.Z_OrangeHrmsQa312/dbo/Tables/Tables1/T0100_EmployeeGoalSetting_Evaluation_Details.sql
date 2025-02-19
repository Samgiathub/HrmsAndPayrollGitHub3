CREATE TABLE [dbo].[T0100_EmployeeGoalSetting_Evaluation_Details] (
    [Emp_GoalSetting_Review_Detail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]                           NUMERIC (18)    NOT NULL,
    [Emp_Id]                           NUMERIC (18)    NOT NULL,
    [Emp_GoalSetting_Review_Id]        NUMERIC (18)    NOT NULL,
    [Emp_GoalSetting_Detail_Id]        NUMERIC (18)    NOT NULL,
    [Actual]                           NVARCHAR (100)  NULL,
    [Emp_Feedback]                     NVARCHAR (300)  NULL,
    [Sup_Score]                        VARCHAR (50)    NULL,
    [Sup_Feedback]                     NVARCHAR (300)  NULL,
    [WeightedScore]                    NUMERIC (18, 2) NULL,
    [KPA_Type_ID]                      INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0010_EmployeeGoalSetting_Evaluation_Details] PRIMARY KEY CLUSTERED ([Emp_GoalSetting_Review_Detail_Id] ASC),
    CONSTRAINT [FK_T0010_EmployeeGoalSetting_Evaluation_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0010_EmployeeGoalSetting_Evaluation_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0010_EmployeeGoalSetting_Evaluation_Details_T0095_EmployeeGoalSetting_Details] FOREIGN KEY ([Emp_GoalSetting_Detail_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Details] ([Emp_GoalSetting_Detail_Id]),
    CONSTRAINT [FK_T0010_EmployeeGoalSetting_Evaluation_Details_T0095_EmployeeGoalSetting_Evaluation] FOREIGN KEY ([Emp_GoalSetting_Review_Id]) REFERENCES [dbo].[T0095_EmployeeGoalSetting_Evaluation] ([Emp_GoalSetting_Review_Id])
);

