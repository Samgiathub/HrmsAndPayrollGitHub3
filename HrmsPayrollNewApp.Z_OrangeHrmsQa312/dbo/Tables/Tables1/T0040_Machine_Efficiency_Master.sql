CREATE TABLE [dbo].[T0040_Machine_Efficiency_Master] (
    [Efficiency_ID]  NUMERIC (18) NOT NULL,
    [Cmp_ID]         NUMERIC (18) NULL,
    [Machine_ID]     NUMERIC (18) NULL,
    [Effective_Date] DATETIME     NULL,
    CONSTRAINT [PK_T0040_Machine_Efficiency_Master] PRIMARY KEY NONCLUSTERED ([Efficiency_ID] ASC),
    CONSTRAINT [FK_T0040_Machine_Efficiency_Master_T0040_Machine_Master] FOREIGN KEY ([Machine_ID]) REFERENCES [dbo].[T0040_Machine_Master] ([Machine_ID])
);

