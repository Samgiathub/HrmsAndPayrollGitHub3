﻿CREATE TABLE [dbo].[T0050_LEAVE_CF_MONTHLY_SETTING] (
    [Leave_Tran_ID]         NUMERIC (18)    NOT NULL,
    [Leave_ID]              NUMERIC (18)    NOT NULL,
    [For_Date]              DATETIME        NOT NULL,
    [Cmp_Id]                NUMERIC (18)    NOT NULL,
    [CF_M_Days]             NUMERIC (18, 2) NOT NULL,
    [Effective_Date]        DATETIME        NULL,
    [Type_ID]               NUMERIC (18)    NULL,
    [CF_M_DaysAfterJoining] NUMERIC (9, 2)  NULL,
    CONSTRAINT [PK_T0050_LEAVE_CF_MONTHLY_SETTING] PRIMARY KEY CLUSTERED ([Leave_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0050_LEAVE_CF_MONTHLY_SETTING_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0050_LEAVE_CF_MONTHLY_SETTING_T0040_LEAVE_MASTER] FOREIGN KEY ([Leave_ID]) REFERENCES [dbo].[T0040_LEAVE_MASTER] ([Leave_ID])
);

