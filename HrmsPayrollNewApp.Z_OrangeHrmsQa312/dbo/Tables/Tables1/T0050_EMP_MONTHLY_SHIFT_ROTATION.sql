CREATE TABLE [dbo].[T0050_EMP_MONTHLY_SHIFT_ROTATION] (
    [Cmp_ID]         NUMERIC (18) NOT NULL,
    [Tran_ID]        NUMERIC (18) NOT NULL,
    [Emp_ID]         NUMERIC (18) NOT NULL,
    [Rotation_ID]    NUMERIC (18) NOT NULL,
    [Effective_Date] DATETIME     NOT NULL,
    [SysDate]        DATETIME     NOT NULL,
    CONSTRAINT [PK_T0050_Emp_Monthly_Shift_Rotation] PRIMARY KEY CLUSTERED ([Tran_ID] ASC) WITH (FILLFACTOR = 80)
);

