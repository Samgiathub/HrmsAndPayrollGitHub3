CREATE TABLE [dbo].[T0100_SHIFT_ALLOWANCE_RATE] (
    [Tran_id]        INT             NOT NULL,
    [Cmp_id]         INT             NOT NULL,
    [Shift_id]       INT             NOT NULL,
    [Rate]           NUMERIC (18, 2) CONSTRAINT [DF_T0100_SHIFT_ALLOWANCE_RATE_Rate] DEFAULT ((0)) NOT NULL,
    [Effective_Date] DATETIME        NULL,
    [Is_Emp_Rate]    TINYINT         CONSTRAINT [DF_T0100_SHIFT_ALLOWANCE_RATE_Is_Emp_Rate] DEFAULT ((0)) NOT NULL,
    [Created_Date]   DATETIME        CONSTRAINT [DF_T0100_SHIFT_ALLOWANCE_RATE_Created_Date] DEFAULT (getdate()) NOT NULL,
    [Minimum_Count]  NUMERIC (18, 2) CONSTRAINT [DF_T0100_SHIFT_ALLOWANCE_RATE_Minimum_Count] DEFAULT ((0)) NOT NULL,
    [Ad_Id]          NUMERIC (18)    CONSTRAINT [DF_T0100_SHIFT_ALLOWANCE_RATE_Ad_Id] DEFAULT ((0)) NOT NULL
);

