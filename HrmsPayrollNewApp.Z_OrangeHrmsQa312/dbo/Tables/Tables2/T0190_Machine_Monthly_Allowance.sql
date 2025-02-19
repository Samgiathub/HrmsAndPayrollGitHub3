CREATE TABLE [dbo].[T0190_Machine_Monthly_Allowance] (
    [Allow_Tran_ID] NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Machine_ID]    NUMERIC (18)    NOT NULL,
    [Salary_Month]  INT             NOT NULL,
    [Salary_Year]   INT             NOT NULL,
    [For_Date]      DATETIME        NOT NULL,
    [Allow_amount]  NUMERIC (18, 2) NOT NULL,
    [Comments]      VARCHAR (200)   NOT NULL,
    [Import_Date]   DATETIME        NULL
);

