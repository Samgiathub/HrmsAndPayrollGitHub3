CREATE TABLE [dbo].[T0052_HRMS_AppTrainingDetail] (
    [App_Trainingdetail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_ID]                NUMERIC (18)    NOT NULL,
    [InitiateId]            NUMERIC (18)    NULL,
    [Emp_Id]                NUMERIC (18)    NULL,
    [Type]                  NVARCHAR (50)   NULL,
    [TrainingAreas]         NVARCHAR (1000) NULL,
    CONSTRAINT [PK_T0052_HRMS_AppTrainingDetail] PRIMARY KEY CLUSTERED ([App_Trainingdetail_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_AppTrainingDetail_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_HRMS_AppTrainingDetail_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([InitiateId]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0052_HRMS_AppTrainingDetail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

