CREATE TABLE [dbo].[T0040_BONUS_OVERTIME_AMOUNT] (
    [Tran_ID]           INT           IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NULL,
    [Emp_ID]            NUMERIC (18)  NULL,
    [For_Date]          DATETIME      NULL,
    [In_Time]           DATETIME      NULL,
    [Out_Time]          DATETIME      NULL,
    [Overtime_Duration] VARCHAR (500) NULL,
    [Amount]            NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 95)
);

