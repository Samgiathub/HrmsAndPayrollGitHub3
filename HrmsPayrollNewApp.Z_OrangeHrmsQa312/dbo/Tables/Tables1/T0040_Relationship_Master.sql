CREATE TABLE [dbo].[T0040_Relationship_Master] (
    [Relationship_ID] NUMERIC (18)  NOT NULL,
    [Relationship]    VARCHAR (100) NULL,
    [Cmp_Id]          NUMERIC (18)  NULL,
    CONSTRAINT [PK_T0040_Relationship_Master] PRIMARY KEY CLUSTERED ([Relationship_ID] ASC) WITH (FILLFACTOR = 80)
);

