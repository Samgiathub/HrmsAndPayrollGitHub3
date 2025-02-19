CREATE TABLE [dbo].[T0190_BONUS_DETAIL] (
    [Bonus_Tran_ID]                    NUMERIC (18)    NOT NULL,
    [Bonus_ID]                         NUMERIC (18)    NOT NULL,
    [Cmp_ID]                           NUMERIC (18)    NOT NULL,
    [Bonus_Calculated_Amount]          NUMERIC (18)    NOT NULL,
    [Bonus_Amount]                     NUMERIC (18, 2) NOT NULL,
    [Month_Date]                       DATETIME        NOT NULL,
    [Present_Days]                     NUMERIC (18, 2) CONSTRAINT [DF_T0190_BONUS_DETAIL_Present_Days] DEFAULT ((0)) NOT NULL,
    [Working_Days]                     NUMERIC (18, 2) CONSTRAINT [DF_T0190_BONUS_DETAIL_Working_Days] DEFAULT ((0)) NOT NULL,
    [Monthly_Ex_Gratia_Calculated_Amt] NUMERIC (18, 5) NULL,
    CONSTRAINT [PK_T0190_BONUS_DETAIL] PRIMARY KEY CLUSTERED ([Bonus_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0190_BONUS_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0190_BONUS_DETAIL_T0180_BONUS] FOREIGN KEY ([Bonus_ID]) REFERENCES [dbo].[T0180_BONUS] ([Bonus_ID])
);

