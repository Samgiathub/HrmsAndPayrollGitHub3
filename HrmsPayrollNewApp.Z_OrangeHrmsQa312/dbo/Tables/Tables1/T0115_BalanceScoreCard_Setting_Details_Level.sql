CREATE TABLE [dbo].[T0115_BalanceScoreCard_Setting_Details_Level] (
    [Tran_Id]               NUMERIC (18)    NOT NULL,
    [Cmp_Id]                NUMERIC (18)    NOT NULL,
    [Emp_Id]                NUMERIC (18)    NOT NULL,
    [BSC_Setting_Detail_Id] NUMERIC (18)    NOT NULL,
    [KPI_Id]                NUMERIC (18)    NOT NULL,
    [BSC_Objective]         NVARCHAR (MAX)  NULL,
    [BSC_Measure]           NVARCHAR (200)  NULL,
    [BSC_Target]            NVARCHAR (100)  NULL,
    [BSC_Formula]           NVARCHAR (100)  NULL,
    [BSC_Weight]            NUMERIC (18, 2) NULL,
    [Rpt_Level]             TINYINT         NULL,
    [BSC_Level_Id]          NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0115_BalanceScoreCard_Setting_Details_Level] PRIMARY KEY CLUSTERED ([Tran_Id] ASC),
    CONSTRAINT [FK_T0115_BalanceScoreCard_Setting_Details_Level_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0115_BalanceScoreCard_Setting_Details_Level_T0040_KPI_Master] FOREIGN KEY ([KPI_Id]) REFERENCES [dbo].[T0040_KPI_Master] ([KPI_Id]),
    CONSTRAINT [FK_T0115_BalanceScoreCard_Setting_Details_Level_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0115_BalanceScoreCard_Setting_Details_Level_T0095_BalanceScoreCard_Setting_Details] FOREIGN KEY ([BSC_Setting_Detail_Id]) REFERENCES [dbo].[T0095_BalanceScoreCard_Setting_Details] ([BSC_Setting_Detail_Id]),
    CONSTRAINT [FK_T0115_BalanceScoreCard_Setting_Details_Level_T0110_BalanceScoreCard_Setting_Approval] FOREIGN KEY ([BSC_Level_Id]) REFERENCES [dbo].[T0110_BalanceScoreCard_Setting_Approval] ([BSC_Level_Id])
);

