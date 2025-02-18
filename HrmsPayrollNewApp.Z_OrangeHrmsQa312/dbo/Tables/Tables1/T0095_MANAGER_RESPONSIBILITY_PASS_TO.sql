﻿CREATE TABLE [dbo].[T0095_MANAGER_RESPONSIBILITY_PASS_TO] (
    [Tran_id]        NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Manger_Emp_id]  NUMERIC (18)  NULL,
    [Pass_To_Emp_id] NUMERIC (18)  NULL,
    [From_date]      DATETIME      NULL,
    [To_date]        DATETIME      NULL,
    [Type]           NVARCHAR (50) NULL,
    [timestamp]      DATETIME      CONSTRAINT [DF_T0095_MANAGER_RESPONSIBILITY_PASS_TO_timestamp] DEFAULT (getdate()) NULL,
    [Cmp_id]         NUMERIC (18)  CONSTRAINT [DF_T0095_MANAGER_RESPONSIBILITY_PASS_TO_Cmp_id] DEFAULT ((0)) NOT NULL,
    [is_manual]      TINYINT       CONSTRAINT [DF_T0095_MANAGER_RESPONSIBILITY_PASS_TO_is_manual] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0095_MANAGER_RESPONSIBILITY_PASS_TO] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

