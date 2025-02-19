CREATE TABLE [dbo].[T0040_Fav_Sport_Master] (
    [FS_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [Sport_Name] NVARCHAR (100) NULL,
    [Cmp_ID]     INT            NULL,
    PRIMARY KEY CLUSTERED ([FS_ID] ASC) WITH (FILLFACTOR = 95)
);

