CREATE TABLE [dbo].[T0195_Allowance_Days] (
    [Tran_Id] NUMERIC (18)    NOT NULL,
    [Cmp_Id]  NUMERIC (18)    NULL,
    [AD_ID]   NUMERIC (18)    NULL,
    [Month]   NUMERIC (18)    NULL,
    [Year]    NUMERIC (18)    NULL,
    [Days]    NUMERIC (18, 2) NULL,
    CONSTRAINT [PK_T0195_Allowance_Days] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

