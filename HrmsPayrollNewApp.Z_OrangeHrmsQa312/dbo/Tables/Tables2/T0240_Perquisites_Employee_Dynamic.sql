CREATE TABLE [dbo].[T0240_Perquisites_Employee_Dynamic] (
    [Tran_id]        NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [cmp_id]         NUMERIC (18)    NOT NULL,
    [emp_id]         NUMERIC (18)    CONSTRAINT [DF_T0240_Perquisites_Employee_Dynamic_emp_id] DEFAULT ((0)) NOT NULL,
    [It_Id]          NUMERIC (18)    NOT NULL,
    [Financial_Year] NVARCHAR (100)  NOT NULL,
    [Amount]         NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Dynamic_Amount] DEFAULT ((0)) NOT NULL,
    [modify_date]    DATETIME        CONSTRAINT [DF_T0240_Perquisites_Employee_Dynamic_modify_date] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0240_Perquisites_Employee_Dynamic] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

