CREATE TABLE [dbo].[T0210_Monthly_Salary_Slip_Gradecount] (
    [Tran_Id]             NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Sal_tran_id]         NUMERIC (18)    NOT NULL,
    [Emp_id]              NUMERIC (18)    NOT NULL,
    [Cmp_id]              NUMERIC (18)    NOT NULL,
    [Sal_St_date]         DATETIME        NOT NULL,
    [Sal_End_date]        DATETIME        NOT NULL,
    [Actual_day_Count]    NUMERIC (18, 2) NULL,
    [Actual_night_count]  NUMERIC (18, 2) NULL,
    [Upgrade_day_count]   NUMERIC (18, 2) NULL,
    [Upgrade_night_count] NUMERIC (18, 2) NULL,
    [Day_Basic_Salary]    NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Night_Basic_Salary]  NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Day_Basic_DA]        NUMERIC (18, 2) NULL,
    [Night_Basic_DA]      NUMERIC (18, 2) NULL,
    [CL_Leave]            NUMERIC (18, 2) NULL,
    [AVG_SAL]             NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Grd_OT_Hours]        NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0210_Monthly_Salary_Slip_Gradecount] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0210_Monthly_Salary_Slip_Gradecount_T0200_MONTHLY_SALARY] FOREIGN KEY ([Sal_tran_id]) REFERENCES [dbo].[T0200_MONTHLY_SALARY] ([Sal_Tran_ID])
);

