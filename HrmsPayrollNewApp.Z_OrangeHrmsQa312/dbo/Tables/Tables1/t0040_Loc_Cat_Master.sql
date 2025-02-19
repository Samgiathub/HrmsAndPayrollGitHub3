CREATE TABLE [dbo].[t0040_Loc_Cat_Master] (
    [Loc_Cat_ID]    NUMERIC (18)  NOT NULL,
    [Category_name] VARCHAR (60)  NOT NULL,
    [Remarks]       VARCHAR (200) NULL,
    CONSTRAINT [PK_t0040_Loc_Cat_Master] PRIMARY KEY CLUSTERED ([Loc_Cat_ID] ASC) WITH (FILLFACTOR = 80)
);

