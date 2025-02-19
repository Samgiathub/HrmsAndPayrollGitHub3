CREATE TABLE [dbo].[T0050_EXPENSE_TYPE_MAX_KM] (
    [Tran_ID]         NUMERIC (18)    NOT NULL,
    [Cmp_ID]          NUMERIC (18)    NOT NULL,
    [Expense_Type_ID] NUMERIC (18)    NOT NULL,
    [KM_Rate]         NUMERIC (18, 2) NOT NULL,
    [Grd_ID]          NUMERIC (18)    NULL,
    [Desig_ID]        NUMERIC (18)    NULL,
    [flag_grd_desig]  TINYINT         NULL,
    [Effective_date]  DATETIME        NULL,
    [Max_KM]          NUMERIC (18, 2) NOT NULL,
    CONSTRAINT [PK_T0050_EXPENSE_TYPE_MAX_KM] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

