CREATE TABLE [dbo].[T0040_AD_Formula_Setting] (
    [Tran_Id]           NUMERIC (18)   NOT NULL,
    [Cmp_Id]            NUMERIC (18)   NOT NULL,
    [AD_Id]             NUMERIC (18)   NOT NULL,
    [AD_Formula]        NVARCHAR (MAX) NOT NULL,
    [Actual_AD_Formula] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0040_AD_Formula_Setting] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_AD_Formula_Eligible_Setting_T0010_Company_Master] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_AD_Formula_Eligible_Setting_T0050_AD_MASTER] FOREIGN KEY ([AD_Id]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID]),
    CONSTRAINT [FK_T0040_AD_Formula_Setting_T0010_Company_Master] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_AD_Formula_Setting_T0050_AD_MASTER] FOREIGN KEY ([AD_Id]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID])
);

