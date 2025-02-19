CREATE TABLE [dbo].[Tbl_GeoLocationTracking] (
    [ID]                  INT            IDENTITY (1, 1) NOT NULL,
    [EmpID]               INT            NOT NULL,
    [CmpID]               INT            NOT NULL,
    [Latitude]            FLOAT (53)     NULL,
    [Longitude]           FLOAT (53)     NULL,
    [TrackingDate]        DATETIME       NULL,
    [Address_Location]    VARCHAR (MAX)  NULL,
    [City]                VARCHAR (MAX)  NULL,
    [Area]                VARCHAR (MAX)  NULL,
    [Battery_Level]       NVARCHAR (MAX) NULL,
    [IMEI_No]             VARCHAR (MAX)  NULL,
    [GPS_accuracy]        FLOAT (53)     NULL,
    [Model_Name]          NVARCHAR (MAX) NULL,
    [GPS_accuracy_string] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Tbl_GeoLocationTracking] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

