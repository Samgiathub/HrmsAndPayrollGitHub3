CREATE TABLE [dbo].[T0240_Perquisites_Employee_Car] (
    [Tran_id]                  NUMERIC (18)    NOT NULL,
    [cmp_id]                   NUMERIC (18)    NOT NULL,
    [emp_id]                   NUMERIC (18)    NOT NULL,
    [perquisites_id]           NUMERIC (18)    NOT NULL,
    [Financial_Year]           NVARCHAR (30)   NOT NULL,
    [usage_type]               NUMERIC (18)    CONSTRAINT [DF_T0240_Perquisites_Employee_Car_usage_type] DEFAULT ((0)) NOT NULL,
    [owned_type]               NUMERIC (18)    CONSTRAINT [DF_T0240_Perquisites_Employee_Car_owned_type] DEFAULT ((0)) NOT NULL,
    [Actual_Expencse]          NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Actual_Expencse] DEFAULT ((0)) NOT NULL,
    [is_Depreciation]          TINYINT         CONSTRAINT [DF_T0240_Perquisites_Employee_Car_is_Depreciation] DEFAULT ((0)) NOT NULL,
    [Cost_of_car]              NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Cost_of_car] DEFAULT ((0)) NOT NULL,
    [Car_HP]                   NUMERIC (18)    CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Car_HP] DEFAULT ((0)) NOT NULL,
    [is_Chauffeur]             TINYINT         CONSTRAINT [DF_T0240_Perquisites_Employee_Car_is_Chauffeur] DEFAULT ((0)) NOT NULL,
    [Chauffeur_Salary]         NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Chauffeur_Salary] DEFAULT ((0)) NOT NULL,
    [no_of_month]              NUMERIC (18)    CONSTRAINT [DF_T0240_Perquisites_Employee_Car_no_of_month] DEFAULT ((0)) NOT NULL,
    [amount_recovered]         NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_amount_recovered] DEFAULT ((0)) NOT NULL,
    [Total_perq_Amt_per_month] NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Total_perq_Amt_per_month] DEFAULT ((0)) NOT NULL,
    [Total_perq_Amt]           NUMERIC (18, 2) CONSTRAINT [DF_T0240_Perquisites_Employee_Car_Total_perq_Amt] DEFAULT ((0)) NOT NULL,
    [Change_Date]              DATETIME        NOT NULL,
    CONSTRAINT [PK_T0240_Perquisites_Employee_Car] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

