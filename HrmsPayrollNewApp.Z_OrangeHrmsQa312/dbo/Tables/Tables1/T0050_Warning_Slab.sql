CREATE TABLE [dbo].[T0050_Warning_Slab] (
    [slab_id]     NUMERIC (18)    NOT NULL,
    [cmp_id]      NUMERIC (18)    CONSTRAINT [DF_T0050_Warning_Slab_cmp_id] DEFAULT ((0)) NOT NULL,
    [warning_id]  NUMERIC (18)    CONSTRAINT [DF_T0050_Warning_Slab_warning_id] DEFAULT ((0)) NOT NULL,
    [From_Hours]  NUMERIC (18)    CONSTRAINT [DF_T0050_Warning_Slab_From_Hours] DEFAULT ((0)) NOT NULL,
    [To_Hours]    NUMERIC (18)    CONSTRAINT [DF_T0050_Warning_Slab_To_Hours] DEFAULT ((0)) NOT NULL,
    [Deduct_Days] NUMERIC (18, 2) CONSTRAINT [DF_T0050_Warning_Slab_Deduct_Days] DEFAULT ((0)) NOT NULL
);

