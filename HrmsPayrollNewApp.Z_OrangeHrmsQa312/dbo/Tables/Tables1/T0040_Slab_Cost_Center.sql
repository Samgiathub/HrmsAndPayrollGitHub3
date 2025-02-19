CREATE TABLE [dbo].[T0040_Slab_Cost_Center] (
    [Slab_id]   NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_id]    NUMERIC (18)    NULL,
    [Slab_from] NUMERIC (18, 2) NULL,
    [Slab_to]   NUMERIC (18, 2) NULL,
    [Slab_name] VARCHAR (100)   NULL,
    CONSTRAINT [PK_T0040_Slab_Cost_Center] PRIMARY KEY CLUSTERED ([Slab_id] ASC) WITH (FILLFACTOR = 95)
);

