CREATE TABLE [dbo].[T0165_Attendance_Approval] (
    [Att_Apr_ID]      NUMERIC (18)   NOT NULL,
    [Att_App_ID]      NUMERIC (18)   NULL,
    [Cmp_ID]          NUMERIC (18)   NULL,
    [Emp_ID]          NUMERIC (18)   NULL,
    [For_Date]        DATETIME       NULL,
    [Shift_Sec]       NUMERIC (18)   NULL,
    [P_Days]          NUMERIC (5, 2) NULL,
    [Att_Status]      CHAR (1)       NULL,
    [Approver_Emp_ID] NUMERIC (18)   NULL,
    [Remarks]         VARCHAR (500)  NULL,
    [Modify_By]       VARCHAR (10)   NULL,
    [Modify_Date]     DATETIME       NULL,
    [Ip_Address]      VARCHAR (20)   NULL,
    PRIMARY KEY CLUSTERED ([Att_Apr_ID] ASC)
);

