CREATE TABLE [dbo].[T0040_CompanyWise_Branch_Table] (
    [Tran_Id]        NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Branch_Id]      VARCHAR (255) NULL,
    [Account_No]     VARCHAR (255) NULL,
    [Bank_ID]        NUMERIC (18)  NULL,
    [Effective_Date] DATETIME      NULL,
    [System_Date]    DATETIME      NULL,
    [CMP_ID]         NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_CompanyWise_Branch_Table] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 95)
);

