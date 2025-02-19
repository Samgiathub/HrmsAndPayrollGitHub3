CREATE TABLE [dbo].[Products] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [ProductName] NVARCHAR (50)   NULL,
    [Price]       DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

