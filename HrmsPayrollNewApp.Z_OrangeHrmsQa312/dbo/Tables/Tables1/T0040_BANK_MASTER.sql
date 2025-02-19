CREATE TABLE [dbo].[T0040_BANK_MASTER] (
    [Bank_ID]          NUMERIC (18)  NOT NULL,
    [Cmp_Id]           NUMERIC (18)  NOT NULL,
    [Bank_Code]        VARCHAR (10)  NOT NULL,
    [Bank_Name]        VARCHAR (100) NOT NULL,
    [Bank_Ac_No]       VARCHAR (30)  NOT NULL,
    [Bank_Address]     VARCHAR (250) NOT NULL,
    [Bank_Branch_Name] VARCHAR (50)  NOT NULL,
    [Bank_City]        VARCHAR (50)  NOT NULL,
    [Is_Default]       VARCHAR (1)   NOT NULL,
    [Bank_BSR_Code]    VARCHAR (50)  NULL,
    [ClientCode]       NVARCHAR (50) NULL,
    [Company_Branch]   VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_BANK_MASTER] PRIMARY KEY CLUSTERED ([Bank_ID] ASC) WITH (FILLFACTOR = 80)
);

