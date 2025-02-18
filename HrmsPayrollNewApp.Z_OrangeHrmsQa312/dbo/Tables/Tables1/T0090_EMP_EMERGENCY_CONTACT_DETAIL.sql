﻿CREATE TABLE [dbo].[T0090_EMP_EMERGENCY_CONTACT_DETAIL] (
    [Emp_ID]         NUMERIC (18)  NOT NULL,
    [Row_ID]         NUMERIC (18)  NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Name]           VARCHAR (100) NOT NULL,
    [RelationShip]   VARCHAR (20)  NOT NULL,
    [Home_Tel_No]    VARCHAR (30)  NOT NULL,
    [Home_Mobile_No] VARCHAR (30)  NOT NULL,
    [Work_Tel_No]    VARCHAR (30)  NOT NULL,
    CONSTRAINT [PK_T0090_EMP_EMERGENCY_CONTACT_DETAIL] PRIMARY KEY CLUSTERED ([Emp_ID] ASC, [Row_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_EMP_EMERGENCY_CONTACT_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0090_EMP_EMERGENCY_CONTACT_DETAIL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);

