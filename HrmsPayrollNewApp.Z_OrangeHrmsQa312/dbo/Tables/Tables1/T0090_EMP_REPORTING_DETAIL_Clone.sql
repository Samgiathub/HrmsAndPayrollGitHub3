CREATE TABLE [dbo].[T0090_EMP_REPORTING_DETAIL_Clone] (
    [Row_ID]           NUMERIC (18) NOT NULL,
    [Emp_ID]           NUMERIC (18) NOT NULL,
    [R_Emp_ID]         NUMERIC (18) NOT NULL,
    [Cmp_ID]           NUMERIC (18) NOT NULL,
    [Reporting_To]     VARCHAR (30) NOT NULL,
    [Reporting_Method] VARCHAR (20) NOT NULL,
    [System_Date]      DATETIME     NOT NULL,
    [Login_Id]         NUMERIC (18) NOT NULL
);

