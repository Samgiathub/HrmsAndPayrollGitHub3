CREATE TABLE [dbo].[T0190_DAILY_AD_DETAIL_IMPORT] (
    [Tran_ID]     NUMERIC (18)  NOT NULL,
    [Emp_ID]      NUMERIC (18)  NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NOT NULL,
    [AD_ID]       NUMERIC (18)  NOT NULL,
    [Import_Date] DATETIME      NOT NULL,
    [For_Date]    DATETIME      NOT NULL,
    [Amount]      NUMERIC (18)  NOT NULL,
    [Comment]     VARCHAR (200) NULL
);

