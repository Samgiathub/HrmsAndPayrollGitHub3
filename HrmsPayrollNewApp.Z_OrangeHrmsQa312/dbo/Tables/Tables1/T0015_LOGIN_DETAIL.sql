﻿CREATE TABLE [dbo].[T0015_LOGIN_DETAIL] (
    [Login_ID]   NUMERIC (18) NOT NULL,
    [Cmp_ID]     NUMERIC (18) NOT NULL,
    [Ip_Address] VARCHAR (20) NOT NULL,
    [Sys_Date]   DATETIME     NOT NULL,
    CONSTRAINT [PK_T0015_LOGIN_DETAIL] PRIMARY KEY CLUSTERED ([Login_ID] ASC, [Sys_Date] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0015_LOGIN_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0015_LOGIN_DETAIL_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID])
);

