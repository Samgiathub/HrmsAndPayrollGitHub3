CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_GoalReview] (
    [ReviewGoal_Id]          NUMERIC (18)   NOT NULL,
    [ReviewGoal_CmpId]       NUMERIC (18)   NOT NULL,
    [FK_GoalId]              NUMERIC (18)   NOT NULL,
    [FK_GoalDescriptionId]   NUMERIC (18)   NOT NULL,
    [FK_EmployeeId]          NUMERIC (18)   NOT NULL,
    [Comment]                VARCHAR (1000) NULL,
    [FK_Rating]              NUMERIC (18)   NULL,
    [ReviewGoal_Signoff]     TINYINT        NULL,
    [ReviewGoal_SignoffDate] DATETIME       NULL,
    [Is_Emp_Manager]         TINYINT        NOT NULL,
    [FK_SettingId]           NUMERIC (18)   NOT NULL,
    [ReviewGoal_CreatedBy]   NUMERIC (18)   NOT NULL,
    [ReviewGoal_CreatedDate] DATETIME       NOT NULL,
    [ReviewGoal_ModifyBy]    NUMERIC (18)   NULL,
    [ReviewGoal_ModifyDate]  DATETIME       NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_GoalReview] PRIMARY KEY CLUSTERED ([ReviewGoal_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_GoalReview_T0040_HRMS_Appraisal_SignoffSetting_Master] FOREIGN KEY ([FK_SettingId]) REFERENCES [dbo].[T0040_HRMS_Appraisal_SignoffSetting_Master] ([Setting_Id]),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_GoalReview_T0090_HRMS_Appraisal_Emp_Goal] FOREIGN KEY ([FK_GoalId]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_Goal] ([Goal_Id]),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_GoalReview_T0090_HRMS_Appraisal_Emp_GoalDescription] FOREIGN KEY ([FK_GoalDescriptionId]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_GoalDescription] ([GoalDescription_Id])
);

