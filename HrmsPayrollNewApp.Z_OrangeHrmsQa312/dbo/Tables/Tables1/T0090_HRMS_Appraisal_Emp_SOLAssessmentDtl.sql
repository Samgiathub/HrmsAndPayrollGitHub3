CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl] (
    [SOLAssessmentDtl_Id]          NUMERIC (18)   NOT NULL,
    [SOLAssessmentDtl_CmpId]       NUMERIC (18)   NOT NULL,
    [Fk_SOLAssessment_Id]          NUMERIC (18)   NOT NULL,
    [Fk_SOL]                       NUMERIC (18)   NOT NULL,
    [FK_EmployeeId]                NUMERIC (18)   NOT NULL,
    [IndicativeExample]            VARCHAR (1000) NULL,
    [DepartmentActionPlan]         VARCHAR (1000) NULL,
    [FK_Rating_Emp]                NUMERIC (18)   NULL,
    [FK_Rating_Sup]                NUMERIC (18)   NULL,
    [ReviewSOL_Signoff]            TINYINT        NULL,
    [ReviewSOL_SignoffDate]        DATETIME       NULL,
    [Is_Emp_Manager]               TINYINT        NOT NULL,
    [FK_SettingId]                 NUMERIC (18)   NOT NULL,
    [SOLAssessmentDtl_CreatedBy]   NUMERIC (18)   NOT NULL,
    [SOLAssessmentDtl_CreatedDate] DATETIME       NOT NULL,
    [SOLAssessmentDtl_ModifyBy]    NUMERIC (18)   NULL,
    [SOLAssessmentDtl_ModifyDate]  DATETIME       NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl] PRIMARY KEY CLUSTERED ([SOLAssessmentDtl_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl_T0040_HRMS_Appraisal_SignoffSetting_Master] FOREIGN KEY ([FK_SettingId]) REFERENCES [dbo].[T0040_HRMS_Appraisal_SignoffSetting_Master] ([Setting_Id]),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl_T0040_HRMS_Appraisal_SOL_Master] FOREIGN KEY ([Fk_SOL]) REFERENCES [dbo].[T0040_HRMS_Appraisal_SOL_Master] ([SOL_Id]),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_SOLAssessmentDtl_T0090_HRMS_Appraisal_Emp_SOLAssessment] FOREIGN KEY ([Fk_SOLAssessment_Id]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_SOLAssessment] ([SOLAssessment_Id])
);

