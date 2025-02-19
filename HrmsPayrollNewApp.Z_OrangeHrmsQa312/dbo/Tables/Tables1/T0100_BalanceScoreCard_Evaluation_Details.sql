CREATE TABLE [dbo].[T0100_BalanceScoreCard_Evaluation_Details] (
    [Emp_BSC_Review_Detail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]                   NUMERIC (18)    NOT NULL,
    [Emp_Id]                   NUMERIC (18)    NOT NULL,
    [Emp_BSC_Review_Id]        NUMERIC (18)    NULL,
    [BSC_Setting_Detail_Id]    NUMERIC (18)    NULL,
    [Actual]                   NVARCHAR (100)  NULL,
    [Score]                    VARCHAR (50)    NULL,
    [WeightedScore]            NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0100_BalanceScoreCard_Evaluation_Details] PRIMARY KEY CLUSTERED ([Emp_BSC_Review_Detail_Id] ASC),
    CONSTRAINT [FK_T0100_BalanceScoreCard_Evaluation_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_BalanceScoreCard_Evaluation_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0100_BalanceScoreCard_Evaluation_Details_T0095_BalanceScoreCard_Evaluation] FOREIGN KEY ([Emp_BSC_Review_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Evaluation] ([Emp_BSC_Review_Id]),
    CONSTRAINT [FK_T0100_BalanceScoreCard_Evaluation_Details_T0095_BalanceScoreCard_Setting_Details] FOREIGN KEY ([BSC_Setting_Detail_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Setting_Details] ([BSC_Setting_Detail_Id])
);

