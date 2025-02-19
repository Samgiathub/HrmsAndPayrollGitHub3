CREATE TABLE [dbo].[T0030_Asset_Installation] (
    [Asset_Installation_ID] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                NUMERIC (18)  NOT NULL,
    [Asset_Id]              NUMERIC (18)  NOT NULL,
    [Installation_Name]     VARCHAR (500) NOT NULL,
    [Installation_Type]     NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0030_Asset_Installation] PRIMARY KEY CLUSTERED ([Asset_Installation_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0030_Asset_Installation_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0030_Asset_Installation_T0040_ASSET_MASTER] FOREIGN KEY ([Asset_Id]) REFERENCES [dbo].[T0040_ASSET_MASTER] ([Asset_ID])
);

