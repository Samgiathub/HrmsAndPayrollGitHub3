CREATE TABLE [dbo].[T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory] (
    [Signoff_ID]      NUMERIC (18) NOT NULL,
    [FK_PS_Id]        NUMERIC (18) NOT NULL,
    [Signoff_Version] NUMERIC (18) NOT NULL,
    [Signoff_Date]    DATETIME     NOT NULL,
    [Emp_ID]          NUMERIC (18) NOT NULL,
    CONSTRAINT [PK_T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory] PRIMARY KEY CLUSTERED ([Signoff_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Appraisal_Emp_PerformanceSummary_SignoffHistory_T0090_HRMS_Appraisal_Emp_PerformanceSummary] FOREIGN KEY ([FK_PS_Id]) REFERENCES [dbo].[T0090_HRMS_Appraisal_Emp_PerformanceSummary] ([PS_Id])
);

