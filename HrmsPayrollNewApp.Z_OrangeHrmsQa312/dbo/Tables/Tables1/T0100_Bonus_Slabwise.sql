CREATE TABLE [dbo].[T0100_Bonus_Slabwise] (
    [Tran_ID]             NUMERIC (18)    NOT NULL,
    [Cmp_ID]              NUMERIC (18)    NULL,
    [Emp_ID]              NUMERIC (18)    NULL,
    [From_date]           DATETIME        NULL,
    [To_date]             DATETIME        NULL,
    [Gross_Salary]        NUMERIC (18, 2) NULL,
    [Working_Days]        NUMERIC (18, 2) NULL,
    [Eligible_Day]        NUMERIC (18, 2) NULL,
    [Paid_Day]            NUMERIC (18, 2) NULL,
    [Leave_Slab]          NUMERIC (18, 2) NULL,
    [Bonus_Amount]        NUMERIC (18, 2) NULL,
    [Additional_Amount]   NUMERIC (18, 2) NULL,
    [Total_Bonus_Amount]  NUMERIC (18, 2) NULL,
    [For_date]            DATETIME        NULL,
    [Bonus_Effect_on_Sal] NUMERIC (18)    NULL,
    [Bonus_Effect_Month]  NUMERIC (18)    NULL,
    [Bonus_Effect_Year]   NUMERIC (18)    NULL,
    [Bonus_Comments]      VARCHAR (500)   NULL,
    [Extra_Paid_Days]     NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

