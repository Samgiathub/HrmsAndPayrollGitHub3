CREATE TABLE [dbo].[T0040_Product_Master] (
    [Product_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]       NUMERIC (18)  NOT NULL,
    [Login_ID]     NUMERIC (18)  NOT NULL,
    [Product_Name] VARCHAR (200) NOT NULL,
    [System_Date]  DATETIME      NULL,
    CONSTRAINT [PK_T0040_Product_Master] PRIMARY KEY CLUSTERED ([Product_ID] ASC),
    CONSTRAINT [FK_T0040_Product_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

