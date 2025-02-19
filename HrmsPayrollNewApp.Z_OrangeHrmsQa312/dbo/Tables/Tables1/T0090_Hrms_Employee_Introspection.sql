CREATE TABLE [dbo].[T0090_Hrms_Employee_Introspection] (
    [Emp_Inspection_Id] NUMERIC (18)    NOT NULL,
    [Appr_Detail_Id]    NUMERIC (18)    NOT NULL,
    [For_Date]          DATETIME        NULL,
    [Que_Id]            NUMERIC (18)    NOT NULL,
    [Answer]            NVARCHAR (1000) NULL,
    [Emp_Status]        INT             NULL,
    [Inspection_Status] INT             NULL,
    [Que_Rate]          INT             NULL,
    [Cmp_ID]            NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0090_Hrms_Employee_Introspection] PRIMARY KEY CLUSTERED ([Emp_Inspection_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Hrms_Employee_Introspection_T0055_HRMS_APPR_FEEDBACK_QUESTION] FOREIGN KEY ([Que_Id]) REFERENCES [dbo].[T0055_HRMS_APPR_FEEDBACK_QUESTION] ([Que_id]),
    CONSTRAINT [FK_T0090_Hrms_Employee_Introspection_T0090_Hrms_Employee_Introspection] FOREIGN KEY ([Appr_Detail_Id]) REFERENCES [dbo].[T0090_Hrms_Appraisal_Initiation_Detail] ([Appr_Detail_Id])
);

