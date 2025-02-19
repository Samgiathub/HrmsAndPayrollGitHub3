CREATE TABLE [dbo].[T0040_SelfAppraisal_Master] (
    [SApparisal_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [SApparisal_Content] NVARCHAR (1000) NULL,
    [SAppraisal_Sort]    INT             NULL,
    [SDept_Id]           VARCHAR (800)   NULL,
    [SIsMandatory]       INT             CONSTRAINT [DF_T0040_SelfAppraisal_Master_SIsMandatory] DEFAULT ((0)) NULL,
    [SType]              INT             CONSTRAINT [DF_T0040_SelfAppraisal_Master_SType] DEFAULT ((0)) NULL,
    [SWeight]            INT             CONSTRAINT [DF_T0040_SelfAppraisal_Master_SWeight] DEFAULT ((0)) NULL,
    [Effective_Date]     DATETIME        NULL,
    [Ref_SID]            NUMERIC (18)    NULL,
    [SKPAWeight]         NUMERIC (18)    NULL,
    [SCateg_Id]          VARCHAR (MAX)   NULL,
    [SBranch_Id]         VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_T0040_SelfAppraisal_Master] PRIMARY KEY CLUSTERED ([SApparisal_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_SelfAppraisal_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

