CREATE TABLE [dbo].[T0040_Machine_Allocation_Master] (
    [Allocation_ID]  NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]         NUMERIC (18)  NOT NULL,
    [Emp_ID]         NUMERIC (18)  NOT NULL,
    [Shift_ID]       NUMERIC (18)  NULL,
    [Effective_Date] DATETIME      NULL,
    [Machine_ID]     VARCHAR (300) NULL,
    CONSTRAINT [PK_T0040_Machine_Allocation_Master] PRIMARY KEY NONCLUSTERED ([Allocation_ID] ASC)
);

