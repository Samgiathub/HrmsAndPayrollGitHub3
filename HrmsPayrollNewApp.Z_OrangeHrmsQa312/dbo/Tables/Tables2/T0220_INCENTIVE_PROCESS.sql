CREATE TABLE [dbo].[T0220_INCENTIVE_PROCESS] (
    [Inc_Tran_ID]    NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Emp_ID]         NUMERIC (18)    NULL,
    [Cmp_ID]         NUMERIC (18)    NULL,
    [Scheme_ID]      NUMERIC (18)    NULL,
    [Branch_ID]      NUMERIC (18)    NULL,
    [Desig_ID]       NUMERIC (18)    NULL,
    [Incentive_Amt]  NUMERIC (18, 2) NULL,
    [Additional_Amt] NUMERIC (18, 2) NULL,
    [Deduction_Amt]  NUMERIC (18, 2) NULL,
    [Paid_Amt]       NUMERIC (18, 2) NULL,
    [Status]         CHAR (1)        NULL,
    [For_Date]       DATETIME        NULL,
    [Login_ID]       NUMERIC (18)    NULL,
    [System_Date]    DATETIME        NULL
);

