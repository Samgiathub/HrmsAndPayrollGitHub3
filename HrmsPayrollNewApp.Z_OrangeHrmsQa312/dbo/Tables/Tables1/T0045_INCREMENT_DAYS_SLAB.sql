﻿CREATE TABLE [dbo].[T0045_INCREMENT_DAYS_SLAB] (
    [ROW_ID]     INT             IDENTITY (1, 1) NOT NULL,
    [CMP_ID]     NUMERIC (18)    NULL,
    [TRAN_ID]    NUMERIC (18)    NULL,
    [FROM_DAYS]  NUMERIC (18, 2) NULL,
    [TO_DAYS]    NUMERIC (18, 2) NULL,
    [PERCENTAGE] NUMERIC (18, 2) NULL,
    CONSTRAINT [PK__T0045_IN__68DB447D289D02EA] PRIMARY KEY CLUSTERED ([ROW_ID] ASC)
);

