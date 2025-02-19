CREATE TABLE [dbo].[T0210_PAYSLIP_DATA_DAILY_DAILY] (
    [PaySlip_Tran_ID]  NUMERIC (18)   NOT NULL,
    [Sal_Tran_ID]      NUMERIC (18)   NULL,
    [Cmp_ID]           NUMERIC (18)   NOT NULL,
    [Allowance_Data]   VARCHAR (8000) NULL,
    [Deduction_Data]   VARCHAR (8000) NULL,
    [Temp_Sal_Tran_ID] NUMERIC (18)   NULL
);

