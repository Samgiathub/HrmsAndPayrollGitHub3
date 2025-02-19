CREATE TABLE [dbo].[T0120_TS_Approval] (
    [Timesheet_Approval_ID] NUMERIC (18)  NOT NULL,
    [Project_Status_ID]     NUMERIC (18)  NULL,
    [Timesheet_ID]          NUMERIC (18)  NULL,
    [Employee_ID]           NUMERIC (18)  NULL,
    [Approval_By]           NUMERIC (18)  NULL,
    [Timesheet_Period]      VARCHAR (50)  NULL,
    [Approval_Remarks]      VARCHAR (MAX) NULL,
    [Cmp_ID]                NUMERIC (18)  NULL,
    [Created_By]            NUMERIC (18)  NULL,
    [Created_Date]          DATETIME      NULL,
    [Modify_By]             NUMERIC (18)  NULL,
    [Modify_Date]           DATETIME      NULL,
    [Attachment]            VARCHAR (MAX) NULL,
    CONSTRAINT [PK_T0120_TS_Approval] PRIMARY KEY CLUSTERED ([Timesheet_Approval_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_TS_Approval_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0120_TS_Approval_T0040_Project_Status] FOREIGN KEY ([Project_Status_ID]) REFERENCES [dbo].[T0040_Project_Status] ([Project_Status_ID]),
    CONSTRAINT [FK_T0120_TS_Approval_T0080_EMP_MASTER1] FOREIGN KEY ([Employee_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_TS_Approval_T0100_TS_Application] FOREIGN KEY ([Timesheet_ID]) REFERENCES [dbo].[T0100_TS_Application] ([Timesheet_ID])
);

