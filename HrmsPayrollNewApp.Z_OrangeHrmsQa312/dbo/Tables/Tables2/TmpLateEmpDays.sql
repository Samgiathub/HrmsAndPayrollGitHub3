CREATE TABLE [dbo].[TmpLateEmpDays] (
    [Cmp_ID]          NUMERIC (18)    NULL,
    [Emp_ID]          NUMERIC (18)    NULL,
    [For_Date]        DATETIME        NULL,
    [In_Time]         DATETIME        NULL,
    [Out_Time]        DATETIME        NULL,
    [Shift_St_Time]   DATETIME        NULL,
    [Shift_End_Time]  DATETIME        NULL,
    [Late_Sec]        NUMERIC (18)    NULL,
    [Early_Sec]       NUMERIC (18)    NULL,
    [Late_Limit]      VARCHAR (20)    NULL,
    [Early_Limit]     VARCHAR (20)    NULL,
    [Late_Deduction]  NUMERIC (18, 2) NULL,
    [Early_Deduction] NUMERIC (18, 2) NULL,
    [ExemptFlag]      VARCHAR (10)    NULL
);

