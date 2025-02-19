CREATE TABLE [dbo].[T0160_Late_Early_Validation] (
    [Trans_ID]          NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Cmp_ID]            NUMERIC (18)   NULL,
    [Emp_ID]            NUMERIC (18)   NULL,
    [Sal_Tran_ID]       NUMERIC (18)   NULL,
    [For_Date]          DATETIME       NULL,
    [Sal_Month]         NUMERIC (18)   NULL,
    [Sal_Year]          NUMERIC (18)   NULL,
    [Late_Sec]          NUMERIC (18)   NULL,
    [Early_Sec]         NUMERIC (18)   NULL,
    [Late_Deduction]    NUMERIC (3, 2) NULL,
    [Early_Deduction]   NUMERIC (3, 2) NULL,
    [Flag_No_Exepmtion] BIT            NULL,
    PRIMARY KEY CLUSTERED ([Trans_ID] ASC)
);

