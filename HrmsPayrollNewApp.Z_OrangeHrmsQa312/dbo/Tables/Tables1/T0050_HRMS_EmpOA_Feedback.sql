CREATE TABLE [dbo].[T0050_HRMS_EmpOA_Feedback] (
    [Emp_OA_ID]     NUMERIC (18)  NOT NULL,
    [Cmp_ID]        NUMERIC (18)  NULL,
    [Initiation_Id] NUMERIC (18)  NULL,
    [Emp_Id]        NUMERIC (18)  NULL,
    [OA_ID]         NUMERIC (18)  NULL,
    [EOA_Column1]   VARCHAR (50)  NULL,
    [EOA_Column2]   VARCHAR (50)  NULL,
    [RM_Comments]   VARCHAR (MAX) NULL,
    [HOD_Comments]  VARCHAR (MAX) NULL,
    [GH_Comments]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0050_HRMS_EmpOA_Feedback] PRIMARY KEY CLUSTERED ([Emp_OA_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_HRMS_EmpOA_Feedback_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_HRMS_EmpOA_Feedback_T0040_HRMS_OtherAssessment_Master] FOREIGN KEY ([OA_ID]) REFERENCES [dbo].[T0040_HRMS_OtherAssessment_Master] ([OA_Id]),
    CONSTRAINT [FK_T0050_HRMS_EmpOA_Feedback_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([Initiation_Id]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0050_HRMS_EmpOA_Feedback_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

