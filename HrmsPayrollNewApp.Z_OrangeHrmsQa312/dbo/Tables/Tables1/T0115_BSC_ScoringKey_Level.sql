CREATE TABLE [dbo].[T0115_BSC_ScoringKey_Level] (
    [Row_Id]                NUMERIC (18)   NOT NULL,
    [Cmp_Id]                NUMERIC (18)   NOT NULL,
    [Tran_Id]               NUMERIC (18)   NOT NULL,
    [BSC_Setting_Detail_Id] NUMERIC (18)   NULL,
    [Key_Name]              VARCHAR (50)   NULL,
    [Key_Value]             NVARCHAR (100) NULL,
    [BSC_Level_Id]          NUMERIC (18)   NULL,
    [Rpt_Level]             INT            NULL,
    CONSTRAINT [PK_T0115_BSC_ScoringKey_Level] PRIMARY KEY CLUSTERED ([Row_Id] ASC),
    CONSTRAINT [FK_T0115_BSC_ScoringKey_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_BSC_ScoringKey_Level_T0095_BalanceScoreCard_Setting_Details] FOREIGN KEY ([BSC_Setting_Detail_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Setting_Details] ([BSC_Setting_Detail_Id]),
    CONSTRAINT [FK_T0115_BSC_ScoringKey_Level_T0110_BalanceScoreCard_Setting_Approval] FOREIGN KEY ([BSC_Level_Id]) REFERENCES [dbo].[T0110_BalanceScoreCard_Setting_Approval] ([BSC_Level_Id]),
    CONSTRAINT [FK_T0115_BSC_ScoringKey_Level_T0115_BalanceScoreCard_Setting_Details_Level] FOREIGN KEY ([Tran_Id]) REFERENCES [dbo].[T0115_BalanceScoreCard_Setting_Details_Level] ([Tran_Id])
);

