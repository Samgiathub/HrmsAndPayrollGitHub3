CREATE TABLE [dbo].[T0052_HRMS_AttributeFeedback] (
    [EmpAtt_ID]       NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Initiation_Id]   NUMERIC (18)    NULL,
    [Emp_Id]          NUMERIC (18)    NULL,
    [PA_ID]           NUMERIC (18)    NULL,
    [Att_Type]        VARCHAR (5)     NULL,
    [Att_Score]       NUMERIC (18)    NULL,
    [Att_Achievement] NUMERIC (18, 2) NULL,
    [Att_Critical]    NVARCHAR (1000) NULL,
    [Threshold_value] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0052_HRMS_AttributeFeedback] PRIMARY KEY CLUSTERED ([EmpAtt_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0052_HRMS_AttributeFeedback_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0052_HRMS_AttributeFeedback_T0040_HRMS_AttributeMaster] FOREIGN KEY ([PA_ID]) REFERENCES [dbo].[T0040_HRMS_AttributeMaster] ([PA_ID]),
    CONSTRAINT [FK_T0052_HRMS_AttributeFeedback_T0050_HRMS_InitiateAppraisal] FOREIGN KEY ([Initiation_Id]) REFERENCES [dbo].[T0050_HRMS_InitiateAppraisal] ([InitiateId]),
    CONSTRAINT [FK_T0052_HRMS_AttributeFeedback_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

