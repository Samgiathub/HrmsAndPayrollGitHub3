CREATE TABLE [dbo].[T0040_BONUS_CALC] (
    [Tran_ID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [For_Date]           DATETIME        NOT NULL,
    [Branch_ID]          NUMERIC (18)    NOT NULL,
    [Particulars]        VARCHAR (512)   NOT NULL,
    [Login_ID]           NUMERIC (18)    NOT NULL,
    [SystemDate]         DATETIME        NOT NULL,
    [Bonus_Calculate_On] NUMERIC (18, 2) DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_T0040_BONUS_CALC] PRIMARY KEY NONCLUSTERED ([Tran_ID] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0040_BONUS_CALC_BRANCH_ID_FOR_DATE]
    ON [dbo].[T0040_BONUS_CALC]([For_Date] DESC, [Branch_ID] ASC);

