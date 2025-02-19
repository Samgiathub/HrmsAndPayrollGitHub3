CREATE TABLE [dbo].[T0110_Asset_Application_Details] (
    [Asset_ApplicationDet_Id] NUMERIC (18) NOT NULL,
    [Asset_Application_Id]    NUMERIC (18) NOT NULL,
    [Cmp_Id]                  NUMERIC (18) NOT NULL,
    [Asset_Id]                NUMERIC (18) NOT NULL,
    [AssetM_Id]               NUMERIC (18) NULL,
    [Status]                  CHAR (1)     NOT NULL,
    CONSTRAINT [PK_T0110_Asset_Application_Details] PRIMARY KEY CLUSTERED ([Asset_ApplicationDet_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0110_Asset_Application_Details_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_Asset_Application_Details_T0040_Asset_Details] FOREIGN KEY ([AssetM_Id]) REFERENCES [dbo].[T0040_Asset_Details] ([AssetM_ID]),
    CONSTRAINT [FK_T0110_Asset_Application_Details_T0040_ASSET_MASTER] FOREIGN KEY ([Asset_Id]) REFERENCES [dbo].[T0040_ASSET_MASTER] ([Asset_ID]),
    CONSTRAINT [FK_T0110_Asset_Application_Details_T0100_Asset_Application] FOREIGN KEY ([Asset_Application_Id]) REFERENCES [dbo].[T0100_Asset_Application] ([Asset_Application_ID])
);

