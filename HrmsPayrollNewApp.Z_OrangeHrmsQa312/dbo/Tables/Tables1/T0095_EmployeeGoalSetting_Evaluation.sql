CREATE TABLE [dbo].[T0095_EmployeeGoalSetting_Evaluation] (
    [Emp_GoalSetting_Review_Id] NUMERIC (18)   NOT NULL,
    [Cmp_Id]                    NUMERIC (18)   NOT NULL,
    [Emp_Id]                    NUMERIC (18)   NOT NULL,
    [FinYear]                   INT            NOT NULL,
    [Review_Type]               INT            NOT NULL,
    [Review_Status]             NUMERIC (18)   NOT NULL,
    [Emp_Comments]              NVARCHAR (300) NULL,
    [Manager_Comments]          NVARCHAR (300) NULL,
    [AdditionalAchievement]     NVARCHAR (300) NULL,
    [CreatedDate]               DATETIME       NOT NULL,
    [CreatedBy]                 NUMERIC (18)   NOT NULL,
    [ModifiedDate]              DATETIME       NULL,
    [ModifiedBy]                NUMERIC (18)   NULL,
    CONSTRAINT [PK_T0095_EmployeeGoalSetting_Evaluation] PRIMARY KEY CLUSTERED ([Emp_GoalSetting_Review_Id] ASC),
    CONSTRAINT [FK_T0095_EmployeeGoalSetting_Evaluation_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_EmployeeGoalSetting_Evaluation_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

