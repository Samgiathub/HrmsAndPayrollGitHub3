﻿CREATE TABLE [dbo].[T0040_INCREMENT_CALC] (
    [TRAN_ID]     NUMERIC (18)  NOT NULL,
    [CMP_ID]      NUMERIC (18)  NOT NULL,
    [FOR_DATE]    DATETIME      NOT NULL,
    [BRANCH_ID]   NUMERIC (18)  NOT NULL,
    [PARTICULARS] VARCHAR (MAX) NULL,
    [LOGIN_ID]    NUMERIC (18)  NULL,
    [SYSTEMDATE]  DATETIME      NULL,
    CONSTRAINT [PK_T0040_INCREMENT_CALC_1] PRIMARY KEY NONCLUSTERED ([TRAN_ID] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [IX_T0040_INCREMENT_CALC_FORDATE_BRANCHID]
    ON [dbo].[T0040_INCREMENT_CALC]([FOR_DATE] DESC, [BRANCH_ID] ASC);

