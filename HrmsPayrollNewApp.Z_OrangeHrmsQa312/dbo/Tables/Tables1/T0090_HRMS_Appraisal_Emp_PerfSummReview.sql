CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_PerfSummReview] (
    [PSReview_Id]          NUMERIC (18)   NOT NULL,
    [FK_PSId]              NUMERIC (18)   NOT NULL,
    [FK_EmployeeId]        NUMERIC (18)   NOT NULL,
    [PS_Comment]           VARCHAR (1000) NOT NULL,
    [CP_Comment]           VARCHAR (1000) NOT NULL,
    [FK_RatingId]          NUMERIC (18)   NULL,
    [PSReview_Signoff]     TINYINT        NULL,
    [PSReview_SignoffDate] DATETIME       NULL,
    [Is_Emp_Manager]       TINYINT        NOT NULL,
    [FK_SettingId]         NUMERIC (18)   NOT NULL,
    [PSReview_CreatedBy]   NUMERIC (18)   NOT NULL,
    [PSReview_CreatedDate] DATETIME       NOT NULL,
    [PSReview_ModifyBy]    NUMERIC (18)   NULL,
    [PSReview_ModifyDate]  DATETIME       NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_PerfSummReview] PRIMARY KEY CLUSTERED ([PSReview_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_PerfSummReview_T0040_HRMS_Appraisal_SignoffSetting_Master] FOREIGN KEY ([FK_SettingId]) REFERENCES [dbo].[T0040_HRMS_Appraisal_SignoffSetting_Master] ([Setting_Id]),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_PerfSummReview_T0090_HRMS_Appraisal_Emp_PerformanceSummary] FOREIGN KEY ([FK_PSId]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_PerformanceSummary] ([PS_Id])
);

