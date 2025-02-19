CREATE TABLE [dbo].[T0040_MOBILE_STORE_MASTER] (
    [Store_ID]    NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]      NUMERIC (18)  NOT NULL,
    [Store_Code]  VARCHAR (10)  NULL,
    [Store_Name]  VARCHAR (100) NULL,
    [System_Date] DATETIME      NULL,
    [Login_ID]    NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Store_ID] ASC) WITH (FILLFACTOR = 95)
);

