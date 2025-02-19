CREATE TABLE [dbo].[T0090_Hrms_Appraisal_Initiation] (
    [Appr_Int_Id]     NUMERIC (18) NOT NULL,
    [For_Date]        DATETIME     NOT NULL,
    [Login_Id]        NUMERIC (18) NOT NULL,
    [Invoke_Emp]      INT          NULL,
    [Invoke_Superior] INT          NULL,
    [Invoke_Team]     INT          NULL,
    [Cmp_Id]          NUMERIC (18) NOT NULL,
    [Branch_Id]       NUMERIC (18) NULL,
    [Status]          NUMERIC (18) CONSTRAINT [DF_T0090_Hrms_Appraisal_Initiation_Status] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0090_Hrms_Appraisal_Initiation] PRIMARY KEY CLUSTERED ([Appr_Int_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_Hrms_Appraisal_Initiation_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_Hrms_Appraisal_Initiation_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_Id]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

