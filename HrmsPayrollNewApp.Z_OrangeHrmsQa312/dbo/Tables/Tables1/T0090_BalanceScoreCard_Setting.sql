CREATE TABLE [dbo].[T0090_BalanceScoreCard_Setting] (
    [BSC_SettingId] NUMERIC (18) NOT NULL,
    [Cmp_Id]        NUMERIC (18) NOT NULL,
    [Emp_Id]        NUMERIC (18) NOT NULL,
    [BSC_Status]    NUMERIC (18) NOT NULL,
    [FinYear]       INT          NOT NULL,
    [Createddate]   DATETIME     NOT NULL,
    [ModifiedDate]  DATETIME     NULL,
    [CreatedBy]     NUMERIC (18) NOT NULL,
    [ModifiedBy]    NUMERIC (18) NULL,
    CONSTRAINT [PK_T0090_BalanceScoreCard_Setting] PRIMARY KEY CLUSTERED ([BSC_SettingId] ASC),
    CONSTRAINT [FK_T0090_BalanceScoreCard_Setting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_BalanceScoreCard_Setting_T0080_EMP_MASTER] FOREIGN KEY ([Emp_Id]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

