CREATE TABLE [dbo].[API_Hit_Log] (
    [Hit_ID]          INT            IDENTITY (1, 1) NOT NULL,
    [API_Name]        NVARCHAR (200) NULL,
    [TimeStamp]       DATETIME       NULL,
    [Hit_Count_Today] INT            NULL,
    [Hit_Count_Total] INT            NULL,
    CONSTRAINT [PK_API_Hit_Log] PRIMARY KEY CLUSTERED ([Hit_ID] ASC) WITH (FILLFACTOR = 95)
);

