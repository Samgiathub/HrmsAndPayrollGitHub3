CREATE TABLE [dbo].[T0052_HRMS_AppTrainDetail] (
    [App_Traindetail_Id]   NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NULL,
    [InitiateId]           NUMERIC (18)    NULL,
    [Emp_Id]               NUMERIC (18)    NULL,
    [Type]                 NVARCHAR (50)   NULL,
    [Attend_LastYear]      NVARCHAR (1000) NULL,
    [Recommended_ThisYear] NVARCHAR (1000) NULL,
    [OtherTraining]        NVARCHAR (1000) NULL,
    CONSTRAINT [PK_T0052_HRMS_AppTrainDetail] PRIMARY KEY CLUSTERED ([App_Traindetail_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_AppTrainDetail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_HRMS_AppTrainDetail_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([InitiateId]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0052_HRMS_AppTrainDetail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

