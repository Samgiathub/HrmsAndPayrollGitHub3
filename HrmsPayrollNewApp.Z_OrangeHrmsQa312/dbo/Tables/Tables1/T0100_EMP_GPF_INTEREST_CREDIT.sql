﻿CREATE TABLE [dbo].[T0100_EMP_GPF_INTEREST_CREDIT] (
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Tran_ID]       NUMERIC (18)    NOT NULL,
    [Emp_ID]        NUMERIC (18)    NOT NULL,
    [AD_ID]         NUMERIC (18)    NOT NULL,
    [From_Date]     DATETIME        NOT NULL,
    [To_Date]       DATETIME        NOT NULL,
    [Year_St_Date]  DATETIME        NOT NULL,
    [Year_End_Date] DATETIME        NOT NULL,
    [Amount]        NUMERIC (18, 4) NOT NULL,
    [SystemDate]    DATETIME        NULL,
    CONSTRAINT [PK_T0100_EMP_GPF_INTEREST_CREDIT] PRIMARY KEY NONCLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0100_EMP_GPF_INTEREST_CREDIT]
    ON [dbo].[T0100_EMP_GPF_INTEREST_CREDIT]([Emp_ID] ASC, [From_Date] ASC, [AD_ID] ASC) WITH (FILLFACTOR = 80);

