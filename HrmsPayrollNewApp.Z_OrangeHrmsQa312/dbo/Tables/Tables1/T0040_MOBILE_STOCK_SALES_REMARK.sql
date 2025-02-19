CREATE TABLE [dbo].[T0040_MOBILE_STOCK_SALES_REMARK] (
    [Mobile_Remark_ID] NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18)  NOT NULL,
    [Remark_Name]      VARCHAR (250) NULL,
    [System_Date]      DATETIME      NULL,
    [Login_ID]         NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Mobile_Remark_ID] ASC) WITH (FILLFACTOR = 95)
);

