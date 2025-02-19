CREATE TABLE [dbo].[send_log] (
    [ID]          NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [mobile]      NVARCHAR (50)   NULL,
    [sendtext]    NVARCHAR (1000) NULL,
    [response]    NVARCHAR (500)  NULL,
    [created]     NVARCHAR (50)   NULL,
    [createddate] DATETIME        NULL
);

