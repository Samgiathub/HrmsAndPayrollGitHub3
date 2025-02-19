CREATE TABLE [dbo].[T0052_Emp_SelfAppraisal] (
    [SelfApp_Id]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [SAppraisal_ID]    NUMERIC (18)    NULL,
    [InitiateId]       NUMERIC (18)    NULL,
    [Emp_Id]           NUMERIC (18)    NULL,
    [Answer]           NVARCHAR (2000) NULL,
    [Weightage]        NUMERIC (18, 2) NULL,
    [Emp_Score]        NUMERIC (18, 2) NULL,
    [Comments]         NVARCHAR (4000) NULL,
    [Manager_Score]    NUMERIC (18, 2) NULL,
    [Manager_comments] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_T0052_Emp_SelfAppraisal] PRIMARY KEY CLUSTERED ([SelfApp_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_Emp_SelfAppraisal_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_Emp_SelfAppraisal_T0040_SelfAppraisal_Master] FOREIGN KEY ([SAppraisal_ID]) REFERENCES [dbo].[T0040_SelfAppraisal_Master] ([SApparisal_ID]),
    CONSTRAINT [FK_T0052_Emp_SelfAppraisal_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([InitiateId]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId])
);

