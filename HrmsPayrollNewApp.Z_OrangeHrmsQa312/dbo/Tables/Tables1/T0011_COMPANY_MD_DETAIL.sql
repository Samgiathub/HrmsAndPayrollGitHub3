﻿CREATE TABLE [dbo].[T0011_COMPANY_MD_DETAIL] (
    [MD_ID]          NUMERIC (18)   NOT NULL,
    [Cmp_ID]         NUMERIC (18)   NOT NULL,
    [MD_Name]        VARCHAR (100)  NOT NULL,
    [MD_Designation] VARCHAR (30)   NOT NULL,
    [MD_Street_1]    VARCHAR (50)   NOT NULL,
    [MD_Street_2]    VARCHAR (50)   NOT NULL,
    [MD_Street_3]    VARCHAR (50)   NOT NULL,
    [MD_City]        VARCHAR (30)   NOT NULL,
    [MD_State]       VARCHAR (30)   NOT NULL,
    [MD_Pin_Code]    VARCHAR (30)   NOT NULL,
    [MD_Tel_No]      VARCHAR (50)   NOT NULL,
    [MD_Email]       VARCHAR (100)  NOT NULL,
    [MD_Share]       NUMERIC (5, 2) NOT NULL,
    [MD_Type]        TINYINT        NOT NULL,
    CONSTRAINT [PK_T0011_COMPANY_MD_DETAIL] PRIMARY KEY CLUSTERED ([MD_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0011_COMPANY_MD_DETAIL_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

