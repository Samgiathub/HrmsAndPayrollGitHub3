CREATE TABLE [dbo].[T0040_BONUS_LATE_COMING_SLAB] (
    [Tran_ID]        INT             IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Branch_ID]      NUMERIC (18)    NULL,
    [Effective_Date] DATETIME        NULL,
    [Typeid]         NUMERIC (18)    NULL,
    [From_Min]       NUMERIC (18)    NULL,
    [To_Min]         NUMERIC (18)    NULL,
    [Amount]         NUMERIC (18, 2) NULL,
    [Slabpertime]    NUMERIC (18)    NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

