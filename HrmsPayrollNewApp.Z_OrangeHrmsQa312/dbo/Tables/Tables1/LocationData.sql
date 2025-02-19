CREATE TABLE [dbo].[LocationData] (
    [ID]        INT        NOT NULL,
    [Latitude]  FLOAT (53) NULL,
    [Longitude] FLOAT (53) NULL,
    [Date]      DATETIME   NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 95)
);

