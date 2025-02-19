CREATE TABLE [dbo].[T0090_HRMS_FINAL_SCORE] (
    [Row_ID]            NUMERIC (18)    NOT NULL,
    [Emp_ID]            NUMERIC (18)    NOT NULL,
    [S_EMP_ID]          NUMERIC (18)    NULL,
    [Cmp_ID]            NUMERIC (18)    NULL,
    [For_Date]          DATETIME        NULL,
    [Title_Name]        NVARCHAR (50)   NULL,
    [Total_Score]       NUMERIC (18, 2) NULL,
    [Eval_Score]        NUMERIC (18, 2) NULL,
    [Percentage]        NUMERIC (18, 2) NULL,
    [Emp_Status]        NUMERIC (18)    NULL,
    [Inspection_status] NUMERIC (18)    NULL,
    [Appr_Int_Id]       NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0090_HRMS_FINAL_SCORE] PRIMARY KEY CLUSTERED ([Row_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_FINAL_SCORE_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_HRMS_FINAL_SCORE_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0090_HRMS_FINAL_SCORE_T0090_Hrms_Appraisal_Initiation] FOREIGN KEY ([Appr_Int_Id]) REFERENCES [dbo].[T0090_Hrms_Appraisal_Initiation] ([Appr_Int_Id])
);

