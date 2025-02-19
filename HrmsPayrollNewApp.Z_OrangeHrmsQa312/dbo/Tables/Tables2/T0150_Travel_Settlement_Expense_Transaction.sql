CREATE TABLE [dbo].[T0150_Travel_Settlement_Expense_Transaction] (
    [Tran_id]              NUMERIC (18)    NOT NULL,
    [Cmp_id]               NUMERIC (18)    NOT NULL,
    [Emp_id]               NUMERIC (18)    NOT NULL,
    [For_Date]             DATETIME        NULL,
    [Opening_Amount]       NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Expense_Transaction_Opening_Amount] DEFAULT ((0)) NOT NULL,
    [Amount]               NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Expense_Transaction_Amount] DEFAULT ((0)) NOT NULL,
    [Closing_Amount]       NUMERIC (18, 2) CONSTRAINT [DF_T0150_Travel_Settlement_Expense_Transaction_Closing_Amount] DEFAULT ((0)) NOT NULL,
    [Travel_Settelment_ID] NVARCHAR (100)  NULL,
    CONSTRAINT [PK_T0150_Travel_Settlement_Expense_Transaction] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

