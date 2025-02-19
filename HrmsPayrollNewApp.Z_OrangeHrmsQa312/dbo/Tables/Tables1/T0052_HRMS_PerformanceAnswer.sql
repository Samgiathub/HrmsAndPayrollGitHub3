CREATE TABLE [dbo].[T0052_HRMS_PerformanceAnswer] (
    [PFAnswer_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [InitiateId]      NUMERIC (18)    NULL,
    [PerformanceF_ID] NUMERIC (18)    NULL,
    [Emp_Id]          NUMERIC (18)    NULL,
    [Answer]          NVARCHAR (1000) NULL,
    [HOD_Feedback]    NVARCHAR (1000) CONSTRAINT [DF__T0052_HRM__HOD_F__7E7F3FBB] DEFAULT ('') NULL,
    [GH_Feedback]     NVARCHAR (1000) CONSTRAINT [DF__T0052_HRM__GH_Fe__7F7363F4] DEFAULT ('') NULL,
    CONSTRAINT [PK_T0052_HRMS_PerformanceAnswer] PRIMARY KEY CLUSTERED ([PFAnswer_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_PerformanceAnswer_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_HRMS_PerformanceAnswer_T0040_PerformanceFeedback_Master] FOREIGN KEY ([PerformanceF_ID]) REFERENCES [dbo].[T0040_PerformanceFeedback_Master] ([PerformanceF_ID]),
    CONSTRAINT [FK_T0052_HRMS_PerformanceAnswer_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([InitiateId]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0052_HRMS_PerformanceAnswer_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

