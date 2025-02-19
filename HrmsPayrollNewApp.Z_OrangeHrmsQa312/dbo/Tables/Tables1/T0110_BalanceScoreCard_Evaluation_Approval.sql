CREATE TABLE [dbo].[T0110_BalanceScoreCard_Evaluation_Approval] (
    [Emp_BSC_Review_Level_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                  NUMERIC (18)  NOT NULL,
    [Emp_Id]                  NUMERIC (18)  NOT NULL,
    [S_Emp_Id]                NUMERIC (18)  NULL,
    [Emp_BSC_Review_Id]       NUMERIC (18)  NULL,
    [Approval_Date]           DATETIME      NULL,
    [Approval_Comments]       VARCHAR (300) NULL,
    [Login_Id]                NUMERIC (18)  NULL,
    [Rpt_Level]               INT           NULL,
    [Approval_Status]         INT           NULL,
    CONSTRAINT [PK_T0110_BalanceScoreCard_Evaluation_Approval] PRIMARY KEY CLUSTERED ([Emp_BSC_Review_Level_Id] ASC),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Evaluation_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Evaluation_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Evaluation_Approval_T0095_BalanceScoreCard_Evaluation] FOREIGN KEY ([Emp_BSC_Review_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Evaluation] ([Emp_BSC_Review_Id])
);

