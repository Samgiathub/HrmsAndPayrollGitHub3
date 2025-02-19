CREATE TABLE [dbo].[T0052_BSC_AlertSetting] (
    [BSC_Alert_Id]    NUMERIC (18) NOT NULL,
    [Cmp_Id]          NUMERIC (18) NOT NULL,
    [BSC_AlertType]   INT          NULL,
    [BSC_AlertDay]    NUMERIC (18) NULL,
    [BSC_Month]       NUMERIC (18) NULL,
    [BSC_AlertNodays] NCHAR (10)   NULL,
    [BSC_Date]        DATETIME     NULL,
    [BSC_ReviewType]  INT          NULL,
    CONSTRAINT [PK_T0052_BSC_AlertSetting] PRIMARY KEY CLUSTERED ([BSC_Alert_Id] ASC),
    CONSTRAINT [FK_T0052_BSC_AlertSetting_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

