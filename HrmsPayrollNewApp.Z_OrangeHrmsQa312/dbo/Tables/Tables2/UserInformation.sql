CREATE TABLE [dbo].[UserInformation] (
    [UserID]          INT           IDENTITY (1, 1) NOT NULL,
    [IPAddress]       VARCHAR (45)  NULL,
    [Country]         VARCHAR (100) NULL,
    [Region]          VARCHAR (100) NULL,
    [City]            VARCHAR (100) NULL,
    [ConnectionType]  VARCHAR (50)  NULL,
    [Browser]         VARCHAR (100) NULL,
    [OperatingSystem] VARCHAR (100) NULL,
    [DeviceType]      VARCHAR (100) NULL,
    [WeatherInfo]     VARCHAR (MAX) NULL,
    [Timezone]        VARCHAR (100) NULL,
    [Language]        VARCHAR (100) NULL,
    [CreatedDate]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([UserID] ASC) WITH (FILLFACTOR = 95)
);

