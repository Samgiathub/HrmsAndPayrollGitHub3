CREATE TABLE [dbo].[T0095_GPF_OPENING] (
    [Cmp_ID]      NUMERIC (18)    NOT NULL,
    [Tran_ID]     NUMERIC (18)    NOT NULL,
    [Emp_ID]      NUMERIC (18)    NOT NULL,
    [For_Date]    DATETIME        NOT NULL,
    [GPF_Opening] NUMERIC (18, 4) NOT NULL,
    [SystemDate]  DATETIME        NULL
);

