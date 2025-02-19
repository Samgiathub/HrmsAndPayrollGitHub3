CREATE TABLE [dbo].[T0140_BACK_DATED_ARREAR_LEAVE] (
    [Tran_id]                NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Cmp_id]                 NUMERIC (18)    NOT NULL,
    [Emp_id]                 NUMERIC (18)    NOT NULL,
    [Leave_approval_id]      NUMERIC (18)    NOT NULL,
    [Arrear_Days]            NUMERIC (18, 2) CONSTRAINT [DF_T0140_BACK_DATED_ARREAR_LEAVE_Arrear_Days] DEFAULT ((0)) NOT NULL,
    [Present_import_tran_id] NUMERIC (18)    NOT NULL,
    [TimeStamp]              DATETIME        CONSTRAINT [DF_T0140_BACK_DATED_ARREAR_LEAVE_TimeStamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_T0140_BACK_DATED_ARREAR_LEAVE] PRIMARY KEY CLUSTERED ([Tran_id] ASC) WITH (FILLFACTOR = 80)
);

