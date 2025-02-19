CREATE TABLE [dbo].[Tbl_Geo_AreaName] (
    [ID]        INT           IDENTITY (1, 1) NOT NULL,
    [City_ID]   INT           NOT NULL,
    [Area_Name] VARCHAR (MAX) NULL,
    [Latitude]  DECIMAL (18)  NULL,
    [Longitude] DECIMAL (18)  NULL,
    CONSTRAINT [PK_Tbl_Geo_AreaName] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

