CREATE TABLE [dbo].[ErrorLogs] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [Message]         NVARCHAR (MAX) NULL,
    [MessageTemplate] NVARCHAR (MAX) NULL,
    [Level]           NVARCHAR (MAX) NULL,
    [TimeStamp]       DATETIME       NULL,
    [Exception]       NVARCHAR (MAX) NULL,
    [Properties]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ErrorLogs] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

