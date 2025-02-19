CREATE TABLE [dbo].[T0060_Emp_Assessment_View] (
    [Emp_AssessmentView_Id] NUMERIC (18) NOT NULL,
    [Cmp_Id]                NUMERIC (18) NOT NULL,
    [Emp_Id]                NUMERIC (18) NOT NULL,
    [SA_View]               INT          CONSTRAINT [DF_T0060_Emp_Assessment_View_SA_View] DEFAULT ((1)) NOT NULL,
    [KPA_View]              INT          CONSTRAINT [DF_T0060_Emp_Assessment_View_KPA_View] DEFAULT ((1)) NOT NULL,
    [Effective_Date]        DATETIME     NULL,
    CONSTRAINT [FK_T0060_Emp_Assessment_View_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0060_Emp_Assessment_View_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

