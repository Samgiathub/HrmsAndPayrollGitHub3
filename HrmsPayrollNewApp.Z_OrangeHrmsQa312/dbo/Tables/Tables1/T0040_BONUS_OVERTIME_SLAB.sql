CREATE TABLE [dbo].[T0040_BONUS_OVERTIME_SLAB] (
    [Tran_ID]        INT             IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Branch_ID]      NUMERIC (18)    NULL,
    [Effective_Date] DATETIME        NULL,
    [Start_Time]     VARCHAR (500)   NULL,
    [From_Min]       NUMERIC (18)    NULL,
    [To_Min]         NUMERIC (18)    NULL,
    [Amount]         NUMERIC (18, 2) NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

