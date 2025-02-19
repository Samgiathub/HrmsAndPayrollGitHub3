CREATE TABLE [dbo].[T0050_Retaintion_Rate_Master] (
    [RRate_Id]       NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18) NULL,
    [AD_ID]          NUMERIC (18) NULL,
    [Grd_ID]         NUMERIC (18) NULL,
    [Branch_ID]      NUMERIC (18) NULL,
    [Effective_date] DATETIME     NULL,
    [Login_Id]       NUMERIC (18) NULL,
    [System_Date]    DATETIME     NULL,
    CONSTRAINT [PK_T0050_Retainition_Rate_Master] PRIMARY KEY CLUSTERED ([RRate_Id] ASC) WITH (FILLFACTOR = 95)
);

