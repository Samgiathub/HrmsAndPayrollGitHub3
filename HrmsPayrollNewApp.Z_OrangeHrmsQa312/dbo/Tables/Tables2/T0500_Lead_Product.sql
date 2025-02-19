CREATE TABLE [dbo].[T0500_Lead_Product] (
    [Lead_Product_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Lead_Product_Name] VARCHAR (100) NULL,
    [Cmp_ID]            NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Lead_Product_ID] ASC)
);

