CREATE TABLE [dbo].[T0501_Sales_Error_Logs] (
    [Tran_ID]     NUMERIC (18)   NOT NULL,
    [Cmp_ID]      NUMERIC (18)   NULL,
    [Row_ID]      NUMERIC (18)   NULL,
    [Error_Code]  VARCHAR (100)  NULL,
    [Error_Desc]  VARCHAR (1000) NULL,
    [For_Date]    DATETIME       NULL,
    [Import_Type] VARCHAR (100)  NULL,
    [KeyGUID]     VARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

