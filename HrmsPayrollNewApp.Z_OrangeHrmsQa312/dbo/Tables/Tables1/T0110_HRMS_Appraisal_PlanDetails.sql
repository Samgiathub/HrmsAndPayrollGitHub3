CREATE TABLE [dbo].[T0110_HRMS_Appraisal_PlanDetails] (
    [HPD_Id]         NUMERIC (18)   NOT NULL,
    [Row_ID]         NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [Emp_ID]         NUMERIC (18)   NOT NULL,
    [InitiateId]     NUMERIC (18)   NOT NULL,
    [Plan]           NVARCHAR (500) NULL,
    [Area]           NVARCHAR (500) NULL,
    [Method_Id]      NUMERIC (18)   NULL,
    [TimeFrame_Id]   NUMERIC (18)   NULL,
    [Comments]       NVARCHAR (500) NULL,
    [Approval_Level] NVARCHAR (200) NULL,
    CONSTRAINT [PK_T0110_HRMS_Appraisal_PlanDetails] PRIMARY KEY CLUSTERED ([HPD_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0110_HRMS_Appraisal_PlanDetails_T0040_HRMS_TimeFrame_Master] FOREIGN KEY ([TimeFrame_Id]) REFERENCES [dbo].[T0040_HRMS_TimeFrame_Master] ([TimeFrame_Id]),
    CONSTRAINT [FK_T0110_HRMS_Appraisal_PlanDetails_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([InitiateId]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0110_HRMS_Appraisal_PlanDetails_T0110_HRMS_Appraisal_PlanDetails] FOREIGN KEY ([Method_Id]) REFERENCES [dbo].[T0040_HRMS_Method_Master] ([Method_Id])
);

