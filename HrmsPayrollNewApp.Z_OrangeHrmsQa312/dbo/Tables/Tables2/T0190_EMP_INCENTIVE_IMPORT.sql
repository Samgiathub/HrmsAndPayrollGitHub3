CREATE TABLE [dbo].[T0190_EMP_INCENTIVE_IMPORT] (
    [Tran_ID]     NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NULL,
    [Emp_ID]      NUMERIC (18)    NULL,
    [Branch_ID]   NUMERIC (18)    NULL,
    [Desig_ID]    NUMERIC (18)    NULL,
    [Para_Name]   VARCHAR (MAX)   NULL,
    [Para_Value]  NUMERIC (18, 2) NULL,
    [Para_Type]   VARCHAR (2)     NULL,
    [Para_ID]     NUMERIC (18)    NULL,
    [For_Date]    DATETIME        NULL,
    [Login_ID]    NUMERIC (18)    NULL,
    [System_Date] DATETIME        NULL,
    [Formula]     NVARCHAR (MAX)  NULL
);

