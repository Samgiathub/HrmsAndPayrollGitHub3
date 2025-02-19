CREATE TABLE [dbo].[T0050_CANTEEN_DETAIL] (
    [Cmp_Id]          NUMERIC (18)    NOT NULL,
    [Cnt_Id]          NUMERIC (18)    NOT NULL,
    [Tran_Id]         NUMERIC (18)    NOT NULL,
    [Effective_Date]  DATETIME        NOT NULL,
    [Amount]          NUMERIC (18, 2) NULL,
    [grd_id]          NUMERIC (18)    CONSTRAINT [DF_T0050_CANTEEN_DETAIL_grd_id] DEFAULT ((0)) NOT NULL,
    [Subsidy_Amount]  NUMERIC (18, 2) CONSTRAINT [DF_T0050_CANTEEN_DETAIL_Subsidy_Amount] DEFAULT ((0)) NOT NULL,
    [Total_Amount]    NUMERIC (18, 2) CONSTRAINT [DF_T0050_CANTEEN_DETAIL_Total_Amount] DEFAULT ((0)) NOT NULL,
    [Exemption_Count] INT             NULL,
    CONSTRAINT [FK_T0050_CANTEEN_DETAIL_T0050_CANTEEN_MASTER] FOREIGN KEY ([Cnt_Id]) REFERENCES [dbo].[T0050_CANTEEN_MASTER] ([Cnt_Id])
);

