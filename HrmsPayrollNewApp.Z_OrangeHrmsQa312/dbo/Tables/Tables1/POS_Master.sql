﻿CREATE TABLE [dbo].[POS_Master] (
    [POS_ID]   INT            IDENTITY (1, 1) NOT NULL,
    [POS_Name] NVARCHAR (200) NOT NULL,
    [Cmp_ID]   INT            NOT NULL,
    CONSTRAINT [PK_POS_Master] PRIMARY KEY CLUSTERED ([POS_ID] ASC) WITH (FILLFACTOR = 95)
);

