CREATE TABLE [dbo].[T0095_Emp_Salary_Cycle] (
    [Tran_id]        NUMERIC (18) IDENTITY (1, 1) NOT NULL,
    [Cmp_id]         NUMERIC (18) NOT NULL,
    [Emp_id]         NUMERIC (18) NOT NULL,
    [SalDate_id]     NUMERIC (18) NOT NULL,
    [Effective_date] DATETIME     NOT NULL,
    CONSTRAINT [PK_T0095_Emp_Salary_Cycle] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0095_Emp_Salary_Cycle_7_1338591957__K3_K5_K1_K2_4]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Emp_id] ASC, [Effective_date] ASC, [Tran_id] ASC, [Cmp_id] ASC)
    INCLUDE([SalDate_id]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_Emp_Salary_Cycle_Emp_ID_Effective_Date]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Emp_id] ASC, [Effective_date] ASC)
    INCLUDE([SalDate_id]) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_1338591957_1_5]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Tran_id], [Effective_date]);


GO
CREATE STATISTICS [_dta_stat_1338591957_3_1_5_2]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Emp_id], [Tran_id], [Effective_date], [Cmp_id]);


GO
CREATE STATISTICS [_dta_stat_1338591957_5_2_3]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Effective_date], [Cmp_id], [Emp_id]);


GO
CREATE STATISTICS [_dta_stat_1338591957_1_2_5]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Tran_id], [Cmp_id], [Effective_date]);


GO
CREATE STATISTICS [_dta_stat_1338591957_1_2_3]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Tran_id], [Cmp_id], [Emp_id]);


GO
CREATE STATISTICS [IS_T0095_Emp_Salary_Cycle_Effective_Date]
    ON [dbo].[T0095_Emp_Salary_Cycle]([Effective_date], [Emp_id]);

