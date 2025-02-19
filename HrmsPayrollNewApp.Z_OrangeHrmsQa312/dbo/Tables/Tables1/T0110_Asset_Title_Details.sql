CREATE TABLE [dbo].[T0110_Asset_Title_Details] (
    [Asset_Title_Id]        NUMERIC (18)  NOT NULL,
    [Cmp_Id]                NUMERIC (18)  NOT NULL,
    [Asset_Installation_ID] NUMERIC (18)  NOT NULL,
    [Asset_Title]           VARCHAR (250) NOT NULL,
    [AssetM_Id]             NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0110_Asset_Title_Details] PRIMARY KEY CLUSTERED ([Asset_Title_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0110_Asset_Title_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_Asset_Title_Details_T0030_Asset_Installation] FOREIGN KEY ([Asset_Installation_ID]) REFERENCES [dbo].[T0030_Asset_Installation] ([Asset_Installation_ID]),
    CONSTRAINT [FK_T0110_Asset_Title_Details_T0040_Asset_Details] FOREIGN KEY ([AssetM_Id]) REFERENCES [dbo].[T0040_Asset_Details] ([AssetM_ID])
);

