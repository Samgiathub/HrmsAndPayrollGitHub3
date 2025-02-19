CREATE TABLE [dbo].[Sal_Posting_Error_Logs] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [Sal_Pos_MID]  NVARCHAR (MAX) NULL,
    [API_Name]     NVARCHAR (MAX) NULL,
    [API_Response] NVARCHAR (MAX) NULL,
    [CreatedDate]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 95)
);

