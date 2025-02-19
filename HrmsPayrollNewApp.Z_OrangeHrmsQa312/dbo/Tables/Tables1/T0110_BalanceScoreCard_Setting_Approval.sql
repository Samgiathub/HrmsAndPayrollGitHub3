CREATE TABLE [dbo].[T0110_BalanceScoreCard_Setting_Approval] (
    [BSC_Level_Id]      NUMERIC (18)  NOT NULL,
    [Cmp_Id]            NUMERIC (18)  NOT NULL,
    [Emp_Id]            NUMERIC (18)  NOT NULL,
    [S_Emp_Id]          NUMERIC (18)  NULL,
    [BSC_SettingId]     NUMERIC (18)  NULL,
    [Approval_Date]     DATETIME      NULL,
    [Approval_Comments] VARCHAR (500) NULL,
    [Login_Id]          NUMERIC (18)  NULL,
    [Rpt_Level]         INT           NOT NULL,
    [Approval_Status]   INT           NOT NULL,
    CONSTRAINT [PK_T0110_BalanceScoreCard_Setting_Approval] PRIMARY KEY CLUSTERED ([BSC_Level_Id] ASC),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Setting_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Setting_Approval_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_BalanceScoreCard_Setting_Approval_T0090_BalanceScoreCard_Setting] FOREIGN KEY ([BSC_SettingId]) REFERENCES [dbo].[T0090_BalanceScoreCard_Setting] ([BSC_SettingId])
);

