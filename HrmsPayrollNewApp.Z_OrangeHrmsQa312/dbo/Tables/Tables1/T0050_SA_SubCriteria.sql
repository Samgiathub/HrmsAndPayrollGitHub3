CREATE TABLE [dbo].[T0050_SA_SubCriteria] (
    [SAppCriteria_ID]      NUMERIC (18)  NOT NULL,
    [Cmp_ID]               NUMERIC (18)  NOT NULL,
    [SApparisal_ID]        NUMERIC (18)  NOT NULL,
    [SAppCriteria_Content] VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_T0050_SA_SubCriteria] PRIMARY KEY CLUSTERED ([SAppCriteria_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_SA_SubCriteria_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_SA_SubCriteria_T0040_SelfAppraisal_Master] FOREIGN KEY ([SApparisal_ID]) REFERENCES [dbo].[T0040_SelfAppraisal_Master] ([SApparisal_ID])
);

