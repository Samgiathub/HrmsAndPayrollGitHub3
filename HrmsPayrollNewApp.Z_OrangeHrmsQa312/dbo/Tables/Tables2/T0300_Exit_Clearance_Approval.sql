CREATE TABLE [dbo].[T0300_Exit_Clearance_Approval] (
    [Approval_Id]   NUMERIC (18)  CONSTRAINT [DF_T0300_NOC_Approval_Tran_Id] DEFAULT ((0)) NOT NULL,
    [Cmp_ID]        NUMERIC (18)  CONSTRAINT [DF_T0300_NOC_Approval_Cmp_ID] DEFAULT ((0)) NOT NULL,
    [Request_Date]  DATETIME      NOT NULL,
    [Approval_Date] DATETIME      NULL,
    [Emp_ID]        NUMERIC (18)  CONSTRAINT [DF_T0300_NOC_Approval_Emp_ID] DEFAULT ((0)) NOT NULL,
    [Exit_ID]       NUMERIC (18)  CONSTRAINT [DF_T0300_NOC_Approval_Exit_ID] DEFAULT ((0)) NOT NULL,
    [Hod_ID]        NUMERIC (18)  CONSTRAINT [DF_Table_1_Hod_ID] DEFAULT ((0)) NOT NULL,
    [Noc_Status]    CHAR (1)      NOT NULL,
    [Remarks]       VARCHAR (MAX) NULL,
    [Sys_date]      DATETIME      CONSTRAINT [DF_T0300_NOC_Approval_Sys_date] DEFAULT (getdate()) NULL,
    [Dept_Id]       NUMERIC (18)  NULL,
    [Updated_By]    NUMERIC (18)  CONSTRAINT [DF_T0300_Exit_Clearance_Approval_User_Id] DEFAULT ((0)) NOT NULL,
    [Center_ID]     NUMERIC (18)  NULL
);

