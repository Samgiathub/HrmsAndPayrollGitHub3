CREATE TABLE [dbo].[T0200_MONTHLY_SALARY_LEAVE] (
    [L_Sal_Tran_ID]           NUMERIC (18)    NOT NULL,
    [L_Sal_Receipt_No]        NUMERIC (18)    NOT NULL,
    [Emp_ID]                  NUMERIC (18)    NOT NULL,
    [Cmp_ID]                  NUMERIC (18)    NOT NULL,
    [Increment_ID]            NUMERIC (18)    NOT NULL,
    [L_Month_St_Date]         DATETIME        NOT NULL,
    [L_Month_End_Date]        DATETIME        NOT NULL,
    [L_Sal_Generate_Date]     DATETIME        NOT NULL,
    [L_Sal_Cal_Days]          NUMERIC (18, 4) NOT NULL,
    [L_Working_Days]          NUMERIC (18, 4) NOT NULL,
    [L_Outof_Days]            NUMERIC (18, 1) NULL,
    [L_Shift_Day_Sec]         NUMERIC (18)    NULL,
    [L_Shift_Day_Hour]        VARCHAR (20)    NULL,
    [L_Basic_Salary]          NUMERIC (18, 2) NULL,
    [L_Day_Salary]            NUMERIC (18, 5) NULL,
    [L_Hour_Salary]           NUMERIC (18, 5) NULL,
    [L_Salary_Amount]         NUMERIC (18, 2) NULL,
    [L_Allow_Amount]          NUMERIC (18, 2) NULL,
    [L_Other_Allow_Amount]    NUMERIC (18, 2) NULL,
    [L_Gross_Salary]          NUMERIC (18, 2) NULL,
    [L_Dedu_Amount]           NUMERIC (18, 2) NULL,
    [L_Loan_Amount]           NUMERIC (18, 2) NULL,
    [L_Loan_Intrest_Amount]   NUMERIC (18, 2) NULL,
    [L_Advance_Amount]        NUMERIC (18, 2) NULL,
    [L_Other_Dedu_Amount]     NUMERIC (18, 2) NULL,
    [L_Total_Dedu_Amount]     NUMERIC (18, 2) NULL,
    [L_Due_Loan_Amount]       NUMERIC (18, 2) NULL,
    [L_Net_Amount]            NUMERIC (18, 2) NULL,
    [L_Actually_Gross_Salary] NUMERIC (18, 2) NULL,
    [L_PT_Amount]             NUMERIC (18)    CONSTRAINT [DF_Table2_S_PT_Amount] DEFAULT ((0)) NULL,
    [L_PT_Calculated_Amount]  NUMERIC (18)    CONSTRAINT [DF_Table2_S_PT_Calculated_Amount] DEFAULT ((0)) NULL,
    [L_M_Adv_Amount]          NUMERIC (18)    NULL,
    [L_M_Loan_Amount]         NUMERIC (18)    NULL,
    [L_M_IT_Tax]              NUMERIC (18)    NULL,
    [L_LWF_Amount]            NUMERIC (18)    CONSTRAINT [DF_Table2_S_LWF_Amount] DEFAULT ((0)) NULL,
    [L_Revenue_Amount]        NUMERIC (18)    CONSTRAINT [DF_Table2_S_Revenue_Amount] DEFAULT ((0)) NULL,
    [L_PT_F_T_Limit]          VARCHAR (20)    NULL,
    [L_Sal_Type]              VARCHAR (20)    NULL,
    [L_Eff_Date]              DATETIME        NOT NULL,
    [Login_ID]                NUMERIC (18)    NOT NULL,
    [Modify_Date]             DATETIME        NOT NULL,
    [Is_FNF]                  TINYINT         CONSTRAINT [DF_T0200_MONTHLY_SALARY_LEAVE_Is_FNF] DEFAULT ((0)) NULL,
    [Sal_tran_ID]             NUMERIC (18)    NULL,
    CONSTRAINT [PK_T0200_MONTHLY_SALARY_LEAVE] PRIMARY KEY CLUSTERED ([L_Sal_Tran_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_LEAVE_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_LEAVE_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0200_MONTHLY_SALARY_LEAVE_T0095_INCREMENT] FOREIGN KEY ([Increment_ID]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0200_MONTHLY_SALARY_LEAVE_Sal_tran_ID]
    ON [dbo].[T0200_MONTHLY_SALARY_LEAVE]([Sal_tran_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0200_MONTHLY_SALARY_LEAVE_For_P0200_Pre_Salary]
    ON [dbo].[T0200_MONTHLY_SALARY_LEAVE]([Emp_ID] ASC, [Cmp_ID] ASC);

