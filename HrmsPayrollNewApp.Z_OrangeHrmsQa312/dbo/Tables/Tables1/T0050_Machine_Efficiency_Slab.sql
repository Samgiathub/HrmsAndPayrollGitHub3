CREATE TABLE [dbo].[T0050_Machine_Efficiency_Slab] (
    [Slab_ID]       NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NULL,
    [Efficiency_ID] NUMERIC (18)    NULL,
    [Avg_Percent]   NUMERIC (18, 2) NOT NULL,
    [Basic_Amount]  NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_T0050_Machine_Efficiency_Slab] PRIMARY KEY CLUSTERED ([Slab_ID] ASC)
);

