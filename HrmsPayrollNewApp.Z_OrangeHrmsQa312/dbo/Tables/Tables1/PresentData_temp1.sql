CREATE TABLE [dbo].[PresentData_temp1] (
    [Emp_Id]               NUMERIC (18)    NULL,
    [For_date]             DATETIME        NULL,
    [Duration_in_sec]      NUMERIC (18)    NULL,
    [Shift_ID]             NUMERIC (18)    NULL,
    [Shift_Type]           NUMERIC (18)    NULL,
    [Emp_OT]               NUMERIC (18)    NULL,
    [Emp_OT_min_Limit]     NUMERIC (18)    NULL,
    [Emp_OT_max_Limit]     NUMERIC (18)    NULL,
    [P_days]               NUMERIC (12, 3) DEFAULT ((0)) NULL,
    [OT_Sec]               NUMERIC (18)    DEFAULT ((0)) NULL,
    [In_Time]              DATETIME        NULL,
    [Shift_Start_Time]     DATETIME        NULL,
    [OT_Start_Time]        NUMERIC (18)    DEFAULT ((0)) NULL,
    [Shift_Change]         TINYINT         DEFAULT ((0)) NULL,
    [Flag]                 INT             DEFAULT ((0)) NULL,
    [Weekoff_OT_Sec]       NUMERIC (18)    DEFAULT ((0)) NULL,
    [Holiday_OT_Sec]       NUMERIC (18)    DEFAULT ((0)) NULL,
    [Chk_By_Superior]      NUMERIC (18)    DEFAULT ((0)) NULL,
    [IO_Tran_Id]           NUMERIC (18)    DEFAULT ((0)) NULL,
    [OUT_Time]             DATETIME        NULL,
    [Shift_End_Time]       DATETIME        NULL,
    [OT_End_Time]          NUMERIC (18)    DEFAULT ((0)) NULL,
    [Working_Hrs_St_Time]  TINYINT         DEFAULT ((0)) NULL,
    [Working_Hrs_End_Time] TINYINT         DEFAULT ((0)) NULL,
    [GatePass_Deduct_Days] NUMERIC (18, 2) DEFAULT ((0)) NULL
);


GO
CREATE CLUSTERED INDEX [ix_PresentData_temp1_Emp_Id_For_date]
    ON [dbo].[PresentData_temp1]([Emp_Id] ASC, [For_date] ASC) WITH (FILLFACTOR = 95);

