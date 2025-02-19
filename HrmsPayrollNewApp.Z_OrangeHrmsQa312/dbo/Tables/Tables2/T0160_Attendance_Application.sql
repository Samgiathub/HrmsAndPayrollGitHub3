CREATE TABLE [dbo].[T0160_Attendance_Application] (
    [Att_App_ID]  NUMERIC (18)   NOT NULL,
    [Cmp_ID]      NUMERIC (18)   NULL,
    [Emp_ID]      NUMERIC (18)   NULL,
    [For_Date]    DATETIME       NULL,
    [Shift_Sec]   NUMERIC (18)   NULL,
    [P_Days]      NUMERIC (5, 2) NULL,
    [Modify_By]   VARCHAR (10)   NULL,
    [Modify_Date] DATETIME       NULL,
    [Ip_Address]  VARCHAR (20)   NULL,
    PRIMARY KEY CLUSTERED ([Att_App_ID] ASC)
);

