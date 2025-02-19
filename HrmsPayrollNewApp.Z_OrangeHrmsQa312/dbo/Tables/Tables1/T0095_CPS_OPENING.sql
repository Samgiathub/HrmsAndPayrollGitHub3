CREATE TABLE [dbo].[T0095_CPS_OPENING] (
    [Tran_ID]     NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NULL,
    [Emp_ID]      NUMERIC (18)    NULL,
    [For_Date]    DATETIME        NULL,
    [CPS_Opening] NUMERIC (18, 2) NULL,
    [SystemDate]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

