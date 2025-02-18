﻿CREATE TABLE [dbo].[T0095_MANAGERS] (
    [Tran_id]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_MANAGERS_Cmp_id] DEFAULT ((0)) NOT NULL,
    [Emp_id]         NUMERIC (18) CONSTRAINT [DF_T0095_MANAGERS_Emp_id] DEFAULT ((0)) NOT NULL,
    [branch_id]      NUMERIC (18) CONSTRAINT [DF_T0095_MANAGERS_branch_id] DEFAULT ((0)) NOT NULL,
    [Effective_Date] DATETIME     NULL,
    CONSTRAINT [PK_T0095_MANAGERS] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

