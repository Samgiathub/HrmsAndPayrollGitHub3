CREATE TABLE [dbo].[Category] (
    [CatId]        INT            IDENTITY (1, 1) NOT NULL,
    [CategoryName] NVARCHAR (255) NULL,
    [Descriptions] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([CatId] ASC) WITH (FILLFACTOR = 95)
);

