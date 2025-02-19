CREATE TABLE [dbo].[T0040_GEO_LOCATION_MASTER] (
    [Geo_Location_ID] NUMERIC (18)  NOT NULL,
    [Cmp_ID]          NUMERIC (18)  NULL,
    [Geo_Location]    VARCHAR (MAX) NULL,
    [Latitude]        NVARCHAR (50) NULL,
    [Longitude]       NVARCHAR (50) NULL,
    [Meter]           INT           NULL,
    [Login_ID]        NUMERIC (18)  NULL,
    [System_Date]     DATETIME      NULL,
    CONSTRAINT [PK_T0040_Geo_Location_Master] PRIMARY KEY CLUSTERED ([Geo_Location_ID] ASC) WITH (FILLFACTOR = 95)
);

