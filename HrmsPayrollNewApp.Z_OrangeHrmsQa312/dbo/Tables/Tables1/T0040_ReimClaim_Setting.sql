CREATE TABLE [dbo].[T0040_ReimClaim_Setting] (
    [TranID]            NUMERIC (18)    NOT NULL,
    [Cmp_ID]            NUMERIC (18)    NOT NULL,
    [AD_ID]             NUMERIC (18)    NOT NULL,
    [Non_Taxable_Limit] NUMERIC (18, 2) CONSTRAINT [DF_T0040_ReimClaim_Setting_Non_Taxable_Limit] DEFAULT ((0)) NULL,
    [Taxable_Limit]     NUMERIC (18, 2) CONSTRAINT [DF_T0040_ReimClaim_Setting_Taxable_Limit] DEFAULT ((0)) NULL,
    [Num_LTA_Block]     NUMERIC (18, 2) NULL,
    [Is_CF]             TINYINT         CONSTRAINT [DF_T0040_ReimClaim_Setting_Is_CF] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0040_ReimClaim_Setting] PRIMARY KEY CLUSTERED ([TranID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0040_ReimClaim_Setting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0040_ReimClaim_Setting_T0050_AD_MASTER] FOREIGN KEY ([AD_ID]) REFERENCES [dbo].[T0050_AD_MASTER] ([AD_ID])
);

