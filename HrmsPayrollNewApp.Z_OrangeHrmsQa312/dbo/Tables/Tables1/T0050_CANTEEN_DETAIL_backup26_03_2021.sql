CREATE TABLE [dbo].[T0050_CANTEEN_DETAIL_backup26_03_2021] (
    [Cmp_Id]          NUMERIC (18)    NOT NULL,
    [Cnt_Id]          NUMERIC (18)    NOT NULL,
    [Tran_Id]         NUMERIC (18)    NOT NULL,
    [Effective_Date]  DATETIME        NOT NULL,
    [Amount]          NUMERIC (18, 2) NULL,
    [grd_id]          NUMERIC (18)    NOT NULL,
    [Subsidy_Amount]  NUMERIC (18, 2) NOT NULL,
    [Total_Amount]    NUMERIC (18, 2) NOT NULL,
    [Exemption_Count] INT             NULL
);

