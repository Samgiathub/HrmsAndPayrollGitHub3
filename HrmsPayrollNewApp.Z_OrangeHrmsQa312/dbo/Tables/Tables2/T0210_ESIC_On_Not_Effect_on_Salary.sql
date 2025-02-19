CREATE TABLE [dbo].[T0210_ESIC_On_Not_Effect_on_Salary] (
    [Tran_Id]      NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [For_Date]     DATETIME        CONSTRAINT [DF_Table_1_Month] DEFAULT (getdate()) NOT NULL,
    [Cmp_Id]       NUMERIC (18)    NOT NULL,
    [Emp_Id]       NUMERIC (18)    CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Emp_Id] DEFAULT ((0)) NOT NULL,
    [Hours]        NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Hours] DEFAULT ((0)) NOT NULL,
    [Amount]       NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Amount] DEFAULT ((0)) NOT NULL,
    [Esic]         NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Esic] DEFAULT ((0)) NOT NULL,
    [Net_Amount]   NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Net_Amount] DEFAULT ((0)) NOT NULL,
    [Ad_Id]        NUMERIC (18)    CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Ad_Id] DEFAULT ((0)) NOT NULL,
    [Modify_Date]  DATETIME        CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Modify_Date] DEFAULT (getdate()) NOT NULL,
    [Comp_Esic]    NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Comp_Esic] DEFAULT ((0)) NOT NULL,
    [TDS]          NUMERIC (18, 2) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_TDS] DEFAULT ((0)) NOT NULL,
    [Loan_Amount]  NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Working_Days] NUMERIC (18, 4) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Working_Days] DEFAULT ((0)) NOT NULL,
    [Calculate_on] NUMERIC (18)    CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Calculate_on] DEFAULT ((0)) NOT NULL,
    [Hour_Rate]    NUMERIC (18, 4) CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Hour_Rate] DEFAULT ((0)) NOT NULL,
    [Shift_Sec]    NUMERIC (18)    CONSTRAINT [DF_T0210_ESIC_On_Not_Effect_on_Salary_Shift_Sec] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0210_ESIC_On_Not_Effect_on_Salary] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

