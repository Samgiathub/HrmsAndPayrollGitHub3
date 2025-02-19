CREATE TABLE [dbo].[T0060_Appraisal_DesigWeightage] (
    [Desig_weightage_Id]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]                 NUMERIC (18)    NOT NULL,
    [Desig_ID]               NUMERIC (18)    NOT NULL,
    [EKPA_Weightage]         NUMERIC (18, 2) NULL,
    [SA_Weightage]           NUMERIC (18, 2) NULL,
    [Effective_Date]         DATETIME        NULL,
    [PA_Weightage]           NUMERIC (18, 2) NULL,
    [PoA_Weightage]          NUMERIC (18, 2) NULL,
    [EKPA_RestrictWeightage] BIT             NULL,
    [SA_RestrictWeightage]   BIT             NULL,
    CONSTRAINT [PK_T0060_Appraisal_DesigWeightage] PRIMARY KEY CLUSTERED ([Desig_weightage_Id] ASC)
);

