CREATE TABLE [dbo].[T0100_Machine_Daily_Efficiency] (
    [Efficiency_ID]    NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]           NUMERIC (18)    NOT NULL,
    [For_Date]         DATETIME        NOT NULL,
    [Machine_ID]       VARCHAR (50)    NULL,
    [Shift_ID]         NUMERIC (18)    NOT NULL,
    [Assigned_Emp_ID]  NUMERIC (18)    NOT NULL,
    [Alternate_Emp_ID] NUMERIC (18)    NOT NULL,
    [Efficiency]       NUMERIC (18, 2) NULL,
    [Segment_ID]       NUMERIC (18)    NULL,
    [WeaverFlag]       VARCHAR (2)     NULL,
    CONSTRAINT [PK_T0100_Machine_Daily_Efficiency] PRIMARY KEY NONCLUSTERED ([Efficiency_ID] ASC)
);

