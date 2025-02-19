CREATE TABLE [dbo].[Logs] (
    [Id]              INT                IDENTITY (1, 1) NOT NULL,
    [Message]         NVARCHAR (MAX)     NULL,
    [MessageTemplate] NVARCHAR (MAX)     NULL,
    [Level]           NVARCHAR (128)     NULL,
    [TimeStamp]       DATETIMEOFFSET (7) NULL,
    [Exception]       NVARCHAR (MAX)     NULL,
    [Properties]      NVARCHAR (MAX)     NULL,
    [LogEvent]        NVARCHAR (MAX)     NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

