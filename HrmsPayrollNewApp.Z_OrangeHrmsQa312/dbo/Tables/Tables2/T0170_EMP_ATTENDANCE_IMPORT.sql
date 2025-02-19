CREATE TABLE [dbo].[T0170_EMP_ATTENDANCE_IMPORT] (
    [Tran_Id]     NUMERIC (18)    NOT NULL,
    [Emp_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]      NUMERIC (18)    NOT NULL,
    [Month]       NUMERIC (2)     NOT NULL,
    [Year]        NUMERIC (4)     NOT NULL,
    [Att_Detail]  NVARCHAR (4000) NOT NULL,
    [PresentDays] NUMERIC (18, 2) NOT NULL,
    [WeeklyOff]   NUMERIC (18)    NOT NULL,
    [Holiday]     NUMERIC (18)    NOT NULL,
    [Absent]      NUMERIC (18, 2) NOT NULL,
    [System_Date] DATETIME        NOT NULL,
    [Login_Id]    INT             NOT NULL,
    CONSTRAINT [PK_T0170_EMP_ATTENDANCE_IMPORT] PRIMARY KEY CLUSTERED ([Tran_Id] ASC) WITH (FILLFACTOR = 80)
);

