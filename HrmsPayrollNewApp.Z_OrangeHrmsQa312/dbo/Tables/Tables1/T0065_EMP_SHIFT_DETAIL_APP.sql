CREATE TABLE [dbo].[T0065_EMP_SHIFT_DETAIL_APP] (
    [Emp_Tran_ID]        BIGINT      NOT NULL,
    [Emp_Application_ID] INT         NOT NULL,
    [Shift_Tran_ID]      INT         NOT NULL,
    [Cmp_ID]             INT         NOT NULL,
    [Shift_ID]           INT         NOT NULL,
    [Shift_Type]         NUMERIC (5) NULL,
    [Rotation_ID]        INT         NULL,
    [Approved_Emp_ID]    INT         NULL,
    [Approved_Date]      DATETIME    NULL,
    [Rpt_Level]          INT         NULL,
    CONSTRAINT [FK_T0065_EMP_SHIFT_DETAIL_APP_T0060_EMP_MASTER_APP] FOREIGN KEY ([Emp_Tran_ID]) REFERENCES [dbo].[T0060_EMP_MASTER_APP] ([Emp_Tran_ID])
);

