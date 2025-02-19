CREATE TABLE [dbo].[T0040_File_Status_Master] (
    [F_StatusID]  INT            NOT NULL,
    [StatusCode]  NVARCHAR (MAX) NULL,
    [StatusTitle] NVARCHAR (MAX) NOT NULL,
    [StatusCDTM]  DATETIME       NULL,
    [StatusUDTM]  DATETIME       NULL,
    [StatusLog]   NVARCHAR (MAX) NULL,
    [Is_Active]   INT            DEFAULT ((1)) NULL,
    [Cmp_ID]      INT            NULL,
    CONSTRAINT [PK_T0040_File_Status_Master] PRIMARY KEY CLUSTERED ([F_StatusID] ASC) WITH (FILLFACTOR = 80)
);

