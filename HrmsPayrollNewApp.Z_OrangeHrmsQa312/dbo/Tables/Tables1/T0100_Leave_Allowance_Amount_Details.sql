CREATE TABLE [dbo].[T0100_Leave_Allowance_Amount_Details] (
    [Tran_ID]        NUMERIC (18)    NOT NULL,
    [Cmp_Id]         NUMERIC (18)    NOT NULL,
    [Emp_Id]         NUMERIC (18)    NOT NULL,
    [Leave_Id]       NUMERIC (18)    NOT NULL,
    [Effective_Date] DATETIME        NOT NULL,
    [Amount]         NUMERIC (18, 2) CONSTRAINT [DF_T0100_Leave_Allowance_Amount_Details_Amount] DEFAULT ((0)) NOT NULL,
    [Sys_Date]       DATETIME        NOT NULL
);

