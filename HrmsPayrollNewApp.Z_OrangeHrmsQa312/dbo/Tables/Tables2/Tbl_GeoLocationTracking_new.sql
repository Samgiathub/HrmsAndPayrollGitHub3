CREATE TABLE [dbo].[Tbl_GeoLocationTracking_new] (
    [ID]               INT           IDENTITY (1, 1) NOT NULL,
    [EmpID]            INT           NOT NULL,
    [CmpID]            INT           NOT NULL,
    [Latitude]         FLOAT (53)    NULL,
    [Longitude]        FLOAT (53)    NULL,
    [Date]             DATETIME      NULL,
    [Address_Location] VARCHAR (MAX) NULL,
    [Timestamp]        NUMERIC (18)  NULL
);

