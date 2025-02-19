CREATE TABLE [dbo].[T0040_Emp_ESOP_Allocation] (
    [Esop_Id]          NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Effective_date]   DATETIME2 (7)   NULL,
    [NoOfShare]        INT             NULL,
    [PerquisiteValue]  NUMERIC (18, 2) NULL,
    [TaxablePerqValue] NUMERIC (18, 2) NULL,
    [SystemDate]       DATETIME2 (7)   NULL,
    [Emp_Id]           NUMERIC (9)     NULL,
    [Cmp_Id]           NUMERIC (9)     NULL,
    [Emp_Price]        NUMERIC (18, 2) NULL,
    CONSTRAINT [PK__T0040_Em__8AF6ED6B1439B88A] PRIMARY KEY CLUSTERED ([Esop_Id] ASC) WITH (FILLFACTOR = 95)
);

