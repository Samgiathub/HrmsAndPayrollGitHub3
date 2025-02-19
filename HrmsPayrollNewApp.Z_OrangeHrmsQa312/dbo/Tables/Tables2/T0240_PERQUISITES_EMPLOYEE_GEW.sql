CREATE TABLE [dbo].[T0240_PERQUISITES_EMPLOYEE_GEW] (
    [Trans_ID]       NUMERIC (18)  NULL,
    [Cmp_id]         NUMERIC (18)  NULL,
    [Emp_id]         NUMERIC (18)  NULL,
    [Financial_Year] NVARCHAR (60) NULL,
    [Total_Amount]   NUMERIC (18)  NULL,
    [From_Date]      DATETIME      NULL,
    [To_Date]        DATETIME      NULL,
    [ChangeDate]     DATETIME      CONSTRAINT [DF_T0240_PERQUISITES_EMPLOYEE_GEW_ChangeDate] DEFAULT (getdate()) NULL
);

