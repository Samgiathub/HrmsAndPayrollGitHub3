CREATE TABLE [dbo].[T0210_Salary_Budget_Details] (
    [SalBudget_DetailID] NUMERIC (18)    NOT NULL,
    [SalBudget_ID]       NUMERIC (18)    NULL,
    [SalBudget_TransID]  NUMERIC (18)    NULL,
    [OldBasic_Salary]    NUMERIC (18, 2) NULL,
    [OldGross_Salary]    NUMERIC (18, 2) NULL,
    [OldCTC_Salary]      NUMERIC (18, 2) NULL,
    [Increment_Per]      NUMERIC (18, 2) NULL,
    [Increment_BasicAmt] NUMERIC (18, 2) NULL,
    [Increment_GrossAmt] NUMERIC (18, 2) NULL,
    [Increment_CTCAmt]   NUMERIC (18, 2) NULL,
    [NewBasic_Salary]    NUMERIC (18, 2) NULL,
    [NewGross_Salary]    NUMERIC (18, 2) NULL,
    [NewCTC_Salary]      NUMERIC (18, 2) NULL,
    [Cmp_ID]             NUMERIC (18)    NULL,
    [Created_By]         NUMERIC (18)    NULL,
    [Created_Date]       DATETIME        NULL,
    [Modified_By]        NUMERIC (18)    NULL,
    [Modified_Date]      DATETIME        NULL,
    CONSTRAINT [PK_T0210_Salary_Budget_Details] PRIMARY KEY CLUSTERED ([SalBudget_DetailID] ASC)
);

