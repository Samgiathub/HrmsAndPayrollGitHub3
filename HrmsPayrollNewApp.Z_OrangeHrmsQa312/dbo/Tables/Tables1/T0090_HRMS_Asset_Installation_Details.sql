CREATE TABLE [dbo].[T0090_HRMS_Asset_Installation_Details] (
    [Asset_InstallationDet_Id] NUMERIC (18)  NOT NULL,
    [Cmp_Id]                   NUMERIC (18)  NOT NULL,
    [AssetM_Id]                NUMERIC (18)  NOT NULL,
    [Asset_Installation_ID]    NUMERIC (18)  NOT NULL,
    [Installation_Details]     VARCHAR (MAX) NOT NULL,
    [Resume_Id]                NUMERIC (18)  NOT NULL,
    [Asset_Approval_ID]        NUMERIC (18)  NOT NULL,
    CONSTRAINT [PK_T0090_HRMS_Asset_Installation_Details] PRIMARY KEY CLUSTERED ([Asset_InstallationDet_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0090_HRMS_Asset_Installation_Details_T0030_Asset_Installation] FOREIGN KEY ([Asset_Installation_ID]) REFERENCES [dbo].[T0030_Asset_Installation] ([Asset_Installation_ID]),
    CONSTRAINT [FK_T0090_HRMS_Asset_Installation_Details_T0040_Asset_Details] FOREIGN KEY ([AssetM_Id]) REFERENCES [dbo].[T0040_Asset_Details] ([AssetM_ID]),
    CONSTRAINT [FK_T0090_HRMS_Asset_Installation_Details_T0055_Resume_Master] FOREIGN KEY ([Resume_Id]) REFERENCES [dbo].[T0055_Resume_Master] ([Resume_Id]),
    CONSTRAINT [FK_T0090_HRMS_Asset_Installation_Details_T0090_HRMS_Asset_Allocation] FOREIGN KEY ([Asset_Approval_ID]) REFERENCES [dbo].[T0090_HRMS_Asset_Allocation] ([Asset_Approval_Id])
);

