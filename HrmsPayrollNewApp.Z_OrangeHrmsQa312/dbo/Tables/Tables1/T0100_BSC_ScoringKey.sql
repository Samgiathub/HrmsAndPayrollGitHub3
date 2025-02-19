CREATE TABLE [dbo].[T0100_BSC_ScoringKey] (
    [BSC_ScoringKey_Id]     NUMERIC (18)   NOT NULL,
    [Cmp_Id]                NUMERIC (18)   NOT NULL,
    [BSC_Setting_Detail_Id] NUMERIC (18)   NULL,
    [Key_Name]              VARCHAR (50)   NULL,
    [Key_Value]             NVARCHAR (100) NULL,
    CONSTRAINT [PK_T0100_BSC_ScoringKey] PRIMARY KEY CLUSTERED ([BSC_ScoringKey_Id] ASC),
    CONSTRAINT [FK_T0100_BSC_ScoringKey_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_BSC_ScoringKey_T0095_BalanceScoreCard_Setting_Details] FOREIGN KEY ([BSC_Setting_Detail_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Setting_Details] ([BSC_Setting_Detail_Id])
);

