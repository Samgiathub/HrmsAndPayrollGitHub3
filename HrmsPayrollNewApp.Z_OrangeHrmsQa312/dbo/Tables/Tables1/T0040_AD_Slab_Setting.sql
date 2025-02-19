CREATE TABLE [dbo].[T0040_AD_Slab_Setting] (
    [Tran_Id]       NUMERIC (18)    NOT NULL,
    [Cmp_Id]        NUMERIC (18)    NOT NULL,
    [AD_Id]         NUMERIC (18)    NOT NULL,
    [From_Slab]     NUMERIC (18, 2) CONSTRAINT [DF_T0040_AD_Slab_Setting_From_Slab] DEFAULT ((0)) NOT NULL,
    [To_Slab]       NUMERIC (18, 2) CONSTRAINT [DF_T0040_AD_Slab_Setting_To_Slab] DEFAULT ((0)) NOT NULL,
    [Calc_Type]     VARCHAR (100)   NULL,
    [Amount]        NUMERIC (18, 2) CONSTRAINT [DF_T0040_AD_Slab_Setting_Amount] DEFAULT ((0)) NOT NULL,
    [Sal_Calc_Type] NUMERIC (18)    CONSTRAINT [DF_T0040_AD_Slab_Setting_Sal_Calc_Type] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0040_AD_Slab_Setting] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_AD_Slab_Setting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_AD_Slab_Setting_T0050_AD_MASTER] FOREIGN KEY ([AD_Id]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID])
);

