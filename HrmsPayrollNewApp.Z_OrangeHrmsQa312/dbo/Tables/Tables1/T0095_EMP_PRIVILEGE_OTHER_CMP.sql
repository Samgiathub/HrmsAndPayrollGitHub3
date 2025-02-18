﻿CREATE TABLE [dbo].[T0095_EMP_PRIVILEGE_OTHER_CMP] (
    [Tran_id]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]         NUMERIC (18) NOT NULL,
    [Emp_id]         NUMERIC (18) NOT NULL,
    [O_Cmp_id]       NUMERIC (18) NOT NULL,
    [O_Privilege_id] NUMERIC (18) NOT NULL,
    [is_active]      TINYINT      CONSTRAINT [DF_T0095_EMP_PRIVILEGE_OTHER_CMP_is_active] DEFAULT ((1)) NOT NULL,
    [System_Date]    DATETIME     CONSTRAINT [DF_T0095_EMP_PRIVILEGE_OTHER_CMP_System_Date] DEFAULT (getdate()) NOT NULL,
    [Last_Updated]   DATETIME     NULL,
    [Login_ID]       NUMERIC (18) CONSTRAINT [DF_T0095_EMP_PRIVILEGE_OTHER_CMP_Login_ID] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0095_EMP_PRIVILEGE_OTHER_CMP] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

