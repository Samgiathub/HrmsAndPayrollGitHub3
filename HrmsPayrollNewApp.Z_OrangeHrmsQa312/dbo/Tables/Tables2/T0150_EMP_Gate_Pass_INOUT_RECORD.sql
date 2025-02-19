CREATE TABLE [dbo].[T0150_EMP_Gate_Pass_INOUT_RECORD] (
    [Tran_Id]        NUMERIC (18) NOT NULL,
    [cmp_Id]         NUMERIC (18) NOT NULL,
    [emp_id]         NUMERIC (18) NOT NULL,
    [For_date]       DATETIME     NOT NULL,
    [Out_Time]       DATETIME     NULL,
    [In_Time]        DATETIME     NULL,
    [Hours]          VARCHAR (10) CONSTRAINT [DF_T0150_EMP_Gate_Pass_INOUT_RECORD_Hours] DEFAULT ((0)) NOT NULL,
    [Reason_id]      NUMERIC (18) CONSTRAINT [DF_T0150_EMP_Gate_Pass_INOUT_RECORD_Reason_id] DEFAULT ((0)) NOT NULL,
    [Exempted]       TINYINT      CONSTRAINT [DF_T0150_EMP_Gate_Pass_INOUT_RECORD_Exempted] DEFAULT ((0)) NOT NULL,
    [IP_Address]     VARCHAR (50) NOT NULL,
    [Is_Approved]    TINYINT      CONSTRAINT [DF_T0150_EMP_Gate_Pass_INOUT_RECORD_Is_Approved] DEFAULT ((0)) NOT NULL,
    [Is_Default]     TINYINT      CONSTRAINT [DF_T0150_EMP_Gate_Pass_INOUT_RECORD_Is_Default] DEFAULT ((0)) NOT NULL,
    [Shift_St_Time]  VARCHAR (10) NULL,
    [Shift_End_Time] VARCHAR (10) NULL,
    [App_ID]         NUMERIC (18) NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_T0150_EMP_Gate_Pass_INOUT_RECORD_cmp_Id_emp_id_Is_ApprovedFor_date]
    ON [dbo].[T0150_EMP_Gate_Pass_INOUT_RECORD]([cmp_Id] ASC, [emp_id] ASC, [Is_Approved] ASC, [For_date] ASC) WITH (FILLFACTOR = 90);

