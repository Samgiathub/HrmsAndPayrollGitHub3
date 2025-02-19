CREATE TABLE [dbo].[T0060_Appraisal_EmpWeightage] (
    [Emp_Weightage_Id]       NUMERIC (18)    NOT NULL,
    [Cmp_Id]                 NUMERIC (18)    NOT NULL,
    [Emp_Id]                 NUMERIC (18)    NOT NULL,
    [EKPA_Weightage]         NUMERIC (18, 2) NULL,
    [SA_Weightage]           NUMERIC (18, 2) NULL,
    [Effective_Date]         DATETIME        NULL,
    [PA_Weightage]           NUMERIC (18, 2) NULL,
    [PoA_Weightage]          NUMERIC (18, 2) NULL,
    [EKPA_RestrictWeightage] BIT             CONSTRAINT [DF_T0060_Appraisal_EmpWeightage_EKPA_RestrictWeightage] DEFAULT ((0)) NULL,
    [SA_RestrictWeightage]   BIT             CONSTRAINT [DF_T0060_Appraisal_EmpWeightage_SA_RestrictWeightage] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0060_Appraisal_EmpWeightage] PRIMARY KEY CLUSTERED ([Emp_Weightage_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0060_Appraisal_EmpWeightage_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_Appraisal_EmpWeightage_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

