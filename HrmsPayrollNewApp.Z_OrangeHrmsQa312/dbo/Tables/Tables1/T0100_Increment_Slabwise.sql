CREATE TABLE [dbo].[T0100_Increment_Slabwise] (
    [Tran_ID]              NUMERIC (18)    NOT NULL,
    [Cmp_ID]               NUMERIC (18)    NULL,
    [Emp_ID]               NUMERIC (18)    NULL,
    [Gross_Salary]         NUMERIC (18, 2) NULL,
    [Wages_Calculate_On]   NUMERIC (18, 2) NULL,
    [Wages_Amount]         NUMERIC (18, 2) NULL,
    [Working_Days]         NUMERIC (18, 2) NULL,
    [Eligible_Day]         NUMERIC (18, 2) NULL,
    [Increment_Amount]     NUMERIC (18, 2) NULL,
    [Additional_Increment] NUMERIC (18, 2) NULL,
    [Total_Increment]      NUMERIC (18, 2) NULL,
    [From_date]            DATETIME        NULL,
    [To_date]              DATETIME        NULL,
    [For_date]             DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

