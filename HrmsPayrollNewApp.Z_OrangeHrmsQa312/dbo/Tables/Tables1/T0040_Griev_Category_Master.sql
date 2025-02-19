CREATE TABLE [dbo].[T0040_Griev_Category_Master] (
    [G_CategoryID]   INT            NOT NULL,
    [CategoryCode]   NVARCHAR (MAX) NULL,
    [CategoryTitle]  NVARCHAR (MAX) NOT NULL,
    [CategoryStatus] NVARCHAR (MAX) NULL,
    [CategoryCDTM]   DATETIME       NULL,
    [CategoryUDTM]   DATETIME       NULL,
    [CategoryLog]    NVARCHAR (MAX) NULL,
    [Is_Active]      INT            DEFAULT ((1)) NULL,
    [Cmp_ID]         INT            NULL,
    CONSTRAINT [PK_T0040_Griev_Category_Master] PRIMARY KEY CLUSTERED ([G_CategoryID] ASC) WITH (FILLFACTOR = 80)
);

