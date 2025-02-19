CREATE TABLE [dbo].[T0050_SubBranch] (
    [SubBranch_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]                NUMERIC (18)   NULL,
    [Branch_ID]             NUMERIC (18)   NULL,
    [SubBranch_Code]        NVARCHAR (50)  NULL,
    [SubBranch_Name]        NVARCHAR (100) NULL,
    [SubBranch_Description] NVARCHAR (250) NULL,
    [IsActive]              TINYINT        NULL,
    [InActive_EffeDate]     DATETIME       NULL,
    [City_id]               NUMERIC (18)   DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0050_SubBranch] PRIMARY KEY CLUSTERED ([SubBranch_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_SubBranch_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_SubBranch_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID])
);

