CREATE TABLE [dbo].[T0011_COMPANY_DETAIL] (
    [Tran_Id]         INT            IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]          NUMERIC (18)   NULL,
    [Cmp_Name]        VARCHAR (100)  NULL,
    [Cmp_Address]     VARCHAR (250)  NULL,
    [Old_Cmp_Name]    VARCHAR (100)  NULL,
    [Old_Cmp_Address] VARCHAR (250)  NULL,
    [LoginId]         NUMERIC (18)   NULL,
    [Effect_Date]     DATETIME       NULL,
    [System_Date]     DATETIME       NULL,
    [Cmp_Header]      VARCHAR (1000) NULL,
    [Cmp_Footer]      VARCHAR (1000) NULL,
    CONSTRAINT [PK_T0011_COMPANY_DETAIL] PRIMARY KEY NONCLUSTERED ([Tran_Id] ASC)
);

