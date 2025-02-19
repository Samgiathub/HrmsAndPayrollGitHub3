CREATE TABLE [dbo].[T0302_Process_Detail] (
    [tran_id]            NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [cmp_id]             NUMERIC (18)    CONSTRAINT [DF_T0302_Process_Detail_cmp_id] DEFAULT ((0)) NOT NULL,
    [emp_id]             NUMERIC (18)    CONSTRAINT [DF_T0302_Process_Detail_emp_id] DEFAULT ((0)) NOT NULL,
    [For_Date]           DATETIME        NOT NULL,
    [process_type_id]    NUMERIC (18)    CONSTRAINT [DF_T0302_Process_Detail_process_type_id] DEFAULT ((0)) NOT NULL,
    [payment_process_id] NUMERIC (18)    CONSTRAINT [DF_T0302_Process_Detail_payment_process_id] DEFAULT ((0)) NOT NULL,
    [Ad_id]              NUMERIC (18)    CONSTRAINT [DF_T0302_Process_Detail_Ad_id] DEFAULT ((0)) NOT NULL,
    [Amount]             NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Amount] DEFAULT ((0)) NOT NULL,
    [Esic]               NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Esic] DEFAULT ((0)) NOT NULL,
    [Comp_Esic]          NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Comp_Esic] DEFAULT ((0)) NOT NULL,
    [Net_Amount]         NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Net_Amount] DEFAULT ((0)) NOT NULL,
    [modify_date]        DATETIME        CONSTRAINT [DF_T0302_Process_Detail_modify_date] DEFAULT (getdate()) NOT NULL,
    [TDS]                NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_TDS] DEFAULT ((0)) NOT NULL,
    [Loan_Id]            NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Loan_Id] DEFAULT ((0)) NOT NULL,
    [Leave_Id]           NUMERIC (18, 2) CONSTRAINT [DF_T0302_Process_Detail_Leave_Id] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0302_Process_Detail] PRIMARY KEY CLUSTERED ([tran_id] ASC) WITH (FILLFACTOR = 80)
);

