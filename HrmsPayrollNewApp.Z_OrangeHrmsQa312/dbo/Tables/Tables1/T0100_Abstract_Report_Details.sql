CREATE TABLE [dbo].[T0100_Abstract_Report_Details] (
    [Trans_ID]               NUMERIC (18)   NOT NULL,
    [Cmp_ID]                 NUMERIC (18)   NULL,
    [Report_ID]              NUMERIC (18)   NULL,
    [Employee_Type]          NUMERIC (18)   NULL,
    [Sorting_No]             NUMERIC (18)   NULL,
    [Earning_Component_ID]   VARCHAR (2000) NULL,
    [Earning_Short_Name]     VARCHAR (MAX)  NULL,
    [Deduction_Component_ID] VARCHAR (2000) NULL,
    [Deduction_Short_Name]   VARCHAR (MAX)  NULL,
    [Loan_ID]                VARCHAR (2000) NULL,
    [Loan_Short_Name]        VARCHAR (MAX)  NULL,
    [System_Date]            DATETIME       NULL,
    [TypeId]                 NUMERIC (5)    NULL,
    [Abstract_Report_ID]     NUMERIC (5)    NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC) WITH (FILLFACTOR = 80)
);

