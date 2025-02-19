CREATE TABLE [dbo].[T0020_ESOP_SharePrice_Master] (
    [Tran_Id]                NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [EffectiveDate]          DATETIME        NULL,
    [MarketPrice]            NUMERIC (18, 2) NULL,
    [EmployeePrice]          NUMERIC (18, 2) NULL,
    [MonthWiseLockingPeriod] NUMERIC (9)     NULL,
    [CreatedDate]            DATETIME        NULL,
    [Cmp_id]                 INT             NULL
);

