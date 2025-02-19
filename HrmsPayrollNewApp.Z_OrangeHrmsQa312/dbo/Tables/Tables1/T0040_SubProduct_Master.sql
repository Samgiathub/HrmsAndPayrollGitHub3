CREATE TABLE [dbo].[T0040_SubProduct_Master] (
    [SubProduct_ID]   NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Product_ID]      NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NOT NULL,
    [Login_ID]        NUMERIC (18)  NOT NULL,
    [SubProduct_Name] VARCHAR (200) NOT NULL,
    [Unit]            VARCHAR (50)  NOT NULL,
    [System_Date]     DATETIME      NULL,
    CONSTRAINT [PK_T0040_SubProduct_Master] PRIMARY KEY CLUSTERED ([SubProduct_ID] ASC),
    CONSTRAINT [FK_T0040_SubProduct_Master_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_SubProduct_Master_T0040_Product_Master] FOREIGN KEY ([Product_ID]) REFERENCES [dbo].[T0040_Product_Master] ([Product_ID])
);

