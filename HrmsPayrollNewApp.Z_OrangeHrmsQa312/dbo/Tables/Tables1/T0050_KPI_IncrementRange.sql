CREATE TABLE [dbo].[T0050_KPI_IncrementRange] (
    [KPI_IncrementRangeId] NUMERIC (18) NOT NULL,
    [Cmp_Id]               NUMERIC (18) NOT NULL,
    [RangeName]            VARCHAR (80) NOT NULL,
    [RangeValue]           VARCHAR (50) NOT NULL,
    [EffectiveDate]        DATETIME     NOT NULL,
    CONSTRAINT [PK_T0050_KPI_IncrementRange] PRIMARY KEY CLUSTERED ([KPI_IncrementRangeId] ASC),
    CONSTRAINT [FK_T0050_KPI_IncrementRange_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_Id]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id])
);

