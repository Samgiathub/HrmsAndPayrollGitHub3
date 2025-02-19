CREATE TABLE [dbo].[T0040_Hobby_Master] (
    [H_ID]      INT            IDENTITY (1, 1) NOT NULL,
    [HobbyName] NVARCHAR (100) NULL,
    [Cmp_ID]    INT            NULL,
    PRIMARY KEY CLUSTERED ([H_ID] ASC) WITH (FILLFACTOR = 95)
);

