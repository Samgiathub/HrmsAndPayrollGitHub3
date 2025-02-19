CREATE TABLE [dbo].[T0095_BalanceScoreCard_Setting_Details] (
    [BSC_Setting_Detail_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]                NUMERIC (18)    NOT NULL,
    [BSC_SettingId]         NUMERIC (18)    NOT NULL,
    [Emp_Id]                NUMERIC (18)    NOT NULL,
    [KPI_Id]                NUMERIC (18)    NOT NULL,
    [BSC_Objective]         NVARCHAR (MAX)  NULL,
    [BSC_Measure]           NVARCHAR (200)  NULL,
    [BSC_Target]            NVARCHAR (100)  NULL,
    [BSC_Formula]           NVARCHAR (100)  NULL,
    [BSC_Weight]            NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0095_BalanceScoreCard_Setting_Details] PRIMARY KEY CLUSTERED ([BSC_Setting_Detail_Id] ASC),
    CONSTRAINT [FK_T0095_BalanceScoreCard_Setting_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0095_BalanceScoreCard_Setting_Details_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0095_BalanceScoreCard_Setting_Details_T0090_BalanceScoreCard_Setting] FOREIGN KEY ([BSC_SettingId]) REFERENCES [dbo].[T0090_BalanceScoreCard_Setting] ([BSC_SettingId])
);

