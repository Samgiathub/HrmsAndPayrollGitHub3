CREATE TABLE [dbo].[T0040_INCOME_TAX_SETTING] (
    [Cmp_ID]     NUMERIC (18)   NOT NULL,
    [Tran_ID]    NUMERIC (18)   NOT NULL,
    [For_Date]   DATETIME       NOT NULL,
    [Row_Id]     NUMERIC (18)   NOT NULL,
    [From_Limit] NUMERIC (18)   NOT NULL,
    [To_Limit]   NUMERIC (18)   NOT NULL,
    [Percentage] NUMERIC (6, 2) NULL,
    [Flag]       CHAR (1)       NOT NULL,
    CONSTRAINT [PK_T0040_INCOME_TAX_SETTING] PRIMARY KEY CLUSTERED ([Cmp_ID] ASC, [Tran_ID] ASC, [For_Date] ASC, [Row_Id] ASC) WITH (FILLFACTOR = 80)
);

